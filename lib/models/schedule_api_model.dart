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
  });

  factory ScheduleApiModel.fromJson(Map<String, dynamic> json) {
    final assignedUserJson = json['assigned_user'];
    return ScheduleApiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      title: (json['title'] ?? 'Jadwal').toString(),
      description: json['description']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
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
