import 'package:flutter/material.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_item_improved.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/services/end_user_api_service.dart';

/// Tab untuk schedule dengan status: completed
/// Menampilkan jadwal yang sudah selesai
/// Fitur: Points breakdown, Photo proofs, Rating mitra
class CompletedTab extends StatefulWidget {
  final DateTime? selectedDate;
  final String? searchQuery;

  const CompletedTab({
    super.key,
    this.selectedDate,
    this.searchQuery,
  });

  @override
  State<CompletedTab> createState() => _CompletedTabState();
}

class _CompletedTabState extends State<CompletedTab>
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

  List<ActivityModel> _getFilteredActivities() {
    // Filter hanya status 'completed'
    final completedSchedules = _schedules.where((schedule) {
      return schedule['status'] == 'completed';
    }).toList();

    // Convert ke ActivityModel
    List<ActivityModel> activities = completedSchedules.map((schedule) {
      DateTime scheduledDate;

      try {
        if (schedule['schedule_date'] != null &&
            schedule['pickup_time_start'] != null) {
          final dateStr = schedule['schedule_date'].toString();
          final timeStr = schedule['pickup_time_start'].toString();

          final dateParts = dateStr.split('-');
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);

          final timeParts = timeStr.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          scheduledDate = DateTime(year, month, day, hour, minute);
        } else if (schedule['scheduled_at'] != null) {
          scheduledDate = DateTime.parse(schedule['scheduled_at']);
        } else {
          throw Exception('Missing schedule date fields');
        }
      } catch (e) {
        rethrow;
      }

      // Parse actual_weights
      List<TrashDetail>? trashDetails;
      int? totalWeight;
      int? totalPoints;

      if (schedule['actual_weights'] != null) {
        final weights = schedule['actual_weights'];
        trashDetails = [];
        int calculatedWeight = 0;

        int parseWeightToInt(dynamic value) {
          if (value is num) return value.toInt();
          if (value is String) {
            return double.tryParse(value.trim().replaceAll(',', '.'))?.toInt() ??
                0;
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
          final pointsFromApi =
              int.tryParse(schedule['total_points']?.toString() ?? '');
          totalPoints = pointsFromApi ?? (totalWeight * 10);
        }
      }

      // Parse pickup_photos
      List<String>? photoProofs;
      if (schedule['pickup_photos'] != null) {
        if (schedule['pickup_photos'] is List) {
          photoProofs = (schedule['pickup_photos'] as List)
              .map((p) => p.toString())
              .toList();
        }
      }

      // Get mitra name
      String? completedBy;
      if (schedule['mitra_name'] != null) {
        completedBy = schedule['mitra_name'].toString();
      }

      final wasteSummary = schedule['waste_summary']?.toString().trim();
      final wasteTypeScheduled =
          schedule['waste_type_scheduled']?.toString().trim();

      return ActivityModel(
        id: schedule['id']?.toString() ?? '',
        title: (wasteSummary != null && wasteSummary.isNotEmpty)
            ? 'Pickup $wasteSummary'
            : (wasteTypeScheduled != null && wasteTypeScheduled.isNotEmpty)
                ? 'Pickup $wasteTypeScheduled'
                : 'Layanan Sampah',
        address: schedule['pickup_address'] ?? '',
        dateTime: _formatDateTime(scheduledDate),
        status: 'Selesai',
        isActive: false,
        date: scheduledDate,
        notes: schedule['notes'],
        trashDetails: trashDetails,
        totalWeight: totalWeight,
        totalPoints: totalPoints,
        photoProofs: photoProofs,
        completedBy: completedBy,
      );
    }).toList();

    // Filter berdasarkan tanggal jika ada
    if (widget.selectedDate != null) {
      activities = activities.where((activity) {
        return activity.date.year == widget.selectedDate!.year &&
            activity.date.month == widget.selectedDate!.month &&
            activity.date.day == widget.selectedDate!.day;
      }).toList();
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

    return 'assets/ic_trash.png';
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SkeletonItems.card(height: 110),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String title = 'Belum ada pickup selesai';
    String subtitle = 'Riwayat pickup yang selesai akan muncul di sini';

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
              Icons.check_circle_outline,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: _isLoading
          ? _buildSkeletonLoading()
          : _getFilteredActivities().isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _buildEmptyState(),
                        ),
                      ],
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  itemCount: _getFilteredActivities().length,
                  itemBuilder: (context, index) {
                    final filteredActivities = _getFilteredActivities();
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
}
