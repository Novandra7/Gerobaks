import 'package:bank_sha/services/api_client.dart';

/// Complete Order Service - Full CRUD for Orders
///
/// Features:
/// - Get all orders (GET /api/orders)
/// - Get order by ID (GET /api/orders/{id})
/// - Create order (POST /api/orders) [ALREADY EXISTS]
/// - Update order (PUT /api/orders/{id}) [NEW]
/// - Delete order (DELETE /api/orders/{id})
/// - Filter by user/mitra/status
/// - Order statistics and tracking
///
/// Use Cases:
/// - Users create waste pickup orders
/// - Users update order details before pickup
/// - Mitra accepts/rejects orders
/// - Admin manages all orders
/// - Real-time order status tracking
class OrderServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // Order statuses
  static const List<String> statuses = [
    'pending',
    'accepted',
    'on_the_way',
    'picked_up',
    'completed',
    'cancelled',
    'rejected',
  ];

  // Waste types
  static const List<String> wasteTypes = [
    'plastic',
    'paper',
    'metal',
    'glass',
    'organic',
    'electronic',
    'mixed',
  ];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Get all orders with filters
  ///
  /// GET /api/orders
  ///
  /// Parameters:
  /// - [userId]: Filter by user ID
  /// - [mitraId]: Filter by mitra ID
  /// - [status]: Filter by status
  /// - [wasteType]: Filter by waste type
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of orders
  ///
  /// Example:
  /// ```dart
  /// // Get all orders
  /// final orders = await orderService.getOrders();
  ///
  /// // Get user's orders
  /// final myOrders = await orderService.getOrders(userId: 123);
  ///
  /// // Get pending orders
  /// final pending = await orderService.getOrders(status: 'pending');
  /// ```
  Future<List<dynamic>> getOrders({
    int? userId,
    int? mitraId,
    String? status,
    String? wasteType,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      // Validate waste type if provided
      if (wasteType != null && !wasteTypes.contains(wasteType)) {
        throw ArgumentError(
          'Invalid waste type. Must be one of: ${wasteTypes.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (userId != null) query['user_id'] = userId;
      if (mitraId != null) query['mitra_id'] = mitraId;
      if (status != null) query['status'] = status;
      if (wasteType != null) query['waste_type'] = wasteType;

      print('📦 Getting orders');
      if (userId != null) print('   Filter: User #$userId');
      if (mitraId != null) print('   Filter: Mitra #$mitraId');
      if (status != null) print('   Filter: Status = $status');

      final response = await _apiClient.getJson('/api/orders', query: query);

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} orders');
      return data;
    } catch (e) {
      print('❌ Error getting orders: $e');
      rethrow;
    }
  }

  /// Get order by ID
  ///
  /// GET /api/orders/{id}
  ///
  /// Parameters:
  /// - [orderId]: Order ID
  ///
  /// Returns: Order object with full details
  ///
  /// Example:
  /// ```dart
  /// final order = await orderService.getOrderById(123);
  /// print('Status: ${order['status']}');
  /// print('Total: Rp ${order['total_price']}');
  /// ```
  Future<dynamic> getOrderById(int orderId) async {
    try {
      print('📦 Getting order #$orderId');

      final response = await _apiClient.get('/api/orders/$orderId');

      final order = response['data'];
      print('✅ Order: ${order['status']} - Rp ${order['total_price'] ?? 0}');

      return order;
    } catch (e) {
      print('❌ Error getting order: $e');
      rethrow;
    }
  }

  /// Create new order
  ///
  /// POST /api/orders
  ///
  /// Parameters:
  /// - [scheduleId]: Related schedule ID
  /// - [wasteType]: Type of waste (plastic, paper, metal, etc.)
  /// - [estimatedWeight]: Estimated weight in kg
  /// - [pickupAddress]: Pickup address
  /// - [latitude]: Address latitude (optional)
  /// - [longitude]: Address longitude (optional)
  /// - [notes]: Additional notes (optional)
  /// - [photoUrl]: Photo of waste (optional, base64)
  ///
  /// Returns: Created order object
  ///
  /// Example:
  /// ```dart
  /// final order = await orderService.createOrder(
  ///   scheduleId: 456,
  ///   wasteType: 'plastic',
  ///   estimatedWeight: 5.5,
  ///   pickupAddress: 'Jl. Sudirman No. 123',
  ///   latitude: -6.2088,
  ///   longitude: 106.8456,
  ///   notes: '3 bags of plastic bottles',
  /// );
  /// ```
  Future<dynamic> createOrder({
    required int scheduleId,
    required String wasteType,
    required double estimatedWeight,
    required String pickupAddress,
    double? latitude,
    double? longitude,
    String? notes,
    String? photoUrl,
  }) async {
    try {
      // Validate waste type
      if (!wasteTypes.contains(wasteType)) {
        throw ArgumentError(
          'Invalid waste type. Must be one of: ${wasteTypes.join(", ")}',
        );
      }

      // Validate weight
      if (estimatedWeight <= 0) {
        throw ArgumentError('Estimated weight must be greater than 0');
      }

      // Validate address
      if (pickupAddress.trim().isEmpty) {
        throw ArgumentError('Pickup address is required');
      }

      // Validate coordinates if provided
      if (latitude != null && (latitude < -90 || latitude > 90)) {
        throw ArgumentError('Latitude must be between -90 and 90');
      }
      if (longitude != null && (longitude < -180 || longitude > 180)) {
        throw ArgumentError('Longitude must be between -180 and 180');
      }

      final body = {
        'schedule_id': scheduleId,
        'waste_type': wasteType,
        'estimated_weight': estimatedWeight,
        'pickup_address': pickupAddress,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
      };

      print('📦 Creating order');
      print('   Type: $wasteType');
      print('   Weight: ${estimatedWeight}kg');
      print('   Address: $pickupAddress');

      final response = await _apiClient.postJson('/api/orders', body);

      print('✅ Order created');
      return response['data'];
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  /// Update existing order
  ///
  /// PUT /api/orders/{id}
  ///
  /// Parameters:
  /// - [orderId]: Order ID to update
  /// - [wasteType]: New waste type (optional)
  /// - [estimatedWeight]: New estimated weight (optional)
  /// - [actualWeight]: Actual weight after pickup (optional)
  /// - [pickupAddress]: New pickup address (optional)
  /// - [latitude]: New latitude (optional)
  /// - [longitude]: New longitude (optional)
  /// - [notes]: New notes (optional)
  /// - [status]: New status (optional)
  /// - [totalPrice]: Total price (optional, set by mitra)
  /// - [photoUrl]: New photo (optional, base64)
  ///
  /// Returns: Updated order object
  ///
  /// Example:
  /// ```dart
  /// // User updates order before pickup
  /// final order = await orderService.updateOrder(
  ///   orderId: 123,
  ///   estimatedWeight: 7.0,
  ///   notes: 'Updated: 4 bags now',
  /// );
  ///
  /// // Mitra updates after pickup
  /// final order = await orderService.updateOrder(
  ///   orderId: 123,
  ///   actualWeight: 6.5,
  ///   totalPrice: 32500.0,
  ///   status: 'completed',
  /// );
  /// ```
  Future<dynamic> updateOrder({
    required int orderId,
    String? wasteType,
    double? estimatedWeight,
    double? actualWeight,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    String? notes,
    String? status,
    double? totalPrice,
    String? photoUrl,
  }) async {
    try {
      // Validate waste type if provided
      if (wasteType != null && !wasteTypes.contains(wasteType)) {
        throw ArgumentError(
          'Invalid waste type. Must be one of: ${wasteTypes.join(", ")}',
        );
      }

      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      // Validate weights if provided
      if (estimatedWeight != null && estimatedWeight <= 0) {
        throw ArgumentError('Estimated weight must be greater than 0');
      }
      if (actualWeight != null && actualWeight <= 0) {
        throw ArgumentError('Actual weight must be greater than 0');
      }

      // Validate coordinates if provided
      if (latitude != null && (latitude < -90 || latitude > 90)) {
        throw ArgumentError('Latitude must be between -90 and 90');
      }
      if (longitude != null && (longitude < -180 || longitude > 180)) {
        throw ArgumentError('Longitude must be between -180 and 180');
      }

      final body = <String, dynamic>{};

      if (wasteType != null) body['waste_type'] = wasteType;
      if (estimatedWeight != null) body['estimated_weight'] = estimatedWeight;
      if (actualWeight != null) body['actual_weight'] = actualWeight;
      if (pickupAddress != null && pickupAddress.isNotEmpty)
        body['pickup_address'] = pickupAddress;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (notes != null) body['notes'] = notes;
      if (status != null) body['status'] = status;
      if (totalPrice != null) body['total_price'] = totalPrice;
      if (photoUrl != null) body['photo_url'] = photoUrl;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('📦 Updating order #$orderId');

      final response = await _apiClient.putJson('/api/orders/$orderId', body);

      print('✅ Order updated');
      return response['data'];
    } catch (e) {
      print('❌ Error updating order: $e');
      rethrow;
    }
  }

  /// Delete order
  ///
  /// DELETE /api/orders/{id}
  ///
  /// Parameters:
  /// - [orderId]: Order ID to delete
  ///
  /// Example:
  /// ```dart
  /// await orderService.deleteOrder(123);
  /// print('Order cancelled successfully');
  /// ```
  Future<void> deleteOrder(int orderId) async {
    try {
      print('🗑️ Deleting order #$orderId');

      await _apiClient.delete('/api/orders/$orderId');

      print('✅ Order deleted');
    } catch (e) {
      print('❌ Error deleting order: $e');
      rethrow;
    }
  }

  // ========================================
  // Status Update Helpers
  // ========================================

  /// Accept order (mitra)
  Future<dynamic> acceptOrder(int orderId) async {
    return updateOrder(orderId: orderId, status: 'accepted');
  }

  /// Reject order (mitra)
  Future<dynamic> rejectOrder(int orderId) async {
    return updateOrder(orderId: orderId, status: 'rejected');
  }

  /// Mark as on the way (mitra)
  Future<dynamic> startPickup(int orderId) async {
    return updateOrder(orderId: orderId, status: 'on_the_way');
  }

  /// Mark as picked up (mitra)
  Future<dynamic> markAsPickedUp(int orderId, double actualWeight) async {
    return updateOrder(
      orderId: orderId,
      status: 'picked_up',
      actualWeight: actualWeight,
    );
  }

  /// Complete order (mitra)
  Future<dynamic> completeOrder({
    required int orderId,
    required double actualWeight,
    required double totalPrice,
  }) async {
    return updateOrder(
      orderId: orderId,
      status: 'completed',
      actualWeight: actualWeight,
      totalPrice: totalPrice,
    );
  }

  /// Cancel order (user)
  Future<dynamic> cancelOrder(int orderId) async {
    return updateOrder(orderId: orderId, status: 'cancelled');
  }

  // ========================================
  // Query Helpers
  // ========================================

  /// Get active orders (not completed/cancelled/rejected)
  Future<List<dynamic>> getActiveOrders({int? userId, int? mitraId}) async {
    try {
      final pending = await getOrders(
        userId: userId,
        mitraId: mitraId,
        status: 'pending',
      );
      final accepted = await getOrders(
        userId: userId,
        mitraId: mitraId,
        status: 'accepted',
      );
      final onTheWay = await getOrders(
        userId: userId,
        mitraId: mitraId,
        status: 'on_the_way',
      );
      final pickedUp = await getOrders(
        userId: userId,
        mitraId: mitraId,
        status: 'picked_up',
      );

      return [...pending, ...accepted, ...onTheWay, ...pickedUp];
    } catch (e) {
      print('❌ Error getting active orders: $e');
      return [];
    }
  }

  /// Get completed orders
  Future<List<dynamic>> getCompletedOrders({int? userId, int? mitraId}) async {
    return getOrders(userId: userId, mitraId: mitraId, status: 'completed');
  }

  /// Get order statistics
  Future<Map<String, int>> getOrderStatistics({
    int? userId,
    int? mitraId,
  }) async {
    try {
      final stats = <String, int>{};

      for (var status in statuses) {
        final orders = await getOrders(
          userId: userId,
          mitraId: mitraId,
          status: status,
          perPage: 1,
        );
        stats[status] = orders.length;
      }

      return stats;
    } catch (e) {
      print('❌ Error getting order statistics: $e');
      return {};
    }
  }

  /// Calculate total earnings (for mitra)
  Future<double> calculateTotalEarnings(int mitraId) async {
    try {
      final completedOrders = await getCompletedOrders(mitraId: mitraId);

      double total = 0.0;
      for (var order in completedOrders) {
        final price = (order['total_price'] ?? 0.0) as num;
        total += price.toDouble();
      }

      return total;
    } catch (e) {
      print('❌ Error calculating earnings: $e');
      return 0.0;
    }
  }

  /// Validate order can be updated
  String? validateOrderUpdate(String currentStatus, String newStatus) {
    // Define valid status transitions
    final validTransitions = {
      'pending': ['accepted', 'rejected', 'cancelled'],
      'accepted': ['on_the_way', 'cancelled'],
      'on_the_way': ['picked_up', 'cancelled'],
      'picked_up': ['completed', 'cancelled'],
      'completed': [], // Cannot change from completed
      'cancelled': [], // Cannot change from cancelled
      'rejected': [], // Cannot change from rejected
    };

    final allowed = validTransitions[currentStatus] ?? [];

    if (!allowed.contains(newStatus)) {
      return 'Cannot change status from $currentStatus to $newStatus';
    }

    return null; // Valid transition
  }
}
