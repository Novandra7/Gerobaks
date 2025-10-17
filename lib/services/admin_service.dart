import 'package:bank_sha/services/api_client.dart';

/// Admin Service - Admin panel operations
///
/// Features:
/// - Dashboard statistics (GET /api/admin/stats)
/// - System logs (GET /api/admin/logs)
/// - Broadcast notifications (POST /api/admin/broadcast)
/// - User management (admin operations)
/// - System health monitoring
/// - Report generation
///
/// Use Cases:
/// - Admin dashboard overview
/// - System monitoring
/// - Mass notifications
/// - Analytics and reporting
/// - User management
class AdminService {
  final ApiClient _apiClient = ApiClient();

  // Log types
  static const List<String> logTypes = [
    'error',
    'warning',
    'info',
    'security',
    'transaction',
  ];

  // Report types
  static const List<String> reportTypes = [
    'orders',
    'users',
    'revenue',
    'waste_collected',
    'ratings',
  ];

  // Time periods
  static const List<String> timePeriods = [
    'today',
    'yesterday',
    'this_week',
    'last_week',
    'this_month',
    'last_month',
    'this_year',
    'custom',
  ];

  // ========================================
  // Dashboard & Statistics
  // ========================================

  /// Get dashboard statistics
  ///
  /// GET /api/admin/stats
  ///
  /// Parameters:
  /// - [period]: Time period (today, this_week, this_month, etc.)
  /// - [startDate]: Start date for custom period (YYYY-MM-DD)
  /// - [endDate]: End date for custom period (YYYY-MM-DD)
  ///
  /// Returns: Dashboard statistics object
  ///
  /// Example:
  /// ```dart
  /// // Get today's stats
  /// final stats = await adminService.getDashboardStats(period: 'today');
  /// print('Total orders: ${stats['total_orders']}');
  /// print('Revenue: Rp ${stats['total_revenue']}');
  ///
  /// // Get custom period stats
  /// final stats = await adminService.getDashboardStats(
  ///   period: 'custom',
  ///   startDate: '2024-01-01',
  ///   endDate: '2024-01-31',
  /// );
  /// ```
  Future<dynamic> getDashboardStats({
    String period = 'today',
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Validate period
      if (!timePeriods.contains(period)) {
        throw ArgumentError(
          'Invalid period. Must be one of: ${timePeriods.join(", ")}',
        );
      }

      // Validate custom period
      if (period == 'custom') {
        if (startDate == null || endDate == null) {
          throw ArgumentError(
            'Start date and end date required for custom period',
          );
        }
      }

      final query = <String, dynamic>{'period': period};

      if (startDate != null) query['start_date'] = startDate;
      if (endDate != null) query['end_date'] = endDate;

      print('📊 Getting dashboard statistics');
      print('   Period: $period');

      final response = await _apiClient.getJson(
        '/api/admin/stats',
        query: query,
      );

      final stats = response['data'];
      print('✅ Statistics retrieved');

      return stats;
    } catch (e) {
      print('❌ Error getting dashboard stats: $e');
      rethrow;
    }
  }

  /// Get real-time statistics
  ///
  /// Returns: Real-time system metrics
  ///
  /// Example:
  /// ```dart
  /// final realtime = await adminService.getRealtimeStats();
  /// print('Active users: ${realtime['active_users']}');
  /// print('Ongoing orders: ${realtime['ongoing_orders']}');
  /// ```
  Future<dynamic> getRealtimeStats() async {
    try {
      print('📊 Getting realtime statistics');

      final response = await _apiClient.get('/api/admin/stats/realtime');

      print('✅ Realtime stats retrieved');
      return response['data'];
    } catch (e) {
      print('❌ Error getting realtime stats: $e');
      rethrow;
    }
  }

  // ========================================
  // System Logs
  // ========================================

