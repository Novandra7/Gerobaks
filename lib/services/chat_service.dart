import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../services/local_storage_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/end_user_api_service.dart';
import '../utils/api_routes.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final StreamController<List<ChatConversation>> _conversationsController =
      StreamController<List<ChatConversation>>.broadcast();

  final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();

  Stream<List<ChatConversation>> get conversationsStream =>
      _conversationsController.stream;
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  List<ChatConversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  final Map<int, int> _pickupRoomIds = {};
  late LocalStorageService _localStorage;
  late EndUserApiService _apiService;
  bool _isInitialized = false;

  // Initialize with local storage and API service
  Future<void> initializeData() async {
    if (_isInitialized) return;
    _localStorage = await LocalStorageService.getInstance();
    _apiService = EndUserApiService();
    await _loadConversationsFromAPI();
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await initializeData();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _localStorage.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  int? _extractPickupScheduleId(String conversationId) {
    if (!conversationId.startsWith('pickup_')) return null;
    return int.tryParse(conversationId.substring('pickup_'.length));
  }

  int? _extractPickupScheduleIdFromConversationTitle(String title) {
    final match = RegExp(
      r'pickup\s*#\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(title);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  String _resolvePickupConversationId(String conversationId) {
    if (conversationId.startsWith('pickup_')) return conversationId;

    final conversation = getConversationById(conversationId);
    if (conversation == null) return conversationId;

    final scheduleId = _extractPickupScheduleIdFromConversationTitle(
      conversation.title,
    );
    if (scheduleId == null) return conversationId;
    return 'pickup_$scheduleId';
  }

  dynamic _extractData(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  Future<Map<String, dynamic>?> _fetchPickupRoomByScheduleId(
    int pickupScheduleId,
  ) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('${ApiRoutes.baseUrl}/api/chat/rooms/$pickupScheduleId'),
      headers: headers,
    );

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    final data = _extractData(decoded);

    Map<String, dynamic>? asMap;
    if (data is Map<String, dynamic>) {
      asMap = data;
    } else if (data is Map) {
      asMap = Map<String, dynamic>.from(data);
    }

    if (asMap == null) return null;

    // API pickup room bisa mengembalikan payload berbentuk:
    // { room: {...}, participant_type: "mitra" }.
    // Normalisasi agar caller selalu bisa akses room['id'] / room['status'].
    final nestedRoom = asMap['room'];
    if (nestedRoom is Map<String, dynamic>) {
      final normalized = Map<String, dynamic>.from(nestedRoom);
      normalized['participant_type'] =
          asMap['participant_type'] ?? normalized['participant_type'];
      return normalized;
    }
    if (nestedRoom is Map) {
      final normalized = Map<String, dynamic>.from(nestedRoom);
      normalized['participant_type'] =
          asMap['participant_type'] ?? normalized['participant_type'];
      return normalized;
    }

    return asMap;
  }

  Future<List<dynamic>> _fetchPickupRoomMessagesRaw(int roomId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('${ApiRoutes.baseUrl}/api/chat/rooms/$roomId/messages'),
      headers: headers,
    );

    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body);
    final data = _extractData(decoded);

    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final candidate =
          data['messages'] ?? data['items'] ?? data['rows'] ?? data['data'];
      if (candidate is List) return candidate;
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final candidate =
          map['messages'] ?? map['items'] ?? map['rows'] ?? map['data'];
      if (candidate is List) return candidate;
    }
    return [];
  }

  Future<int?> _ensurePickupRoomId(String conversationId) async {
    final scheduleId = _extractPickupScheduleId(conversationId);
    if (scheduleId == null) return null;

    final cachedRoomId = _pickupRoomIds[scheduleId];
    if (cachedRoomId != null) return cachedRoomId;

    final room = await _fetchPickupRoomByScheduleId(scheduleId);
    if (room == null) return null;

    final roomId = int.tryParse(room['id']?.toString() ?? '');
    if (roomId != null) {
      _pickupRoomIds[scheduleId] = roomId;
    }
    return roomId;
  }

  Future<void> _refreshPickupConversation(String conversationId) async {
    final roomId = await _ensurePickupRoomId(conversationId);
    if (roomId == null) return;

    final messagesRaw = await _fetchPickupRoomMessagesRaw(roomId);
    final messages = await _mapPickupMessages(messagesRaw);

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final existing = _conversations[index];
    final lastMessage = messages.isNotEmpty ? messages.last.message : '';
    final lastTime = messages.isNotEmpty
        ? messages.last.timestamp
        : existing.lastMessageTime;

    _conversations[index] = ChatConversation(
      id: existing.id,
      title: existing.title,
      lastMessage: lastMessage,
      lastMessageTime: lastTime,
      isUnread: existing.isUnread,
      unreadCount: existing.unreadCount,
      adminName: existing.adminName,
      adminAvatar: existing.adminAvatar,
      messages: messages,
    );

    _currentMessages = messages;
    _messagesController.add(_currentMessages);
    _conversationsController.add(_conversations);
    await _saveConversationsToStorage();
  }

  Future<List<ChatMessage>> _mapPickupMessages(
    List<dynamic> rawMessages,
  ) async {
    final userRole = await _localStorage.getUserRole() ?? 'end_user';
    final currentSenderType = userRole == 'mitra' ? 'mitra' : 'user';

    final mapped = <ChatMessage>[];
    for (final item in rawMessages) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final senderType = map['sender_type']?.toString() ?? '';
      final isFromUser = senderType == 'user';
      final isMine = senderType == currentSenderType;

      final rawType = map['message_type']?.toString().toLowerCase() ?? 'text';
      final messageType = rawType == 'image'
          ? MessageType.image
          : rawType == 'voice'
          ? MessageType.voice
          : rawType == 'system_event'
          ? MessageType.system
          : MessageType.text;

      final sentAtRaw =
          map['sent_at'] ?? map['created_at'] ?? map['timestamp'] ?? '';
      final parsedTime =
          DateTime.tryParse(sentAtRaw.toString())?.toLocal() ?? DateTime.now();

      final messageText =
          map['message_text']?.toString() ??
          map['message']?.toString() ??
          map['text']?.toString() ??
          '';

      final attachment = map['attachment_url']?.toString();
      final fallbackAttachment = messageText.isNotEmpty ? messageText : null;

      mapped.add(
        ChatMessage(
          id: map['id']?.toString() ?? _generateId(),
          message:
              (messageType == MessageType.image ||
                  messageType == MessageType.voice)
              ? ''
              : messageText,
          timestamp: parsedTime,
          isFromUser: isFromUser,
          imageUrl: messageType == MessageType.image
              ? (attachment ?? fallbackAttachment)
              : null,
          voiceUrl: messageType == MessageType.voice
              ? (attachment ?? fallbackAttachment)
              : null,
          type: messageType,
        ),
      );

      // Update message status to delivered/read for incoming messages.
      if (!isMine &&
          map['id'] != null &&
          (map['status']?.toString() == 'sent' ||
              map['status']?.toString() == 'delivered')) {
        unawaited(_updatePickupMessageStatus(map['id'].toString(), 'read'));
      }
    }
    return mapped;
  }

  Future<void> _sendPickupMessage({
    required String conversationId,
    String messageText = '',
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    final optimisticMessageId = await _appendOptimisticPickupMessage(
      conversationId: conversationId,
      messageText: messageText,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
    );

    final roomId = await _ensurePickupRoomId(conversationId);
    if (roomId == null) {
      if (optimisticMessageId != null) {
        await _removeOptimisticPickupMessage(
          conversationId,
          optimisticMessageId,
        );
      }
      throw Exception('Pickup room tidak ditemukan');
    }

    final headers = await _getAuthHeaders();
    final attachmentValue = attachmentUrl?.trim() ?? '';
    final hasAttachment = attachmentValue.isNotEmpty;
    final isLocalAttachment =
        hasAttachment && !_isRemoteAttachmentUrl(attachmentValue);

    http.Response response;
    if (isLocalAttachment) {
      response = await _sendPickupMultipartMessageWithFallback(
        roomId: roomId,
        headers: headers,
        messageText: messageText,
        messageType: messageType,
        localAttachmentPath: attachmentValue,
      );
    } else {
      final body = <String, dynamic>{
        'message_text': messageText,
        'message_type': messageType,
      };
      if (hasAttachment) {
        body['attachment_url'] = attachmentValue;
      }

      response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}/api/chat/rooms/$roomId/messages'),
        headers: headers,
        body: jsonEncode(body),
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (optimisticMessageId != null) {
        await _removeOptimisticPickupMessage(
          conversationId,
          optimisticMessageId,
        );
      }
      throw Exception(
        'Gagal kirim pesan pickup (${response.statusCode} - ${response.body})',
      );
    }

    await _refreshPickupConversation(conversationId);
  }

  bool _isRemoteAttachmentUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'data';
  }

  Future<http.Response> _sendPickupMultipartMessageWithFallback({
    required int roomId,
    required Map<String, String> headers,
    required String messageText,
    required String messageType,
    required String localAttachmentPath,
  }) async {
    final uri = Uri.parse('${ApiRoutes.baseUrl}/api/chat/rooms/$roomId/messages');
    final fileFieldCandidates = <String>['attachment', 'file', 'image', 'media'];
    http.Response? lastResponse;

    for (final fieldName in fileFieldCandidates) {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields['message_text'] = messageText;
      request.fields['message_type'] = messageType;
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, localAttachmentPath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
      lastResponse = response;

      if (response.statusCode != 400 && response.statusCode != 422) {
        break;
      }
    }

    return lastResponse ?? http.Response('Upload attachment gagal', 500);
  }

  Future<String?> _appendOptimisticPickupMessage({
    required String conversationId,
    required String messageText,
    required String messageType,
    String? attachmentUrl,
  }) async {
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex == -1) return null;

    final userRole = await _localStorage.getUserRole() ?? 'end_user';
    final optimisticMessageId = 'local_${_generateId()}';
    final now = DateTime.now();
    final parsedMessageType = messageType == 'image'
        ? MessageType.image
        : messageType == 'voice'
        ? MessageType.voice
        : MessageType.text;

    final optimisticMessage = ChatMessage(
      id: optimisticMessageId,
      message: messageText,
      timestamp: now,
      isFromUser: userRole != 'mitra',
      imageUrl: parsedMessageType == MessageType.image
          ? (attachmentUrl ?? messageText)
          : null,
      voiceUrl: parsedMessageType == MessageType.voice
          ? (attachmentUrl ?? messageText)
          : null,
      type: parsedMessageType,
    );

    final conversation = _conversations[conversationIndex];
    final updatedMessages = List<ChatMessage>.from(conversation.messages)
      ..add(optimisticMessage);

    _conversations[conversationIndex] = ChatConversation(
      id: conversation.id,
      title: conversation.title,
      lastMessage: parsedMessageType == MessageType.text
          ? messageText
          : parsedMessageType == MessageType.image
          ? 'Mengirim gambar...'
          : 'Mengirim voice note...',
      lastMessageTime: now,
      isUnread: conversation.isUnread,
      unreadCount: conversation.unreadCount,
      adminName: conversation.adminName,
      adminAvatar: conversation.adminAvatar,
      messages: updatedMessages,
    );

    _currentMessages = updatedMessages;
    _messagesController.add(_currentMessages);
    _conversationsController.add(_conversations);
    await _saveConversationsToStorage();

    return optimisticMessageId;
  }

  Future<void> _removeOptimisticPickupMessage(
    String conversationId,
    String messageId,
  ) async {
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex == -1) return;

    final conversation = _conversations[conversationIndex];
    final updatedMessages = List<ChatMessage>.from(conversation.messages)
      ..removeWhere((message) => message.id == messageId);

    final lastMessage = updatedMessages.isNotEmpty
        ? updatedMessages.last
        : null;

    _conversations[conversationIndex] = ChatConversation(
      id: conversation.id,
      title: conversation.title,
      lastMessage: lastMessage?.message ?? '',
      lastMessageTime: lastMessage?.timestamp ?? conversation.lastMessageTime,
      isUnread: conversation.isUnread,
      unreadCount: conversation.unreadCount,
      adminName: conversation.adminName,
      adminAvatar: conversation.adminAvatar,
      messages: updatedMessages,
    );

    _currentMessages = updatedMessages;
    _messagesController.add(_currentMessages);
    _conversationsController.add(_conversations);
    await _saveConversationsToStorage();
  }

  Future<void> _markPickupRoomAsRead(String conversationId) async {
    final roomId = await _ensurePickupRoomId(conversationId);
    if (roomId == null) return;

    final headers = await _getAuthHeaders();
    final response = await http.patch(
      Uri.parse('${ApiRoutes.baseUrl}/api/chat/rooms/$roomId/read'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _refreshPickupConversation(conversationId);
    }
  }

  Future<void> _updatePickupMessageStatus(
    String messageId,
    String status,
  ) async {
    final headers = await _getAuthHeaders();
    await http.patch(
      Uri.parse('${ApiRoutes.baseUrl}/api/chat/messages/$messageId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
  }

  // Load conversations from API first, fallback to local storage
  Future<void> _loadConversationsFromAPI() async {
    try {
      // Try to load from API first
      final apiConversations = await _apiService.getChats();

      if (apiConversations.isNotEmpty) {
        // Convert API data to ChatConversation objects
        _conversations = apiConversations
            .map((data) => _convertApiToConversation(data))
            .toList();
      } else {
        // Fallback to local storage
        await _loadConversationsFromStorage();
      }

      _conversationsController.add(_conversations);
    } catch (e) {
      print('Error loading conversations from API: $e');
      // Fallback to local storage on error
      await _loadConversationsFromStorage();
    }
  }

  // Convert API chat data to ChatConversation model
  ChatConversation _convertApiToConversation(Map<String, dynamic> data) {
    return ChatConversation(
      id: data['id']?.toString() ?? _generateId(),
      title: data['title'] ?? 'Chat Support',
      lastMessage: data['last_message'] ?? '',
      lastMessageTime: data['last_message_time'] != null
          ? DateTime.parse(data['last_message_time']).toLocal()
          : DateTime.now(),
      isUnread: data['is_unread'] ?? false,
      unreadCount: data['unread_count'] ?? 0,
      adminName: data['admin_name'] ?? 'Customer Service',
      adminAvatar: data['admin_avatar'],
      messages:
          [], // Messages will be loaded separately when conversation is opened
    );
  }

  Future<void> _loadConversationsFromStorage() async {
    final storedConversations = await _localStorage.getConversations();

    if (storedConversations.isNotEmpty) {
      _conversations = storedConversations
          .map((data) => ChatConversation.fromJson(data))
          .toList();
    } else {
      // Initialize with sample data if no stored data
      _conversations = [
        ChatConversation(
          id: '1',
          title: 'Chat dengan Customer Service',
          lastMessage:
              'Terima kasih telah menghubungi kami. Ada yang bisa kami bantu?',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
          isUnread: true,
          unreadCount: 2,
          adminName: 'CS Gerobaks',
          messages: [
            ChatMessage(
              id: '1',
              message: 'Halo, selamat datang di Gerobaks!',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              isFromUser: false,
              type: MessageType.system,
            ),
            ChatMessage(
              id: '2',
              message:
                  'Halo, saya ingin bertanya tentang jadwal pengangkutan sampah',
              timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
              isFromUser: true,
            ),
            ChatMessage(
              id: '3',
              message:
                  'Terima kasih telah menghubungi kami. Ada yang bisa kami bantu?',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              isFromUser: false,
            ),
          ],
        ),
      ];
      await _saveConversationsToStorage();
    }

    _conversationsController.add(_conversations);
  }

  Future<void> _saveConversationsToStorage() async {
    final conversationsData = _conversations
        .map((conv) => conv.toJson())
        .toList();
    await _localStorage.saveConversations(conversationsData);
  }

  // Get all conversations
  List<ChatConversation> getConversations() {
    return List.from(_conversations);
  }

  // Get conversation by ID
  ChatConversation? getConversationById(String conversationId) {
    try {
      return _conversations.firstWhere((c) => c.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // Get messages for specific conversation
  List<ChatMessage> getMessages(String conversationId) {
    if (conversationId.startsWith('pickup_')) {
      unawaited(_refreshPickupConversation(conversationId));
    }
    final conversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => throw Exception('Conversation not found'),
    );
    _currentMessages = List.from(conversation.messages);
    _messagesController.add(_currentMessages);
    return _currentMessages;
  }

  // Send message with user role awareness
  Future<void> sendMessage(String conversationId, String message) async {
    // Get current user role
    final localStorage = await LocalStorageService.getInstance();
    final userRole = await localStorage.getUserRole() ?? 'end_user';
    final resolvedConversationId = _resolvePickupConversationId(conversationId);
    final isPickupConversation = resolvedConversationId.startsWith('pickup_');

    final bool isMitraUser = userRole == 'mitra';

    if (isPickupConversation) {
      await _sendPickupMessage(
        conversationId: resolvedConversationId,
        messageText: message,
      );
      return;
    }

    final newMessage = ChatMessage(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      isFromUser:
          !isMitraUser, // For mitra, they are representing the system/admin side
    );

    // Generic conversation tidak lagi pakai default receiver hardcoded.
    // Endpoint pickup chat sudah ditangani di cabang isPickupConversation di atas.

    // Add to conversation
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedMessages = List<ChatMessage>.from(conversation.messages)
        ..add(newMessage);

      String adminName = conversation.adminName;
      String? adminAvatar = conversation.adminAvatar;

      // Update admin info if this is a mitra user
      if (isMitraUser) {
        try {
          final rawUserData = await localStorage.getRawUser();
          if (rawUserData != null) {
            adminName = rawUserData['name'] ?? 'Mitra Gerobaks';
            adminAvatar =
                rawUserData['profilePicUrl'] ?? conversation.adminAvatar;
          }
        } catch (e) {
          print('Error getting user data for chat: $e');
        }
      }

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: message,
        lastMessageTime: DateTime.now(),
        isUnread: conversation.isUnread,
        unreadCount: conversation.unreadCount,
        adminName: adminName,
        adminAvatar: adminAvatar,
        messages: updatedMessages,
      );

      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();

      // Generate AI response only for generic CS conversation.
      if (!isMitraUser && !isPickupConversation) {
        Timer(const Duration(seconds: 1), () {
          _generateAIResponse(conversationId, message);
        });
      }
    }
  }

  // Generate AI response using Gemini
  void _generateAIResponse(String conversationId, String userMessage) async {
    try {
      final geminiService = GeminiAIService();

      // Get conversation history for context
      final conversationIndex = _conversations.indexWhere(
        (c) => c.id == conversationId,
      );
      if (conversationIndex == -1) return;

      final conversation = _conversations[conversationIndex];

      // First show typing indicator
      final typingMessage = ChatMessage(
        id: _generateId(),
        message: "${conversation.adminName} is typing...",
        timestamp: DateTime.now(),
        isFromUser: false,
        type: MessageType.typing,
      );

      final updatedMessagesWithTyping = List<ChatMessage>.from(
        conversation.messages,
      )..add(typingMessage);

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: conversation.lastMessage,
        lastMessageTime: conversation.lastMessageTime,
        isUnread: conversation.isUnread,
        unreadCount: conversation.unreadCount,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: updatedMessagesWithTyping,
      );

      _currentMessages = updatedMessagesWithTyping;
      _messagesController.add(_currentMessages);

      // Get context for AI
      final recentMessages = conversation.messages
          .where((m) => m.type == MessageType.text)
          .take(10)
          .map((m) => '${m.isFromUser ? "User" : "Admin"}: ${m.message}')
          .toList();

      // Create a more personalized prompt
      String prompt =
          '''
      You are a helpful customer service agent named ${conversation.adminName} for Gerobaks, a waste management service app in Indonesia.
      Be friendly, informative, and speak in Bahasa Indonesia with occasional Indonesian slang for a natural conversation flow.
      Keep responses concise (2-3 sentences max). Use emoji occasionally 😊.
      
      Provide helpful information about:
      - Waste collection schedules and tracking
      - Subscription plans and payment options
      - Technical issues with the app
      - Reward points and redemption
      - Recycling and waste management tips
      
      Here's the recent conversation history:
      ${recentMessages.join('\n')}
      
      User's latest message: $userMessage
      
      Respond as ${conversation.adminName}:
      ''';

      // Generate AI response with realistic typing delay
      final baseTypingDelay = 1000 + (userMessage.length * 15).clamp(0, 3000);
      await Future.delayed(Duration(milliseconds: baseTypingDelay));

      final aiResponse = await geminiService.generateResponse(
        prompt,
        conversationHistory: recentMessages,
      );

      // Remove typing indicator and add actual response
      final filteredMessages = List<ChatMessage>.from(
        conversation.messages,
      ).where((m) => m.type != MessageType.typing).toList();

      final adminMessage = ChatMessage(
        id: _generateId(),
        message: aiResponse,
        timestamp: DateTime.now(),
        isFromUser: false,
      );

      // Add AI response to conversation
      final updatedMessages = List<ChatMessage>.from(filteredMessages)
        ..add(adminMessage);

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: aiResponse.length > 50
            ? '${aiResponse.substring(0, 50)}...'
            : aiResponse,
        lastMessageTime: DateTime.now(),
        isUnread: true,
        unreadCount: conversation.unreadCount + 1,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: updatedMessages,
      );

      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    } catch (e) {
      print('Error generating AI response: $e');
      // Fallback to simple response if AI fails
      _generateFallbackResponse(conversationId);
    }
  }

  // Fallback response if AI service fails
  void _generateFallbackResponse(String conversationId) async {
    final responses = [
      'Terima kasih atas pertanyaannya. Tim customer service Gerobaks siap membantu Anda! 😊',
      'Hai! Saya akan membantu Anda dengan layanan pengelolaan sampah Gerobaks.',
      'Mohon tunggu sebentar, saya akan cek informasinya untuk Anda.',
      'Ada yang bisa saya bantu terkait layanan Gerobaks hari ini?',
      'Tim Gerobaks selalu siap memberikan solusi terbaik untuk pengelolaan sampah Anda.',
      'Maaf, saya perlu waktu untuk memeriksa informasi tersebut. Boleh tunggu sebentar?',
      'Terima kasih sudah menghubungi Gerobaks. Kami akan segera memproses permintaan Anda.',
      'Siap! Akan saya bantu selesaikan masalah Anda segera.',
      'Kami sangat menghargai masukan Anda untuk layanan Gerobaks yang lebih baik.',
      'Mohon maaf atas ketidaknyamanannya. Kami akan berusaha menyelesaikan masalah ini secepatnya.',
    ];

    // Get conversation
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex == -1) return;

    final conversation = _conversations[conversationIndex];

    // First show typing indicator
    final typingMessage = ChatMessage(
      id: _generateId(),
      message: "${conversation.adminName} is typing...",
      timestamp: DateTime.now(),
      isFromUser: false,
      type: MessageType.typing,
    );

    final updatedMessagesWithTyping = List<ChatMessage>.from(
      conversation.messages,
    )..add(typingMessage);

    _conversations[conversationIndex] = ChatConversation(
      id: conversation.id,
      title: conversation.title,
      lastMessage: conversation.lastMessage,
      lastMessageTime: conversation.lastMessageTime,
      isUnread: conversation.isUnread,
      unreadCount: conversation.unreadCount,
      adminName: conversation.adminName,
      adminAvatar: conversation.adminAvatar,
      messages: updatedMessagesWithTyping,
    );

    _currentMessages = updatedMessagesWithTyping;
    _messagesController.add(_currentMessages);

    // Add a small delay to simulate typing
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1500)));

    final randomResponse = responses[Random().nextInt(responses.length)];

    // Remove typing indicator and add actual response
    final filteredMessages = List<ChatMessage>.from(
      conversation.messages,
    ).where((m) => m.type != MessageType.typing).toList();

    final adminMessage = ChatMessage(
      id: _generateId(),
      message: randomResponse,
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    final updatedMessages = List<ChatMessage>.from(filteredMessages)
      ..add(adminMessage);

    _conversations[conversationIndex] = ChatConversation(
      id: conversation.id,
      title: conversation.title,
      lastMessage: randomResponse,
      lastMessageTime: DateTime.now(),
      isUnread: true,
      unreadCount: conversation.unreadCount + 1,
      adminName: conversation.adminName,
      adminAvatar: conversation.adminAvatar,
      messages: updatedMessages,
    );

    _currentMessages = updatedMessages;
    _messagesController.add(_currentMessages);
    _conversationsController.add(_conversations);
    await _saveConversationsToStorage();
  }

  // Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    if (conversationId.startsWith('pickup_')) {
      await _markPickupRoomAsRead(conversationId);
      return;
    }

    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];

      if (conversation.isUnread) {
        _conversations[conversationIndex] = ChatConversation(
          id: conversation.id,
          title: conversation.title,
          lastMessage: conversation.lastMessage,
          lastMessageTime: conversation.lastMessageTime,
          isUnread: false,
          unreadCount: 0,
          adminName: conversation.adminName,
          adminAvatar: conversation.adminAvatar,
          messages: conversation.messages,
        );

        _conversationsController.add(_conversations);
        await _saveConversationsToStorage();
      }
    }
  }

  // For backward compatibility
  Future<void> markAsRead(String conversationId) async {
    return markConversationAsRead(conversationId);
  }

  // Clear conversation (delete all messages)
  Future<void> clearConversation(String conversationId) async {
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];

      final initialMessage = ChatMessage(
        id: _generateId(),
        message: 'Riwayat chat telah dihapus',
        timestamp: DateTime.now(),
        isFromUser: false,
        type: MessageType.system,
      );

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: 'Riwayat chat telah dihapus',
        lastMessageTime: DateTime.now(),
        isUnread: false,
        unreadCount: 0,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: [initialMessage],
      );

      _currentMessages = [initialMessage];
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    }
  }

  // Simulate admin response
  Future<void> simulateAdminResponse(String conversationId) async {
    final adminResponses = [
      'Terima kasih atas pertanyaannya. Tim admin Gerobaks siap membantu Anda!',
      'Mohon tunggu sebentar, kami sedang memeriksa informasi terkait pertanyaan Anda.',
      'Kami sudah menerima pesan Anda dan akan menindaklanjuti segera.',
      'Apakah ada informasi tambahan yang dapat Anda berikan?',
      'Untuk mempercepat proses, mohon sertakan ID transaksi jika ada.',
      'Kami akan segera menghubungi tim lapangan untuk menindaklanjuti laporan Anda.',
    ];

    final randomResponse =
        adminResponses[Random().nextInt(adminResponses.length)];

    final adminMessage = ChatMessage(
      id: _generateId(),
      message: randomResponse,
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedMessages = List<ChatMessage>.from(conversation.messages)
        ..add(adminMessage);

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: randomResponse,
        lastMessageTime: DateTime.now(),
        isUnread: true,
        unreadCount: conversation.unreadCount + 1,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: updatedMessages,
      );

      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    }
  }

  // Simulate user response
  Future<void> simulateUserResponse(String conversationId) async {
    final userResponses = [
      'Terima kasih informasinya. Saya akan menunggu pengambilan sampah sesuai jadwal.',
      'Kapan jadwal pengambilan sampah di lokasi saya?',
      'Saya mengalami masalah dengan aplikasi, bisa dibantu?',
      'Sampah saya belum diambil sesuai jadwal, bagaimana tindak lanjutnya?',
      'Saya ingin memberikan masukan untuk pelayanan Gerobaks.',
      'Mohon bantuan untuk konfirmasi pembayaran saya.',
    ];

    final randomResponse =
        userResponses[Random().nextInt(userResponses.length)];

    final userMessage = ChatMessage(
      id: _generateId(),
      message: randomResponse,
      timestamp: DateTime.now(),
      isFromUser: false,
    );

    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedMessages = List<ChatMessage>.from(conversation.messages)
        ..add(userMessage);

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: randomResponse,
        lastMessageTime: DateTime.now(),
        isUnread: true,
        unreadCount: conversation.unreadCount + 1,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: updatedMessages,
      );

      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    }
  }

  // Create new conversation
  Future<String> createNewConversation({
    String title = 'Chat dengan Customer Service',
    String adminName = 'Customer Service',
    String? adminAvatar,
  }) async {
    final String conversationId = _generateId();
    final now = DateTime.now();

    final initialMessage = ChatMessage(
      id: _generateId(),
      message: 'Halo, selamat datang di Gerobaks!',
      timestamp: now,
      isFromUser: false,
      type: MessageType.system,
    );

    final newConversation = ChatConversation(
      id: conversationId,
      title: title,
      lastMessage: 'Halo, selamat datang di Gerobaks!',
      lastMessageTime: now,
      isUnread: false,
      unreadCount: 0,
      adminName: adminName,
      adminAvatar: adminAvatar,
      messages: [initialMessage],
    );

    _conversations.add(newConversation);
    _conversationsController.add(_conversations);
    await _saveConversationsToStorage();

    return conversationId;
  }

  /// Get or create dedicated pickup conversation (one room per pickup schedule).
  Future<String> getOrCreatePickupConversation({
    required int pickupScheduleId,
    required String counterpartName,
  }) async {
    await _ensureInitialized();

    final conversationId = 'pickup_$pickupScheduleId';
    final title = 'Pickup #$pickupScheduleId';
    final sanitizedCounterpartName = counterpartName.trim().isNotEmpty
        ? counterpartName.trim()
        : 'Mitra/User';

    final room = await _fetchPickupRoomByScheduleId(pickupScheduleId);
    final roomId = int.tryParse(room?['id']?.toString() ?? '');
    if (roomId != null) {
      _pickupRoomIds[pickupScheduleId] = roomId;
    }

    final messagesRaw = roomId != null
        ? await _fetchPickupRoomMessagesRaw(roomId)
        : <dynamic>[];
    final messages = await _mapPickupMessages(messagesRaw);

    final existingIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    final conversation = ChatConversation(
      id: conversationId,
      title: title,
      lastMessage: messages.isNotEmpty ? messages.last.message : '',
      lastMessageTime: messages.isNotEmpty
          ? messages.last.timestamp
          : DateTime.now(),
      isUnread: false,
      unreadCount: 0,
      adminName: sanitizedCounterpartName,
      messages: messages,
    );

    if (existingIndex == -1) {
      _conversations.add(conversation);
    } else {
      _conversations[existingIndex] = conversation;
    }
    _conversationsController.add(_conversations);
    await _saveConversationsToStorage();

    return conversationId;
  }

  /// Cache-first: langsung kembalikan conversation id agar page bisa dibuka
  /// tanpa menunggu fetch riwayat dari API. Sinkronisasi backend berjalan
  /// asynchronous di background.
  Future<String> getOrCreatePickupConversationFast({
    required int pickupScheduleId,
    required String counterpartName,
  }) async {
    await _ensureInitialized();

    final conversationId = 'pickup_$pickupScheduleId';
    final title = 'Pickup #$pickupScheduleId';
    final sanitizedCounterpartName = counterpartName.trim().isNotEmpty
        ? counterpartName.trim()
        : 'Mitra/User';

    final existingIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );

    if (existingIndex == -1) {
      _conversations.add(
        ChatConversation(
          id: conversationId,
          title: title,
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          isUnread: false,
          unreadCount: 0,
          adminName: sanitizedCounterpartName,
          messages: const [],
        ),
      );
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    } else if (_conversations[existingIndex].adminName.isEmpty) {
      final existing = _conversations[existingIndex];
      _conversations[existingIndex] = ChatConversation(
        id: existing.id,
        title: existing.title,
        lastMessage: existing.lastMessage,
        lastMessageTime: existing.lastMessageTime,
        isUnread: existing.isUnread,
        unreadCount: existing.unreadCount,
        adminName: sanitizedCounterpartName,
        adminAvatar: existing.adminAvatar,
        messages: existing.messages,
      );
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    }

    unawaited(
      getOrCreatePickupConversation(
        pickupScheduleId: pickupScheduleId,
        counterpartName: counterpartName,
      ),
    );

    return conversationId;
  }

  // Get total unread count
  int getTotalUnreadCount() {
    return _conversations.fold(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
  }

  // Send image message
  Future<void> sendImageMessage(String conversationId, String imageUrl) async {
    if (conversationId.startsWith('pickup_')) {
      await _sendPickupMessage(
        conversationId: conversationId,
        messageText: '',
        attachmentUrl: imageUrl,
        messageType: 'image',
      );
      return;
    }

    final localStorage = await LocalStorageService.getInstance();
    final userRole = await localStorage.getUserRole() ?? 'end_user';
    final isMitraUser = userRole == 'mitra';

    final newMessage = ChatMessage(
      id: _generateId(),
      message: 'Image sent',
      timestamp: DateTime.now(),
      isFromUser: !isMitraUser,
      imageUrl: imageUrl,
      type: MessageType.image,
    );

    // Add to conversation
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedMessages = List<ChatMessage>.from(conversation.messages)
        ..add(newMessage);

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: 'Sent an image',
        lastMessageTime: DateTime.now(),
        isUnread: conversation.isUnread,
        unreadCount: conversation.unreadCount,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: updatedMessages,
      );

      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    }
  }

  // Send voice message
  Future<void> sendVoiceMessage(
    String conversationId,
    String voiceUrl,
    int durationInSeconds,
  ) async {
    if (conversationId.startsWith('pickup_')) {
      await _sendPickupMessage(
        conversationId: conversationId,
        messageText: '',
        attachmentUrl: voiceUrl,
        messageType: 'voice',
      );
      return;
    }

    final localStorage = await LocalStorageService.getInstance();
    final userRole = await localStorage.getUserRole() ?? 'end_user';
    final isMitraUser = userRole == 'mitra';

    final newMessage = ChatMessage(
      id: _generateId(),
      message: 'Voice message',
      timestamp: DateTime.now(),
      isFromUser: !isMitraUser,
      voiceUrl: voiceUrl,
      voiceDuration: durationInSeconds,
      type: MessageType.voice,
    );

    // Add to conversation
    final conversationIndex = _conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (conversationIndex != -1) {
      final conversation = _conversations[conversationIndex];
      final updatedMessages = List<ChatMessage>.from(conversation.messages)
        ..add(newMessage);

      _conversations[conversationIndex] = ChatConversation(
        id: conversation.id,
        title: conversation.title,
        lastMessage: 'Sent a voice message',
        lastMessageTime: DateTime.now(),
        isUnread: conversation.isUnread,
        unreadCount: conversation.unreadCount,
        adminName: conversation.adminName,
        adminAvatar: conversation.adminAvatar,
        messages: updatedMessages,
      );

      _currentMessages = updatedMessages;
      _messagesController.add(_currentMessages);
      _conversationsController.add(_conversations);
      await _saveConversationsToStorage();
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void dispose() {
    _conversationsController.close();
    _messagesController.close();
  }
}
