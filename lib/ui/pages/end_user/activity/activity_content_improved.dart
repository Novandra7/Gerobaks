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
  State<ActivityContentImproved> createState() => _ActivityContentImprovedState();
}

class _ActivityContentImprovedState extends State<ActivityContentImproved> {
  bool _isLoading = true;
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
    setState(() {
      _isLoading = true;
    });

    try {
      final schedules = await _apiService.getUserSchedules();
      
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading schedules: $e");
      if (mounted) {
        setState(() {
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
      itemCount: 6,  // Show 6 skeleton items
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
      
      return ActivityModel(
        id: schedule['id']?.toString() ?? '',
        title: schedule['service_type'] ?? 'Layanan Sampah',
        address: schedule['pickup_address'] ?? '',
        dateTime: _formatDateTime(scheduledDate),
        status: _mapStatusToReadableStatus(schedule['status']),
        isActive: _isScheduleActive(schedule['status']),
        date: scheduledDate,
        notes: schedule['notes'],
      );
    }).toList();
    
    // Filter berdasarkan tab aktif/riwayat
    activities = activities.where((activity) => activity.isActive == widget.showActive).toList();
    
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
        final mainCategories = ['Dijadwalkan', 'Menuju Lokasi', 'Selesai', 'Dibatalkan'];
        activities = activities.where((activity) => !mainCategories.contains(activity.getCategory())).toList();
      } else {
        activities = activities.where((activity) => activity.getCategory() == widget.filterCategory).toList();
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
      case 'in_progress':
        return 'Menuju Lokasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  bool _isScheduleActive(String? status) {
    // Active schedules are those that are pending or in progress
    return status == 'pending' || status == 'in_progress';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_getDayName(dateTime.weekday)}, ${dateTime.day}/${dateTime.month}/${dateTime.year} - ${_formatTime(dateTime)}';
  }

  String _getDayName(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ActivityItemImproved(activity: filteredActivities[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = widget.showActive ? 'Tidak ada aktivitas aktif' : 'Tidak ada riwayat aktivitas';
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
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: greyTextStyle.copyWith(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}