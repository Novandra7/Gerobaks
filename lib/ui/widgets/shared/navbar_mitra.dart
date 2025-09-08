
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

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
  State<CustomBottomNavBarMitra> createState() => _CustomBottomNavBarMitraState();
}

class _CustomBottomNavBarMitraState extends State<CustomBottomNavBarMitra> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);
            
            // Responsif menggunakan ResponsiveHelper
            final double navHeight = ResponsiveHelper.getResponsiveHeight(context, 66);
            
            // Bottom padding that includes safe area
            final double navPadBottom = media.padding.bottom + ResponsiveHelper.getResponsiveSpacing(context, 12);
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
                  topRight: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
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
              padding: EdgeInsets.only(
                left: ResponsiveHelper.getResponsiveSpacing(context, 8), 
                right: ResponsiveHelper.getResponsiveSpacing(context, 8), 
                top: 0, 
                bottom: navPadBottom
              ),
              height: navHeight + navPadBottom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dashboard item
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard',
                    index: 0,
                  ),
                  
                  // Jadwal item
                  _buildNavItem(
                    icon: Icons.schedule_outlined,
                    activeIcon: Icons.schedule,
                    label: 'Jadwal',
                    index: 1,
                  ),
                  
                  // Center placeholder for FAB
                  SizedBox(width: media.size.width * 0.15),
                  
                  // Laporan item
                  _buildNavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    label: 'Laporan',
                    index: 3,
                  ),
                  
                  // Profil item
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person,
                    label: 'Profil',
                    index: 4,
                  ),
                ],
              ),
            );
          },
        ),
        // FAB power button now handled in Scaffold
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
    
    return Expanded(
      child: InkWell(
        onTap: () => widget.onTabTapped(index),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
        splashColor: greenColor.withOpacity(0.1),
        highlightColor: greenColor.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: ResponsiveHelper.getResponsiveHeight(context, 32),
                width: ResponsiveHelper.getResponsiveWidth(context, 32),
                decoration: BoxDecoration(
                  color: isSelected ? greenColor.withOpacity(0.12) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isImage
                      ? Image.asset(
                          isSelected ? (activeImagePath ?? imagePath!) : imagePath!,
                          color: isSelected ? greenColor : inactiveColor,
                          width: ResponsiveHelper.getResponsiveWidth(context, 20),
                          height: ResponsiveHelper.getResponsiveHeight(context, 20),
                          filterQuality: FilterQuality.high,
                        )
                      : Icon(
                          isSelected ? activeIcon ?? icon : icon,
                          color: isSelected ? greenColor : inactiveColor,
                          size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                        ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                style: isSelected
                    ? TextStyle(
                        color: greenColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
                        fontWeight: semiBold,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      )
                    : TextStyle(
                        color: inactiveColor,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                        fontWeight: medium,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
