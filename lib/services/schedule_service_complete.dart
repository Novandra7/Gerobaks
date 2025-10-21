import 'package:bank_sha/services/api_client.dart';

/// Complete Schedule Service - Full CRUD for Schedules
///
/// Features:
/// - Get all schedules (GET /api/schedules)
/// - Get schedule by ID (GET /api/schedules/{id})
/// - Create schedule (POST /api/schedules) [ALREADY EXISTS]
/// - Update schedule (PUT /api/schedules/{id}) [NEW]
/// - Delete schedule (DELETE /api/schedules/{id}) [NEW]
/// - Filter by user/mitra
/// - Validation helpers
///
/// Use Cases:
/// - Users create pickup schedules
/// - Users update schedule times
/// - Users cancel schedules
/// - Admin manages all schedules
class ScheduleServiceComplete {
  final ApiClient _apiClient = ApiClient();

  // Schedule statuses
  static const List<String> statuses = [
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Get all schedules with filters
  ///
  /// GET /api/schedules
  ///
  /// Parameters:
  /// - [userId]: Filter by user ID
  /// - [mitraId]: Filter by mitra ID
  /// - [status]: Filter by status
  /// - [date]: Filter by date (YYYY-MM-DD)
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of schedules
  ///
  /// Example:
  /// ```dart
  /// // Get all schedules
  /// final schedules = await scheduleService.getSchedules();
  ///
  /// // Get user's schedules
  /// final mySchedules = await scheduleService.getSchedules(userId: 123);
  ///
  /// // Get pending schedules
  /// final pending = await scheduleService.getSchedules(status: 'pending');
  /// ```
  Future<List<dynamic>> getSchedules({
    int? userId,
    int? mitraId,
    String? status,
    String? date,
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

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (userId != null) query['user_id'] = userId;
      if (mitraId != null) query['mitra_id'] = mitraId;
      if (status != null) query['status'] = status;
      if (date != null && date.isNotEmpty) query['date'] = date;

      print('📅 Getting schedules');
      if (userId != null) print('   Filter: User #$userId');
      if (mitraId != null) print('   Filter: Mitra #$mitraId');
      if (status != null) print('   Filter: Status = $status');

      final response = await _apiClient.getJson('/api/schedules', query: query);

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} schedules');
      return data;
    } catch (e) {
      print('❌ Error getting schedules: $e');
      rethrow;
    }
  }

  /// Get schedule by ID
  ///
  /// GET /api/schedules/{id}
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID
  ///
  /// Returns: Schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.getScheduleById(123);
  /// print('Date: ${schedule['pickup_date']}');
  /// print('Time: ${schedule['pickup_time']}');
  /// ```
  Future<dynamic> getScheduleById(int scheduleId) async {
    try {
      print('📅 Getting schedule #$scheduleId');

      final response = await _apiClient.get('/api/schedules/$scheduleId');

      final schedule = response['data'];
      print(
        '✅ Schedule: ${schedule['pickup_date']} at ${schedule['pickup_time']}',
      );

      return schedule;
    } catch (e) {
      print('❌ Error getting schedule: $e');
      rethrow;
    }
  }

