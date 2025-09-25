import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/ui/widgets/shared/chat_icon_with_badge.dart';

class DashboardHeader extends StatelessWidget {
  final String name;
  final String vehicleNumber;
  final String driverId;
  final VoidCallback onChatPressed;
  final VoidCallback onNotificationPressed;
  final List<QuickActionItem> quickActions;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.vehicleNumber,
    required this.driverId,
    required this.onChatPressed,
    required this.onNotificationPressed,
    required this.quickActions,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Pagi';
    } else if (hour < 15) {
      return 'Siang';
    } else if (hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF37DE7A), Color(0xFF00A643)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          transform: GradientRotation(0.2),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 30),
          ),
          bottomRight: Radius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 30),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A643).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top:
            MediaQuery.of(context).padding.top +
            ResponsiveHelper.getResponsiveSpacing(context, 16),
        bottom: ResponsiveHelper.getResponsiveSpacing(context, 20),
        left: ResponsiveHelper.getResponsiveSpacing(context, 20),
        right: ResponsiveHelper.getResponsiveSpacing(context, 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with logo and notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/img_gerobakss.png',
                height: ResponsiveHelper.getResponsiveHeight(context, 28),
                color: Colors.white,
              ),
              Row(
                children: [
                  // Chat icon with badge
                  Container(
                    margin: EdgeInsets.only(
                      right: ResponsiveHelper.getResponsiveSpacing(context, 8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ChatIconWithBadge(
                      onTap: onChatPressed,
                      iconColor: Colors.white,
                      forHeader: true,
                      iconSize: ResponsiveHelper.getResponsiveIconSize(
                        context,
                        22,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveSpacing(context, 4),
                  ),
                  // Notification icon
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: IconButton(
                      onPressed: onNotificationPressed,
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          22,
                        ),
                      ),
                      tooltip: 'Notifikasi',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          22,
                        ),
                        minHeight: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),

          // Vehicle info
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.white.withOpacity(0.9),
                size: ResponsiveHelper.getResponsiveIconSize(context, 14),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveSpacing(context, 6),
              ),
              Text(
                vehicleNumber,
                style: whiteTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: medium,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveSpacing(context, 16),
              ),
              Icon(
                Icons.badge_outlined,
                color: Colors.white.withOpacity(0.9),
                size: ResponsiveHelper.getResponsiveIconSize(context, 14),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveSpacing(context, 6),
              ),
              Text(
                driverId,
                style: whiteTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: medium,
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10)),

          // Greeting with name
          Text(
            'Selamat ${_getGreeting()}, $name',
            style: whiteTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
              fontWeight: semiBold,
            ),
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24)),

          // Quick Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: quickActions.map((action) {
              return _buildQuickAction(
                context,
                icon: action.icon,
                label: action.label,
                onTap: action.onTap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getResponsiveRadius(context, 16),
      ),
      child: Container(
        width: ResponsiveHelper.getResponsiveWidth(context, 65),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 10),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 16),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6)),
            Text(
              label,
              style: whiteTextStyle.copyWith(
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

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
