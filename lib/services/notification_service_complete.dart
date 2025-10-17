import 'package:bank_sha/services/api_client.dart';

/// Complete Notification Service - Full notification management
///
/// Features:
/// - Get all notifications (GET /api/notifications)
/// - Get notification by ID (GET /api/notifications/{id})
/// - Mark as read (PUT /api/notifications/{id}/mark-read) [NEW]
/// - Mark all as read (PUT /api/notifications/mark-all-read)
/// - Delete notification (DELETE /api/notifications/{id})
/// - Get unread count
/// - Filter by type and status
///
/// Use Cases:
/// - Users receive order updates
/// - Push notification display
/// - Notification badge management
/// - Notification history
class NotificationServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // Notification types
  static const List<String> types = [
    'order_created',
    'order_accepted',
    'order_on_the_way',
    'order_picked_up',
    'order_completed',
    'order_cancelled',
    'payment_received',
    'balance_updated',
    'schedule_reminder',
    'system_announcement',
  ];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Get all notifications with filters
  ///
  /// GET /api/notifications
  ///
  /// Parameters:
  /// - [type]: Filter by notification type
  /// - [isRead]: Filter by read status (true/false)
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of notifications
  ///
  /// Example:
  /// ```dart
  /// // Get all notifications
  /// final notifications = await notificationService.getNotifications();
  ///
  /// // Get unread notifications
  /// final unread = await notificationService.getNotifications(isRead: false);
  ///
  /// // Get order notifications
  /// final orders = await notificationService.getNotifications(
  ///   type: 'order_created',
  /// );
  /// ```
  Future<List<dynamic>> getNotifications({
    String? type,
    bool? isRead,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Validate type if provided
      if (type != null && !types.contains(type)) {
        throw ArgumentError(
          'Invalid notification type. Must be one of: ${types.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (type != null) query['type'] = type;
      if (isRead != null) query['is_read'] = isRead ? '1' : '0';

      print('🔔 Getting notifications');
      if (type != null) print('   Filter: Type = $type');
      if (isRead != null) print('   Filter: Read = $isRead');

      final response = await _apiClient.getJson(
        '/api/notifications',
        query: query,
      );

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} notifications');
      return data;
    } catch (e) {
      print('❌ Error getting notifications: $e');
      rethrow;
    }
  }

  /// Get notification by ID
  ///
  /// GET /api/notifications/{id}
  ///
  /// Parameters:
  /// - [notificationId]: Notification ID
  ///
  /// Returns: Notification object
  ///
  /// Example:
  /// ```dart
  /// final notification = await notificationService.getNotificationById(123);
  /// print('Title: ${notification['title']}');
  /// print('Message: ${notification['message']}');
  /// ```
  Future<dynamic> getNotificationById(int notificationId) async {
    try {
      print('🔔 Getting notification #$notificationId');

      final response = await _apiClient.get(
        '/api/notifications/$notificationId',
      );

      final notification = response['data'];
      print('✅ Notification: ${notification['title']}');

      return notification;
    } catch (e) {
      print('❌ Error getting notification: $e');
      rethrow;
    }
  }

  /// Mark notification as read
  ///
  /// PUT /api/notifications/{id}/mark-read
  ///
  /// Parameters:
  /// - [notificationId]: Notification ID to mark as read
  ///
  /// Returns: Updated notification object
  ///
  /// Example:
  /// ```dart
  /// final notification = await notificationService.markAsRead(123);
  /// print('Marked as read: ${notification['is_read']}');
  /// ```
  Future<dynamic> markAsRead(int notificationId) async {
    try {
      print('🔔 Marking notification #$notificationId as read');

      final response = await _apiClient.putJson(
        '/api/notifications/$notificationId/mark-read',
        {},
      );

      print('✅ Notification marked as read');
      return response['data'];
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  ///
  /// PUT /api/notifications/mark-all-read
  ///
  /// Returns: Success message
  ///
  /// Example:
  /// ```dart
  /// await notificationService.markAllAsRead();
  /// print('All notifications marked as read');
  /// ```
  Future<dynamic> markAllAsRead() async {
    try {
      print('🔔 Marking all notifications as read');

      final response = await _apiClient.putJson(
        '/api/notifications/mark-all-read',
        {},
      );

      print('✅ All notifications marked as read');
      return response['data'];
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  ///
  /// DELETE /api/notifications/{id}
  ///
  /// Parameters:
  /// - [notificationId]: Notification ID to delete
  ///
  /// Example:
  /// ```dart
  /// await notificationService.deleteNotification(123);
  /// print('Notification deleted');
  /// ```
  Future<void> deleteNotification(int notificationId) async {
    try {
      print('🗑️ Deleting notification #$notificationId');

      await _apiClient.delete('/api/notifications/$notificationId');

      print('✅ Notification deleted');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get unread notifications
  ///
  /// Returns: List of unread notifications
  ///
  /// Example:
  /// ```dart
  /// final unread = await notificationService.getUnreadNotifications();
  /// print('You have ${unread.length} unread notifications');
  /// ```
  Future<List<dynamic>> getUnreadNotifications() async {
    return getNotifications(isRead: false);
  }

  /// Get unread count
  ///
  /// Returns: Number of unread notifications
  ///
  /// Example:
  /// ```dart
  /// final count = await notificationService.getUnreadCount();
  /// // Display badge with count
  /// ```
  Future<int> getUnreadCount() async {
    try {
      print('🔔 Getting unread notification count');

      final unread = await getUnreadNotifications();
      final count = unread.length;

      print('✅ Unread count: $count');
      return count;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Get notifications by type
  ///
  /// Parameters:
  /// - [type]: Notification type
  ///
  /// Returns: List of notifications of specified type
  ///
  /// Example:
  /// ```dart
  /// final orderNotifs = await notificationService.getNotificationsByType(
  ///   'order_created',
  /// );
  /// ```
  Future<List<dynamic>> getNotificationsByType(String type) async {
    return getNotifications(type: type);
  }

  /// Delete all read notifications
  ///
  /// Example:
  /// ```dart
  /// await notificationService.deleteAllReadNotifications();
  /// print('All read notifications cleared');
  /// ```
  Future<void> deleteAllReadNotifications() async {
    try {
      print('🗑️ Deleting all read notifications');

      final readNotifications = await getNotifications(isRead: true);

      for (var notification in readNotifications) {
        final id = notification['id'] as int;
        await deleteNotification(id);
      }

      print('✅ All read notifications deleted');
    } catch (e) {
      print('❌ Error deleting read notifications: $e');
      rethrow;
    }
  }

  /// Get notification statistics
  ///
  /// Returns: Map with notification counts by type
  ///
  /// Example:
  /// ```dart
  /// final stats = await notificationService.getNotificationStatistics();
  /// print('Order notifications: ${stats['order_created']}');
  /// ```
  Future<Map<String, int>> getNotificationStatistics() async {
    try {
      final stats = <String, int>{};

      for (var type in types) {
        final notifications = await getNotifications(type: type, perPage: 1);
        stats[type] = notifications.length;
      }

      return stats;
    } catch (e) {
      print('❌ Error getting notification statistics: $e');
      return {};
    }
  }

  /// Format notification time (relative)
  ///
  /// Parameters:
  /// - [timestamp]: Notification timestamp
  ///
  /// Returns: Formatted time string
  ///
  /// Example:
  /// ```dart
  /// final time = notificationService.formatNotificationTime(
  ///   DateTime.parse('2024-01-15 10:00:00'),
  /// );
  /// print(time); // "2 hours ago"
  /// ```
  String formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Get notification icon based on type
  ///
  /// Parameters:
  /// - [type]: Notification type
  ///
  /// Returns: Icon name/path
  ///
  /// Example:
  /// ```dart
  /// final icon = notificationService.getNotificationIcon('order_created');
  /// ```
  String getNotificationIcon(String type) {
    switch (type) {
      case 'order_created':
      case 'order_accepted':
      case 'order_on_the_way':
      case 'order_picked_up':
      case 'order_completed':
        return 'ic_tracking.png';
      case 'order_cancelled':
        return 'ic_tempat_sampah.png';
      case 'payment_received':
      case 'balance_updated':
        return 'ic_topup.png';
      case 'schedule_reminder':
        return 'ic_calender.png';
      case 'system_announcement':
        return 'ic_notification.png';
      default:
        return 'ic_notification.png';
    }
  }
}
