// Definisi rute API untuk Gerobaks
// Memisahkan endpoint API ke dalam satu file untuk kemudahan pengelolaan
// dan konsistensi di seluruh aplikasi

class ApiRoutes {
  // Authentication Routes
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';

  // Dashboard Routes
  static const String dashboard = '/api/dashboard';

  // Schedule Routes
  static const String schedules = '/api/schedules';
  static String schedule(int id) => '/api/schedules/$id';

  // Tracking Routes
  static const String trackings = '/api/trackings';
  static String tracking(int id) => '/api/trackings/$id';

  // Order Routes
  static const String orders = '/api/orders';
  static String order(int id) => '/api/orders/$id';

  // Payment Routes
  static const String payments = '/api/payments';
  static String payment(int id) => '/api/payments/$id';

  // Service Routes
  static const String services = '/api/services';
  static String service(int id) => '/api/services/$id';

  // Rating Routes
  static const String ratings = '/api/ratings';
  static String rating(int id) => '/api/ratings/$id';

  // Notification Routes
  static const String notifications = '/api/notifications';
  static String notification(int id) => '/api/notifications/$id';

  // Chat Routes
  static const String chats = '/api/chats';
  static String chat(int id) => '/api/chats/$id';

  // Balance Routes
  static const String balance = '/api/balance';
  static const String balanceTransactions = '/api/balance/transactions';
  static const String balanceSummary = '/api/balance/summary';
}
