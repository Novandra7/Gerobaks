import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const FilterTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    // Menghitung ukuran berdasarkan golden ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final basePadding = screenWidth / 25;
    final tabHeight = basePadding * 1.8;
    final borderRadius = basePadding * 0.6;
    final fontSize = isSmallScreen ? 12.0 : 14.0;

    final Color activeColor = selectedColor ?? greenColor;
    final Color inactiveColor = unselectedColor ?? Colors.white;
    final Color activeTextColor = selectedTextColor ?? Colors.white;
    final Color inactiveTextColor = unselectedTextColor ?? greenColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.getResponsiveRadius(context, borderRadius),
      ),
      child: Container(
        height: ResponsiveHelper.getResponsiveHeight(context, tabHeight),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, borderRadius),
          ),
          border: Border.all(color: activeColor, width: 1.5),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeTextColor : inactiveTextColor,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, fontSize),
            fontWeight: isSelected ? semiBold : medium,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
