class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? profilePicUrl;
  final int points;
  final bool isVerified;
  final List<String>? savedAddresses;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.profilePicUrl,
    this.points = 15, // New users start with 15 points
    this.isVerified = false,
    this.savedAddresses,
    required this.createdAt,
    this.lastLogin,
  });

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      // Handle both profilePicUrl and profile_picture formats
      profilePicUrl: json['profilePicUrl'] ?? json['profile_picture'],
      points: json['points'] ?? 15,
      isVerified: json['isVerified'] ?? false,
      savedAddresses: json['savedAddresses'] != null 
          ? List<String>.from(json['savedAddresses']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'profilePicUrl': profilePicUrl,
      'points': points,
      'isVerified': isVerified,
      'savedAddresses': savedAddresses,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profilePicUrl,
    int? points,
    bool? isVerified,
    List<String>? savedAddresses,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      points: points ?? this.points,
      isVerified: isVerified ?? this.isVerified,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
