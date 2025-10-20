import 'package:equatable/equatable.dart';

/// States untuk authentication
/// Menggunakan Equatable untuk memudahkan comparison
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? token;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.user,
    this.errorMessage,
  });

  /// Initial state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Loading state
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// Authenticated state
  factory AuthState.authenticated({
    required String token,
    required Map<String, dynamic> user,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      token: token,
      user: user,
    );
  }

  /// Unauthenticated state
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Error state
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  /// Copy with method for easy state updates
  AuthState copyWith({
    AuthStatus? status,
    String? token,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Get user role
  String? get userRole => user?['role'];

  /// Get user ID
  int? get userId => user?['id'];

  /// Get user name
  String? get userName => user?['name'];

  /// Get user email
  String? get userEmail => user?['email'];

  @override
  List<Object?> get props => [status, token, user, errorMessage];
}
