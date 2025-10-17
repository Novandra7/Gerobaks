import 'package:bank_sha/services/api_client.dart';

/// Complete Subscription Service - Subscription management
///
/// Features:
/// - Get all subscriptions (GET /api/subscriptions)
/// - Get subscription by ID (GET /api/subscriptions/{id})
/// - Subscribe (POST /api/subscriptions) [NEW]
/// - Update subscription (PUT /api/subscriptions/{id})
/// - Cancel subscription (DELETE /api/subscriptions/{id}) [NEW]
/// - Get active subscriptions
/// - Subscription plans
///
/// Use Cases:
/// - Users subscribe to premium features
/// - Users manage subscription plans
/// - Auto-renewal handling
/// - Subscription history
class SubscriptionServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // Subscription plans
  static const List<String> plans = ['basic', 'premium', 'enterprise'];

  // Subscription statuses
  static const List<String> statuses = [
    'active',
    'expired',
    'cancelled',
    'pending_payment',
  ];

  // Billing cycles
  static const List<String> billingCycles = ['monthly', 'quarterly', 'yearly'];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Get all subscriptions with filters
  ///
  /// GET /api/subscriptions
  ///
  /// Parameters:
  /// - [userId]: Filter by user ID
  /// - [plan]: Filter by plan (basic, premium, enterprise)
  /// - [status]: Filter by status (active, expired, cancelled)
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of subscriptions
  ///
  /// Example:
  /// ```dart
  /// // Get all subscriptions
  /// final subscriptions = await subscriptionService.getSubscriptions();
  ///
  /// // Get active subscriptions
  /// final active = await subscriptionService.getSubscriptions(status: 'active');
  ///
  /// // Get premium subscribers
  /// final premium = await subscriptionService.getSubscriptions(plan: 'premium');
  /// ```
  Future<List<dynamic>> getSubscriptions({
    int? userId,
    String? plan,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Validate plan if provided
      if (plan != null && !plans.contains(plan)) {
        throw ArgumentError(
          'Invalid plan. Must be one of: ${plans.join(", ")}',
        );
      }

      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (userId != null) query['user_id'] = userId;
      if (plan != null) query['plan'] = plan;
      if (status != null) query['status'] = status;

      print('💎 Getting subscriptions');
      if (plan != null) print('   Filter: Plan = $plan');
      if (status != null) print('   Filter: Status = $status');

      final response = await _apiClient.getJson(
        '/api/subscriptions',
        query: query,
      );

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} subscriptions');
      return data;
    } catch (e) {
      print('❌ Error getting subscriptions: $e');
      rethrow;
    }
  }

  /// Get subscription by ID
  ///
  /// GET /api/subscriptions/{id}
  ///
  /// Parameters:
  /// - [subscriptionId]: Subscription ID
  ///
  /// Returns: Subscription object
  ///
  /// Example:
  /// ```dart
  /// final subscription = await subscriptionService.getSubscriptionById(123);
  /// print('Plan: ${subscription['plan']}');
  /// print('Status: ${subscription['status']}');
  /// ```
  Future<dynamic> getSubscriptionById(int subscriptionId) async {
    try {
      print('💎 Getting subscription #$subscriptionId');

      final response = await _apiClient.get(
        '/api/subscriptions/$subscriptionId',
      );

      final subscription = response['data'];
      print(
        '✅ Subscription: ${subscription['plan']} (${subscription['status']})',
      );

      return subscription;
    } catch (e) {
      print('❌ Error getting subscription: $e');
      rethrow;
    }
  }

  /// Subscribe to a plan
  ///
  /// POST /api/subscriptions
  ///
  /// Parameters:
  /// - [plan]: Subscription plan (basic, premium, enterprise)
  /// - [billingCycle]: Billing cycle (monthly, quarterly, yearly)
  /// - [autoRenew]: Enable auto-renewal (default: true)
  /// - [paymentMethodId]: Payment method ID (optional)
  ///
  /// Returns: Created subscription object
  ///
  /// Example:
  /// ```dart
  /// final subscription = await subscriptionService.subscribe(
  ///   plan: 'premium',
  ///   billingCycle: 'monthly',
  ///   autoRenew: true,
  /// );
  /// ```
  Future<dynamic> subscribe({
    required String plan,
    required String billingCycle,
    bool autoRenew = true,
    int? paymentMethodId,
  }) async {
    try {
      // Validate plan
      if (!plans.contains(plan)) {
        throw ArgumentError(
          'Invalid plan. Must be one of: ${plans.join(", ")}',
        );
      }

      // Validate billing cycle
      if (!billingCycles.contains(billingCycle)) {
        throw ArgumentError(
          'Invalid billing cycle. Must be one of: ${billingCycles.join(", ")}',
        );
      }

      final body = {
        'plan': plan,
        'billing_cycle': billingCycle,
        'auto_renew': autoRenew,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      };

      print('💎 Subscribing to plan');
      print('   Plan: $plan');
      print('   Billing: $billingCycle');
      print('   Auto-renew: $autoRenew');

      final response = await _apiClient.postJson('/api/subscriptions', body);

      print('✅ Subscription created');
      return response['data'];
    } catch (e) {
      print('❌ Error subscribing: $e');
      rethrow;
    }
  }

  /// Update subscription
  ///
  /// PUT /api/subscriptions/{id}
  ///
  /// Parameters:
  /// - [subscriptionId]: Subscription ID to update
  /// - [plan]: New plan (optional)
  /// - [billingCycle]: New billing cycle (optional)
  /// - [autoRenew]: Enable/disable auto-renewal (optional)
  /// - [status]: New status (optional)
  ///
  /// Returns: Updated subscription object
  ///
  /// Example:
  /// ```dart
  /// // Upgrade plan
  /// final subscription = await subscriptionService.updateSubscription(
  ///   subscriptionId: 123,
  ///   plan: 'enterprise',
  /// );
  ///
  /// // Disable auto-renewal
  /// final subscription = await subscriptionService.updateSubscription(
  ///   subscriptionId: 123,
  ///   autoRenew: false,
  /// );
  /// ```
  Future<dynamic> updateSubscription({
    required int subscriptionId,
    String? plan,
    String? billingCycle,
    bool? autoRenew,
    String? status,
  }) async {
    try {
      // Validate plan if provided
      if (plan != null && !plans.contains(plan)) {
        throw ArgumentError(
          'Invalid plan. Must be one of: ${plans.join(", ")}',
        );
      }

      // Validate billing cycle if provided
      if (billingCycle != null && !billingCycles.contains(billingCycle)) {
        throw ArgumentError(
          'Invalid billing cycle. Must be one of: ${billingCycles.join(", ")}',
        );
      }

      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      final body = <String, dynamic>{};

      if (plan != null) body['plan'] = plan;
      if (billingCycle != null) body['billing_cycle'] = billingCycle;
      if (autoRenew != null) body['auto_renew'] = autoRenew;
      if (status != null) body['status'] = status;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('💎 Updating subscription #$subscriptionId');

      final response = await _apiClient.putJson(
        '/api/subscriptions/$subscriptionId',
        body,
      );

      print('✅ Subscription updated');
      return response['data'];
    } catch (e) {
      print('❌ Error updating subscription: $e');
      rethrow;
    }
  }

  /// Cancel subscription
  ///
  /// DELETE /api/subscriptions/{id}
  ///
  /// Parameters:
  /// - [subscriptionId]: Subscription ID to cancel
  ///
  /// Example:
  /// ```dart
  /// await subscriptionService.cancelSubscription(123);
  /// print('Subscription cancelled successfully');
  /// ```
  Future<void> cancelSubscription(int subscriptionId) async {
    try {
      print('🗑️ Cancelling subscription #$subscriptionId');

      await _apiClient.delete('/api/subscriptions/$subscriptionId');

      print('✅ Subscription cancelled');
    } catch (e) {
      print('❌ Error cancelling subscription: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get active subscription for user
  ///
  /// Parameters:
  /// - [userId]: User ID
  ///
  /// Returns: Active subscription or null
  ///
  /// Example:
  /// ```dart
  /// final subscription = await subscriptionService.getActiveSubscription(123);
  /// if (subscription != null) {
  ///   print('Active plan: ${subscription['plan']}');
  /// }
  /// ```
  Future<dynamic> getActiveSubscription(int userId) async {
    try {
      final subscriptions = await getSubscriptions(
        userId: userId,
        status: 'active',
      );

      return subscriptions.isNotEmpty ? subscriptions.first : null;
    } catch (e) {
      print('❌ Error getting active subscription: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  ///
  /// Parameters:
  /// - [userId]: User ID
  ///
  /// Returns: true if user has active subscription
  ///
  /// Example:
  /// ```dart
  /// final hasSubscription = await subscriptionService.hasActiveSubscription(123);
  /// if (!hasSubscription) {
  ///   showUpgradeDialog();
  /// }
  /// ```
  Future<bool> hasActiveSubscription(int userId) async {
    final subscription = await getActiveSubscription(userId);
    return subscription != null;
  }

  /// Get subscription plan details
  ///
  /// Parameters:
  /// - [plan]: Plan name
  ///
  /// Returns: Plan details map
  ///
  /// Example:
  /// ```dart
  /// final details = subscriptionService.getPlanDetails('premium');
  /// print('Price: ${details['monthly_price']}');
  /// ```
  Map<String, dynamic> getPlanDetails(String plan) {
    switch (plan) {
      case 'basic':
        return {
          'name': 'Basic',
          'monthly_price': 0.0,
          'quarterly_price': 0.0,
          'yearly_price': 0.0,
          'features': [
            'Basic waste pickup',
            'Email support',
            '1 pickup per week',
          ],
        };
      case 'premium':
        return {
          'name': 'Premium',
          'monthly_price': 99000.0,
          'quarterly_price': 270000.0,
          'yearly_price': 990000.0,
          'features': [
            'Priority waste pickup',
            '24/7 phone support',
            'Unlimited pickups',
            'Reward points 2x',
            'Exclusive rewards',
          ],
        };
      case 'enterprise':
        return {
          'name': 'Enterprise',
          'monthly_price': 299000.0,
          'quarterly_price': 810000.0,
          'yearly_price': 2990000.0,
          'features': [
            'All Premium features',
            'Dedicated account manager',
            'Custom pickup schedules',
            'Analytics dashboard',
            'API access',
            'Reward points 3x',
          ],
        };
      default:
        return {};
    }
  }

  /// Calculate subscription price
  ///
  /// Parameters:
  /// - [plan]: Plan name
  /// - [billingCycle]: Billing cycle
  ///
  /// Returns: Price for the plan/cycle
  ///
  /// Example:
  /// ```dart
  /// final price = subscriptionService.calculatePrice('premium', 'monthly');
  /// print('Price: Rp $price');
  /// ```
  double calculatePrice(String plan, String billingCycle) {
    final details = getPlanDetails(plan);

    switch (billingCycle) {
      case 'monthly':
        return (details['monthly_price'] ?? 0.0) as double;
      case 'quarterly':
        return (details['quarterly_price'] ?? 0.0) as double;
      case 'yearly':
        return (details['yearly_price'] ?? 0.0) as double;
      default:
        return 0.0;
    }
  }

  /// Get discount percentage for billing cycle
  ///
  /// Parameters:
  /// - [plan]: Plan name
  /// - [billingCycle]: Billing cycle
  ///
  /// Returns: Discount percentage
  ///
  /// Example:
  /// ```dart
  /// final discount = subscriptionService.getDiscount('premium', 'yearly');
  /// print('Save ${discount}% with yearly billing');
  /// ```
  double getDiscount(String plan, String billingCycle) {
    final details = getPlanDetails(plan);
    final monthly = (details['monthly_price'] ?? 0.0) as double;

    if (monthly == 0) return 0.0;

    double totalPrice;
    int months;

    switch (billingCycle) {
      case 'quarterly':
        totalPrice = (details['quarterly_price'] ?? 0.0) as double;
        months = 3;
        break;
      case 'yearly':
        totalPrice = (details['yearly_price'] ?? 0.0) as double;
        months = 12;
        break;
      default:
        return 0.0;
    }

    final regularPrice = monthly * months;
    final savings = regularPrice - totalPrice;

    return (savings / regularPrice) * 100;
  }
}
