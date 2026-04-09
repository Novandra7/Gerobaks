/// Model untuk tracking info lengkap dari API /api/user/tracking/{id}
class TrackingInfoModel {
  final int pickupScheduleId;
  final String status;
  final String? scheduledDate;
  final String? scheduledTime;
  final MitraInfoModel mitraInfo;
  final UserLocationModel userLocation;
  final MitraLocationModel mitraLocation;
  final TrackingMetricsModel trackingInfo;

  TrackingInfoModel({
    required this.pickupScheduleId,
    required this.status,
    this.scheduledDate,
    this.scheduledTime,
    required this.mitraInfo,
    required this.userLocation,
    required this.mitraLocation,
    required this.trackingInfo,
  });

  factory TrackingInfoModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return TrackingInfoModel(
      pickupScheduleId:
          (data['schedule_id'] ?? data['pickup_schedule_id']) as int,
      status: data['status'] as String,
      scheduledDate: data['scheduled_date'] as String?,
      scheduledTime: data['scheduled_time'] as String?,
      mitraInfo: MitraInfoModel.fromJson(data['mitra'] ?? data['mitra_info'] ?? {}),
      userLocation: UserLocationModel.fromJson(data['user_location'] ?? {}),
      mitraLocation: MitraLocationModel.fromJson(data['mitra_location'] ?? {}),
      trackingInfo: TrackingMetricsModel.fromJson(data),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': pickupScheduleId,
      'status': status,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'mitra': mitraInfo.toJson(),
      'user_location': userLocation.toJson(),
      'mitra_location': mitraLocation.toJson(),
      'distance_km': trackingInfo.distanceKm,
      'distance_meters': trackingInfo.distanceMeters,
      'estimated_arrival_minutes': trackingInfo.estimatedArrivalMinutes,
      'estimated_arrival_time': trackingInfo.estimatedArrivalTime,
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
  final String? vehiclePlate;
  final String? photo;

  MitraInfoModel({
    this.id,
    required this.name,
    required this.phone,
    this.vehiclePlate,
    this.photo,
  });

  factory MitraInfoModel.fromJson(Map<String, dynamic> json) {
    return MitraInfoModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Unknown Mitra',
      phone: json['phone'] as String? ?? '',
      vehiclePlate: json['vehicle_plate'] as String?,
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle_plate': vehiclePlate,
      'photo': photo,
    };
  }
}

/// Model untuk lokasi user (tujuan pickup)
class UserLocationModel {
  final double? latitude;
  final double? longitude;
  final String address;

  UserLocationModel({
    this.latitude,
    this.longitude,
    required this.address,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      address: json['address'] as String? ?? 'Alamat tidak tersedia',
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }

  bool get hasValidLocation => latitude != null && longitude != null;
}

/// Model untuk lokasi mitra saat ini
class MitraLocationModel {
  final double? latitude;
  final double? longitude;
  final DateTime? lastUpdate;
  final bool isActive;

  MitraLocationModel({
    this.latitude,
    this.longitude,
    this.lastUpdate,
    required this.isActive,
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
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'last_update': lastUpdate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get hasValidLocation => latitude != null && longitude != null;
  bool get isStale => !isActive;
}

/// Model untuk metrics tracking (jarak, ETA, dll)
class TrackingMetricsModel {
  final int? distanceMeters;
  final double? distanceKm;
  final num? estimatedArrivalMinutes;
  final String? estimatedArrivalTime;

  TrackingMetricsModel({
    this.distanceMeters,
    this.distanceKm,
    this.estimatedArrivalMinutes,
    this.estimatedArrivalTime,
  });

  factory TrackingMetricsModel.fromJson(Map<String, dynamic> json) {
    return TrackingMetricsModel(
      distanceMeters: json['distance_meters'] as int?,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      estimatedArrivalMinutes: json['estimated_arrival_minutes'] as num?,
      estimatedArrivalTime: json['estimated_arrival_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_meters': distanceMeters,
      'distance_km': distanceKm,
      'estimated_arrival_minutes': estimatedArrivalMinutes,
      'estimated_arrival_time': estimatedArrivalTime,
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
    if (estimatedArrivalMinutes == null) return 'N/A';
    if (estimatedArrivalMinutes! < 60) {
      return '${estimatedArrivalMinutes!.toStringAsFixed(1)} menit';
    }
    final hours = estimatedArrivalMinutes! ~/ 60;
    final minutes = estimatedArrivalMinutes! % 60;
    return '$hours jam ${minutes > 0 ? "${minutes.toStringAsFixed(1)} menit" : ""}';
  }

  // Backward compatibility
  double? get etaMinutes => estimatedArrivalMinutes?.toDouble();
  DateTime? get estimatedArrival => estimatedArrivalTime != null
      ? DateTime.tryParse(estimatedArrivalTime!)
      : null;
}
