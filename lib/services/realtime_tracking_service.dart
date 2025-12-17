import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_sha/models/tracking/tracking_models.dart';
import 'package:bank_sha/utils/app_config.dart';
import 'package:logger/logger.dart';

/// Service untuk menangani real-time GPS tracking antara Mitra dan User
///
/// Features:
/// - Mitra: Send location every 10 seconds
/// - User: Poll location every 5 seconds
/// - Automatic start/stop tracking
/// - Battery level monitoring
class RealTimeTrackingService {
  RealTimeTrackingService._internal();
  static final RealTimeTrackingService _instance =
      RealTimeTrackingService._internal();
  factory RealTimeTrackingService() => _instance;

  final Logger _logger = Logger();
  Timer? _trackingTimer;
  bool _isTracking = false;
  int? _currentPickupScheduleId;

  // Base URL from AppConfig
  String get _baseUrl => AppConfig.apiBaseUrl;

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // MITRA: SEND LOCATION UPDATES
  // ==========================================

  /// Start tracking - Mitra mengirim lokasi setiap 10 detik
  Future<void> startMitraTracking(int pickupScheduleId) async {
    if (_isTracking) {
      _logger.i(
        'Tracking sudah berjalan untuk pickup schedule: $_currentPickupScheduleId',
      );
      return;
    }

    _currentPickupScheduleId = pickupScheduleId;
    _isTracking = true;

    _logger.i('🚀 Start Mitra tracking for pickup schedule: $pickupScheduleId');

    // Kirim lokasi pertama kali langsung
    await _sendMitraLocation(pickupScheduleId);

    // Kemudian kirim setiap 10 detik
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_isTracking) {
        await _sendMitraLocation(pickupScheduleId);
      }
    });
  }

  /// Send current location to backend
  Future<MitraLocationUpdateResponse?> _sendMitraLocation(
    int pickupScheduleId,
  ) async {
    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _logger.e('❌ Location permission denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      // Convert speed from m/s to km/h
      final speedKmh = position.speed > 0 ? position.speed * 3.6 : null;

      // Prepare request
      final request = MitraLocationUpdateRequest(
        pickupScheduleId: pickupScheduleId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: speedKmh,
        heading: position.heading,
        // batteryLevel: await _getBatteryLevel(), // Optional: implement battery level
      );

      // Send to backend
      final url = Uri.parse('$_baseUrl/api/mitra/tracking/update-location');
      final headers = await _getHeaders();

      _logger.d(
        '📍 Sending location: ${position.latitude}, ${position.longitude}',
      );

      final response = await http
          .post(url, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = MitraLocationUpdateResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.i(
          '✅ Location updated: Distance ${result.data?.trackingInfo.distanceKm} km, ETA ${result.data?.trackingInfo.etaMinutes} min',
        );

        return result;
      } else {
        _logger.e(
          '❌ Failed to update location: ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Error sending location', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Stop tracking
  Future<void> stopMitraTracking(int pickupScheduleId) async {
    if (!_isTracking) {
      _logger.w('⚠️ Tracking sudah tidak aktif');
      return;
    }

    _logger.i('🛑 Stop Mitra tracking for pickup schedule: $pickupScheduleId');

    // Cancel timer
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _currentPickupScheduleId = null;

    // Notify backend
    try {
      final url = Uri.parse('$_baseUrl/api/mitra/tracking/stop');
      final headers = await _getHeaders();

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({'pickup_schedule_id': pickupScheduleId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _logger.i('✅ Tracking stopped successfully');
      } else {
        _logger.e('❌ Failed to stop tracking: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error stopping tracking: $e');
    }
  }

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Get current pickup schedule ID being tracked
  int? get currentPickupScheduleId => _currentPickupScheduleId;

  // ==========================================
  // USER: GET TRACKING INFO
  // ==========================================

  /// Get real-time tracking info (untuk User)
  /// Polling every 5 seconds recommended
  Future<TrackingInfoModel?> getUserTrackingInfo(int pickupScheduleId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/user/tracking/$pickupScheduleId');
      final headers = await _getHeaders();

      _logger.d('📡 Fetching tracking info for pickup: $pickupScheduleId');
      _logger.d('   URL: $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      _logger.d('📥 Response status: ${response.statusCode}');
      _logger.d('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final trackingInfo = TrackingInfoModel.fromJson(json);

          _logger.i('✅ Tracking info retrieved successfully');
          _logger.d(
            '   📍 Distance: ${trackingInfo.trackingInfo.formattedDistance}',
          );
          _logger.d('   ⏱️  ETA: ${trackingInfo.trackingInfo.formattedEta}');
          _logger.d(
            '   🔄 Location stale: ${trackingInfo.mitraLocation.isStale}',
          );
          _logger.d('   👤 Mitra: ${trackingInfo.mitraInfo.name}');

          return trackingInfo;
        } else {
          _logger.w('⚠️ Tracking info failed: ${json['message']}');
          return null;
        }
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.w('⚠️ Tracking not available: ${json['message']}');
        _logger.d('   Error code: ${json['error_code']}');
        return null;
      } else if (response.statusCode == 403) {
        _logger.e('❌ Unauthorized: This schedule does not belong to you');
        return null;
      } else if (response.statusCode == 404) {
        _logger.w('⚠️ Schedule not found');
        return null;
      } else {
        _logger.e('❌ Failed to get tracking info: ${response.statusCode}');
        _logger.e('   Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error getting tracking info',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get tracking history (for completed pickups)
  Future<TrackingHistoryModel?> getTrackingHistory(int pickupScheduleId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/user/tracking/$pickupScheduleId/history',
      );
      final headers = await _getHeaders();

      _logger.d('📜 Fetching tracking history for pickup: $pickupScheduleId');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final history = TrackingHistoryModel.fromJson(json);

          _logger.i(
            '✅ Tracking history: ${history.totalPoints} points, '
            'Duration: ${history.formattedDuration}',
          );

          return history;
        } else {
          _logger.w('⚠️ Tracking history failed: ${json['message']}');
          return null;
        }
      } else {
        _logger.e('❌ Failed to get tracking history: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error getting tracking history',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position (one-time)
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkLocationPermission();

      if (permission == LocationPermission.denied) {
        final newPermission = await requestLocationPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          _logger.e('❌ Location permission denied');
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _logger.e('❌ Error getting current position: $e');
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _currentPickupScheduleId = null;
  }
}
