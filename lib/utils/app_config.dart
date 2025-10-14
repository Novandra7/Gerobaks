import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kelas singleton untuk mengakses konfigurasi aplikasi
/// Menghindari masalah dengan dotenv yang tidak diinisialisasi
class AppConfig {
  // Singleton instance
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Default values - Updated to use production
  static const String DEFAULT_API_URL = 'https://gerobaks.dumeg.com';
  static const String DEVELOPMENT_API_URL = 'http://10.0.2.2:8000';
  static const String STAGING_API_URL = 'https://staging-gerobaks.dumeg.com';
  static const String PRODUCTION_API_URL = 'https://gerobaks.dumeg.com';
  static const String CUSTOM_API_URL_KEY = 'custom_api_url';
  static const String ENVIRONMENT_KEY = 'app_environment';

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

  // Set API URL secara manual dan simpan ke SharedPreferences
  static Future<void> setApiBaseUrl(String url) async {
    _customApiUrl = url;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CUSTOM_API_URL_KEY, url);

    print('🌐 API URL diubah dan disimpan: $url');
  }

  // Get custom API URL from SharedPreferences
  static Future<String?> _getStoredApiUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(CUSTOM_API_URL_KEY);
    } catch (e) {
      print('! Error getting stored API URL: $e');
      return null;
    }
  }

  // Safe getter for API URL with fallback
  static Future<String> get apiBaseUrlAsync async {
    // Jika URL kustom di memory, gunakan itu
    if (_customApiUrl.isNotEmpty) {
      return _customApiUrl;
    }

    // Cek apakah ada URL tersimpan di SharedPreferences
    final storedUrl = await _getStoredApiUrl();
    if (storedUrl != null && storedUrl.isNotEmpty) {
      _customApiUrl = storedUrl;
      return storedUrl;
    }

    // Fallback ke .env atau default
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

  // Synchronous getter (uses cached value or default)
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

  // Reset API URL to default
  static Future<void> resetApiBaseUrl() async {
    _customApiUrl = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(CUSTOM_API_URL_KEY);

    print('🌐 API URL direset ke default');
  }

  // Check if using custom API URL
  static bool get isUsingCustomApiUrl {
    return _customApiUrl.isNotEmpty;
  }

  // Load stored URL on app startup
  static Future<void> loadStoredApiUrl() async {
    final storedUrl = await _getStoredApiUrl();
    if (storedUrl != null && storedUrl.isNotEmpty) {
      _customApiUrl = storedUrl;
      print('🌐 Loaded stored API URL: $storedUrl');
    }
  }
}
