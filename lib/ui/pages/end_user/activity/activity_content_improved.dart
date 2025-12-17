import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_item_improved.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/services/in_app_notification_service.dart';

class ActivityContentImproved extends StatefulWidget {
  final DateTime? selectedDate;
  final bool showActive;
  final String? filterCategory;
  final String? searchQuery;
  final Future<void> Function()? onRefresh;

  const ActivityContentImproved({
    super.key,
    this.selectedDate,
    required this.showActive,
    this.filterCategory,
    this.searchQuery,
    this.onRefresh,
  });

  @override
  State<ActivityContentImproved> createState() =>
      _ActivityContentImprovedState();
}

class _ActivityContentImprovedState extends State<ActivityContentImproved> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];
  late EndUserApiService _apiService;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Debug mode - Set true untuk lihat log polling
  static const bool _debugMode = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadSchedules();

    // Start auto-refresh timer (setiap 10 detik) untuk detect status changes
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && !_isRefreshing && widget.showActive) {
        // Only auto-refresh if on "Aktif" tab
        _refreshSchedulesInBackground();
      }
    });
  }

  Future<void> _refreshSchedulesInBackground() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      if (_debugMode) print('🔄 [Polling] Checking for schedule updates...');

      final schedules = await _apiService.getUserPickupSchedules();

      if (_debugMode) {
        print('📦 [Polling] Got ${schedules.length} schedules from API');
      }

      if (mounted) {
        // Check if there are any status changes
        bool hasChanges = false;
        if (_schedules.length != schedules.length) {
          hasChanges = true;
          if (_debugMode) {
            print(
              '📊 [Polling] Schedule count changed: ${_schedules.length} → ${schedules.length}',
            );
          }
        } else {
          for (int i = 0; i < schedules.length; i++) {
            final oldSchedule = _schedules.firstWhere(
              (s) => s['id'] == schedules[i]['id'],
              orElse: () => {},
            );

            if (oldSchedule.isNotEmpty &&
                oldSchedule['status'] != schedules[i]['status']) {
              hasChanges = true;

              if (_debugMode) {
                print('');
                print('🔔 [Status Change Detected!]');
                print('   Schedule ID: ${schedules[i]['id']}');
                print('   Old Status: ${oldSchedule['status']}');
                print('   New Status: ${schedules[i]['status']}');
                print('   Address: ${schedules[i]['pickup_address']}');
                print('   Day: ${schedules[i]['schedule_day']}');
                print('   Time: ${schedules[i]['pickup_time_start']}');
                print('');
              }

              // Show notification for status change
              final oldStatus = oldSchedule['status'];
              final newStatus = schedules[i]['status'];
              final address = schedules[i]['pickup_address'] ?? 'lokasi Anda';
              final scheduleDay = schedules[i]['schedule_day'] ?? '';
              final pickupTime = schedules[i]['pickup_time_start'] ?? '';

              if (oldStatus == 'pending' && newStatus == 'accepted') {
                if (_debugMode) print('✅ Showing "Jadwal Diterima" banner...');
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
                if (_debugMode)
                  print('🚛 Showing "Mitra On The Way" banner...');
                InAppNotificationService.show(
                  context: context,
                  title: 'Mitra Dalam Perjalanan 🚛',
                  message: 'Mitra sedang menuju ke $address',
                  subtitle: '$scheduleDay • $pickupTime',
                  type: InAppNotificationType.info,
                  duration: const Duration(seconds: 5),
                );
              } else if (newStatus == 'arrived') {
                if (_debugMode) print('📍 Showing "Mitra Arrived" banner...');
                InAppNotificationService.show(
                  context: context,
                  title: 'Mitra Sudah Tiba! 📍',
                  message: 'Mitra sudah sampai di lokasi penjemputan',
                  subtitle: '$scheduleDay • $pickupTime',
                  type: InAppNotificationType.warning,
                  duration: const Duration(seconds: 5),
                );
              } else if (newStatus == 'completed') {
                if (_debugMode) print('✅ Showing "Pickup Completed" banner...');
                final totalWeight = schedules[i]['total_weight_kg'];
                final points = schedules[i]['total_points'];
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
          }
        }

        if (hasChanges) {
          if (_debugMode) print('♻️ [Polling] Updating UI with new data...');
          setState(() {
            _schedules = schedules;
          });
        } else {
          if (_debugMode) print('⏹️ [Polling] No changes detected');
        }
      }
    } catch (e) {
      if (_debugMode) print('❌ [Polling Error] $e');
    } finally {
      _isRefreshing = false;
    }
  }

  void _showStatusChangeNotificationWithDetails(
    String message,
    Color color,
    String scheduleDay,
    String pickupTime, {
    String? extraInfo,
  }) {
    if (!mounted) return;

    // Tentukan tipe notifikasi berdasarkan message
    InAppNotificationType type;
    String title;
    String body;
    String? subtitle;

    if (message.contains('diterima oleh mitra')) {
      type = InAppNotificationType.success;
      title = 'Jadwal Diterima! 🎉';
      body = 'Mitra telah menerima jadwal penjemputan Anda';
      subtitle = '$scheduleDay • $pickupTime';
    } else if (message.contains('menuju ke')) {
      type = InAppNotificationType.info;
      title = 'Mitra Dalam Perjalanan 🚛';
      body = message.replaceAll('🚛 ', '');
      subtitle = '$scheduleDay • $pickupTime';
    } else if (message.contains('sudah tiba')) {
      type = InAppNotificationType.warning;
      title = 'Mitra Sudah Tiba! 📍';
      body = 'Mitra sudah sampai di lokasi penjemputan';
      subtitle = '$scheduleDay • $pickupTime';
    } else if (message.contains('Pengambilan sampah selesai')) {
      type = InAppNotificationType.completed;
      title = 'Penjemputan Selesai! ✅';
      body = 'Terima kasih telah menggunakan layanan kami';
      subtitle = extraInfo ?? '$scheduleDay • $pickupTime';
    } else {
      type = InAppNotificationType.info;
      title = 'Notifikasi';
      body = message;
      subtitle = '$scheduleDay • $pickupTime';
    }

    // Tampilkan in-app notification banner
    InAppNotificationService.show(
      context: context,
      title: title,
      message: body,
      subtitle: subtitle,
      type: type,
      duration: const Duration(seconds: 5),
      onTap: () {
        // Refresh list saat di-tap
        _loadSchedules();
      },
    );
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Loading schedules from pickup-schedules endpoint...');
      print('   - Show Active: ${widget.showActive}');
      print('   - Date Filter: ${widget.selectedDate}');
      print('   - Category Filter: ${widget.filterCategory}');

      // Use pickup-schedules as primary endpoint (already working and tested!)
      final schedules = await _apiService.getUserPickupSchedules();

      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });

        print('✅ Loaded ${_schedules.length} schedules successfully');
      }
    } catch (e) {
      print("❌ Error loading schedules: $e");
      if (mounted) {
        setState(() {
          _schedules = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(ActivityContentImproved oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When filters change, reload data
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.filterCategory != widget.filterCategory ||
        oldWidget.showActive != widget.showActive ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadSchedules();
    }
  }

  // Build skeleton loading for activity items
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SkeletonItems.card(height: 110),
        );
      },
    );
  }

  List<ActivityModel> getFilteredActivities() {
    // Convert API schedules to ActivityModel objects
    List<ActivityModel> activities = _schedules.map((schedule) {
      // ✅ Parse waktu jadwal dari backend (HANYA gunakan field dari backend)
      // Backend WAJIB mengirim: schedule_date + pickup_time_start ATAU scheduled_at
      DateTime scheduledDate;

      try {
        // Priority 1: Gunakan schedule_date + pickup_time_start (paling akurat)
        if (schedule['schedule_date'] != null &&
            schedule['pickup_time_start'] != null) {
          final dateStr = schedule['schedule_date'].toString(); // "2025-12-15"
          final timeStr = schedule['pickup_time_start']
              .toString(); // "10:00:00"

          // Parse date components
          final dateParts = dateStr.split('-');
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);

          // Parse time components
          final timeParts = timeStr.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          // Create static DateTime
          scheduledDate = DateTime(year, month, day, hour, minute);

          print('✅ Using schedule_date + pickup_time_start: $scheduledDate');
        }
        // Priority 2: Gunakan scheduled_at (alternative)
        else if (schedule['scheduled_at'] != null) {
          scheduledDate = DateTime.parse(schedule['scheduled_at']);

          print('✅ Using scheduled_at: $scheduledDate');
        }
        // ❌ TIDAK ADA FALLBACK - Field harus ada dari backend!
        else {
          // Log error jika field tidak ada
          print(
            '❌ ERROR: Backend tidak mengirim schedule_date, pickup_time_start, atau scheduled_at!',
          );
          print('   Schedule ID: ${schedule['id']}');
          print('   Backend HARUS deploy dengan field yang benar!');

          // Throw exception agar kita tahu ada masalah
          throw Exception(
            'Backend error: Missing required fields (schedule_date, pickup_time_start, scheduled_at). '
            'Backend harus deploy dengan field yang benar!',
          );
        }
      } catch (e) {
        // Log error dengan detail
        print('❌ ERROR parsing schedule datetime: $e');
        print('   Schedule data: $schedule');

        // Re-throw exception agar developer tahu ada masalah
        rethrow;
      }

      // Parse actual_weights jika ada (untuk schedule yang completed)
      List<TrashDetail>? trashDetails;
      int? totalWeight;
      int? totalPoints;

      if (schedule['actual_weights'] != null &&
          schedule['status'] == 'completed') {
        print('🔍 Parsing completed schedule #${schedule['id']}');
        final weights = schedule['actual_weights'];
        print('   📦 Actual weights: $weights');
        trashDetails = [];
        int calculatedWeight = 0;
        int calculatedPoints = 0;

        if (weights is Map) {
          weights.forEach((type, weight) {
            final weightValue = (weight is String)
                ? double.tryParse(weight)?.toInt() ?? 0
                : (weight is num)
                ? weight.toInt()
                : 0;

            // Kalkulasi poin (contoh: 10 poin per kg)
            final points = weightValue * 10;

            calculatedWeight += weightValue;
            calculatedPoints += points;

            print('   ✅ $type: ${weightValue}kg = $points poin');

            trashDetails!.add(
              TrashDetail(
                type: type.toString(),
                weight: weightValue,
                points: points,
                icon: _getTrashIcon(type.toString()),
              ),
            );
          });
        }

        totalWeight = calculatedWeight;
        totalPoints = calculatedPoints;
        print(
          '   📊 Total: ${totalWeight}kg, $totalPoints poin, ${trashDetails.length} jenis',
        );
      }

      // Parse pickup_photos jika ada
      List<String>? photoProofs;
      if (schedule['pickup_photos'] != null) {
        if (schedule['pickup_photos'] is List) {
          photoProofs = (schedule['pickup_photos'] as List)
              .map((p) => p.toString())
              .toList();
        }
      }

      // Get mitra name jika ada
      String? completedBy;
      if (schedule['mitra_name'] != null) {
        completedBy = schedule['mitra_name'].toString();
      }

      return ActivityModel(
        id: schedule['id']?.toString() ?? '',
        title: schedule['service_type'] ?? 'Layanan Sampah',
        address: schedule['pickup_address'] ?? '',
        dateTime: _formatDateTime(scheduledDate),
        status: _mapStatusToReadableStatus(schedule['status']),
        isActive: _isScheduleActive(schedule['status']),
        date: scheduledDate,
        notes: schedule['notes'],
        trashDetails: trashDetails,
        totalWeight: totalWeight,
        totalPoints: totalPoints,
        photoProofs: photoProofs,
        completedBy: completedBy,
      );
    }).toList();

    // Filter berdasarkan tab aktif/riwayat
    activities = activities
        .where((activity) => activity.isActive == widget.showActive)
        .toList();

    // Filter berdasarkan tanggal jika ada
    if (widget.selectedDate != null) {
      activities = activities.where((activity) {
        return activity.date.year == widget.selectedDate!.year &&
            activity.date.month == widget.selectedDate!.month &&
            activity.date.day == widget.selectedDate!.day;
      }).toList();
    }

    // Filter berdasarkan kategori
    if (widget.filterCategory != null && widget.filterCategory != 'Semua') {
      if (widget.filterCategory == 'Lainnya') {
        // Untuk filter "Lainnya", tampilkan yang tidak masuk kategori utama
        final mainCategories = [
          'Dijadwalkan',
          'Menuju Lokasi',
          'Selesai',
          'Dibatalkan',
        ];
        activities = activities
            .where(
              (activity) => !mainCategories.contains(activity.getCategory()),
            )
            .toList();
      } else {
        activities = activities
            .where(
              (activity) => activity.getCategory() == widget.filterCategory,
            )
            .toList();
      }
    }

    // Filter berdasarkan pencarian
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final query = widget.searchQuery!.toLowerCase();
      activities = activities.where((activity) {
        return activity.title.toLowerCase().contains(query) ||
            activity.address.toLowerCase().contains(query) ||
            (activity.notes ?? '').toLowerCase().contains(query);
      }).toList();
    }

    // Urutkan berdasarkan tanggal (yang terbaru di atas)
    activities.sort((a, b) => b.date.compareTo(a.date));

    return activities;
  }

  String _mapStatusToReadableStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'Dijadwalkan';
      case 'accepted':
      case 'on_progress':
        return 'Sedang Diproses'; // ✅ Match dengan activity_item_improved.dart & activity_model_improved.dart
      case 'in_progress':
      case 'on_the_way':
        return 'Mitra Menuju Lokasi';
      case 'arrived':
        return 'Mitra Sudah Tiba';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status?.replaceAll('_', ' ').toUpperCase() ?? 'Unknown';
    }
  }

  bool _isScheduleActive(String? status) {
    // Active schedules are those that are pending, accepted, on_progress, in_progress, or arrived
    return status == 'pending' ||
        status == 'accepted' ||
        status == 'on_progress' || // ✅ Keep on_progress in active tab
        status == 'in_progress' ||
        status == 'on_the_way' ||
        status == 'arrived';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_getDayName(dateTime.weekday)}, ${dateTime.day}/${dateTime.month}/${dateTime.year} - ${_formatTime(dateTime)}';
  }

  String _getDayName(int weekday) {
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTrashIcon(String trashType) {
    final type = trashType.toLowerCase();

    if (type.contains('organik')) {
      return 'assets/ic_transaction_cat1.png';
    } else if (type.contains('plastik')) {
      return 'assets/ic_transaction_cat2.png';
    } else if (type.contains('kertas') || type.contains('paper')) {
      return 'assets/ic_transaction_cat3.png';
    } else if (type.contains('kaca') ||
        type.contains('logam') ||
        type.contains('metal')) {
      return 'assets/ic_transaction_cat4.png';
    } else if (type.contains('elektronik') || type.contains('b3')) {
      return 'assets/ic_transaction_cat5.png';
    }

    return 'assets/ic_trash.png'; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    final filteredActivities = getFilteredActivities();

    if (filteredActivities.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh ?? _loadSchedules,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: filteredActivities.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ActivityItemImproved(
                  activity: filteredActivities[index],
                ),
              );
            },
          ),
        ),
        // Auto-refresh indicator
        if (_isRefreshing && widget.showActive)
          Positioned(
            top: 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Checking updates...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String title = widget.showActive
        ? 'Tidak ada aktivitas aktif'
        : 'Tidak ada riwayat aktivitas';
    String subtitle = widget.showActive
        ? 'Buat jadwal pengambilan sampah baru'
        : 'Belum ada aktivitas yang diselesaikan';

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      title = 'Tidak ditemukan';
      subtitle = 'Coba kata kunci pencarian lain';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.showActive ? Icons.schedule : Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
