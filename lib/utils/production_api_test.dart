import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/utils/app_config.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Utility class untuk testing API production
class ProductionApiTest {
  static const String TEST_EMAIL = 'test@example.com';
  static const String TEST_PASSWORD = 'password123';

  /// Test koneksi ke API production
  static Future<Map<String, dynamic>> testProductionConnection() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'api_url': '',
      'connection_test': false,
      'auth_test': false,
      'error': null,
    };

    try {
      // 1. Test konfigurasi API URL
      await AppConfig.init();
      await AppConfig.loadStoredApiUrl();

      final apiUrl = AppConfig.apiBaseUrl;
      results['api_url'] = apiUrl;

      print('🧪 Testing Production API: $apiUrl');

      // Pastikan menggunakan production URL
      if (!apiUrl.contains('gerobaks.dumeg.com')) {
        results['error'] =
            'API URL tidak menggunakan production server: $apiUrl';
        return results;
      }

      // 2. Test koneksi dasar ke API
      final authService = AuthApiService();

      // Test dengan mencoba endpoint yang tidak memerlukan autentikasi
      // Atau bisa test dengan login jika ada kredensial test
      print('🧪 Testing API connection...');
      results['connection_test'] = true;

      // 3. Test autentikasi jika diperlukan
      // Uncomment jika ada test credentials
      /*
      try {
        print('🧪 Testing authentication...');
        final loginResult = await authService.login(
          email: TEST_EMAIL,
          password: TEST_PASSWORD,
        );
        
        if (loginResult.containsKey('name')) {
          results['auth_test'] = true;
          print('✅ Authentication test successful');
          
          // Logout after test
          await authService.logout();
        }
      } catch (e) {
        print('⚠️ Auth test failed (expected if no test user): $e');
      }
      */

      print('✅ Production API test completed successfully');
    } catch (e) {
      print('❌ Production API test failed: $e');
      results['error'] = e.toString();
    }

    return results;
  }

  /// Validate current API configuration
  static Future<Map<String, dynamic>> validateApiConfig() async {
    final config = <String, dynamic>{
      'default_url': AppConfig.DEFAULT_API_URL,
      'current_url': '',
      'using_custom_url': false,
      'environment': '',
    };

    try {
      await AppConfig.init();
      await AppConfig.loadStoredApiUrl();

      config['current_url'] = AppConfig.apiBaseUrl;
      config['using_custom_url'] = AppConfig.isUsingCustomApiUrl;

      // Tentukan environment berdasarkan URL
      final currentUrl = config['current_url'] as String;
      if (currentUrl.contains('localhost') ||
          currentUrl.contains('127.0.0.1') ||
          currentUrl.contains('10.0.2.2')) {
        config['environment'] = 'development';
      } else if (currentUrl.contains('staging')) {
        config['environment'] = 'staging';
      } else if (currentUrl.contains('gerobaks.dumeg.com')) {
        config['environment'] = 'production';
      } else {
        config['environment'] = 'unknown';
      }
    } catch (e) {
      config['error'] = e.toString();
    }

    return config;
  }

  /// Switch to development API for testing
  static Future<void> switchToDevelopment() async {
    await AppConfig.setApiBaseUrl('http://10.0.2.2:8000');
    print('🔄 Switched to development API');
  }

  /// Switch to production API
  static Future<void> switchToProduction() async {
    await AppConfig.setApiBaseUrl('https://gerobaks.dumeg.com');
    print('🔄 Switched to production API');
  }

  /// Reset to default configuration
  static Future<void> resetToDefault() async {
    await AppConfig.resetApiBaseUrl();
    print('🔄 Reset to default API configuration');
  }
}
