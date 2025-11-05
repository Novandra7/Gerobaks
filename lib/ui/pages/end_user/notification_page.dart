import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:bank_sha/services/notification_count_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    List<Map<String, dynamic>> notifications = [];

    // Tambahkan notifikasi pengambilan hari ini (jika ada)
    if (WasteScheduleService.hasTodayPickup()) {
      notifications.add(WasteScheduleService.generateTodayNotification());
    }

    // Tambahkan reminder untuk besok
    notifications.add(WasteScheduleService.generateTomorrowReminder());

    // Tambahkan notifikasi lainnya
    notifications.addAll([
      {
        'id': 'system_update',
        'title': 'Update Aplikasi',
        'message': 'Versi terbaru aplikasi Gerobaks telah tersedia',
        'time': '2 jam lalu',
        'icon': 'system_update',
        'type': 'system',
        'isClickable': false,
        'route': null,
      },
      {
        'id': 'promotion',
        'title': 'Promo Spesial',
        'message':
            'Dapatkan 50 poin extra untuk 10 pengambilan pertama bulan ini!',
        'time': '1 hari lalu',
        'icon': 'local_offer',
        'type': 'promotion',
        'isClickable': false,
        'route': null,
      },
    ]);

    setState(() {
      _notifications = notifications;
    });
  }

  IconData _getNotificationIcon(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'recycling':
        return Icons.recycling;
      case 'warning':
        return Icons.warning;
      case 'delete':
        return Icons.delete_outline;
      case 'schedule':
        return Icons.schedule;
      case 'system_update':
        return Icons.system_update;
      case 'local_offer':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'waste_pickup':
        return greenColor;
      case 'reminder':
        return Colors.orange;
      case 'system':
        return Colors.blue;
      case 'promotion':
        return Colors.purple;
      default:
        return greyColor;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (notification['isClickable'] == true && notification['route'] != null) {
      Navigator.pushNamed(context, notification['route']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive padding based on screen size
    final horizontalPadding = screenWidth < 360 ? 16.0 : 24.0;
    final iconSize = screenWidth < 360 ? 40.0 : 48.0;

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: const CustomAppNotif(title: 'Notifikasi', showBackButton: true),
      body: _notifications.isEmpty
          ? _buildEmptyState(screenHeight)
          : _buildNotificationList(horizontalPadding, iconSize),
    );
  }

  Widget _buildEmptyState(double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: greyColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: medium),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Notifikasi akan muncul di sini ketika ada jadwal pengambilan sampah atau update penting lainnya',
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(double horizontalPadding, double iconSize) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isClickable = notification['isClickable'] == true;

        return _buildNotificationItem(
          notification,
          isClickable,
          iconSize,
          index == _notifications.length - 1, // isLast
        );
      },
    );
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> notification,
    bool isClickable,
    double iconSize,
    bool isLast,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 16 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isClickable
              ? () => _handleNotificationTap(notification)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification, iconSize),
                  const SizedBox(width: 16),
                  _buildNotificationContent(notification),
                  const SizedBox(width: 12),
                  _buildNotificationTrailing(notification, isClickable),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    Map<String, dynamic> notification,
    double iconSize,
  ) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: _getNotificationColor(notification['type']).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationIcon(notification['icon']),
        color: _getNotificationColor(notification['type']),
        size: iconSize * 0.5,
      ),
    );
  }

  Widget _buildNotificationContent(Map<String, dynamic> notification) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification['title'],
            style: blackTextStyle.copyWith(
              fontWeight: semiBold,
              fontSize: 15,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            notification['message'],
            style: greyTextStyle.copyWith(fontSize: 13, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (notification['description'] != null) ...[
            const SizedBox(height: 4),
            Text(
              notification['description'],
              style: greyTextStyle.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationTrailing(
    Map<String, dynamic> notification,
    bool isClickable,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: greyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            notification['time'],
            style: greyTextStyle.copyWith(fontSize: 11, fontWeight: medium),
          ),
        ),
        if (isClickable) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getNotificationColor(
                notification['type'],
              ).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: _getNotificationColor(notification['type']),
              size: 12,
            ),
          ),
        ],
      ],
    );
  }
}
