import 'dart:convert';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class untuk membantu proses autentikasi
/// Kelas ini menangani operasi auto-login dan penentuan role pengguna
class AuthHelper {
  // Konstanta untuk role
  static const String ROLE_END_USER = 'end_user';
  static const String ROLE_MITRA = 'mitra';
  static const String ROLE_ADMIN = 'admin';

  // Private constructor to prevent instantiation
  AuthHelper._();

  /// Try to automatically login using saved credentials
  ///
  /// Returns:
  /// - Map dengan kunci:
  ///   - 'success': boolean yang menunjukkan keberhasilan login
  ///   - 'role': String yang menunjukkan role pengguna ('end_user' atau 'mitra')
  static Future<Map<String, dynamic>> tryAutoLogin() async {
    print("🔑 [AUTH] Attempting auto-login...");
    try {
      // Get AuthApiService instance
      final authService = AuthApiService();
      final localStorage = await LocalStorageService.getInstance();

      // Debug info
      print("🔑 [AUTH] API URL: ${authService.getBaseUrl()}");
      print("🔑 [AUTH] Checking for existing API token...");

      // Check if we're already logged in via API token
      final token = await authService.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      print("🔑 [AUTH] Has valid token: $isLoggedIn");

      if (isLoggedIn) {
        try {
          print("🔑 [AUTH] Token found, fetching user profile via API...");
          // Get user data from API
          final userData = await authService.me();
          print("🔑 [AUTH] ME API Success: ${userData.toString()}");

          String? role = userData['role'];
          print("🔑 [AUTH] Role from API: $role");

          // Validasi dan normalisasi role
          if (role != null &&
              ![ROLE_END_USER, ROLE_MITRA, ROLE_ADMIN].contains(role)) {
            print(
              "🔑 [AUTH] Invalid role '$role' found, defaulting to end_user",
            );
            role = ROLE_END_USER; // Default to end_user if role is invalid
          }

          // Ensure role exists
          if (role == null) {
            print("🔑 [AUTH] No role found, defaulting to end_user");
            role = ROLE_END_USER;
            userData['role'] = role; // Add role to userData
          }

          // Save to localStorage for backward compatibility during transition
          await localStorage.saveUserData(userData);
          await localStorage.saveBool(localStorage.getLoginKey(), true);
          
          // IMPORTANT: Also save to SharedPreferences for ApiServiceManager
          // Ensure required fields exist
          if (!userData.containsKey('created_at')) {
            userData['created_at'] = DateTime.now().toIso8601String();
          }
          if (!userData.containsKey('updated_at')) {
            userData['updated_at'] = DateTime.now().toIso8601String();
          }
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(userData));
          print("🔑 [AUTH] Saved user to SharedPreferences with keys: ${userData.keys.toList()}");
          
          // Reload ApiServiceManager auth state
          await ApiServiceManager().reloadAuthState();

          print(
            "🔑 [AUTH] Auth success via token. Role: $role, Name: ${userData['name']}",
          );
          return {'success': true, 'role': role};
        } catch (e) {
          // Token might be invalid, logout
          print("🔑 [AUTH] Error fetching user profile: $e");
          print("🔑 [AUTH] Logging out due to invalid token");
          await authService.logout();
        }
      }

      // If not logged in with token, try to login with saved credentials
      print("🔑 [AUTH] No valid token, checking for saved credentials...");
      final credentials = await localStorage.getCredentials();
      if (credentials == null) {
        print("🔑 [AUTH] No saved credentials found");
        return {'success': false};
      }

      print(
        "🔑 [AUTH] Credentials found for ${credentials['email']}, attempting login...",
      );

      // Try to login with saved credentials using API
      try {
        final userData = await authService.login(
          email: credentials['email']!,
          password: credentials['password']!,
        );

        print("🔑 [AUTH] Login successful with saved credentials");
        print("🔑 [AUTH] User data: ${userData.toString()}");

        String? role = userData['role'];
        print("🔑 [AUTH] Role from login response: $role");

        // Validasi dan normalisasi role
        if (role != null &&
            ![ROLE_END_USER, ROLE_MITRA, ROLE_ADMIN].contains(role)) {
          print("🔑 [AUTH] Invalid role '$role', defaulting to end_user");
          role = ROLE_END_USER; // Default to end_user if role is invalid
        }

        // Ensure role exists
        if (role == null) {
          print("🔑 [AUTH] No role in login response, defaulting to end_user");
          role = ROLE_END_USER;
          userData['role'] = role; // Add role to userData
        }

        // Save to localStorage for backward compatibility
        await localStorage.saveUserData(userData);
        await localStorage.saveBool(localStorage.getLoginKey(), true);
        
        // IMPORTANT: Also save to SharedPreferences for ApiServiceManager
        // Ensure required fields exist
        if (!userData.containsKey('created_at')) {
          userData['created_at'] = DateTime.now().toIso8601String();
        }
        if (!userData.containsKey('updated_at')) {
          userData['updated_at'] = DateTime.now().toIso8601String();
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(userData));
        print("🔑 [AUTH] Saved user to SharedPreferences with keys: ${userData.keys.toList()}");
        
        // Reload ApiServiceManager auth state
        await ApiServiceManager().reloadAuthState();

        print(
          "🔑 [AUTH] Auth success via credentials. Role: $role, Name: ${userData['name']}",
        );
        return {'success': true, 'role': role};
      } catch (e) {
        print("🔑 [AUTH] Login with saved credentials failed: $e");
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

  /// Memeriksa apakah role adalah admin
  static bool isAdmin(String? role) {
    return role == ROLE_ADMIN;
  }

  /// Memeriksa apakah role adalah end user
  static bool isEndUser(String? role) {
    return role == ROLE_END_USER || role == null; // Default to end_user if null
  }

  /// Memeriksa apakah user memiliki akses admin atau mitra
  static bool hasAdminAccess(String? role) {
    return role == ROLE_ADMIN || role == ROLE_MITRA;
  }
}
