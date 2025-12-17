/// Model untuk request update lokasi mitra ke API /api/mitra/tracking/update-location
class MitraLocationUpdateRequest {
  final int pickupScheduleId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final int? batteryLevel;

  MitraLocationUpdateRequest({
    required this.pickupScheduleId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.batteryLevel,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'pickup_schedule_id': pickupScheduleId,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (accuracy != null) data['accuracy'] = accuracy;
    if (speed != null) data['speed'] = speed;
    if (heading != null) data['heading'] = heading;
    if (batteryLevel != null) data['battery_level'] = batteryLevel;

    return data;
  }
}

/// Model untuk response dari update lokasi mitra
class MitraLocationUpdateResponse {
  final bool success;
  final String message;
  final MitraLocationUpdateData? data;

  MitraLocationUpdateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MitraLocationUpdateResponse.fromJson(Map<String, dynamic> json) {
    return MitraLocationUpdateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? MitraLocationUpdateData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class MitraLocationUpdateData {
  final int pickupScheduleId;
  final LocationPoint currentLocation;
  final TrackingMetricsData trackingInfo;
  final DateTime updatedAt;

  MitraLocationUpdateData({
    required this.pickupScheduleId,
    required this.currentLocation,
    required this.trackingInfo,
    required this.updatedAt,
  });

  factory MitraLocationUpdateData.fromJson(Map<String, dynamic> json) {
    return MitraLocationUpdateData(
      pickupScheduleId: json['pickup_schedule_id'] as int,
      currentLocation: LocationPoint.fromJson(
        json['current_location'] as Map<String, dynamic>,
      ),
      trackingInfo: TrackingMetricsData.fromJson(
        json['tracking_info'] as Map<String, dynamic>,
      ),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class LocationPoint {
  final double latitude;
  final double longitude;

  LocationPoint({required this.latitude, required this.longitude});

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class TrackingMetricsData {
  final int distanceMeters;
  final double distanceKm;
  final DateTime estimatedArrival;
  final int etaMinutes;

  TrackingMetricsData({
    required this.distanceMeters,
    required this.distanceKm,
    required this.estimatedArrival,
    required this.etaMinutes,
  });

  factory TrackingMetricsData.fromJson(Map<String, dynamic> json) {
    return TrackingMetricsData(
      distanceMeters: json['distance_meters'] as int,
      distanceKm: (json['distance_km'] as num).toDouble(),
      estimatedArrival: DateTime.parse(json['estimated_arrival'] as String),
      etaMinutes: json['eta_minutes'] as int,
    );
  }
}
