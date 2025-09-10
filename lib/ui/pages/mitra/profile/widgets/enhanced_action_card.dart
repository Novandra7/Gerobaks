import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/utils/golden_ratio_helper.dart';

class EnhancedActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Widget? badge;
  final bool hasNewContent;

  const EnhancedActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
    this.badge,
    this.hasNewContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final double baseSpacing = 16.0;
    final double horizontalPadding = baseSpacing;
    final double verticalPadding = baseSpacing / GoldenRatioHelper.phi;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: Ink(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(context, horizontalPadding),
              vertical: ResponsiveHelper.getResponsiveSpacing(context, verticalPadding),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
                          decoration: BoxDecoration(
                            color: iconBackgroundColor ?? greenui,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? greenColor,
                            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                          ),
                        ),
                        if (badge != null)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: badge!,
                          ),
                        if (hasNewContent)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: ResponsiveHelper.getResponsiveWidth(context, 10),
                              height: ResponsiveHelper.getResponsiveHeight(context, 10),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                    Text(
                      label,
                      style: blackTextStyle.copyWith(
                        fontSize: GoldenRatioHelper.goldenFontSize(context, level: 0, base: 12.0),
                        fontWeight: medium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (description != null) ...[
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                      Text(
                        description!,
                        style: greyTextStyle.copyWith(
                          fontSize: GoldenRatioHelper.goldenFontSize(context, level: -1, base: 12.0),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
