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
  /// Get user schedules with optional filters
  ///
  /// Parameters:
  /// - [status]: Filter by status (pending, in_progress, completed, cancelled)
  /// - [date]: Filter by date (YYYY-MM-DD)
  /// - [wasteType]: Filter by waste type (Organik, Anorganik, B3, Elektronik)
  /// - [page]: Page number (default: 1)
  /// - [perPage]: Items per page (default: 20)
  Future<Map<String, dynamic>> getUserSchedules({
    String? status,
    String? date,
    String? wasteType,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final headers = await _getHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (date != null) queryParams['date'] = date;
      if (wasteType != null) queryParams['waste_type'] = wasteType;

      final uri = Uri.parse(
        '${ApiRoutes.baseUrl}/api/waste-schedules',
      ).replace(queryParameters: queryParams);

      _logger.i('📅 Fetching schedules: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _logger.i('✅ Schedules fetched successfully');
          _logger.i(
            '   - Total: ${data['data']['summary']['total_schedules']}',
          );
          _logger.i('   - Active: ${data['data']['summary']['active_count']}');
          _logger.i(
            '   - Completed: ${data['data']['summary']['completed_count']}',
          );

          // Safely cast schedules array to avoid type errors
          final schedulesData = data['data']['schedules'];
          List<Map<String, dynamic>> schedules = [];

          if (schedulesData is List) {
            schedules = schedulesData.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }).toList();
          }

          return {
            'schedules': schedules,
            'pagination': data['data']['pagination'] ?? {},
            'summary': data['data']['summary'] ?? {},
          };
        } else {
          _logger.e('❌ API returned success=false: ${data['message']}');
          return {'schedules': [], 'pagination': {}, 'summary': {}};
        }
      } else if (response.statusCode == 404) {
        _logger.w(
          '⚠️  Endpoint not found (404). Backend endpoint /api/waste-schedules mungkin belum ready',
        );
        _logger.w(
          '   Mengembalikan data kosong. Ini normal jika backend belum ready.',
        );
        return {'schedules': [], 'pagination': {}, 'summary': {}};
      } else {
        _logger.e('❌ Failed to fetch schedules: ${response.statusCode}');
        _logger.e('   Response: ${response.body}');
        return {'schedules': [], 'pagination': {}, 'summary': {}};
      }
    } catch (e) {
      _logger.e('❌ Error fetching schedules: $e');
      return {'schedules': [], 'pagination': {}, 'summary': {}};
    }
  }

  /// Get schedule detail by ID
  Future<Map<String, dynamic>?> getScheduleDetail(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/waste-schedules/$scheduleId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _logger.i('✅ Schedule detail fetched: ID $scheduleId');
          return data['data']['schedule'];
        } else {
          _logger.e('❌ Failed to get schedule detail: ${data['message']}');
          return null;
        }
      } else if (response.statusCode == 404) {
        _logger.e('❌ Schedule not found: ID $scheduleId');
        return null;
      } else {
        _logger.e('❌ Failed to fetch schedule detail: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error fetching schedule detail: $e');
      return null;
    }
  }

  /// Create new schedule
  ///
  /// Required fields:
  /// - service_type: String
  /// - waste_type: String (Organik, Anorganik, B3, Elektronik)
  /// - pickup_address: String
  /// - scheduled_at: String (YYYY-MM-DD HH:MM:SS)
  ///
  /// Optional fields:
  /// - pickup_latitude: double
  /// - pickup_longitude: double
  /// - notes: String
  /// - estimated_weight: double
  Future<Map<String, dynamic>?> createSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final headers = await _getHeaders();

      _logger.i('📝 Creating schedule...');
      _logger.i('   - Service: ${scheduleData['service_type']}');
      _logger.i('   - Waste Type: ${scheduleData['waste_type']}');
      _logger.i('   - Scheduled: ${scheduleData['scheduled_at']}');

      final response = await http.post(
        Uri.parse('${ApiRoutes.baseUrl}/api/waste-schedules'),
        headers: headers,
        body: json.encode(scheduleData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _logger.i(
            '✅ Schedule created successfully: ID ${data['data']['schedule']['id']}',
          );
          return data['data']['schedule'];
        } else {
          _logger.e('❌ Failed to create schedule: ${data['message']}');
          return null;
        }
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        _logger.e('❌ Validation error: ${data['errors']}');
        return null;
      } else {
        _logger.e('❌ Failed to create schedule: ${response.statusCode}');
        _logger.e('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error creating schedule: $e');
      return null;
    }
  }

  /// Cancel schedule
  ///
  /// Parameters:
  /// - [scheduleId]: ID of schedule to cancel
  /// - [reason]: Reason for cancellation (optional)
  Future<bool> cancelSchedule(int scheduleId, {String? reason}) async {
    try {
      final headers = await _getHeaders();

      _logger.i('🚫 Cancelling schedule ID: $scheduleId');
      if (reason != null) {
        _logger.i('   Reason: $reason');
      }

      final response = await http.post(
        Uri.parse(
          '${ApiRoutes.baseUrl}/api/waste-schedules/$scheduleId/cancel',
        ),
        headers: headers,
        body: json.encode({'reason': reason ?? 'Cancelled by user'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _logger.i('✅ Schedule cancelled successfully');
          return true;
        } else {
          _logger.e('❌ Failed to cancel schedule: ${data['message']}');
          return false;
        }
      } else if (response.statusCode == 404) {
        _logger.e('❌ Schedule not found or cannot be cancelled');
        return false;
      } else {
        _logger.e('❌ Failed to cancel schedule: ${response.statusCode}');
        _logger.e('   Response: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error cancelling schedule: $e');
      return false;
    }
  }

  /// Get user pickup schedules (from /api/pickup-schedules)
  /// This is the endpoint that's currently working and used for creating schedules
  Future<List<Map<String, dynamic>>> getUserPickupSchedules() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseUrl}/api/pickup-schedules'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          _logger.i('✅ Pickup schedules fetched successfully');

          // Handle nested response: data.data contains the array
          dynamic schedulesData = data['data'];

          if (schedulesData is Map) {
            // If data is object, check for 'data' key (pagination response)
            if (schedulesData['data'] is List) {
              final schedules = List<Map<String, dynamic>>.from(
                schedulesData['data'],
              );
              _logger.i(
                '📦 Loaded ${schedules.length} schedules from nested data.data',
              );
              return schedules;
            }
            // Check for 'schedules' key (alternative format)
            if (schedulesData['schedules'] is List) {
              return List<Map<String, dynamic>>.from(
                schedulesData['schedules'],
              );
            }
          } else if (schedulesData is List) {
            // Direct array
            return List<Map<String, dynamic>>.from(schedulesData);
          }

          _logger.w('⚠️ Unexpected data format, returning empty list');
          return [];
        } else {
          _logger.e('❌ API returned success=false: ${data['message']}');
          return [];
        }
      } else {
        _logger.e('❌ Failed to fetch pickup schedules: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('❌ Error fetching pickup schedules: $e');
      return [];
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
