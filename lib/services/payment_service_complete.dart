import 'package:bank_sha/services/api_client.dart';

/// Complete Payment Service - Transaction Processing
///
/// Features:
/// - Create payment (POST /api/payments)
/// - Update payment (PUT /api/payments/{id})
/// - Get payments list (GET /api/payments)
/// - Get payment by ID (GET /api/payments/{id})
/// - Mark payment as paid (PUT /api/payments/{id}/mark-paid)
/// - Generate QRIS code
/// - Check payment status
/// - Support multiple payment methods
///
/// Payment Methods:
/// - cash: Cash on delivery/pickup
/// - transfer: Bank transfer (requires proof image)
/// - ewallet: E-wallet (OVO, GoPay, Dana, etc.)
/// - qris: QRIS payment (scan QR code)
///
/// Use Cases:
/// - User pays for order
/// - Upload payment proof (transfer)
/// - Generate QRIS for payment
/// - Admin verifies payment
/// - Auto-update order status after successful payment
class PaymentServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // Supported payment methods
  static const List<String> paymentMethods = [
    'cash',
    'transfer',
    'ewallet',
    'qris',
  ];

  // Payment statuses
  static const List<String> paymentStatuses = ['pending', 'success', 'failed'];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Create a new payment for an order
  ///
  /// POST /api/payments
  ///
  /// Parameters:
  /// - [orderId]: ID of the order to pay for
  /// - [method]: Payment method (cash, transfer, ewallet, qris)
  /// - [amount]: Payment amount (must match order total)
  /// - [proofImage]: Base64 encoded proof of payment (for transfer)
  /// - [transactionId]: External transaction ID (for ewallet/qris)
  /// - [notes]: Additional notes (optional)
  ///
  /// Returns: Created Payment object
  ///
  /// Example:
  /// ```dart
  /// // Cash payment
  /// final cashPayment = await paymentService.createPayment(
  ///   orderId: 123,
  ///   method: 'cash',
  ///   amount: 50000.0,
  /// );
  ///
  /// // Transfer with proof
  /// final transferPayment = await paymentService.createPayment(
  ///   orderId: 123,
  ///   method: 'transfer',
  ///   amount: 50000.0,
  ///   proofImage: base64Image,
  ///   notes: 'Transfer from BCA',
  /// );
  ///
  /// // E-wallet
  /// final ewalletPayment = await paymentService.createPayment(
  ///   orderId: 123,
  ///   method: 'ewallet',
  ///   amount: 50000.0,
  ///   transactionId: 'OVO-123456789',
  /// );
  /// ```
  Future<dynamic> createPayment({
    required int orderId,
    required String method,
    required double amount,
    String? proofImage,
    String? transactionId,
    String? notes,
  }) async {
    try {
      // Validate method
      if (!paymentMethods.contains(method)) {
        throw ArgumentError(
          'Invalid payment method. Must be one of: ${paymentMethods.join(", ")}',
        );
      }

      // Validate amount
      if (amount <= 0) {
        throw ArgumentError('Amount must be greater than 0');
      }

      // Validate proof for transfer
      if (method == 'transfer' && (proofImage == null || proofImage.isEmpty)) {
        throw ArgumentError('Proof of payment is required for bank transfer');
      }

      final body = {
        'order_id': orderId,
        'method': method,
        'amount': amount,
        if (proofImage != null && proofImage.isNotEmpty)
          'proof_image': proofImage,
        if (transactionId != null && transactionId.isNotEmpty)
          'transaction_id': transactionId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('💳 Creating payment for Order #$orderId');
      print('   Method: $method');
      print('   Amount: Rp ${amount.toStringAsFixed(2)}');

      final response = await _apiClient.postJson('/api/payments', body);

      print('✅ Payment created successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error creating payment: $e');
      rethrow;
    }
  }

  /// Update existing payment
  ///
  /// PUT /api/payments/{id}
  ///
  /// Parameters:
  /// - [id]: Payment ID to update
  /// - [status]: New status (pending, success, failed)
  /// - [proofImage]: New proof image
  /// - [transactionId]: New transaction ID
  /// - [notes]: New notes
  ///
  /// Returns: Updated Payment object
  ///
  /// Example:
  /// ```dart
  /// // Update payment status
  /// final updated = await paymentService.updatePayment(
  ///   789,
  ///   status: 'success',
  ///   notes: 'Payment verified by admin',
  /// );
  /// ```
  Future<dynamic> updatePayment(
    int id, {
    String? status,
    String? proofImage,
    String? transactionId,
    String? notes,
  }) async {
    try {
      // Validate status if provided
      if (status != null && !paymentStatuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${paymentStatuses.join(", ")}',
        );
      }

      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (proofImage != null) body['proof_image'] = proofImage;
      if (transactionId != null) body['transaction_id'] = transactionId;
      if (notes != null) body['notes'] = notes;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('💳 Updating payment #$id');

      final response = await _apiClient.putJson('/api/payments/$id', body);

      print('✅ Payment updated successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error updating payment: $e');
      rethrow;
    }
  }

  /// Mark payment as paid (admin/system action)
  ///
  /// PUT /api/payments/{id}/mark-paid
  ///
  /// Parameters:
  /// - [id]: Payment ID to mark as paid
  ///
  /// Returns: Updated Payment object
  ///
  /// Example:
  /// ```dart
  /// await paymentService.markAsPaid(789);
  /// ```
  Future<dynamic> markAsPaid(int id) async {
    try {
      print('💳 Marking payment #$id as paid');

      final response = await _apiClient.putJson(
        '/api/payments/$id/mark-paid',
        {},
      );

      print('✅ Payment marked as paid');
      return response['data'];
    } catch (e) {
      print('❌ Error marking as paid: $e');
      rethrow;
    }
  }

  /// Get list of payments
  ///
  /// GET /api/payments
  ///
  /// Parameters:
  /// - [orderId]: Filter by order ID
  /// - [userId]: Filter by user ID
  /// - [method]: Filter by payment method
  /// - [status]: Filter by payment status
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of Payment objects
  ///
  /// Example:
  /// ```dart
  /// // Get all payments for an order
  /// final orderPayments = await paymentService.getPayments(orderId: 123);
  ///
  /// // Get pending payments
  /// final pendingPayments = await paymentService.getPayments(status: 'pending');
  /// ```
  Future<List<dynamic>> getPayments({
    int? orderId,
    int? userId,
    String? method,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (orderId != null) query['order_id'] = orderId;
      if (userId != null) query['user_id'] = userId;
      if (method != null) query['method'] = method;
      if (status != null) query['status'] = status;

      print('💳 Getting payments');
      if (orderId != null) print('   Filter: Order #$orderId');
      if (method != null) print('   Filter: Method = $method');
      if (status != null) print('   Filter: Status = $status');

      final response = await _apiClient.getJson('/api/payments', query: query);

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} payments');
      return data;
    } catch (e) {
      print('❌ Error getting payments: $e');
      rethrow;
    }
  }

  /// Get payment by ID
  ///
  /// GET /api/payments/{id}
  ///
  /// Parameters:
  /// - [id]: Payment ID
  ///
  /// Returns: Payment object
  ///
  /// Example:
  /// ```dart
  /// final payment = await paymentService.getPaymentById(789);
  /// print('Status: ${payment['status']}');
  /// print('Amount: Rp ${payment['amount']}');
  /// ```
  Future<dynamic> getPaymentById(int id) async {
    try {
      print('💳 Getting payment #$id');

      final response = await _apiClient.get('/api/payments/$id');

      print('✅ Payment found');
      return response['data'];
    } catch (e) {
      print('❌ Error getting payment: $e');
      rethrow;
    }
  }

  // ========================================
  // QRIS & E-wallet Integration
  // ========================================

  /// Generate QRIS code for payment
  ///
  /// This creates a payment and returns QRIS code URL/data
  ///
  /// Parameters:
  /// - [orderId]: Order ID to pay for
  /// - [amount]: Payment amount
  ///
  /// Returns: QRIS code URL or base64 image
  ///
  /// Example:
  /// ```dart
  /// final qrisCode = await paymentService.generateQRIS(
  ///   orderId: 123,
  ///   amount: 50000.0,
  /// );
  /// // Display QR code in UI
  /// Image.network(qrisCode);
  /// ```
  Future<String> generateQRIS({
    required int orderId,
    required double amount,
  }) async {
    try {
      print('📱 Generating QRIS for Order #$orderId');
      print('   Amount: Rp ${amount.toStringAsFixed(2)}');

      // Create QRIS payment
      final payment = await createPayment(
        orderId: orderId,
        method: 'qris',
        amount: amount,
      );

      // Extract QRIS code from response
      // This depends on backend implementation
      final qrisCode = payment['qris_code'] ?? payment['qr_code_url'];

      if (qrisCode == null) {
        throw Exception('QRIS code not generated by backend');
      }

      print('✅ QRIS generated successfully');
      return qrisCode as String;
    } catch (e) {
      print('❌ Error generating QRIS: $e');
      rethrow;
    }
  }

  /// Check payment status (polling for QRIS/e-wallet)
  ///
  /// Parameters:
  /// - [paymentId]: Payment ID to check
  ///
  /// Returns: Payment status (pending, success, failed)
  ///
  /// Example:
  /// ```dart
  /// final status = await paymentService.checkPaymentStatus(789);
  /// if (status == 'success') {
  ///   // Payment completed
  ///   navigateToSuccessPage();
  /// }
  /// ```
  Future<String> checkPaymentStatus(int paymentId) async {
    try {
      print('🔍 Checking payment status #$paymentId');

      final payment = await getPaymentById(paymentId);
      final status = payment['status'] ?? 'pending';

      print('   Status: $status');
      return status as String;
    } catch (e) {
      print('❌ Error checking payment status: $e');
      rethrow;
    }
  }

  /// Poll payment status until completed or timeout
  ///
  /// Parameters:
  /// - [paymentId]: Payment ID to monitor
  /// - [onStatusChange]: Callback when status changes
  /// - [intervalSeconds]: Polling interval (default: 3 seconds)
  /// - [timeoutMinutes]: Max polling time (default: 10 minutes)
  ///
  /// Example:
  /// ```dart
  /// await paymentService.pollPaymentStatus(
  ///   789,
  ///   onStatusChange: (status) {
  ///     print('Payment status: $status');
  ///     if (status == 'success') {
  ///       showSuccessDialog();
  ///     }
  ///   },
  /// );
  /// ```
  Future<String> pollPaymentStatus(
    int paymentId, {
    Function(String)? onStatusChange,
    int intervalSeconds = 3,
    int timeoutMinutes = 10,
  }) async {
    print('🔄 Starting payment status polling for #$paymentId');

    final startTime = DateTime.now();
    String lastStatus = 'pending';

    while (true) {
      try {
        final status = await checkPaymentStatus(paymentId);

        if (status != lastStatus) {
          lastStatus = status;
          onStatusChange?.call(status);
        }

        // Check if completed
        if (status == 'success' || status == 'failed') {
          print('✅ Payment completed with status: $status');
          return status;
        }

        // Check timeout
        final elapsed = DateTime.now().difference(startTime);
        if (elapsed.inMinutes >= timeoutMinutes) {
          print('⏱️ Payment polling timeout');
          return lastStatus;
        }

        // Wait before next poll
        await Future.delayed(Duration(seconds: intervalSeconds));
      } catch (e) {
        print('❌ Error polling payment: $e');
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get payment methods info
  ///
  /// Returns: List of available payment methods with details
  ///
  /// Example:
  /// ```dart
  /// final methods = paymentService.getPaymentMethods();
  /// for (var method in methods) {
  ///   print('${method['name']}: ${method['description']}');
  /// }
  /// ```
  List<Map<String, dynamic>> getPaymentMethods() {
    return [
      {
        'id': 'cash',
        'name': 'Cash',
        'description': 'Pay with cash on delivery/pickup',
        'requires_proof': false,
        'instant': true,
      },
      {
        'id': 'transfer',
        'name': 'Bank Transfer',
        'description': 'Transfer to bank account',
        'requires_proof': true,
        'instant': false,
      },
      {
        'id': 'ewallet',
        'name': 'E-Wallet',
        'description': 'OVO, GoPay, Dana, etc.',
        'requires_proof': false,
        'instant': true,
      },
      {
        'id': 'qris',
        'name': 'QRIS',
        'description': 'Scan QR code to pay',
        'requires_proof': false,
        'instant': true,
      },
    ];
  }

  /// Validate payment before creation
  ///
  /// Parameters:
  /// - [orderId]: Order ID
  /// - [amount]: Payment amount
  /// - [method]: Payment method
  ///
  /// Returns: null if valid, error message if invalid
  ///
  /// Example:
  /// ```dart
  /// final error = await paymentService.validatePayment(
  ///   orderId: 123,
  ///   amount: 50000.0,
  ///   method: 'transfer',
  /// );
  /// if (error != null) {
  ///   showErrorDialog(error);
  /// }
  /// ```
  Future<String?> validatePayment({
    required int orderId,
    required double amount,
    required String method,
  }) async {
    try {
      // Validate method
      if (!paymentMethods.contains(method)) {
        return 'Invalid payment method: $method';
      }

      // Validate amount
      if (amount <= 0) {
        return 'Amount must be greater than 0';
      }

      // Check if order already has successful payment
      final existingPayments = await getPayments(
        orderId: orderId,
        status: 'success',
      );
      if (existingPayments.isNotEmpty) {
        return 'Order has already been paid';
      }

      return null; // Valid
    } catch (e) {
      return 'Error validating payment: $e';
    }
  }
}
