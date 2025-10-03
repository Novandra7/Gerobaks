import 'dart:convert';
import 'dart:math';
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

  String get _baseUrl {
    try {
      // Prefer .env configuration. Example: API_BASE_URL=http://127.0.0.1:8000
      final env = dotenv.env['API_BASE_URL'];
      if (env != null && env.isNotEmpty) {
        print("🌐 Using API URL from .env: $env");
        return env;
      }
    } catch (e) {
      print("⚠️ Error accessing dotenv: $e");
      // If we get a NotInitializedError, dotenv hasn't been loaded yet
      // We'll handle this by using the default URL
    }

    // Default fallback - menggunakan 10.0.2.2 untuk emulator Android
    // 10.0.2.2 adalah alamat khusus yang merujuk ke localhost komputer host
    const defaultUrl = 'http://10.0.2.2:8000';
    print("⚠️ PERINGATAN: API_BASE_URL tidak ditemukan di .env!");
    print("🌐 Menggunakan default URL: $defaultUrl");
    print("ℹ️ Pastikan server Laravel Anda berjalan di $defaultUrl");
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
    final resp = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
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
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final uri = _buildUri(path);
    final headers = await _headers();
    final resp = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
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
      'POST ${uri.toString()} failed: ${resp.statusCode} ${resp.body}',
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
