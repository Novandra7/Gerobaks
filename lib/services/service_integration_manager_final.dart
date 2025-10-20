import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Import all core services
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/services/schedule_service_new.dart';
import 'package:bank_sha/services/tracking_service_new.dart';
import 'package:bank_sha/services/order_service_new.dart';
import 'package:bank_sha/services/service_management_service.dart';
import 'package:bank_sha/services/dashboard_balance_service.dart';
import 'package:bank_sha/services/chat_api_service_new.dart';
import 'package:bank_sha/services/payment_rating_service.dart';
import 'package:bank_sha/services/report_admin_service.dart';

// Import additional services
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/notification_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';

// Import models
import 'package:bank_sha/models/user.dart'; // Correct User model with role property

/// Central Service Integration Manager
/// Mengelola semua service dan menyediakan akses unified untuk keseluruhan aplikasi
///
/// Features:
/// - Centralized service management
/// - Authentication state management
/// - Role-based access control
/// - Real-time data synchronization
/// - Background service coordination
///
/// Usage:
/// ```dart
/// final integration = ServiceIntegrationManager();
/// await integration.initialize();
///
/// // Use services based on user role
/// if (integration.isAdmin) {
///   final reports = await integration.reportAdminService.getAllReports();
/// }
///
/// if (integration.isMitra) {
///   final orders = await integration.orderService.getMyOrders();
/// }
/// ```
class ServiceIntegrationManager {
  ServiceIntegrationManager._internal();
  static final ServiceIntegrationManager _instance =
      ServiceIntegrationManager._internal();
  factory ServiceIntegrationManager() => _instance;

  // ==================== CORE SERVICES ====================
  late final ApiServiceManager _apiManager;
  late final AuthApiService _authService;
  late final UserService _userService;
  late final LocalStorageService _localStorageService;
  late final NotificationService _notificationService;

  // ==================== FEATURE SERVICES ====================
  late final ScheduleService _scheduleService;
  late final TrackingService _trackingService;
  late final OrderService _orderService;
  late final ServiceManagementService _serviceManagementService;
  late final DashboardBalanceService _dashboardBalanceService;
  late final ChatApiService _chatService;
  late final PaymentRatingService _paymentRatingService;
  late final ReportAdminService _reportAdminService;

  // ==================== STATE MANAGEMENT ====================
  bool _isInitialized = false;
  User? _currentUser;
  StreamController<User?>? _userStreamController;
  StreamController<Map<String, dynamic>>? _notificationStreamController;
  StreamController<Map<String, dynamic>>? _dataUpdateStreamController;

  Timer? _notificationPollingTimer;
  Timer? _dataRefreshTimer;
  Timer? _heartbeatTimer;

  // ==================== GETTERS ====================

  /// Core Services
  ApiServiceManager get apiManager => _apiManager;
  AuthApiService get authService => _authService;
  UserService get userService => _userService;
  LocalStorageService get localStorageService => _localStorageService;
  NotificationService get notificationService => _notificationService;

  /// Feature Services
  ScheduleService get scheduleService => _scheduleService;
  TrackingService get trackingService => _trackingService;
  OrderService get orderService => _orderService;
  ServiceManagementService get serviceManagementService =>
      _serviceManagementService;
  DashboardBalanceService get dashboardBalanceService =>
      _dashboardBalanceService;
  ChatApiService get chatService => _chatService;
  PaymentRatingService get paymentRatingService => _paymentRatingService;
  ReportAdminService get reportAdminService => _reportAdminService;

  /// State Properties
  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Role Checking
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isMitra => _currentUser?.role == 'mitra';
  bool get isEndUser => _currentUser?.role == 'end_user';

  /// Streams for reactive programming
  Stream<User?> get userStream =>
      _userStreamController?.stream ?? Stream.empty();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController?.stream ?? Stream.empty();
  Stream<Map<String, dynamic>> get dataUpdateStream =>
      _dataUpdateStreamController?.stream ?? Stream.empty();

  // ==================== INITIALIZATION ====================

  /// Initialize all services and restore authentication state
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🚀 Initializing Service Integration Manager...');

