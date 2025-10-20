import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/models/tracking_model.dart';

/// Complete Tracking Service - Real-time GPS Tracking
///
/// Features:
/// - Create tracking (POST /api/trackings)
/// - Update tracking (PUT /api/trackings/{id})
/// - Delete tracking (DELETE /api/trackings/{id})
/// - Get trackings list (GET /api/trackings)
/// - Get tracking by ID (GET /api/trackings/{id})
/// - Real-time GPS position streaming
/// - Start/Stop tracking sessions
///
/// Use Cases:
/// - Mitra sends GPS location while on duty
/// - User sees real-time mitra position
/// - System tracking for audit trail
class TrackingServiceComplete {
  final ApiClient _apiClient = ApiClient();

  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _trackingTimer;
  bool _isTracking = false;

  /// Check if GPS tracking is currently active
  bool get isTracking => _isTracking;

  // ========================================
  // CRUD Operations
  // ========================================

  /// Create a new tracking record (GPS position)
  ///
  /// POST /api/trackings
  ///
  /// Parameters:
  /// - [orderId]: ID of the order being tracked
  /// - [mitraId]: ID of the mitra providing the service
  /// - [latitude]: GPS latitude (-90 to 90, DECIMAL 10,7)
  /// - [longitude]: GPS longitude (-180 to 180, DECIMAL 10,7)
  /// - [speed]: Speed in km/h (optional, DECIMAL 8,2)
  /// - [heading]: Heading/bearing in degrees 0-360 (optional, DECIMAL 5,2)
  /// - [accuracy]: GPS accuracy in meters (optional)
  ///
  /// Returns: Created Tracking object
  ///
  /// Example:
  /// ```dart
  /// final tracking = await trackingService.createTracking(
  ///   orderId: 123,
  ///   mitraId: 456,
  ///   latitude: -6.1897999,
  ///   longitude: 106.8666999,
  ///   speed: 35.5,
  ///   heading: 45.0,
  ///   accuracy: 10.5,
  /// );
  /// ```
  Future<TrackingModel> createTracking({
    required int orderId,
    required int mitraId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    try {
      // Validate coordinates
      if (latitude < -90 || latitude > 90) {
        throw ArgumentError('Latitude must be between -90 and 90');
      }
      if (longitude < -180 || longitude > 180) {
        throw ArgumentError('Longitude must be between -180 and 180');
      }
      if (heading != null && (heading < 0 || heading > 360)) {
        throw ArgumentError('Heading must be between 0 and 360');
      }

      final body = {
        'order_id': orderId,
        'mitra_id': mitraId,
        'latitude': latitude,
        'longitude': longitude,
        if (speed != null) 'speed': speed,
        if (heading != null) 'heading': heading,
        if (accuracy != null) 'accuracy': accuracy,
      };

      print('📍 Creating tracking: Order #$orderId, Mitra #$mitraId');
      print('   Location: ($latitude, $longitude)');

      final response = await _apiClient.postJson(
        '/api/tracking',
        body,
      ); // FIXED: /trackings → /tracking

      print('✅ Tracking created successfully');
      return TrackingModel.fromJson(response['data']);
    } catch (e) {
      print('❌ Error creating tracking: $e');
      rethrow;
    }
  }

  /// Update existing tracking record
  ///
  /// ⚠️ NOT SUPPORTED BY BACKEND - This method will be removed
  /// Backend only supports: GET /api/tracking and POST /api/tracking
  ///
  /// Parameters:
  /// - [id]: Tracking ID to update
  /// - Other parameters same as createTracking (all optional)
  ///
  /// Returns: Updated Tracking object
  @Deprecated(
    'Backend does not support PUT /api/tracking/{id}. Use createTracking() instead.',
  )
  Future<TrackingModel> updateTracking(
    int id, {
    double? latitude,
    double? longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    throw UnimplementedError(
      'Update tracking is not supported by backend API. '
      'Please create a new tracking record instead using createTracking().',
    );
  }

  /// Delete tracking record
  ///
  /// ⚠️ NOT SUPPORTED BY BACKEND - This method will be removed
  /// Backend only supports: GET /api/tracking and POST /api/tracking
  ///
  /// Parameters:
  /// - [id]: Tracking ID to delete
  @Deprecated('Backend does not support DELETE /api/tracking/{id}')
  Future<void> deleteTracking(int id) async {
    throw UnimplementedError(
      'Delete tracking is not supported by backend API.',
    );
  }

  /// Get list of tracking records
  ///
  /// GET /api/tracking (FIXED: was /trackings)
  ///
  /// Parameters:
  /// - [orderId]: Filter by order ID
  /// - [mitraId]: Filter by mitra ID
  /// - [scheduleId]: Filter by schedule ID
  /// - [limit]: Max number of items to return
  ///
  /// Returns: List of Tracking objects
  Future<List<TrackingModel>> getTrackings({
    int? orderId,
    int? mitraId,
    int? scheduleId,
    int? limit,
  }) async {
    try {
      final query = <String, dynamic>{};

      if (orderId != null) query['order_id'] = orderId;
      if (mitraId != null) query['mitra_id'] = mitraId;
      if (scheduleId != null) query['schedule_id'] = scheduleId;
      if (limit != null) query['limit'] = limit;

      print('📍 Getting trackings (filters: $query)');

      final response = await _apiClient.getJson(
        '/api/tracking',
        query: query,
      ); // FIXED: /trackings → /tracking

      final List<dynamic> data = response['data'] ?? [];
      final trackings = data
          .map((json) => TrackingModel.fromJson(json))
          .toList();

      print('✅ Found ${trackings.length} trackings');
      return trackings;
    } catch (e) {
      print('❌ Error getting trackings: $e');
      rethrow;
    }
  }

  /// Get tracking by schedule ID
  ///
  /// GET /api/tracking/schedule/{scheduleId} (FIXED: was /trackings/{id})
  ///
  /// Parameters:
  /// - [id]: Tracking ID
  ///
  /// Returns: Tracking object
  /// Get tracking by schedule ID
  ///
  /// GET /api/tracking/schedule/{scheduleId} (FIXED PATH)
  ///
  /// Parameters:
  /// - [scheduleId]: Schedule ID
  ///
  /// Returns: List of Tracking objects for that schedule
  Future<List<TrackingModel>> getTrackingByScheduleId(int scheduleId) async {
    try {
      print('📍 Getting tracking for schedule #$scheduleId');

      final response = await _apiClient.get(
        '/api/tracking/schedule/$scheduleId',
      ); // FIXED

      final List<dynamic> data = response['data'] ?? [];
      final trackings = data
          .map((json) => TrackingModel.fromJson(json))
          .toList();

      print('✅ Found ${trackings.length} tracking records');
      return trackings;
    } catch (e) {
      print('❌ Error getting tracking by schedule: $e');
      rethrow;
    }
  }

  /// Get tracking by ID (DEPRECATED)
  @Deprecated(
    'Use getTrackingByScheduleId() - backend uses schedule-based tracking',
  )
  Future<TrackingModel> getTrackingById(int id) async {
    final trackings = await getTrackingByScheduleId(id);
    return trackings.isNotEmpty
        ? trackings.first
        : throw Exception('No tracking found');
  }

  // ========================================
  // Real-time GPS Tracking
  // ========================================

  /// Start real-time GPS tracking for an order
  ///
  /// This will:
  /// 1. Request GPS permissions
  /// 2. Start listening to position updates
  /// 3. Automatically send position to server every interval
  ///
  /// Parameters:
  /// - [orderId]: Order ID to track
  /// - [mitraId]: Mitra ID providing the service
  /// - [intervalSeconds]: How often to send updates (default: 10 seconds)
  /// - [onPositionUpdate]: Callback when position is updated
  /// - [onError]: Callback when error occurs
  ///
  /// Example:
  /// ```dart
  /// await trackingService.startTracking(
  ///   orderId: 123,
  ///   mitraId: 456,
  ///   intervalSeconds: 10,
  ///   onPositionUpdate: (tracking) {
  ///     print('Position updated: ${tracking.latitude}, ${tracking.longitude}');
  ///   },
  ///   onError: (error) {
  ///     print('Tracking error: $error');
  ///   },
  /// );
  /// ```
  Future<void> startTracking({
    required int orderId,
    required int mitraId,
    int intervalSeconds = 10,
    Function(TrackingModel)? onPositionUpdate,
    Function(dynamic)? onError,
  }) async {
    try {
      // Check if already tracking
      if (_isTracking) {
        print('⚠️ Tracking already active');
        return;
      }

      print('🚀 Starting GPS tracking for Order #$orderId');

      // Check GPS permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          throw Exception('GPS permission denied');
        }
      }

      // Check if GPS is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS service is disabled');
      }

      _isTracking = true;

      // Start position stream with high accuracy
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) async {
              try {
                // Send position to server
                final tracking = await createTracking(
                  orderId: orderId,
                  mitraId: mitraId,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  speed: position.speed * 3.6, // m/s to km/h
                  heading: position.heading,
                  accuracy: position.accuracy,
                );

                // Call callback
                onPositionUpdate?.call(tracking);

                print(
                  '📍 Position sent: (${position.latitude}, ${position.longitude})',
                );
              } catch (e) {
                print('❌ Error sending position: $e');
                onError?.call(e);
              }
            },
            onError: (error) {
              print('❌ GPS stream error: $error');
              onError?.call(error);
            },
          );

      print('✅ GPS tracking started (interval: ${intervalSeconds}s)');
    } catch (e) {
      _isTracking = false;
      print('❌ Error starting tracking: $e');
      onError?.call(e);
      rethrow;
    }
  }

  /// Stop GPS tracking
  ///
  /// This will:
  /// 1. Cancel position stream subscription
  /// 2. Stop sending updates to server
  ///
  /// Example:
  /// ```dart
  /// await trackingService.stopTracking();
  /// ```
  Future<void> stopTracking() async {
    try {
      print('🛑 Stopping GPS tracking');

      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      _trackingTimer?.cancel();
      _trackingTimer = null;

      _isTracking = false;

      print('✅ GPS tracking stopped');
    } catch (e) {
      print('❌ Error stopping tracking: $e');
      rethrow;
    }
  }

  /// Get current GPS position once (without starting tracking)
  ///
  /// Returns: Current Position
  ///
  /// Example:
  /// ```dart
  /// final position = await trackingService.getCurrentPosition();
  /// print('Current location: ${position.latitude}, ${position.longitude}');
  /// ```
  Future<Position> getCurrentPosition() async {
    try {
      print('📍 Getting current position');

      // Check permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          throw Exception('GPS permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        '✅ Position obtained: (${position.latitude}, ${position.longitude})',
      );
      return position;
    } catch (e) {
      print('❌ Error getting position: $e');
      rethrow;
    }
  }

  /// Calculate distance between two GPS coordinates (in meters)
  ///
  /// Parameters:
  /// - [lat1], [lon1]: First coordinate
  /// - [lat2], [lon2]: Second coordinate
  ///
  /// Returns: Distance in meters
  ///
  /// Example:
  /// ```dart
  /// final distance = trackingService.calculateDistance(
  ///   -6.1897999, 106.8666999,
  ///   -6.1907999, 106.8676999,
  /// );
  /// print('Distance: ${distance}m');
  /// ```
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Cleanup - Call this when disposing the service
  void dispose() {
    stopTracking();
  }
}
