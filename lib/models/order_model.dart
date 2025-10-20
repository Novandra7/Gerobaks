import 'dart:convert';

class OrderModel {
  final int id;
  final int userId;
  final int? mitraId;
  final int? serviceId;
  final int? scheduleId;
  final String addressText;
  final double? latitude;
  final double? longitude;
  final String status;
  final double totalPrice;
  final String paymentStatus;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.mitraId,
    this.serviceId,
    this.scheduleId,
    required this.addressText,
    this.latitude,
    this.longitude,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      mitraId: map['mitra_id']?.toInt(),
      serviceId: map['service_id']?.toInt(),
      scheduleId: map['schedule_id']?.toInt(),
      addressText: map['address_text'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      status: map['status'] ?? 'pending',
      totalPrice: map['total_price']?.toDouble() ?? 0.0,
      paymentStatus: map['payment_status'] ?? 'pending',
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory OrderModel.fromJson(String source) {
    return OrderModel.fromMap(json.decode(source));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'mitra_id': mitraId,
      'service_id': serviceId,
      'schedule_id': scheduleId,
      'address_text': addressText,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Payment status helpers
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';
  bool get isPaymentFailed => paymentStatus == 'failed';

  // Geolocation check
  bool get hasLocation => latitude != null && longitude != null;
}