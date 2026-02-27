import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all addresses for the authenticated user
class FetchAddresses extends AddressEvent {
  const FetchAddresses();
}

/// Set a specific address as the default
class SetDefaultAddress extends AddressEvent {
  final int addressId;

  const SetDefaultAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}

/// Create a new address
class CreateAddress extends AddressEvent {
  final String label;
  final String address;
  final String? addressText;
  final String? latitude;
  final String? longitude;
  final bool isDefault;
  final String? subscriptionPlanId;

  const CreateAddress({
    required this.label,
    required this.address,
    this.addressText,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.subscriptionPlanId,
  });

  @override
  List<Object?> get props => [label, address, addressText, latitude, longitude, isDefault, subscriptionPlanId];
}

/// Update an existing address
class UpdateAddress extends AddressEvent {
  final int addressId;
  final String label;
  final String address;
  final String? addressText;
  final String? latitude;
  final String? longitude;
  final bool isDefault;
  final String? subscriptionPlanId;
  /// ID of the existing subscription to PATCH (if null, a new subscription will be POSTed)
  final String? existingSubscriptionId;

  const UpdateAddress({
    required this.addressId,
    required this.label,
    required this.address,
    this.addressText,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.subscriptionPlanId,
    this.existingSubscriptionId,
  });

  @override
  List<Object?> get props => [addressId, label, address, addressText, latitude, longitude, isDefault, subscriptionPlanId, existingSubscriptionId];
}

/// Delete a specific address
class DeleteAddress extends AddressEvent {
  final int addressId;
  /// ID of the subscription linked to this address (if any), to be deleted alongside
  final String? subscriptionId;

  const DeleteAddress(this.addressId, {this.subscriptionId});

  @override
  List<Object?> get props => [addressId, subscriptionId];
}
