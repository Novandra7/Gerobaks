import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class GoldenProfileCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double cornerRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool useGoldenRatio;
  
  const GoldenProfileCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.cornerRadius = 16.0,
    this.padding,
    this.onTap,
    this.useGoldenRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use golden ratio for padding if enabled
    final double basePadding = 16.0;
    final double horizontalPadding = basePadding;
    final double verticalPadding = useGoldenRatio 
        ? basePadding / GoldenRatioHelper.phi 
        : basePadding * 0.62; // Approximation of 1/1.618
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, cornerRadius)
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? whiteColor,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveRadius(context, cornerRadius)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(context, horizontalPadding),
              vertical: ResponsiveHelper.getResponsiveSpacing(context, verticalPadding),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
