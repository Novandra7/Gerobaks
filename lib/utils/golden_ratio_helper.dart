import 'package:flutter/material.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class GoldenRatioHelper {
  // Golden ratio constant (phi = 1.618)
  static const double phi = 1.618;
  
  /// Calculates golden ratio height based on width
  static double calculateGoldenHeight(double width) {
    return width / phi;
  }
  
  /// Calculates golden ratio width based on height
  static double calculateGoldenWidth(double height) {
    return height * phi;
  }
  
  /// Creates padding that follows golden ratio proportions
  static EdgeInsetsGeometry goldenPadding(BuildContext context, {double base = 16.0}) {
    final double horizontal = base;
    final double vertical = base / phi;
    
    return EdgeInsets.symmetric(
      horizontal: ResponsiveHelper.getResponsiveSpacing(context, horizontal),
      vertical: ResponsiveHelper.getResponsiveSpacing(context, vertical),
    );
  }
  
  /// Creates a container with golden ratio dimensions
  static Widget goldenContainer({
    required BuildContext context,
    required Widget child,
    double baseWidth = 100.0,
    Color? color,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    final double width = ResponsiveHelper.getResponsiveWidth(context, baseWidth);
    final double height = calculateGoldenHeight(width);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
  
  /// Creates spacing that follows golden ratio
  static SizedBox goldenSpacingVertical(BuildContext context, {double base = 16.0}) {
    return SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, base / phi));
  }
  
  static SizedBox goldenSpacingHorizontal(BuildContext context, {double base = 16.0}) {
    return SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, base / phi));
  }
  
  /// Creates font sizes that follow golden ratio progression
  static double goldenFontSize(BuildContext context, {int level = 0, double base = 16.0}) {
    double size = base;
    
    if (level > 0) {
      for (int i = 0; i < level; i++) {
        size *= phi;
      }
    } else if (level < 0) {
      for (int i = 0; i > level; i--) {
        size /= phi;
      }
    }
    
    return ResponsiveHelper.getResponsiveFontSize(context, size);
  }
  
  /// Creates a grid with golden ratio proportions
  static Widget goldenGrid({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
    int columns = 2,
  }) {
    final double aspectRatio = phi;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, spacing),
        mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, spacing / phi),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
