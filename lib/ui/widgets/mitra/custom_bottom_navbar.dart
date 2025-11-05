import 'package:flutter/material.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class CustomBottomNavBarMitraNew extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const CustomBottomNavBarMitraNew({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  State<CustomBottomNavBarMitraNew> createState() =>
      _CustomBottomNavBarMitraNewState();
}

class _CustomBottomNavBarMitraNewState
    extends State<CustomBottomNavBarMitraNew> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 24),
          ),
          topRight: Radius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 24),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            index: 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Jadwal',
            index: 1,
          ),
          _buildNavItem(
            context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = widget.currentIndex == index;
    final Color activeColor = const Color(0xFF01A643);
    final Color inactiveColor = const Color(0xFFBDBDBD);

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTabTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: ResponsiveHelper.getResponsiveIconSize(context, 26),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
