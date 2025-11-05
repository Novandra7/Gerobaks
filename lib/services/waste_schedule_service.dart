class WasteScheduleService {
  static final WasteScheduleService _instance =
      WasteScheduleService._internal();
  factory WasteScheduleService() => _instance;
  WasteScheduleService._internal();

  // Jadwal pengambilan sampah per hari
  static const Map<int, Map<String, String>> weeklySchedule = {
    1: {
      // Senin
      'type': 'Organik',
      'description': 'Pengambilan sampah organik (sisa makanan, daun)',
      'time': '06:00',
      'icon': 'eco',
    },
    2: {
      // Selasa
      'type': 'Anorganik',
      'description': 'Pengambilan sampah anorganik (plastik, kaleng)',
      'time': '06:00',
      'icon': 'recycling',
    },
    3: {
      // Rabu
      'type': 'B3',
      'description': 'Pengambilan sampah B3 (baterai, obat, kimia)',
      'time': '06:00',
      'icon': 'warning',
    },
    4: {
      // Kamis
      'type': 'Campuran',
      'description': 'Pengambilan sampah campuran',
      'time': '06:00',
      'icon': 'delete',
    },
    5: {
      // Jumat
      'type': 'Campuran',
      'description': 'Pengambilan sampah campuran',
      'time': '06:00',
      'icon': 'delete',
    },
    6: {
      // Sabtu
      'type': 'Campuran',
      'description': 'Pengambilan sampah campuran',
      'time': '06:00',
      'icon': 'delete',
    },
    7: {
      // Minggu
      'type': 'Campuran',
      'description': 'Pengambilan sampah campuran',
      'time': '06:00',
      'icon': 'delete',
    },
  };

  /// Mendapatkan jadwal untuk hari tertentu
  static Map<String, String>? getScheduleForDay(int weekday) {
    return weeklySchedule[weekday];
  }

  /// Mendapatkan jadwal untuk hari ini
  static Map<String, String>? getTodaySchedule() {
    final today = DateTime.now().weekday;
    return getScheduleForDay(today);
  }

  /// Mendapatkan jadwal untuk besok
  static Map<String, String>? getTomorrowSchedule() {
    final tomorrow = DateTime.now().add(const Duration(days: 1)).weekday;
    return getScheduleForDay(tomorrow);
  }

  /// Mendapatkan nama hari dalam bahasa Indonesia
  static String getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  /// Menghasilkan notifikasi untuk hari ini
  static Map<String, dynamic> generateTodayNotification() {
    final schedule = getTodaySchedule();
    if (schedule == null) return {};

    return {
      'id': 'waste_today',
      'title': 'Pengambilan Sampah ${schedule['type']}',
      'message':
          'Hari ini pengambilan sampah ${schedule['type']?.toLowerCase()}!',
      'description': schedule['description'],
      'time': 'Hari ini, ${schedule['time']}',
      'icon': schedule['icon'],
      'type': 'waste_pickup',
      'isClickable': true,
      'route': '/add-schedule',
    };
  }

  /// Menghasilkan notifikasi reminder untuk besok
  static Map<String, dynamic> generateTomorrowReminder() {
    final schedule = getTomorrowSchedule();
    if (schedule == null) return {};

    final tomorrowDay = getDayName(
      DateTime.now().add(const Duration(days: 1)).weekday,
    );

    return {
      'id': 'waste_tomorrow',
      'title': 'Reminder Pengambilan Sampah',
      'message':
          '$tomorrowDay besok pengambilan sampah ${schedule['type']?.toLowerCase()}',
      'description':
          'Siapkan sampah ${schedule['type']?.toLowerCase()} untuk besok',
      'time': 'Besok, ${schedule['time']}',
      'icon': 'schedule',
      'type': 'reminder',
      'isClickable': false,
      'route': null,
    };
  }

  /// Mendapatkan jadwal mingguan lengkap
  static List<Map<String, dynamic>> getWeeklySchedule() {
    List<Map<String, dynamic>> schedule = [];

    for (int day = 1; day <= 7; day++) {
      final daySchedule = getScheduleForDay(day);
      if (daySchedule != null) {
        schedule.add({
          'day': getDayName(day),
          'dayNumber': day,
          'type': daySchedule['type'],
          'description': daySchedule['description'],
          'time': daySchedule['time'],
          'icon': daySchedule['icon'],
        });
      }
    }

    return schedule;
  }

  /// Cek apakah hari ini ada pengambilan sampah
  static bool hasTodayPickup() {
    return getTodaySchedule() != null;
  }

  /// Mendapatkan waktu pengambilan hari ini
  static String? getTodayPickupTime() {
    final schedule = getTodaySchedule();
    return schedule?['time'];
  }

  /// Mendapatkan jenis sampah hari ini
  static String? getTodayWasteType() {
    final schedule = getTodaySchedule();
    return schedule?['type'];
  }
}
