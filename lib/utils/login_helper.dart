import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/utils/app_logger.dart';
import 'package:flutter/material.dart';

class LoginHelper {
  static final AppLogger _logger = AppLogger('LoginHelper');

  /// Memeriksa status login dan mengambil data user dari localStorage
  /// Menavigasi ke halaman yang tepat berdasarkan role
  static Future<void> checkLoginStatusAndNavigate(BuildContext context) async {
    _logger.debug('Memeriksa status login...');

    // Get localStorage service
    final localStorage = await LocalStorageService.getInstance();

    // Check if user is logged in
    final isLoggedIn =
        await localStorage.getBool(localStorage.getLoginKey()) ?? false;

    if (!isLoggedIn) {
      _logger.debug('Pengguna belum login, tetap di halaman login');
      return;
    }

    // Get user data
    final userData = await localStorage.getUserData();
    if (userData == null) {
      _logger.warning('User data tidak ditemukan meskipun status login true');
      await localStorage.saveBool(localStorage.getLoginKey(), false);
      return;
    }

    // Check for role
    String? role = userData['role'];
    if (role == null) {
      _logger.warning('Role tidak ditemukan dalam user data');
      role = await localStorage.getUserRole();

      if (role == null) {
        _logger.warning(
          'Role tidak ditemukan juga di penyimpanan terpisah, menggunakan default: end_user',
        );
        role = 'end_user';

        // Update user data dengan role default
        userData['role'] = role;
        await localStorage.saveUserData(userData);
      }
    }

    _logger.debug('Login status: active, role: $role');

    // Navigate based on role
    if (role == 'mitra') {
      _logger.debug('Navigasi ke dashboard mitra');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/mitra-dashboard-new',
        (route) => false,
      );
    } else {
      _logger.debug('Navigasi ke dashboard pengguna');
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  /// Mencoba auto-login dengan kredensial yang tersimpan
  static Future<void> attemptAutoLogin(BuildContext context) async {
    _logger.debug('Mencoba auto-login...');

    // Get localStorage service
    final localStorage = await LocalStorageService.getInstance();

    // Check if credentials exist
    final credentials = await localStorage.getCredentials();
    if (credentials == null) {
      _logger.debug('Kredensial untuk auto-login tidak ditemukan');
      return;
    }

    _logger.debug(
      'Kredensial ditemukan untuk ${credentials['email']}, mencoba login...',
    );

    try {
      // Login using API
      final authService = AuthApiService();
      final userData = await authService.login(
        email: credentials['email']!,
        password: credentials['password']!,
      );

      _logger.debug(
        'Auto-login berhasil untuk ${userData['name']} dengan role ${userData['role']}',
      );

      // Update localStorage
      await localStorage.saveUserData(userData);
      await localStorage.saveBool(localStorage.getLoginKey(), true);

      // Navigate based on role
      if (userData['role'] == 'mitra') {
        _logger.debug('Navigasi ke dashboard mitra setelah auto-login');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/mitra-dashboard-new',
          (route) => false,
        );
      } else {
        _logger.debug('Navigasi ke dashboard pengguna setelah auto-login');
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      _logger.error('Auto-login gagal: $e');
      // Tidak menampilkan error ke user pada auto-login yang gagal
    }
  }

  /// Membersihkan semua data login dan menavigasi ke halaman login
  static Future<void> logout(BuildContext context) async {
    _logger.debug('Melakukan logout...');

    // Get localStorage service
    final localStorage = await LocalStorageService.getInstance();

    // Logout from API
    try {
      final authService = AuthApiService();
      await authService.logout();
    } catch (e) {
      _logger.warning('API logout gagal: $e');
      // Continue with local logout anyway
    }

    // Clear local login data
    await localStorage.fullLogout();

    _logger.debug('Logout berhasil, navigasi ke halaman login');

    // Navigate to login page
    Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route) => false);
  }
}
