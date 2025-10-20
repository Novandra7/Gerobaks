import 'package:bank_sha/services/waste_schedule_service.dart';

class NotificationCountService {
  static final NotificationCountService _instance =
      NotificationCountService._internal();
  factory NotificationCountService() => _instance;
  NotificationCountService._internal();

  /// Get total notification count based on actual notification logic
  static int getTotalNotificationCount() {
    List<Map<String, dynamic>> notifications = _getAllNotifications();
    return notifications.length;
  }

  /// Get all notifications (same logic as NotificationPage)
  static List<Map<String, dynamic>> _getAllNotifications() {
    List<Map<String, dynamic>> notifications = [];

    // Tambahkan notifikasi pengambilan hari ini (jika ada)
    if (WasteScheduleService.hasTodayPickup()) {
      notifications.add(WasteScheduleService.generateTodayNotification());
    }

    // Tambahkan reminder untuk besok
    notifications.add(WasteScheduleService.generateTomorrowReminder());

    // Tambahkan notifikasi sistem lainnya
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

    return notifications;
  }

  /// Get detailed notification breakdown
  static Map<String, int> getNotificationBreakdown() {
    List<Map<String, dynamic>> notifications = _getAllNotifications();

    int wastePickupCount = 0;
    int reminderCount = 0;
    int systemCount = 0;
    int promotionCount = 0;

    for (var notification in notifications) {
      switch (notification['type']) {
        case 'waste_pickup':
          wastePickupCount++;
          break;
        case 'reminder':
          reminderCount++;
          break;
        case 'system':
          systemCount++;
          break;
        case 'promotion':
          promotionCount++;
          break;
      }
    }

    return {
      'waste_pickup': wastePickupCount,
      'reminder': reminderCount,
      'system': systemCount,
      'promotion': promotionCount,
      'total': notifications.length,
    };
  }

  /// Check if there are any notifications
  static bool hasNotifications() {
    return getTotalNotificationCount() > 0;
  }
}
