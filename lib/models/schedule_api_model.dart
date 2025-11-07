import 'package:intl/intl.dart';

class ScheduleApiModel {
  ScheduleApiModel({
    required this.id,
    required this.title,
    this.description,
    this.notes,
    this.completionNotes,
    this.cancellationReason,
    this.latitude,
    this.longitude,
    this.pickupLatitude,
    this.pickupLongitude,
    this.pickupAddress,
    this.status,
    this.assignedTo,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.confirmedAt,
    this.startedAt,
    this.assignedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.trackingsCount,
    this.assignedUser,
    this.userId,
    this.mitraId,
    this.userName,
    this.mitraName,
    this.serviceType,
    this.paymentMethod,
    this.price,
    this.frequency,
    this.wasteType,
    this.estimatedWeight,
    this.actualDuration,
    this.estimatedDuration,
    this.contactName,
    this.contactPhone,
    this.isPaid,
    this.amount,
    this.additionalWastes = const [],
  });

  factory ScheduleApiModel.fromJson(Map<String, dynamic> json) {
    final assignedUserJson = json['assigned_user'];
    final additionalWastesRaw = json['additional_wastes'];
    return ScheduleApiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      title: (json['title'] ?? 'Jadwal').toString(),
      description: json['description']?.toString(),
      notes: json['notes']?.toString(),
    completionNotes: json['completion_notes']?.toString(),
    cancellationReason: json['cancellation_reason']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      pickupLatitude: _toDouble(json['pickup_latitude']),
      pickupLongitude: _toDouble(json['pickup_longitude']),
      pickupAddress: json['pickup_address']?.toString(),
      status: json['status']?.toString(),
      assignedTo: json['assigned_to'] == null
          ? null
          : int.tryParse(json['assigned_to'].toString()),
      scheduledAt: _parseDate(json['scheduled_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    completedAt: _parseDate(json['completed_at']),
    cancelledAt: _parseDate(json['cancelled_at']),
    confirmedAt: _parseDate(json['confirmed_at']),
    startedAt: _parseDate(json['started_at']),
    assignedAt: _parseDate(json['assigned_at']),
    acceptedAt: _parseDate(json['accepted_at']),
    rejectedAt: _parseDate(json['rejected_at']),
      trackingsCount: json['trackings_count'] is int
          ? json['trackings_count'] as int
          : int.tryParse(json['trackings_count']?.toString() ?? ''),
      assignedUser: assignedUserJson is Map<String, dynamic>
          ? ScheduleAssignedUser.fromJson(assignedUserJson)
          : null,
      userId: json['user_id'] == null
          ? null
          : int.tryParse(json['user_id'].toString()),
      mitraId: json['mitra_id'] == null
          ? null
          : int.tryParse(json['mitra_id'].toString()),
      userName: json['user_name']?.toString(),
      mitraName: json['mitra_name']?.toString(),
      serviceType: json['service_type']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      price: _toDouble(json['price']),
      frequency: json['frequency']?.toString(),
      wasteType: json['waste_type']?.toString(),
      estimatedWeight: _toDouble(json['estimated_weight']),
    actualDuration: _toInt(json['actual_duration']),
      estimatedDuration: json['estimated_duration'] == null
          ? null
          : int.tryParse(json['estimated_duration'].toString()),
      contactName: json['contact_name']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      isPaid: _toBool(json['is_paid']),
      amount: _toDouble(json['amount']),
      additionalWastes: additionalWastesRaw is List
          ? additionalWastesRaw.whereType<Map<String, dynamic>>().toList(
              growable: false,
            )
          : const [],
    );
  }

  final int id;
  final String title;
  final String? description;
  final String? notes;
  final String? completionNotes;
  final String? cancellationReason;
  final double? latitude;
  final double? longitude;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? pickupAddress;
  final String? status;
  final int? assignedTo;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final int? trackingsCount;
  final ScheduleAssignedUser? assignedUser;
  final int? userId;
  final int? mitraId;
  final String? userName;
  final String? mitraName;
  final String? serviceType;
  final String? paymentMethod;
  final double? price;
  final String? frequency;
  final String? wasteType;
  final double? estimatedWeight;
  final int? actualDuration;
  final int? estimatedDuration;
  final String? contactName;
  final String? contactPhone;
  final bool? isPaid;
  final double? amount;
  final List<Map<String, dynamic>> additionalWastes;

  String get formattedDate {
    if (scheduledAt == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(scheduledAt!);
  }

  String get formattedTime {
    if (scheduledAt == null) return 'Jadwal belum ditentukan';
    return DateFormat('HH:mm', 'id_ID').format(scheduledAt!);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'no' || normalized == '0') {
      return false;
    }
    return null;
  }
}

class ScheduleAssignedUser {
  ScheduleAssignedUser({required this.id, required this.name, this.phone});

  factory ScheduleAssignedUser.fromJson(Map<String, dynamic> json) {
    return ScheduleAssignedUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
    );
  }

  final int id;
  final String name;
  final String? phone;
}
