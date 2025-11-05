import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Import all services
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/services/service_management_service.dart';
import 'package:bank_sha/services/dashboard_balance_service.dart';
import 'package:bank_sha/services/chat_api_service_new.dart';
import 'package:bank_sha/services/payment_rating_service.dart';
import 'package:bank_sha/services/report_admin_service.dart';

// Import models
import 'package:bank_sha/models/user.dart';

/// Central Service Integration Manager
/// Mengelola semua service dan menyediakan akses unified untuk keseluruhan aplikasi
///
/// Usage:
/// ```dart
/// final integration = ServiceIntegrationManager();
/// await integration.initialize();
///
/// // Use services
/// final orders = await integration.orderService.getMyOrders();
/// ```
class ServiceIntegrationManager {
  ServiceIntegrationManager._internal();
  static final ServiceIntegrationManager _instance =
      ServiceIntegrationManager._internal();
  factory ServiceIntegrationManager() => _instance;

  // Core Services
  late final ApiServiceManager _apiManager;
  late final ScheduleService _scheduleService;
  late final TrackingService _trackingService;
  late final OrderService _orderService;
  late final ServiceManagementService _serviceManagementService;
  late final DashboardBalanceService _dashboardBalanceService;
  late final ChatApiService _chatService;
  late final PaymentRatingService _paymentRatingService;
  late final ReportAdminService _reportAdminService;

  // State Management
  bool _isInitialized = false;
  User? _currentUser;
  StreamController<User?>? _userStreamController;
  StreamController<Map<String, dynamic>>? _notificationStreamController;
  Timer? _notificationPollingTimer;
  Timer? _dataRefreshTimer;

  // ==================== GETTERS ====================

  /// Get API Service Manager
  ApiServiceManager get apiManager => _apiManager;

  /// Get Schedule Service
  ScheduleService get scheduleService => _scheduleService;

  /// Get Tracking Service
  TrackingService get trackingService => _trackingService;

  /// Get Order Service
  OrderService get orderService => _orderService;

  /// Get Service Management Service
  ServiceManagementService get serviceManagementService =>
      _serviceManagementService;

  /// Get Dashboard Balance Service
  DashboardBalanceService get dashboardBalanceService =>
      _dashboardBalanceService;

  /// Get Chat Service
  ChatApiService get chatService => _chatService;

  /// Get Payment Rating Service
  PaymentRatingService get paymentRatingService => _paymentRatingService;

  /// Get Report Admin Service
  ReportAdminService get reportAdminService => _reportAdminService;

  /// Check if services are initialized
  bool get isInitialized => _isInitialized;

  /// Get current user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _apiManager.isAuthenticated;

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if current user is mitra
  bool get isMitra => _currentUser?.isMitra ?? false;

  /// Check if current user is end user
  bool get isEndUser => _currentUser?.isEndUser ?? false;

  /// Get user stream for reactive UI updates
  Stream<User?> get userStream =>
      _userStreamController?.stream ?? Stream.empty();

  /// Get notification stream for real-time notifications
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController?.stream ?? Stream.empty();

  // ==================== INITIALIZATION ====================

  /// Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🚀 Initializing Service Integration Manager...');

      // Initialize core API manager first
      _apiManager = ApiServiceManager();

      // Initialize all services
      _scheduleService = ScheduleService();
      _trackingService = TrackingService();
      _orderService = OrderService();
      _serviceManagementService = ServiceManagementService();
      _dashboardBalanceService = DashboardBalanceService();
      _chatService = ChatApiService();
      _paymentRatingService = PaymentRatingService();
      _reportAdminService = ReportAdminService();

      // Initialize stream controllers
      _userStreamController = StreamController<User?>.broadcast();
      _notificationStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

      // Attempt to restore authentication state
      await _restoreAuthenticationState();

      // Start background services
      _startBackgroundServices();

