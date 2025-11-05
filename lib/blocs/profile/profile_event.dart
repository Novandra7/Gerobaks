import 'package:equatable/equatable.dart';

/// Events untuk profile management
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk fetch user profile
class FetchUserProfile extends ProfileEvent {
  const FetchUserProfile();
}

/// Event untuk update user profile
class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;

  const UpdateProfile({this.name, this.email, this.phone, this.address});

  @override
  List<Object?> get props => [name, email, phone, address];
}

/// Event untuk upload profile image
class UploadProfileImage extends ProfileEvent {
  final String imagePath;

  const UploadProfileImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Event untuk change password
class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

/// Event untuk refresh profile
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}
