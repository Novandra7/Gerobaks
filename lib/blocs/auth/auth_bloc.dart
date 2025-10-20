import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC untuk mengelola authentication
/// Menggunakan AuthApiService untuk komunikasi dengan backend
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService _authService = AuthApiService();

  AuthBloc() : super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      print('🔐 AuthBloc: Starting login for ${event.email}');

      final response = await _authService.login(
        email: event.email,
        password: event.password,
      );

      print('✅ AuthBloc: Login successful');
      print('Response data: $response');

      // Extract token and user data from response
      final token = response['token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;

      if (token != null && user != null) {
        print('✅ AuthBloc: Token and user data found');
        print('User role: ${user['role']}');

        emit(AuthState.authenticated(token: token, user: user));
      } else {
        print('❌ AuthBloc: Token or user data missing');
        emit(AuthState.error('Data login tidak lengkap'));
      }
    } catch (e) {
      print('❌ AuthBloc: Login failed - $e');
      emit(AuthState.error(e.toString()));
    }
  }

  /// Handle register request
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      print('🔐 AuthBloc: Starting registration for ${event.email}');

      final response = await _authService.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role ?? 'end_user', // Default to end_user for MVP
      );

      print('✅ AuthBloc: Registration successful');

      // Extract token and user data from response
      final token = response['token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;

      if (token != null && user != null) {
        emit(AuthState.authenticated(token: token, user: user));
      } else {
        emit(AuthState.error('Data registrasi tidak lengkap'));
      }
    } catch (e) {
      print('❌ AuthBloc: Registration failed - $e');
      emit(AuthState.error(e.toString()));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('🔐 AuthBloc: Logging out');

      // Call logout API
      await _authService.logout();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      print('✅ AuthBloc: Logout successful');

      emit(AuthState.unauthenticated());
    } catch (e) {
      print('❌ AuthBloc: Logout failed - $e');
      // Even if API call fails, still clear local data and logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      emit(AuthState.unauthenticated());
    }
  }

  /// Check authentication status from SharedPreferences
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      print('🔐 AuthBloc: Checking auth status');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        // Parse user data
        final user = Map<String, dynamic>.from(
          await compute(_parseUserData, userJson),
        );

        print('✅ AuthBloc: User authenticated from local storage');
        print('User role: ${user['role']}');

        emit(AuthState.authenticated(token: token, user: user));
      } else {
        print('ℹ️ AuthBloc: No stored credentials found');
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      print('❌ AuthBloc: Auth check failed - $e');
      emit(AuthState.unauthenticated());
    }
  }

  /// Update user profile in state
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isAuthenticated) {
      emit(state.copyWith(user: event.userData));

      // Also update SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(event.userData));
      } catch (e) {
        print('❌ Failed to update user data in storage: $e');
      }
    }
  }

  /// Helper function to parse user data (for compute isolation)
  static Map<String, dynamic> _parseUserData(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }
}
