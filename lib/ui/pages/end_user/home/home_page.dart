import 'dart:async';
import 'package:bank_sha/ui/pages/end_user/popupiklan.dart';
import 'package:bank_sha/ui/pages/end_user/wilayah/wilayah_page.dart';
import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:bank_sha/services/popup_notification_service.dart';
import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/services/in_app_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_page_improved.dart';
import 'package:bank_sha/ui/pages/end_user/profile/profile_page.dart';
import 'package:bank_sha/ui/pages/end_user/home/home_content.dart';
import 'package:bank_sha/ui/widgets/shared/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _activityPageKey = 0; // Key to force activity page refresh

  // Global polling untuk semua page
  Timer? _globalPollingTimer;
  late EndUserApiService _apiService;
  List<Map<String, dynamic>> _cachedSchedules = [];
  bool _isPolling = false;

  // Debug mode
  static const bool _debugMode = true;

  List<Widget> _buildPages() => [
    const HomeContent(),
    ActivityPageImproved(key: ValueKey(_activityPageKey)),
    const WilayahPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize API service dan start global polling
    _initializeGlobalPolling();

    // Tampilkan popup iklan, lalu notifikasi jadwal setelah iklan ditutup
    _showInitialPopups();
  }

  @override
  void dispose() {
    _globalPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeGlobalPolling() async {
    try {
      _apiService = EndUserApiService();
      await _apiService.initialize();

      // Load initial schedules
      final schedules = await _apiService.getUserPickupSchedules();
      _cachedSchedules = schedules;

      if (_debugMode) {
        print(
          '✅ [Global Polling] Initialized with ${schedules.length} schedules',
        );
      }

      // Start polling every 10 seconds
      _globalPollingTimer = Timer.periodic(const Duration(seconds: 10), (
        timer,
      ) {
        if (mounted && !_isPolling) {
          _checkForScheduleUpdates();
        }
      });

      if (_debugMode) {
        print('🚀 [Global Polling] Timer started (10 second interval)');
      }
    } catch (e) {
      if (_debugMode) {
        print('❌ [Global Polling] Init error: $e');
      }
    }
  }

  Future<void> _checkForScheduleUpdates() async {
    if (_isPolling || !mounted) return;

    _isPolling = true;
    try {
      if (_debugMode) print('🔄 [Global Polling] Checking for updates...');

      final schedules = await _apiService.getUserPickupSchedules();

      if (_debugMode) {
        print('📦 [Global Polling] Got ${schedules.length} schedules');
      }

      // Compare with cache to detect status changes
      for (var newSchedule in schedules) {
        final scheduleId = newSchedule['id'];
        final newStatus = newSchedule['status'];

        final cachedSchedule = _cachedSchedules.firstWhere(
          (s) => s['id'] == scheduleId,
          orElse: () => {},
        );

        if (cachedSchedule.isNotEmpty) {
          final oldStatus = cachedSchedule['status'];

          if (oldStatus != newStatus) {
            // Show popup notification
            _showScheduleStatusPopup(oldStatus, newStatus, newSchedule);
          }
        }
      }

      // Update cache
      _cachedSchedules = schedules;
    } catch (e) {
      if (_debugMode) {
        print('❌ [Global Polling] Error: $e');
      }
    } finally {
      _isPolling = false;
    }
  }

  String _getCurrentPageName() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Activity';
      case 2:
        return 'Wilayah';
      case 3:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }

  void _showScheduleStatusPopup(
    String oldStatus,
    String newStatus,
    Map<String, dynamic> schedule,
  ) {
    if (!mounted) return;

    final scheduleDay = schedule['schedule_day'] ?? '';
    final pickupTime = schedule['pickup_time_start'] ?? '';
    final address = schedule['pickup_address'] ?? 'lokasi Anda';

    if (oldStatus == 'pending' && newStatus == 'accepted') {
      if (_debugMode) print('🎉 [Global Polling] Showing ACCEPTED banner');
      InAppNotificationService.show(
        context: context,
        title: 'Jadwal Diterima! 🎉',
        message: 'Mitra telah menerima jadwal penjemputan Anda',
        subtitle: '$scheduleDay • $pickupTime',
        type: InAppNotificationType.success,
        duration: const Duration(seconds: 5),
      );
    } else if ((oldStatus == 'pending' || oldStatus == 'accepted') &&
        (newStatus == 'in_progress' || newStatus == 'on_the_way')) {
      if (_debugMode) print('🚛 [Global Polling] Showing ON THE WAY banner');
      InAppNotificationService.show(
        context: context,
        title: 'Mitra Dalam Perjalanan 🚛',
        message: 'Mitra sedang menuju ke $address',
        subtitle: '$scheduleDay • $pickupTime',
        type: InAppNotificationType.info,
        duration: const Duration(seconds: 5),
      );
    } else if (newStatus == 'arrived') {
      if (_debugMode) print('📍 [Global Polling] Showing ARRIVED banner');
      InAppNotificationService.show(
        context: context,
        title: 'Mitra Sudah Tiba! 📍',
        message: 'Mitra sudah sampai di lokasi penjemputan',
        subtitle: '$scheduleDay • $pickupTime',
        type: InAppNotificationType.warning,
        duration: const Duration(seconds: 5),
      );
    } else if (newStatus == 'completed') {
      if (_debugMode) print('✅ [Global Polling] Showing COMPLETED banner');
      final totalWeight = schedule['total_weight_kg'];
      final points = schedule['total_points'];
      final subtitle = totalWeight != null && points != null
          ? '$totalWeight kg • +$points poin'
          : '$scheduleDay • $pickupTime';
      InAppNotificationService.show(
        context: context,
        title: 'Penjemputan Selesai! ✅',
        message: 'Terima kasih telah menggunakan layanan kami',
        subtitle: subtitle,
        type: InAppNotificationType.completed,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showInitialPopups() async {
    try {
      // Tunggu sebentar setelah build selesai
      await Future.delayed(const Duration(milliseconds: 500));

      // Tampilkan popup iklan dan tunggu sampai ditutup
      await showIklanPopup(context);

      // Setelah popup iklan ditutup, tampilkan notifikasi jadwal (jika ada)
      if (mounted && WasteScheduleService.hasTodayPickup()) {
        // Beri jeda sebentar untuk transisi yang smooth
        await Future.delayed(const Duration(milliseconds: 300));
        PopupNotificationService.showWasteScheduleNotification(context);
      }
    } catch (e) {
      // Jika ada error dengan popup iklan, tetap tampilkan notifikasi jadwal
      if (mounted && WasteScheduleService.hasTodayPickup()) {
        await Future.delayed(const Duration(milliseconds: 800));
        PopupNotificationService.showWasteScheduleNotification(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () async {
            // Allow adding schedule without subscription requirement
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<ScheduleBloc>(),
                  child: const AddSchedulePage(),
                ),
              ),
            );

            // If schedule was created successfully, refresh activity page
            if (result == true) {
              // Increment key to force activity page rebuild
              setState(() {
                _activityPageKey++; // Increment key to force rebuild
                print(
                  '🔄 Schedule created successfully, refreshing activity page...',
                );
              });

              // If user not on activity tab, switch to it to show the new schedule
              if (_currentIndex != 1) {
                setState(() {
                  _currentIndex = 1; // Switch to activity tab
                });
              }
            }
          },
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white, width: 3),
          ),
          backgroundColor: greenColor,
          child: Icon(Icons.add_rounded, color: whiteColor, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildPages()[_currentIndex],
      ),
    );
  }
}
