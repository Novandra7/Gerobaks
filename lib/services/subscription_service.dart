import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/subscription_model.dart';
import '../services/local_storage_service.dart';
import '../services/user_service.dart';
import '../utils/api_routes.dart';
import 'package:logger/logger.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final Logger _logger = Logger();
  final StreamController<UserSubscription?> _subscriptionController =
      StreamController<UserSubscription?>.broadcast();

  Stream<UserSubscription?> get subscriptionStream =>
      _subscriptionController.stream;

  UserSubscription? _currentSubscription;
  late LocalStorageService _localStorage;

  Future<void> initialize() async {
    _localStorage = await LocalStorageService.getInstance();
    await _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final subscriptionData = await _localStorage.getSubscription();
    _logger.d('LocalStorage subscription data = $subscriptionData');

    if (subscriptionData != null) {
      _currentSubscription = UserSubscription.fromJson(subscriptionData);
      _subscriptionController.add(_currentSubscription);
      _logger.d('Loaded subscription = $_currentSubscription');

      // Sync subscription status with user model
      await _syncUserSubscriptionStatus();
    } else {
      _logger.d('No subscription data found in localStorage');
      _currentSubscription = null;
      _subscriptionController.add(null);

      // Sync subscription status with user model (set as not subscribed)
      await _syncUserSubscriptionStatus();
    }
  }

  // Sync subscription status with user model
  Future<void> _syncUserSubscriptionStatus() async {
    try {
      final userService = await UserService.getInstance();
      await userService.init();
      final currentUser = await userService.getCurrentUser();

      if (currentUser != null) {
        final bool isActive = _currentSubscription?.isActive ?? false;
        final String? subscriptionType = isActive
            ? _currentSubscription?.planId.split('_').first
            : null;

        // Only update if there's a mismatch
        if (currentUser.isSubscribed != isActive ||
            (isActive && subscriptionType != currentUser.subscriptionType)) {
          final updatedUser = currentUser.copyWith(
            isSubscribed: isActive,
            subscriptionType: subscriptionType,
          );

          await userService.updateUserData(updatedUser);
          _logger.d(
            'Synced user subscription status: isSubscribed=$isActive, type=$subscriptionType',
          );
        }
      }
    } catch (e) {
      _logger.e('Error syncing subscription status with user model: $e');
    }
  }

  // Get available subscription plans from API
  Future<List<SubscriptionPlan>> getAvailablePlansFromAPI() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.subscriptionPlans}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> plansData = data['data'] ?? [];

        return plansData
            .map((planData) => SubscriptionPlan.fromApiJson(planData))
            .toList();
      } else {
        _logger.e('Failed to fetch subscription plans: ${response.statusCode}');
        throw Exception('Failed to fetch subscription plans');
      }
    } catch (e) {
      _logger.e('Error fetching subscription plans from API: $e');
      // Fallback to local plans
      return getAvailablePlans();
    }
  }

  // Get current subscription from API
  Future<UserSubscription?> getCurrentSubscriptionFromAPI() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.currentSubscription}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] != null) {
          final subscription = UserSubscription.fromApiJson(data['data']);

          // Update local storage
          await _localStorage.saveSubscription(subscription.toJson());
          _currentSubscription = subscription;
          _subscriptionController.add(_currentSubscription);

          return subscription;
        }
      } else if (response.statusCode == 404) {
        // No active subscription
        _currentSubscription = null;
        _subscriptionController.add(null);
        await _localStorage.clearSubscription();
        return null;
      } else {
        _logger.e(
          'Failed to fetch current subscription: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Error fetching current subscription from API: $e');
    }

    return _currentSubscription;
  }

  // Subscribe to a plan via API
  Future<UserSubscription> subscribeToAPI(
    String planId,
    String paymentMethodId,
  ) async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final requestBody = {
        'subscription_plan_id': planId,
        'payment_method': paymentMethodId,
        'auto_renew': true,
      };

      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.subscribe}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final subscription = UserSubscription.fromApiJson(data['data']);

        // Update local storage
        await _localStorage.saveSubscription(subscription.toJson());
        _currentSubscription = subscription;
        _subscriptionController.add(_currentSubscription);

        // Sync with user model
        await _syncUserSubscriptionStatus();

        _logger.d('Successfully subscribed to plan via API');
        return subscription;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Subscription failed';
        _logger.e(
          'Failed to subscribe: ${response.statusCode} - $errorMessage',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Error subscribing via API: $e');
      throw Exception('Failed to subscribe: $e');
    }
  }

  // Cancel subscription via API
  Future<bool> cancelSubscriptionAPI() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null || _currentSubscription == null) {
        throw Exception('User not authenticated or no active subscription');
      }

      final response = await http.post(
        Uri.parse(
          '${ApiRoutes.baseUrl}${ApiRoutes.cancelSubscription.replaceAll('{subscription}', _currentSubscription!.id)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'cancellation_reason': 'User requested cancellation',
        }),
      );

      if (response.statusCode == 200) {
        // Update local subscription status
        if (_currentSubscription != null) {
          final updatedSubscription = _currentSubscription!.copyWith(
            status: PaymentStatus.cancelled,
          );
          await _localStorage.saveSubscription(updatedSubscription.toJson());
          _currentSubscription = updatedSubscription;
          _subscriptionController.add(_currentSubscription);

          // Sync with user model
          await _syncUserSubscriptionStatus();
        }

        _logger.d('Successfully cancelled subscription via API');
        return true;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Cancellation failed';
        _logger.e(
          'Failed to cancel subscription: ${response.statusCode} - $errorMessage',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Error cancelling subscription via API: $e');
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Get subscription history from API
  Future<List<UserSubscription>> getSubscriptionHistoryFromAPI() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.subscriptionHistory}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> historyData = data['data'] ?? [];

        return historyData
            .map(
              (subscriptionData) =>
                  UserSubscription.fromApiJson(subscriptionData),
            )
            .toList();
      } else {
        _logger.e(
          'Failed to fetch subscription history: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching subscription history from API: $e');
      return getSubscriptionHistory(); // Fallback to local history
    }
  }

  // Get available subscription plans
  List<SubscriptionPlan> getAvailablePlans() {
    return [
      SubscriptionPlan(
        id: 'basic_monthly',
        name: 'Paket Basic',
        description: 'Cocok untuk kebutuhan rumah tangga',
        price: 50000,
        durationInDays: 30,
        type: SubscriptionType.basic,
        features: [
          'Pengangkutan sampah 2x seminggu',
          'Notifikasi jadwal pengangkutan',
          'Customer support via chat',
          'Laporan bulanan',
        ],
      ),
      SubscriptionPlan(
        id: 'premium_monthly',
        name: 'Paket Premium',
        description: 'Paket terpopuler dengan layanan lengkap',
        price: 75000,
        durationInDays: 30,
        type: SubscriptionType.premium,
        isPopular: true,
        features: [
          'Pengangkutan sampah 3x seminggu',
          'Notifikasi real-time',
          'Priority customer support',
          'Laporan detail harian',
          'Recycling reward points',
          'Eco-friendly tips',
        ],
      ),
      SubscriptionPlan(
        id: 'pro_monthly',
        name: 'Paket Pro',
        description: 'Untuk kebutuhan bisnis dan komunitas',
        price: 120000,
        durationInDays: 30,
        type: SubscriptionType.pro,
        features: [
          'Pengangkutan sampah harian',
          'Real-time tracking',
          'Dedicated customer support',
          'Analytics dashboard',
          'Priority scheduling',
          'Bulk waste management',
          'Custom pickup time',
          'Business reports',
        ],
      ),
    ];
  }

  // Get available payment methods
  List<PaymentMethod> getPaymentMethods() {
    return [
      // E-Wallet Methods
      PaymentMethod(
        id: 'qris',
        name: 'QRIS',
        icon: 'assets/ic_qris.png',
        description: 'Scan QR Code untuk pembayaran instant',
        category: 'E-Wallet',
      ),
      PaymentMethod(
        id: 'shopeepay',
        name: 'ShopeePay',
        icon: 'assets/ic_shopeepay.png',
        description: 'Bayar dengan ShopeePay',
        category: 'E-Wallet',
      ),
      PaymentMethod(
        id: 'dana',
        name: 'DANA',
        icon: 'assets/ic_dana.png',
        description: 'Bayar dengan DANA',
        category: 'E-Wallet',
      ),
      PaymentMethod(
        id: 'gopay',
        name: 'GoPay',
        icon: 'assets/ic_gopay.png',
        description: 'Bayar dengan GoPay',
        category: 'E-Wallet',
      ),
      PaymentMethod(
        id: 'ovo',
        name: 'OVO',
        icon: 'assets/ic_ovo.png',
        description: 'Bayar dengan OVO',
        category: 'E-Wallet',
      ),
      // Bank Transfer Methods
      PaymentMethod(
        id: 'bca',
        name: 'BCA Virtual Account',
        icon: 'assets/img_bank_bca.png',
        description: 'Transfer melalui BCA Virtual Account',
        category: 'Bank Transfer',
      ),
      PaymentMethod(
        id: 'mandiri',
        name: 'Mandiri Virtual Account',
        icon: 'assets/img_bank_mandiri.png',
        description: 'Transfer melalui Mandiri Virtual Account',
        category: 'Bank Transfer',
      ),
      PaymentMethod(
        id: 'bni',
        name: 'BNI Virtual Account',
        icon: 'assets/img_bank_bni.png',
        description: 'Transfer melalui BNI Virtual Account',
        category: 'Bank Transfer',
      ),
      PaymentMethod(
        id: 'ocbc',
        name: 'OCBC Virtual Account',
        icon: 'assets/img_bank_ocbc.png',
        description: 'Transfer melalui OCBC Virtual Account',
        category: 'Bank Transfer',
      ),
    ];
  }

  // Process subscription payment
  Future<UserSubscription> processPayment(
    SubscriptionPlan plan,
    PaymentMethod paymentMethod,
  ) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final subscription = UserSubscription(
      id: _generateId(),
      planId: plan.id,
      planName: plan.name,
      startDate: now,
      endDate: now.add(Duration(days: plan.durationInDays)),
      status:
          PaymentStatus.success, // In real app, this would be pending initially
      amount: plan.price,
      paymentMethod: paymentMethod.name,
      transactionId: _generateTransactionId(),
    );

    // Save to local storage
    await _localStorage.saveSubscription(subscription.toJson());

    _currentSubscription = subscription;
    _subscriptionController.add(_currentSubscription);

    // Update user model with subscription information
    try {
      final userService = await UserService.getInstance();
      await userService.init();
      final currentUser = await userService.getCurrentUser();

      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          isSubscribed: true,
          subscriptionType: plan.type.toString().split('.').last,
        );

        await userService.updateUserData(updatedUser);
      }
    } catch (e) {
      _logger.e('Error updating user subscription status: $e');
    }

    return subscription;
  }

  // Get current subscription
  UserSubscription? getCurrentSubscription() {
    return _currentSubscription;
  }

  // Clear subscription (for testing)
  Future<void> clearSubscription() async {
    await _localStorage.clearSubscription();
    _currentSubscription = null;
    _subscriptionController.add(null);
    _logger.d('Subscription cleared');
  }

  // Check if user has active subscription
  bool hasActiveSubscription() {
    bool isActive = _currentSubscription?.isActive ?? false;

    // Ensure user model subscription status is in sync with actual subscription
    Future.microtask(() async {
      try {
        final userService = await UserService.getInstance();
        await userService.init();
        final currentUser = await userService.getCurrentUser();

        if (currentUser != null) {
          // Only update if there's a mismatch
          if (currentUser.isSubscribed != isActive ||
              (isActive &&
                  _currentSubscription != null &&
                  currentUser.subscriptionType !=
                      _currentSubscription!.planId.split('_').first)) {
            final updatedUser = currentUser.copyWith(
              isSubscribed: isActive,
              subscriptionType: isActive
                  ? _currentSubscription?.planId.split('_').first
                  : null,
            );

            await userService.updateUserData(updatedUser);
          }
        }
      } catch (e) {
        _logger.e('Error syncing subscription status with user model: $e');
      }
    });

    return isActive;
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    if (_currentSubscription != null) {
      final cancelledSubscription = UserSubscription(
        id: _currentSubscription!.id,
        planId: _currentSubscription!.planId,
        planName: _currentSubscription!.planName,
        startDate: _currentSubscription!.startDate,
        endDate: DateTime.now(), // End now
        status: PaymentStatus.expired,
        amount: _currentSubscription!.amount,
        paymentMethod: _currentSubscription!.paymentMethod,
        transactionId: _currentSubscription!.transactionId,
      );

      await _localStorage.saveSubscription(cancelledSubscription.toJson());
      _currentSubscription = cancelledSubscription;
      _subscriptionController.add(_currentSubscription);

      // Update user subscription status
      try {
        final userService = await UserService.getInstance();
        await userService.init();
        final currentUser = await userService.getCurrentUser();

        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            isSubscribed: false,
            subscriptionType: null,
          );

          await userService.updateUserData(updatedUser);
        }
      } catch (e) {
        _logger.e('Error updating user subscription status: $e');
      }
    }
  }

  // Extend subscription
  Future<UserSubscription> extendSubscription(SubscriptionPlan plan) async {
    if (_currentSubscription != null) {
      final startDate = _currentSubscription!.isActive
          ? _currentSubscription!.endDate
          : DateTime.now();

      final newSubscription = UserSubscription(
        id: _generateId(),
        planId: plan.id,
        planName: plan.name,
        startDate: startDate,
        endDate: startDate.add(Duration(days: plan.durationInDays)),
        status: PaymentStatus.success,
        amount: plan.price,
        transactionId: _generateTransactionId(),
      );

      await _localStorage.saveSubscription(newSubscription.toJson());
      _currentSubscription = newSubscription;
      _subscriptionController.add(_currentSubscription);

      // Update user model with subscription information
      try {
        final userService = await UserService.getInstance();
        await userService.init();
        final currentUser = await userService.getCurrentUser();

        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            isSubscribed: true,
            subscriptionType: plan.type.toString().split('.').last,
          );

          await userService.updateUserData(updatedUser);
        }
      } catch (e) {
        _logger.e('Error updating user subscription status: $e');
      }

      return newSubscription;
    }

    throw Exception('No existing subscription to extend');
  }

  // Get subscription history (for now, just return current if exists)
  List<UserSubscription> getSubscriptionHistory() {
    return _currentSubscription != null ? [_currentSubscription!] : [];
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _generateTransactionId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return 'TRX${List.generate(8, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  void dispose() {
    _subscriptionController.close();
  }
}
