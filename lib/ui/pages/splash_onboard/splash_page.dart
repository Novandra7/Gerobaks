import 'dart:async';

import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/utils/auth_helper.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/user_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();

    // Attempt auto-login after a brief delay to show the splash screen
    Timer(const Duration(seconds: 3), () async {
      // Try to auto-login with saved credentials
      final bool autoLoginSuccess = await AuthHelper.tryAutoLogin();
      
      if (autoLoginSuccess && mounted) {
        print("Auto-login successful, navigating to home page");
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/home',
          (route) => false,
        );
      } else if (mounted) {
        print("Auto-login failed or not attempted, navigating to onboarding");
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        );
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
