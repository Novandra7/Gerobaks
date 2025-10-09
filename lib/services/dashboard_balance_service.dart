import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Dashboard Metrics Model untuk Mitra
class MitraDashboardMetrics {
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int activeSchedules;
  final double totalEarnings;
  final double todayEarnings;
  final double averageRating;
  final int totalReviews;
  final List<Map<String, dynamic>> recentOrders;
  final List<Map<String, dynamic>> weeklyStats;

  MitraDashboardMetrics({
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.activeSchedules,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.averageRating,
    required this.totalReviews,
    required this.recentOrders,
    required this.weeklyStats,
  });

  factory MitraDashboardMetrics.fromMap(Map<String, dynamic> map) {
    return MitraDashboardMetrics(
      totalOrders: map['total_orders']?.toInt() ?? 0,
      completedOrders: map['completed_orders']?.toInt() ?? 0,
      pendingOrders: map['pending_orders']?.toInt() ?? 0,
      activeSchedules: map['active_schedules']?.toInt() ?? 0,
      totalEarnings: (map['total_earnings'] ?? 0).toDouble(),
      todayEarnings: (map['today_earnings'] ?? 0).toDouble(),
      averageRating: (map['average_rating'] ?? 0).toDouble(),
      totalReviews: map['total_reviews']?.toInt() ?? 0,
      recentOrders: List<Map<String, dynamic>>.from(map['recent_orders'] ?? []),
      weeklyStats: List<Map<String, dynamic>>.from(map['weekly_stats'] ?? []),
    );
  }

  double get completionRate => totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;
  String get formattedTotalEarnings => 'Rp ${totalEarnings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedTodayEarnings => 'Rp ${todayEarnings.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

/// Dashboard Metrics Model untuk End User
class UserDashboardMetrics {
  final int totalOrders;
  final int completedOrders;
  final int activeOrders;
  final int points;
  final double totalSpent;
  final double carbonSaved;
  final int scheduledPickups;
  final List<Map<String, dynamic>> recentOrders;
  final List<Map<String, dynamic>> monthlyStats;
  final Map<String, dynamic> subscription;

  UserDashboardMetrics({
    required this.totalOrders,
    required this.completedOrders,
    required this.activeOrders,
    required this.points,
    required this.totalSpent,
    required this.carbonSaved,
    required this.scheduledPickups,
    required this.recentOrders,
    required this.monthlyStats,
    required this.subscription,
  });

  factory UserDashboardMetrics.fromMap(Map<String, dynamic> map) {
    return UserDashboardMetrics(
      totalOrders: map['total_orders']?.toInt() ?? 0,
      completedOrders: map['completed_orders']?.toInt() ?? 0,
      activeOrders: map['active_orders']?.toInt() ?? 0,
      points: map['points']?.toInt() ?? 0,
      totalSpent: (map['total_spent'] ?? 0).toDouble(),
      carbonSaved: (map['carbon_saved'] ?? 0).toDouble(),
      scheduledPickups: map['scheduled_pickups']?.toInt() ?? 0,
      recentOrders: List<Map<String, dynamic>>.from(map['recent_orders'] ?? []),
      monthlyStats: List<Map<String, dynamic>>.from(map['monthly_stats'] ?? []),
      subscription: Map<String, dynamic>.from(map['subscription'] ?? {}),
    );
  }

  String get formattedTotalSpent => 'Rp ${totalSpent.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  bool get hasActiveSubscription => subscription['status'] == 'active';
  String get subscriptionType => subscription['type'] ?? 'none';
}

/// Balance Entry Model
class BalanceEntry {
  final int id;
  final int userId;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final String? reference;
  final DateTime createdAt;

  BalanceEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    this.reference,
    required this.createdAt,
  });

