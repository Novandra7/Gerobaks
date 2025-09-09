import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/mitra/statistic_card.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class StatisticsGrid extends StatelessWidget {
  final VoidCallback onRefresh;

  const StatisticsGrid({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

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
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20)),
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
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                  Text(
                    'Statistik Hari Ini',
                    style: blackTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 16 : 18),
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
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20)),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // Tetap menggunakan 2 kolom
            crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 12),
            mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16), // Menambah spacing vertikal
            childAspectRatio: isSmallScreen ? 1.3 : 1.5, // Mengurangi aspect ratio lebih banyak untuk menambah tinggi card
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
                valueColor: const Color(0xFFEAB308), // Yellow/gold
                icon: Icons.star_border_rounded,
              ),
              
              // Waktu Aktif
              StatisticCard(
                title: 'Waktu Aktif',
                value: '7',
                valueColor: const Color(0xFF3B82F6), // Blue
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
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 6),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC1F2AD), // Warna paling atas (0%)
              const Color(0xFF5CC488), // Warna kedua (55%)
              const Color(0xFF55C080), // Warna ketiga (80%)
              const Color(0xFF46C375), // Warna paling bawah (100%)
            ],
            stops: const [0.0, 0.55, 0.8, 1.0],
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 20)),
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
