import 'dart:async';
import 'package:bank_sha/services/api_client.dart';

/// Complete Chat Service - Real-time Messaging
///
/// Features:
/// - Send message (POST /api/chats)
/// - Update message (PUT /api/chats/{id})
/// - Delete message (DELETE /api/chats/{id})
/// - Get messages list (GET /api/chats)
/// - Get message by ID (GET /api/chats/{id})
/// - Mark message as read
/// - Real-time message stream (polling)
///
/// Use Cases:
/// - User chat with mitra
/// - Mitra chat with user
/// - Support text, image, location messages
/// - Real-time message notifications
class ChatServiceComplete {
  final ApiClient _apiClient = ApiClient();

  Timer? _messagePollingTimer;
  int? _lastMessageId;

  // ========================================
  // CRUD Operations
  // ========================================

  /// Send a new message
  ///
  /// POST /api/chats
  ///
  /// Parameters:
  /// - [receiverId]: ID of the user receiving the message
  /// - [message]: Message content (text, base64 image, or JSON for location)
  /// - [type]: Message type (text, image, location) - default: text
  /// - [metadata]: Additional data as JSON string (optional)
  ///
  /// Message Types:
  /// - **text**: Plain text message
  /// - **image**: Base64 encoded image
  /// - **location**: JSON with lat/lng {"lat": -6.1897999, "lng": 106.8666999}
  ///
  /// Returns: Created Chat/Message object
  ///
  /// Example:
  /// ```dart
  /// // Send text message
  /// final textMsg = await chatService.sendMessage(
  ///   receiverId: 456,
  ///   message: 'Hello! Are you on the way?',
  ///   type: 'text',
  /// );
  ///
  /// // Send image (base64)
  /// final imageMsg = await chatService.sendMessage(
  ///   receiverId: 456,
  ///   message: base64Image,
  ///   type: 'image',
  /// );
  ///
  /// // Send location
  /// final locationMsg = await chatService.sendMessage(
  ///   receiverId: 456,
  ///   message: '{"lat": -6.1897999, "lng": 106.8666999}',
  ///   type: 'location',
  /// );
  /// ```
  Future<dynamic> sendMessage({
    required int receiverId,
    required String message,
    String type = 'text',
    String? metadata,
  }) async {
    try {
      // Validate message type
      final validTypes = ['text', 'image', 'location'];
      if (!validTypes.contains(type)) {
        throw ArgumentError(
          'Invalid message type. Must be one of: ${validTypes.join(", ")}',
        );
      }

      // Validate message content
      if (message.trim().isEmpty) {
        throw ArgumentError('Message cannot be empty');
      }

      final body = {
        'receiver_id': receiverId,
        'message': message,
        'type': type,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      };

      print('💬 Sending message to User #$receiverId');
      print('   Type: $type');
      if (type == 'text') {
        final preview = message.length > 50
            ? '${message.substring(0, 50)}...'
            : message;
        print('   Content: $preview');
      }

      final response = await _apiClient.postJson('/api/chats', body);

      print('✅ Message sent successfully');
      return response['data']; // Return as dynamic since model might not exist yet
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Update existing message
  ///
  /// PUT /api/chats/{id}
  ///
  /// Parameters:
  /// - [id]: Message ID to update
  /// - [message]: New message content (optional)
  /// - [type]: New message type (optional)
  /// - [metadata]: New metadata (optional)
  ///
  /// Returns: Updated Chat/Message object
  ///
  /// Note: Usually only used to edit text messages
  ///
  /// Example:
  /// ```dart
  /// final updated = await chatService.updateMessage(
  ///   789,
  ///   message: 'Edited: Hello! Are you on the way?',
  /// );
  /// ```
  Future<dynamic> updateMessage(
    int id, {
    String? message,
    String? type,
    String? metadata,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (message != null && message.isNotEmpty) body['message'] = message;
      if (type != null) body['type'] = type;
      if (metadata != null) body['metadata'] = metadata;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('💬 Updating message #$id');

      final response = await _apiClient.putJson('/api/chats/$id', body);

      print('✅ Message updated successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error updating message: $e');
      rethrow;
    }
  }

  /// Delete message
  ///
  /// DELETE /api/chats/{id}
  ///
  /// Parameters:
  /// - [id]: Message ID to delete
  ///
  /// Example:
  /// ```dart
  /// await chatService.deleteMessage(789);
  /// ```
  Future<void> deleteMessage(int id) async {
    try {
      print('🗑️ Deleting message #$id');

      await _apiClient.delete('/api/chats/$id');

      print('✅ Message deleted successfully');
    } catch (e) {
      print('❌ Error deleting message: $e');
      rethrow;
    }
  }

  /// Get list of messages
  ///
  /// GET /api/chats
  ///
  /// Parameters:
  /// - [userId]: Filter by user ID (messages to/from this user)
  /// - [senderId]: Filter by sender ID
  /// - [receiverId]: Filter by receiver ID
  /// - [type]: Filter by message type (text, image, location)
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 50, max: 100)
  ///
  /// Returns: List of Chat/Message objects
  ///
  /// Example:
  /// ```dart
  /// // Get all messages with a specific user
  /// final messages = await chatService.getMessages(userId: 456);
  ///
  /// // Get only text messages
  /// final textMessages = await chatService.getMessages(type: 'text');
  /// ```
  Future<List<dynamic>> getMessages({
    int? userId,
    int? senderId,
    int? receiverId,
    String? type,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (userId != null) query['user_id'] = userId;
      if (senderId != null) query['sender_id'] = senderId;
      if (receiverId != null) query['receiver_id'] = receiverId;
      if (type != null) query['type'] = type;

      print('💬 Getting messages');
      if (userId != null) print('   Filter: User #$userId');
      if (senderId != null) print('   Filter: Sender #$senderId');
      if (receiverId != null) print('   Filter: Receiver #$receiverId');

      final response = await _apiClient.getJson('/api/chats', query: query);

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} messages');
      return data;
    } catch (e) {
      print('❌ Error getting messages: $e');
      rethrow;
    }
  }

