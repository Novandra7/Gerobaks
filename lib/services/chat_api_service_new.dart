import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Chat Message Model untuk API response
class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final int? orderId;
  final String message;
  final String type;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.orderId,
    required this.message,
    required this.type,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id']?.toInt() ?? 0,
      senderId: map['sender_id']?.toInt() ?? 0,
      receiverId: map['receiver_id']?.toInt() ?? 0,
      orderId: map['order_id']?.toInt(),
      message: map['message'] ?? '',
      type: map['type'] ?? 'text',
      attachmentUrl: map['attachment_url'],
      attachmentType: map['attachment_type'],
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'order_id': orderId,
      'message': message,
      'type': type,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isTextMessage => type == 'text';
  bool get isImageMessage => type == 'image';
  bool get isAudioMessage => type == 'audio';
  bool get isFileMessage => type == 'file';
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  
  bool isFromCurrentUser(int currentUserId) => senderId == currentUserId;
}

/// Chat Conversation Model
class ChatConversation {
  final int participantId;
  final String participantName;
  final String? participantAvatar;
  final String participantRole;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime? lastActivity;

  ChatConversation({
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.participantRole,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      participantId: map['participant_id']?.toInt() ?? 0,
      participantName: map['participant_name'] ?? '',
      participantAvatar: map['participant_avatar'],
      participantRole: map['participant_role'] ?? 'end_user',
      lastMessage: map['last_message'] != null 
          ? ChatMessage.fromMap(map['last_message'])
          : null,
      unreadCount: map['unread_count']?.toInt() ?? 0,
      lastActivity: map['last_activity'] != null
          ? DateTime.parse(map['last_activity'])
          : null,
    );
  }

  bool get hasUnreadMessages => unreadCount > 0;
  String get lastMessagePreview {
    if (lastMessage == null) return 'Belum ada pesan';
    
    switch (lastMessage!.type) {
      case 'image':
        return '📷 Gambar';
      case 'audio':
        return '🎵 Pesan suara';
      case 'file':
        return '📁 File';
      default:
        return lastMessage!.message.length > 50
            ? '${lastMessage!.message.substring(0, 50)}...'
            : lastMessage!.message;
    }
  }
}

