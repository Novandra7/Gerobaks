import 'package:equatable/equatable.dart';

/// States untuk profile management
enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
  updating,
  updated,
  uploadingImage,
  imageUploaded,
  changingPassword,
  passwordChanged,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Map<String, dynamic>? userData;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userData,
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  /// Loading state
  factory ProfileState.loading() {
    return const ProfileState(status: ProfileStatus.loading);
  }

  /// Loaded state
  factory ProfileState.loaded(Map<String, dynamic> userData) {
    return ProfileState(
      status: ProfileStatus.loaded,
      userData: userData,
    );
  }

  /// Error state
  factory ProfileState.error(String message) {
    return ProfileState(
      status: ProfileStatus.error,
      errorMessage: message,
    );
  }

  /// Updating state
  factory ProfileState.updating() {
    return const ProfileState(status: ProfileStatus.updating);
  }

  /// Updated state
  factory ProfileState.updated(Map<String, dynamic> userData, String message) {
    return ProfileState(
      status: ProfileStatus.updated,
      userData: userData,
      successMessage: message,
    );
  }

  /// Uploading image state
  factory ProfileState.uploadingImage() {
    return const ProfileState(status: ProfileStatus.uploadingImage);
  }

  /// Image uploaded state
  factory ProfileState.imageUploaded(Map<String, dynamic> userData) {
    return ProfileState(
      status: ProfileStatus.imageUploaded,
      userData: userData,
      successMessage: 'Foto profil berhasil diupdate',
    );
  }

  /// Changing password state
  factory ProfileState.changingPassword() {
    return const ProfileState(status: ProfileStatus.changingPassword);
  }

  /// Password changed state
  factory ProfileState.passwordChanged() {
    return const ProfileState(
      status: ProfileStatus.passwordChanged,
      successMessage: 'Password berhasil diubah',
    );
  }

  /// Copy with method
  ProfileState copyWith({
    ProfileStatus? status,
    Map<String, dynamic>? userData,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userData: userData ?? this.userData,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Get user name
  String? get userName => userData?['name'];

  /// Get user email
  String? get userEmail => userData?['email'];

  /// Get user phone
  String? get userPhone => userData?['phone'];

  /// Get user address
  String? get userAddress => userData?['address'];

  /// Get user avatar
  String? get userAvatar => userData?['avatar'];

  /// Get user role
  String? get userRole => userData?['role'];

  @override
  List<Object?> get props => [status, userData, errorMessage, successMessage];
}
