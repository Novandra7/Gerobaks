import 'package:dio/dio.dart';
import '../models/notification_model.dart';

/// Service untuk handle API notification
class NotificationApiService {
  final Dio _dio;
  final String baseUrl;

  NotificationApiService({required Dio dio, String? baseUrl})
    : _dio = dio,
      baseUrl = baseUrl ?? 'http://127.0.0.1:8000/api';

  /// Setup Dio dengan Bearer token
  void setAuthToken(String token) {
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// 1. Get Notifications List
  ///
  /// Query Parameters:
  /// - page: Page number (default: 1)
  /// - perPage: Items per page (max: 100, default: 20)
  /// - isRead: Filter: 0=unread, 1=read, null=all
  /// - type: Filter: schedule/reminder/info/system/promo
  /// - category: Filter by category
  /// - priority: Filter: low/normal/high/urgent
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? isRead,
    String? type,
    String? category,
    String? priority,
  }) async {
    try {
      print('� Fetching notifications...');
      print('   - Page: $page, Per Page: $perPage');
      if (isRead != null) print('   - Filter is_read: $isRead');
      if (type != null) print('   - Filter type: $type');
      if (category != null) print('   - Filter category: $category');
      if (priority != null) print('   - Filter priority: $priority');

      final response = await _dio.get(
        '$baseUrl/notifications',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (isRead != null) 'is_read': isRead ? 1 : 0,
          if (type != null) 'type': type,
          if (category != null) 'category': category,
          if (priority != null) 'priority': priority,
        },
      );

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      final notificationsList = response.data['data']['notifications'];
      print('✅ Notifications fetched: ${notificationsList.length} items');

      return NotificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException details:');
      print('   - Message: ${e.message}');
      print('   - Type: ${e.type}');
      print('   - Response: ${e.response?.data}');
      print('   - Status Code: ${e.response?.statusCode}');
      _handleError(e, 'fetching notifications');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// 2. Get Unread Count
  ///
  /// Returns:
  /// - unread_count: Total unread notifications
  /// - by_category: Unread count per category
  /// - by_priority: Unread count per priority
  /// - has_urgent: Boolean if ada urgent notification
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      print('📊 Fetching unread count...');

      final response = await _dio.get('$baseUrl/notifications/unread-count');

      print('📦 Unread count response status: ${response.statusCode}');
      print('📦 Unread count response data: ${response.data}');

      final unreadCount = response.data['data']['unread_count'];
      print('✅ Unread count: $unreadCount');

      return UnreadCountResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error getting unread count: ${e.message}');
      _handleError(e, 'getting unread count');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error in getUnreadCount: $e');
      rethrow;
    }
  }

  /// Helper untuk check urgent notifications
  Future<bool> hasUrgentNotifications() async {
    try {
      final response = await getUnreadCount();
      return response.hasUrgent;
    } catch (e) {
      print('⚠️ Error checking urgent notifications: $e');
      return false;
    }
  }

  /// 3. Mark Notification as Read (Single)
  ///
  /// Parameters:
  /// - notificationId: ID notifikasi yang akan di-mark read
  ///
  /// Returns:
  /// - notification: Notification yang sudah di-update
  /// - remaining_unread: Jumlah notif yang masih unread
  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      print('✓ Marking notification #$notificationId as read...');

      final response = await _dio.post(
        '$baseUrl/notifications/$notificationId/mark-read',
      );

      print('✅ Notification #$notificationId marked as read');

      return response.data['data'];
    } on DioException catch (e) {
      print('❌ Error marking notification as read: ${e.message}');
      _handleError(e, 'marking notification as read');
      rethrow;
    }
  }

  /// 4. Mark All Notifications as Read
  ///
  /// Returns:
  /// - marked_count: Jumlah notifikasi yang di-mark read
  /// - unread_count: Sisa unread count (should be 0)
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      print('✓✓ Marking all notifications as read...');

      final response = await _dio.post('$baseUrl/notifications/mark-all-read');

      final markedCount = response.data['data']['marked_count'];
      print('✅ All notifications marked as read: $markedCount items');

      return response.data['data'];
    } on DioException catch (e) {
      print('❌ Error marking all as read: ${e.message}');
      _handleError(e, 'marking all notifications as read');
      rethrow;
    }
  }

  /// 5. Delete Notification
  ///
  /// Parameters:
  /// - notificationId: ID notifikasi yang akan dihapus
  ///
  /// Returns:
  /// - id: ID notifikasi yang dihapus
  /// - deleted_at: Timestamp penghapusan
  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      print('🗑️ Deleting notification #$notificationId...');

      final response = await _dio.delete(
        '$baseUrl/notifications/$notificationId',
      );

      print('✅ Notification #$notificationId deleted');

      return response.data['data'];
    } on DioException catch (e) {
      print('❌ Error deleting notification: ${e.message}');
      _handleError(e, 'deleting notification');
      rethrow;
    }
  }

  /// 6. Clear All Read Notifications
  ///
  /// Menghapus semua notifikasi yang sudah dibaca
  ///
  /// Returns:
  /// - deleted_count: Jumlah notifikasi yang dihapus
  Future<int> clearReadNotifications() async {
    try {
      print('🗑️ Clearing all read notifications...');

      final response = await _dio.delete('$baseUrl/notifications/clear-read');

      final deletedCount = response.data['data']['deleted_count'];
      print('✅ Cleared $deletedCount read notifications');

      return deletedCount;
    } on DioException catch (e) {
      print('❌ Error clearing read notifications: ${e.message}');
      _handleError(e, 'clearing read notifications');
      rethrow;
    }
  }

  /// Helper untuk handle error dari API
  void _handleError(DioException error, String action) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      switch (statusCode) {
        case 401:
          print('🔒 Unauthorized: Token invalid atau expired');
          throw Exception('Authentication required. Please login again.');

        case 404:
          print('🔍 Not Found: Resource tidak ditemukan');
          final message = data?['message'] ?? 'Notification not found';
          throw Exception(message);

        case 422:
          print('⚠️ Validation Error');
          final errors = data?['errors'] ?? {};
          throw Exception('Validation failed: ${errors.toString()}');

        case 500:
          print('🔥 Server Error');
          throw Exception('Server error. Please try again later.');

        default:
          print('❌ Error $statusCode: ${data?['message']}');
          throw Exception(
            'Failed $action: ${data?['message'] ?? 'Unknown error'}',
          );
      }
    } else {
      // Network error
      print('🌐 Network Error: ${error.message}');
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Register FCM Token
  /// POST /api/user/fcm-token
  Future<bool> registerFcmToken({
    required String fcmToken,
    required String deviceType,
    String? deviceName,
  }) async {
    try {
      print('📤 Registering FCM token...');
      print('   - Device type: $deviceType');

      final response = await _dio.post(
        '$baseUrl/user/fcm-token',
        data: {
          'fcm_token': fcmToken,
          'device_type': deviceType,
          if (deviceName != null) 'device_name': deviceName,
        },
      );

      print('✅ FCM token registered: ${response.data}');
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('❌ Error registering FCM token: ${e.message}');
      _handleError(e, 'registering FCM token');
      rethrow;
    }
  }

  /// Remove FCM Token (logout)
  /// DELETE /api/user/fcm-token
  Future<bool> removeFcmToken(String fcmToken) async {
    try {
      print('🗑️ Removing FCM token...');

      final response = await _dio.delete(
        '$baseUrl/user/fcm-token',
        data: {'fcm_token': fcmToken},
      );

      print('✅ FCM token removed: ${response.data}');
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('❌ Error removing FCM token: ${e.message}');
      _handleError(e, 'removing FCM token');
      rethrow;
    }
  }

  /// Helper untuk format error message untuk UI
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        return data?['message'] ?? 'Something went wrong';
      } else {
        return 'Network error. Please check your connection.';
      }
    }
    return error.toString();
  }
}
