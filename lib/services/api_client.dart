import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage';
import 'package:bank_sha/utils/api_routes.dart'; 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mencoba mengekstrak JSON dari respons yang mungkin tercampur dengan HTML
dynamic _tryExtractJson(String body) {
  // Mencoba parse sebagaimana adanya dulu
  try {
    return jsonDecode(body);
  } catch (_) {
    // Jika gagal, coba cari JSON dengan regex
    final jsonPattern = RegExp(r'\{".*\}');
    final match = jsonPattern.firstMatch(body);
    if (match != null) {
      final jsonStr = match.group(0);
      if (jsonStr != null) {
        try {
          print('🔍 Menemukan JSON dalam respons campuran HTML+JSON');
          return jsonDecode(jsonStr);
        } catch (e) {
          print('❌ Gagal mem-parse JSON yang diekstrak: $e');
        }
      }
    }
    throw FormatException(
      'Tidak dapat mengekstrak JSON valid dari respons: $body',
    );
  }
}

class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // Caching baseUrl untuk mengurangi overhead
  static String? _cachedBaseUrl;

  String get _baseUrl {
    // Return cached value jika sudah ada
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    // Default URLs berdasarkan jenis perangkat
    // 10.0.2.2 adalah alamat khusus yang merujuk ke localhost untuk emulator Android
    // 127.0.0.1 untuk iOS simulator
    // IP LAN komputer untuk perangkat fisik (misal: 192.168.1.x)
    const String defaultUrl = 'http://10.0.2.2:8000';
    const String emulatorUrl = 'http://10.0.2.2:8000';
    const String iosSimulatorUrl = 'http://127.0.0.1:8000';
    const String physicalDeviceUrl =
        'http://192.168.1.100:8000'; // Ganti dengan IP komputer Anda

    try {
      // Prefer .env configuration. Example: API_BASE_URL=http://127.0.0.1:8000
      final env = dotenv.env['API_BASE_URL'];
      if (env != null && env.isNotEmpty) {
        print("🌐 Using API URL from .env: $env");
        _cachedBaseUrl = env;
        return env;
      }
    } catch (e) {
      print("⚠️ Error accessing dotenv: $e");
      // If we get a NotInitializedError, dotenv hasn't been loaded yet
      // We'll handle this by using the default URL
    }

    print("⚠️ PERINGATAN: API_BASE_URL tidak ditemukan di .env!");
    print("🌐 Menggunakan default URL: $defaultUrl");
    print("ℹ️ Pastikan server Laravel Anda berjalan di $defaultUrl");

    // Cache default URL
    _cachedBaseUrl = defaultUrl;
    return defaultUrl;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse(_baseUrl + normalized);

    // Untuk debugging
    print("🔗 API Request to: ${uri.toString()}");

    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v.toString())),
      },
    );
  }

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    final uri = _buildUri(path, query);
    final headers = await _headers();
    print('🛜 API GET Request: ${uri.toString()}');
    print('🔑 Headers: $headers');
    try {
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      print('📥 API Response Status: ${resp.statusCode}');
      print('📥 API Response Headers: ${resp.headers}');
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return null;
        try {
          // Coba ekstrak JSON bahkan jika tercampur dengan HTML
          return _tryExtractJson(resp.body);
        } catch (e) {
          print('🚨 Error parsing JSON response: $e');
          print('🚨 Response body: ${resp.body}');
          throw HttpException(
            'Invalid JSON response: ${resp.body.substring(0, min(100, resp.body.length))}...',
            statusCode: resp.statusCode,
          );
        }
      }
      throw HttpException(
        'GET ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
        statusCode: resp.statusCode,
      );
    } catch (e) {
      if (e is http.ClientException) {
        print('🚨 HTTP Client Error: ${e.toString()}');
        throw HttpException('Koneksi ke server gagal: ${e.toString()}');
      } else if (e is TimeoutException) {
        print('⏱️ Request Timeout: ${e.toString()}');
        throw HttpException('Koneksi timeout: Server tidak merespons');
      }
      print('🚨 Unknown Error: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    print('🛜 API POST Request: ${uri.toString()}');
    print('📤 Request Body: ${jsonEncode(body)}');
    print('🔑 Headers: $headers');

    bool isLoginRequest =
        path.endsWith('/login') || path.endsWith('/api/login');
    if (isLoginRequest) {
      print('🔐 DETECTED LOGIN REQUEST');
    }

    try {
      final resp = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      print('📥 API POST Response Status: ${resp.statusCode}');
      print('📥 API Response Headers: ${resp.headers}');

      // Print raw response body for debugging (limit to first 1000 chars if too long)
      final previewLength = min(1000, resp.body.length);
      print(
        '📥 API POST Response Body (preview): ${resp.body.substring(0, previewLength)}${resp.body.length > previewLength ? "..." : ""}',
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return null;
        try {
          // Coba ekstrak JSON bahkan jika tercampur dengan HTML
          final result = _tryExtractJson(resp.body);

          // Special logging for login request
          if (isLoginRequest) {
            print('🔐 LOGIN RESPONSE STRUCTURE:');
            if (result is Map) {
              print('- Root keys: ${result.keys.toList()}');
              if (result['data'] is Map) {
                final data = result['data'] as Map;
                print('- Data keys: ${data.keys.toList()}');

                if (data['user'] is Map) {
                  final user = data['user'] as Map;
                  print('- User keys: ${user.keys.toList()}');
                  print('- User role: ${user['role']}');
                } else {
                  print('- No nested user object found in data');
                }

                if (data['token'] != null) {
                  print(
                    '- Token exists: ${data['token'].toString().substring(0, min(10, data['token'].toString().length))}...',
                  );
                }
              }
            }
          }

          return result;
        } catch (e) {
          print('🚨 Error parsing JSON response: $e');
          print('🚨 Response body: ${resp.body}');
          throw HttpException(
            'Invalid JSON response: ${resp.body.substring(0, min(100, resp.body.length))}...',
            statusCode: resp.statusCode,
          );
        }
      }
      throw HttpException(
        'POST ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
        statusCode: resp.statusCode,
      );
    } catch (e) {
      if (e is http.ClientException) {
        print('🚨 HTTP Client Error: ${e.toString()}');
        throw HttpException('Koneksi ke server gagal: ${e.toString()}');
      } else if (e is TimeoutException) {
        print('⏱️ Request Timeout: ${e.toString()}');
        throw HttpException('Koneksi timeout: Server tidak merespons');
      }
      print('🚨 Unknown Error: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> patchJson(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    final resp = await http
        .patch(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return jsonDecode(resp.body);
    }
    throw HttpException(
      'PATCH ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
      statusCode: resp.statusCode,
    );
  }
}

extension on ApiClient {
  static final _storage = FlutterSecureStorage();
  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, {this.statusCode});
  @override
  String toString() => message;
}