      // Initialize stream controllers first
      _userStreamController = StreamController<User?>.broadcast();
      _notificationStreamController =
          StreamController<Map<String, dynamic>>.broadcast();
      _dataUpdateStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

      // Initialize core services in order
      await _initializeCoreServices();

      // Initialize feature services
      await _initializeFeatureServices();

      // Restore authentication state if available
      await _restoreAuthenticationState();

      // Start background services
      _startBackgroundServices();

      _isInitialized = true;
      print('✅ Service Integration Manager initialized successfully');

      // Notify initialization complete
      _dataUpdateStreamController?.add({
        'type': 'initialization_complete',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Failed to initialize Service Integration Manager: $e');
      rethrow;
    }
  }

  /// Initialize core services that other services depend on
  Future<void> _initializeCoreServices() async {
    _apiManager = ApiServiceManager();
    _authService = AuthApiService();
    _userService = await UserService.getInstance();
    _localStorageService = await LocalStorageService.getInstance();
    _notificationService = NotificationService();

    print('✅ Core services initialized');
  }

  /// Initialize feature services
  Future<void> _initializeFeatureServices() async {
    _scheduleService = ScheduleService();
    _trackingService = TrackingService();
    _orderService = OrderService();
    _serviceManagementService = ServiceManagementService();
    _dashboardBalanceService = DashboardBalanceService();
    _chatService = ChatApiService();
    _paymentRatingService = PaymentRatingService();
    _reportAdminService = ReportAdminService();

    print('✅ Feature services initialized');
  }

  /// Restore authentication state from local storage
  Future<void> _restoreAuthenticationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        // Set token in API manager (token handled by AuthApiService internally)

