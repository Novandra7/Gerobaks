import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 10)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 4)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6)),
            Text(
              label,
              style: blackTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                fontWeight: medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: ResponsiveHelper.getResponsiveHeight(context, 24),
              width: ResponsiveHelper.getResponsiveWidth(context, 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BB38), Color(0xFF009E29)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 2)),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, ResponsiveHelper.isSmallScreen(context) ? 16 : 18),
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
