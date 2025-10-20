import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';

/// Utility class untuk membantu proses autentikasi
/// Kelas ini menangani operasi auto-login dan penentuan role pengguna
class AuthHelper {
  // Konstanta untuk role
  static const String ROLE_END_USER = 'end_user';
  static const String ROLE_MITRA = 'mitra';
<<<<<<< HEAD
  static const String ROLE_ADMIN = 'admin';
=======
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575

  // Private constructor to prevent instantiation
  AuthHelper._();

  /// Try to automatically login using saved credentials
  ///
  /// Returns:
  /// - Map dengan kunci:
  ///   - 'success': boolean yang menunjukkan keberhasilan login
  ///   - 'role': String yang menunjukkan role pengguna ('end_user' atau 'mitra')
  static Future<Map<String, dynamic>> tryAutoLogin() async {
<<<<<<< HEAD
    print("🔑 [AUTH] Attempting auto-login...");
=======
    print("🔑 [AUTH] Attempting auto-login with saved credentials");

>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575
    try {
      // Get AuthApiService instance
      final authService = AuthApiService();
      final localStorage = await LocalStorageService.getInstance();

<<<<<<< HEAD
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

        print(
          "🔑 [AUTH] Auth success via credentials. Role: $role, Name: ${userData['name']}",
        );
        return {'success': true, 'role': role};
      } catch (e) {
        print("🔑 [AUTH] Login with saved credentials failed: $e");
        return {'success': false};
      }
=======
      // Check if we're already logged in
      final isLoggedIn = await localStorage.isLoggedIn();
      print("🔑 [AUTH] isLoggedIn status: $isLoggedIn");

      // If user is not logged in (manually logged out), don't attempt auto-login
      if (!isLoggedIn) {
        print("🔑 [AUTH] User is not logged in, skipping auto-login");
        return {'success': false};
      }

      if (isLoggedIn) {
        // Get user data to determine role
        final userData = await localStorage.getUserData();
        final String? role = userData?['role'];
        print(
          "🔑 [AUTH] Already logged in with user data: ${userData?['name']} (${userData?['email']})",
        );
        print("🔑 [AUTH] Role from user data: $role");
        return {
          'success': true,
          'role':
              role ?? ROLE_END_USER, // Default to end_user if role not found
        };
      }

      // This block will never be reached due to the logic above, but keeping for clarity
      print("🔑 [AUTH] No valid login session found");
      return {'success': false};
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575
    } catch (e) {
      print("🔑 [AUTH] Auto-login error: $e");
      return {'success': false};
    }
  }

  /// Memeriksa apakah role adalah mitra
  static bool isMitra(String? role) {
    return role == ROLE_MITRA;
  }

<<<<<<< HEAD
  /// Memeriksa apakah role adalah admin
  static bool isAdmin(String? role) {
    return role == ROLE_ADMIN;
  }

=======
>>>>>>> 2e541a34a65c54536f2513f1cd751746eb9fc575
  /// Memeriksa apakah role adalah end user
  static bool isEndUser(String? role) {
    return role == ROLE_END_USER || role == null; // Default to end_user if null
  }

  /// Memeriksa apakah user memiliki akses admin atau mitra
  static bool hasAdminAccess(String? role) {
    return role == ROLE_ADMIN || role == ROLE_MITRA;
  }
}
