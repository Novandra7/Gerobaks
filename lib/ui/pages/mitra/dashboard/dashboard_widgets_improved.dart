import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class DashboardNotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardNotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
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
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: blackTextStyle.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 14 : 16),
                          fontWeight: semiBold,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                      Text(
                        message,
                        style: greyTextStyle.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 16 : 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 14)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 28),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: blackTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 14 : 16),
                        fontWeight: bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
                    Text(
                      subtitle,
                      style: greyTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 11 : 12),
                        fontWeight: medium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
    

class RefreshButton extends StatelessWidget {
  final VoidCallback onTap;

  const RefreshButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 6),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFD7ECD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 20)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.refresh_rounded,
              color: greenColor,
              size: ResponsiveHelper.getResponsiveIconSize(context, 14),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
            Text(
              'Refresh',
              style: greentextstyle2.copyWith(
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
