import 'package:flutter/material.dart';
import 'package:bank_sha/utils/app_config.dart';

/// Model untuk Mitra Pickup Schedule
class MitraPickupSchedule {
  final int id;
  final int userId;
  final String userName;
  final String userPhone;
  final String pickupAddress;
  final double latitude;
  final double longitude;
  final String scheduleDay;
  final String wasteTypeScheduled;
  final String? userWasteTypes; // NEW: Semua jenis sampah yang user input
  final Map<String, dynamic>? estimatedWeights; // NEW: Estimasi berat per jenis
  final DateTime scheduledPickupAt;
  final String pickupTimeStart;
  final String pickupTimeEnd;
  final String wasteSummary;
  final String? notes;
  final String status; // pending, on_progress, completed
  final DateTime createdAt;
  final int? assignedMitraId;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? actualWeights;
  final double? totalWeight;
  final List<String>? pickupPhotos;

  MitraPickupSchedule({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
    required this.scheduleDay,
    required this.wasteTypeScheduled,
    this.userWasteTypes, // NEW: Optional
    this.estimatedWeights, // NEW: Optional
    required this.scheduledPickupAt,
    required this.pickupTimeStart,
    required this.pickupTimeEnd,
    required this.wasteSummary,
    this.notes,
    required this.status,
    required this.createdAt,
    this.assignedMitraId,
    this.assignedAt,
    this.completedAt,
    this.actualWeights,
    this.totalWeight,
    this.pickupPhotos,
  });

  /// Helper method untuk parse double dari berbagai format
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Helper method untuk normalize actual_weights dari berbagai format
  /// Backend kadang kirim format berbeda:
  /// - {"Kaca": "1.0", "Logam": "1.0"} (object dengan string values)
  /// - [{"type": "B3", "weight": 3.2}] (array of objects)
  /// Normalize ke format object dengan numeric values
  static Map<String, dynamic>? _normalizeActualWeights(dynamic value) {
    if (value == null) return null;

    // Jika sudah Map, pastikan values adalah numbers
    if (value is Map) {
      final normalized = <String, dynamic>{};
      value.forEach((key, val) {
        normalized[key.toString()] = _parseDouble(val) ?? 0.0;
      });
      return normalized;
    }

    // Jika Array, convert ke Map
    if (value is List) {
      final normalized = <String, dynamic>{};
      for (var item in value) {
        if (item is Map &&
            item.containsKey('type') &&
            item.containsKey('weight')) {
          final type = item['type'].toString();
          final weight = _parseDouble(item['weight']) ?? 0.0;
          normalized[type] = weight;
        }
      }
      return normalized.isNotEmpty ? normalized : null;
    }

    return null;
  }

  /// Convert relative path to full URL if needed
  static String _normalizePhotoUrl(String path, String apiBaseUrl) {
    // If already full URL, return as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Remove leading slash if exists
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // Combine with base URL
    return '$apiBaseUrl/$cleanPath';
  }

  factory MitraPickupSchedule.fromJson(Map<String, dynamic> json) {
    // Get API base URL from app config
    final apiBaseUrl = AppConfig.apiBaseUrl;

    return MitraPickupSchedule(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? json['user']?['name'] ?? '',
      userPhone: json['user_phone'] ?? json['user']?['phone'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      scheduleDay: json['schedule_day'] ?? '',
      wasteTypeScheduled: json['waste_type_scheduled'] ?? '',
      userWasteTypes: json['user_waste_types'], // NEW: Parse user's waste types
      estimatedWeights: json['estimated_weights'] != null
          ? Map<String, dynamic>.from(json['estimated_weights'])
          : null, // NEW: Parse estimated weights
      scheduledPickupAt: json['scheduled_pickup_at'] != null
          ? DateTime.parse(json['scheduled_pickup_at'])
          : DateTime.now(),
      pickupTimeStart: json['pickup_time_start'] ?? '',
      pickupTimeEnd: json['pickup_time_end'] ?? '',
      wasteSummary: json['waste_summary'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      assignedMitraId: json['assigned_mitra_id'],
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      actualWeights: _normalizeActualWeights(json['actual_weights']),
      totalWeight: _parseDouble(json['total_weight']),
      pickupPhotos: json['pickup_photos'] != null
          ? (json['pickup_photos'] as List)
                .map(
                  (photo) => _normalizePhotoUrl(photo.toString(), apiBaseUrl),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'pickup_address': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'schedule_day': scheduleDay,
      'waste_type_scheduled': wasteTypeScheduled,
      'user_waste_types': userWasteTypes, // NEW
      'estimated_weights': estimatedWeights, // NEW
      'scheduled_pickup_at': scheduledPickupAt.toIso8601String(),
      'pickup_time_start': pickupTimeStart,
      'pickup_time_end': pickupTimeEnd,
      'waste_summary': wasteSummary,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'assigned_mitra_id': assignedMitraId,
      'assigned_at': assignedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'actual_weights': actualWeights,
      'total_weight': totalWeight,
      'pickup_photos': pickupPhotos,
    };
  }

  // Helpers
  bool get isPending => status == 'pending';
  bool get isOnProgress => status == 'on_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'on_progress':
        return 'Dalam Proses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF8C00); // orangeColor
      case 'on_progress':
        return const Color(0xFF53C1F9); // blueColor
      case 'completed':
        return const Color(0xFF00BB38); // greenColor
      case 'cancelled':
        return const Color(0xFFF30303); // redcolor
      default:
        return const Color(0xFFA4A8AE); // greyColor
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'on_progress':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
