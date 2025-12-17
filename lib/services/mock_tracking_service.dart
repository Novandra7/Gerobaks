import 'dart:math';
import 'package:latlong2/latlong.dart';

/// 🎭 Mock Tracking Service
///
/// Service untuk simulasi tracking real-time TANPA backend.
/// Digunakan untuk testing UI tracking ketika backend belum siap.
///
/// Fitur:
/// - User location: Fixed (Jakarta area)
/// - Mitra location: Bergerak mendekati user dengan kecepatan realistis (~30 km/h)
/// - Auto-update: Location mitra berubah setiap kali dipanggil
/// - Distance & ETA: Dihitung otomatis berdasarkan jarak
///
/// Toggle:
/// - const bool USE_MOCK_TRACKING = true;  // Gunakan mock data
/// - const bool USE_MOCK_TRACKING = false; // Gunakan real backend

class MockTrackingService {
  // 🕐 Waktu mulai simulasi (untuk hitung elapsed time)
  static final DateTime _simulationStartTime = DateTime.now();

  // 📍 User location (FIXED) - Jakarta area
  static const double _userLatitude = -6.2088;
  static const double _userLongitude = 106.8456;

  // 📍 Mitra starting location (2 km away from user)
  // Posisi awal: Northeast dari user
  static const double _mitraStartLatitude = -6.1920; // ~2 km north
  static const double _mitraStartLongitude = 106.8600; // ~1.5 km east

  // 🚗 Mitra speed: 30 km/h = 8.33 m/s
  // In degrees: ~0.000075 per second (approximation for equatorial region)
  static const double _mitraSpeedDegreesPerSecond = 0.000075;

  /// 🎲 Generate mock tracking data
  ///
  /// Returns mock data structure yang kompatibel dengan TrackingInfoModel.
  /// Mitra akan bergerak mendekati user dengan kecepatan konstan.
  static Map<String, dynamic> generateMockTrackingData(int scheduleId) {
    // Calculate elapsed time since simulation started
    final elapsed = DateTime.now().difference(_simulationStartTime).inSeconds;

    // 📍 Calculate mitra current position
    // Mitra moves in straight line towards user
    final latDiff = _userLatitude - _mitraStartLatitude;
    final lngDiff = _userLongitude - _mitraStartLongitude;
    final totalDistance = sqrt(latDiff * latDiff + lngDiff * lngDiff);

    // Direction vector (normalized)
    final latDirection = latDiff / totalDistance;
    final lngDirection = lngDiff / totalDistance;

    // Move towards user based on elapsed time
    final distanceTraveled = elapsed * _mitraSpeedDegreesPerSecond;

    // Current mitra position
    double mitraCurrentLat =
        _mitraStartLatitude + (latDirection * distanceTraveled);
    double mitraCurrentLng =
        _mitraStartLongitude + (lngDirection * distanceTraveled);

    // 🎯 Check if mitra has arrived (within 50 meters = ~0.00045 degrees)
    final remainingLat = _userLatitude - mitraCurrentLat;
    final remainingLng = _userLongitude - mitraCurrentLng;
    final remainingDistance = sqrt(
      remainingLat * remainingLat + remainingLng * remainingLng,
    );

    bool hasArrived = remainingDistance < 0.00045; // ~50 meters

    if (hasArrived) {
      // Mitra has arrived - set to user location
      mitraCurrentLat = _userLatitude;
      mitraCurrentLng = _userLongitude;
    }

    // 📏 Calculate distance in km
    final distanceKm = _calculateDistanceKm(
      _userLatitude,
      _userLongitude,
      mitraCurrentLat,
      mitraCurrentLng,
    );

    // ⏱️ Calculate ETA in minutes
    final etaMinutes = hasArrived
        ? 0
        : (distanceKm / 30 * 60).round(); // 30 km/h

    // 📱 Generate mock data structure
    return {
      'success': true,
      'data': {
        'pickup_schedule_id': scheduleId,
        'status': hasArrived ? 'arrived' : 'on_the_way',
        'user_location': {
          'latitude': _userLatitude,
          'longitude': _userLongitude,
          'address': 'Jl. Sudirman Kav. 52-53, Jakarta Selatan',
        },
        'mitra_location': {
          'latitude': mitraCurrentLat,
          'longitude': mitraCurrentLng,
          'last_update': DateTime.now().toIso8601String(),
          'is_stale': false, // Mock data always fresh
        },
        'mitra_info': {
          'id': 999,
          'name': 'Budi Santoso (MOCK)',
          'phone': '081234567890',
          'vehicle_type': 'Motor',
          'vehicle_number': 'B 1234 XYZ',
          'photo_url': null,
          'rating': 4.8,
        },
        'tracking_info': {
          'is_tracking_active': true,
          'distance_km': distanceKm,
          'eta_minutes': etaMinutes,
          'route_polyline': null, // Not used
        },
        'simulation_info': {
          'elapsed_seconds': elapsed,
          'speed_kmh': 30.0,
          'has_arrived': hasArrived,
          'note':
              '🎭 MOCK DATA - Mitra bergerak mendekati user dengan kecepatan 30 km/h',
        },
      },
    };
  }

  /// 📏 Calculate distance between two coordinates in kilometers
  /// Using Haversine formula
  static double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadiusKm * c;
    return double.parse(
      distance.toStringAsFixed(2),
    ); // Round to 2 decimal places
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// 🔄 Reset simulation (restart from beginning)
  static void resetSimulation() {
    // Note: Cannot reset static final DateTime
    // User should restart the app to reset simulation
    print('⚠️ To reset simulation, please restart the app');
  }

  /// 📊 Get simulation status
  static Map<String, dynamic> getSimulationStatus() {
    final elapsed = DateTime.now().difference(_simulationStartTime).inSeconds;
    final elapsedMinutes = (elapsed / 60).toStringAsFixed(1);

    return {
      'simulation_started_at': _simulationStartTime.toIso8601String(),
      'elapsed_seconds': elapsed,
      'elapsed_minutes': elapsedMinutes,
      'user_location': {'latitude': _userLatitude, 'longitude': _userLongitude},
      'mitra_start_location': {
        'latitude': _mitraStartLatitude,
        'longitude': _mitraStartLongitude,
      },
      'speed_kmh': 30.0,
    };
  }
}

/// 🎯 Helper function to parse mock data response
///
/// Usage:
/// ```dart
/// final mockData = MockTrackingService.generateMockTrackingData(scheduleId);
/// final trackingInfo = parseMockTrackingData(mockData);
/// ```
Map<String, dynamic>? parseMockTrackingData(Map<String, dynamic> response) {
  if (response['success'] != true) return null;
  return response['data'];
}
