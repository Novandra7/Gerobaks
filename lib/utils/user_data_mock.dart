import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:logger/logger.dart';

/// Class UserDataMock sekarang hanya berfungsi sebagai helper untuk
/// mendapatkan data dari API atau localStorage.
/// Tidak lagi menggunakan data hardcoded.
class UserDataMock {
  static final _logger = Logger();

  // Data kosong - semua data sekarang diambil dari API
  static final List<Map<String, dynamic>> endUsers = [];
  static final List<Map<String, dynamic>> mitras = [];

  /// Semua methods di bawah ini sekarang mengakses localStorage
  /// yang sudah diisi oleh API setelah login

  /// Gabungan semua users - sekarang tidak digunakan lagi
  static List<Map<String, dynamic>> get allUsers {
    return []; // Return empty list, data sekarang dari API
  }

  /// Mendapatkan user dari localStorage (sudah diisi oleh API setelah login)
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      // Mengambil data dari localStorage
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();

      // Jika ada data dan email cocok, kembalikan data tersebut
      if (userData != null && userData['email'] == email) {
        return userData;
      }

      // Jika tidak ada di localStorage, kembalikan null
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  /// Method ini tidak digunakan lagi - data dari API
  static Map<String, dynamic>? getUserById(String id) {
    // Tidak digunakan lagi, data dari API
    return null;
  }

  /// Method ini tidak digunakan lagi - data dari API
  static List<Map<String, dynamic>> getUsersByRole(String role) {
    // Tidak digunakan lagi, data dari API
    return [];
  }

  /// Method ini tidak digunakan lagi - login via API
  static Map<String, dynamic>? validateLogin(String email, String password) {
    // Tidak digunakan lagi, login via API
    return null;
  }

  /// Method untuk mendaftarkan user melalui API
  static Future<bool> registerEndUser(Map<String, dynamic> userData) async {
    try {
      _logger.i(
        '🔐 Registrasi user via API: ${userData['name']} (${userData['email']})',
      );

      // Gunakan API untuk registrasi
      await AuthApiService().register(
        name: userData['name'],
        email: userData['email'],
        password: userData['password'],
        role: 'end_user', // Set default role
      );

      _logger.i('✅ Registrasi API berhasil');
      return true;
    } catch (e) {
      _logger.e('❌ Registrasi gagal: $e');
      return false;
    }
  }
}
