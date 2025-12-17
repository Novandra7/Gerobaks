import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/mitra/statistic_card.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class StatisticsGrid extends StatelessWidget {
  final VoidCallback onRefresh;
  final Map<String, dynamic>? statistics;
  final bool isLoading;

  const StatisticsGrid({
    super.key,
    required this.onRefresh,
    this.statistics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    // Meningkatkan threshold, hampir semua layar akan dianggap 'kecil' untuk memberikan lebih banyak ruang vertikal
    final isSmallScreen = screenWidth < 500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: ResponsiveHelper.getResponsiveHeight(context, 24),
                    width: ResponsiveHelper.getResponsiveWidth(context, 3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF01A643),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveSpacing(context, 10),
                  ),
                  Text(
                    'Statistik Hari Ini',
                    style: blackTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        isSmallScreen ? 16 : 18,
                      ),
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
              _buildRefreshButton(context, onRefresh),
            ],
          ),
        ),

        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // Tetap menggunakan 2 kolom
            crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
              context,
              12,
            ),
            mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
              context,
              16,
            ), // Menambah spacing vertikal
            childAspectRatio: isSmallScreen
                ? 1.3
                : 1.5, // Mengurangi aspect ratio lebih banyak untuk menambah tinggi card
            children: [
              // 1. Selesai Hari Ini (completed_today)
              StatisticCard(
                title: 'Selesai Hari Ini',
                value: isLoading
                    ? '-'
                    : (statistics?['completed_today']?.toString() ?? '0'),
                valueColor: const Color(0xFF00A643), // Bright green
                icon: Icons.check_circle_outline,
              ),

              // 2. Jadwal Tersedia (available_schedules)
              StatisticCard(
                title: 'Jadwal Tersedia',
                value: isLoading
                    ? '-'
                    : (statistics?['available_schedules']?.toString() ?? '0'),
                valueColor: const Color(0xFFFBBF24), // Kuning/Yellow
                icon: Icons.calendar_today_outlined,
              ),

              // 3. Waktu Aktif (active_hours)
              StatisticCard(
                title: 'Waktu Aktif',
                value: isLoading
                    ? '-'
                    : '${statistics?['active_hours']?.toString() ?? '0'}j',
                valueColor: blueColor, // Blue dari theme
                icon: Icons.access_time_outlined,
              ),

              // 4. Sedang Berjalan (pending_pickups)
              StatisticCard(
                title: 'Sedang Berjalan',
                value: isLoading
                    ? '-'
                    : (statistics?['pending_pickups']?.toString() ?? '0'),
                valueColor: const Color(0xFFF97316), // Orange
                icon: Icons.local_shipping_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getResponsiveRadius(context, 16),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 6),
        ),
        decoration: BoxDecoration(
          // Solid color background menggunakan greenLight dari theme
          color: greenColor, // Menggunakan warna dari theme.dart
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 20),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.refresh_rounded,
              color: whiteColor,
              size: ResponsiveHelper.getResponsiveIconSize(context, 16),
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
            Text(
              'Refresh',
              style: whiteTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
