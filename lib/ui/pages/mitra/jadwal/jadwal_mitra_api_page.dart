import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/mitra_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/mitra/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_detail_page.dart';

class JadwalMitraApiPage extends StatefulWidget {
  const JadwalMitraApiPage({super.key});

  @override
  State<JadwalMitraApiPage> createState() => _JadwalMitraApiPageState();
}

class _JadwalMitraApiPageState extends State<JadwalMitraApiPage>
    with TickerProviderStateMixin {
  final MitraService _mitraService = MitraService();
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<ScheduleModel> _schedules = [];
  DateTime _selectedDate = DateTime.now();

  // Jumlah jadwal berdasarkan status
  int _pendingCount = 0;
  int _inProgressCount = 0;
  int _completedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    initializeDateFormatting('id_ID');
    _loadSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadSchedules();
    }
  }

  Future<void> _loadSchedules() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tentukan status berdasarkan tab yang aktif
      String? status;
      switch (_tabController.index) {
        case 1:
          status = 'pending';
          break;
        case 2:
          status = 'in_progress';
          break;
        case 3:
          status = 'completed';
          break;
      }

      final schedules = await _mitraService.getAssignments(
        status: status,
        date: _selectedDate,
      );

      if (!mounted) return;

      // Hitung jumlah jadwal per status
      _pendingCount = schedules
          .where((s) => s.status == ScheduleStatus.pending)
          .length;
      _inProgressCount = schedules
          .where((s) => s.status == ScheduleStatus.inProgress)
          .length;
      _completedCount = schedules
          .where((s) => s.status == ScheduleStatus.completed)
          .length;
      _totalCount = schedules.length;

      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onDateSelected(DateTime date) async {
    if (date == _selectedDate) return;

    setState(() {
      _selectedDate = date;
    });

    await _loadSchedules();
  }

  Future<void> _onRefresh() async {
    return _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Jadwal Pengambilan'),
        elevation: 0,
        backgroundColor: greenColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: whiteColor,
          tabs: [
            Tab(text: 'Semua ($_totalCount)'),
            Tab(text: 'Belum ($_pendingCount)'),
            Tab(text: 'Proses ($_inProgressCount)'),
            Tab(text: 'Selesai ($_completedCount)'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSchedules,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : _schedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey,
                            size: 50,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada jadwal yang ditemukan',
                            style: greyTextStyle.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        return ScheduleCard(
                          schedule: schedule,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JadwalDetailPage(scheduleId: schedule.id!),
                              ),
                            ).then((_) => _loadSchedules());
                          },
                          onStatusChange: (newStatus) async {
                            try {
                              await _mitraService.updateScheduleStatus(
                                int.parse(schedule.id!),
                                newStatus == ScheduleStatus.inProgress
                                    ? 'in_progress'
                                    : newStatus == ScheduleStatus.completed
                                    ? 'completed'
                                    : 'pending',
                              );

                              _loadSchedules();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Status jadwal berhasil diperbarui',
                                  ),
                                  backgroundColor: greenColor,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal memperbarui status jadwal: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanggal',
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected =
                    _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;

                return GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? greenColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E', 'id_ID').format(date),
                          style: TextStyle(
                            color: isSelected ? whiteColor : blackColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d', 'id_ID').format(date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: semiBold,
                            color: isSelected ? whiteColor : blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
