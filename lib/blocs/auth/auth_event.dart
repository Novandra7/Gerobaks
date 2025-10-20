import 'package:equatable/equatable.dart';

/// Events untuk authentication
/// Mendukung login, register, logout, dan check auth status
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event untuk register
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? role;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
}

/// Event untuk logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event untuk check authentication status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event untuk update user profile in state
class UpdateUserProfile extends AuthEvent {
  final Map<String, dynamic> userData;

  const UpdateUserProfile(this.userData);

  @override
  List<Object?> get props => [userData];
}
