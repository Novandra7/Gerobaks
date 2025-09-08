import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';

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
      // Get LocalStorageService instance
      final localStorage = await LocalStorageService.getInstance();
      
      // Check if we're already logged in
      final isLoggedIn = await localStorage.isLoggedIn();
      print("🔑 [AUTH] isLoggedIn status: $isLoggedIn");
      
      if (isLoggedIn) {
        // Get user data to determine role
        final userData = await localStorage.getUserData();
        final String? role = userData?['role'];
        print("🔑 [AUTH] Already logged in with user data: ${userData?['name']} (${userData?['email']})");
        print("🔑 [AUTH] Role from user data: $role");
        return {
          'success': true,
          'role': role ?? ROLE_END_USER // Default to end_user if role not found
        };
      }
      
      // Check if we have saved credentials
      final credentials = await localStorage.getCredentials();
      if (credentials == null) {
        print("🔑 [AUTH] No saved credentials found");
        return {'success': false};
      }
      
      // Try to login with saved credentials
      final userService = await UserService.getInstance();
      await userService.init();
      
      final user = await userService.loginUser(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      
      if (user != null) {
        // Get updated user data to determine role
        final userData = await localStorage.getUserData();
        final String? role = userData?['role'];
        print("🔑 [AUTH] Auto-login successful for: ${user.name} with role: $role");
        return {
          'success': true,
          'role': role ?? ROLE_END_USER // Default to end_user if role not found
        };
      } else {
        print("🔑 [AUTH] Auto-login failed: Invalid credentials");
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
