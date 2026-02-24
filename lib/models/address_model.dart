class AddressModel {
  final int id;
  final String label;
  final String address;
  final String? latitude;
  final String? longitude;
  final bool isDefault;
  final bool isVerified;
  final String? subscriptionPlan;
  final String? subscriptionStatus;

  const AddressModel({
    required this.id,
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.isVerified = false,
    this.subscriptionPlan,
    this.subscriptionStatus,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'] as Map<String, dynamic>?;
    final plan = subscription?['plan'] as Map<String, dynamic>?;

    return AddressModel(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: json['latitude'] as String? ?? '',
      longitude: json['longitude'] as String? ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      subscriptionPlan: plan?['name'] as String?,
      subscriptionStatus: subscription?['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault,
    'is_verified': isVerified,
  };

  AddressModel copyWith({
    int? id,
    String? label,
    String? address,
    String? latitude,
    String? longitude,
    bool? isDefault,
    bool? isVerified,
    String? subscriptionPlan,
    String? subscriptionStatus,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isVerified: isVerified ?? this.isVerified,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}
