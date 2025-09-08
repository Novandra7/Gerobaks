import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:bank_sha/utils/role_helper.dart';
import 'package:flutter/material.dart';

class NavigationGuard {
  static Future<bool> checkAccess({
    required BuildContext context,
    required String requiredRole,
    String? redirectRoute,
  }) async {
    try {
      // Get current user from local storage
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();
      
      if (userData == null) {
        // No user logged in, redirect to sign in
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/sign-in', 
          (route) => false,
        );
        return false;
      }
      
      // Check if user has the required role
      final userRole = userData['role'] as String?;
      if (userRole != requiredRole) {
        // Wrong role, redirect to appropriate dashboard
        final correctRoute = redirectRoute ?? RoleHelper.getDefaultRouteForRole(userRole ?? '');
        Navigator.pushNamedAndRemoveUntil(
          context,
          correctRoute,
          (route) => false,
        );
        return false;
      }
      
      return true;
    } catch (e) {
      // Error occurred, redirect to sign in
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/sign-in', 
        (route) => false,
      );
      return false;
    }
  }
  
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();
      
      if (userData != null) {
        // Get complete user data from mock
        return UserDataMock.getUserByEmail(userData['email']);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  static Future<String?> getCurrentUserRole() async {
    final user = await getCurrentUser();
    return user?['role'];
  }
  
  static Future<void> logout(BuildContext context) async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      await localStorage.logout();
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/sign-in',
        (route) => false,
      );
    } catch (e) {
      // Still navigate to sign in even if clearing fails
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/sign-in',
        (route) => false,
      );
    }
  }
  
  // Helper untuk mendapatkan route yang tepat berdasarkan role user
  static Future<String> getAppropriateRoute() async {
    final userRole = await getCurrentUserRole();
    return RoleHelper.getDefaultRouteForRole(userRole ?? '');
  }
}
