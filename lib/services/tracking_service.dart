import 'dart:async';
import 'package:bank_sha/services/tracking_api_service.dart';
import 'package:latlong2/latlong.dart';

/// Model Tracking untuk digunakan di UI
class Tracking {
  final int id;
  final int scheduleId;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  Tracking({
    required this.id,
    required this.scheduleId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      id: json['id'] as int,
      scheduleId: json['schedule_id'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(
        json['recorded_at'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  LatLng get position => LatLng(latitude, longitude);
}

/// Service untuk tracking yang menggunakan TrackingApiService
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final TrackingApiService _api = TrackingApiService();
  final _historyController = StreamController<List<Tracking>>.broadcast();

  Stream<List<Tracking>> get historyStream => _historyController.stream;

  /// Post location tracking
  Future<void> postLocation({
    required int scheduleId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    DateTime? recordedAt,
  }) async {
    await _api.postLocation(
      scheduleId: scheduleId,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      heading: heading,
      recordedAt: recordedAt,
    );
  }

  /// Get tracking history
  Future<List<Tracking>> getHistory({
    required int scheduleId,
    int limit = 200,
    DateTime? since,
    DateTime? until,
  }) async {
    try {
      final data = await _api.getHistory(
        scheduleId: scheduleId,
        limit: limit,
        since: since,
        until: until,
      );

      final trackings = data.map((json) => Tracking.fromJson(json)).toList();

      // Emit to stream
      _historyController.add(trackings);

      return trackings;
    } catch (e) {
      _historyController.addError(e);
      rethrow;
    }
  }

  /// Stream tracking history with periodic updates
  Stream<List<Tracking>> streamHistory({
    required int scheduleId,
    Duration interval = const Duration(seconds: 5),
    int limit = 200,
  }) async* {
    while (true) {
      try {
        final trackings = await getHistory(
          scheduleId: scheduleId,
          limit: limit,
        );
        yield trackings;
      } catch (e) {
        print('Error streaming tracking history: $e');
      }
      await Future.delayed(interval);
    }
  }

  /// Watch tracking by schedule (alias for streamHistory)
  Stream<List<Tracking>> watchTrackingBySchedule(int scheduleId) {
    return streamHistory(scheduleId: scheduleId);
  }

  void dispose() {
    _historyController.close();
  }
}
