import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Kelas singleton untuk mengakses konfigurasi aplikasi
/// Menghindari masalah dengan dotenv yang tidak diinisialisasi
class AppConfig {
  // Singleton instance
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Default values
  static const String DEFAULT_API_URL = 'http://10.0.2.2:8000';

  // Initialize config - call this before using any methods
  static bool _isInitialized = false;

  // Initialize with defaults if dotenv fails
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: '.env');
      print('✓ .env file loaded successfully');
    } catch (e) {
      print('✗ Could not load .env file: $e');
      print('✓ Using default configuration values');
    }

    _isInitialized = true;
  }

  // Variable untuk menyimpan API URL kustom
  static String _customApiUrl = '';

  // Set API URL secara manual - berguna untuk development
  static void setApiBaseUrl(String url) {
    _customApiUrl = url;
    print('🌐 API URL diubah menjadi: $url');
  }

  // Safe getter for API URL with fallback
  static String get apiBaseUrl {
    // Jika URL kustom telah diatur, gunakan itu
    if (_customApiUrl.isNotEmpty) {
      return _customApiUrl;
    }

    try {
      final url = dotenv.env['API_BASE_URL'] ?? DEFAULT_API_URL;
      print('🌐 Using API URL: $url');
      return url;
    } catch (e) {
      print('! Error accessing dotenv: $e');
      print('🌐 Fallback to default API URL: $DEFAULT_API_URL');
      return DEFAULT_API_URL;
    }
  }
}
