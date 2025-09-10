import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class EnhancedInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final String? badge;
  final Color? badgeColor;

  const EnhancedInfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.onTap,
    this.showEditIcon = false,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getResponsiveSpacing(context, 8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 8)),
                decoration: BoxDecoration(
                  color: (iconColor ?? greenColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? greenColor,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 18),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: blackTextStyle.copyWith(
                            fontSize: GoldenRatioHelper.goldenFontSize(context, level: 0, base: 14.0),
                            fontWeight: medium,
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsiveSpacing(context, 6),
                              vertical: ResponsiveHelper.getResponsiveSpacing(context, 2),
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor ?? greenColor,
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 4)),
                            ),
                            child: Text(
                              badge!,
                              style: whiteTextStyle.copyWith(
                                fontSize: GoldenRatioHelper.goldenFontSize(context, level: -2, base: 14.0),
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Text(
                      value,
                      style: greyTextStyle.copyWith(
                        fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 14.0),
                      ),
                    ),
                  ],
                ),
              ),
              if (showEditIcon)
                Icon(
                  Icons.edit_outlined,
                  color: greyColor,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