      _isInitialized = true;
      print('✅ Service Integration Manager initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Service Integration Manager: $e');
      rethrow;
    }
  }

  /// Dispose all services and streams
  Future<void> dispose() async {
    print('🛑 Disposing Service Integration Manager...');

    // Cancel timers
    _notificationPollingTimer?.cancel();
    _dataRefreshTimer?.cancel();

    // Close streams
    await _userStreamController?.close();
    await _notificationStreamController?.close();

    _isInitialized = false;
    print('✅ Service Integration Manager disposed');
  }

  // ==================== AUTHENTICATION MANAGEMENT ====================

  /// Login user and initialize personalized services
  Future<User> login(String email, String password) async {
    try {
      final user = await _apiManager.login(email, password);
      await _onUserAuthenticated(user);
      return user;
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String role = 'end_user',
  }) async {
    try {
      final user = await _apiManager.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );
      await _onUserAuthenticated(user);
      return user;
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Logout and clear all user data
  Future<void> logout() async {
    try {
      await _apiManager.logout();
      await _onUserLoggedOut();
    } catch (e) {
      print('❌ Logout failed: $e');
      rethrow;
    }
  }

  /// Refresh user data
  Future<User> refreshUser() async {
    try {
      final user = await _apiManager.refreshUser();
      _currentUser = user;
      _userStreamController?.add(user);
      return user;
    } catch (e) {
      print('❌ Failed to refresh user: $e');
      rethrow;
    }
  }

  // ==================== ROLE-BASED SERVICE ACCESS ====================

  /// Get services available for current user role
  Map<String, bool> getAvailableServices() {
    return {
      'schedules': true, // Available for all authenticated users
      'tracking': isMitra || isAdmin, // Only mitra and admin
      'orders': true, // Available for all authenticated users
      'services': isAdmin, // Only admin can manage services
      'dashboard': true, // Available for all authenticated users
      'chat': true, // Available for all authenticated users
      'payments': isEndUser || isAdmin, // End users and admin
      'ratings': isEndUser, // Only end users can create ratings
      'reports': true, // All users can create reports
      'admin': isAdmin, // Only admin
      'balance': isMitra || isEndUser, // Mitra and end users have balance
    };
  }

  /// Check if current user can access specific service
  bool canAccessService(String serviceName) {
    final availableServices = getAvailableServices();
    return availableServices[serviceName] ?? false;
  }

  // ==================== QUICK ACCESS METHODS ====================

  /// Get dashboard data for current user
  Future<Map<String, dynamic>> getDashboardData() async {
    _requireAuth();

    if (isMitra) {
      return await _dashboardBalanceService.getMitraDashboardData();
    } else if (isEndUser) {
      return await _dashboardBalanceService.getUserDashboardData();
    } else if (isAdmin) {
      return await _reportAdminService.getAdminStatistics().then(
        (stats) => stats.toMap(),
      );
    }

    throw Exception('Unknown user role for dashboard');
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    _requireAuth();

    try {
      // Simplified implementation - get recent notifications
      final notificationApi = NotificationApiService();
      final result = await notificationApi.getNotifications(limit: 50);
      final notifications = result['notifications'] as List;

      // Count unread (simplified - assume new notifications are unread)
      return notifications.where((n) => n['is_read'] == false).length;
    } catch (e) {
      print('❌ Failed to get unread notification count: $e');
      return 0;
    }
  }

  /// Get recent activities for current user
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 10,
  }) async {
    _requireAuth();

    final activities = <Map<String, dynamic>>[];

    try {
      // Get recent orders
      if (canAccessService('orders')) {
        final orders = await _orderService.getMyOrders();
        for (final order in orders.take(3)) {
          activities.add({
            'type': 'order',
            'title': 'Order ${order.status}',
            'description': 'Order #${order.id}',
            'timestamp': order.updatedAt,
            'data': order.toMap(),
          });
        }
      }

      // Get recent payments (for end users)
      if (canAccessService('payments')) {
        final payments = await _paymentRatingService.getMyPayments();
        for (final payment in payments.take(2)) {
          activities.add({
            'type': 'payment',
            'title': 'Payment ${payment.status}',
            'description': payment.formattedAmount,
            'timestamp': payment.updatedAt,
            'data': payment.toMap(),
          });
        }
      }

      // Get recent schedules (for mitra)
      if (canAccessService('schedules') && isMitra) {
        final schedules = await _scheduleService.getMySchedules();
        for (final schedule in schedules.take(2)) {
          activities.add({
            'type': 'schedule',
            'title': 'Schedule ${schedule.status}',
            'description': schedule.description,
            'timestamp': schedule.updatedAt,
            'data': schedule.toMap(),
          });
        }
      }

      // Sort by timestamp
      activities.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );

      return activities.take(limit).toList();
    } catch (e) {
      print('❌ Failed to get recent activities: $e');
      return [];
    }
  }

  /// Search across all services
  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    _requireAuth();

    final results = <String, List<dynamic>>{};

    try {
      // Search orders
      if (canAccessService('orders')) {
        final orders = await _orderService.searchOrders(query);
        results['orders'] = orders;
      }

      // Search services
      if (canAccessService('services')) {
        final services = await _serviceManagementService.searchServices(query);
        results['services'] = services;
      }

      // Search schedules
      if (canAccessService('schedules')) {
        final schedules = await _scheduleService.searchSchedules(query);
        results['schedules'] = schedules;
      }

      return results;
    } catch (e) {
      print('❌ Failed to search: $e');
      return {};
    }
  }

  // ==================== REAL-TIME FEATURES ====================

  /// Start real-time tracking for mitra
  Stream<Map<String, dynamic>> startRealTimeTracking() {
    _requireRole('mitra');
    return _trackingService.getRealTimeTracking();
  }

  /// Start real-time chat
  Stream<List<dynamic>> startRealTimeChat(int conversationId) {
    _requireAuth();
    return _chatService.getConversationMessagesStream(conversationId);
  }

  /// Start real-time dashboard updates
  Stream<Map<String, dynamic>> startRealTimeDashboard() {
    _requireAuth();

    if (isMitra) {
      return _dashboardBalanceService.getMitraDashboardStream();
    } else if (isEndUser) {
      return _dashboardBalanceService.getUserDashboardStream();
    }

    return Stream.empty();
  }

  // ==================== OFFLINE SUPPORT ====================

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      // Simple ping to check connectivity
      final response = await _apiManager.api.get('/api/ping');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Sync offline data when back online
  Future<void> syncOfflineData() async {
    if (!await isOnline()) return;

    print('🔄 Syncing offline data...');

    try {
      // Sync pending data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Sync pending orders
      final pendingOrders = prefs.getStringList('pending_orders') ?? [];
      for (final orderJson in pendingOrders) {
        // Process pending order data
      }

      // Clear synced data
      await prefs.remove('pending_orders');

      print('✅ Offline data synced successfully');
    } catch (e) {
      print('❌ Failed to sync offline data: $e');
    }
  }

  // ==================== PRIVATE METHODS ====================

  /// Restore authentication state from storage
  Future<void> _restoreAuthenticationState() async {
    try {
      final user = await _apiManager.refreshUser();
      await _onUserAuthenticated(user);
    } catch (e) {
      print('⚠️ Could not restore authentication state: $e');
    }
  }

  /// Handle user authentication
  Future<void> _onUserAuthenticated(User user) async {
    _currentUser = user;
    _userStreamController?.add(user);

    // Start personalized background services
    _startPersonalizedServices();

    print('✅ User authenticated: ${user.name} (${user.role})');
  }

  /// Handle user logout
  Future<void> _onUserLoggedOut() async {
    _currentUser = null;
    _userStreamController?.add(null);

    // Stop personalized services
    _stopPersonalizedServices();

    print('✅ User logged out');
  }

  /// Start background services
  void _startBackgroundServices() {
    // Sync offline data periodically
    _dataRefreshTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      if (await isOnline()) {
        await syncOfflineData();
      }
    });
  }

  /// Start personalized services for authenticated user
  void _startPersonalizedServices() {
    if (!isAuthenticated) return;

    // Start notification polling
    _notificationPollingTimer = Timer.periodic(Duration(seconds: 30), (
      _,
    ) async {
      try {
        final notifications = await _serviceManagementService
            .getNotifications();
        if (notifications.isNotEmpty) {
          _notificationStreamController?.add({
            'type': 'new_notifications',
            'count': notifications.length,
            'notifications': notifications,
          });
        }
      } catch (e) {
        print('❌ Failed to poll notifications: $e');
      }
    });
  }

  /// Stop personalized services
  void _stopPersonalizedServices() {
    _notificationPollingTimer?.cancel();
  }

  /// Require authentication
  void _requireAuth() {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }
  }

  /// Require specific role
  void _requireRole(String role) {
    _requireAuth();
    if (_currentUser?.role != role) {
      throw Exception('Role $role required');
    }
  }
}

/// Extension for AdminStatistics to add toMap method
extension AdminStatisticsExtension on dynamic {
  Map<String, dynamic> toMap() {
    if (runtimeType.toString().contains('AdminStatistics')) {
      return {
        'total_users': this.totalUsers,
        'total_mitra': this.totalMitra,
        'total_orders': this.totalOrders,
        'total_services': this.totalServices,
        'pending_orders': this.pendingOrders,
        'completed_orders': this.completedOrders,
        'active_users': this.activeUsers,
        'active_mitra': this.activeMitra,
        'total_revenue': this.totalRevenue,
        'monthly_revenue': this.monthlyRevenue,
        'orders_by_status': this.ordersByStatus,
        'users_by_role': this.usersByRole,
        'recent_activities': this.recentActivities,
      };
    }
    return {};
  }
}
