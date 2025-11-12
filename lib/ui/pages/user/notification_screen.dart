import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_api_service.dart';
import '../../../services/local_storage_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late NotificationApiService _notificationApi;
  late TabController _tabController;

  List<NotificationModel> notifications = [];
  int unreadCount = 0;
  bool hasUrgent = false;
  bool isLoading = false;
  int currentPage = 1;
  bool? filterIsRead; // null = all, false = unread, true = read
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Initialize services
  Future<void> _initializeServices() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = 'Authentication required. Please login again.';
        });
        return;
      }

      final dio = Dio();
      _notificationApi = NotificationApiService(dio: dio);
      _notificationApi.setAuthToken(token);

      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      print('❌ Error initializing services: $e');
      setState(() {
        _errorMessage = 'Failed to initialize. Please restart the app.';
      });
    }
  }

  /// Load notifications dari API
  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 NotificationScreen: Loading notifications...');
      print('   - Current tab: ${_tabController.index}');
      print('   - Filter isRead: $filterIsRead');
      
      final response = await _notificationApi.getNotifications(
        page: currentPage,
        isRead: filterIsRead,
      );

      print('✅ NotificationScreen: Received ${response.notifications.length} notifications');
      print('   - Unread count: ${response.summary.unreadCount}');

      setState(() {
        notifications = response.notifications;
        unreadCount = response.summary.unreadCount;
        isLoading = false;
      });
    } catch (e) {
      print('❌ NotificationScreen: Error loading notifications');
      print('   - Error type: ${e.runtimeType}');
      print('   - Error message: $e');
      
      setState(() {
        isLoading = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat notifikasi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Load unread count
  Future<void> _loadUnreadCount() async {
    try {
      final response = await _notificationApi.getUnreadCount();
      setState(() {
        unreadCount = response.unreadCount;
        hasUrgent = response.hasUrgent;
      });
    } catch (e) {
      print('⚠️ Error loading unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> _markAsRead(int id) async {
    try {
      await _notificationApi.markAsRead(id);
      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      print('❌ Error marking as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai sebagai dibaca'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mark all notifications as read
  Future<void> _markAllAsRead() async {
    try {
      final result = await _notificationApi.markAllAsRead();
      final markedCount = result['marked_count'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$markedCount notifikasi ditandai sudah dibaca'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      print('❌ Error marking all as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai semua sebagai dibaca'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete notification
  Future<void> _deleteNotification(int id) async {
    try {
      await _notificationApi.deleteNotification(id);
      setState(() {
        notifications.removeWhere((n) => n.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadUnreadCount();
    } catch (e) {
      print('❌ Error deleting notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus notifikasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Clear all read notifications
  Future<void> _clearReadNotifications() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text(
          'Semua notifikasi yang sudah dibaca akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final deletedCount = await _notificationApi.clearReadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deletedCount notifikasi dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      print('❌ Error clearing notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus notifikasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationModel notif) {
    // Mark as read if unread
    if (!notif.isRead) {
      _markAsRead(notif.id);
    }

    // Navigate based on notification type
    switch (notif.type) {
      case 'schedule':
        // Navigate to schedule detail
        if (notif.scheduleId != null) {
          Navigator.pushNamed(
            context,
            '/schedule-detail',
            arguments: notif.scheduleId,
          );
        }
        break;

      case 'reminder':
        // Navigate to schedule list
        Navigator.pushNamed(context, '/schedule');
        break;

      case 'info':
        // Show info detail in dialog
        _showNotificationDetail(notif);
        break;

      case 'system':
      case 'promo':
        // Show detail in dialog
        _showNotificationDetail(notif);
        break;

      default:
        break;
    }
  }

  /// Show notification detail dialog
  void _showNotificationDetail(NotificationModel notif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIcon(notif.icon),
              color: _getPriorityColor(notif.priority),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(notif.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notif.message),
              const SizedBox(height: 16),
              Text(
                _formatTime(notif.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Badge with unread count
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
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
              // Urgent indicator (red dot)
              if (hasUrgent)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: unreadCount > 0 ? _markAllAsRead : null,
            tooltip: 'Tandai semua sudah dibaca',
          ),
          // Clear read notifications
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearReadNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus yang sudah dibaca'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          onTap: (index) {
            setState(() {
              currentPage = 1;
              filterIsRead = index == 0 ? null : (index == 2);
            });
            _loadNotifications();
          },
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Belum Dibaca'),
            Tab(text: 'Sudah Dibaca'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              filterIsRead == null
                  ? 'Belum ada notifikasi'
                  : filterIsRead!
                  ? 'Belum ada notifikasi yang sudah dibaca'
                  : 'Belum ada notifikasi yang belum dibaca',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Dismissible(
            key: Key('notif_${notif.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteNotification(notif.id);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildNotificationTile(notif),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPriorityColor(notif.priority).withOpacity(0.1),
        child: Icon(
          _getIcon(notif.icon),
          color: _getPriorityColor(notif.priority),
        ),
      ),
      title: Text(
        notif.title,
        style: TextStyle(
          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notif.message, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            _formatTime(notif.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!notif.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getPriorityColor(notif.priority),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () => _handleNotificationTap(notif),
    );
  }

  /// Get icon berdasarkan icon name dari backend
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'calendar':
      case 'calendar_today':
        return Icons.calendar_today;
      case 'bell':
      case 'notifications':
        return Icons.notifications;
      case 'check_circle':
        return Icons.check_circle;
      case 'stars':
        return Icons.stars;
      case 'local_offer':
        return Icons.local_offer;
      case 'system_update':
        return Icons.system_update;
      case 'warning':
        return Icons.warning;
      case 'eco':
        return Icons.eco;
      case 'recycling':
        return Icons.recycling;
      case 'delete_outline':
        return Icons.delete_outline;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'cancel':
        return Icons.cancel;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  /// Get color berdasarkan priority
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Format time untuk display
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    return '${time.day}/${time.month}/${time.year}';
  }
}
