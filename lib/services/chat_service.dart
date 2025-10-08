import 'dart:async';
import 'dart:math';
import '../models/chat_model.dart';
import '../services/local_storage_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/end_user_api_service.dart';

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
  late LocalStorageService _localStorage;
  late EndUserApiService _apiService;

  // Initialize with local storage and API service
  Future<void> initializeData() async {
    _localStorage = await LocalStorageService.getInstance();
    _apiService = EndUserApiService();
    await _loadConversationsFromAPI();
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
          ? DateTime.parse(data['last_message_time'])
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

    final bool isMitraUser = userRole == 'mitra';

    final newMessage = ChatMessage(
      id: _generateId(),
      message: message,
      timestamp: DateTime.now(),
      isFromUser:
          !isMitraUser, // For mitra, they are representing the system/admin side
    );

    // Send message to API first
    try {
      await _apiService.sendMessage(
        1, // Default receiver ID for customer service
        message,
      );
    } catch (e) {
      print('Error sending message to API: $e');
      // Continue with local storage even if API fails
    }

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

      // Generate AI response only if user is end_user (not mitra)
      if (!isMitraUser) {
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

  // Get total unread count
  int getTotalUnreadCount() {
    return _conversations.fold(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
  }

  // Send image message
  Future<void> sendImageMessage(String conversationId, String imageUrl) async {
    final newMessage = ChatMessage(
      id: _generateId(),
      message: 'Image sent',
      timestamp: DateTime.now(),
      isFromUser: true,
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
    final newMessage = ChatMessage(
      id: _generateId(),
      message: 'Voice message',
      timestamp: DateTime.now(),
      isFromUser: true,
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
