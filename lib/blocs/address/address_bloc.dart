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
    on<CreateAddress>(_onCreateAddress);
    on<UpdateAddress>(_onUpdateAddress);
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

  Future<void> _onCreateAddress(
    CreateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressState.operating(state.addresses));
    try {
      print('📍 AddressBloc: Creating new address');
      final response = await _api.postJson(ApiRoutes.userAddresses, {
        'label': event.label,
        'address': event.address,
        'address_text': event.addressText,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'subscription_status': event.subscriptionPlanId != null ? 'pending' : null,
        'is_default': event.isDefault,
      });
      print('✅ AddressBloc: Address created');

      // Jika plan subscription dipilih, buat subscription setelah address dibuat
      if (event.subscriptionPlanId != null) {
        final addressId = response?['data']?['id']?.toString();
        if (addressId != null) {
          print('📋 AddressBloc: Creating subscription for address $addressId');
          await _api.postJson(ApiRoutes.subscribe, {
            'address_id': addressId,
            'subscription_plan_id': event.subscriptionPlanId,
            'auto_renew': true,
          });
          print('✅ AddressBloc: Subscription created');
        }
      }

      emit(AddressState.operationSuccess(
        state.addresses,
        'Alamat berhasil ditambahkan',
      ));
      add(const FetchAddresses());
    } catch (e) {
      print('❌ AddressBloc: Failed to create address - $e');
      emit(AddressState(
        status: AddressStatus.error,
        addresses: state.addresses,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressState.operating(state.addresses));
    try {
      print('📍 AddressBloc: Updating address ${event.addressId}');
      await _api.patchJson(ApiRoutes.userAddress(event.addressId), {
        'label': event.label,
        'address': event.address,
        'address_text': event.addressText,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'is_default': event.isDefault,
        if (event.subscriptionPlanId != null) 'subscription_status': 'pending',
      });
      print('✅ AddressBloc: Address updated');

      if (event.subscriptionPlanId != null) {
        if (event.existingSubscriptionId != null) {
          // Update existing subscription via PATCH
          await _api.patchJson(
            ApiRoutes.updateSubscription(event.existingSubscriptionId!),
            {'subscription_plan_id': event.subscriptionPlanId},
          );
        } else {
          // Create new subscription via POST
          await _api.patchJson(ApiRoutes.subscribe, {
            'address_id': event.addressId.toString(),
            'subscription_plan_id': event.subscriptionPlanId,
            'auto_renew': true,
          });
        }
      }

      emit(AddressState.operationSuccess(
        state.addresses,
        'Alamat berhasil diperbarui',
      ));
      add(const FetchAddresses());
    } catch (e) {
      print('❌ AddressBloc: Failed to update address - $e');
      emit(AddressState(
        status: AddressStatus.error,
        addresses: state.addresses,
        errorMessage: e.toString(),
      ));
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
      // Best-effort: cancel then delete the linked subscription before deleting the address
      if (event.subscriptionId != null) {
        try {
          await _api.postJson(ApiRoutes.cancelSubscription(event.subscriptionId!), {});
        } catch (_) {
          // Ignore — subscription may already be pending/cancelled, proceed with delete
        }
        try {
          await _api.delete(ApiRoutes.deleteSubscription(event.subscriptionId!));
        } catch (_) {
          // Ignore — proceed with address deletion regardless
        }
      }

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
