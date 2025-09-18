import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isOnline;
  final Function() onToggleOnlineStatus;

  const CustomBottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isOnline,
    required this.onToggleOnlineStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.calendar_month_outlined,
            label: 'Jadwal',
          ),
          _buildOnlineButton(),
          _buildNavItem(
            index: 3,
            icon: Icons.bar_chart_outlined,
            label: 'Laporan',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.person_outline,
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? greenColor : greyColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: isSelected 
                ? greenTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  )
                : greyTextStyle.copyWith(
                    fontSize: 12,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineButton() {
    return GestureDetector(
      onTap: onToggleOnlineStatus,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isOnline ? greenColor : Colors.grey,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? greenColor.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.power_settings_new,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
