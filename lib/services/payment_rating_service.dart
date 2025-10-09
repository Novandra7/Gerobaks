import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Payment Model untuk API response
class Payment {
  final int id;
  final int orderId;
  final int userId;
  final double amount;
  final String method;
  final String status;
  final String? reference;
  final String? gatewayResponse;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.reference,
    this.gatewayResponse,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toInt() ?? 0,
      orderId: map['order_id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      amount: (map['amount'] ?? 0).toDouble(),
      method: map['method'] ?? '',
      status: map['status'] ?? 'pending',
      reference: map['reference'],
      gatewayResponse: map['gateway_response'],
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'reference': reference,
      'gateway_response': gatewayResponse,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';

  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  
  String get methodDisplayName {
    switch (method.toLowerCase()) {
      case 'credit_card':
        return 'Kartu Kredit';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'e_wallet':
        return 'E-Wallet';
      case 'qris':
        return 'QRIS';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Lunas';
      case 'failed':
        return 'Gagal';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
}

/// Rating Model untuk API response
class Rating {
  final int id;
  final int orderId;
  final int userId;
  final int mitraId;
  final int rating;
  final String? comment;
  final List<String>? tags;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.mitraId,
    required this.rating,
    this.comment,
    this.tags,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id']?.toInt() ?? 0,
      orderId: map['order_id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      mitraId: map['mitra_id']?.toInt() ?? 0,
      rating: map['rating']?.toInt() ?? 0,
      comment: map['comment'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'mitra_id': mitraId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isExcellent => rating >= 5;
  bool get isGood => rating >= 4;
  bool get isAverage => rating >= 3;
  bool get isPoor => rating < 3;

  String get ratingText {
    switch (rating) {
      case 5:
        return 'Sangat Baik';
      case 4:
        return 'Baik';
      case 3:
        return 'Cukup';
      case 2:
        return 'Kurang';
      case 1:
        return 'Sangat Kurang';
      default:
        return 'Tidak Ada Rating';
    }
  }

  String get starDisplay => '★' * rating + '☆' * (5 - rating);
}

/// Service untuk mengelola pembayaran dan rating
class PaymentRatingService {
  PaymentRatingService._internal();
  static final PaymentRatingService _instance = PaymentRatingService._internal();
  factory PaymentRatingService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  // ==================== PAYMENT METHODS ====================

  /// Get list of payments with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 10)
  /// [status] - filter berdasarkan status
  /// [method] - filter berdasarkan metode pembayaran
  Future<Map<String, dynamic>> getPayments({
    int page = 1,
    int limit = 10,
    String? status,
    String? method,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (method != null) 'method': method,
      };

      final response = await _api.getJson(ApiRoutes.payments, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'payments': (data['data'] as List).map((item) => Payment.fromMap(item)).toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          }
        };
      }

      throw Exception('Failed to load payments');
    } catch (e) {
      print('❌ Failed to get payments: $e');
      rethrow;
    }
  }

  /// Get single payment by ID
  Future<Payment> getPayment(int id) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final response = await _api.get(ApiRoutes.payment(id));
      
      if (response != null && response['success'] == true) {
        return Payment.fromMap(response['data']);
      }

      throw Exception('Payment not found');
    } catch (e) {
      print('❌ Failed to get payment $id: $e');
      rethrow;
    }
  }

  /// Create new payment entry
  Future<Payment> createPayment({
    required int orderId,
    required double amount,
    required String method,
    String? reference,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final requestData = {
        'order_id': orderId,
        'amount': amount,
        'method': method,
        if (reference != null) 'reference': reference,
      };

      final response = await _api.postJson(ApiRoutes.payments, requestData);
      
      if (response != null && response['success'] == true) {
        return Payment.fromMap(response['data']);
      }

      throw Exception('Failed to create payment');
    } catch (e) {
      print('❌ Failed to create payment: $e');
      rethrow;
    }
  }

