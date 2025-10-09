import 'dart:convert';

/// Model User yang sesuai dengan struktur API backend Gerobaks
/// Mendukung semua role: end_user, mitra, admin
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;
  final String? phone;
  final String? address;
  final String subscriptionStatus;
  final int points;
  final String? employeeId;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? workArea;
  final String status;
  final double? rating;
  final int totalCollections;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
    this.phone,
    this.address,
    this.subscriptionStatus = 'inactive',
    this.points = 0,
    this.employeeId,
    this.vehicleType,
    this.vehiclePlate,
    this.workArea,
    this.status = 'active',
    this.rating,
    this.totalCollections = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create User from API response JSON
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'end_user',
      profilePicture: map['profile_picture'],
      phone: map['phone'],
      address: map['address'],
      subscriptionStatus: map['subscription_status'] ?? 'inactive',
      points: map['points']?.toInt() ?? 0,
      employeeId: map['employee_id'],
      vehicleType: map['vehicle_type'],
      vehiclePlate: map['vehicle_plate'],
      workArea: map['work_area'],
      status: map['status'] ?? 'active',
      rating: map['rating']?.toDouble(),
      totalCollections: map['total_collections']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Create User from JSON string
  factory User.fromJson(String source) {
    return User.fromMap(json.decode(source));
  }

  /// Convert User to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_picture': profilePicture,
      'phone': phone,
      'address': address,
      'subscription_status': subscriptionStatus,
      'points': points,
      'employee_id': employeeId,
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
      'work_area': workArea,
      'status': status,
      'rating': rating,
      'total_collections': totalCollections,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert User to JSON string
  String toJson() => json.encode(toMap());

  /// Create copy with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? profilePicture,
    String? phone,
    String? address,
    String? subscriptionStatus,
    int? points,
    String? employeeId,
    String? vehicleType,
    String? vehiclePlate,
    String? workArea,
    String? status,
    double? rating,
    int? totalCollections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      points: points ?? this.points,
      employeeId: employeeId ?? this.employeeId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      workArea: workArea ?? this.workArea,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalCollections: totalCollections ?? this.totalCollections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is end_user
  bool get isEndUser => role == 'end_user';

  /// Check if user is mitra
  bool get isMitra => role == 'mitra';

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user has subscription
  bool get hasActiveSubscription => subscriptionStatus == 'active';

  /// Get user initials for avatar
  String get initials {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Get display name with role badge
  String get displayNameWithRole {
    switch (role) {
      case 'admin':
        return '$name (Admin)';
      case 'mitra':
        return '$name (Mitra)';
      case 'end_user':
      default:
        return name;
    }
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           phone != null && 
           address != null;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}