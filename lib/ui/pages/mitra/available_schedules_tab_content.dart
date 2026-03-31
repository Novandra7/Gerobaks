import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';

/// Content widget for Available Schedules tab (without AppBar)
/// To be used inside JadwalMitraPageNew
class AvailableSchedulesTabContent extends StatefulWidget {
  final VoidCallback? onScheduleAccepted;

  const AvailableSchedulesTabContent({super.key, this.onScheduleAccepted});

  @override
  State<AvailableSchedulesTabContent> createState() =>
      _AvailableSchedulesTabContentState();
}

class _AvailableSchedulesTabContentState
    extends State<AvailableSchedulesTabContent> {
  final MitraApiService _apiService = MitraApiService();
  final ScrollController _scrollController = ScrollController();

  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;
  int _totalSchedules = 0;

  // Filters
  String? _selectedWasteType;
  String? _selectedArea;
  DateTime? _selectedDate;

  final List<String> _wasteTypes = [
    'Organik',
    'Anorganik',
    'B3',
    'Kertas',
    'Plastik',
    'Logam',
    'Kaca',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeService();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // User scrolled to 80% of the list, start loading more
      _loadMoreSchedules();
    }
  }

  Future<void> _initializeService() async {
    await _apiService.initialize();
    if (!mounted) return;
    await _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMorePages = true;
      _schedules = [];
    });

    try {
      final result = await _apiService.getAvailableSchedules(
        page: 1,
        wasteType: _selectedWasteType,
        area: _selectedArea,
        date: _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
      );

      final schedules = result['schedules'] as List<MitraPickupSchedule>;
      final currentPage = result['current_page'] as int? ?? 1;
      final lastPage = result['last_page'] as int? ?? 1;
      final total = result['total'] as int? ?? schedules.length;

      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _currentPage = currentPage;
        _hasMorePages = currentPage < lastPage;
        _totalSchedules = total;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreSchedules() async {
    if (!mounted || _isLoadingMore || !_hasMorePages || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _apiService.getAvailableSchedules(
        page: _currentPage + 1,
        wasteType: _selectedWasteType,
        area: _selectedArea,
        date: _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
      );

      final moreSchedules = result['schedules'] as List<MitraPickupSchedule>;
      final currentPage = result['current_page'] as int? ?? _currentPage + 1;
      final lastPage = result['last_page'] as int? ?? 1;
      final total = result['total'] as int? ?? _totalSchedules;

      if (!mounted) return;
      setState(() {
        if (moreSchedules.isEmpty) {
          _hasMorePages = false;
        } else {
          _schedules.addAll(moreSchedules);
          _currentPage = currentPage;
          _hasMorePages = currentPage < lastPage;
          _totalSchedules = total;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal lainnya: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Jadwal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Waste Type Filter
              const Text(
                'Jenis Sampah',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedWasteType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pilih jenis sampah',
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua')),
                  ..._wasteTypes.map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  ),
                ],
                onChanged: (value) {
                  setModalState(() => _selectedWasteType = value);
                },
              ),
              const SizedBox(height: 16),

              // Area Filter
              const Text('Area', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _selectedArea,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Jakarta Selatan',
                ),
                onChanged: (value) {
                  setModalState(
                    () => _selectedArea = value.isEmpty ? null : value,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Date Filter
              const Text(
                'Tanggal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    setModalState(() => _selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat(
                            'dd MMM yyyy',
                            'id_ID',
                          ).format(_selectedDate!)
                        : 'Pilih tanggal',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedWasteType = null;
                          _selectedArea = null;
                          _selectedDate = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Filters already updated in modal state
                        });
                        Navigator.pop(context);
                        _loadSchedules();
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptSchedule(MitraPickupSchedule schedule) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: greenColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Terima Jadwal?',
              style: blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Pastikan Anda siap menangani jadwal ini',
              style: greyTextStyle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Detail card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: greyColor.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 18, color: greenColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.userName,
                              style: blackTextStyle.copyWith(
                                fontWeight: semiBold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              schedule.userPhone,
                              style: greyTextStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 16, color: greyColor.withOpacity(0.2)),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: redcolor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.pickupAddress,
                          style: blackTextStyle.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Schedule time
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: blueColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${schedule.scheduleDay} · ${schedule.pickupTimeStart} - ${schedule.pickupTimeEnd}',
                          style: blackTextStyle.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  // Waste summary
                  if (schedule.wasteSummary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: orangeColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.wasteSummary,
                                style: blackTextStyle.copyWith(fontSize: 13),
                              ),
                              if (schedule.scheduledWeight != '0.00') ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${schedule.wasteTypeScheduled}: ${schedule.scheduledWeight} kg',
                                  style: greyTextStyle.copyWith(fontSize: 12),
                                ),
                              ],
                              if (schedule.additionalWastes != null &&
                                  schedule.additionalWastes!.isNotEmpty)
                                ...schedule.additionalWastes!.map(
                                  (w) => Text(
                                    '${w.type}: ~${w.estimatedWeight} kg (estimasi)',
                                    style: greyTextStyle.copyWith(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: greyColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: blackTextStyle.copyWith(
                        fontWeight: semiBold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: Text(
                      'Ya, Terima',
                      style: whiteTextStyle.copyWith(
                        fontWeight: semiBold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: greenColor),
                  const SizedBox(height: 16),
                  Text(
                    'Menerima jadwal...',
                    style: blackTextStyle.copyWith(fontWeight: medium),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      await _apiService.acceptSchedule(schedule.id);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Jadwal berhasil diterima',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Optimistic update: remove the accepted schedule from list immediately.
        // This avoids calling _loadSchedules() (which triggers setState) in the
        // same callback as onScheduleAccepted (which also triggers setState in
        // Pickup tab via ValueNotifier) — two setState chains in one frame caused
        // the call stack error.
        setState(() {
          _schedules.removeWhere((s) => s.id == schedule.id);
          _totalSchedules = _totalSchedules > 0 ? _totalSchedules - 1 : 0;
        });
        // Notify parent on next frame to switch tab + refresh Pickup.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onScheduleAccepted?.call();
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal menerima jadwal: $e',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _viewDetail(MitraPickupSchedule schedule) {
    Navigator.pushNamed(context, '/mitra/schedule-detail', arguments: schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Menampilkan ${_schedules.length}${_totalSchedules > 0 ? ' dari $_totalSchedules' : ''} jadwal tersedia',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (_selectedWasteType != null ||
                        _selectedArea != null ||
                        _selectedDate != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _showFilters,
              ),
            ],
          ),
        ),

        // Content
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSchedules,
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
                color: greyColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: greyColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada jadwal tersedia',
              style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _loadSchedules,
              icon: Icon(Icons.refresh, color: blueColor),
              label: Text(
                'Refresh',
                style: blueTextStyle.copyWith(fontWeight: semiBold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: blueColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length + (_isLoadingMore ? 1 : 1),
        itemBuilder: (context, index) {
          if (index == _schedules.length) {
            // Loading indicator
            if (_isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return const SizedBox.shrink();
          }

          final schedule = _schedules[index];
          return _ScheduleCard(
            schedule: schedule,
            onAccept: () => _acceptSchedule(schedule),
            onTap: () => _viewDetail(schedule),
          );
        },
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final MitraPickupSchedule schedule;
  final VoidCallback onAccept;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.schedule,
    required this.onAccept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: blueColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: blueColor.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
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
                // User Info + Status
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: greenColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: greenColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        (schedule.userName.trim().isNotEmpty
                                ? schedule.userName.trim()[0]
                                : '?')
                            .toUpperCase(),
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 20,
                          fontWeight: bold,
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
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.userPhone,
                            style: greyTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: schedule.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: schedule.statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            schedule.statusIcon,
                            size: 16,
                            color: schedule.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schedule.statusDisplay,
                            style: TextStyle(
                              color: schedule.statusColor,
                              fontWeight: semiBold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: greyColor.withOpacity(0.3)),
                const SizedBox(height: 12),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 20, color: redcolor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.pickupAddress,
                        style: blackTextStyle.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Schedule Time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: blueColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: blueColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.scheduleDay,
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${schedule.pickupTimeStart} - ${schedule.pickupTimeEnd}',
                              style: greyTextStyle.copyWith(
                                fontSize: 13,
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

                // Waste Types & Weights
                if (schedule.wasteSummary.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: orangeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: orangeColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: orangeColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                schedule.wasteSummary,
                                style: blackTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: medium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Scheduled weight for main waste type
                        if (schedule.scheduledWeight != '0.00') ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const SizedBox(width: 28),
                              Text(
                                '${schedule.wasteTypeScheduled}: ${schedule.scheduledWeight} kg',
                                style: greyTextStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                        // Additional wastes
                        if (schedule.additionalWastes != null &&
                            schedule.additionalWastes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ...schedule.additionalWastes!.map(
                            (w) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  const SizedBox(width: 28),
                                  Text(
                                    '${w.type}: ~${w.estimatedWeight} kg (tambahan)',
                                    style: greyTextStyle.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Accept Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Terima Jadwal',
                      style: whiteTextStyle.copyWith(fontWeight: semiBold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shadowColor: greenColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
