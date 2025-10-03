import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';

/// Utility class untuk membantu proses autentikasi
/// Kelas ini menangani operasi auto-login dan penentuan role pengguna
class AuthHelper {
  // Konstanta untuk role
  static const String ROLE_END_USER = 'end_user';
  static const String ROLE_MITRA = 'mitra';

  // Private constructor to prevent instantiation
  AuthHelper._();

  /// Try to automatically login using saved credentials
  ///
  /// Returns:
  /// - Map dengan kunci:
  ///   - 'success': boolean yang menunjukkan keberhasilan login
  ///   - 'role': String yang menunjukkan role pengguna ('end_user' atau 'mitra')
  static Future<Map<String, dynamic>> tryAutoLogin() async {
    print("🔑 [AUTH] Attempting auto-login with saved credentials");

    try {
      // Get AuthApiService instance
      final authService = AuthApiService();
      final localStorage =
          await LocalStorageService.getInstance(); // Still needed for transition period

      // Check if we're already logged in via API token
      final token = await authService.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      print("🔑 [AUTH] isLoggedIn status from token: $isLoggedIn");

      if (isLoggedIn) {
        try {
          // Get user data from API
          final userData = await authService.me();
          final String? role = userData['role'];
          print(
            "🔑 [AUTH] Already logged in with user data: ${userData['name']} (${userData['email']})",
          );
          print("🔑 [AUTH] Role from API: $role");

          // Save to localStorage for backward compatibility during transition
          await localStorage.saveUserData(userData);
          await localStorage.saveBool(localStorage.getLoginKey(), true);

          return {
            'success': true,
            'role':
                role ?? ROLE_END_USER, // Default to end_user if role not found
          };
        } catch (e) {
          print("🔑 [AUTH] Error fetching user data: $e");
          // Token might be invalid, logout
          await authService.logout();
        }
      }

      // If not logged in with token, try to login with saved credentials for backward compatibility
      final credentials = await localStorage.getCredentials();
      if (credentials == null) {
        print("🔑 [AUTH] No saved credentials found");
        return {'success': false};
      }

      // Try to login with saved credentials using API
      try {
        final loginResponse = await authService.login(
          email: credentials['email']!,
          password: credentials['password']!,
        );

        final userData = loginResponse;
        final String? role = userData['role'];
        print(
          "🔑 [AUTH] API Login successful for: ${userData['name']} with role: $role",
        );

        // Save to localStorage for backward compatibility
        await localStorage.saveUserData(userData);
        await localStorage.saveBool(localStorage.getLoginKey(), true);

        return {'success': true, 'role': role ?? ROLE_END_USER};
      } catch (e) {
        print("🔑 [AUTH] API Login failed: $e");
        return {'success': false};
      }
    } catch (e) {
      print("🔑 [AUTH] Auto-login error: $e");
      return {'success': false};
    }
  }

  /// Memeriksa apakah role adalah mitra
  static bool isMitra(String? role) {
    return role == ROLE_MITRA;
  }

  /// Memeriksa apakah role adalah end user
  static bool isEndUser(String? role) {
    return role == ROLE_END_USER || role == null; // Default to end_user if null
  }
}
