import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/subscription_model.dart';
import '../services/local_storage_service.dart';
import '../services/user_service.dart';
import '../utils/api_routes.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();
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

    if (subscriptionData != null) {
      _currentSubscription = UserSubscription.fromJson(subscriptionData);
      _subscriptionController.add(_currentSubscription);

      await _syncUserSubscriptionStatus();
    } else {
      _currentSubscription = null;
      _subscriptionController.add(null);

      await _syncUserSubscriptionStatus();
    }
  }

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

        if (currentUser.isSubscribed != isActive ||
            (isActive && subscriptionType != currentUser.subscriptionType)) {
          final updatedUser = currentUser.copyWith(
            isSubscribed: isActive,
            subscriptionType: subscriptionType,
          );

          await userService.updateUserData(updatedUser);
        }
      }
    } catch (e) {
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlansFromAPI() async {
    return getAvailablePlans();
  }

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
        _currentSubscription = null;
        _subscriptionController.add(null);
        await _localStorage.clearSubscription();
        return null;
      }
    } catch (e) {
    }

    return _currentSubscription;
  }

  Future<UserSubscription> subscribeToAPI(
    String planId,
    String paymentMethodId, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null) {
        throw Exception('User belum login. Silakan login terlebih dahulu.');
      }

      Map<String, dynamic> requestBody = {
        'subscription_plan_id': planId,
        'payment_method': paymentMethodId,
        'auto_renew': true,
        ...?additionalData,
      };

      final url = '${ApiRoutes.baseUrl}${ApiRoutes.subscribe}';

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout. Silakan coba lagi.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['data'] == null) {
          throw Exception('Response API tidak valid');
        }

        final subscription = UserSubscription.fromApiJson(responseData['data']);

        await _localStorage.saveSubscription(subscription.toJson());
        _currentSubscription = subscription;
        _subscriptionController.add(_currentSubscription);

        await _syncUserSubscriptionStatus();

        return subscription;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Data tidak valid';
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 402) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Pembayaran gagal';
        throw Exception(errorMessage);
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Data tidak valid';
        throw Exception(errorMessage);
      } else if (response.statusCode == 500) {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Terjadi kesalahan pada server';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception(
            'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Subscription failed';
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on FormatException catch (e) {
      throw Exception('Response server tidak valid.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Gagal membuat subscription: ${e.toString()}');
    }
  }

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
        return [];
      }
    } catch (e) {
      return getSubscriptionHistory();
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null) {
        return _getStaticPlans();
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

        if (plansData.isEmpty) {
          return _getStaticPlans();
        }

        return plansData
            .map((planData) => SubscriptionPlan.fromApiJson(planData))
            .toList();
      } else {
        return _getStaticPlans();
      }
    } catch (e) {
      return _getStaticPlans();
    }
  }

  List<SubscriptionPlan> _getStaticPlans() {
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

  List<PaymentMethod> getPaymentMethods() {
    return [
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

  Future<UserSubscription> processPayment(
    SubscriptionPlan plan,
    PaymentMethod paymentMethod,
  ) async {
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final subscription = UserSubscription(
      id: _generateId(),
      planId: plan.id,
      planName: plan.name,
      startDate: now,
      endDate: now.add(Duration(days: plan.durationInDays)),
      status: PaymentStatus.success,
      amount: plan.price,
      paymentMethod: paymentMethod.name,
      transactionId: _generateTransactionId(),
    );

    await _localStorage.saveSubscription(subscription.toJson());

    _currentSubscription = subscription;
    _subscriptionController.add(_currentSubscription);

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
    }

    return subscription;
  }

  UserSubscription? getCurrentSubscription() {
    return _currentSubscription;
  }

  Future<void> clearSubscription() async {
    await _localStorage.clearSubscription();
    _currentSubscription = null;
    _subscriptionController.add(null);
  }

  bool hasActiveSubscription() {
    bool isActive = _currentSubscription?.isActive ?? false;

    Future.microtask(() async {
      try {
        final userService = await UserService.getInstance();
        await userService.init();
        final currentUser = await userService.getCurrentUser();

        if (currentUser != null) {
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
      }
    });

    return isActive;
  }

  Future<void> cancelSubscription() async {
    if (_currentSubscription == null) return;

    try {
      final token = await _localStorage.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.cancelSubscription(_currentSubscription!.id)}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'cancellation_reason': 'User requested cancellation',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {
        String errorMessage = 'Gagal membatalkan langganan';

        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Server error: ${response.statusCode}';
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Gagal membatalkan langganan: ${e.toString()}');
    }

    final cancelledSubscription = _currentSubscription!.copyWith(
      status: PaymentStatus.cancelled,
    );

    await _localStorage.saveSubscription(cancelledSubscription.toJson());
    _currentSubscription = cancelledSubscription;
    _subscriptionController.add(_currentSubscription);

    await _syncUserSubscriptionStatus();
  }

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
      }

      return newSubscription;
    }

    throw Exception('No existing subscription to extend');
  }

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
