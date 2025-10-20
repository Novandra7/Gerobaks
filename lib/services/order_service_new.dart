import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Order Model untuk API response
class Order {
  final int id;
  final int userId;
  final int serviceId;
  final String serviceName;
  final String? description;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime scheduledDate;
  final String timeSlot;
  final String status;
  final double totalAmount;
  final int? assignedMitraId;
  final String? assignedMitraName;
  final String? notes;
  final String? paymentStatus;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    required this.totalAmount,
    this.assignedMitraId,
    this.assignedMitraName,
    this.notes,
    this.paymentStatus,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      serviceId: map['service_id']?.toInt() ?? 0,
      serviceName: map['service_name'] ?? map['service']?['name'] ?? '',
      description: map['description'],
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      scheduledDate: DateTime.parse(map['scheduled_date'] ?? DateTime.now().toIso8601String()),
      timeSlot: map['time_slot'] ?? '',
      status: map['status'] ?? 'pending',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      assignedMitraId: map['assigned_mitra_id']?.toInt(),
      assignedMitraName: map['assigned_mitra_name'] ?? map['assigned_mitra']?['name'],
      notes: map['notes'],
      paymentStatus: map['payment_status'] ?? 'pending',
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'service_name': serviceName,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduled_date': scheduledDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': status,
      'total_amount': totalAmount,
      'assigned_mitra_id': assignedMitraId,
      'assigned_mitra_name': assignedMitraName,
      'notes': notes,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';
  bool get isPaymentRefunded => paymentStatus == 'refunded';
}

