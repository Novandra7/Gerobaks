// Definisi rute API untuk Gerobaks
// Memisahkan endpoint API ke dalam satu file untuk kemudahan pengelolaan
// dan konsistensi di seluruh aplikasi

class ApiRoutes {
  // Base URL - can be changed for different environments
  static const String baseUrl =
      'http://127.0.0.1:8000'; // Default development URL

  // Authentication Routes
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';

  // User Management Routes
  static const String updateProfile = '/api/user/update-profile';
  static const String changePassword = '/api/user/change-password';
  static const String uploadProfileImage = '/api/user/upload-profile-image';

  // Dashboard Routes
  static const String dashboard = '/api/dashboard';
  static String dashboardMitra(int id) => '/api/dashboard/mitra/$id';
  static String dashboardUser(int id) => '/api/dashboard/user/$id';

  // Schedule Routes
  static const String schedules = '/api/schedules';
  static const String schedulesMobile = '/api/schedules/mobile';
  static String schedule(int id) => '/api/schedules/$id';
  static String scheduleComplete(int id) => '/api/schedules/$id/complete';
  static String scheduleCancel(int id) => '/api/schedules/$id/cancel';

  // Tracking Routes
  static const String trackings = '/api/trackings';
  static String tracking(int id) => '/api/trackings/$id';
  static String trackingBySchedule(int scheduleId) =>
      '/api/tracking/schedule/$scheduleId';

  // Order Routes
  static const String orders = '/api/orders';
  static String order(int id) => '/api/orders/$id';
  static String orderCancel(int id) => '/api/orders/$id/cancel';
  static String orderAssign(int id) => '/api/orders/$id/assign';
  static String orderStatus(int id) => '/api/orders/$id/status';

  // Payment Routes
  static const String payments = '/api/payments';
  static String payment(int id) => '/api/payments/$id';
  static String paymentMarkPaid(int id) => '/api/payments/$id/mark-paid';

  // Subscription Routes
  static const String subscriptionPlans = '/api/subscription/plans';
  static String subscriptionPlan(int id) => '/api/subscription/plans/$id';
  static const String currentSubscription = '/api/subscription/current';
  static const String subscribe = '/api/subscription/subscribe';
  static const String subscriptionHistory = '/api/subscription/history';
  static const String cancelSubscription =
      '/api/subscription/{subscription}/cancel';
  static const String activateSubscription =
      '/api/subscription/{subscription}/activate';

  // Service Routes
  static const String services = '/api/services';
  static String service(int id) => '/api/services/$id';

  // Rating Routes
  static const String ratings = '/api/ratings';
  static String rating(int id) => '/api/ratings/$id';

  // Notification Routes
  static const String notifications = '/api/notifications';
  static String notification(int id) => '/api/notifications/$id';
  static const String notificationMarkRead = '/api/notifications/mark-read';

  // Chat Routes
  static const String chats = '/api/chats';
  static String chat(int id) => '/api/chats/$id';

  // Address Routes
  static const String addresses = '/api/addresses';
  static String address(int id) => '/api/addresses/$id';

  // Balance Routes
  static const String balance = '/api/balance';
  static const String balanceTopup = '/api/balance/topup';
  static const String balanceWithdraw = '/api/balance/withdraw';
  static const String balanceLedger = '/api/balance/ledger';
  static const String balanceSummary = '/api/balance/summary';

  // Feedback Routes
  static const String feedback = '/api/feedback';

  // Settings Routes
  static const String settings = '/api/settings';
  static const String settingsApiConfig = '/api/settings/api-config';

  // Report Routes
  static const String reports = '/api/reports';
  static String report(int id) => '/api/reports/$id';

  // Admin Routes
  static const String adminStats = '/api/admin/stats';
  static const String adminUsers = '/api/admin/users';
  static String adminUser(int id) => '/api/admin/users/$id';
  static const String adminLogs = '/api/admin/logs';
  static const String adminExport = '/api/admin/export';
  static const String adminNotifications = '/api/admin/notifications';
  static const String adminHealth = '/api/admin/health';

  // Health Check Routes
  static const String ping = '/api/ping';
  static const String health = '/api/health';
}