  factory BalanceEntry.fromMap(Map<String, dynamic> map) {
    return BalanceEntry(
      id: map['id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      balanceBefore: (map['balance_before'] ?? 0).toDouble(),
      balanceAfter: (map['balance_after'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      reference: map['reference'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
  String get formattedAmount => 'Rp ${amount.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get displayAmount => '${isCredit ? '+' : '-'}$formattedAmount';
}

/// Balance Summary Model
class BalanceSummary {
  final double currentBalance;
  final double totalCredit;
  final double totalDebit;
  final int totalTransactions;
  final List<BalanceEntry> recentEntries;

  BalanceSummary({
    required this.currentBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.totalTransactions,
    required this.recentEntries,
  });

  factory BalanceSummary.fromMap(Map<String, dynamic> map) {
    return BalanceSummary(
      currentBalance: (map['current_balance'] ?? 0).toDouble(),
      totalCredit: (map['total_credit'] ?? 0).toDouble(),
      totalDebit: (map['total_debit'] ?? 0).toDouble(),
      totalTransactions: map['total_transactions']?.toInt() ?? 0,
      recentEntries: (map['recent_entries'] as List? ?? [])
          .map((item) => BalanceEntry.fromMap(item))
          .toList(),
    );
  }

  String get formattedCurrentBalance => 'Rp ${currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedTotalCredit => 'Rp ${totalCredit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedTotalDebit => 'Rp ${totalDebit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

/// Service untuk mengelola dashboard dan balance
class DashboardBalanceService {
  DashboardBalanceService._internal();
  static final DashboardBalanceService _instance = DashboardBalanceService._internal();
  factory DashboardBalanceService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get dashboard metrics for Mitra
  Future<MitraDashboardMetrics> getMitraDashboard([int? mitraId]) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can access

      final userId = mitraId ?? _authManager.userId;
      final response = await _api.get(ApiRoutes.dashboardMitra(userId));
      
      if (response != null && response['success'] == true) {
        return MitraDashboardMetrics.fromMap(response['data']);
      }

      throw Exception('Failed to load mitra dashboard');
    } catch (e) {
      print('❌ Failed to get mitra dashboard: $e');
      rethrow;
    }
  }

  /// Get dashboard metrics for End User
  Future<UserDashboardMetrics> getUserDashboard([int? userId]) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final targetUserId = userId ?? _authManager.userId;
      final response = await _api.get(ApiRoutes.dashboardUser(targetUserId));
      
      if (response != null && response['success'] == true) {
        return UserDashboardMetrics.fromMap(response['data']);
      }

      throw Exception('Failed to load user dashboard');
    } catch (e) {
      print('❌ Failed to get user dashboard: $e');
      rethrow;
    }
  }

  /// Get balance summary for current user
  Future<BalanceSummary> getBalanceSummary({int? limit}) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        if (limit != null) 'limit': limit,
      };

      final response = await _api.getJson(ApiRoutes.balanceSummary, query: query);
      
      if (response != null && response['success'] == true) {
        return BalanceSummary.fromMap(response['data']);
      }

      throw Exception('Failed to load balance summary');
    } catch (e) {
      print('❌ Failed to get balance summary: $e');
      rethrow;
    }
  }

  /// Get balance ledger with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 20)
  /// [type] - filter berdasarkan tipe transaksi (credit/debit)
  Future<Map<String, dynamic>> getBalanceLedger({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      };

      final response = await _api.getJson(ApiRoutes.balanceLedger, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'entries': (data['data'] as List).map((item) => BalanceEntry.fromMap(item)).toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          },
          'summary': data['summary'] ?? {},
        };
      }

      throw Exception('Failed to load balance ledger');
    } catch (e) {
      print('❌ Failed to get balance ledger: $e');
      rethrow;
    }
  }

  /// Get current balance points
  Future<int> getCurrentPoints() async {
    try {
      final summary = await getBalanceSummary(limit: 1);
      return summary.currentBalance.toInt();
    } catch (e) {
      print('❌ Failed to get current points: $e');
      return 0;
    }
  }

  /// Get recent balance activities
  Future<List<BalanceEntry>> getRecentBalanceActivities({int limit = 10}) async {
    try {
      final result = await getBalanceLedger(limit: limit);
      return result['entries'] as List<BalanceEntry>;
    } catch (e) {
      print('❌ Failed to get recent balance activities: $e');
      return [];
    }
  }

  /// Check if current user can view mitra dashboard
  bool canViewMitraDashboard() {
    return _authManager.isAuthenticated && _authManager.isMitra;
  }

  /// Check if current user can view user dashboard
  bool canViewUserDashboard() {
    return _authManager.isAuthenticated; // All authenticated users can view
  }

  /// Check if current user can view balance
  bool canViewBalance() {
    return _authManager.isAuthenticated; // All authenticated users can view balance
  }

  /// Get dashboard route based on user role
  String getDashboardRoute() {
    if (_authManager.isMitra) {
      return '/mitra-dashboard';
    } else if (_authManager.isAdmin) {
      return '/admin-dashboard';
    } else {
      return '/end-user-home';
    }
  }

  /// Get balance entry types
  List<String> getBalanceEntryTypes() {
    return ['credit', 'debit'];
  }

  /// Stream real-time dashboard updates (polling-based)
  Stream<dynamic> watchDashboard() async* {
    while (_authManager.isAuthenticated) {
      try {
        if (_authManager.isMitra) {
          final metrics = await getMitraDashboard();
          yield metrics;
        } else {
          final metrics = await getUserDashboard();
          yield metrics;
        }
        
        // Update every 2 minutes
        await Future.delayed(const Duration(minutes: 2));
      } catch (e) {
        print('❌ Error in dashboard stream: $e');
        yield null;
        await Future.delayed(const Duration(minutes: 5)); // Longer delay on error
      }
    }
  }

  /// Stream real-time balance updates (polling-based)
  Stream<BalanceSummary> watchBalance() async* {
    while (_authManager.isAuthenticated) {
      try {
        final summary = await getBalanceSummary(limit: 5);
        yield summary;
        
        // Update every 1 minute
        await Future.delayed(const Duration(minutes: 1));
      } catch (e) {
        print('❌ Error in balance stream: $e');
        await Future.delayed(const Duration(minutes: 3)); // Longer delay on error
      }
    }
  }
}