import 'package:flutter/material.dart';
import 'package:bank_sha/ui/widgets/shared/api_config_dialog.dart';
import 'package:bank_sha/utils/app_config.dart';

/// Helper untuk menampilkan dialog konfigurasi API dan fungsi lainnya
/// terkait pengelolaan API URL
class ApiHelper {
  /// Menampilkan dialog konfigurasi API
  static Future<bool?> showApiConfigDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ApiConfigDialog(),
    );
  }

  /// Mendapatkan base URL API
  static String getBaseUrl() {
    return AppConfig.apiBaseUrl;
  }

  /// Mengubah base URL API
  static void setBaseUrl(String url) {
    AppConfig.setApiBaseUrl(url);
  }

  /// Mendapatkan URL endpoint lengkap
  static String getFullUrl(String endpoint) {
    final baseUrl = getBaseUrl();
    if (baseUrl.endsWith('/') && endpoint.startsWith('/')) {
      return baseUrl + endpoint.substring(1);
    } else if (!baseUrl.endsWith('/') && !endpoint.startsWith('/')) {
      return '$baseUrl/$endpoint';
    }
    return baseUrl + endpoint;
  }
}
