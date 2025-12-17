import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk handle GPS location tracking
/// - Request permissions
/// - Get current position
/// - Background tracking untuk Mitra
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Timer? _trackingTimer;
  bool _isTracking = false;
  Position? _lastKnownPosition;

  /// Callback untuk kirim lokasi ke server
  Function(Position)? onLocationUpdate;

  /// Check apakah GPS service enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    // Check jika service enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Service disabled, minta user enable
      return false;
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied permanently
      // Buka app settings
      await openAppSettings();
      return false;
    }

    // Request background permission untuk Android 10+
    if (await Permission.locationAlways.isDenied) {
      final status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        print('⚠️ Background location permission denied');
      }
    }

    return true;
  }

  /// Get current position (one-time)
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        print('❌ Location permission not granted');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      return _lastKnownPosition; // Return last known if available
    }
  }

  /// Start periodic location tracking (untuk Mitra saat on_the_way)
  /// Update setiap [intervalSeconds] detik (default 15 detik)
  Future<bool> startTracking({
    int intervalSeconds = 15,
    required Function(Position) onUpdate,
  }) async {
    if (_isTracking) {
      print('⚠️ Tracking already running');
      return true;
    }

    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      print('❌ Cannot start tracking: No permission');
      return false;
    }

    onLocationUpdate = onUpdate;
    _isTracking = true;

    print('✅ Starting GPS tracking (interval: ${intervalSeconds}s)');

    // Get initial position
    Position? initialPosition = await getCurrentPosition();
    if (initialPosition != null) {
      onUpdate(initialPosition);
    }

    // Start periodic tracking
    _trackingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (
      timer,
    ) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );

        _lastKnownPosition = position;

        // Call callback untuk kirim ke server
        onLocationUpdate?.call(position);

        print(
          '📍 Location updated: ${position.latitude}, ${position.longitude}',
        );
      } catch (e) {
        print('❌ Error in tracking loop: $e');

        // Jika error, coba gunakan last known position
        if (_lastKnownPosition != null) {
          onLocationUpdate?.call(_lastKnownPosition!);
        }
      }
    });

    return true;
  }

  /// Stop tracking
  void stopTracking() {
    if (_trackingTimer != null) {
      _trackingTimer!.cancel();
      _trackingTimer = null;
      _isTracking = false;
      onLocationUpdate = null;
      print('🛑 GPS tracking stopped');
    }
  }

  /// Check jika sedang tracking
  bool get isTracking => _isTracking;

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Calculate distance between two coordinates (Haversine formula)
  /// Returns distance in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Convert to km
  }

  /// Calculate ETA based on distance
  /// Assumes average speed of 30 km/h (Jakarta traffic)
  int calculateETA(double distanceKm, {double averageSpeedKmh = 30}) {
    if (distanceKm <= 0) return 0;
    double hours = distanceKm / averageSpeedKmh;
    int minutes = (hours * 60).round();
    return minutes;
  }

  /// Format coordinates untuk display
  String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Dispose
  void dispose() {
    stopTracking();
  }
}
