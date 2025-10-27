import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bank_sha/utils/auth_helper.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/shared/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation
    _animationController.forward();

    // Attempt auto-login after a brief delay to show the splash screen
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      try {
        print("🚀 [SPLASH] Attempting auto-login from splash page");

        // Check API token first (more reliable than localStorage flags)
        final authService = AuthApiService();
        final token = await authService.getToken();

        print("🚀 [SPLASH] Token exists: ${token != null && token.isNotEmpty}");

        if (token == null || token.isEmpty) {
          print("🚀 [SPLASH] No valid token found, navigating to login");
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign-in',
              (route) => false,
            );
          }
          return;
        }

        // Get LocalStorageService instance for debugging
        final localStorage = await LocalStorageService.getInstance();
        final isLoggedIn = await localStorage.getBool(
          localStorage.getLoginKey(),
        );
        print("🚀 [SPLASH] isLoggedIn check result: $isLoggedIn");

        // Check user data directly for debugging
        final userData = await localStorage.getUserData();
        if (userData != null) {
          print(
            "🚀 [SPLASH] User data found: ${userData['name']} (${userData['email']})",
          );
          print("🚀 [SPLASH] Role in userData: ${userData['role']}");

          // Debug stored role separately
          final storedRole = await localStorage.getUserRole();
          print("🚀 [SPLASH] Explicitly stored role: $storedRole");
        } else {
          print("🚀 [SPLASH] No user data found in localStorage");
        }

        // Try to auto-login with saved credentials
        final Map<String, dynamic> autoLoginResult =
            await AuthHelper.tryAutoLogin();
        print("🚀 [SPLASH] Auto-login result: $autoLoginResult");

        if (autoLoginResult['success'] && mounted) {
          final String role =
              autoLoginResult['role'] ?? AuthHelper.ROLE_END_USER;
          print("🚀 [SPLASH] Auto-login successful with role: $role");

          // Navigate berdasarkan role
          if (AuthHelper.isMitra(role)) {
            print(
              "🚀 [SPLASH] Auto-login successful for mitra, navigating to mitra dashboard",
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mitra-dashboard-new',
              (route) => false,
            );
          } else if (AuthHelper.isAdmin(role)) {
            print(
              "🚀 [SPLASH] Auto-login successful for admin, navigating to mitra dashboard (temporary)",
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mitra-dashboard-new',
              (route) => false,
            );
          } else {
            print(
              "🚀 [SPLASH] Auto-login successful for end user, navigating to home page",
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        } else if (mounted) {
          print(
            "🚀 [SPLASH] Auto-login failed or not attempted, navigating to login",
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sign-in',
            (route) => false,
          );
        }
      } catch (e) {
        print("🚀 [SPLASH] Error during auto-login: $e");
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sign-in',
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Choose the appropriate splash screen based on device pixel density
  String _getSplashScreenAsset() {
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    if (pixelRatio >= 3.0) {
      // For high density screens (xxxhdpi)
      return 'assets/splashScreen (1440x2960).png';
    } else if (pixelRatio >= 2.0) {
      // For medium-high density screens (xxhdpi)
      return 'assets/splashScreen (1080x1920).png';
    } else {
      // For lower density screens
      return 'assets/splashScreen (1080x1920).png'; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the device screen size
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getSplashScreenAsset()),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
