import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/notification_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationIconWithBadge extends StatefulWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double? iconSize;
  final bool useAssetIcon;

  // Global notifier to trigger refresh from anywhere in the app
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  const NotificationIconWithBadge({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize,
    this.useAssetIcon = true,
  });

  @override
  State<NotificationIconWithBadge> createState() =>
      _NotificationIconWithBadgeState();
}

class _NotificationIconWithBadgeState extends State<NotificationIconWithBadge> {
  int _notificationCount = 0;
  bool _hasUrgent = false;
  NotificationApiService? _notificationApi;
  StreamSubscription<RemoteMessage>? _messagingSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();

    // Listen for incoming notifications while app is in foreground
    _messagingSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        _loadNotificationCount();
      }
    });

    // Listen for manual refresh triggers (e.g. after marking as read)
    NotificationIconWithBadge.refreshNotifier.addListener(_loadNotificationCount);
  }

  @override
  void dispose() {
    _messagingSubscription?.cancel();
    NotificationIconWithBadge.refreshNotifier.removeListener(_loadNotificationCount);
    super.dispose();
  }

  Future<void> _initializeAndLoad() async {
    await _initializeService();
    if (_notificationApi != null) {
      await _loadNotificationCount();
    }
  }

  Future<void> _initializeService() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token != null && token.isNotEmpty) {
        final dio = Dio();
        _notificationApi = NotificationApiService(dio: dio);
        _notificationApi!.setAuthToken(token);
      }
    } catch (e) {
      print('⚠️ NotificationIcon: Error initializing: $e');
    }
  }

  Future<void> _loadNotificationCount() async {
    if (_notificationApi == null) return;

    try {
      final response = await _notificationApi!.getUnreadCount();
      if (mounted) {
        setState(() {
          _notificationCount = response.unreadCount;
          _hasUrgent = response.hasUrgent;
        });
      }
    } catch (e) {
      print('⚠️ NotificationIcon: Error loading count: $e');
    }
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
          // Use either asset icon or Material icon based on useAssetIcon parameter
          widget.useAssetIcon
              ? Image.asset(
                  'assets/ic_notification.png',
                  width: widget.iconSize ?? 32,
                  height: widget.iconSize ?? 32,
                )
              : Icon(
                  Icons.notifications_outlined,
                  color: widget.iconColor ?? Colors.black,
                  size: widget.iconSize ?? 32,
                ),

          // Badge with count
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

          // Urgent indicator (pulsing red dot)
          if (_hasUrgent && _notificationCount > 0)
            Positioned(
              left: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
