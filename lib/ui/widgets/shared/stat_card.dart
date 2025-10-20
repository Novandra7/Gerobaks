import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.iconColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // Menghitung ukuran berdasarkan golden ratio dan responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth / 25;

    // Ukuran kartu berdasarkan golden ratio
    final cardWidth = basePadding * 3.2;
    final cardHeight = cardWidth * 1.1;
    final padding = basePadding * 0.4;
    final spacingVertical = basePadding * 0.25;
    final borderRadius = basePadding * 0.8;

    // Font dan icon sizes
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final countFontSize = isSmallScreen ? 18.0 : 20.0;
    final labelFontSize = isSmallScreen ? 10.0 : 12.0;

    return Container(
      width: ResponsiveHelper.getResponsiveWidth(context, cardWidth),
      height: ResponsiveHelper.getResponsiveHeight(context, cardHeight),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: padding,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(context, padding),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: ResponsiveHelper.getResponsiveIconSize(context, iconSize),
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              spacingVertical,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                countFontSize,
              ),
              fontWeight: extraBold,
            ),
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              spacingVertical * 0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                labelFontSize,
              ),
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }
}
