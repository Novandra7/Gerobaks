import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/notification_api_service.dart';
import '../services/local_storage_service.dart';

/// Widget untuk menampilkan badge notifikasi dengan unread count
/// dan indicator urgent (red dot)
class NotificationBadge extends StatefulWidget {
  final VoidCallback? onTap;
  final bool showLabel;
  final double iconSize;

  const NotificationBadge({
    super.key,
    this.onTap,
    this.showLabel = true,
    this.iconSize = 24,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  NotificationApiService? _notificationApi;
  int unreadCount = 0;
  bool hasUrgent = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    await _initializeServices();
    if (_isInitialized) {
      await loadUnreadCount();
    }
  }

  Future<void> _initializeServices() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null || token.isEmpty) {
        print('⚠️ NotificationBadge: No auth token');
        return;
      }

      final dio = Dio();
      _notificationApi = NotificationApiService(dio: dio);
      _notificationApi!.setAuthToken(token);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('❌ NotificationBadge: Error initializing: $e');
    }
  }

  /// Load unread count dari API
  Future<void> loadUnreadCount() async {
    if (_notificationApi == null) return;

    try {
      final response = await _notificationApi!.getUnreadCount();
      if (mounted) {
        setState(() {
          unreadCount = response.unreadCount;
          hasUrgent = response.hasUrgent;
        });
      }
    } catch (e) {
      print('⚠️ NotificationBadge: Error loading unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: widget.iconSize),
          onPressed: widget.onTap,
        ),

        // Badge dengan unread count
        if (widget.showLabel && unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Urgent indicator (red dot with glow effect)
        if (hasUrgent)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 10,
              height: 10,
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
    );
  }
}

/// Widget untuk menampilkan notification icon dengan badge di AppBar
class NotificationAppBarIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const NotificationAppBarIcon({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      onTap:
          onPressed ??
          () {
            Navigator.pushNamed(context, '/notifications');
          },
    );
  }
}
