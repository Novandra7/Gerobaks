import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A skeleton loader that shows a shimmering effect for content loading
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = this.baseColor ?? theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);
    final highlightColor = this.highlightColor ?? theme.colorScheme.surface;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: duration,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
