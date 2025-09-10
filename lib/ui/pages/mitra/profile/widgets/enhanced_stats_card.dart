import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class EnhancedStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showTrend;
  final double? trendPercentage;
  final bool isPositive;
  final VoidCallback? onTap;
  
  // Define colors used in this widget
  final Color redColor = const Color(0xFFFF0000);

  const EnhancedStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.showTrend = false,
    this.trendPercentage,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Base spacing using golden ratio
    final double baseSpacing = 16.0;
    final double iconSpacing = baseSpacing / GoldenRatioHelper.phi;
    final double contentSpacing = baseSpacing / (GoldenRatioHelper.phi * 2);
    
    // Font sizes based on golden ratio
    final double titleFontSize = GoldenRatioHelper.goldenFontSize(context, level: -1, base: 16.0);
    final double valueFontSize = GoldenRatioHelper.goldenFontSize(context, level: 1, base: 12.0);
    final double subtitleFontSize = GoldenRatioHelper.goldenFontSize(context, level: -2, base: 16.0);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: Ink(
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
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, baseSpacing)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, iconSpacing)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveRadius(context, 8)
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? greenColor,
                        size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing * 0.5)),
                    Expanded(
                      child: Text(
                        title,
                        style: blackTextStyle.copyWith(
                          fontSize: titleFontSize,
                          fontWeight: medium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, baseSpacing * 0.75)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: blackTextStyle.copyWith(
                          fontSize: valueFontSize,
                          fontWeight: extraBold,
                        ),
                      ),
                    ),
                    if (showTrend && trendPercentage != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 6),
                          vertical: ResponsiveHelper.getResponsiveSpacing(context, 3),
                        ),
                        decoration: BoxDecoration(
                          color: isPositive ? greenColor.withOpacity(0.2) : redColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveRadius(context, 4)
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isPositive ? greenColor : redColor,
                              size: ResponsiveHelper.getResponsiveIconSize(context, 12),
                            ),
                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 2)),
                            Text(
                              '${trendPercentage!.toStringAsFixed(1)}%',
                              style: isPositive
                                  ? greeTextStyle.copyWith(fontSize: subtitleFontSize, fontWeight: semiBold)
                                  : blackTextStyle.copyWith(
                                      fontSize: subtitleFontSize,
                                      fontWeight: semiBold,
                                      color: redColor,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, contentSpacing)),
                  Text(
                    subtitle!,
                    style: greyTextStyle.copyWith(
                      fontSize: subtitleFontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
