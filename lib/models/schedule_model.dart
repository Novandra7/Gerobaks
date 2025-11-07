import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/models/waste_item.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ScheduleStatus {
  pending, // Scheduled but not yet started
  confirmed, // Accepted/confirmed by mitra, waiting to start
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
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final String? completionNotes;
  final String? cancellationReason;
  final int? actualDuration;
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
  this.cancelledAt,
  this.confirmedAt,
  this.startedAt,
  this.assignedAt,
  this.acceptedAt,
  this.rejectedAt,
  this.completionNotes,
  this.cancellationReason,
  this.actualDuration,
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
  'cancelledAt': cancelledAt?.toIso8601String(),
  'confirmedAt': confirmedAt?.toIso8601String(),
  'startedAt': startedAt?.toIso8601String(),
  'assignedAt': assignedAt?.toIso8601String(),
  'acceptedAt': acceptedAt?.toIso8601String(),
  'rejectedAt': rejectedAt?.toIso8601String(),
  'completionNotes': completionNotes,
  'cancellationReason': cancellationReason,
  'actualDuration': actualDuration,
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
    cancelledAt: json['cancelledAt'] != null
      ? DateTime.parse(json['cancelledAt'] as String)
      : null,
    confirmedAt: json['confirmedAt'] != null
      ? DateTime.parse(json['confirmedAt'] as String)
      : null,
    startedAt: json['startedAt'] != null
      ? DateTime.parse(json['startedAt'] as String)
      : null,
    assignedAt: json['assignedAt'] != null
      ? DateTime.parse(json['assignedAt'] as String)
      : null,
    acceptedAt: json['acceptedAt'] != null
      ? DateTime.parse(json['acceptedAt'] as String)
      : null,
    rejectedAt: json['rejectedAt'] != null
      ? DateTime.parse(json['rejectedAt'] as String)
      : null,
    completionNotes: json['completionNotes'] as String?,
    cancellationReason: json['cancellationReason'] as String?,
    actualDuration: json['actualDuration'] as int?,
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
    final scheduled = api.scheduledAt ?? api.createdAt ?? DateTime.now();
    final time = TimeOfDay(hour: scheduled.hour, minute: scheduled.minute);
    final statusString = api.status ?? 'pending';
    final lat = api.pickupLatitude ?? api.latitude ?? 0;
    final lng = api.pickupLongitude ?? api.longitude ?? 0;
    final address = (api.pickupAddress != null && api.pickupAddress!.isNotEmpty)
        ? api.pickupAddress!
        : (api.description != null && api.description!.isNotEmpty)
        ? api.description!
        : 'Lokasi tidak tersedia';

    final noteText = (api.notes != null && api.notes!.isNotEmpty)
        ? api.notes
        : api.description;

    final wasteItems = <WasteItem>[];
    for (final waste in api.additionalWastes) {
      final item = WasteItem.fromJson(waste);
      if (item.wasteType.isNotEmpty) {
        wasteItems.add(item);
      }
    }
    final computedWeight = wasteItems.fold<double>(
      0,
      (sum, item) => sum + item.estimatedWeight,
    );
    final totalWeight = computedWeight > 0
        ? computedWeight
        : (api.estimatedWeight ?? 0.0);

    return ScheduleModel(
      id: api.id.toString(),
      userId: (api.userId ?? api.assignedTo)?.toString() ?? 'unknown',
      scheduledDate: scheduled,
      timeSlot: time,
      location: LatLng(lat, lng),
      address: address,
      notes: noteText,
      status: _parseStatus(statusString),
      frequency: _parseFrequency(api.frequency ?? 'once'),
      driverId: (api.mitraId ?? api.assignedTo)?.toString(),
      createdAt: api.createdAt ?? scheduled,
      completedAt: statusString == 'completed'
      ? (api.completedAt ?? api.updatedAt ?? api.createdAt)
      : api.completedAt,
    cancelledAt: api.cancelledAt,
    confirmedAt: api.confirmedAt,
    startedAt: api.startedAt,
    assignedAt: api.assignedAt,
    acceptedAt: api.acceptedAt,
    rejectedAt: api.rejectedAt,
    completionNotes:
      api.completionNotes ?? (statusString == 'completed' ? api.notes : null),
    cancellationReason: api.cancellationReason,
    actualDuration: api.actualDuration,
      wasteType:
          api.wasteType ??
          (wasteItems.isNotEmpty ? wasteItems.first.wasteType : 'Campuran'),
      estimatedWeight:
          api.estimatedWeight ?? (wasteItems.isNotEmpty ? totalWeight : null),
      wasteItems: wasteItems,
      totalEstimatedWeight: totalWeight,
      isPaid: api.isPaid ?? false,
      amount: api.amount ?? api.price,
      contactName: api.contactName ?? api.userName ?? api.assignedUser?.name,
      contactPhone: api.contactPhone ?? api.assignedUser?.phone,
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
    DateTime? cancelledAt,
    DateTime? confirmedAt,
    DateTime? startedAt,
    DateTime? assignedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    String? completionNotes,
    String? cancellationReason,
    int? actualDuration,
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
  cancelledAt: cancelledAt ?? this.cancelledAt,
  confirmedAt: confirmedAt ?? this.confirmedAt,
  startedAt: startedAt ?? this.startedAt,
  assignedAt: assignedAt ?? this.assignedAt,
  acceptedAt: acceptedAt ?? this.acceptedAt,
  rejectedAt: rejectedAt ?? this.rejectedAt,
  completionNotes: completionNotes ?? this.completionNotes,
  cancellationReason: cancellationReason ?? this.cancellationReason,
  actualDuration: actualDuration ?? this.actualDuration,
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
    final normalized = frequency
        .replaceAll(RegExp(r'[\s_-]+'), '')
        .toLowerCase();
    return ScheduleFrequency.values.firstWhere((element) {
      final value = element.toString().split('.').last;
      final normalizedValue = value
          .replaceAll(RegExp(r'[\s_-]+'), '')
          .toLowerCase();
      return normalizedValue == normalized;
    }, orElse: () => ScheduleFrequency.once);
  }
}
