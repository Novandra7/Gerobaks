import 'package:bloc/bloc.dart';
import 'package:bank_sha/models/address_model.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'address_event.dart';
import 'address_state.dart';

/// BLoC untuk mengelola alamat pengguna
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final ApiClient _api = ApiClient();

  AddressBloc() : super(AddressState.initial()) {
    on<FetchAddresses>(_onFetchAddresses);
    on<SetDefaultAddress>(_onSetDefaultAddress);
    on<DeleteAddress>(_onDeleteAddress);
  }

  Future<void> _onFetchAddresses(
    FetchAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressState.loading());
    try {
      print('📍 AddressBloc: Fetching addresses');
      final response = await _api.get(ApiRoutes.userAddresses);

      final List<dynamic> raw = response['data'] as List<dynamic>? ?? [];
      final addresses = raw
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();

      print('✅ AddressBloc: ${addresses.length} addresses fetched');
      emit(AddressState.loaded(addresses));
    } catch (e) {
      print('❌ AddressBloc: Failed to fetch addresses - $e');
      emit(AddressState.error(e.toString()));
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<AddressState> emit,
  ) async {
    final previousAddresses = state.addresses;
    // Optimistically update the list before the API call
    final updatedAddresses = previousAddresses.map((a) {
      return a.copyWith(isDefault: a.id == event.addressId);
    }).toList();
    emit(AddressState.loaded(updatedAddresses));

    try {
      print('📍 AddressBloc: Setting default address ${event.addressId}');
      await _api.postJson(
        ApiRoutes.userAddressSetDefault(event.addressId),
        {},
      );
      print('✅ AddressBloc: Default address set');
    } catch (e) {
      print('❌ AddressBloc: Failed to set default address - $e');
      // Rollback + show error via snackbar while keeping the list visible
      emit(AddressState(
        status: AddressStatus.error,
        addresses: previousAddresses,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressState.operating(state.addresses));
    try {
      print('📍 AddressBloc: Deleting address ${event.addressId}');
      await _api.delete(ApiRoutes.userAddress(event.addressId));
      print('✅ AddressBloc: Address deleted');

      // Refresh the list after deletion
      add(const FetchAddresses());
    } catch (e) {
      print('❌ AddressBloc: Failed to delete address - $e');
      emit(AddressState.error(e.toString()));
    }
  }
}
