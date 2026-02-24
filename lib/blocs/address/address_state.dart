import 'package:equatable/equatable.dart';
import 'package:bank_sha/models/address_model.dart';

enum AddressStatus {
  initial,
  loading,
  loaded,
  error,
  operating, // loading for delete/set-default
  operationSuccess,
}

class AddressState extends Equatable {
  final AddressStatus status;
  final List<AddressModel> addresses;
  final String? errorMessage;
  final String? successMessage;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.errorMessage,
    this.successMessage,
  });

  factory AddressState.initial() =>
      const AddressState(status: AddressStatus.initial);

  factory AddressState.loading() =>
      const AddressState(status: AddressStatus.loading);

  factory AddressState.loaded(List<AddressModel> addresses) =>
      AddressState(status: AddressStatus.loaded, addresses: addresses);

  factory AddressState.error(String message) => AddressState(
        status: AddressStatus.error,
        errorMessage: message,
      );

  /// Operating state — keep current addresses visible during an action
  factory AddressState.operating(List<AddressModel> addresses) =>
      AddressState(status: AddressStatus.operating, addresses: addresses);

  factory AddressState.operationSuccess(
    List<AddressModel> addresses,
    String message,
  ) => AddressState(
        status: AddressStatus.operationSuccess,
        addresses: addresses,
        successMessage: message,
      );

  AddressState copyWith({
    AddressStatus? status,
    List<AddressModel>? addresses,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, addresses, errorMessage, successMessage];
}
