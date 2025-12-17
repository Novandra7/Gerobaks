import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/services/in_app_notification_service.dart';
import 'package:bank_sha/services/schedule_notification_overlay.dart';
import 'package:bank_sha/services/auth_api_service.dart';

/// Global Notification Polling Service
/// Berjalan di background dan check status perubahan jadwal
/// Tidak perlu berada di activity page untuk terima notifikasi
class GlobalNotificationPollingService {
  // Singleton pattern
  static final GlobalNotificationPollingService _instance =
      GlobalNotificationPollingService._internal();

  factory GlobalNotificationPollingService() => _instance;

  GlobalNotificationPollingService._internal();

  // Services
  EndUserApiService? _apiService;
  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isInitialized = false;
  bool _isStarting = false; // ✅ ADD: Prevent concurrent startPolling calls

  // Cache untuk detect changes
  List<Map<String, dynamic>> _cachedSchedules = [];

  // ✅ ADD: Track which schedule IDs have been notified
  final Set<String> _notifiedScheduleChanges = {};

  // Navigation key untuk show banner dari mana saja
  GlobalKey<NavigatorState>? _navigatorKey;

  // Debug mode
  static const bool _debugMode = true;

  /// Initialize service dengan navigator key
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) {
      if (_debugMode) print('⚠️ [GlobalNotification] Already initialized');
      return;
    }

    try {
      _navigatorKey = navigatorKey;
      _apiService = EndUserApiService();
      await _apiService!.initialize();

      _isInitialized = true;
      if (_debugMode) {
        print('✅ [GlobalNotification] Service initialized');
      }
    } catch (e) {
      if (_debugMode) {
        print('❌ [GlobalNotification] Init error: $e');
      }
    }
  }

  /// Start polling (dipanggil setelah user login)
  Future<void> startPolling() async {
    // ✅ Prevent concurrent calls
    if (_isStarting) {
      if (_debugMode) {
        print('⚠️ [GlobalNotification] Start already in progress, skipping...');
      }
      return;
    }

    if (_isPolling) {
      if (_debugMode) {
        print('⚠️ [GlobalNotification] Already polling, skipping...');
      }
      return;
    }

    _isStarting = true; // ✅ Lock

    try {
      // Auto-initialize if not initialized yet
      if (!_isInitialized) {
        if (_debugMode) {
          print(
            '⚠️ [GlobalNotification] Not initialized yet, initializing now...',
          );
        }

        // Try to get navigator key from existing instance or wait
        if (_navigatorKey == null) {
          if (_debugMode) {
            print(
              '❌ [GlobalNotification] Navigator key not set, cannot start polling',
            );
            print(
              '   Make sure initialize() is called in main.dart with navigator key',
            );
          }
          return;
        }

        // Try to initialize
        try {
          _apiService = EndUserApiService();
          await _apiService!.initialize();
          _isInitialized = true;

          if (_debugMode) {
            print('✅ [GlobalNotification] Auto-initialized successfully');
          }
        } catch (e) {
          if (_debugMode) {
            print('❌ [GlobalNotification] Auto-init error: $e');
          }
          return;
        }
      }

      // Check if user is logged in
      final authService = AuthApiService();
      final token = await authService.getToken();

      if (token == null) {
        if (_debugMode) {
          print('⚠️ [GlobalNotification] No token, user not logged in');
        }
        return;
      }

      _isPolling = true;

      if (_debugMode) {
        print('🚀 [GlobalNotification] Polling started (every 30 seconds)');
      }

      // Load initial schedules
      await _loadInitialSchedules();

      // Start periodic polling
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _checkForUpdates();
      });
    } finally {
      _isStarting = false; // ✅ Unlock
    }
  }

  /// Stop polling (dipanggil saat logout)
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _cachedSchedules.clear();

    if (_debugMode) {
      print('⏹️ [GlobalNotification] Polling stopped');
    }
  }

  /// Load initial schedules (untuk cache)
  Future<void> _loadInitialSchedules() async {
    try {
      if (_apiService == null) return;

      final schedules = await _apiService!.getUserPickupSchedules();
      _cachedSchedules = schedules;

      if (_debugMode) {
        print(
          '📦 [GlobalNotification] Initial cache loaded: ${schedules.length} schedules',
        );
      }
    } catch (e) {
      if (_debugMode) {
        print('❌ [GlobalNotification] Load initial error: $e');
      }
    }
  }

  /// Check for updates (polling method)
  Future<void> _checkForUpdates() async {
    if (!_isPolling) return;

    try {
      if (_apiService == null) {
        if (_debugMode) {
          print('⚠️ [GlobalNotification] API service not available');
        }
        return;
      }

      if (_debugMode) {
        print('🔄 [GlobalNotification] Checking for updates...');
      }

      final schedules = await _apiService!.getUserPickupSchedules();

      if (_debugMode) {
        print('📦 [GlobalNotification] Got ${schedules.length} schedules');
      }

      // Compare dengan cache
      _compareAndNotify(schedules);

      // Update cache
      _cachedSchedules = schedules;
    } catch (e) {
      if (_debugMode) {
        print('❌ [GlobalNotification] Polling error: $e');
      }
    }
  }

  /// Compare schedules dan show notification jika ada perubahan
  void _compareAndNotify(List<Map<String, dynamic>> newSchedules) {
    if (_cachedSchedules.isEmpty) {
      // First load, no comparison needed
      if (_debugMode) {
        print(
          '📋 [GlobalNotification] First load (cache empty), no comparison',
        );
        print('   New schedules: ${newSchedules.length}');
        for (var schedule in newSchedules) {
          print('   - ID: ${schedule['id']}, Status: ${schedule['status']}');
        }
      }
      return;
    }

    if (_debugMode) {
      print('🔍 [GlobalNotification] Comparing schedules...');
      print('   Cached: ${_cachedSchedules.length} schedules');
      print('   New: ${newSchedules.length} schedules');
    }

    for (var newSchedule in newSchedules) {
      final scheduleId = newSchedule['id'];
      final newStatus = newSchedule['status'];

      if (_debugMode) {
        print('   Checking schedule ID: $scheduleId, New Status: $newStatus');
      }

      final cachedSchedule = _cachedSchedules.firstWhere(
        (s) => s['id'] == scheduleId,
        orElse: () => {},
      );

      if (cachedSchedule.isEmpty) {
        // New schedule created
        if (_debugMode) {
          print('   🆕 New schedule detected: $scheduleId');
        }
        continue;
      }

      // Check status change
      final oldStatus = cachedSchedule['status'];

      if (_debugMode) {
        print('   Found in cache: Old Status: $oldStatus');
      }

      if (oldStatus != newStatus) {
        if (_debugMode) {
          print('');
          print('🔔 [GlobalNotification] ⚡ STATUS CHANGE DETECTED! ⚡');
          print('   Schedule ID: $scheduleId');
          print('   Old Status: "$oldStatus"');
          print('   New Status: "$newStatus"');
          print('   Mitra Name: ${newSchedule['mitra_name']}');
          print('   Schedule Day: ${newSchedule['schedule_day']}');
          print('   Pickup Time: ${newSchedule['pickup_time_start']}');
          print('');
        }

        // Show notification banner
        _showNotificationBanner(
          oldStatus: oldStatus,
          newStatus: newStatus,
          schedule: newSchedule,
        );
      } else {
        if (_debugMode) {
          print('   ✓ No status change for schedule $scheduleId');
        }
      }
    }
  }

  /// Show notification popup berdasarkan status change
  void _showNotificationBanner({
    required String oldStatus,
    required String newStatus,
    required Map<String, dynamic> schedule,
  }) {
    if (_debugMode) {
      print('');
      print('📱 [GlobalNotification] _showNotificationBanner called');
      print('   Old Status: "$oldStatus"');
      print('   New Status: "$newStatus"');
      print(
        '   Navigator Key: ${_navigatorKey != null ? "✅ Available" : "❌ NULL"}',
      );
    }

    // Get current context from navigator key
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      if (_debugMode) {
        print('❌ [GlobalNotification] No context available for notification');
        print('   This means:');
        print('   1. Navigator key not properly set in main.dart');
        print('   2. MaterialApp not yet built');
        print('   3. App in background/not mounted');
      }
      return;
    }

    if (_debugMode) {
      print('✅ [GlobalNotification] Context obtained successfully');
      print('   Context widget: ${context.widget.runtimeType}');
      print('   Context mounted: ${context.mounted}');
    }

    // Double check context is still mounted
    if (!context.mounted) {
      if (_debugMode) {
        print('⚠️ [GlobalNotification] Context not mounted, cannot show popup');
      }
      return;
    }

    final scheduleDay = schedule['schedule_day'] ?? '';
    final pickupTime = schedule['pickup_time_start'] ?? '';
    final address = schedule['pickup_address'] ?? 'lokasi Anda';
    final mitraName = schedule['mitra_name'];

    if (_debugMode) {
      print('   Schedule Day: $scheduleDay');
      print('   Pickup Time: $pickupTime');
      print('   Mitra Name: $mitraName');
    }

    // Determine notification type dan message based on backend status flow
    // Status flow: pending → accepted/on_progress → on_the_way → arrived → completed

    if ((oldStatus == 'pending' && newStatus == 'accepted') ||
        (oldStatus == 'pending' && newStatus == 'on_progress')) {
      // Mitra accept jadwal - SHOW POP-UP DIALOG
      // Backend bisa pakai 'accepted' atau 'on_progress'
      if (_debugMode) {
        print('');
        print(
          '🎉 [GlobalNotification] ===== SHOWING "JADWAL DITERIMA" POPUP =====',
        );
        print('');
      }

      ScheduleNotificationOverlay.show(
        context: context,
        title: 'Jadwal Diterima! 🎉',
        message: mitraName != null
            ? 'Mitra $mitraName telah menerima jadwal penjemputan Anda'
            : 'Mitra telah menerima jadwal penjemputan Anda',
        subtitle: '$scheduleDay • $pickupTime',
        type: ScheduleNotificationOverlayType.accepted,
        onTap: () {
          // Optional: Navigate to activity page
          // Navigator.pushNamed(context, '/jadwal');
        },
      );
    } else if ((oldStatus == 'accepted' && newStatus == 'on_the_way') ||
        (oldStatus == 'on_progress' && newStatus == 'on_the_way')) {
      // Mitra sedang dalam perjalanan - SHOW POP-UP DIALOG
      if (_debugMode) {
        print('');
        print(
          '🚛 [GlobalNotification] ===== SHOWING "MITRA ON THE WAY" POPUP =====',
        );
        print('');
      }

      ScheduleNotificationOverlay.show(
        context: context,
        title: 'Mitra Dalam Perjalanan 🚛',
        message: 'Mitra sedang menuju ke $address',
        subtitle: '$scheduleDay • $pickupTime',
        type: ScheduleNotificationOverlayType.onTheWay,
      );
    } else if (oldStatus == 'on_the_way' && newStatus == 'arrived') {
      // Mitra sudah sampai - SHOW POP-UP DIALOG
      if (_debugMode) {
        print('');
        print(
          '📍 [GlobalNotification] ===== SHOWING "MITRA ARRIVED" POPUP =====',
        );
        print('');
      }

      ScheduleNotificationOverlay.show(
        context: context,
        title: 'Mitra Sudah Tiba! 📍',
        message: 'Mitra sudah sampai di lokasi penjemputan',
        subtitle: '$scheduleDay • $pickupTime',
        type: ScheduleNotificationOverlayType.arrived,
      );
    } else if ((oldStatus == 'arrived' && newStatus == 'completed') ||
        (oldStatus == 'on_the_way' && newStatus == 'completed') ||
        (oldStatus == 'accepted' && newStatus == 'completed') ||
        (oldStatus == 'on_progress' && newStatus == 'completed')) {
      // Penjemputan selesai - SHOW POP-UP DIALOG
      // Bisa dari berbagai status sebelumnya ke completed
      if (_debugMode) {
        print('');
        print(
          '✅ [GlobalNotification] ===== SHOWING "PICKUP COMPLETED" POPUP =====',
        );
        print('');
      }

      final totalWeight = schedule['total_weight_kg'];
      final points = schedule['total_points'];
      final subtitle = totalWeight != null && points != null
          ? '$totalWeight kg • +$points poin'
          : '$scheduleDay • $pickupTime';

      ScheduleNotificationOverlay.show(
        context: context,
        title: 'Penjemputan Selesai! ✅',
        message: 'Terima kasih telah menggunakan layanan kami',
        subtitle: subtitle,
        type: ScheduleNotificationOverlayType.completed,
      );
    } else if (newStatus == 'cancelled') {
      // Jadwal dibatalkan - SHOW BANNER (tidak perlu popup untuk cancel)
      if (_debugMode) {
        print('');
        print('❌ [GlobalNotification] ===== SHOWING "CANCELLED" BANNER =====');
        print('');
      }

      InAppNotificationService.show(
        context: context,
        title: 'Jadwal Dibatalkan ❌',
        message: 'Jadwal penjemputan telah dibatalkan',
        subtitle: '$scheduleDay • $pickupTime',
        type: InAppNotificationType.warning,
        duration: const Duration(seconds: 5),
      );
    } else {
      // Status change tidak dikenali
      if (_debugMode) {
        print('');
        print('⚠️ [GlobalNotification] ===== UNHANDLED STATUS CHANGE =====');
        print('   Old Status: "$oldStatus"');
        print('   New Status: "$newStatus"');
        print('   Possible reasons:');
        print('   1. Status skip steps (e.g. pending → arrived)');
        print('   2. Status tidak sesuai flow backend');
        print('   3. Custom status yang belum ditangani');
        print('');
      }
    }
  }

  /// Check if service is running
  bool get isRunning => _isPolling;

  /// Get cached schedules count
  int get cachedSchedulesCount => _cachedSchedules.length;

  /// Force refresh (for manual trigger)
  Future<void> forceRefresh() async {
    if (_debugMode) {
      print('🔄 [GlobalNotification] Force refresh triggered');
    }
    await _checkForUpdates();
  }

  /// Dispose service
  void dispose() {
    stopPolling();
    _apiService = null;
    _navigatorKey = null;
    _isInitialized = false;

    if (_debugMode) {
      print('🗑️ [GlobalNotification] Service disposed');
    }
  }
}
