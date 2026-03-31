import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final MitraApiService _apiService = MitraApiService();
  final ScrollController _scrollController = ScrollController();

  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    await _apiService.initialize();
    _loadHistory();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadHistory({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _schedules.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.getHistory(
        page: _currentPage,
        perPage: 20,
      );

      setState(() {
        _schedules = result['schedules'] as List<MitraPickupSchedule>;
        _totalPages = (result['total_pages'] as int?) ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final result = await _apiService.getHistory(
        page: _currentPage,
        perPage: 20,
      );

      setState(() {
        _schedules.addAll(result['schedules'] as List<MitraPickupSchedule>);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Rollback page on error
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Gagal memuat data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading && _schedules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadHistory(reset: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: greyColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: greyColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada riwayat',
              style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Riwayat pengambilan yang selesai akan muncul di sini',
                style: greyTextStyle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadHistory(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _schedules.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final schedule = _schedules[index];
          return _HistoryCard(schedule: schedule);
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MitraPickupSchedule schedule;

  const _HistoryCard({required this.schedule});

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HistoryDetailModal(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointsEarned = schedule.totalWeight != null
        ? (schedule.totalWeight! * 10).toInt()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: greenColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: greenColor.withValues(alpha: 0.1), width: 1),
      ),
      child: InkWell(
        onTap: () => _showDetailModal(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [whiteColor, lightBackgroundColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      schedule.completedAt != null
                          ? DateFormat(
                              'dd MMM yyyy, HH:mm',
                              'id_ID',
                            ).format(schedule.completedAt!)
                          : '-',
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: schedule.statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: schedule.statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            schedule.statusIcon,
                            size: 14,
                            color: schedule.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule.statusDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: semiBold,
                              color: schedule.statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, color: greyColor.withValues(alpha: 0.3)),

                // User Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: blueColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: blueColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        (schedule.userName.trim().isNotEmpty
                                ? schedule.userName.trim()[0]
                                : '?')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.userName,
                            style: blackTextStyle.copyWith(
                              fontWeight: bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.pickupAddress,
                            style: greyTextStyle.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Scheduled Pickup Time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: blueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: blueColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: blueColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.scheduleDay,
                              style: blackTextStyle.copyWith(
                                fontSize: 13,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${schedule.pickupTimeStart} - ${schedule.pickupTimeEnd}',
                              style: greyTextStyle.copyWith(
                                fontSize: 12,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Weight and Points Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        orangeColor.withValues(alpha: 0.1),
                        yellowColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: orangeColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: orangeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.scale,
                                size: 20,
                                color: orangeColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Berat',
                                  style: greyTextStyle.copyWith(fontSize: 11),
                                ),
                                Text(
                                  '${schedule.totalWeight?.toStringAsFixed(2) ?? '0'} kg',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: greyColor.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: yellowColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.stars,
                                size: 20,
                                color: yellowColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Poin Didapat',
                                  style: greyTextStyle.copyWith(fontSize: 11),
                                ),
                                Text(
                                  '$pointsEarned pts',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: bold,
                                    color: yellowColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Photos Count
                if (schedule.pickupPhotos != null &&
                    schedule.pickupPhotos!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: blueColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: blueColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library, size: 16, color: blueColor),
                          const SizedBox(width: 6),
                          Text(
                            '${schedule.pickupPhotos!.length} foto',
                            style: blueTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Detail Modal Widget
class _HistoryDetailModal extends StatelessWidget {
  final MitraPickupSchedule schedule;

  const _HistoryDetailModal({required this.schedule});

  IconData _getTrashIcon(String trashType) {
    final type = trashType.toLowerCase();

    if (type.contains('plastik')) return Icons.shopping_bag_outlined;
    if (type.contains('kertas') || type.contains('koran')) {
      return Icons.article_outlined;
    }
    if (type.contains('logam') ||
        type.contains('besi') ||
        type.contains('aluminium')) {
      return Icons.hardware_outlined;
    }
    if (type.contains('kaca') || type.contains('botol')) {
      return Icons.local_bar_outlined;
    }
    if (type.contains('b3') || type.contains('kimia')) {
      return Icons.warning_amber_rounded;
    }
    if (type.contains('elektro')) return Icons.devices_outlined;
    if (type.contains('organik')) return Icons.eco_outlined;

    return Icons.recycling_outlined;
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imagePath,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Gambar tidak dapat dimuat',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointsEarned = schedule.totalWeight != null
        ? (schedule.totalWeight! * 10).toInt()
        : 0;

    // Parse actual weights to list with details
    List<Map<String, dynamic>> trashDetails = [];
    if (schedule.actualWeights != null) {
      schedule.actualWeights!.forEach((type, weight) {
        final weightValue = weight is double
            ? weight
            : (weight as num).toDouble();
        trashDetails.add({
          'type': type,
          'weight': weightValue,
          'points': (weightValue * 10).toInt(),
          'icon': _getTrashIcon(type),
        });
      });
    }

    final List<Color> itemColors = [
      orangeColor,
      redcolor,
      const Color(0xff8B5CF6),
      const Color(0xff0D9488),
      greenColor,
      blueColor,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: greyColor.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: greenColor.withAlpha(51),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: whiteColor.withAlpha(64),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: whiteColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengambilan Selesai',
                          style: whiteTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          schedule.completedAt != null
                              ? DateFormat('EEEE, dd MMM yyyy • HH:mm', 'id_ID')
                                  .format(schedule.completedAt!)
                              : '-',
                          style: whiteTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: regular,
                            color: whiteColor.withAlpha(230),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          color: whiteColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Date and User Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: greyColor.withAlpha(51)),
                      boxShadow: [
                        BoxShadow(
                          color: greyColor.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: blueColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: 20,
                                color: blueColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  schedule.completedAt != null
                                      ? DateFormat(
                                          'EEEE, dd MMMM yyyy • HH:mm',
                                          'id_ID',
                                        ).format(schedule.completedAt!)
                                      : '-',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            height: 32,
                            thickness: 1,
                            color: greyColor.withAlpha(51),
                          ),
                        ),
                        
                        // User Info Section
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: blueColor.withAlpha(51),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (schedule.userName.trim().isNotEmpty
                                          ? schedule.userName.trim()[0]
                                          : '?')
                                      .toUpperCase(),
                                  style: whiteTextStyle.copyWith(
                                    fontWeight: bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule.userName,
                                    style: blackTextStyle.copyWith(
                                      fontWeight: bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: greyColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          schedule.pickupAddress,
                                          style: greyTextStyle.copyWith(
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: orangeColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: orangeColor.withAlpha(51),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: orangeColor.withAlpha(77),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.summarize_rounded,
                                color: orangeColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'RINGKASAN',
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Total Berat',
                          '${schedule.totalWeight?.toStringAsFixed(2) ?? '0.00'} kg',
                        ),
                        _buildSummaryRow(
                          'Total Jenis',
                          '${trashDetails.length} jenis',
                        ),
                        _buildSummaryRow(
                          'Total Poin',
                          '$pointsEarned poin',
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Trash Details
                  if (trashDetails.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: greenColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.recycling_rounded,
                            color: greenColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'DETAIL SAMPAH',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(trashDetails.length, (index) {
                      final detail = trashDetails[index];
                      final color = itemColors[index % itemColors.length];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withAlpha(77),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(26),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                detail['icon'] as IconData,
                                color: color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail['type'],
                                    style: blackTextStyle.copyWith(
                                      fontWeight: bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.scale_rounded,
                                        size: 14,
                                        color: greyColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${detail['weight'].toStringAsFixed(2)} kg',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withAlpha(51),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.stars_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${detail['points']}',
                                    style: whiteTextStyle.copyWith(
                                      fontWeight: bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Photos
                  if (schedule.pickupPhotos != null &&
                      schedule.pickupPhotos!.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: blueColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.photo_camera_rounded,
                            color: blueColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'BUKTI FOTO',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: schedule.pickupPhotos!.length,
                      itemBuilder: (context, index) {
                        final photoPath = schedule.pickupPhotos![index];
                        print(photoPath);
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(context, photoPath),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: greyColor.withAlpha(77),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: greyColor.withAlpha(26),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    photoPath,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Gagal memuat foto',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.4),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(204),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.zoom_in_rounded,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Notes
                  if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xff8B5CF6).withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.note_alt_rounded,
                            color: Color(0xff8B5CF6),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'CATATAN',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F3FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xff8B5CF6).withAlpha(51),
                        ),
                      ),
                      child: Text(
                        schedule.notes!,
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? greenColor.withAlpha(77)
              : greyColor.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: greyTextStyle.copyWith(
              fontSize: 14,
              fontWeight: medium,
            ),
          ),
          Container(
            padding: isHighlighted
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6)
                : null,
            decoration: isHighlighted
                ? BoxDecoration(
                    color: greenColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: greenColor.withAlpha(51),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHighlighted)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontWeight: bold,
                    fontSize: 15,
                    color: isHighlighted ? whiteColor : blackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
