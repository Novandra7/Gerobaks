/// Model untuk history tracking dari API /api/user/tracking/{id}/history
class TrackingHistoryModel {
  final int pickupScheduleId;
  final String status;
  final List<TrackingLogModel> trackingLogs;
  final int totalPoints;
  final DateTime? startTime;
  final DateTime? endTime;

  TrackingHistoryModel({
    required this.pickupScheduleId,
    required this.status,
    required this.trackingLogs,
    required this.totalPoints,
    this.startTime,
    this.endTime,
  });

  factory TrackingHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return TrackingHistoryModel(
      pickupScheduleId: data['pickup_schedule_id'] as int,
      status: data['status'] as String,
      trackingLogs: (data['tracking_logs'] as List)
          .map((log) => TrackingLogModel.fromJson(log as Map<String, dynamic>))
          .toList(),
      totalPoints: data['total_points'] as int,
      startTime: data['start_time'] != null
          ? DateTime.parse(data['start_time'] as String)
          : null,
      endTime: data['end_time'] != null
          ? DateTime.parse(data['end_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_schedule_id': pickupScheduleId,
      'status': status,
      'tracking_logs': trackingLogs.map((log) => log.toJson()).toList(),
      'total_points': totalPoints,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }

  Duration? get totalDuration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  String get formattedDuration {
    final duration = totalDuration;
    if (duration == null) return 'N/A';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours jam ${minutes > 0 ? "$minutes menit" : ""}';
    }
    return '$minutes menit';
  }
}

/// Model untuk single tracking log point
class TrackingLogModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  TrackingLogModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  factory TrackingLogModel.fromJson(Map<String, dynamic> json) {
    return TrackingLogModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get formattedSpeed {
    if (speed == null) return 'N/A';
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  String get formattedAccuracy {
    if (accuracy == null) return 'N/A';
    return '±${accuracy!.toStringAsFixed(1)}m';
  }
}