/// Service untuk mengelola order penjemputan sampah
class OrderService {
  OrderService._internal();
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get list of orders with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 10)
  /// [status] - filter berdasarkan status
  /// [paymentStatus] - filter berdasarkan status pembayaran
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (paymentStatus != null) 'payment_status': paymentStatus,
      };

      final response = await _api.getJson(ApiRoutes.orders, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'orders': (data['data'] as List).map((item) => Order.fromMap(item)).toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          }
        };
      }

      throw Exception('Failed to load orders');
    } catch (e) {
      print('❌ Failed to get orders: $e');
      rethrow;
    }
  }

  /// Get single order by ID
  Future<Order> getOrder(int id) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final response = await _api.get(ApiRoutes.order(id));
      
      if (response != null && response['success'] == true) {
        return Order.fromMap(response['data']);
      }

      throw Exception('Order not found');
    } catch (e) {
      print('❌ Failed to get order $id: $e');
      rethrow;
    }
  }

  /// Create new order (requires end_user role)
  Future<Order> createOrder({
    required int serviceId,
    String? description,
    required String address,
    double? latitude,
    double? longitude,
    required DateTime scheduledDate,
    required String timeSlot,
    String? notes,
    String? paymentMethod,
  }) async {
    try {
      _authManager.requireRole('end_user'); // Only end_user can create orders

      final requestData = {
        'service_id': serviceId,
        if (description != null) 'description': description,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'scheduled_date': scheduledDate.toIso8601String(),
        'time_slot': timeSlot,
        if (notes != null) 'notes': notes,
        if (paymentMethod != null) 'payment_method': paymentMethod,
      };

      final response = await _api.postJson(ApiRoutes.orders, requestData);
      
      if (response != null && response['success'] == true) {
        return Order.fromMap(response['data']);
      }

      throw Exception('Failed to create order');
    } catch (e) {
      print('❌ Failed to create order: $e');
      rethrow;
    }
  }

  /// Cancel order (requires end_user role and order must be pending)
  Future<Order> cancelOrder(int id, {String? reason}) async {
    try {
      _authManager.requireRole('end_user'); // Only end_user can cancel

      final requestData = <String, dynamic>{};
      if (reason != null) requestData['reason'] = reason;

      final response = await _api.postJson(ApiRoutes.orderCancel(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Order.fromMap(response['data']);
      }

      throw Exception('Failed to cancel order');
    } catch (e) {
      print('❌ Failed to cancel order $id: $e');
      rethrow;
    }
  }

  /// Assign mitra to order (requires mitra role)
  Future<Order> assignOrder(int id, {int? mitraId}) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can assign

      final requestData = <String, dynamic>{};
      if (mitraId != null) {
        requestData['mitra_id'] = mitraId;
      } else {
        // Self-assign if no mitra_id provided
        requestData['mitra_id'] = _authManager.userId;
      }

      final response = await _api.patchJson(ApiRoutes.orderAssign(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Order.fromMap(response['data']);
      }

      throw Exception('Failed to assign order');
    } catch (e) {
      print('❌ Failed to assign order $id: $e');
      rethrow;
    }
  }

  /// Update order status (requires mitra or admin role)
  Future<Order> updateOrderStatus(int id, String status, {String? notes}) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra/admin can update status

      final requestData = {
        'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.patchJson(ApiRoutes.orderStatus(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Order.fromMap(response['data']);
      }

      throw Exception('Failed to update order status');
    } catch (e) {
      print('❌ Failed to update order $id status: $e');
      rethrow;
    }
  }

  /// Get orders for current user (filtered based on role)
  Future<List<Order>> getMyOrders() async {
    try {
      _authManager.requireAuth();

      final result = await getOrders(limit: 100); // Get more orders for user
      return result['orders'] as List<Order>;
    } catch (e) {
      print('❌ Failed to get my orders: $e');
      rethrow;
    }
  }

  /// Get pending orders for mitra to assign
  Future<List<Order>> getPendingOrders() async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can see pending orders

      final result = await getOrders(status: 'pending', limit: 50);
      return result['orders'] as List<Order>;
    } catch (e) {
      print('❌ Failed to get pending orders: $e');
      rethrow;
    }
  }

  /// Get assigned orders for current mitra
  Future<List<Order>> getAssignedOrders() async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can see assigned orders

      final result = await getOrders(status: 'assigned', limit: 50);
      final allOrders = result['orders'] as List<Order>;
      
      // Filter orders assigned to current mitra
      return allOrders.where((order) => 
        order.assignedMitraId == _authManager.userId
      ).toList();
    } catch (e) {
      print('❌ Failed to get assigned orders: $e');
      rethrow;
    }
  }

  /// Get completed orders for current user
  Future<List<Order>> getCompletedOrders() async {
    try {
      _authManager.requireAuth();

      final result = await getOrders(status: 'completed', limit: 50);
      return result['orders'] as List<Order>;
    } catch (e) {
      print('❌ Failed to get completed orders: $e');
      rethrow;
    }
  }

  /// Get order status options
  List<String> getStatusOptions() {
    return ['pending', 'assigned', 'in_progress', 'completed', 'cancelled'];
  }

  /// Get payment status options
  List<String> getPaymentStatusOptions() {
    return ['pending', 'paid', 'refunded'];
  }

  /// Get available time slots for orders
  List<String> getAvailableTimeSlots() {
    return [
      '06:00-08:00',
      '08:00-10:00',
      '10:00-12:00',
      '12:00-14:00',
      '14:00-16:00',
      '16:00-18:00',
    ];
  }

  /// Check if user can create order
  bool canCreateOrder() {
    return _authManager.isAuthenticated && _authManager.isEndUser;
  }

  /// Check if user can assign order
  bool canAssignOrder() {
    return _authManager.isAuthenticated && _authManager.isMitra;
  }

  /// Check if user can update order status
  bool canUpdateOrderStatus() {
    return _authManager.isAuthenticated && 
           (_authManager.isMitra || _authManager.isAdmin);
  }

  /// Check if order can be cancelled
  bool canCancelOrder(Order order) {
    return _authManager.isAuthenticated && 
           _authManager.isEndUser &&
           order.userId == _authManager.userId &&
           (order.isPending || order.isAssigned);
  }

  /// Calculate estimated price based on service and area
  Future<double> calculateEstimatedPrice({
    required int serviceId,
    String? area,
    double? distance,
  }) async {
    // This would typically call an API endpoint for price calculation
    // For now, return a mock calculation
    
    const basePrice = 25000.0; // Base price in IDR
    double multiplier = 1.0;
    
    // Area-based pricing
    if (area != null) {
      switch (area.toLowerCase()) {
        case 'jakarta':
          multiplier = 1.2;
          break;
        case 'bandung':
          multiplier = 1.1;
          break;
        case 'surabaya':
          multiplier = 1.15;
          break;
        default:
          multiplier = 1.0;
      }
    }
    
    // Distance-based pricing
    if (distance != null && distance > 5.0) {
      multiplier += (distance - 5.0) * 0.1; // 10% per km beyond 5km
    }
    
    return basePrice * multiplier;
  }
}