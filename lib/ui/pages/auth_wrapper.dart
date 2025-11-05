import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/blocs.dart';
import 'package:bank_sha/ui/pages/sign_in/sign_in_page.dart';
import 'package:bank_sha/ui/pages/end_user/home/home_page.dart';
import 'package:bank_sha/ui/pages/mitra/dashboard/mitra_dashboard_page.dart';

/// AuthWrapper - Routes users based on authentication status
///
/// This widget listens to AuthBloc and decides where to route the user:
/// - If loading: Show splash/loading screen
/// - If unauthenticated: Show login page
/// - If authenticated:
///   - end_user role -> HomePage
///   - mitra role -> MitraDashboardPage
///   - admin role -> AdminDashboard (future)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('🔄 AuthWrapper: Current auth status - ${state.status}');

        // Show loading while checking auth status
        if (state.status == AuthStatus.loading ||
            state.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated - route based on role
        if (state.status == AuthStatus.authenticated) {
          final userRole = state.userRole;
          print('✅ AuthWrapper: User authenticated with role: $userRole');

          // Route based on user role
          switch (userRole) {
            case 'end_user':
              return HomePage();
            case 'mitra':
              return const MitraDashboardPage();
            case 'admin':
              // TODO: Create AdminDashboard page
              return const Scaffold(
                body: Center(child: Text('Admin Dashboard - Coming Soon')),
              );
            default:
              // Unknown role - show error and logout
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Unknown role: $userRole'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
          }
        }

        // User is not authenticated - show login page
        print('🔓 AuthWrapper: User not authenticated, showing login');
        return SignInPage();
      },
    );
  }
}
