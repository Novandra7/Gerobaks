import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';

/// Utility class to help with authentication
class AuthHelper {
  // Private constructor to prevent instantiation
  AuthHelper._();
  
  /// Try to automatically login using saved credentials
  static Future<bool> tryAutoLogin() async {
    print("Attempting auto-login with saved credentials");
    
    try {
      // Get LocalStorageService instance
      final localStorage = await LocalStorageService.getInstance();
      
      // Check if we're already logged in
      final isLoggedIn = await localStorage.isLoggedIn();
      if (isLoggedIn) {
        print("Already logged in, no auto-login needed");
        return true;
      }
      
      // Check if we have saved credentials
      final credentials = await localStorage.getCredentials();
      if (credentials == null) {
        print("No saved credentials found");
        return false;
      }
      
      // Try to login with saved credentials
      final userService = await UserService.getInstance();
      await userService.init();
      
      final user = await userService.loginUser(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      
      if (user != null) {
        print("Auto-login successful for: ${user.name}");
        return true;
      } else {
        print("Auto-login failed: Invalid credentials");
        return false;
      }
    } catch (e) {
      print("Auto-login error: $e");
      return false;
    }
  }
}
