import 'package:flutter/material.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/services/chat_service.dart';

class CustomBottomNavBarMitraNew extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final bool isOnline;
  final Function(bool)? onPowerToggle;
  
  const CustomBottomNavBarMitraNew({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
    this.isOnline = false,
    this.onPowerToggle,
  }) : super(key: key);

  @override
  State<CustomBottomNavBarMitraNew> createState() => _CustomBottomNavBarMitraNewState();
}

class _CustomBottomNavBarMitraNewState extends State<CustomBottomNavBarMitraNew> {
  final ChatService _chatService = ChatService();
  int _unreadCount = 0;
  
  @override
  void initState() {
    super.initState();
    _initChatService();
  }
  
  Future<void> _initChatService() async {
    await _chatService.initializeData();
    _updateUnreadCount();
    
    // Listen for changes in conversations
    _chatService.conversationsStream.listen((_) {
      _updateUnreadCount();
    });
  }
  
  void _updateUnreadCount() {
    final unreadCount = _chatService.getTotalUnreadCount();
    if (mounted && unreadCount != _unreadCount) {
      setState(() {
        _unreadCount = unreadCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
              topRight: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 24)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
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
              // Center placeholder for power button
              Expanded(
                child: SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(context, 60),
                ),
              ),
              _buildNavItem(
                context, 
                icon: Icons.insert_chart_outlined,
                activeIcon: Icons.insert_chart,
                label: 'Laporan',
                index: 3,
              ),
              _buildNavItem(
                context, 
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                index: 4,
              ),
            ],
          ),
        ),
        
        // Power Button
        Transform.translate(
          offset: const Offset(0, -30),
          child: GestureDetector(
            onTap: () {
              if (widget.onPowerToggle != null) {
                widget.onPowerToggle!(!widget.isOnline);
              }
            },
            child: Container(
              width: ResponsiveHelper.getResponsiveWidth(context, 60),
              height: ResponsiveHelper.getResponsiveHeight(context, 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isOnline 
                  ? const LinearGradient(
                      colors: [Color(0xFF37DE7A), Color(0xFF00A643)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      transform: GradientRotation(0.2),
                    )
                  : null,
                color: widget.isOnline ? null : const Color(0xFFE0E0E0),
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isOnline 
                      ? const Color(0xFF01A643).withOpacity(0.3) 
                      : Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: widget.isOnline ? Colors.white : Colors.grey[400],
                  size: ResponsiveHelper.getResponsiveIconSize(context, 30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    int? badge,
  }) {
    final bool isSelected = widget.currentIndex == index;
    final Color inactiveColor = const Color(0xFFBDBDBD);
    
    return Expanded(
      child: InkWell(
        onTap: () => widget.onTabTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10)),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? const Color(0xFF01A643) : inactiveColor,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
                if (badge != null && badge > 0)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF01A643) : inactiveColor,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10)),
          ],
        ),
      ),
    );
  }
}
