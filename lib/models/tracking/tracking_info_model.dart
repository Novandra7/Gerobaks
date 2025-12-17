/// Model untuk tracking info lengkap dari API /api/user/tracking/{id}
class TrackingInfoModel {
  final int pickupScheduleId;
  final String status;
  final MitraInfoModel mitraInfo;
  final UserLocationModel userLocation;
  final MitraLocationModel mitraLocation;
  final TrackingMetricsModel trackingInfo;

  TrackingInfoModel({
    required this.pickupScheduleId,
    required this.status,
    required this.mitraInfo,
    required this.userLocation,
    required this.mitraLocation,
    required this.trackingInfo,
  });

  factory TrackingInfoModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return TrackingInfoModel(
      // Support both 'schedule_id' and 'pickup_schedule_id' from backend
      pickupScheduleId:
          (data['schedule_id'] ?? data['pickup_schedule_id']) as int,
      status: data['status'] as String,
      mitraInfo: MitraInfoModel.fromJson(data['mitra_info']),
      userLocation: UserLocationModel.fromJson(data['user_location']),
      mitraLocation: MitraLocationModel.fromJson(data['mitra_location']),
      // Support both 'tracking_info' and 'tracking_metrics' from backend
      trackingInfo: TrackingMetricsModel.fromJson(
        data['tracking_info'] ?? data['tracking_metrics'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_schedule_id': pickupScheduleId,
      'status': status,
      'mitra_info': mitraInfo.toJson(),
      'user_location': userLocation.toJson(),
      'mitra_location': mitraLocation.toJson(),
      'tracking_info': trackingInfo.toJson(),
    };
  }

  bool get isTrackable => status == 'on_the_way' || status == 'arrived';
  bool get hasValidMitraLocation =>
      mitraLocation.latitude != null && mitraLocation.longitude != null;
}

/// Model untuk informasi mitra
class MitraInfoModel {
  final int? id;
  final String name;
  final String phone;
  final String? vehicleNumber;

  MitraInfoModel({
    this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber,
  });

  factory MitraInfoModel.fromJson(Map<String, dynamic> json) {
    return MitraInfoModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Unknown Mitra',
      phone: json['phone'] as String? ?? '',
      vehicleNumber: json['vehicle_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle_number': vehicleNumber,
    };
  }
}

/// Model untuk lokasi user (tujuan pickup)
class UserLocationModel {
  final double latitude;
  final double longitude;
  final String address;

  UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }
}

/// Model untuk lokasi mitra saat ini
class MitraLocationModel {
  final double? latitude;
  final double? longitude;
  final DateTime? lastUpdate;
  final bool isStale;

  MitraLocationModel({
    this.latitude,
    this.longitude,
    this.lastUpdate,
    required this.isStale,
  });

  factory MitraLocationModel.fromJson(Map<String, dynamic> json) {
    return MitraLocationModel(
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'] as String)
          : null,
      isStale: json['is_stale'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'last_update': lastUpdate?.toIso8601String(),
      'is_stale': isStale,
    };
  }

  bool get hasValidLocation => latitude != null && longitude != null;
}

/// Model untuk metrics tracking (jarak, ETA, dll)
class TrackingMetricsModel {
  final int? distanceMeters;
  final double? distanceKm;
  final DateTime? estimatedArrival;
  final int? etaMinutes;

  TrackingMetricsModel({
    this.distanceMeters,
    this.distanceKm,
    this.estimatedArrival,
    this.etaMinutes,
  });

  factory TrackingMetricsModel.fromJson(Map<String, dynamic> json) {
    return TrackingMetricsModel(
      distanceMeters: json['distance_meters'] as int?,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'] as String)
          : null,
      etaMinutes: json['eta_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_meters': distanceMeters,
      'distance_km': distanceKm,
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'eta_minutes': etaMinutes,
    };
  }

  String get formattedDistance {
    if (distanceKm == null) return 'N/A';
    if (distanceKm! < 1) {
      return '${distanceMeters}m';
    }
    return '${distanceKm!.toStringAsFixed(2)} km';
  }

  String get formattedEta {
    if (etaMinutes == null) return 'N/A';
    if (etaMinutes! < 60) {
      return '$etaMinutes menit';
    }
    final hours = etaMinutes! ~/ 60;
    final minutes = etaMinutes! % 60;
    return '$hours jam ${minutes > 0 ? "$minutes menit" : ""}';
  }
}
