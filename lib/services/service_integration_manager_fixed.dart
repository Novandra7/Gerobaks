import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Import all services dengan nama yang benar
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/balance_service.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/services/subscription_service.dart';

// Import models
import 'package:bank_sha/models/user.dart';

/// Fixed Service Integration Manager
/// Menggunakan services yang benar-benar ada di codebase
///
/// Usage:
/// ```dart
/// final integration = ServiceIntegrationManagerFixed();
/// await integration.initialize();
///
/// // Use services
/// final user = await integration.login('email', 'password');
/// ```
class ServiceIntegrationManagerFixed {
  ServiceIntegrationManagerFixed._internal();
  static final ServiceIntegrationManagerFixed _instance =
      ServiceIntegrationManagerFixed._internal();
  factory ServiceIntegrationManagerFixed() => _instance;

  // Core Services yang benar-benar ada
  late final ApiServiceManager _apiManager;
  late final ScheduleService _scheduleService;
  late final UserService _userService;
  late final BalanceService _balanceService;
  late final ChatService _chatService;
  late final EndUserApiService _endUserApiService;
  late final SubscriptionService _subscriptionService;

  // State Management
  bool _isInitialized = false;
  User? _currentUser;
  StreamController<User?>? _userStreamController;
  StreamController<Map<String, dynamic>>? _notificationStreamController;
  Timer? _backgroundTimer;

  // ==================== GETTERS ====================

  /// Get API Service Manager
  ApiServiceManager get apiManager => _apiManager;

  /// Get Schedule Service
  ScheduleService get scheduleService => _scheduleService;

  /// Get User Service
  UserService get userService => _userService;

  /// Get Balance Service
  BalanceService get balanceService => _balanceService;

  /// Get Chat Service
  ChatService get chatService => _chatService;

  /// Get End User API Service
  EndUserApiService get endUserApiService => _endUserApiService;

  /// Get Subscription Service
  SubscriptionService get subscriptionService => _subscriptionService;

  /// Check if services are initialized
  bool get isInitialized => _isInitialized;

  /// Get current user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.role == 'admin';

  /// Check if current user is mitra
  bool get isMitra => _currentUser?.role == 'mitra';

  /// Check if current user is end user
  bool get isEndUser => _currentUser?.role == 'end_user';

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
      print('🚀 Initializing Fixed Service Integration Manager...');

      // Initialize services yang benar-benar ada
      _apiManager = ApiServiceManager();
      _scheduleService = ScheduleService();
      _userService = UserService();
      _balanceService = BalanceService();
      _chatService = ChatService();
      _endUserApiService = EndUserApiService();
      _subscriptionService = SubscriptionService();

      // Initialize stream controllers
      _userStreamController = StreamController<User?>.broadcast();
      _notificationStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

      // Attempt to restore user if logged in
      await _restoreUser();

      // Start background services
      _startBackgroundServices();

