import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/notification_count_service.dart';

class NotificationIconWithBadge extends StatefulWidget {
  final VoidCallback? onTap;

  const NotificationIconWithBadge({super.key, this.onTap});

  @override
  State<NotificationIconWithBadge> createState() =>
      _NotificationIconWithBadgeState();
}

class _NotificationIconWithBadgeState extends State<NotificationIconWithBadge> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  void _loadNotificationCount() {
    setState(() {
      _notificationCount = NotificationCountService.getTotalNotificationCount();
    });
  }

  /// Refresh notification count (can be called from parent widgets)
  void refreshCount() {
    _loadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset('assets/ic_notification.png', width: 32, height: 32),
          if (_notificationCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: EdgeInsets.all(_notificationCount > 9 ? 3 : 4),
                decoration: BoxDecoration(
                  color: redcolor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    _notificationCount > 99
                        ? '99+'
                        : _notificationCount.toString(),
                    style: whiteTextStyle.copyWith(
                      fontSize: _notificationCount > 9 ? 9 : 10,
                      fontWeight: bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
