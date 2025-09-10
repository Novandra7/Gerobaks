import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class GoldenStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool useGoldenRatio;

  const GoldenStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.useGoldenRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    // Base spacing using golden ratio
    final double baseSpacing = 16.0;
    final double iconSpacing = useGoldenRatio ? baseSpacing / GoldenRatioHelper.phi : baseSpacing * 0.6;
    final double contentSpacing = useGoldenRatio ? baseSpacing / (GoldenRatioHelper.phi * 2) : baseSpacing * 0.4;
    
    // Font size based on golden ratio
    final double titleFontSize = useGoldenRatio 
        ? GoldenRatioHelper.goldenFontSize(context, level: -1, base: 16.0)
        : ResponsiveHelper.getResponsiveFontSize(context, 12);
        
    final double valueFontSize = useGoldenRatio
        ? GoldenRatioHelper.goldenFontSize(context, level: 1, base: 12.0)
        : ResponsiveHelper.getResponsiveFontSize(context, 18);
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, baseSpacing)),
      decoration: BoxDecoration(
        color: backgroundColor ?? greenui,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, iconSpacing)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, useGoldenRatio ? 8 : 8)
              ),
            ),
            child: Icon(
              icon,
              color: iconColor ?? greenColor,
              size: ResponsiveHelper.getResponsiveIconSize(
                context, 
                useGoldenRatio ? 24 * (1 / GoldenRatioHelper.phi) : 24
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing * 0.75)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: greyTextStyle.copyWith(
                    fontSize: titleFontSize,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, contentSpacing)),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: valueFontSize,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
