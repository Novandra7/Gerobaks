import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:bank_sha/utils/app_config.dart';

/// Mencoba mengekstrak JSON dari respons yang mungkin tercampur dengan HTML
dynamic _tryExtractJson(String body) {
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

  // Metode untuk mendapatkan SharedPreferences instance
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Caching baseUrl untuk mengurangi overhead
  static String? _cachedBaseUrl;

  String get _baseUrl {
    // ALWAYS get fresh URL from AppConfig (no caching to prevent stale URLs)
    final currentUrl = AppConfig.apiBaseUrl;
    
    // Update cache if changed
    if (_cachedBaseUrl != currentUrl) {
      print('🔄 API URL changed: $_cachedBaseUrl -> $currentUrl');
      _cachedBaseUrl = currentUrl;
    }
    
    return currentUrl;
  }

  /// Clear cached base URL (useful when switching environments)
  static void clearCache() {
    _cachedBaseUrl = null;
    print('🔄 ApiClient cache cleared');
  }

  /// Mendapatkan base URL yang sedang digunakan untuk API
  String getBaseUrl() {
    return _baseUrl;
  }

  Uri _buildUri(String path) {
    final baseUrl = _baseUrl;
    final fullUrl = '$baseUrl$path';
    return Uri.parse(fullUrl);
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  Future<dynamic> get(String path) async {
    try {
      final uri = _buildUri(path);
      final headers = await _headers();

      print('🌐 GET $uri');
      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return null;
        return _tryExtractJson(resp.body);
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

  // GET request dengan support untuk query parameters
  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    try {
      var uri = _buildUri(path);
      if (query != null) {
        // Konversi query parameter menjadi String
        final queryParams = <String, String>{};
        query.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _headers();

      print('🌐 GET $uri');
      print('📄 Request headers: $headers');

      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('📡 Response status: ${resp.statusCode}');
      print('📡 Response body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return null;
        return _tryExtractJson(resp.body);
      }

      // Debugging respons error
      if (resp.statusCode >= 400) {
        print('❌ API Error: ${resp.statusCode}');
        try {
          final errorData = jsonDecode(resp.body);
          print('❌ Error details: $errorData');
        } catch (e) {
          print('❌ Could not parse error response: ${e.toString()}');
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

  // POST request dengan JSON body
  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    try {
      final uri = _buildUri(path);
      final headers = await _headers();

      print('🌐 POST $uri');
      print('📦 Request body: ${jsonEncode(body)}');
      print('📄 Request headers: $headers');

      final resp = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      print('📡 Response status: ${resp.statusCode}');
      print('📡 Response body: ${resp.body}');

      // Debugging respons yang lebih detail
      if (resp.statusCode >= 400) {
        print('❌ API Error: ${resp.statusCode}');
        try {
          final errorData = jsonDecode(resp.body);
          print('❌ Error details: $errorData');
        } catch (e) {
          print('❌ Could not parse error response: ${e.toString()}');
        }
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) return null;
        return _tryExtractJson(resp.body);
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

  Future<dynamic> putJson(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    final resp = await http
        .put(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return _tryExtractJson(resp.body);
    }
    throw HttpException(
      'PUT ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
      statusCode: resp.statusCode,
    );
  }

  Future<dynamic> patchJson(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    final resp = await http
        .patch(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return _tryExtractJson(resp.body);
    }
    throw HttpException(
      'PATCH ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
      statusCode: resp.statusCode,
    );
  }

  Future<dynamic> delete(String path) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    final resp = await http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return _tryExtractJson(resp.body);
    }
    throw HttpException(
      'DELETE ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
      statusCode: resp.statusCode,
    );
  }

  // Simpan token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Hapus token (untuk logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Check apakah token ada
  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Mendapatkan token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, {this.statusCode});
  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}
