import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bank_sha/utils/app_config.dart';

class AdditionalWaste {
  final String type;
  final double estimatedWeight;

  AdditionalWaste({required this.type, required this.estimatedWeight});

  factory AdditionalWaste.fromJson(Map<String, dynamic> json) {
    return AdditionalWaste(
      type: json['type'] ?? '',
      estimatedWeight: MitraPickupSchedule._parseDouble(json['estimated_weight']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'estimated_weight': estimatedWeight,
      };
}

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
  final String scheduledWeight;
  final String? userWasteTypes;
  final Map<String, dynamic>? estimatedWeights;
  final double totalEstimatedWeight;
  final List<AdditionalWaste>? additionalWastes;
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
  final String? wasteImage;
  final String? profilePicture;

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
    required this.scheduledWeight,
    this.userWasteTypes,
    this.estimatedWeights,
    required this.totalEstimatedWeight,
    this.additionalWastes,
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
    this.wasteImage,
    this.profilePicture,
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

  static Map<String, dynamic>? _normalizeEstimatedWeights(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is List) {
      final normalized = <String, dynamic>{};
      for (final item in value) {
        if (item is! Map) continue;

        final type = item['type'] ?? item['waste_type'] ?? item['name'];
        final weight =
            item['estimated_weight'] ?? item['weight'] ?? item['value'];
        if (type == null) continue;

        normalized[type.toString()] = _parseDouble(weight) ?? 0.0;
      }
      return normalized.isNotEmpty ? normalized : null;
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
      try {
        return _normalizeEstimatedWeights(jsonDecode(trimmed));
      } on FormatException {
        return null;
      }
    }

    return null;
  }

  static List<AdditionalWaste>? _normalizeAdditionalWastes(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
      try {
        return _normalizeAdditionalWastes(jsonDecode(trimmed));
      } on FormatException {
        return null;
      }
    }

    if (value is List) {
      final wastes = value.whereType<Map>().map((waste) {
        final payload = Map<String, dynamic>.from(waste);
        if (!payload.containsKey('estimated_weight') &&
            payload.containsKey('weight')) {
          payload['estimated_weight'] = payload['weight'];
        }
        return AdditionalWaste.fromJson(payload);
      }).toList();
      return wastes.isNotEmpty ? wastes : null;
    }

    if (value is Map) {
      if (value.containsKey('type')) {
        final payload = Map<String, dynamic>.from(value);
        if (!payload.containsKey('estimated_weight') &&
            payload.containsKey('weight')) {
          payload['estimated_weight'] = payload['weight'];
        }
        return [AdditionalWaste.fromJson(payload)];
      }

      final wastes = <AdditionalWaste>[];
      for (final child in value.values) {
        final parsed = _normalizeAdditionalWastes(child);
        if (parsed != null) {
          wastes.addAll(parsed);
        }
      }
      return wastes.isNotEmpty ? wastes : null;
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
    final normalizedPath = path.replaceAll('\\', '/').trim();
    if (normalizedPath.isEmpty) return normalizedPath;

    // If already full URL, return as is
    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      return normalizedPath;
    }

    // Remove leading slash if exists
    final cleanPath = normalizedPath.startsWith('/')
        ? normalizedPath.substring(1)
        : normalizedPath;

    // Build URL from origin (scheme + host + port), not full api path.
    // This prevents malformed URLs when apiBaseUrl accidentally includes `/api`.
    final apiUri = Uri.tryParse(apiBaseUrl);
    final origin = (apiUri != null &&
            apiUri.hasScheme &&
            apiUri.host.isNotEmpty &&
            apiUri.authority.isNotEmpty)
        ? '${apiUri.scheme}://${apiUri.authority}'
        : apiBaseUrl;

