import 'dart:convert';

enum SubscriptionType { basic, premium, pro }

enum PaymentStatus { pending, success, failed, expired, cancelled }

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationInDays;
  final SubscriptionType type;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInDays,
    required this.type,
    required this.features,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      durationInDays: json['durationInDays'],
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == 'SubscriptionType.${json['type']}',
        orElse: () => SubscriptionType.basic,
      ),
      features: List<String>.from(json['features']),
      isPopular: json['isPopular'] ?? false,
    );
  }

  // Factory constructor for API JSON response
  factory SubscriptionPlan.fromApiJson(Map<String, dynamic> json) {
    // Map API response to local model
    List<String> features = [];
    if (json['features'] != null) {
      if (json['features'] is String) {
        // If features is a JSON string, decode it
        final featuresJson = json['features'];
        if (featuresJson.isNotEmpty) {
          final List<dynamic> featuresList = List<dynamic>.from(
            jsonDecode(featuresJson) ?? [],
          );
          features = featuresList.map((f) => f.toString()).toList();
        }
      } else if (json['features'] is List) {
        features = List<String>.from(json['features']);
      }
    }

    // Map billing cycle to duration in days
    int durationInDays = 30; // default monthly
    if (json['billing_cycle'] == 'yearly') {
      durationInDays = 365;
    }

    // Determine subscription type based on plan name or features
    SubscriptionType type = SubscriptionType.basic;
    final planName = json['name']?.toString().toLowerCase() ?? '';
    if (planName.contains('premium') || planName.contains('professional')) {
      type = SubscriptionType.premium;
    } else if (planName.contains('enterprise') || planName.contains('pro')) {
      type = SubscriptionType.pro;
    }

    return SubscriptionPlan(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      durationInDays: durationInDays,
      type: type,
      features: features,
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationInDays': durationInDays,
      'type': type.toString().split('.').last,
      'features': features,
      'isPopular': isPopular,
    };
  }

  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get durationText =>
      durationInDays == 30 ? '1 Bulan' : '$durationInDays Hari';
}

class UserSubscription {
  final String id;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final PaymentStatus status;
  final double amount;
  final String? paymentMethod;
  final String? transactionId;

  UserSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amount,
    this.paymentMethod,
    this.transactionId,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      planId: json['planId'],
      planName: json['planName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      amount: json['amount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
    );
  }

  // Factory constructor for API JSON response
  factory UserSubscription.fromApiJson(Map<String, dynamic> json) {
    // Map API response to local model
    PaymentStatus status = PaymentStatus.pending;
    final statusStr = json['status']?.toString().toLowerCase() ?? 'pending';

    switch (statusStr) {
      case 'active':
        status = PaymentStatus.success;
        break;
      case 'expired':
        status = PaymentStatus.expired;
        break;
      case 'cancelled':
        status = PaymentStatus.cancelled;
        break;
      case 'failed':
        status = PaymentStatus.failed;
        break;
      default:
        status = PaymentStatus.pending;
    }

    return UserSubscription(
      id: json['id'].toString(),
      planId: json['subscription_plan_id'].toString(),
      planName: json['plan']?['name'] ?? 'Unknown Plan',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: status,
      amount: double.parse(json['amount_paid'].toString()),
      paymentMethod: json['payment_method'],
      transactionId: json['payment_reference'],
    );
  }

  // CopyWith method for updating subscription
  UserSubscription copyWith({
    String? id,
    String? planId,
    String? planName,
    DateTime? startDate,
    DateTime? endDate,
    PaymentStatus? status,
    double? amount,
    String? paymentMethod,
    String? transactionId,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'planName': planName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  bool get isActive =>
      DateTime.now().isBefore(endDate) && status == PaymentStatus.success;
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining =>
      isActive ? endDate.difference(DateTime.now()).inDays : 0;

  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Menunggu Pembayaran';
      case PaymentStatus.success:
        return isExpired ? 'Berakhir' : 'Aktif';
      case PaymentStatus.failed:
        return 'Gagal';
      case PaymentStatus.expired:
        return 'Berakhir';
      case PaymentStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String category;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.category = 'Other',
    this.isActive = true,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
      category: json['category'] ?? 'Other',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'category': category,
      'isActive': isActive,
    };
  }
}
