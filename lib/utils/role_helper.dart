class RoleHelper {
  static const String endUser = 'end_user';
  static const String mitra = 'mitra';
  
  static bool isEndUser(String role) {
    return role == endUser;
  }
  
  static bool isMitra(String role) {
    return role == mitra;
  }
  
  static String getDefaultRouteForRole(String role) {
    switch (role) {
      case mitra:
        return '/mitra-dashboard-new';
      case endUser:
      default:
        return '/home';
    }
  }
  
  static String getRoleDisplayName(String role) {
    switch (role) {
      case mitra:
        return 'Mitra';
      case endUser:
        return 'Pengguna';
      default:
        return 'Unknown';
    }
  }
  
  static List<String> getAllowedActionsForRole(String role) {
    switch (role) {
      case mitra:
        return [
          'view_pickup_schedule',
          'start_pickup',
          'complete_pickup',
          'generate_report',
          'view_performance',
        ];
      case endUser:
        return [
          'subscribe',
          'make_complaint',
          'track_pickup',
          'view_rewards',
          'make_payment',
        ];
      default:
        return [];
    }
  }
  
  static bool canPerformAction(String role, String action) {
    return getAllowedActionsForRole(role).contains(action);
  }
}
