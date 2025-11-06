import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_sha/utils/app_config.dart';

/// Force reset semua konfigurasi ke production API
/// Gunakan ini jika aplikasi masih menggunakan API lokal
class ProductionForceReset {
  /// Reset semua konfigurasi API ke production
  static Future<void> forceProductionMode() async {
    print('🔄 FORCING PRODUCTION MODE...');
    
    try {
      // 1. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_api_url');
      await prefs.remove('app_environment');
      print('✅ Cleared stored API configuration');
      
      // 2. Set production URL explicitly
      await AppConfig.setApiBaseUrl(AppConfig.PRODUCTION_API_URL);
      print('✅ Set production API URL: ${AppConfig.PRODUCTION_API_URL}');
      
      // 3. Reload config
      await AppConfig.loadStoredApiUrl();
      print('✅ Reloaded configuration');
      
      // 4. Verify
      final currentUrl = AppConfig.apiBaseUrl;
      print('✅ Current API URL: $currentUrl');
      
      if (currentUrl.contains('localhost') || 
          currentUrl.contains('127.0.0.1') || 
          currentUrl.contains('10.0.2.2')) {
        print('⚠️ WARNING: Still using local API!');
        print('⚠️ Please restart the app completely');
        return;
      }
      
      print('✅ PRODUCTION MODE ACTIVATED SUCCESSFULLY!');
      print('✅ API: $currentUrl');
      
    } catch (e) {
      print('❌ Error forcing production mode: $e');
      rethrow;
    }
  }
  
  /// Check apakah sedang menggunakan production API
  static Future<bool> isProductionMode() async {
    final url = AppConfig.apiBaseUrl;
    final isProduction = url.contains('gerobaks.dumeg.com');
    
    print('🔍 Current API: $url');
    print('🔍 Production mode: $isProduction');
    
    return isProduction;
  }
  
  /// Get detailed configuration info
  static Future<Map<String, dynamic>> getConfigInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUrl = prefs.getString('custom_api_url');
    final currentUrl = AppConfig.apiBaseUrl;
    
    return {
      'current_url': currentUrl,
      'stored_url': storedUrl ?? 'none',
      'default_url': AppConfig.DEFAULT_API_URL,
      'production_url': AppConfig.PRODUCTION_API_URL,
      'is_production': currentUrl.contains('gerobaks.dumeg.com'),
      'is_local': currentUrl.contains('localhost') || 
                  currentUrl.contains('127.0.0.1') || 
                  currentUrl.contains('10.0.2.2'),
    };
  }
}
