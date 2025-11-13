import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';

/// Content widget for Available Schedules tab (without AppBar)
/// To be used inside JadwalMitraPageNew
class AvailableSchedulesTabContent extends StatefulWidget {
  const AvailableSchedulesTabContent({super.key});

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
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
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
      final hasMore = result['has_more'] as bool? ?? false;

      setState(() {
        _schedules = schedules;
        _hasMorePages = hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreSchedules() async {
    if (_isLoadingMore || !_hasMorePages || _isLoading) return;

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
      final hasMore = result['has_more'] as bool? ?? false;

      setState(() {
        if (moreSchedules.isEmpty) {
          _hasMorePages = false;
        } else {
          _schedules.addAll(moreSchedules);
          _currentPage++;
          _hasMorePages = hasMore;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat jadwal lainnya: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Jadwal?'),
        content: Text(
          'Apakah Anda yakin ingin menerima jadwal pengambilan dari ${schedule.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      await _apiService.acceptSchedule(schedule.id);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Jadwal berhasil diterima'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSchedules(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menerima jadwal: $e'),
            backgroundColor: Colors.red,
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
                  'Menampilkan ${_schedules.length} jadwal tersedia',
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
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada jadwal tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSchedules,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
            // Loading indicator or end message
            if (_isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!_hasMorePages && _schedules.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[400],
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✅ Semua jadwal telah ditampilkan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
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
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: const Icon(Icons.person, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          schedule.userPhone,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
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
                      color: schedule.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.pickupAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Schedule Time
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${schedule.scheduleDay}, ${schedule.pickupTimeStart} - ${schedule.pickupTimeEnd}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Waste Types
              if (schedule.wasteSummary.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.wasteSummary,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
                  label: const Text('Terima Jadwal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