  /// Create new schedule
  ///
  /// POST /api/schedules
  ///
  /// Parameters:
  /// - [pickupDate]: Pickup date (YYYY-MM-DD)
  /// - [pickupTime]: Pickup time (HH:MM)
  /// - [address]: Pickup address
  /// - [latitude]: Address latitude (optional)
  /// - [longitude]: Address longitude (optional)
  /// - [notes]: Additional notes (optional)
  ///
  /// Returns: Created schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.createSchedule(
  ///   pickupDate: '2024-01-15',
  ///   pickupTime: '14:00',
  ///   address: 'Jl. Sudirman No. 123',
  ///   latitude: -6.2088,
  ///   longitude: 106.8456,
  ///   notes: 'Near the park',
  /// );
  /// ```
  Future<dynamic> createSchedule({
    required String pickupDate,
    required String pickupTime,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      // Validate required fields
      if (pickupDate.trim().isEmpty) {
        throw ArgumentError('Pickup date is required');
      }
      if (pickupTime.trim().isEmpty) {
        throw ArgumentError('Pickup time is required');
      }
      if (address.trim().isEmpty) {
        throw ArgumentError('Address is required');
      }

      // Validate coordinates if provided
      if (latitude != null && (latitude < -90 || latitude > 90)) {
        throw ArgumentError('Latitude must be between -90 and 90');
      }
      if (longitude != null && (longitude < -180 || longitude > 180)) {
        throw ArgumentError('Longitude must be between -180 and 180');
      }

      final body = {
        'pickup_date': pickupDate,
        'pickup_time': pickupTime,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      print('📅 Creating schedule');
      print('   Date: $pickupDate');
      print('   Time: $pickupTime');
      print('   Address: $address');

      final response = await _apiClient.postJson('/api/schedules', body);

      print('✅ Schedule created');
      return response['data'];
    } catch (e) {
      print('❌ Error creating schedule: $e');
      rethrow;
    }
  }

  /// Update existing schedule
  ///
  /// PUT /api/schedules/{id}
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to update
  /// - [pickupDate]: New pickup date (optional)
  /// - [pickupTime]: New pickup time (optional)
  /// - [address]: New address (optional)
  /// - [latitude]: New latitude (optional)
  /// - [longitude]: New longitude (optional)
  /// - [notes]: New notes (optional)
  /// - [status]: New status (optional)
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// // Update time only
  /// final schedule = await scheduleService.updateSchedule(
  ///   scheduleId: 123,
  ///   pickupTime: '15:00',
  /// );
  ///
  /// // Update multiple fields
  /// final schedule = await scheduleService.updateSchedule(
  ///   scheduleId: 123,
  ///   pickupDate: '2024-01-16',
  ///   pickupTime: '10:00',
  ///   notes: 'Updated notes',
  /// );
  /// ```
  Future<dynamic> updateSchedule({
    required int scheduleId,
    String? pickupDate,
    String? pickupTime,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    String? status,
  }) async {
    try {
      // Validate status if provided
      if (status != null && !statuses.contains(status)) {
        throw ArgumentError(
          'Invalid status. Must be one of: ${statuses.join(", ")}',
        );
      }

      // Validate coordinates if provided
      if (latitude != null && (latitude < -90 || latitude > 90)) {
        throw ArgumentError('Latitude must be between -90 and 90');
      }
      if (longitude != null && (longitude < -180 || longitude > 180)) {
        throw ArgumentError('Longitude must be between -180 and 180');
      }

      final body = <String, dynamic>{};

      if (pickupDate != null && pickupDate.isNotEmpty)
        body['pickup_date'] = pickupDate;
      if (pickupTime != null && pickupTime.isNotEmpty)
        body['pickup_time'] = pickupTime;
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (notes != null) body['notes'] = notes;
      if (status != null) body['status'] = status;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('📅 Updating schedule #$scheduleId');

      final response = await _apiClient.putJson(
        '/api/schedules/$scheduleId',
        body,
      );

      print('✅ Schedule updated');
      return response['data'];
    } catch (e) {
      print('❌ Error updating schedule: $e');
      rethrow;
    }
  }

  /// Delete schedule
  ///
  /// DELETE /api/schedules/{id}
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to delete
  ///
  /// Example:
  /// ```dart
  /// await scheduleService.deleteSchedule(123);
  /// print('Schedule cancelled successfully');
  /// ```
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      print('🗑️ Deleting schedule #$scheduleId');

      await _apiClient.delete('/api/schedules/$scheduleId');

      print('✅ Schedule deleted');
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Mitra accepts a schedule (POST /api/schedules/{id}/accept)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to accept
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.acceptSchedule(123);
  /// ```
  Future<dynamic> acceptSchedule(int scheduleId) async {
    try {
      print('✅ Accepting schedule #$scheduleId');

      final response = await _apiClient.postJson(
        '/api/schedules/$scheduleId/accept',
        {},
      );

      print('✅ Schedule accepted successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error accepting schedule: $e');
      rethrow;
    }
  }

  /// Mitra starts the pickup (POST /api/schedules/{id}/start)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to start
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.startSchedule(123);
  /// ```
  Future<dynamic> startSchedule(int scheduleId) async {
    try {
      print('🚀 Starting schedule #$scheduleId');

      final response = await _apiClient.postJson(
        '/api/schedules/$scheduleId/start',
        {},
      );

      print('✅ Schedule started successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error starting schedule: $e');
      rethrow;
    }
  }

  /// Mitra completes the pickup (POST /api/schedules/{id}/complete)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to complete
  /// - [actualWeight]: Actual waste weight collected (optional)
  /// - [notes]: Completion notes (optional)
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.completeSchedulePickup(
  ///   scheduleId: 123,
  ///   actualWeight: 15.5,
  ///   notes: 'Collected successfully',
  /// );
  /// ```
  Future<dynamic> completeSchedulePickup({
    required int scheduleId,
    double? actualWeight,
    String? notes,
  }) async {
    try {
      print('✅ Completing schedule #$scheduleId');

      final body = <String, dynamic>{};
      if (actualWeight != null) body['actual_weight'] = actualWeight;
      if (notes != null) body['completion_notes'] = notes;

      final response = await _apiClient.postJson(
        '/api/schedules/$scheduleId/complete',
        body,
      );

      print('✅ Schedule completed successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error completing schedule: $e');
      rethrow;
    }
  }

  /// Cancel schedule with reason (POST /api/schedules/{id}/cancel)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to cancel
  /// - [reason]: Cancellation reason
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.cancelScheduleWithReason(
  ///   scheduleId: 123,
  ///   reason: 'User not available',
  /// );
  /// ```
  Future<dynamic> cancelScheduleWithReason({
    required int scheduleId,
    required String reason,
  }) async {
    try {
      print('❌ Cancelling schedule #$scheduleId');

      final response = await _apiClient.postJson(
        '/api/schedules/$scheduleId/cancel',
        {'cancellation_reason': reason},
      );

      print('✅ Schedule cancelled successfully');
      return response['data'];
    } catch (e) {
      print('❌ Error cancelling schedule: $e');
      rethrow;
    }
  }

  /// Cancel schedule (set status to cancelled) - Legacy method
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to cancel
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.cancelSchedule(123);
  /// ```
  Future<dynamic> cancelSchedule(int scheduleId) async {
    return updateSchedule(scheduleId: scheduleId, status: 'cancelled');
  }

  /// Confirm schedule (set status to confirmed)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to confirm
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.confirmSchedule(123);
  /// ```
  Future<dynamic> confirmSchedule(int scheduleId) async {
    return updateSchedule(scheduleId: scheduleId, status: 'confirmed');
  }

  /// Complete schedule (set status to completed)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID to complete
  ///
  /// Returns: Updated schedule object
  ///
  /// Example:
  /// ```dart
  /// final schedule = await scheduleService.completeSchedule(123);
  /// ```
  Future<dynamic> completeSchedule(int scheduleId) async {
    return updateSchedule(scheduleId: scheduleId, status: 'completed');
  }

  /// Get upcoming schedules for user
  ///
  /// Parameters:
  /// - [userId]: User ID
  ///
  /// Returns: List of upcoming schedules (pending + confirmed)
  ///
  /// Example:
  /// ```dart
  /// final upcoming = await scheduleService.getUpcomingSchedules(123);
  /// ```
  Future<List<dynamic>> getUpcomingSchedules(int userId) async {
    try {
      final pending = await getSchedules(userId: userId, status: 'pending');
      final confirmed = await getSchedules(userId: userId, status: 'confirmed');

      return [...pending, ...confirmed];
    } catch (e) {
      print('❌ Error getting upcoming schedules: $e');
      return [];
    }
  }

  /// Validate schedule date (must be in future)
  ///
  /// Parameters:
  /// - [date]: Date string (YYYY-MM-DD)
  /// - [time]: Time string (HH:MM)
  ///
  /// Returns: null if valid, error message if invalid
  ///
  /// Example:
  /// ```dart
  /// final error = scheduleService.validateScheduleDateTime('2024-01-01', '10:00');
  /// if (error != null) {
  ///   showErrorDialog(error);
  /// }
  /// ```
  String? validateScheduleDateTime(String date, String time) {
    try {
      final dateTime = DateTime.parse('$date $time:00');
      final now = DateTime.now();

      if (dateTime.isBefore(now)) {
        return 'Schedule date/time must be in the future';
      }

      // Allow scheduling up to 30 days in advance
      final maxDate = now.add(Duration(days: 30));
      if (dateTime.isAfter(maxDate)) {
        return 'Cannot schedule more than 30 days in advance';
      }

      return null; // Valid
    } catch (e) {
      return 'Invalid date/time format';
    }
  }
}
