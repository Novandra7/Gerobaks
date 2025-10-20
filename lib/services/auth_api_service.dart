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
  }) async {
    try {
      print('🔐 Registering user via API: $name ($email)');
      final resp = await _api.postJson(ApiRoutes.register, {
        'name': name,
        'email': email,
        'password': password,
        if (role != null) 'role': role,
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
          return Map<String, dynamic>.from(data['user'] as Map);
        }

        // If no nested user key, return the data directly
        print('⚠️ Using data directly - no nested user key found');
        return Map<String, dynamic>.from(data);
      }
    }

    print('❌ Invalid response structure from API: $json');
    return {};
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
