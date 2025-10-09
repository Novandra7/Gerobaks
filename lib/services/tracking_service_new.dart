import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Tracking Model untuk API response
class Tracking {
  final int id;
  final int scheduleId;
  final int userId;
  final double latitude;
  final double longitude;
  final String? address;
  final String? status;
  final String? notes;
  final DateTime timestamp;
  final DateTime createdAt;

  Tracking({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.address,
    this.status,
    this.notes,
    required this.timestamp,
    required this.createdAt,
  });

  factory Tracking.fromMap(Map<String, dynamic> map) {
    return Tracking(
      id: map['id']?.toInt() ?? 0,
      scheduleId: map['schedule_id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'],
      status: map['status'],
      notes: map['notes'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Service untuk mengelola tracking lokasi mitra
class TrackingService {
  TrackingService._internal();
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get latest tracking points (up to 1000 records)
  /// [limit] - jumlah data (default: 100, max: 1000)
  /// [scheduleId] - filter berdasarkan schedule ID
  /// [userId] - filter berdasarkan user ID
  Future<List<Tracking>> getLatestTracking({
    int limit = 100,
    int? scheduleId,
    int? userId,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit > 1000 ? 1000 : limit, // Max 1000 as per API spec
        if (scheduleId != null) 'schedule_id': scheduleId,
        if (userId != null) 'user_id': userId,
      };

      final response = await _api.getJson(ApiRoutes.trackings, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => Tracking.fromMap(item)).toList();
      }

      throw Exception('Failed to load tracking data');
    } catch (e) {
      print('❌ Failed to get tracking data: $e');
      rethrow;
    }
  }

  /// Get tracking history for specific schedule (last 200 points)
  Future<List<Tracking>> getTrackingBySchedule(int scheduleId) async {
    try {
      final response = await _api.get(ApiRoutes.trackingBySchedule(scheduleId));
      
      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => Tracking.fromMap(item)).toList();
      }

      throw Exception('Failed to load tracking history for schedule $scheduleId');
    } catch (e) {
      print('❌ Failed to get tracking history for schedule $scheduleId: $e');
      rethrow;
    }
  }

  /// Record new tracking point (requires mitra role)
  Future<Tracking> recordTracking({
    required int scheduleId,
    required double latitude,
    required double longitude,
    String? address,
    String? status,
    String? notes,
    DateTime? timestamp,
  }) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can record tracking

      final requestData = {
        'schedule_id': scheduleId,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
        'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      };

      final response = await _api.postJson(ApiRoutes.trackings, requestData);
      
      if (response != null && response['success'] == true) {
        return Tracking.fromMap(response['data']);
      }

      throw Exception('Failed to record tracking');
    } catch (e) {
      print('❌ Failed to record tracking: $e');
      rethrow;
    }
  }

  /// Start tracking session for schedule
  Future<Tracking> startTracking({
    required int scheduleId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    return await recordTracking(
      scheduleId: scheduleId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: 'started',
      notes: 'Tracking dimulai',
    );
  }

  /// Update tracking during journey
  Future<Tracking> updateTracking({
    required int scheduleId,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
  }) async {
    return await recordTracking(
      scheduleId: scheduleId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: 'in_progress',
      notes: notes,
    );
  }

  /// Stop tracking session
  Future<Tracking> stopTracking({
    required int scheduleId,
    required double latitude,
    required double longitude,
    String? address,
    String? reason,
  }) async {
    return await recordTracking(
      scheduleId: scheduleId,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: 'completed',
      notes: reason ?? 'Tracking selesai',
    );
  }

  /// Get real-time tracking for schedule (for end_user to monitor)
  Stream<List<Tracking>> watchTrackingBySchedule(int scheduleId) async* {
    while (true) {
      try {
        final trackingList = await getTrackingBySchedule(scheduleId);
        yield trackingList;
        
        // Wait 10 seconds before next update
        await Future.delayed(const Duration(seconds: 10));
      } catch (e) {
        print('❌ Error in tracking stream: $e');
        yield [];
        await Future.delayed(const Duration(seconds: 30)); // Longer delay on error
      }
    }
  }

  /// Calculate distance between two points (in kilometers)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).abs() * (dLat / 2).abs() +
        (lat1 * 3.14159 / 180).abs() * (lat2 * 3.14159 / 180).abs() * 
        (dLon / 2).abs() * (dLon / 2).abs();
    
    final double c = 2 * (a.abs()).abs();
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.14159 / 180;
  }

  /// Calculate total distance traveled from tracking points
  double calculateTotalDistance(List<Tracking> trackingPoints) {
    if (trackingPoints.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    
    for (int i = 1; i < trackingPoints.length; i++) {
      final prev = trackingPoints[i - 1];
      final current = trackingPoints[i];
      
      totalDistance += calculateDistance(
        prev.latitude,
        prev.longitude,
        current.latitude,
        current.longitude,
      );
    }
    
    return totalDistance;
  }

  /// Get tracking status options
  List<String> getStatusOptions() {
    return ['started', 'in_progress', 'paused', 'completed', 'cancelled'];
  }

  /// Check if user can record tracking
  bool canRecordTracking() {
    return _authManager.isAuthenticated && _authManager.isMitra;
  }

  /// Check if user can view tracking
  bool canViewTracking() {
    return _authManager.isAuthenticated; // All authenticated users can view
  }

  /// Get last known position for schedule
  Future<Tracking?> getLastPosition(int scheduleId) async {
    try {
      final trackingList = await getTrackingBySchedule(scheduleId);
      return trackingList.isNotEmpty ? trackingList.first : null;
    } catch (e) {
      print('❌ Failed to get last position for schedule $scheduleId: $e');
      return null;
    }
  }

  /// Check if schedule is currently being tracked
  Future<bool> isScheduleBeingTracked(int scheduleId) async {
    try {
      final lastPosition = await getLastPosition(scheduleId);
      if (lastPosition == null) return false;
      
      // Consider as being tracked if last update was within 5 minutes
      final now = DateTime.now();
      final lastUpdate = lastPosition.timestamp;
      final difference = now.difference(lastUpdate).inMinutes;
      
      return difference <= 5 && 
             (lastPosition.status == 'started' || lastPosition.status == 'in_progress');
    } catch (e) {
      print('❌ Failed to check if schedule $scheduleId is being tracked: $e');
      return false;
    }
  }
}