/// Service untuk mengelola chat dan pesan
class ChatApiService {
  ChatApiService._internal();
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get chat messages between current user and another user
  /// [participantId] - ID user lawan bicara
  /// [orderId] - filter berdasarkan order ID (optional)
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 50)
  Future<List<ChatMessage>> getChatMessages({
    required int participantId,
    int? orderId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        'participant_id': participantId,
        if (orderId != null) 'order_id': orderId,
        'page': page,
        'limit': limit,
      };

      final response = await _api.getJson(ApiRoutes.chats, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => ChatMessage.fromMap(item)).toList();
      }

      throw Exception('Failed to load chat messages');
    } catch (e) {
      print('❌ Failed to get chat messages: $e');
      rethrow;
    }
  }

  /// Send text message
  Future<ChatMessage> sendTextMessage({
    required int receiverId,
    required String message,
    int? orderId,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final requestData = {
        'receiver_id': receiverId,
        'message': message,
        'type': 'text',
        if (orderId != null) 'order_id': orderId,
      };

      final response = await _api.postJson(ApiRoutes.chats, requestData);
      
      if (response != null && response['success'] == true) {
        return ChatMessage.fromMap(response['data']);
      }

      throw Exception('Failed to send message');
    } catch (e) {
      print('❌ Failed to send text message: $e');
      rethrow;
    }
  }

  /// Send image message (placeholder - would need file upload implementation)
  Future<ChatMessage> sendImageMessage({
    required int receiverId,
    required String imagePath,
    String? caption,
    int? orderId,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      // This would typically involve file upload to server first
      // Then send the message with the uploaded image URL
      
      final requestData = {
        'receiver_id': receiverId,
        'message': caption ?? 'Mengirim gambar',
        'type': 'image',
        'attachment_url': imagePath, // This would be the uploaded URL
        'attachment_type': 'image',
        if (orderId != null) 'order_id': orderId,
      };

      final response = await _api.postJson(ApiRoutes.chats, requestData);
      
      if (response != null && response['success'] == true) {
        return ChatMessage.fromMap(response['data']);
      }

      throw Exception('Failed to send image');
    } catch (e) {
      print('❌ Failed to send image message: $e');
      rethrow;
    }
  }

  /// Send audio message (placeholder - would need file upload implementation)
  Future<ChatMessage> sendAudioMessage({
    required int receiverId,
    required String audioPath,
    String? caption,
    int? orderId,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      // This would typically involve file upload to server first
      // Then send the message with the uploaded audio URL
      
      final requestData = {
        'receiver_id': receiverId,
        'message': caption ?? 'Mengirim pesan suara',
        'type': 'audio',
        'attachment_url': audioPath, // This would be the uploaded URL
        'attachment_type': 'audio',
        if (orderId != null) 'order_id': orderId,
      };

      final response = await _api.postJson(ApiRoutes.chats, requestData);
      
      if (response != null && response['success'] == true) {
        return ChatMessage.fromMap(response['data']);
      }

      throw Exception('Failed to send audio');
    } catch (e) {
      print('❌ Failed to send audio message: $e');
      rethrow;
    }
  }

  /// Get chat conversations list for current user
  Future<List<ChatConversation>> getChatConversations() async {
    try {
      _authManager.requireAuth(); // Requires authentication

      // This would call an endpoint that returns conversations grouped by participant
      // For now, we'll simulate by calling the regular chat endpoint
      final query = <String, dynamic>{
        'conversations': true,
        'limit': 20,
      };

      final response = await _api.getJson(ApiRoutes.chats, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => ChatConversation.fromMap(item)).toList();
      }

      throw Exception('Failed to load conversations');
    } catch (e) {
      print('❌ Failed to get conversations: $e');
      return []; // Return empty list on error
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required int participantId,
    int? orderId,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final requestData = {
        'participant_id': participantId,
        'action': 'mark_read',
        if (orderId != null) 'order_id': orderId,
      };

      final response = await _api.postJson('${ApiRoutes.chats}/mark-read', requestData);
      
      if (response == null || response['success'] != true) {
        throw Exception('Failed to mark messages as read');
      }
    } catch (e) {
      print('❌ Failed to mark messages as read: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Get unread messages count
  Future<int> getUnreadMessagesCount() async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final conversations = await getChatConversations();
      return conversations.fold<int>(0, (total, conv) => total + conv.unreadCount);
    } catch (e) {
      print('❌ Failed to get unread messages count: $e');
      return 0;
    }
  }

  /// Get conversation with specific user
  Future<ChatConversation?> getConversationWith(int participantId) async {
    try {
      final conversations = await getChatConversations();
      return conversations.where((conv) => conv.participantId == participantId).firstOrNull;
    } catch (e) {
      print('❌ Failed to get conversation with user $participantId: $e');
      return null;
    }
  }

  /// Start conversation with mitra for order
  Future<ChatMessage> startOrderConversation({
    required int mitraId,
    required int orderId,
    String? initialMessage,
  }) async {
    final message = initialMessage ?? 'Halo, saya ingin menanyakan tentang order #$orderId';
    return await sendTextMessage(
      receiverId: mitraId,
      message: message,
      orderId: orderId,
    );
  }

  /// Get message types
  List<String> getMessageTypes() {
    return ['text', 'image', 'audio', 'file'];
  }

  /// Check if user can send messages
  bool canSendMessages() {
    return _authManager.isAuthenticated; // All authenticated users can send messages
  }

  /// Check if current user can chat with specific user
  bool canChatWith(int userId, String userRole) {
    if (!_authManager.isAuthenticated) return false;
    
    // End users can chat with mitra and admin
    if (_authManager.isEndUser) {
      return userRole == 'mitra' || userRole == 'admin';
    }
    
    // Mitra can chat with end_user and admin
    if (_authManager.isMitra) {
      return userRole == 'end_user' || userRole == 'admin';
    }
    
    // Admin can chat with anyone
    if (_authManager.isAdmin) {
      return true;
    }
    
    return false;
  }

  /// Stream real-time messages for a conversation
  Stream<List<ChatMessage>> watchConversation({
    required int participantId,
    int? orderId,
  }) async* {
    while (_authManager.isAuthenticated) {
      try {
        final messages = await getChatMessages(
          participantId: participantId,
          orderId: orderId,
          limit: 50,
        );
        yield messages;
        
        // Poll every 3 seconds for new messages
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        print('❌ Error in conversation stream: $e');
        yield [];
        await Future.delayed(const Duration(seconds: 10)); // Longer delay on error
      }
    }
  }

  /// Stream real-time conversations list
  Stream<List<ChatConversation>> watchConversations() async* {
    while (_authManager.isAuthenticated) {
      try {
        final conversations = await getChatConversations();
        yield conversations;
        
        // Poll every 10 seconds for conversation updates
        await Future.delayed(const Duration(seconds: 10));
      } catch (e) {
        print('❌ Error in conversations stream: $e');
        yield [];
        await Future.delayed(const Duration(seconds: 30)); // Longer delay on error
      }
    }
  }

  /// Get chat history with pagination
  Future<Map<String, dynamic>> getChatHistory({
    required int participantId,
    int? orderId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final messages = await getChatMessages(
        participantId: participantId,
        orderId: orderId,
        page: page,
        limit: limit,
      );

      return {
        'messages': messages,
        'has_more': messages.length == limit,
        'page': page,
      };
    } catch (e) {
      print('❌ Failed to get chat history: $e');
      rethrow;
    }
  }
}