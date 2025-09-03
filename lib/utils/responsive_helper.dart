import 'package:flutter/material.dart';

/// Helper class untuk mengelola responsifitas di seluruh aplikasi
class ResponsiveHelper {
  /// Mendapatkan ukuran font yang responsif berdasarkan lebar layar
  static double getResponsiveFontSize(BuildContext context, double fontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      return fontSize * 0.8; // 80% dari ukuran asli untuk layar sangat kecil
    } else if (screenWidth < 400) {
      return fontSize * 0.9; // 90% untuk layar kecil
    } else if (screenWidth > 600) {
      return fontSize * 1.1; // 110% untuk layar besar (tablet)
    } else {
      return fontSize; // Ukuran default untuk layar ukuran menengah
    }
  }
  
  /// Mendapatkan padding yang responsif berdasarkan lebar layar
  static EdgeInsetsGeometry getResponsivePadding(
    BuildContext context, {
    double horizontal = 20,
    double vertical = 16,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      // Kurangi padding untuk layar sangat kecil
      return EdgeInsets.symmetric(
        horizontal: horizontal * 0.8,
        vertical: vertical * 0.8,
      );
    } else if (screenWidth > 600) {
      // Tambah padding untuk layar besar (tablet)
      return EdgeInsets.symmetric(
        horizontal: horizontal * 1.2,
        vertical: vertical * 1.2,
      );
    } else {
      // Padding default untuk layar ukuran menengah
      return EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );
    }
  }
  
  /// Periksa apakah layar adalah layar kecil
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  /// Periksa apakah layar adalah layar menengah
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }
  
  /// Periksa apakah layar adalah layar besar (tablet)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
  
  /// Mendapatkan ukuran ikon yang responsif berdasarkan lebar layar
  static double getResponsiveIconSize(BuildContext context, double size) {
    if (isSmallScreen(context)) {
      return size * 0.8;
    } else if (isLargeScreen(context)) {
      return size * 1.2;
    } else {
      return size;
    }
  }
  
  /// Mendapatkan radius sudut yang responsif berdasarkan lebar layar
  static double getResponsiveRadius(BuildContext context, double radius) {
    if (isSmallScreen(context)) {
      return radius * 0.8;
    } else if (isLargeScreen(context)) {
      return radius * 1.2;
    } else {
      return radius;
    }
  }
  
  /// Mendapatkan tinggi elemen UI yang responsif
  static double getResponsiveHeight(BuildContext context, double height) {
    if (isSmallScreen(context)) {
      return height * 0.8;
    } else if (isLargeScreen(context)) {
      return height * 1.2;
    } else {
      return height;
    }
  }
  
  /// Mendapatkan lebar elemen UI yang responsif
  static double getResponsiveWidth(BuildContext context, double width) {
    if (isSmallScreen(context)) {
      return width * 0.8;
    } else if (isLargeScreen(context)) {
      return width * 1.2;
    } else {
      return width;
    }
  }
  
  /// Mendapatkan spacing (jarak) yang responsif
  static double getResponsiveSpacing(BuildContext context, double spacing) {
    if (isSmallScreen(context)) {
      return spacing * 0.8;
    } else if (isLargeScreen(context)) {
      return spacing * 1.2;
    } else {
      return spacing;
    }
  }
  
  /// Mendapatkan margin yang responsif
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    double factor = isSmallScreen(context) ? 0.8 : (isLargeScreen(context) ? 1.2 : 1.0);
    
    return EdgeInsets.only(
      left: left * factor,
      top: top * factor,
      right: right * factor,
      bottom: bottom * factor,
    );
  }
}
