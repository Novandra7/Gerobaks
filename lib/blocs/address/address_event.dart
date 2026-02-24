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

/// Delete a specific address
class DeleteAddress extends AddressEvent {
  final int addressId;

  const DeleteAddress(this.addressId);

  @override
  List<Object?> get props => [addressId];
}
