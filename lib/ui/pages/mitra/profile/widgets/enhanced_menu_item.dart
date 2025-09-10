import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class EnhancedMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showTrailing;
  final bool showBadge;
  final String? badgeText;
  final bool isNew;
  final bool isPremium;

  const EnhancedMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.showTrailing = true,
    this.showBadge = false,
    this.badgeText,
    this.isNew = false,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 12),
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
        ),
        child: Row(
          children: [
            // Icon container with enhanced styling
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
              decoration: BoxDecoration(
                color: backgroundColor ?? lightBackgroundColor,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 10)),
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? greenColor).withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor ?? greenColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 22),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 16)),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: blackTextStyle.copyWith(
                          fontSize: GoldenRatioHelper.goldenFontSize(context, level: 0, base: 16.0),
                          fontWeight: medium,
                        ),
                      ),
                      if (isNew) ...[
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 6),
                            vertical: ResponsiveHelper.getResponsiveSpacing(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: greenColor,
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 4)),
                          ),
                          child: Text(
                            'Baru',
                            style: whiteTextStyle.copyWith(
                              fontSize: GoldenRatioHelper.goldenFontSize(context, level: -2, base: 14.0),
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                      if (isPremium) ...[
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 6),
                            vertical: ResponsiveHelper.getResponsiveSpacing(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: purpleColor,
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 4)),
                          ),
                          child: Text(
                            'Premium',
                            style: whiteTextStyle.copyWith(
                              fontSize: GoldenRatioHelper.goldenFontSize(context, level: -2, base: 14.0),
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Text(
                      subtitle!,
                      style: greyTextStyle.copyWith(
                        fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 14.0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Badge or trailing icon
            if (showBadge && badgeText != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 8),
                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 4),
                ),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                ),
                child: Text(
                  badgeText!,
                  style: blackTextStyle.copyWith(
                    color: greenColor,
                    fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 14.0),
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ] else if (showTrailing) ...[
              Icon(
                Icons.chevron_right,
                color: greyColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
