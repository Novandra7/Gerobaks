import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE4F9E8), // Light green background as per design
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: valueColor.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: blackTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 10 : 11),
                    fontWeight: medium,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 5)),
                decoration: BoxDecoration(
                  color: valueColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: valueColor,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 14),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 22 : 24),
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  letterSpacing: -1.0,
                ),
              ),
              if (title == 'Rating')
                Text(
                  '/5',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 10 : 12),
                    fontWeight: FontWeight.w500,
                    color: valueColor.withOpacity(0.7),
                    height: 2.5,
                  ),
                ),
              if (title == 'Waktu Aktif')
                Text(
                  ' jam',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 10 : 12),
                    fontWeight: FontWeight.w500,
                    color: valueColor.withOpacity(0.7),
                    height: 2.2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatisticsGrid extends StatelessWidget {
  final VoidCallback onRefresh;

  const StatisticsGrid({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

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
        
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 20)),
        
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20)),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
            mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
            childAspectRatio: isSmallScreen ? 1.8 : 2.0,
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
                value: '3',
                valueColor: const Color(0xFFF97316), // Orange
                icon: Icons.hourglass_empty_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context, VoidCallback onRefresh) {
    return InkWell(
      onTap: onRefresh,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 6),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE4F9E8),
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
              style: TextStyle(
                color: greenColor,
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