    // Combine with base URL
    return '$origin/$cleanPath';
  }

  static List<String>? _normalizePickupPhotos(dynamic value, String apiBaseUrl) {
    if (value == null) return null;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return [_normalizePhotoUrl(trimmed, apiBaseUrl)];
      }

      try {
        return _normalizePickupPhotos(jsonDecode(trimmed), apiBaseUrl);
      } on FormatException {
        return [_normalizePhotoUrl(trimmed, apiBaseUrl)];
      }
    }

    if (value is List) {
      final photos = <String>[];
      for (final item in value) {
        if (item is String) {
          photos.add(_normalizePhotoUrl(item, apiBaseUrl));
          continue;
        }

        if (item is Map) {
          final source =
              item['url'] ??
              item['path'] ??
              item['photo'] ??
              item['photo_url'] ??
              item['full_url'];
          if (source != null) {
            photos.add(_normalizePhotoUrl(source.toString(), apiBaseUrl));
          }
        }
      }

      return photos.isNotEmpty ? photos : null;
    }

    if (value is Map) {
      return _normalizePickupPhotos(value.values.toList(), apiBaseUrl);
    }

    return null;
  }

  factory MitraPickupSchedule.fromJson(Map<String, dynamic> json) {
    // Get API base URL from app config
    final apiBaseUrl = AppConfig.apiBaseUrl;

    String? normalizeOptionalPhoto(dynamic value) {
      if (value == null) return null;
      final raw = value.toString().trim();
      if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
      return _normalizePhotoUrl(raw, apiBaseUrl);
    }

    final rawWasteImage =
        json['waste_image'] ??
        json['wasteImage'] ??
        json['waste_image_url'] ??
        json['waste_photo'] ??
        json['photo'] ??
        json['schedule']?['waste_image'] ??
        json['schedule']?['waste_image_url'] ??
        json['pickup_schedule']?['waste_image'];

    final rawProfilePicture =
        json['profile_picture'] ??
        json['profilePicture'] ??
        json['user']?['profile_picture'] ??
        json['user']?['profilePicUrl'];

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
      scheduledWeight: json['scheduled_weight']?.toString() ?? '0.00',
      userWasteTypes: json['user_waste_types'],
      estimatedWeights: _normalizeEstimatedWeights(json['estimated_weights']),
      totalEstimatedWeight: _parseDouble(json['total_estimated_weight']) ?? 0.0,
      additionalWastes: _normalizeAdditionalWastes(
        json['additional_wastes'] ?? json['additional_waste'],
      ),
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
      pickupPhotos: _normalizePickupPhotos(
        json['pickup_photos'] ?? json['photos'],
        apiBaseUrl,
      ),
      wasteImage: normalizeOptionalPhoto(rawWasteImage),
      profilePicture: normalizeOptionalPhoto(rawProfilePicture),
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
      'scheduled_weight': scheduledWeight,
      'user_waste_types': userWasteTypes,
      'estimated_weights': estimatedWeights,
      'total_estimated_weight': totalEstimatedWeight,
      'additional_wastes': additionalWastes?.map((w) => w.toJson()).toList(),
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
      'waste_image': wasteImage,
      'profile_picture': profilePicture,
    };
  }

  // Helpers
  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isAccepted => status == 'accepted';
  bool get isOnProgress => status == 'on_progress';
  bool get isOnTheWay => status == 'on_the_way';
  bool get isArrived => status == 'arrived';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'assigned':
        return 'Ditugaskan';
      case 'accepted':
        return 'Diterima';
      case 'on_the_way':
        return 'Menuju Lokasi';
      case 'arrived':
        return 'Sudah Sampai';
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
      case 'assigned':
        return const Color(0xFF00BB38); // greenColor
      case 'accepted':
        return const Color(0xFF00BB38); // greenColor
      case 'on_the_way':
        return const Color(0xFF53C1F9); // blueColor
      case 'arrived':
        return const Color(0xFF9C27B0); // purpleColor
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
      case 'assigned':
        return Icons.assignment_turned_in_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'on_the_way':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
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
