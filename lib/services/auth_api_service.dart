import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bank_sha/services/api_client.dart';

class AuthApiService {
  AuthApiService._internal();
  static final AuthApiService _instance = AuthApiService._internal();
  factory AuthApiService() => _instance;

  final ApiClient _api = ApiClient();
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? role,
  }) async {
    final resp = await _api.postJson('/api/register', {
      'name': name,
      'email': email,
      'password': password,
      if (role != null) 'role': role,
    });
    return _persistFromResponse(resp);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final resp = await _api.postJson('/api/login', {
      'email': email,
      'password': password,
    });
    return _persistFromResponse(resp);
  }

  Future<void> logout() async {
    try {
      await _api.postJson('/api/auth/logout', {});
    } catch (_) {}
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<Map<String, dynamic>> me() async {
    final json = await _api.getJson('/api/auth/me');
    if (json is Map && json['data'] is Map)
      return Map<String, dynamic>.from(json['data']);
    return {};
  }

  Map<String, dynamic> _persistFromResponse(dynamic json) {
    if (json is Map && json['data'] is Map) {
      final d = json['data'] as Map;
      final token = d['token'];
      if (token is String) {
        _storage.write(key: _tokenKey, value: token);
      }
      return Map<String, dynamic>.from(d);
    }
    throw Exception('Malformed auth response: ${json.runtimeType}');
  }
}
