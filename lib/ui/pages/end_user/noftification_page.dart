import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  late EndUserApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _apiService.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading notifications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(List<int> notificationIds) async {
    final success = await _apiService.markNotificationsAsRead(notificationIds);
    if (success) {
      await _loadNotifications(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppNotif(title: 'Notifikasi', showBackButton: true),
      backgroundColor: uicolor,
      body: _isLoading
          ? _buildSkeletonLoading()
          : _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SkeletonItems.circle(size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonItems.text(height: 16, width: 120),
                    const SizedBox(height: 8),
                    SkeletonItems.text(height: 14, width: double.infinity),
                    const SizedBox(height: 4),
                    SkeletonItems.text(height: 14, width: 200),
                    const SizedBox(height: 8),
                    SkeletonItems.text(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi baru.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        return GestureDetector(
          onTap: () => _markAsRead([notif['id']]),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: notif['read_at'] == null
                  ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getNotificationColor(
                    notif['type'],
                  ).withOpacity(0.1),
                  child: Icon(
                    _getNotificationIcon(notif['type']),
                    color: _getNotificationColor(notif['type']),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'] ?? 'Notifikasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notif['read_at'] == null
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: _getNotificationColor(notif['type']),
                              ),
                            ),
                          ),
                          if (notif['read_at'] == null)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['message'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateTime(notif['created_at']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'schedule':
        return Icons.schedule;
      case 'order':
        return Icons.shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'subscription':
        return Icons.check_circle;
      case 'general':
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'schedule':
        return Colors.blue;
      case 'order':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'subscription':
        return Colors.purple;
      case 'general':
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';

    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }
}

