import 'package:bank_sha/ui/widgets/shared/notification_icon_with_badge.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bank_sha/models/notification_model.dart';
import 'package:bank_sha/models/mitra_pickup_schedule.dart';
import 'package:bank_sha/services/notification_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/mitra_api_service.dart';
import 'package:bank_sha/ui/pages/end_user/chat/chat_detail_page.dart';
import 'package:bank_sha/ui/pages/mitra/schedule_detail_page.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/app_logger.dart';
import 'package:bank_sha/utils/navigation_service.dart';

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
      AppLogger.error('Failed to initialize NotificationScreen', e);
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
      final response = await _notificationApi.getNotifications(
        page: currentPage,
        isRead: filterIsRead,
      );

      setState(() {
        notifications = response.notifications;
        unreadCount = response.summary.unreadCount;
        isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading notifications', e);
      setState(() {
        isLoading = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat notifikasi: ${e.toString()}'),
            backgroundColor: redcolor,
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
      // Ignored
    }
  }

  /// Mark notification as read
  Future<void> _markAsRead(int id) async {
    try {
      await _notificationApi.markAsRead(id);
      
      // Trigger global badge refresh
      NotificationIconWithBadge.refreshNotifier.value++;
      
      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menandai sebagai dibaca'),
            backgroundColor: redcolor,
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

      // Trigger global badge refresh
      NotificationIconWithBadge.refreshNotifier.value++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$markedCount notifikasi ditandai sudah dibaca'),
            backgroundColor: greenColor,
          ),
        );
      }

      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menandai semua sebagai dibaca'),
            backgroundColor: redcolor,
          ),
        );
      }
    }
  }

  /// Delete notification
  Future<void> _deleteNotification(int id) async {
    try {
      await _notificationApi.deleteNotification(id);
      
      // Trigger global badge refresh
      NotificationIconWithBadge.refreshNotifier.value++;

      setState(() {
        notifications.removeWhere((n) => n.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notifikasi dihapus'),
            backgroundColor: greenColor,
          ),
        );
      }

      await _loadUnreadCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menghapus notifikasi'),
            backgroundColor: redcolor,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Semua Notifikasi?',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        content: Text(
          'Semua notifikasi yang sudah dibaca akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          style: greyTextStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: greyTextStyle.copyWith(fontWeight: medium),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: TextStyle(color: redcolor, fontWeight: semiBold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final deletedCount = await _notificationApi.clearReadNotifications();

      // Trigger global badge refresh
      NotificationIconWithBadge.refreshNotifier.value++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$deletedCount notifikasi dihapus'),
            backgroundColor: greenColor,
          ),
        );
      }

      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menghapus notifikasi'),
            backgroundColor: redcolor,
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
      case 'chat_message':
        _handleChatNavigation(notif);
        break;

      case 'welcome':
        _showNotificationDetail(notif);
        break;

      case 'schedule':
        _handleScheduleNavigation(notif);
        break;

      case 'reminder':
        Navigator.pushNamed(context, '/jadwal');
        break;

      case 'info':
      case 'system':
      case 'promo':
        _showNotificationDetail(notif);
        break;

      default:
        _showNotificationDetail(notif);
        break;
    }
  }

  /// Handle schedule navigation specifically
  Future<void> _handleScheduleNavigation(NotificationModel notif) async {
    final scheduleId = notif.scheduleId;
    if (scheduleId == null) {
      _showNotificationDetail(notif);
      return;
    }

    try {
      setState(() => isLoading = true);

      // Fetch the full schedule object since the route expects MitraPickupSchedule
      final mitraApi = MitraApiService();
      await mitraApi.initialize();
      final schedule = await mitraApi.getScheduleDetail(scheduleId);

      final localStorage = await LocalStorageService.getInstance();
      final userRole = (await localStorage.getUserRole() ?? '')
          .trim()
          .toLowerCase();
      final isMitra =
          userRole == LocalStorageService.roleMitra || userRole == 'admin';

      setState(() => isLoading = false);

      if (mounted) {
        final navigator = NavigationService.navigatorKey?.currentState;
        if (navigator == null) {
          AppLogger.warning('Navigator not ready for schedule navigation');
          // Fallback to local navigator
          if (isMitra) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleDetailPage(schedule: schedule),
              ),
            );
          } else {
            Navigator.pushNamed(context, '/jadwal');
          }
          return;
        }

        if (isMitra) {
          final route = MaterialPageRoute<void>(
            builder: (context) => ScheduleDetailPage(schedule: schedule),
          );
          navigator.push(route);
        } else {
          navigator.pushNamed('/jadwal');
        }
      }
    } catch (e) {
      AppLogger.error('Error in schedule navigation', e);
      setState(() => isLoading = false);
      if (mounted) {
        _showNotificationDetail(notif);
      }
    }
  }

  /// Handle chat navigation specifically
  Future<void> _handleChatNavigation(NotificationModel notif) async {
    try {
      setState(() => isLoading = true);

      final chatService = ChatService();
      await chatService.initializeData();

      final data = notif.data ?? {};
      final roomIdRaw = (data['room_id'] ?? data['chat_room_id'] ?? '')
          .toString();
      final roomId = int.tryParse(roomIdRaw);

      final payloadConversationId =
          (data['conversation_id'] ?? data['chat_conversation_id'] ?? '')
              .toString();
      final pickupScheduleIdRaw =
          (data['pickup_schedule_id'] ?? data['schedule_id'] ?? '').toString();
      final pickupScheduleId = int.tryParse(pickupScheduleIdRaw);

      String? conversationId;
      if (payloadConversationId.isNotEmpty) {
        conversationId = payloadConversationId;
      } else if (pickupScheduleId != null) {
        final counterpartName =
            (data['sender_name'] ?? data['sender'] ?? 'Petugas').toString();
        conversationId = await chatService.getOrCreatePickupConversationFast(
          pickupScheduleId: pickupScheduleId,
          counterpartName: counterpartName,
        );
      } else if (roomId != null) {
        final counterpartName =
            (data['sender_name'] ?? data['sender'] ?? 'User').toString();
        conversationId = await chatService.getOrCreateConversationByRoomId(
          roomId: roomId,
          counterpartName: counterpartName,
        );
      }

      final localStorage = await LocalStorageService.getInstance();
      final userRole = (await localStorage.getUserRole() ?? '')
          .trim()
          .toLowerCase();
      final isMitra =
          userRole == LocalStorageService.roleMitra || userRole == 'admin';

      setState(() => isLoading = false);

      if (mounted) {
        if (conversationId == null || conversationId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data percakapan tidak ditemukan $conversationId'),
              backgroundColor: orangeColor,
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              conversationId: conversationId!,
              viewAsMitra: isMitra,
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error in chat navigation', e);
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka chat: $e'),
            backgroundColor: redcolor,
          ),
        );
      }
    }
  }

  /// Show notification detail dialog
  void _showNotificationDetail(NotificationModel notif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getIconForType(notif),
              color: _getColorForType(notif.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notif.title,
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notif.body ?? notif.message,
                style: greyTextStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                _formatTime(notif.createdAt),
                style: greyTextStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: blueTextStyle.copyWith(fontWeight: medium),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Badge with unread count
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: blackColor),
                onPressed: () {},
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: redcolor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: whiteTextStyle.copyWith(
                        fontSize: 10,
                        fontWeight: bold,
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
                    decoration: BoxDecoration(
                      color: redcolor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: redcolor.withOpacity(0.5),
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
            icon: Icon(
              Icons.done_all,
              color: unreadCount > 0 ? greenColor : greyColor,
            ),
            onPressed: unreadCount > 0 ? _markAllAsRead : null,
            tooltip: 'Tandai semua sudah dibaca',
          ),
          // Clear read notifications
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: blackColor),
            onSelected: (value) {
              if (value == 'clear') {
                _clearReadNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: redcolor),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus yang sudah dibaca',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: greenColor,
          unselectedLabelColor: greyColor,
          indicatorColor: greenColor,
          labelStyle: TextStyle(fontWeight: semiBold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontWeight: regular, fontSize: 14),
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
            Icon(Icons.error_outline, size: 64, color: greyColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: greyTextStyle.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Coba Lagi',
                style: whiteTextStyle.copyWith(fontWeight: medium),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading && notifications.isEmpty) {
      return Center(child: CircularProgressIndicator(color: greenColor));
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: greyColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              filterIsRead == null
                  ? 'Belum ada notifikasi'
                  : filterIsRead!
                  ? 'Belum ada notifikasi yang sudah dibaca'
                  : 'Belum ada notifikasi yang belum dibaca',
              style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              filterIsRead == null
                  ? 'Notifikasi Anda akan muncul di sini'
                  : filterIsRead!
                  ? 'Notifikasi yang sudah dibaca akan muncul di sini'
                  : 'Notifikasi baru akan muncul di sini',
              style: greyTextStyle.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: greenColor,
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: greyColor.withOpacity(0.2)),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Dismissible(
            key: Key('notif_${notif.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteNotification(notif.id);
            },
            background: Container(
              color: redcolor,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: whiteColor, size: 28),
            ),
            child: _buildNotificationTile(notif),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    final priorityColor = _getPriorityColor(notif.priority);
    final typeColor = _getColorForType(notif.type);
    final isUnread = !notif.isRead;

    // Gunakan warna soft mint/teal untuk background yang belum dibaca (Bukan Biru)
    final unreadBgColor = const Color(0xffF1FAF5);

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? unreadBgColor : whiteColor,
        border: Border(
          left: BorderSide(
            color: isUnread ? priorityColor : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isUnread ? whiteColor : typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: typeColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(_getIconForType(notif), color: typeColor, size: 26),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notif.title,
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: isUnread ? bold : semiBold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  notif.priority == 'urgent' ? 'URGENT' : 'BARU',
                  style: whiteTextStyle.copyWith(fontSize: 8, fontWeight: bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: greyTextStyle.copyWith(
                fontSize: 12,
                color: isUnread ? blackColor.withOpacity(0.7) : greyColor,
                fontWeight: isUnread ? medium : regular,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: greyColor),
                const SizedBox(width: 4),
                Text(
                  _formatTime(notif.createdAt),
                  style: greyTextStyle.copyWith(fontSize: 11),
                ),
                const SizedBox(width: 12),
                // Type badge (Dibuat seragam untuk semua type agar lebih bersih)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: greyColor.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    notif.type.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      color: greyColor,
                      fontSize: 9,
                      fontWeight: bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notif),
      ),
    );
  }

  /// Get icon berdasarkan type
  IconData _getIconForType(NotificationModel notif) {
    switch (notif.type) {
      case 'chat_message':
        return Icons.chat_bubble_outline_rounded;
      case 'welcome':
        return Icons.waving_hand_outlined;
      case 'schedule':
        return Icons.calendar_today_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      case 'system':
        return Icons.settings_suggest_rounded;
      case 'promo':
        return Icons.local_offer_outlined;
      default:
        return _getIconFromBackendName(notif.icon);
    }
  }

  /// Get color berdasarkan type
  Color _getColorForType(String type) {
    switch (type) {
      case 'chat_message':
        return blueColor;
      case 'welcome':
        return orangeColor;
      case 'schedule':
        return greenColor;
      case 'reminder':
        return yellowColor;
      case 'info':
        return blueColor;
      case 'system':
        return greyColor;
      case 'promo':
        return purpleColor;
      default:
        return greyColor;
    }
  }

  /// Original icon mapping from backend name
  IconData _getIconFromBackendName(String iconName) {
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
      default:
        return Icons.notifications;
    }
  }

  /// Get priority label
  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'URGENT';
      case 'high':
        return 'TINGGI';
      case 'normal':
        return 'NORMAL';
      case 'low':
        return 'RENDAH';
      default:
        return 'NORMAL';
    }
  }

  /// Get color berdasarkan priority
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return redcolor;
      case 'high':
        return orangeColor;
      case 'normal':
        return greentext; // Hijau Brand (Bukan Biru)
      case 'low':
        return greyColor;
      default:
        return greentext;
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
