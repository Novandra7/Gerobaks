import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_item_improved.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/services/end_user_api_service.dart';

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
      final schedules = await _apiService.getUserPickupSchedules();

      if (mounted) {
        // Check if there are any status changes
        bool hasChanges = false;
        if (_schedules.length != schedules.length) {
          hasChanges = true;
        } else {
          for (int i = 0; i < schedules.length; i++) {
            final oldSchedule = _schedules.firstWhere(
              (s) => s['id'] == schedules[i]['id'],
              orElse: () => {},
            );

            if (oldSchedule.isNotEmpty &&
                oldSchedule['status'] != schedules[i]['status']) {
              hasChanges = true;

              // Show notification for status change
              final oldStatus = oldSchedule['status'];
              final newStatus = schedules[i]['status'];
              final address = schedules[i]['pickup_address'] ?? 'lokasi Anda';

              if (oldStatus == 'pending' && newStatus == 'accepted') {
                _showStatusChangeNotification(
                  '✅ Jadwal Anda telah diterima oleh mitra!',
                  Colors.green,
                );
              } else if ((oldStatus == 'pending' || oldStatus == 'accepted') &&
                  (newStatus == 'in_progress' || newStatus == 'on_the_way')) {
                _showStatusChangeNotification(
                  '🚛 Mitra sedang menuju ke $address',
                  Colors.blue,
                );
              } else if (newStatus == 'arrived') {
                _showStatusChangeNotification(
                  '� Mitra sudah tiba di lokasi!',
                  Colors.orange,
                );
              } else if (newStatus == 'completed') {
                _showStatusChangeNotification(
                  '✅ Pengambilan sampah selesai! Terima kasih 🎉',
                  Colors.green,
                );
              }
            }
          }
        }

        if (hasChanges) {
          setState(() {
            _schedules = schedules;
          });
        }
      }
    } catch (e) {
      print("❌ Background refresh error: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  void _showStatusChangeNotification(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Lihat',
            textColor: Colors.white,
            onPressed: () {
              // Refresh list to show updated status
              _loadSchedules();
            },
          ),
        ),
      );
    }
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
      final scheduledDate = schedule['scheduled_at'] != null
          ? DateTime.parse(schedule['scheduled_at'])
          : DateTime.now();

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
        return 'Diterima Mitra';
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
    // Active schedules are those that are pending, accepted, in_progress, or arrived
    return status == 'pending' ||
        status == 'accepted' ||
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
            const SizedBox(height: 24),
            // Backend notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Backend sedang memproses data. Silakan coba lagi dalam beberapa saat.',
                      style: blackTextStyle.copyWith(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
