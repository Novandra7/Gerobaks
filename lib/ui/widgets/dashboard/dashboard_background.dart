import 'package:flutter/material.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

/// Widget untuk membuat background dengan sudut melengkung seperti pada vector XML
class DashboardBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double cornerRadius;

  const DashboardBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFF9FFF8),
    this.cornerRadius = 35,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Gunakan corner radius yang responsif
    final radius = ResponsiveHelper.getResponsiveRadius(context, cornerRadius);
    
    return Container(
      width: mediaQuery.size.width,
      height: mediaQuery.size.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

/// Widget untuk membuat konten dengan padding yang konsisten di dashboard
class DashboardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DashboardContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan padding yang responsif
    final responsivePadding = padding ?? 
        ResponsiveHelper.getResponsivePadding(context);
    
    return SafeArea(
      child: Padding(
        padding: responsivePadding,
        child: child,
      ),
    );
  }
}
