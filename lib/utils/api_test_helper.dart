import 'package:flutter/material.dart';
import 'package:bank_sha/utils/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Helper class untuk testing koneksi API lokal
class ApiTestHelper {
  /// Test koneksi ke backend lokal
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final baseUrl = await AppConfig.apiBaseUrlAsync;
      debugPrint('🔍 Testing connection to: $baseUrl');

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/ping'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint('✅ Backend is REACHABLE');
        return {
          'success': true,
          'message': 'Backend connected successfully',
          'url': baseUrl,
          'status': response.statusCode,
        };
      } else {
        debugPrint('⚠️ Backend returned status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Backend returned error: ${response.statusCode}',
          'url': baseUrl,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      return {
        'success': false,
        'message': 'Connection failed: $e',
        'url': await AppConfig.apiBaseUrlAsync,
      };
    }
  }

  /// Test login endpoint
  static Future<Map<String, dynamic>> testLogin({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await AppConfig.apiBaseUrlAsync;
      debugPrint('🔍 Testing login to: $baseUrl/api/auth/login');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('✅ Login successful');
        return {'success': true, 'message': 'Login successful', 'data': data};
      } else {
        debugPrint('⚠️ Login failed: ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'status': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('❌ Login test failed: $e');
      return {'success': false, 'message': 'Login test failed: $e'};
    }
  }

  /// Test get schedules endpoint
  static Future<Map<String, dynamic>> testGetSchedules({String? token}) async {
    try {
      final baseUrl = await AppConfig.apiBaseUrlAsync;
      debugPrint('🔍 Testing get schedules: $baseUrl/api/schedules');

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(Uri.parse('$baseUrl/api/schedules'), headers: headers)
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('✅ Get schedules successful');
        return {
          'success': true,
          'message': 'Schedules retrieved successfully',
          'data': data,
        };
      } else {
        debugPrint('⚠️ Get schedules failed: ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get schedules',
          'status': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('❌ Get schedules test failed: $e');
      return {'success': false, 'message': 'Get schedules test failed: $e'};
    }
  }

  /// Show test results in a dialog
  static void showTestResultDialog(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          result['success'] ? '✅ Success' : '❌ Failed',
          style: TextStyle(
            color: result['success'] ? Colors.green : Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message: ${result['message']}'),
            if (result['url'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('URL: ${result['url']}'),
              ),
            if (result['status'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Status: ${result['status']}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Run all tests
  static Future<void> runAllTests(BuildContext context) async {
    debugPrint('🚀 Running all API tests...');

    // Test 1: Connection
    final connectionResult = await testConnection();
    debugPrint('Test 1 - Connection: ${connectionResult['success']}');

    // Show results
    if (context.mounted) {
      showTestResultDialog(context, connectionResult);
    }
  }
}
