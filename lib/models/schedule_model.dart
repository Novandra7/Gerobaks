import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/models/waste_item.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ScheduleStatus {
  pending, // Scheduled but not yet started
  inProgress, // Currently being executed
  completed, // Completed successfully
  cancelled, // Cancelled by user or system
  missed, // Missed (no execution)
}

enum ScheduleFrequency {
  once, // One-time schedule
  daily, // Every day
  weekly, // Once a week
  biWeekly, // Every two weeks
  monthly, // Once a month
}

class ScheduleModel {
  final String? id;
  final String userId;
  final DateTime scheduledDate;
  final TimeOfDay timeSlot;
  final LatLng location;
  final String address;
  final String? notes;
  final ScheduleStatus status;
  final ScheduleFrequency frequency;
  final String? driverId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String?
  wasteType; // Organik, Anorganik, B3 - DEPRECATED, use wasteItems
  final double? estimatedWeight; // in kg - DEPRECATED, use totalEstimatedWeight
  final List<WasteItem> wasteItems; // NEW: Multiple waste items
  final double totalEstimatedWeight; // NEW: Auto-calculated from wasteItems
  final bool isPaid;
  final double? amount;
  final String? contactName;
  final String? contactPhone;

  ScheduleModel({
    this.id,
    required this.userId,
    required this.scheduledDate,
    required this.timeSlot,
    required this.location,
    required this.address,
    this.notes,
    required this.status,
    required this.frequency,
    this.driverId,
    required this.createdAt,
    this.completedAt,
    this.wasteType,
    this.estimatedWeight,
    this.wasteItems = const [],
    double? totalEstimatedWeight,
    required this.isPaid,
    this.amount,
    this.contactName,
    this.contactPhone,
  }) : totalEstimatedWeight =
           totalEstimatedWeight ??
           wasteItems.fold(0.0, (sum, item) => sum + item.estimatedWeight);

  // Convert TimeOfDay to String for database storage
  String get timeSlotString =>
      '${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}';

  // Get the scheduled datetime (combination of scheduledDate + timeSlot)
  // This should be used instead of createdAt for displaying schedule time
  DateTime get scheduledDateTime {
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      timeSlot.hour,
      timeSlot.minute,
    );
  }

  // Convert ScheduleModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlotString,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'notes': notes,
      'status': status.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'driverId': driverId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'wasteType': wasteType,
      'estimatedWeight': estimatedWeight,
      'wasteItems': wasteItems.map((item) => item.toJson()).toList(),
      'totalEstimatedWeight': totalEstimatedWeight,
      'isPaid': isPaid,
      'amount': amount,
      'contactName': contactName,
      'contactPhone': contactPhone,
    };
  }

  // Create ScheduleModel from JSON
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    // Parse timeSlot from string
    final timeSlotParts = (json['timeSlot'] as String).split(':');
    final timeSlot = TimeOfDay(
      hour: int.parse(timeSlotParts[0]),
      minute: int.parse(timeSlotParts[1]),
    );

    // Parse location from map
    final locationMap = json['location'] as Map<String, dynamic>;
    final location = LatLng(
      locationMap['latitude'] as double,
      locationMap['longitude'] as double,
    );

    // Parse waste items
    final List<WasteItem> wasteItems = [];
    if (json['wasteItems'] != null && json['wasteItems'] is List) {
      wasteItems.addAll(
        (json['wasteItems'] as List).map((item) => WasteItem.fromJson(item)),
      );
    } else if (json['waste_items'] != null && json['waste_items'] is List) {
      wasteItems.addAll(
        (json['waste_items'] as List).map((item) => WasteItem.fromJson(item)),
      );
    }

    return ScheduleModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      timeSlot: timeSlot,
      location: location,
      address: json['address'] as String,
      notes: json['notes'] as String?,
      status: _parseStatus(json['status'] as String),
      frequency: _parseFrequency(json['frequency'] as String),
      driverId: json['driverId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      wasteType: json['wasteType'] as String?,
      estimatedWeight: json['estimatedWeight'] as double?,
      wasteItems: wasteItems,
      totalEstimatedWeight:
          (json['totalEstimatedWeight'] ?? json['total_estimated_weight'])
              as double?,
      isPaid: json['isPaid'] as bool,
      amount: json['amount'] as double?,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }

  factory ScheduleModel.fromApi(ScheduleApiModel api) {
    final scheduled = api.scheduledAt ?? DateTime.now();
    final time = TimeOfDay(hour: scheduled.hour, minute: scheduled.minute);
    final statusString = api.status ?? 'pending';

    return ScheduleModel(
      id: api.id.toString(),
      userId: api.assignedTo?.toString() ?? 'unknown',
      scheduledDate: scheduled,
      timeSlot: time,
      location: LatLng(api.latitude ?? 0, api.longitude ?? 0),
      address: api.description ?? 'Lokasi tidak tersedia',
      notes: api.description,
      status: _parseStatus(statusString),
      frequency: ScheduleFrequency.once,
      driverId: api.assignedTo?.toString(),
      createdAt: api.createdAt ?? DateTime.now(),
      completedAt: statusString == 'completed' ? api.updatedAt : null,
      wasteType: 'Campuran',
      estimatedWeight: null,
      isPaid: false,
      amount: null,
      contactName: api.assignedUser?.name,
      contactPhone: api.assignedUser?.phone,
    );
  }

  // Create a copy with some fields updated
  ScheduleModel copyWith({
    String? id,
    String? userId,
    DateTime? scheduledDate,
    TimeOfDay? timeSlot,
    LatLng? location,
    String? address,
    String? notes,
    ScheduleStatus? status,
    ScheduleFrequency? frequency,
    String? driverId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? wasteType,
    double? estimatedWeight,
    List<WasteItem>? wasteItems,
    double? totalEstimatedWeight,
    bool? isPaid,
    double? amount,
    String? contactName,
    String? contactPhone,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      location: location ?? this.location,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      wasteType: wasteType ?? this.wasteType,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      wasteItems: wasteItems ?? this.wasteItems,
      totalEstimatedWeight: totalEstimatedWeight ?? this.totalEstimatedWeight,
      isPaid: isPaid ?? this.isPaid,
      amount: amount ?? this.amount,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  // Helper for parsing status from string
  static ScheduleStatus _parseStatus(String status) {
    final normalized = status.replaceAll(RegExp(r'[\s_-]+'), '').toLowerCase();

    // ✅ Handle specific backend status mappings
    switch (normalized) {
      case 'ontheway':
      case 'onprogress':
      case 'sedangdiproses':
      case 'accepted':
      case 'arrived':
        return ScheduleStatus.inProgress;
      case 'completed':
      case 'selesai':
        return ScheduleStatus.completed;
      case 'cancelled':
      case 'dibatalkan':
        return ScheduleStatus.cancelled;
      case 'pending':
      case 'dijadwalkan':
        return ScheduleStatus.pending;
      case 'missed':
      case 'terlewat':
        return ScheduleStatus.missed;
    }

    // Fallback: Try to match enum values
    return ScheduleStatus.values.firstWhere((element) {
      final value = element.toString().split('.').last;
      final normalizedValue = value
          .replaceAll(RegExp(r'[\s_-]+'), '')
          .toLowerCase();
      return normalizedValue == normalized;
    }, orElse: () => ScheduleStatus.pending);
  }

  // Helper for parsing frequency from string
  static ScheduleFrequency _parseFrequency(String frequency) {
    return ScheduleFrequency.values.firstWhere(
      (element) => element.toString().split('.').last == frequency,
      orElse: () => ScheduleFrequency.once,
    );
  }
}