  /// Update payment status or reference
  Future<Payment> updatePayment(int id, {
    String? status,
    String? reference,
    String? gatewayResponse,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final requestData = <String, dynamic>{};
      if (status != null) requestData['status'] = status;
      if (reference != null) requestData['reference'] = reference;
      if (gatewayResponse != null) requestData['gateway_response'] = gatewayResponse;

      final response = await _api.patchJson(ApiRoutes.payment(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Payment.fromMap(response['data']);
      }

      throw Exception('Failed to update payment');
    } catch (e) {
      print('❌ Failed to update payment $id: $e');
      rethrow;
    }
  }

  /// Mark payment as paid
  Future<Payment> markPaymentAsPaid(int id) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final response = await _api.postJson(ApiRoutes.paymentMarkPaid(id), {});
      
      if (response != null && response['success'] == true) {
        return Payment.fromMap(response['data']);
      }

      throw Exception('Failed to mark payment as paid');
    } catch (e) {
      print('❌ Failed to mark payment $id as paid: $e');
      rethrow;
    }
  }

  /// Get payment methods
  List<String> getPaymentMethods() {
    return [
      'credit_card',
      'bank_transfer',
      'e_wallet',
      'qris',
      'cash',
    ];
  }

  /// Get payment status options
  List<String> getPaymentStatusOptions() {
    return ['pending', 'paid', 'failed', 'refunded'];
  }

  // ==================== RATING METHODS ====================

  /// Get list of ratings with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 10)
  /// [mitraId] - filter berdasarkan mitra ID
  /// [rating] - filter berdasarkan rating (1-5)
  Future<Map<String, dynamic>> getRatings({
    int page = 1,
    int limit = 10,
    int? mitraId,
    int? rating,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (mitraId != null) 'mitra_id': mitraId,
        if (rating != null) 'rating': rating,
      };

      final response = await _api.getJson(ApiRoutes.ratings, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'ratings': (data['data'] as List).map((item) => Rating.fromMap(item)).toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          }
        };
      }

      throw Exception('Failed to load ratings');
    } catch (e) {
      print('❌ Failed to get ratings: $e');
      rethrow;
    }
  }

  /// Create rating for completed order (requires end_user role)
  Future<Rating> createRating({
    required int orderId,
    required int mitraId,
    required int rating,
    String? comment,
    List<String>? tags,
  }) async {
    try {
      _authManager.requireRole('end_user'); // Only end_user can create ratings

      final requestData = {
        'order_id': orderId,
        'mitra_id': mitraId,
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (tags != null) 'tags': tags,
      };

      final response = await _api.postJson(ApiRoutes.ratings, requestData);
      
      if (response != null && response['success'] == true) {
        return Rating.fromMap(response['data']);
      }

      throw Exception('Failed to create rating');
    } catch (e) {
      print('❌ Failed to create rating: $e');
      rethrow;
    }
  }

  /// Get ratings for specific mitra
  Future<List<Rating>> getMitraRatings(int mitraId, {int limit = 20}) async {
    try {
      final result = await getRatings(mitraId: mitraId, limit: limit);
      return result['ratings'] as List<Rating>;
    } catch (e) {
      print('❌ Failed to get mitra ratings: $e');
      rethrow;
    }
  }

  /// Get my ratings (ratings I gave)
  Future<List<Rating>> getMyRatings() async {
    try {
      _authManager.requireAuth();

      final result = await getRatings(limit: 50);
      final allRatings = result['ratings'] as List<Rating>;
      
      // Filter ratings by current user
      return allRatings.where((rating) => 
        rating.userId == _authManager.userId
      ).toList();
    } catch (e) {
      print('❌ Failed to get my ratings: $e');
      rethrow;
    }
  }

  /// Calculate average rating for mitra
  Future<Map<String, dynamic>> getMitraRatingStats(int mitraId) async {
    try {
      final ratings = await getMitraRatings(mitraId, limit: 100);
      
      if (ratings.isEmpty) {
        return {
          'average': 0.0,
          'total': 0,
          'distribution': [0, 0, 0, 0, 0], // 1-star to 5-star counts
        };
      }

      final total = ratings.length;
      final sum = ratings.fold<int>(0, (sum, rating) => sum + rating.rating);
      final average = sum / total;

      // Calculate rating distribution
      final distribution = List.filled(5, 0);
      for (final rating in ratings) {
        if (rating.rating >= 1 && rating.rating <= 5) {
          distribution[rating.rating - 1]++;
        }
      }

      return {
        'average': average,
        'total': total,
        'distribution': distribution,
        'recent_ratings': ratings.take(5).toList(),
      };
    } catch (e) {
      print('❌ Failed to get mitra rating stats: $e');
      return {
        'average': 0.0,
        'total': 0,
        'distribution': [0, 0, 0, 0, 0],
      };
    }
  }

  /// Get rating tags suggestions
  List<String> getRatingTags() {
    return [
      'Tepat Waktu',
      'Ramah',
      'Profesional',
      'Bersih',
      'Komunikatif',
      'Efisien',
      'Hati-hati',
      'Dapat Dipercaya',
      'Murah',
      'Berkualitas',
    ];
  }

  /// Check if user can create rating
  bool canCreateRating() {
    return _authManager.isAuthenticated && _authManager.isEndUser;
  }

  /// Check if user can view ratings
  bool canViewRatings() {
    return _authManager.isAuthenticated; // All authenticated users can view ratings
  }

  /// Check if order can be rated
  Future<bool> canRateOrder(int orderId) async {
    // This would typically check if:
    // 1. Order is completed
    // 2. User hasn't rated this order yet
    // 3. Rating window is still open
    
    try {
      _authManager.requireAuth();
      
      // For now, assume order can be rated if user is authenticated and is end_user
      return _authManager.isEndUser;
    } catch (e) {
      return false;
    }
  }

  /// Get payment history for current user
  Future<List<Payment>> getMyPayments() async {
    try {
      final result = await getPayments(limit: 50);
      return result['payments'] as List<Payment>;
    } catch (e) {
      print('❌ Failed to get my payments: $e');
      rethrow;
    }
  }

  /// Get pending payments
  Future<List<Payment>> getPendingPayments() async {
    try {
      final result = await getPayments(status: 'pending', limit: 20);
      return result['payments'] as List<Payment>;
    } catch (e) {
      print('❌ Failed to get pending payments: $e');
      rethrow;
    }
  }
}