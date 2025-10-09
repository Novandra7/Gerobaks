import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Central API Service Manager untuk mengatur semua layanan API
/// Mengelola state autentikasi dan routing ke service yang tepat berdasarkan role
class ApiServiceManager {
  ApiServiceManager._internal();
  static final ApiServiceManager _instance = ApiServiceManager._internal();
  factory ApiServiceManager() => _instance;

  // Services
  final AuthApiService _authService = AuthApiService();
  final ApiClient _apiClient = ApiClient();
  
  // Current user state
  User? _currentUser;
  String? _currentToken;
  bool _isInitialized = false;

  // Getters for services
  AuthApiService get auth => _authService;
  ApiClient get client => _apiClient;
  
  // User state getters
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isAuthenticated => _currentUser != null && _currentToken != null;
  String? get userRole => _currentUser?.role;
  
  /// Initialize service manager - harus dipanggil saat app startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🚀 Initializing API Service Manager...');
      
      // Load persisted auth data
      await _loadPersistedAuth();
      
      // Verify token if exists
      if (_currentToken != null) {
        await _verifyCurrentUser();
      }
      
      _isInitialized = true;
      print('✅ API Service Manager initialized');
    } catch (e) {
      print('❌ Failed to initialize API Service Manager: $e');
      await clearAuth(); // Clear invalid auth data
    }
  }

  /// Load persisted authentication data
  Future<void> _loadPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString('auth_token');
    
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson);
        _currentUser = User.fromMap(userMap);
        print('📱 Loaded persisted user: ${_currentUser?.name} (${_currentUser?.role})');
      } catch (e) {
        print('❌ Failed to parse persisted user data: $e');
        await prefs.remove('current_user');
      }
    }
  }

  /// Verify current user token and refresh user data
  Future<void> _verifyCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/auth/me');
      if (response != null && response['success'] == true) {
        _currentUser = User.fromMap(response['data']['user']);
        await _persistCurrentUser();
        print('✅ User token verified and data refreshed');
      }
    } catch (e) {
      print('❌ Token verification failed: $e');
      await clearAuth();
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Persist current user data
  Future<void> _persistCurrentUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', _currentUser!.toJson());
    }
  }

  /// Login dengan email dan password
  Future<User> login(String email, String password) async {
    try {
      final response = await _authService.login(email: email, password: password);
      
      // Extract user and token from response
      if (response['user'] != null) {
        _currentUser = User.fromMap(response['user']);
        _currentToken = response['token'];
        
        await _persistCurrentUser();
        
        print('✅ Login successful: ${_currentUser?.name} (${_currentUser?.role})');
        return _currentUser!;
      }
      
      throw Exception('Invalid login response format');
    } catch (e) {
      print('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Register user baru
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String role = 'end_user',
    String? phone,
    String? address,
    String? vehicleType,
    String? vehiclePlate,
    String? workArea,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      
      // Extract user and token from response
      if (response['user'] != null) {
        _currentUser = User.fromMap(response['user']);
        _currentToken = response['token'];
        
        await _persistCurrentUser();
        
        print('✅ Registration successful: ${_currentUser?.name} (${_currentUser?.role})');
        return _currentUser!;
      }
      
      throw Exception('Invalid registration response format');
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (_currentToken != null) {
        await _apiClient.postJson('/api/auth/logout', {});
      }
    } catch (e) {
      print('⚠️ Logout API call failed: $e');
      // Continue with local logout even if API fails
    } finally {
      await clearAuth();
      print('✅ User logged out');
    }
  }

  /// Clear authentication data
  Future<void> clearAuth() async {
    _currentUser = null;
    _currentToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    await _apiClient.clearToken();
  }

  /// Refresh current user data
  Future<User> refreshUser() async {
    await _verifyCurrentUser();
    return _currentUser!;
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  /// Check if user is end_user
  bool get isEndUser => hasRole('end_user');

  /// Check if user is mitra
  bool get isMitra => hasRole('mitra');

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Get role-specific home route
  String getHomeRoute() {
    switch (userRole) {
      case 'end_user':
        return '/end-user-home';
      case 'mitra':
        return '/mitra-dashboard';
      case 'admin':
        return '/admin-dashboard';
      default:
        return '/login';
    }
  }

  /// Ensure user is authenticated
  void requireAuth() {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }
  }

  /// Ensure user has specific role
  void requireRole(String role) {
    requireAuth();
    if (!hasRole(role)) {
      throw Exception('Role $role required');
    }
  }

  /// Get user display name
  String get userDisplayName => _currentUser?.name ?? 'Unknown User';

  /// Get user email
  String get userEmail => _currentUser?.email ?? '';

  /// Get user ID
  int get userId => _currentUser?.id ?? 0;
}