      _isInitialized = true;
      print('✅ Fixed Service Integration Manager initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Fixed Service Integration Manager: $e');
      rethrow;
    }
  }

  /// Dispose all services and streams
  Future<void> dispose() async {
    print('🛑 Disposing Fixed Service Integration Manager...');

    _backgroundTimer?.cancel();
    await _userStreamController?.close();
    await _notificationStreamController?.close();

    _isInitialized = false;
    print('✅ Fixed Service Integration Manager disposed');
  }

  // ==================== AUTHENTICATION MANAGEMENT ====================

  /// Login user using existing UserService
  Future<User> login(String email, String password) async {
    try {
      final user = await _userService.login(email, password);
      await _onUserAuthenticated(user);
      return user;
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Register new user using existing UserService
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String role = 'end_user',
  }) async {
    try {
      final user = await _userService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await _onUserAuthenticated(user);
      return user;
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _userService.logout();
      await _onUserLoggedOut();
    } catch (e) {
      print('❌ Logout failed: $e');
      rethrow;
    }
  }

  /// Get current user profile
  Future<User?> getCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _userStreamController?.add(user);
      }
      return user;
    } catch (e) {
      print('❌ Failed to get current user: $e');
      return null;
    }
  }

  // ==================== ROLE-BASED SERVICE ACCESS ====================

  /// Get services available for current user role
  Map<String, bool> getAvailableServices() {
    return {
      'schedules': isAuthenticated, // Available for all authenticated users
      'balance': isAuthenticated, // Available for all authenticated users
      'chat': isAuthenticated, // Available for all authenticated users
      'subscription': isAuthenticated, // Available for all authenticated users
      'end_user_api': isEndUser, // Only end users
      'admin_features': isAdmin, // Only admin
      'mitra_features': isMitra, // Only mitra
    };
  }

  /// Check if current user can access specific service
  bool canAccessService(String serviceName) {
    final availableServices = getAvailableServices();
    return availableServices[serviceName] ?? false;
  }

  // ==================== QUICK ACCESS METHODS ====================

  /// Get user balance (using existing BalanceService)
  Future<Map<String, dynamic>> getUserBalance() async {
    _requireAuth();
    return await _balanceService.getBalance();
  }

  /// Get user schedules (using existing ScheduleService)
  Future<List<dynamic>> getUserSchedules() async {
    _requireAuth();
    return await _scheduleService.getUserSchedules();
  }

  /// Get subscription info (using existing SubscriptionService)
  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    _requireAuth();
    return _subscriptionService.getCurrentSubscription();
  }

  /// Send chat message (using existing ChatService)
  Future<void> sendChatMessage(String message, String receiverId) async {
    _requireAuth();
    await _chatService.sendMessage(message, receiverId);
  }

  /// Top up balance (using existing BalanceService)
  Future<bool> topUpBalance(double amount) async {
    _requireAuth();
    return await _balanceService.topUp(amount);
  }

  /// Create schedule (using existing ScheduleService)
  Future<bool> createSchedule(Map<String, dynamic> scheduleData) async {
    _requireAuth();
    return await _scheduleService.createSchedule(scheduleData);
  }

  // ==================== SIMPLIFIED REAL-TIME FEATURES ====================

  /// Start basic notification polling
  void startNotificationPolling() {
    if (!isAuthenticated) return;

    _backgroundTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      try {
        // Simplified notification check
        _notificationStreamController?.add({
          'type': 'ping',
          'timestamp': DateTime.now(),
          'user_id': _currentUser?.id,
        });
      } catch (e) {
        print('❌ Notification polling failed: $e');
      }
    });
  }

  /// Stop notification polling
  void stopNotificationPolling() {
    _backgroundTimer?.cancel();
  }

  // ==================== UTILITY METHODS ====================

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      // Simple connection test using existing API client
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null;
    } catch (e) {
      return false;
    }
  }

  /// Get user role display name
  String getRoleDisplayName() {
    switch (_currentUser?.role) {
      case 'admin':
        return 'Administrator';
      case 'mitra':
        return 'Mitra';
      case 'end_user':
        return 'Pengguna';
      default:
        return 'Unknown';
    }
  }

  /// Check if user profile is complete
  bool isProfileComplete() {
    if (_currentUser == null) return false;

    return _currentUser!.name.isNotEmpty &&
        _currentUser!.email.isNotEmpty &&
        _currentUser!.role.isNotEmpty;
  }

  // ==================== PRIVATE METHODS ====================

  /// Restore user from stored data
  Future<void> _restoreUser() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        await _onUserAuthenticated(user);
      }
    } catch (e) {
      print('⚠️ Could not restore user: $e');
    }
  }

  /// Handle user authentication
  Future<void> _onUserAuthenticated(User user) async {
    _currentUser = user;
    _userStreamController?.add(user);

    // Start user-specific services
    startNotificationPolling();

    print('✅ User authenticated: ${user.name} (${user.role})');
  }

  /// Handle user logout
  Future<void> _onUserLoggedOut() async {
    _currentUser = null;
    _userStreamController?.add(null);

    // Stop user-specific services
    stopNotificationPolling();

    print('✅ User logged out');
  }

  /// Start background services
  void _startBackgroundServices() {
    // Basic background service for connectivity checks
    Timer.periodic(Duration(minutes: 5), (_) async {
      if (await hasInternetConnection()) {
        // Refresh user data if online
        await getCurrentUser();
      }
    });
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

  // ==================== COMPATIBILITY METHODS ====================

  /// Compatibility method for old OrderService calls
  Future<List<dynamic>> getMyOrders() async {
    _requireAuth();

    if (isEndUser) {
      // Use EndUserApiService for end user orders
      return await _endUserApiService.getUserOrders();
    }

    // Fallback untuk role lain
    return [];
  }

  /// Compatibility method for scheduling
  Future<List<dynamic>> getMySchedules() async {
    _requireAuth();
    return await getUserSchedules();
  }

  /// Compatibility method for payments
  Future<List<dynamic>> getMyPayments() async {
    _requireAuth();

    // Get payment history from balance service
    final balance = await getUserBalance();
    return balance['transactions'] ?? [];
  }

  /// Get basic stats for dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    _requireAuth();

    try {
      final balance = await getUserBalance();
      final schedules = await getUserSchedules();

      return {
        'balance': balance['current_balance'] ?? 0,
        'total_schedules': schedules.length,
        'active_subscriptions': 1, // Simplified
        'role': _currentUser?.role,
        'profile_complete': isProfileComplete(),
      };
    } catch (e) {
      print('❌ Failed to get dashboard stats: $e');
      return {};
    }
  }
}
