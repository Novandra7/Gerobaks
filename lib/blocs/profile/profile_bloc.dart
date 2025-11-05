import 'package:bloc/bloc.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC untuk mengelola user profile
/// Menggunakan ApiClient untuk komunikasi dengan backend
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiClient _api = ApiClient();

  ProfileBloc() : super(ProfileState.initial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<ChangePassword>(_onChangePassword);
    on<RefreshProfile>(_onRefreshProfile);
  }

  /// Handle fetch user profile
  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileState.loading());

    try {
      print('👤 ProfileBloc: Fetching user profile');

      // Use ApiRoutes.me endpoint
      final response = await _api.get(ApiRoutes.me);

      print('✅ ProfileBloc: User profile fetched');
      print('Response: $response');

      // Extract user data from response
      final data = response['data'] as Map<String, dynamic>?;

      if (data != null) {
        emit(ProfileState.loaded(data));
      } else {
        emit(ProfileState.error('Data profil tidak ditemukan'));
      }
    } catch (e) {
      print('❌ ProfileBloc: Failed to fetch user profile - $e');
      emit(ProfileState.error(e.toString()));
    }
  }

  /// Handle update profile
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileState.updating());

    try {
      print('👤 ProfileBloc: Updating user profile');

      // Build update data
      final updateData = <String, dynamic>{};
      if (event.name != null) updateData['name'] = event.name;
      if (event.email != null) updateData['email'] = event.email;
      if (event.phone != null) updateData['phone'] = event.phone;
      if (event.address != null) updateData['address'] = event.address;

      final response = await _api.postJson(ApiRoutes.updateProfile, updateData);

      print('✅ ProfileBloc: User profile updated');

      // Extract updated user data
      final data = response['data'] as Map<String, dynamic>?;

      if (data != null) {
        emit(ProfileState.updated(data, 'Profil berhasil diupdate'));
      } else {
        emit(ProfileState.error('Gagal mengupdate profil'));
      }
    } catch (e) {
      print('❌ ProfileBloc: Failed to update profile - $e');
      emit(ProfileState.error(e.toString()));
    }
  }

  /// Handle upload profile image
  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileState.uploadingImage());

    try {
      print('👤 ProfileBloc: Uploading profile image');

      // Use multipart request for image upload
      final uri = Uri.parse(
        '${_api.getBaseUrl()}${ApiRoutes.uploadProfileImage}',
      );
      final request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('image', event.imagePath),
      );

      // Add auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'] as Map<String, dynamic>?;

        if (userData != null) {
          emit(ProfileState.imageUploaded(userData));
        } else {
          emit(ProfileState.error('Gagal mengupload foto profil'));
        }
      } else {
        emit(ProfileState.error('Upload gagal: ${response.statusCode}'));
      }

      print('✅ ProfileBloc: Profile image uploaded');
    } catch (e) {
      print('❌ ProfileBloc: Failed to upload profile image - $e');
      emit(ProfileState.error(e.toString()));
    }
  }

  /// Handle change password
  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    // Validate passwords match
    if (event.newPassword != event.confirmPassword) {
      emit(ProfileState.error('Password baru dan konfirmasi tidak cocok'));
      return;
    }

    emit(ProfileState.changingPassword());

    try {
      print('👤 ProfileBloc: Changing password');

      await _api.postJson(ApiRoutes.changePassword, {
        'current_password': event.currentPassword,
        'new_password': event.newPassword,
        'new_password_confirmation': event.confirmPassword,
      });

      print('✅ ProfileBloc: Password changed');

      emit(ProfileState.passwordChanged());

      // Reload profile data
      add(const FetchUserProfile());
    } catch (e) {
      print('❌ ProfileBloc: Failed to change password - $e');
      emit(ProfileState.error(e.toString()));
    }
  }

  /// Handle refresh profile
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    add(const FetchUserProfile());
  }
}