  /// Get message by ID
  ///
  /// GET /api/chats/{id}
  ///
  /// Parameters:
  /// - [id]: Message ID
  ///
  /// Returns: Chat/Message object
  ///
  /// Example:
  /// ```dart
  /// final message = await chatService.getMessageById(789);
  /// ```
  Future<dynamic> getMessageById(int id) async {
    try {
      print('💬 Getting message #$id');

      final response = await _apiClient.get('/api/chats/$id');

      print('✅ Message found');
      return response['data'];
    } catch (e) {
      print('❌ Error getting message: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Mark message as read
  ///
  /// This might be implemented as updating the message or a separate endpoint
  /// depending on backend implementation
  ///
  /// Parameters:
  /// - [id]: Message ID to mark as read
  ///
  /// Example:
  /// ```dart
  /// await chatService.markAsRead(789);
  /// ```
  Future<void> markAsRead(int id) async {
    try {
      print('📖 Marking message #$id as read');

      // Option 1: Update message with is_read flag
      await updateMessage(id, metadata: '{"is_read": true}');

      // Option 2: If backend has dedicated endpoint
      // await _apiClient.putJson('/api/chats/$id/read', {});

      print('✅ Message marked as read');
    } catch (e) {
      print('❌ Error marking as read: $e');
      rethrow;
    }
  }

  /// Get conversation between two users
  ///
  /// Parameters:
  /// - [user1Id]: First user ID
  /// - [user2Id]: Second user ID
  /// - [page]: Page number (default: 1)
  /// - [perPage]: Items per page (default: 50)
  ///
  /// Returns: List of messages sorted by time
  ///
  /// Example:
  /// ```dart
  /// final conversation = await chatService.getConversation(123, 456);
  /// ```
  Future<List<dynamic>> getConversation(
    int user1Id,
    int user2Id, {
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      print(
        '💬 Getting conversation between User #$user1Id and User #$user2Id',
      );

      // Get all messages between these two users
      final messages = await getMessages(
        userId: user1Id,
        page: page,
        perPage: perPage,
      );

      // Filter messages involving user2
      final conversation = messages.where((msg) {
        final senderId = msg['sender_id'];
        final receiverId = msg['receiver_id'];
        return (senderId == user1Id && receiverId == user2Id) ||
            (senderId == user2Id && receiverId == user1Id);
      }).toList();

      print('✅ Found ${conversation.length} messages in conversation');
      return conversation;
    } catch (e) {
      print('❌ Error getting conversation: $e');
      rethrow;
    }
  }

  /// Get unread message count for a user
  ///
  /// Parameters:
  /// - [userId]: User ID to check unread messages for
  ///
  /// Returns: Number of unread messages
  ///
  /// Example:
  /// ```dart
  /// final unreadCount = await chatService.getUnreadCount(123);
  /// print('Unread messages: $unreadCount');
  /// ```
  Future<int> getUnreadCount(int userId) async {
    try {
      print('💬 Getting unread count for User #$userId');

      final messages = await getMessages(receiverId: userId, perPage: 100);

      // Count messages where is_read is false
      final unreadCount = messages.where((msg) {
        final metadata = msg['metadata'];
        if (metadata == null) return true; // Assume unread if no metadata

        // Try to parse metadata JSON
        try {
          if (metadata is String && metadata.contains('is_read')) {
            return !metadata.contains('"is_read": true');
          }
        } catch (e) {
          return true; // Assume unread on error
        }
        return true;
      }).length;

      print('✅ Unread messages: $unreadCount');
      return unreadCount;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // ========================================
  // Real-time Messaging (Polling)
  // ========================================

  /// Start real-time message polling
  ///
  /// This will periodically check for new messages and call the callback
  ///
  /// Parameters:
  /// - [userId]: User ID to monitor messages for
  /// - [intervalSeconds]: Polling interval (default: 5 seconds)
  /// - [onNewMessage]: Callback when new message arrives
  /// - [onError]: Callback when error occurs
  ///
  /// Example:
  /// ```dart
  /// chatService.startMessagePolling(
  ///   userId: 123,
  ///   intervalSeconds: 5,
  ///   onNewMessage: (message) {
  ///     print('New message: ${message['message']}');
  ///     // Update UI, show notification, etc.
  ///   },
  ///   onError: (error) {
  ///     print('Polling error: $error');
  ///   },
  /// );
  /// ```
  void startMessagePolling({
    required int userId,
    int intervalSeconds = 5,
    required Function(dynamic) onNewMessage,
    Function(dynamic)? onError,
  }) {
    // Stop existing polling if any
    stopMessagePolling();

    print(
      '🔄 Starting message polling for User #$userId (interval: ${intervalSeconds}s)',
    );

    _messagePollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (
      timer,
    ) async {
      try {
        // Get latest messages
        final messages = await getMessages(receiverId: userId, perPage: 10);

        if (messages.isEmpty) return;

        // Check for new messages
        final latestMessage = messages.first;
        final latestId = latestMessage['id'];

        if (_lastMessageId == null) {
          _lastMessageId = latestId;
          return; // First poll, just store ID
        }

        if (latestId != _lastMessageId) {
          // New message detected
          print('📩 New message detected: ID $latestId');
          _lastMessageId = latestId;
          onNewMessage(latestMessage);
        }
      } catch (e) {
        print('❌ Polling error: $e');
        onError?.call(e);
      }
    });

    print('✅ Message polling started');
  }

  /// Stop message polling
  ///
  /// Example:
  /// ```dart
  /// chatService.stopMessagePolling();
  /// ```
  void stopMessagePolling() {
    if (_messagePollingTimer != null) {
      print('🛑 Stopping message polling');
      _messagePollingTimer?.cancel();
      _messagePollingTimer = null;
      _lastMessageId = null;
      print('✅ Message polling stopped');
    }
  }

  /// Check if polling is active
  bool get isPolling =>
      _messagePollingTimer != null && _messagePollingTimer!.isActive;

  /// Cleanup - Call this when disposing the service
  void dispose() {
    stopMessagePolling();
  }
}
