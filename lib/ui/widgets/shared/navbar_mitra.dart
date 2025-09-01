
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class CustomBottomNavBarMitra extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final bool isOnline;
  final Function(bool)? onPowerToggle;

  const CustomBottomNavBarMitra({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    this.isOnline = false,
    this.onPowerToggle,
  });

  @override
  @override
  State<CustomBottomNavBarMitra> createState() => _CustomBottomNavBarMitraState();
}

class _CustomBottomNavBarMitraState extends State<CustomBottomNavBarMitra> {
  late bool isOnline;

  @override
  void initState() {
    super.initState();
    isOnline = widget.isOnline;
  }

  void _togglePower() {
    setState(() {
      isOnline = !isOnline;
    });
    if (widget.onPowerToggle != null) {
      widget.onPowerToggle!(isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);
            final double navHeight = media.size.width < 400 ? 62 : (media.size.width < 600 ? 76 : 88);
            final double navPadBottom = media.padding.bottom + 16;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: navPadBottom),
              height: navHeight + navPadBottom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          icon: Icons.dashboard_rounded,
                          activeIcon: Icons.dashboard,
                          label: 'Dashboard',
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.schedule_outlined,
                          activeIcon: Icons.schedule_rounded,
                          label: 'Jadwal',
                          index: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 0),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          icon: Icons.assessment_outlined,
                          activeIcon: Icons.assessment_rounded,
                          label: 'Laporan',
                          index: 3,
                        ),
                        _buildNavItem(
                          icon: Icons.person_outline_rounded,
                          activeIcon: Icons.person_rounded,
                          label: 'Profil',
                          index: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
  // (FAB power button now handled in Scaffold, not here)
      ],
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    IconData? activeIcon,
    String? imagePath,
    String? activeImagePath,
    required String label,
    required int index,
    bool isImage = false,
  }) {
    final isSelected = widget.currentIndex == index;
    final inactiveColor = const Color(0xFFBDBDBD);
    return InkWell(
      onTap: () => widget.onTabTapped(index),
      borderRadius: BorderRadius.circular(32),
      splashColor: greenColor.withOpacity(0.1),
      highlightColor: greenColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 0, right: 0, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: isSelected ? greenColor.withOpacity(0.12) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isImage
                    ? Image.asset(
                        isSelected ? (activeImagePath ?? imagePath!) : imagePath!,
                        color: isSelected ? greenColor : inactiveColor,
                        width: 22,
                        height: 22,
                        filterQuality: FilterQuality.high,
                      )
                    : Icon(
                        isSelected ? activeIcon ?? icon : icon,
                        color: isSelected ? greenColor : inactiveColor,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              style: isSelected
                  ? greentextstyle2.copyWith(
                      fontSize: 12,
                      fontWeight: semiBold,
                      letterSpacing: 0.2,
                      height: 1.2,
                    )
                  : TextStyle(
                      color: inactiveColor,
                      fontSize: 11,
                      fontWeight: medium,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.1,
                      height: 1.2,
                    ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
