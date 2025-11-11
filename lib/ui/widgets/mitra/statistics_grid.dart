import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/mitra/statistic_card.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class StatisticsGrid extends StatelessWidget {
  final VoidCallback onRefresh;

  const StatisticsGrid({super.key, required this.onRefresh});

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
              // Pengambilan Selesai
              StatisticCard(
                title: 'Pengambilan Selesai',
                value: '12',
                valueColor: const Color(0xFF00A643), // Bright green
                icon: Icons.check_circle_outline,
              ),

              // Rating
              StatisticCard(
                title: 'Rating',
                value: '4.8',
                valueColor: blueColor, // Menggunakan blueColor dari theme.dart
                icon: Icons.star_border_rounded,
              ),

              // Waktu Aktif
              StatisticCard(
                title: 'Waktu Aktif',
                value: '7',
                valueColor: blueColor, // Menggunakan blueColor dari theme.dart
                icon: Icons.access_time_outlined,
              ),

              // Pengambilan Menunggu
              StatisticCard(
                title: 'Pengambilan Menunggu',
                value: '17',
                valueColor: const Color(0xFFF97316), // Orange
                icon: Icons.hourglass_empty_rounded,
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