  /// Get system logs
  ///
  /// GET /api/admin/logs
  ///
  /// Parameters:
  /// - [type]: Log type (error, warning, info, security, transaction)
  /// - [startDate]: Start date filter (YYYY-MM-DD)
  /// - [endDate]: End date filter (YYYY-MM-DD)
  /// - [search]: Search in log messages
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 50, max: 200)
  ///
  /// Returns: List of log entries
  ///
  /// Example:
  /// ```dart
  /// // Get all error logs
  /// final errors = await adminService.getLogs(type: 'error');
  ///
  /// // Get logs for specific date
  /// final logs = await adminService.getLogs(
  ///   startDate: '2024-01-15',
  ///   endDate: '2024-01-15',
  /// );
  ///
  /// // Search logs
  /// final results = await adminService.getLogs(search: 'payment');
  /// ```
  Future<List<dynamic>> getLogs({
    String? type,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      // Validate type if provided
      if (type != null && !logTypes.contains(type)) {
        throw ArgumentError(
          'Invalid log type. Must be one of: ${logTypes.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (type != null) query['type'] = type;
      if (startDate != null) query['start_date'] = startDate;
      if (endDate != null) query['end_date'] = endDate;
      if (search != null && search.isNotEmpty) query['search'] = search;

      print('📋 Getting system logs');
      if (type != null) print('   Filter: Type = $type');

      final response = await _apiClient.getJson(
        '/api/admin/logs',
        query: query,
      );

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} log entries');
      return data;
    } catch (e) {
      print('❌ Error getting logs: $e');
      rethrow;
    }
  }

  /// Clear old logs
  ///
  /// DELETE /api/admin/logs/clear
  ///
  /// Parameters:
  /// - [olderThanDays]: Delete logs older than X days (default: 30)
  ///
  /// Example:
  /// ```dart
  /// // Clear logs older than 30 days
  /// await adminService.clearOldLogs();
  ///
  /// // Clear logs older than 90 days
  /// await adminService.clearOldLogs(olderThanDays: 90);
  /// ```
  Future<void> clearOldLogs({int olderThanDays = 30}) async {
    try {
      print('🗑️ Clearing logs older than $olderThanDays days');

      // Use DELETE with path parameter instead of query
      await _apiClient.delete(
        '/api/admin/logs/clear?older_than_days=$olderThanDays',
      );

      print('✅ Old logs cleared');
    } catch (e) {
      print('❌ Error clearing logs: $e');
      rethrow;
    }
  }

  // ========================================
  // Broadcast Notifications
  // ========================================

  /// Broadcast notification to users
  ///
  /// POST /api/admin/broadcast
  ///
  /// Parameters:
  /// - [title]: Notification title
  /// - [message]: Notification message
  /// - [targetRole]: Target user role (optional: all, end_user, mitra)
  /// - [targetUserIds]: Specific user IDs (optional)
  /// - [imageUrl]: Notification image (optional, base64)
  /// - [actionUrl]: Deep link/action URL (optional)
  ///
  /// Returns: Broadcast result
  ///
  /// Example:
  /// ```dart
  /// // Broadcast to all users
  /// await adminService.broadcastNotification(
  ///   title: 'System Maintenance',
  ///   message: 'Scheduled maintenance on Jan 20, 2024',
  /// );
  ///
  /// // Broadcast to specific role
  /// await adminService.broadcastNotification(
  ///   title: 'New Feature for Mitras',
  ///   message: 'Check out the new earning tracker!',
  ///   targetRole: 'mitra',
  /// );
  ///
  /// // Broadcast to specific users
  /// await adminService.broadcastNotification(
  ///   title: 'Special Offer',
  ///   message: 'Exclusive offer for premium users',
  ///   targetUserIds: [123, 456, 789],
  /// );
  /// ```
  Future<dynamic> broadcastNotification({
    required String title,
    required String message,
    String? targetRole,
    List<int>? targetUserIds,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      // Validate required fields
      if (title.trim().isEmpty) {
        throw ArgumentError('Title is required');
      }
      if (message.trim().isEmpty) {
        throw ArgumentError('Message is required');
      }

      final body = {
        'title': title,
        'message': message,
        if (targetRole != null && targetRole.isNotEmpty)
          'target_role': targetRole,
        if (targetUserIds != null && targetUserIds.isNotEmpty)
          'target_user_ids': targetUserIds,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        if (actionUrl != null && actionUrl.isNotEmpty) 'action_url': actionUrl,
      };

      print('📢 Broadcasting notification');
      print('   Title: $title');
      if (targetRole != null) print('   Target: $targetRole');
      if (targetUserIds != null) print('   Users: ${targetUserIds.length}');

      final response = await _apiClient.postJson('/api/admin/broadcast', body);

      print('✅ Notification broadcasted');
      return response['data'];
    } catch (e) {
      print('❌ Error broadcasting notification: $e');
      rethrow;
    }
  }

  // ========================================
  // Report Generation
  // ========================================

  /// Generate report
  ///
  /// GET /api/admin/reports/{type}
  ///
  /// Parameters:
  /// - [type]: Report type (orders, users, revenue, waste_collected, ratings)
  /// - [startDate]: Report start date (YYYY-MM-DD)
  /// - [endDate]: Report end date (YYYY-MM-DD)
  /// - [format]: Export format (json, csv, pdf) (optional)
  ///
  /// Returns: Report data
  ///
  /// Example:
  /// ```dart
  /// // Generate monthly revenue report
  /// final report = await adminService.generateReport(
  ///   type: 'revenue',
  ///   startDate: '2024-01-01',
  ///   endDate: '2024-01-31',
  /// );
  ///
  /// // Generate orders report as CSV
  /// final csv = await adminService.generateReport(
  ///   type: 'orders',
  ///   startDate: '2024-01-01',
  ///   endDate: '2024-01-31',
  ///   format: 'csv',
  /// );
  /// ```
  Future<dynamic> generateReport({
    required String type,
    required String startDate,
    required String endDate,
    String? format,
  }) async {
    try {
      // Validate type
      if (!reportTypes.contains(type)) {
        throw ArgumentError(
          'Invalid report type. Must be one of: ${reportTypes.join(", ")}',
        );
      }

      final query = <String, dynamic>{
        'start_date': startDate,
        'end_date': endDate,
      };

      if (format != null && format.isNotEmpty) query['format'] = format;

      print('📊 Generating $type report');
      print('   Period: $startDate to $endDate');

      final response = await _apiClient.getJson(
        '/api/admin/reports/$type',
        query: query,
      );

      print('✅ Report generated');
      return response['data'];
    } catch (e) {
      print('❌ Error generating report: $e');
      rethrow;
    }
  }

  // ========================================
  // System Management
  // ========================================

  /// Get system health status
  ///
  /// Returns: System health metrics
  ///
  /// Example:
  /// ```dart
  /// final health = await adminService.getSystemHealth();
  /// print('Database: ${health['database_status']}');
  /// print('Storage: ${health['storage_usage']}%');
  /// ```
  Future<dynamic> getSystemHealth() async {
    try {
      print('🏥 Checking system health');

      final response = await _apiClient.get('/api/admin/system/health');

      print('✅ System health retrieved');
      return response['data'];
    } catch (e) {
      print('❌ Error checking system health: $e');
      rethrow;
    }
  }

  /// Clear application cache
  ///
  /// Example:
  /// ```dart
  /// await adminService.clearCache();
  /// print('Cache cleared successfully');
  /// ```
  Future<void> clearCache() async {
    try {
      print('🗑️ Clearing application cache');

      await _apiClient.delete('/api/admin/cache/clear');

      print('✅ Cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get quick stats summary
  ///
  /// Returns: Quick overview of key metrics
  ///
  /// Example:
  /// ```dart
  /// final summary = await adminService.getQuickStats();
  /// print('Users: ${summary['total_users']}');
  /// print('Orders: ${summary['total_orders']}');
  /// ```
  Future<Map<String, dynamic>> getQuickStats() async {
    try {
      final stats = await getDashboardStats(period: 'today');

      return {
        'total_users': stats['total_users'] ?? 0,
        'total_orders': stats['total_orders'] ?? 0,
        'total_revenue': stats['total_revenue'] ?? 0.0,
        'active_orders': stats['active_orders'] ?? 0,
        'pending_orders': stats['pending_orders'] ?? 0,
      };
    } catch (e) {
      print('❌ Error getting quick stats: $e');
      return {};
    }
  }

  /// Get revenue analytics
  ///
  /// Parameters:
  /// - [period]: Time period
  ///
  /// Returns: Revenue breakdown
  ///
  /// Example:
  /// ```dart
  /// final analytics = await adminService.getRevenueAnalytics('this_month');
  /// print('Total: Rp ${analytics['total']}');
  /// print('Growth: ${analytics['growth_percentage']}%');
  /// ```
  Future<Map<String, dynamic>> getRevenueAnalytics(String period) async {
    try {
      final report = await generateReport(
        type: 'revenue',
        startDate: _getStartDate(period),
        endDate: _getEndDate(period),
      );

      return {
        'total': report['total_revenue'] ?? 0.0,
        'growth_percentage': report['growth_percentage'] ?? 0.0,
        'by_category': report['by_category'] ?? {},
      };
    } catch (e) {
      print('❌ Error getting revenue analytics: $e');
      return {};
    }
  }

  /// Get user growth analytics
  ///
  /// Parameters:
  /// - [period]: Time period
  ///
  /// Returns: User growth data
  ///
  /// Example:
  /// ```dart
  /// final growth = await adminService.getUserGrowth('this_year');
  /// print('New users: ${growth['new_users']}');
  /// ```
  Future<Map<String, dynamic>> getUserGrowth(String period) async {
    try {
      final report = await generateReport(
        type: 'users',
        startDate: _getStartDate(period),
        endDate: _getEndDate(period),
      );

      return {
        'new_users': report['new_users'] ?? 0,
        'active_users': report['active_users'] ?? 0,
        'growth_percentage': report['growth_percentage'] ?? 0.0,
      };
    } catch (e) {
      print('❌ Error getting user growth: $e');
      return {};
    }
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  String _getStartDate(String period) {
    final now = DateTime.now();

    switch (period) {
      case 'today':
        return _formatDate(now);
      case 'this_week':
        return _formatDate(now.subtract(Duration(days: now.weekday - 1)));
      case 'this_month':
        return _formatDate(DateTime(now.year, now.month, 1));
      case 'this_year':
        return _formatDate(DateTime(now.year, 1, 1));
      default:
        return _formatDate(now);
    }
  }

  String _getEndDate(String period) {
    return _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
