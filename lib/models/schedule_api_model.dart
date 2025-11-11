import 'package:intl/intl.dart';

class ScheduleApiModel {
  ScheduleApiModel({
    required this.id,
    required this.title,
    this.description,
    this.latitude,
    this.longitude,
    this.status,
    this.assignedTo,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
    this.trackingsCount,
    this.assignedUser,
    // New fields from production API
    this.userId,
    this.mitraId,
    this.userName,
    this.mitraName,
    this.serviceType,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.estimatedDuration,
    this.notes,
    this.paymentMethod,
    this.price,
    this.frequency,
    this.wasteType,
    this.estimatedWeight,
    this.contactName,
    this.contactPhone,
    this.isPaid,
    this.amount,
    this.additionalWastes,
    this.trackings,
  });

  factory ScheduleApiModel.fromJson(Map<String, dynamic> json) {
    final assignedUserJson = json['assigned_user'];

    // Parse additional_wastes array
    List<Map<String, dynamic>>? additionalWastesList;
    if (json['additional_wastes'] is List) {
      additionalWastesList = (json['additional_wastes'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    // Parse trackings array
    List<Map<String, dynamic>>? trackingsList;
    if (json['trackings'] is List) {
      trackingsList = (json['trackings'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return ScheduleApiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      title: (json['title'] ?? json['pickup_address'] ?? 'Jadwal').toString(),
      description: json['description']?.toString(),
      latitude: _toDouble(json['latitude'] ?? json['pickup_latitude']),
      longitude: _toDouble(json['longitude'] ?? json['pickup_longitude']),
      status: json['status']?.toString(),
      assignedTo: json['assigned_to'] == null
          ? null
          : int.tryParse(json['assigned_to'].toString()),
      scheduledAt: _parseDate(json['scheduled_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      trackingsCount: json['trackings_count'] is int
          ? json['trackings_count'] as int
          : int.tryParse(json['trackings_count']?.toString() ?? ''),
      assignedUser: assignedUserJson is Map<String, dynamic>
          ? ScheduleAssignedUser.fromJson(assignedUserJson)
          : null,
      // New fields
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      mitraId: json['mitra_id'] is int
          ? json['mitra_id'] as int
          : int.tryParse(json['mitra_id']?.toString() ?? ''),
      userName: json['user_name']?.toString(),
      mitraName: json['mitra_name']?.toString(),
      serviceType: json['service_type']?.toString(),
      pickupAddress: json['pickup_address']?.toString(),
      pickupLatitude: _toDouble(json['pickup_latitude']),
      pickupLongitude: _toDouble(json['pickup_longitude']),
      estimatedDuration: json['estimated_duration'] is int
          ? json['estimated_duration'] as int
          : int.tryParse(json['estimated_duration']?.toString() ?? ''),
      notes: json['notes']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      price: _toDouble(json['price']),
      frequency: json['frequency']?.toString(),
      wasteType: json['waste_type']?.toString(),
      estimatedWeight: _toDouble(json['estimated_weight']),
      contactName: json['contact_name']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      isPaid: json['is_paid'] == true || json['is_paid'] == 1,
      amount: _toDouble(json['amount']),
      additionalWastes: additionalWastesList,
      trackings: trackingsList,
    );
  }

  final int id;
  final String title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? status;
  final int? assignedTo;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? trackingsCount;
  final ScheduleAssignedUser? assignedUser;

  // New fields from production API
  final int? userId;
  final int? mitraId;
  final String? userName;
  final String? mitraName;
  final String? serviceType;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final int? estimatedDuration;
  final String? notes;
  final String? paymentMethod;
  final double? price;
  final String? frequency;
  final String? wasteType;
  final double? estimatedWeight;
  final String? contactName;
  final String? contactPhone;
  final bool? isPaid;
  final double? amount;
  final List<Map<String, dynamic>>? additionalWastes;
  final List<Map<String, dynamic>>? trackings;

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
