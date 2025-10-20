import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Report Model untuk API response
class Report {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String description;
  final String status;
  final String? response;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.response,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      response: map['response'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'status': status,
      'response': response,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Sedang Diproses';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'bug':
        return 'Bug/Error';
      case 'feature_request':
        return 'Permintaan Fitur';
      case 'complaint':
        return 'Keluhan';
      case 'suggestion':
        return 'Saran';
      case 'payment_issue':
        return 'Masalah Pembayaran';
      case 'service_issue':
        return 'Masalah Layanan';
      default:
        return type;
    }
  }
}

/// Admin Statistics Model
class AdminStatistics {
  final int totalUsers;
  final int totalMitra;
  final int totalOrders;
  final int totalServices;
  final int pendingOrders;
  final int completedOrders;
  final int activeUsers;
  final int activeMitra;
  final double totalRevenue;
  final double monthlyRevenue;
  final Map<String, int> ordersByStatus;
  final Map<String, int> usersByRole;
  final List<Map<String, dynamic>> recentActivities;

  AdminStatistics({
    required this.totalUsers,
    required this.totalMitra,
    required this.totalOrders,
    required this.totalServices,
    required this.pendingOrders,
    required this.completedOrders,
    required this.activeUsers,
    required this.activeMitra,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.ordersByStatus,
    required this.usersByRole,
    required this.recentActivities,
  });

  factory AdminStatistics.fromMap(Map<String, dynamic> map) {
    return AdminStatistics(
      totalUsers: map['total_users']?.toInt() ?? 0,
      totalMitra: map['total_mitra']?.toInt() ?? 0,
      totalOrders: map['total_orders']?.toInt() ?? 0,
      totalServices: map['total_services']?.toInt() ?? 0,
      pendingOrders: map['pending_orders']?.toInt() ?? 0,
      completedOrders: map['completed_orders']?.toInt() ?? 0,
      activeUsers: map['active_users']?.toInt() ?? 0,
      activeMitra: map['active_mitra']?.toInt() ?? 0,
      totalRevenue: (map['total_revenue'] ?? 0).toDouble(),
      monthlyRevenue: (map['monthly_revenue'] ?? 0).toDouble(),
      ordersByStatus: Map<String, int>.from(map['orders_by_status'] ?? {}),
      usersByRole: Map<String, int>.from(map['users_by_role'] ?? {}),
      recentActivities: List<Map<String, dynamic>>.from(
        map['recent_activities'] ?? [],
      ),
    );
  }

  String get formattedTotalRevenue =>
      'Rp ${totalRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedMonthlyRevenue =>
      'Rp ${monthlyRevenue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

/// User Management Model
class UserManagement {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? profile;

  UserManagement({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  factory UserManagement.fromMap(Map<String, dynamic> map) {
    return UserManagement(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'end_user',
      status: map['status'] ?? 'active',
      emailVerifiedAt: map['email_verified_at'] != null
          ? DateTime.parse(map['email_verified_at'])
          : null,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      profile: map['profile'] != null
          ? Map<String, dynamic>.from(map['profile'])
          : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isBlocked => status == 'blocked';
  bool get isEmailVerified => emailVerifiedAt != null;

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'blocked':
        return 'Diblokir';
      case 'pending':
        return 'Menunggu';
      default:
        return status;
    }
  }

  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'mitra':
        return 'Mitra';
      case 'end_user':
        return 'Pengguna';
      default:
        return role;
    }
  }
}

/// Service untuk mengelola laporan dan administrasi
class ReportAdminService {
  ReportAdminService._internal();
  static final ReportAdminService _instance = ReportAdminService._internal();
  factory ReportAdminService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  // ==================== REPORT METHODS ====================

