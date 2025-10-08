import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_routes.dart';
import '../services/local_storage_service.dart';
import 'package:logger/logger.dart';

class EndUserApiService {
  static final EndUserApiService _instance = EndUserApiService._internal();
  factory EndUserApiService() => _instance;
  EndUserApiService._internal();

  final Logger _logger = Logger();
  late LocalStorageService _localStorage;

  Future<void> initialize() async {
    _localStorage = await LocalStorageService.getInstance();
  }

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _localStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Orders API
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.orders}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching orders: $e');
      return [];
    }
  }

  // Create new order
  Future<Map<String, dynamic>?> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.orders}'),
        headers: headers,
        body: json.encode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to create order: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating order: $e');
      return null;
    }
  }

  // Schedule API
  Future<List<Map<String, dynamic>>> getUserSchedules() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.schedules}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch schedules: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching schedules: $e');
      return [];
    }
  }

  // Create new schedule
  Future<Map<String, dynamic>?> createSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.schedules}'),
        headers: headers,
        body: json.encode(scheduleData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to create schedule: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating schedule: $e');
      return null;
    }
  }

  // Tracking API
  Future<List<Map<String, dynamic>>> getOrderTracking(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/tracking/order/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch tracking: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching tracking: $e');
      return [];
    }
  }

  // Balance API
  Future<Map<String, dynamic>?> getBalanceSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.balanceSummary}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to fetch balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching balance: $e');
      return null;
    }
  }

  // Balance Ledger (Points History)
  Future<List<Map<String, dynamic>>> getBalanceLedger() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.balanceLedger}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch balance ledger: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching balance ledger: $e');
      return [];
    }
  }

  // Top up balance
  Future<bool> topUpBalance(double amount, String paymentMethod) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.balanceTopup}'),
        headers: headers,
        body: json.encode({'amount': amount, 'payment_method': paymentMethod}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Error topping up balance: $e');
      return false;
    }
  }

  // Notifications API
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.notifications}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notifications as read
  Future<bool> markNotificationsAsRead(List<int> notificationIds) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.notificationMarkRead}'),
        headers: headers,
        body: json.encode({'notification_ids': notificationIds}),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error marking notifications as read: $e');
      return false;
    }
  }

  // Chat API
  Future<List<Map<String, dynamic>>> getChats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.chats}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch chats: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching chats: $e');
      return [];
    }
  }

  // Send chat message
  Future<bool> sendMessage(
    int receiverId,
    String message, {
    int? orderId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.chats}'),
        headers: headers,
        body: json.encode({
          'receiver_id': receiverId,
          'message': message,
          if (orderId != null) 'order_id': orderId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Error sending message: $e');
      return false;
    }
  }

  // Services API
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.services}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch services: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching services: $e');
      return [];
    }
  }

  // Ratings API
  Future<bool> submitRating(int orderId, int rating, String? comment) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.ratings}'),
        headers: headers,
        body: json.encode({
          'order_id': orderId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Error submitting rating: $e');
      return false;
    }
  }

  // Feedback API
  Future<bool> submitFeedback(String message, String? category) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.feedback}'),
        headers: headers,
        body: json.encode({
          'message': message,
          if (category != null) 'category': category,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logger.e('Error submitting feedback: $e');
      return false;
    }
  }

  // Get user feedback history
  Future<List<Map<String, dynamic>>> getFeedbackHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.feedback}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch feedback history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching feedback history: $e');
      return [];
    }
  }

  // Payment API
  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.payments}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch payments: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching payments: $e');
      return [];
    }
  }

  // Create payment
  Future<Map<String, dynamic>?> createPayment(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.payments}'),
        headers: headers,
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to create payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating payment: $e');
      return null;
    }
  }

  // Address API
  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.addresses}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch addresses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching addresses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createAddress(
    Map<String, dynamic> addressData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.addresses}'),
        headers: headers,
        body: json.encode(addressData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to create address: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating address: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateAddress(
    int addressId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.addresses}/$addressId'),
        headers: headers,
        body: json.encode(addressData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to update address: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error updating address: $e');
      return null;
    }
  }

  Future<bool> deleteAddress(int addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.addresses}/$addressId'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _logger.e('Error deleting address: $e');
      return false;
    }
  }

  Future<bool> setDefaultAddress(int addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(
          '${ApiRoutes.baseUrl}${ApiRoutes.addresses}/$addressId/set-default',
        ),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error setting default address: $e');
      return false;
    }
  }

  // Feedback/Complaint API
  Future<List<Map<String, dynamic>>> getUserFeedback() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.feedback}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        _logger.e('Failed to fetch feedback: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Error fetching feedback: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createFeedback(
    Map<String, dynamic> feedbackData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.feedback}'),
        headers: headers,
        body: json.encode(feedbackData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        _logger.e('Failed to create feedback: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Error creating feedback: $e');
      return null;
    }
  }
}
