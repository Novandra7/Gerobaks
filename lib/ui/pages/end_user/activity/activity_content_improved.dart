import 'package:flutter/material.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/ui/pages/end_user/activity/activity_item_improved.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';

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
  
  @override
  void initState() {
    super.initState();
    // Simulate loading data
    _simulateLoading();
  }
  
  @override
  void didUpdateWidget(ActivityContentImproved oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When filters change, reload with skeleton loading
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.filterCategory != widget.filterCategory ||
        oldWidget.showActive != widget.showActive ||
        oldWidget.searchQuery != widget.searchQuery) {
      _simulateLoading();
    }
  }
  
  Future<void> _simulateLoading() async {
    // Remove the early return which causes the loading to never complete
    // if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading delay - reduced to 500ms for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
    List<ActivityModel> result = sampleActivities;
    
    // Filter berdasarkan tab aktif/riwayat
    result = result.where((activity) => activity.isActive == widget.showActive).toList();
    
    // Filter berdasarkan tanggal jika ada
    if (widget.selectedDate != null) {
      result = result.where((activity) {
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
        result = result.where((activity) => 
          !mainCategories.contains(activity.getCategory())
        ).toList();
      } else {
        result = result.where((activity) => 
          activity.getCategory() == widget.filterCategory
        ).toList();
      }
    }
    
    // Pencarian telah dihapus, tidak perlu filter ini lagi
    
    // Urutkan berdasarkan tanggal (terbaru ke lama)
    result.sort((a, b) => b.date.compareTo(a.date));
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton loading when loading data
    if (_isLoading) {
      return _buildSkeletonLoading();
    }
    
    final filteredActivities = getFilteredActivities();
    
    // Widget untuk menampilkan tidak ada aktivitas
    Widget emptyWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada aktivitas',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: medium,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.showActive
                ? 'Anda belum memiliki aktivitas yang aktif'
                : 'Anda belum memiliki riwayat aktivitas',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    
    // Widget untuk menampilkan daftar aktivitas
    Widget listWidget = ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(), // Pastikan bisa scroll meskipun konten sedikit
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        return ActivityItemImproved(activity: filteredActivities[index]);
      },
    );
    
    // Tentukan widget konten yang akan ditampilkan
    Widget contentWidget = filteredActivities.isEmpty ? emptyWidget : listWidget;
          
    // Wrap dengan RefreshIndicator jika onRefresh tersedia
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          // Panggil onRefresh dari parent jika ada
          if (widget.onRefresh != null) {
            await widget.onRefresh!();
          }
          
          // Tampilkan loading indicator jika refresh dimulai
          // Use a short delay so users see that something happened
          await Future.delayed(const Duration(milliseconds: 300));
        },
        color: greenColor,
        backgroundColor: Colors.white,
        displacement: 40.0, // Jarak displacement yang lebih baik
        strokeWidth: 3.0, // Lebar stroke yang lebih tebal
        child: filteredActivities.isEmpty 
            ? Stack(
                children: [
                  // ListView kosong untuk memungkinkan scroll
                  ListView(),
                  // Widget kosong di atasnya
                  emptyWidget,
                ],
              ) 
            : listWidget,
      );
    }
    
    return contentWidget;
  }
}
