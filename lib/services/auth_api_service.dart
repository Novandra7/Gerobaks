import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:bank_sha/utils/app_config.dart';

class AuthApiService {
  AuthApiService._internal();
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;

  final ApiClient _api = ApiClient();
  static const _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? role,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('🔐 Registering user via API: $name ($email)');
      print('📍 Address: $address');
      print('📍 Coordinates: ($latitude, $longitude)');

      final resp = await _api.postJson(ApiRoutes.register, {
        'name': name,
        'email': email,
        'password': password,
        if (role != null) 'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });
      print('✅ API registration successful');
      return await _persistFromResponse(resp);
    } catch (e) {
      print('❌ API registration failed: $e');

      // Filter NotInitializedError to provide a clearer error message
      if (e.toString().contains('NotInitializedError')) {
        throw Exception('Koneksi server gagal. Silakan coba lagi.');
      } else {
        throw Exception('Registrasi gagal: ${e.toString().split('\n').first}');
      }
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Logging in user via API: $email');
      print('🔐 API URL: ${AppConfig.apiBaseUrl}${ApiRoutes.login}');
      final resp = await _api.postJson(ApiRoutes.login, {
        'email': email,
        'password': password,
      });
      print('✅ API login successful with raw response: $resp');

      // Deep inspection of response structure
      if (resp is Map) {
        print('Response type: Map');
        if (resp['data'] is Map) {
          final data = resp['data'] as Map;
          print('Data field found with keys: ${data.keys.toList()}');

          if (data['user'] is Map) {
            print(
              'Nested user data found with keys: ${(data['user'] as Map).keys.toList()}',
            );
            print('User role: ${(data['user'] as Map)['role']}');
          } else {
            print('No nested user field in data');
          }

          if (data['token'] != null) {
            print(
              'Token found: ${data['token'].toString().substring(0, 10)}...',
            );
          }
        }
      }

      return await _persistFromResponse(resp);
    } catch (e) {
      print('❌ API login failed: $e');

      // Filter NotInitializedError to provide a clearer error message
      if (e.toString().contains('NotInitializedError')) {
        throw Exception('Koneksi server gagal. Silakan coba lagi.');
      } else if (e.toString().contains('Connection refused')) {
        throw Exception(
          'Server tidak dapat dijangkau. Pastikan server berjalan.',
        );
      } else {
        throw Exception('Email atau password salah');
      }
    }
  }

  /// Mendapatkan base URL yang digunakan API
  String getBaseUrl() {
    return _api.getBaseUrl();
  }

  /// Check if email already exists
  Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      print('🔍 Checking if email exists: $email');
      final resp = await _api.get('${ApiRoutes.checkEmail}?email=$email');
      print('✅ Email check response: $resp');

      // Response format: {"exists": true/false, "message": "..."}
      if (resp is Map) {
        return {
          'exists': resp['exists'] ?? false,
          'message': resp['message'] ?? '',
        };
      }

      return {'exists': false, 'message': ''};
    } catch (e) {
      print('❌ Email check failed: $e');
      // If API error, assume email doesn't exist (let register handle it)
      return {'exists': false, 'message': 'Error checking email'};
    }
  }

  Future<void> logout() async {
    try {
      await _api.postJson(ApiRoutes.logout, {});
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>> me() async {
    final json = await _api.get(ApiRoutes.me);
    print('API me() response: $json');

    if (json is Map) {
      if (json['data'] is Map) {
        final data = json['data'] as Map;

        // Check if user data is nested under 'user' key
        if (data['user'] is Map) {
          print('✅ User data found in nested structure under "user" key');
          final userData = Map<String, dynamic>.from(data['user'] as Map);

          // Normalize field names dari backend
          _normalizeUserFields(userData);

          return userData;
        }

        // If no nested user key, return the data directly
        print('⚠️ Using data directly - no nested user key found');
        final userData = Map<String, dynamic>.from(data);

        // Normalize field names dari backend
        _normalizeUserFields(userData);

        return userData;
      }
    }

    print('❌ Invalid response structure from API: $json');
    return {};
  }

  /// Normalize field names dari backend ke format yang digunakan di app
  /// Backend bisa pakai: user_phone, user_address, etc
  /// App menggunakan: phone, address, etc
  void _normalizeUserFields(Map<String, dynamic> userData) {
    // Map user_phone → phone
    if (userData.containsKey('user_phone') && !userData.containsKey('phone')) {
      userData['phone'] = userData['user_phone'];
      print('🔄 Normalized: user_phone → phone');
    }

    // Map user_address → address
    if (userData.containsKey('user_address') &&
        !userData.containsKey('address')) {
      userData['address'] = userData['user_address'];
      print('🔄 Normalized: user_address → address');
    }

    // Map user_latitude → latitude
    if (userData.containsKey('user_latitude') &&
        !userData.containsKey('latitude')) {
      userData['latitude'] = userData['user_latitude'];
      print('🔄 Normalized: user_latitude → latitude');
    }

    // Map user_longitude → longitude
    if (userData.containsKey('user_longitude') &&
        !userData.containsKey('longitude')) {
      userData['longitude'] = userData['user_longitude'];
      print('🔄 Normalized: user_longitude → longitude');
    }
  }

  Future<Map<String, dynamic>> _persistFromResponse(dynamic json) async {
    if (json is Map && json['data'] is Map) {
      final d = json['data'] as Map;

      // Extract token directly from data
      final token = d['token'];
      if (token is String) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
      }

      // Extract user data from nested structure if available
      Map<String, dynamic> userData = {};

      if (d['user'] is Map) {
        // If user data is nested under 'user' key
        userData = Map<String, dynamic>.from(d['user'] as Map);

        // Make sure the token is included in returned data
        userData['token'] = token;

        // Normalize field names dari backend
        _normalizeUserFields(userData);

        // Debug
        print(
          '✅ User data extracted from nested structure: ${userData['name']} with role: ${userData['role']}',
        );

        return userData;
      } else {
        // Legacy path - for backward compatibility
        userData = Map<String, dynamic>.from(d);
        print('⚠️ Using legacy data structure - no nested user key found');
        return userData;
      }
    }
    throw Exception('Malformed auth response: ${json.runtimeType}');
  }
}
