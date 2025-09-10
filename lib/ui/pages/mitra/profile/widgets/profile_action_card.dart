import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  const ProfileActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 10)),
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
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
              Text(
                label,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                  fontWeight: medium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
