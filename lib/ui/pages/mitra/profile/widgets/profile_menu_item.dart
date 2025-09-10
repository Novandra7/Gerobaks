import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showTrailing;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.showTrailing = true,
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
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
              decoration: BoxDecoration(
                color: backgroundColor ?? lightBackgroundColor,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
              ),
              child: Icon(
                icon,
                color: iconColor ?? greenColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 22),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 16)),
            Expanded(
              child: Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ),
            if (showTrailing)
              Icon(
                Icons.chevron_right,
                color: greyColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20),
              ),
          ],
        ),
      ),
    );
  }
}
