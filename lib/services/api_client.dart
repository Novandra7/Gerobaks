import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  String get _baseUrl {
    // Prefer .env configuration. Example: API_BASE_URL=http://127.0.0.1:8000
    final env = dotenv.env['API_BASE_URL'];
    if (env != null && env.isNotEmpty) return env;

    // Default fallback for local dev
    // Note: On Android emulator, set API_BASE_URL to http://10.0.2.2:8000 in .env
    return 'http://127.0.0.1:8000';
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse(_baseUrl + normalized);
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
      return jsonDecode(resp.body);
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
      return jsonDecode(resp.body);
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
