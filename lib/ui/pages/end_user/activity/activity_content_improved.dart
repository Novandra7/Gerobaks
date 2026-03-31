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

  const ActivityContentImproved({
    super.key,
    this.selectedDate,
    required this.showActive,
    this.filterCategory,
    this.searchQuery,
  });

  @override
  State<ActivityContentImproved> createState() =>
      _ActivityContentImprovedState();
}

class _ActivityContentImprovedState extends State<ActivityContentImproved>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  bool _isFirstLoad = true;
  List<Map<String, dynamic>> _schedules = [];
  late EndUserApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (_isFirstLoad) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final schedules = await _apiService.getUserPickupSchedules();
      final activeSchedules = schedules.where((schedule) {
        final deletedAt = schedule['deleted_at'];
        if (deletedAt == null) return true;
        if (deletedAt is String && deletedAt.trim().isEmpty) return true;
        return false;
      }).toList();

      if (mounted) {
        setState(() {
          _schedules = activeSchedules;
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _schedules = [];
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
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
        }
        // ❌ TIDAK ADA FALLBACK - Field harus ada dari backend!
        else {
          // Throw exception agar kita tahu ada masalah
          throw Exception(
            'Backend error: Missing required fields (schedule_date, pickup_time_start, scheduled_at). '
            'Backend harus deploy dengan field yang benar!',
          );
        }
      } catch (e) {
        // Re-throw exception agar developer tahu ada masalah
        rethrow;
      }

      // Parse actual_weights jika ada (untuk schedule yang completed)
      List<TrashDetail>? trashDetails;
      int? totalWeight;
      int? totalPoints;

      if (schedule['actual_weights'] != null &&
          schedule['status'] == 'completed') {
        final weights = schedule['actual_weights'];
        trashDetails = [];
        int calculatedWeight = 0;

        int parseWeightToInt(dynamic value) {
          if (value is num) return value.toInt();
          if (value is String) {
            return double.tryParse(value.trim().replaceAll(',', '.'))?.toInt() ?? 0;
          }
          return 0;
        }

        if (weights is Map) {
          weights.forEach((type, weight) {
            final weightValue = parseWeightToInt(weight);
            final points = weightValue * 10;

            calculatedWeight += weightValue;

            trashDetails!.add(
              TrashDetail(
                type: type.toString(),
                weight: weightValue,
                points: points,
                icon: _getTrashIcon(type.toString()),
              ),
            );
          });
        } else if (weights is List) {
          for (final item in weights) {
            if (item is! Map) continue;
            final type = item['type']?.toString();
            if (type == null || type.trim().isEmpty) continue;

            final weightValue = parseWeightToInt(item['weight']);
            final points = weightValue * 10;

            calculatedWeight += weightValue;

            trashDetails.add(
              TrashDetail(
                type: type,
                weight: weightValue,
                points: points,
                icon: _getTrashIcon(type),
              ),
            );
          }
        }

        if (trashDetails.isEmpty) {
          trashDetails = null;
        }

        totalWeight = parseWeightToInt(schedule['total_weight']);
        totalWeight = totalWeight > 0 ? totalWeight : calculatedWeight;

        if (schedule['total_points'] is num) {
          totalPoints = (schedule['total_points'] as num).toInt();
        } else {
          final pointsFromApi = int.tryParse(schedule['total_points']?.toString() ?? '');
          totalPoints = pointsFromApi ?? (totalWeight * 10);
        }
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

      final wasteSummary = schedule['waste_summary']?.toString().trim();
      final wasteTypeScheduled = schedule['waste_type_scheduled']?.toString().trim();

      return ActivityModel(
        id: schedule['id']?.toString() ?? '',
        title: (wasteSummary != null && wasteSummary.isNotEmpty)
            ? 'Pickup $wasteSummary'
            : (wasteTypeScheduled != null && wasteTypeScheduled.isNotEmpty)
                ? 'Pickup $wasteTypeScheduled'
                : 'Layanan Sampah',
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
      case 'assigned':
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
        status == 'assigned' ||
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
    super.build(context); // required by AutomaticKeepAliveClientMixin
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    final filteredActivities = getFilteredActivities();

    if (filteredActivities.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ActivityItemImproved(
              activity: filteredActivities[index],
              onCancelled: _loadSchedules,
            ),
          );
        },
      ),
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
