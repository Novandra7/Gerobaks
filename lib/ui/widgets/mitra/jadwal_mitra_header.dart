import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

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
    return Container(
      color: Colors.transparent, // Background transparan seperti dashboard
      child: Column(
        children: [
          // AppBar style seperti dashboard
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // === TITLE JADWAL ===
                  Text(
                    'Jadwal Hari Ini',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistics section dengan background putih seperti dashboard
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: ResponsiveHelper.getResponsiveSpacing(context, 20),
              bottom: ResponsiveHelper.getResponsiveSpacing(context, 30),
              left: ResponsiveHelper.getResponsiveSpacing(context, 16),
              right: ResponsiveHelper.getResponsiveSpacing(context, 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [greenColor.withOpacity(0.1), greenColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: greenColor.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: greenColor, size: isSmallScreen ? 20 : 24),
      ),
      SizedBox(height: isSmallScreen ? 8 : 10),
      Text(
        value,
        style: blackTextStyle.copyWith(
          fontSize: isSmallScreen ? 18 : 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(height: 2),
      Text(
        label,
        style: greyTextStyle.copyWith(
          fontSize: isSmallScreen ? 11 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
