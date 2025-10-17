import 'package:bank_sha/services/api_client.dart';

/// Feedback Service - User feedback and complaints
///
/// Features:
/// - Get all feedback (GET /api/feedback)
/// - Get feedback by ID (GET /api/feedback/{id})
/// - Submit feedback (POST /api/feedback)
/// - Update feedback (PUT /api/feedback/{id})
/// - Delete feedback (DELETE /api/feedback/{id})
/// - Filter by type and status
///
/// Use Cases:
/// - Users submit app feedback
/// - Users report issues/complaints
/// - Admin reviews feedback
/// - Feedback management
class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  // Feedback types
  static const List<String> types = [
    'bug_report',
    'feature_request',
    'complaint',
    'suggestion',
    'praise',
    'other',
  ];

  // Feedback statuses
  static const List<String> statuses = [
    'pending',
    'reviewed',
    'in_progress',
    'resolved',
    'rejected',
  ];

  // Priority levels
  static const List<String> priorities = ['low', 'medium', 'high', 'urgent'];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Get all feedback with filters
  ///
  /// GET /api/feedback
  ///
  /// Parameters:
  /// - [userId]: Filter by user ID
  /// - [type]: Filter by feedback type
  /// - [status]: Filter by status
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of feedback
  ///
  /// Example:
  /// ```dart
  /// // Get all feedback
  /// final feedback = await feedbackService.getFeedback();
  ///
  /// // Get bug reports
  /// final bugs = await feedbackService.getFeedback(type: 'bug_report');
  ///
  /// // Get pending feedback
  /// final pending = await feedbackService.getFeedback(status: 'pending');
  /// ```
  Future<List<dynamic>> getFeedback({
    int? userId,
    String? type,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Validate type if provided
      if (type != null && !types.contains(type)) {
        throw ArgumentError(
          'Invalid feedback type. Must be one of: ${types.join(", ")}',
        );
      }

      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (userId != null) query['user_id'] = userId;
      if (type != null) query['type'] = type;
      if (status != null) query['status'] = status;

      print('💬 Getting feedback');
      if (type != null) print('   Filter: Type = $type');
      if (status != null) print('   Filter: Status = $status');

      final response = await _apiClient.getJson('/api/feedback', query: query);

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} feedback entries');
      return data;
    } catch (e) {
      print('❌ Error getting feedback: $e');
      rethrow;
    }
  }

  /// Get feedback by ID
  ///
  /// GET /api/feedback/{id}
  ///
  /// Parameters:
  /// - [feedbackId]: Feedback ID
  ///
  /// Returns: Feedback object
  ///
  /// Example:
  /// ```dart
  /// final feedback = await feedbackService.getFeedbackById(123);
  /// print('Type: ${feedback['type']}');
  /// print('Message: ${feedback['message']}');
  /// ```
  Future<dynamic> getFeedbackById(int feedbackId) async {
    try {
      print('💬 Getting feedback #$feedbackId');

      final response = await _apiClient.get('/api/feedback/$feedbackId');

      final feedback = response['data'];
      print('✅ Feedback: ${feedback['type']} (${feedback['status']})');

      return feedback;
    } catch (e) {
      print('❌ Error getting feedback: $e');
      rethrow;
    }
  }

  /// Submit feedback
  ///
  /// POST /api/feedback
  ///
  /// Parameters:
  /// - [type]: Feedback type (bug_report, feature_request, etc.)
  /// - [subject]: Feedback subject/title
  /// - [message]: Detailed feedback message
  /// - [priority]: Priority level (optional)
  /// - [screenshot]: Screenshot base64 (optional)
  /// - [deviceInfo]: Device information (optional)
  ///
  /// Returns: Created feedback object
  ///
  /// Example:
  /// ```dart
  /// final feedback = await feedbackService.submitFeedback(
  ///   type: 'bug_report',
  ///   subject: 'App crashes on startup',
  ///   message: 'The app crashes immediately after opening...',
  ///   priority: 'high',
  ///   screenshot: base64Image,
  ///   deviceInfo: 'Android 13, Samsung Galaxy S21',
  /// );
  /// ```
  Future<dynamic> submitFeedback({
    required String type,
    required String subject,
    required String message,
    String? priority,
    String? screenshot,
    String? deviceInfo,
  }) async {
    try {
      // Validate type
      if (!types.contains(type)) {
        throw ArgumentError(
          'Invalid feedback type. Must be one of: ${types.join(", ")}',
        );
      }

      // Validate priority if provided
      if (priority != null && !priorities.contains(priority)) {
        throw ArgumentError(
          'Invalid priority. Must be one of: ${priorities.join(", ")}',
        );
      }

      // Validate required fields
      if (subject.trim().isEmpty) {
        throw ArgumentError('Subject is required');
      }
      if (message.trim().isEmpty) {
        throw ArgumentError('Message is required');
      }

      final body = {
        'type': type,
        'subject': subject,
        'message': message,
        if (priority != null) 'priority': priority,
        if (screenshot != null && screenshot.isNotEmpty)
          'screenshot': screenshot,
        if (deviceInfo != null && deviceInfo.isNotEmpty)
          'device_info': deviceInfo,
      };

      print('💬 Submitting feedback');
      print('   Type: $type');
      print('   Subject: $subject');

      final response = await _apiClient.postJson('/api/feedback', body);

      print('✅ Feedback submitted');
      return response['data'];
    } catch (e) {
      print('❌ Error submitting feedback: $e');
      rethrow;
    }
  }

  /// Update feedback
  ///
  /// PUT /api/feedback/{id}
  ///
  /// Parameters:
  /// - [feedbackId]: Feedback ID to update
  /// - [type]: New type (optional)
  /// - [subject]: New subject (optional)
  /// - [message]: New message (optional)
  /// - [status]: New status (optional)
  /// - [priority]: New priority (optional)
  /// - [adminResponse]: Admin response (optional)
  ///
  /// Returns: Updated feedback object
  ///
  /// Example:
  /// ```dart
  /// // User updates feedback
  /// final feedback = await feedbackService.updateFeedback(
  ///   feedbackId: 123,
  ///   message: 'Updated description with more details...',
  /// );
  ///
  /// // Admin updates status and adds response
  /// final feedback = await feedbackService.updateFeedback(
  ///   feedbackId: 123,
  ///   status: 'resolved',
  ///   adminResponse: 'This issue has been fixed in version 2.0',
  /// );
  /// ```
  Future<dynamic> updateFeedback({
    required int feedbackId,
    String? type,
    String? subject,
    String? message,
    String? status,
    String? priority,
    String? adminResponse,
  }) async {
    try {
      // Validate type if provided
      if (type != null && !types.contains(type)) {
        throw ArgumentError(
          'Invalid feedback type. Must be one of: ${types.join(", ")}',
        );
      }

      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      // Validate priority if provided
      if (priority != null && !priorities.contains(priority)) {
        throw ArgumentError(
          'Invalid priority. Must be one of: ${priorities.join(", ")}',
        );
      }

      final body = <String, dynamic>{};

      if (type != null) body['type'] = type;
      if (subject != null && subject.isNotEmpty) body['subject'] = subject;
      if (message != null && message.isNotEmpty) body['message'] = message;
      if (status != null) body['status'] = status;
      if (priority != null) body['priority'] = priority;
      if (adminResponse != null) body['admin_response'] = adminResponse;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('💬 Updating feedback #$feedbackId');

      final response = await _apiClient.putJson(
        '/api/feedback/$feedbackId',
        body,
      );

      print('✅ Feedback updated');
      return response['data'];
    } catch (e) {
      print('❌ Error updating feedback: $e');
      rethrow;
    }
  }

  /// Delete feedback
  ///
  /// DELETE /api/feedback/{id}
  ///
  /// Parameters:
  /// - [feedbackId]: Feedback ID to delete
  ///
  /// Example:
  /// ```dart
  /// await feedbackService.deleteFeedback(123);
  /// print('Feedback deleted');
  /// ```
  Future<void> deleteFeedback(int feedbackId) async {
    try {
      print('🗑️ Deleting feedback #$feedbackId');

      await _apiClient.delete('/api/feedback/$feedbackId');

      print('✅ Feedback deleted');
    } catch (e) {
      print('❌ Error deleting feedback: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get user's feedback history
  Future<List<dynamic>> getUserFeedback(int userId) async {
    return getFeedback(userId: userId);
  }

  /// Get feedback by type
  Future<List<dynamic>> getFeedbackByType(String type) async {
    return getFeedback(type: type);
  }

  /// Get pending feedback (for admin)
  Future<List<dynamic>> getPendingFeedback() async {
    return getFeedback(status: 'pending');
  }

  /// Get feedback statistics
  Future<Map<String, int>> getFeedbackStatistics() async {
    try {
      final stats = <String, int>{};

      for (var type in types) {
        final feedback = await getFeedback(type: type, perPage: 1);
        stats[type] = feedback.length;
      }

      return stats;
    } catch (e) {
      print('❌ Error getting feedback statistics: $e');
      return {};
    }
  }

  /// Mark feedback as resolved
  Future<dynamic> resolveFeedback(int feedbackId, String adminResponse) async {
    return updateFeedback(
      feedbackId: feedbackId,
      status: 'resolved',
      adminResponse: adminResponse,
    );
  }

  /// Get type display name
  String getTypeDisplayName(String type) {
    switch (type) {
      case 'bug_report':
        return 'Bug Report';
      case 'feature_request':
        return 'Feature Request';
      case 'complaint':
        return 'Complaint';
      case 'suggestion':
        return 'Suggestion';
      case 'praise':
        return 'Praise';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  /// Get priority color
  String getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return '#FF0000'; // Red
      case 'high':
        return '#FF6600'; // Orange
      case 'medium':
        return '#FFCC00'; // Yellow
      case 'low':
        return '#00CC00'; // Green
      default:
        return '#999999'; // Gray
    }
  }
}
