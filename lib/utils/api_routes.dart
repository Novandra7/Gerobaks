// Definisi rute API untuk Gerobaks
// Memisahkan endpoint API ke dalam satu file untuk kemudahan pengelolaan
// dan konsistensi di seluruh aplikasi

import 'package:bank_sha/utils/app_config.dart';

class ApiRoutes {
  // Base URL - Use production API by default from AppConfig
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Development fallback for testing
  static const String devBaseUrl = 'http://127.0.0.1:8000';

  // Authentication Routes
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String checkEmail = '/api/check-email';
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

  // Mitra Routes
  static const String mitraSchedules = '/api/mitra/schedules';
  static const String mitraActivities = '/api/mitra/activities';
  static const String mitraOrders = '/api/mitra/orders';
  static String mitraDashboard(int id) => '/api/dashboard/mitra/$id';
  static const String mitraStatistics = '/api/mitra/statistics';

  // Mitra Pickup System Routes (New)
  static const String mitraPickupAvailable =
      '/api/mitra/pickup-schedules/available';
  static String mitraPickupDetail(int id) => '/api/mitra/pickup-schedules/$id';
  static String mitraPickupAccept(int id) =>
      '/api/mitra/pickup-schedules/$id/accept';
  static String mitraPickupStartJourney(int id) =>
      '/api/mitra/pickup-schedules/$id/start-journey';
  static String mitraPickupArrive(int id) =>
      '/api/mitra/pickup-schedules/$id/arrive';
  static String mitraPickupComplete(int id) =>
      '/api/mitra/pickup-schedules/$id/complete';
  static String mitraPickupCancel(int id) =>
      '/api/mitra/pickup-schedules/$id/cancel';
  static const String mitraPickupMyActive =
      '/api/mitra/pickup-schedules/my-active';
  static const String mitraPickupHistory =
      '/api/mitra/pickup-schedules/history';

  // Activity Routes
  static const String activities = '/api/activities';
  static String activity(int id) => '/api/activities/$id';

  // Schedule Routes
  static const String schedules = '/api/schedules';
  static const String schedulesMobile = '/api/schedules/mobile';
  static String schedule(int id) => '/api/schedules/$id';
  static String scheduleComplete(int id) => '/api/schedules/$id/complete';
  static String scheduleCancel(int id) => '/api/schedules/$id/cancel';

  // Pickup Schedule Routes
  static const String pickupSchedules = '/api/pickup-schedules';
  static String pickupSchedule(int id) => '/api/pickup-schedules/$id';

  // Tracking Routes (Legacy)
  static const String trackings = '/api/trackings';
  static String tracking(int id) => '/api/trackings/$id';
  static String trackingBySchedule(int scheduleId) =>
      '/api/tracking/schedule/$scheduleId';

  // Real-Time Tracking Routes (New Backend Implementation)
  // Mitra Tracking
  static const String mitraTrackingUpdateLocation =
      '/api/mitra/tracking/update-location';
  static const String mitraTrackingStop = '/api/mitra/tracking/stop';

  // User Tracking
  static String userTrackingInfo(int pickupScheduleId) =>
      '/api/user/tracking/$pickupScheduleId';
  static String userTrackingHistory(int pickupScheduleId) =>
      '/api/user/tracking/$pickupScheduleId/history';

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
  static const String subscribe = '/api/subscriptions';
  static const String subscriptionHistory = '/api/subscription/history';
  static String cancelSubscription(String subscriptionId) => '/api/subscriptions/$subscriptionId/cancel';
  static String activateSubscription(String subscriptionId) => '/api/subscriptions/$subscriptionId/activate';

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

  // Address Routes (admin/general)
  static const String addresses = '/api/addresses';
  static String address(int id) => '/api/addresses/$id';

  // User Address Routes
  static const String userAddresses = '/api/user/addresses';
  static String userAddress(int id) => '/api/user/addresses/$id';
  static String userAddressSetDefault(int id) =>
      '/api/user/addresses/$id/set-default';

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