        // Verify token is still valid by getting current user
        try {
          final currentUserResponse = await _authService.me();
          if (currentUserResponse['user'] != null) {
            final currentUser = User.fromMap(currentUserResponse['user']);
            await _setCurrentUser(currentUser);
            print('✅ Authentication state restored successfully');
          }
        } catch (e) {
          print('⚠️ Cached token invalid, clearing auth state: $e');
          await logout();
        }
      }
    } catch (e) {
      print('⚠️ Failed to restore authentication state: $e');
    }
  }

  /// Start background services for real-time updates
  void _startBackgroundServices() {
    // Start notification polling (every 30 seconds)
    _notificationPollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _pollNotifications(),
    );

    // Start data refresh (every 5 minutes)
    _dataRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _refreshData(),
    );

    // Start heartbeat (every 2 minutes)
    _heartbeatTimer = Timer.periodic(
      const Duration(minutes: 2),
      (timer) => _sendHeartbeat(),
    );

    print('✅ Background services started');
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Login user with credentials
  Future<User?> login(String email, String password) async {
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true && response['user'] != null) {
        final user = User.fromMap(response['user']);
        final token = response['token'] ?? response['access_token'];

        // Cache authentication data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', response['user'].toString());

        await _setCurrentUser(user);

        print('✅ User logged in successfully: ${user.name}');
        return user;
      }

      return null;
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Register new user
  Future<User?> register(Map<String, dynamic> userData) async {
    try {
      final response = await _authService.register(
        name: userData['name'],
        email: userData['email'],
        password: userData['password'],
        role: userData['role'],
      );

      if (response['success'] == true && response['user'] != null) {
        final user = User.fromMap(response['user']);
        final token = response['token'] ?? response['access_token'];

        // Cache authentication data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', response['user'].toString());

        await _setCurrentUser(user);

        print('✅ User registered successfully: ${user.name}');
        return user;
      }

      return null;
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Call logout API if authenticated
      if (isAuthenticated) {
        try {
          await _authService.logout();
        } catch (e) {
          print('⚠️ API logout failed, proceeding with local logout: $e');
        }
      }

      // Clear local authentication state
      await _apiManager.clearAuth();
      await _setCurrentUser(null);

      // Clear cached data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      // Stop background services
      _stopBackgroundServices();

      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Logout failed: $e');
      rethrow;
    }
  }

  /// Set current user and notify listeners
  Future<void> _setCurrentUser(User? user) async {
    _currentUser = user;
    _userStreamController?.add(user);

    // Emit user change event
    _dataUpdateStreamController?.add({
      'type': 'user_changed',
      'user': user?.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==================== DATA METHODS ====================

  /// Get role-specific dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      Map<String, dynamic> dashboardData = {};

      if (isAdmin) {
        // Admin dashboard data
        dashboardData = await _getAdminDashboardData();
      } else if (isMitra) {
        // Mitra dashboard data
        dashboardData = await _getMitraDashboardData();
      } else if (isEndUser) {
        // End user dashboard data
        dashboardData = await _getEndUserDashboardData();
      }

      _dataUpdateStreamController?.add({
        'type': 'dashboard_updated',
        'data': dashboardData,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return dashboardData;
    } catch (e) {
      print('❌ Failed to get dashboard data: $e');
      rethrow;
    }
  }

  /// Get admin-specific dashboard data
  Future<Map<String, dynamic>> _getAdminDashboardData() async {
    // Using placeholder methods until services are verified
    return {
      'users': [], // await _userService.getAllUsers(),
      'reports': [], // await _reportAdminService.getAllReports(),
      'statistics': {}, // await _dashboardBalanceService.getStatistics(),
      'recent_activities': await _getRecentActivities(),
    };
  }

  /// Get mitra-specific dashboard data
  Future<Map<String, dynamic>> _getMitraDashboardData() async {
    return {
      'orders': await _orderService.getMyOrders(),
      'schedule': [], // await _scheduleService.getMySchedule(),
      'earnings': {}, // await _dashboardBalanceService.getMyEarnings(),
      'ratings': [], // await _paymentRatingService.getMyRatings(),
    };
  }

  /// Get end user dashboard data
  Future<Map<String, dynamic>> _getEndUserDashboardData() async {
    return {
      'my_orders': await _orderService.getMyOrders(),
      'balance': {}, // await _dashboardBalanceService.getMyBalance(),
      'notifications': [], // await _notificationService.getMyNotifications(),
      'tracking': [], // await _trackingService.getActiveTracking(),
    };
  }

  /// Get recent activities for admin
  Future<List<Map<String, dynamic>>> _getRecentActivities() async {
    // Implementation for recent activities
    return [];
  }

  // ==================== BACKGROUND SERVICES ====================

  /// Poll for new notifications
  Future<void> _pollNotifications() async {
    try {
      if (!isAuthenticated) return;

      // Placeholder until notification service methods are verified
      final notifications = <Map<String, dynamic>>[];

      if (notifications.isNotEmpty) {
        _notificationStreamController?.add({
          'type': 'notifications',
          'data': notifications,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('⚠️ Failed to poll notifications: $e');
    }
  }

  /// Refresh cached data
  Future<void> _refreshData() async {
    try {
      if (!isAuthenticated) return;

      // Refresh dashboard data
      await getDashboardData();

      print('✅ Data refreshed successfully');
    } catch (e) {
      print('⚠️ Failed to refresh data: $e');
    }
  }

  /// Send heartbeat to maintain connection
  Future<void> _sendHeartbeat() async {
    try {
      if (!isAuthenticated) return;

      // Verify auth token is still valid
      final userResponse = await _authService.me();
      if (userResponse['user'] == null) {
        print('⚠️ Heartbeat failed - token invalid, logging out');
        await logout();
      }
    } catch (e) {
      print('⚠️ Heartbeat failed: $e');
    }
  }

  /// Stop all background services
  void _stopBackgroundServices() {
    _notificationPollingTimer?.cancel();
    _dataRefreshTimer?.cancel();
    _heartbeatTimer?.cancel();

    _notificationPollingTimer = null;
    _dataRefreshTimer = null;
    _heartbeatTimer = null;

    print('✅ Background services stopped');
  }

  // ==================== CLEANUP ====================

  /// Dispose all resources
  Future<void> dispose() async {
    _stopBackgroundServices();

    await _userStreamController?.close();
    await _notificationStreamController?.close();
    await _dataUpdateStreamController?.close();

    _userStreamController = null;
    _notificationStreamController = null;
    _dataUpdateStreamController = null;

    _isInitialized = false;
    _currentUser = null;

    print('✅ Service Integration Manager disposed');
  }
}
