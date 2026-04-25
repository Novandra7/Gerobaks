import 'package:flutter/material.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_item_improved.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';
import 'package:bank_sha/services/end_user_api_service.dart';

/// Tab untuk schedule dengan status: pending
/// Menampilkan jadwal yang belum diproses
/// Fitur: Edit schedule, Cancel schedule
class ScheduledTab extends StatefulWidget {
  final DateTime? selectedDate;
  final String? searchQuery;

  const ScheduledTab({super.key, this.selectedDate, this.searchQuery});

  @override
  State<ScheduledTab> createState() => _ScheduledTabState();
}

class _ScheduledTabState extends State<ScheduledTab>
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
    // Filter hanya status 'pending'
    final pendingSchedules = _schedules.where((schedule) {
      return schedule['status'] == 'pending';
    }).toList();

    // Convert ke ActivityModel
    List<ActivityModel> activities = pendingSchedules.map((schedule) {
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

      final wasteSummary = schedule['waste_summary']?.toString().trim();
      final wasteTypeScheduled = schedule['waste_type_scheduled']
          ?.toString()
          .trim();

      return ActivityModel(
        id: schedule['id']?.toString() ?? '',
        title: (wasteSummary != null && wasteSummary.isNotEmpty)
            ? 'Pickup $wasteSummary'
            : (wasteTypeScheduled != null && wasteTypeScheduled.isNotEmpty)
            ? 'Pickup $wasteTypeScheduled'
            : 'Layanan Sampah',
        address: schedule['pickup_address'] ?? '',
        dateTime: _formatDateTime(scheduledDate),
        status: 'Dijadwalkan',
        isActive: true,
        date: scheduledDate,
        notes: schedule['notes'],
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
    activities.sort((a, b) => a.date.compareTo(b.date));

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
    String title = 'Tidak ada jadwal';
    String subtitle = 'Buat jadwal pengambilan sampah baru';

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
            Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
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
