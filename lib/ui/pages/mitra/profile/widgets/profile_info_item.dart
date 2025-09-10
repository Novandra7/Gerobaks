import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;

  const ProfileInfoItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 6)),
          decoration: BoxDecoration(
            color: (iconColor ?? greenColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 8)),
          ),
          child: Icon(
            icon,
            color: iconColor ?? greenColor,
            size: ResponsiveHelper.getResponsiveIconSize(context, 16),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: blackTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  fontWeight: medium,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
              Text(
                value,
                style: greyTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
