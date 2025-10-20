import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/ui/widgets/shared/chat_icon_with_badge.dart';

class JadwalMitraHeader extends StatelessWidget {
  final int locationCount;
  final int pendingCount;
  final int completedCount;
  final VoidCallback? onChatPressed;
  final VoidCallback? onNotificationPressed;

  const JadwalMitraHeader({
    super.key,
    required this.locationCount,
    required this.pendingCount,
    required this.completedCount,
    this.onChatPressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate a more adaptive height based on screen size and device density
    final screenHeight = MediaQuery.of(context).size.height;
    // Use a smaller percentage of the screen height
    final headerHeight = screenHeight * 0.34;

    return Container(
      width: double.infinity,
      height: headerHeight, // Reduced fixed height to prevent overflow
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
            ResponsiveHelper.getResponsiveSpacing(
              context,
              12,
            ), // Reduced top padding
        bottom: ResponsiveHelper.getResponsiveSpacing(
          context,
          12,
        ), // Reduced bottom padding
        left: ResponsiveHelper.getResponsiveSpacing(
          context,
          16,
        ), // Slightly reduced horizontal padding
        right: ResponsiveHelper.getResponsiveSpacing(context, 16),
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

          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(context, 10),
          ), // Reduced spacing
          // New Header Content - Jadwal Pengambilan Title
          Text(
            'Jadwal Pengambilan',
            style: whiteTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                20,
              ), // Slightly smaller font
              fontWeight: semiBold,
            ),
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(context, 10),
          ), // Reduced spacing
          // Statistics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: '$locationCount',
              ),
              _buildStatItem(
                context,
                icon: Icons.hourglass_empty_rounded,
                label: 'Menunggu',
                value: '$pendingCount',
              ),
              _buildStatItem(
                context,
                icon: Icons.check_circle_outline_rounded,
                label: 'Selesai',
                value: '$completedCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildStatItem(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  // Get screen size to make adjustments more responsive
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 360;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: EdgeInsets.all(
          isSmallScreen ? 6 : 7, // Smaller padding for small screens
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2, // Reduced blur
              offset: const Offset(0, 1), // Smaller offset
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00A643),
          size: isSmallScreen ? 16 : 18, // Smaller icons
        ),
      ),
      SizedBox(height: isSmallScreen ? 2 : 3), // Less spacing
      Text(
        value,
        style: whiteTextStyle.copyWith(
          fontSize: isSmallScreen ? 16 : 18, // Smaller font for small screens
          fontWeight: bold,
        ),
      ),
      Text(
        label,
        style: whiteTextStyle.copyWith(
          fontSize: isSmallScreen ? 10 : 11, // Smaller font for labels
          fontWeight: medium,
        ),
      ),
    ],
  );
}