  /// Get list of reports with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 10)
  /// [type] - filter berdasarkan tipe report
  /// [status] - filter berdasarkan status
  Future<Map<String, dynamic>> getReports({
    int page = 1,
    int limit = 10,
    String? type,
    String? status,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (status != null) 'status': status,
      };

      final response = await _api.getJson(ApiRoutes.reports, query: query);

      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'reports': (data['data'] as List)
              .map((item) => Report.fromMap(item))
              .toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          },
        };
      }

      throw Exception('Failed to load reports');
    } catch (e) {
      print('❌ Failed to get reports: $e');
      rethrow;
    }
  }

  /// Create new report
  Future<Report> createReport({
    required String type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final requestData = {
        'type': type,
        'title': title,
        'description': description,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _api.postJson(ApiRoutes.reports, requestData);

      if (response != null && response['success'] == true) {
        return Report.fromMap(response['data']);
      }

      throw Exception('Failed to create report');
    } catch (e) {
      print('❌ Failed to create report: $e');
      rethrow;
    }
  }

  /// Update report status (admin only)
  Future<Report> updateReport(
    int id, {
    String? status,
    String? response,
  }) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final requestData = <String, dynamic>{};
      if (status != null) requestData['status'] = status;
      if (response != null) requestData['response'] = response;

      final responseData = await _api.patchJson(
        ApiRoutes.report(id),
        requestData,
      );

      if (responseData != null && responseData['success'] == true) {
        return Report.fromMap(responseData['data']);
      }

      throw Exception('Failed to update report');
    } catch (e) {
      print('❌ Failed to update report $id: $e');
      rethrow;
    }
  }

  /// Get my reports
  Future<List<Report>> getMyReports() async {
    try {
      _authManager.requireAuth();

      final result = await getReports(limit: 50);
      final allReports = result['reports'] as List<Report>;

      // Filter reports by current user
      return allReports
          .where((report) => report.userId == _authManager.userId)
          .toList();
    } catch (e) {
      print('❌ Failed to get my reports: $e');
      rethrow;
    }
  }

  /// Get report types
  List<String> getReportTypes() {
    return [
      'bug',
      'feature_request',
      'complaint',
      'suggestion',
      'payment_issue',
      'service_issue',
    ];
  }

  /// Get report statuses
  List<String> getReportStatuses() {
    return ['pending', 'in_progress', 'completed', 'rejected'];
  }

  // ==================== ADMIN METHODS ====================

  /// Get admin dashboard statistics (admin only)
  Future<AdminStatistics> getAdminStatistics() async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final response = await _api.get(ApiRoutes.adminStats);

      if (response != null && response['success'] == true) {
        return AdminStatistics.fromMap(response['data']);
      }

      throw Exception('Failed to load admin statistics');
    } catch (e) {
      print('❌ Failed to get admin statistics: $e');
      rethrow;
    }
  }

  /// Get all users with management info (admin only)
  Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
      };

      final response = await _api.getJson(ApiRoutes.adminUsers, query: query);

      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'users': (data['data'] as List)
              .map((item) => UserManagement.fromMap(item))
              .toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          },
        };
      }

      throw Exception('Failed to load users');
    } catch (e) {
      print('❌ Failed to get all users: $e');
      rethrow;
    }
  }

  /// Update user status (admin only)
  Future<UserManagement> updateUserStatus(int userId, String status) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final requestData = {'status': status};
      final response = await _api.patchJson(
        ApiRoutes.adminUser(userId),
        requestData,
      );

      if (response != null && response['success'] == true) {
        return UserManagement.fromMap(response['data']);
      }

      throw Exception('Failed to update user status');
    } catch (e) {
      print('❌ Failed to update user status: $e');
      rethrow;
    }
  }

  /// Block user (admin only)
  Future<UserManagement> blockUser(int userId) async {
    return await updateUserStatus(userId, 'blocked');
  }

  /// Unblock user (admin only)
  Future<UserManagement> unblockUser(int userId) async {
    return await updateUserStatus(userId, 'active');
  }

  /// Delete user (admin only)
  Future<bool> deleteUser(int userId) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final response = await _api.delete(ApiRoutes.adminUser(userId));

      return response != null && response['success'] == true;
    } catch (e) {
      print('❌ Failed to delete user: $e');
      rethrow;
    }
  }

  /// Create new admin user (admin only)
  Future<UserManagement> createAdminUser({
    required String name,
    required String email,
    required String password,
    String role = 'admin',
  }) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final requestData = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };

      final response = await _api.postJson(ApiRoutes.adminUsers, requestData);

      if (response != null && response['success'] == true) {
        return UserManagement.fromMap(response['data']);
      }

      throw Exception('Failed to create admin user');
    } catch (e) {
      print('❌ Failed to create admin user: $e');
      rethrow;
    }
  }

  /// Get system logs (admin only)
  Future<List<Map<String, dynamic>>> getSystemLogs({
    int page = 1,
    int limit = 20,
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (level != null) 'level': level,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _api.getJson(ApiRoutes.adminLogs, query: query);

      if (response != null && response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data']['data'] ?? []);
      }

      throw Exception('Failed to load system logs');
    } catch (e) {
      print('❌ Failed to get system logs: $e');
      rethrow;
    }
  }

  /// Export data (admin only)
  Future<String> exportData({
    required String type,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'csv',
  }) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final query = <String, dynamic>{
        'type': type,
        'format': format,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _api.getJson(ApiRoutes.adminExport, query: query);

      if (response != null && response['success'] == true) {
        return response['data']['download_url'] ?? '';
      }

      throw Exception('Failed to export data');
    } catch (e) {
      print('❌ Failed to export data: $e');
      rethrow;
    }
  }

  /// Send system notification to all users (admin only)
  Future<bool> sendSystemNotification({
    required String title,
    required String message,
    String? role, // Target specific role
    List<int>? userIds, // Target specific users
  }) async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final requestData = {
        'title': title,
        'message': message,
        if (role != null) 'role': role,
        if (userIds != null) 'user_ids': userIds,
      };

      final response = await _api.postJson(
        ApiRoutes.adminNotifications,
        requestData,
      );

      return response != null && response['success'] == true;
    } catch (e) {
      print('❌ Failed to send system notification: $e');
      rethrow;
    }
  }

  /// Get available export types
  List<String> getExportTypes() {
    return ['users', 'orders', 'payments', 'services', 'reports'];
  }

  /// Get system health status (admin only)
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      _authManager.requireRole('admin'); // Admin only

      final response = await _api.get(ApiRoutes.adminHealth);

      if (response != null && response['success'] == true) {
        return response['data'];
      }

      throw Exception('Failed to get system health');
    } catch (e) {
      print('❌ Failed to get system health: $e');
      rethrow;
    }
  }

  // ==================== PERMISSION CHECKS ====================

  /// Check if user can create reports
  bool canCreateReport() {
    return _authManager.isAuthenticated;
  }

  /// Check if user can view all reports
  bool canViewAllReports() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }

  /// Check if user can manage users
  bool canManageUsers() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }

  /// Check if user can view admin statistics
  bool canViewAdminStats() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }

  /// Check if user can export data
  bool canExportData() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }

  /// Check if user can view system logs
  bool canViewSystemLogs() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }
}
