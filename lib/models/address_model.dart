class AddressModel {
  final int id;
  final int? userId;
  final String label;
  final String address;
  final String? addressText;
  final String? latitude;
  final String? longitude;
  final bool isDefault;
  final bool isVerified;
  final String? notes;
  final String? subscriptionPlan;
  final String? subscriptionStatus;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String? createdAt;
  final String? updatedAt;

  const AddressModel({
    required this.id,
    this.userId,
    required this.label,
    required this.address,
    this.addressText,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.isVerified = false,
    this.notes,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      addressText: json['address_text'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      notes: json['notes'] as String?,
      subscriptionPlan: json['subscription_plan'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionStartDate: json['subscription_start_date'] as String?,
      subscriptionEndDate: json['subscription_end_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'label': label,
    'address': address,
    'address_text': addressText,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault,
    'is_verified': isVerified,
    'notes': notes,
    'subscription_plan': subscriptionPlan,
    'subscription_status': subscriptionStatus,
    'subscription_start_date': subscriptionStartDate,
    'subscription_end_date': subscriptionEndDate,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  AddressModel copyWith({
    int? id,
    int? userId,
    String? label,
    String? address,
    String? addressText,
    String? latitude,
    String? longitude,
    bool? isDefault,
    bool? isVerified,
    String? notes,
    String? subscriptionPlan,
    String? subscriptionStatus,
    String? subscriptionStartDate,
    String? subscriptionEndDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      address: address ?? this.address,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      notes: notes ?? this.notes,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
