import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/mitra/schedule_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class JadwalMitraPage extends StatefulWidget {
  const JadwalMitraPage({super.key});

  @override
  State<JadwalMitraPage> createState() => _JadwalMitraPageState();
}

class _JadwalMitraPageState extends State<JadwalMitraPage>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String? _driverId;
  bool _isLoading = false;
  String _selectedFilter =
      'semua'; // Filter options: semua, pending, in_progress, completed

  // Tab controller untuk filter
  late TabController _tabController;

  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initialize
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedFilter = 'semua';
            break;
          case 1:
            _selectedFilter = 'pending';
            break;
          case 2:
            _selectedFilter = 'in_progress';
            break;
          case 3:
            _selectedFilter = 'completed';
            break;
        }
      });
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize date formatting for Indonesia
    await initializeDateFormatting('id_ID', null);

    try {
      // Initialize schedule service
      await _scheduleService.initialize();

      // Get driver ID
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();
      if (userData != null) {
        _driverId = userData['id'] as String;
      }

      // Load schedules
      await _loadSchedules();
    } catch (e) {
      // Tampilkan error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_driverId != null) {
        // Di sini akan implementasi untuk mendapatkan jadwal berdasarkan ID driver dan tanggal
        // dari API atau sumber data lain
        // Untuk sementara, kita gunakan data dummy dan simulasi loading
        await Future.delayed(const Duration(seconds: 1));

        // Dalam implementasi sebenarnya akan seperti:
        // final schedules = await _scheduleService.getSchedules(driverId: _driverId!, date: selectedDate);
        // setState(() {
        //   _schedules = schedules;
        // });
      }
    } catch (e) {
      // Tampilkan error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Jadwal Pengambilan',
              style: whiteTextStyle.copyWith(
                fontSize: 20,
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month_outlined, color: whiteColor),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: whiteColor),
            onPressed: () => _loadSchedules(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: greenColor))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Filter Tabs
        Container(
          color: whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TabBar(
            controller: _tabController,
            indicatorColor: greenColor,
            indicatorWeight: 3,
            labelColor: greenColor,
            unselectedLabelColor: greyColor,
            labelStyle: TextStyle(fontWeight: semiBold, fontSize: 14),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Menunggu'),
              Tab(text: 'Proses'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),

        // Jadwal Content
        Expanded(
          child: RefreshIndicator(
            color: greenColor,
            onRefresh: _loadSchedules,
            child: _getFilteredSchedules().isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: _getFilteredSchedules().length,
                    itemBuilder: (context, index) {
                      // Mendapatkan data jadwal berdasarkan filter
                      final scheduleData = _getFilteredSchedules()[index];
                      return _buildScheduleCard(scheduleData);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // Widget untuk memilih tanggal
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFC1F2AD), // Warna paling atas (0%)
              const Color(0xFF5CC488), // Warna kedua (55%)
              const Color(0xFF55C080), // Warna ketiga (80%)
              const Color(0xFF46C375), // Warna paling bawah (100%)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.55, 0.8, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate),
                  style: whiteTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDate.isAtSameMomentAs(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      )
                      ? 'Jadwal hari ini'
                      : 'Pilih tanggal lain',
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // Widget ringkasan jadwal
  Widget _buildScheduleSummary() {
    // Hitung jumlah jadwal untuk setiap status
    final schedules = _getFilteredSchedules();
    final int pendingCount = schedules
        .where((s) => s['status'] == 'pending')
        .length;
    final int inProgressCount = schedules
        .where((s) => s['status'] == 'in_progress')
        .length;
    final int completedCount = schedules
        .where((s) => s['status'] == 'completed')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.pending_outlined,
            Colors.orange,
            'Menunggu',
            pendingCount.toString(),
          ),
          _buildDivider(),
          _buildSummaryItem(
            Icons.directions_car_outlined,
            Colors.blue,
            'Proses',
            inProgressCount.toString(),
          ),
          _buildDivider(),
          _buildSummaryItem(
            Icons.check_circle_outline,
            greenColor,
            'Selesai',
            completedCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildSummaryItem(
    IconData icon,
    Color color,
    String title,
    String count,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal',
            style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada jadwal pengambilan untuk kategori ini',
            textAlign: TextAlign.center,
            style: greyTextStyle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Mendapatkan jadwal berdasarkan filter yang dipilih
  List<Map<String, dynamic>> _getFilteredSchedules() {
    // Ini akan diganti dengan data dari API nanti
    // Untuk sementara kita gunakan data dummy
    final schedules = [
      {
        'time': '08:00 - 09:00',
        'customer_name': 'Wahyu Indra',
        'address': 'Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur',
        'waste_type': 'Organik',
        'waste_weight': '2 kg',
        'status': 'pending',
        'estimatedDistance': '3.2 km',
      },
      {
        'time': '09:30 - 10:30',
        'customer_name': 'Siti Rahayu',
        'address': 'Perumahan Indah Blok B, Kota Samarinda, Kalimantan Timur',
        'waste_type': 'Anorganik',
        'waste_weight': '1.5 kg',
        'status': 'completed',
        'estimatedDistance': '4.5 km',
      },
      {
        'time': '11:00 - 12:00',
        'customer_name': 'Ahmad Rizal',
        'address': 'Jl. Juanda No. 45, Kota Samarinda, Kalimantan Timur',
        'waste_type': 'Anorganik',
        'waste_weight': '3 kg',
        'status': 'in_progress',
        'estimatedDistance': '1.8 km',
      },
      {
        'time': '14:00 - 16:00',
        'customer_name': 'Wahyu Indra',
        'address': 'Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur',
        'waste_type': 'Organik',
        'waste_weight': '2 kg',
        'status': 'pending',
        'estimatedDistance': '3.2 km',
      },
      {
        'time': '17:00 - 18:00',
        'customer_name': 'Ahmad Rizal',
        'address': 'Jl. Juanda No. 45, Kota Samarinda, Kalimantan Timur',
        'waste_type': 'Anorganik',
        'waste_weight': '3 kg',
        'status': 'pending',
        'estimatedDistance': '2.7 km',
      },
      {
        'time': '16:00 - 17:00',
        'area': 'Apartemen Green Ville Tower A',
        'customers': 30,
        'status': 'completed',
        'estimatedDistance': '6.3 km',
      },
      {
        'time': '17:30 - 18:30',
        'area': 'Kompleks Perumahan Sejahtera',
        'customers': 25,
        'status': 'completed',
        'estimatedDistance': '3.9 km',
      },
    ];

    if (_selectedFilter == 'semua') {
      return schedules;
    } else {
      return schedules.where((s) => s['status'] == _selectedFilter).toList();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: greenColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _loadSchedules(); // Reload schedules for selected date
      });
    }
  }

  // Widget untuk menampilkan kartu jadwal
  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    // Menentukan warna dan teks status berdasarkan status jadwal
    String statusText;
    Color statusColor;
    Color statusBgColor;

    switch (schedule['status']) {
      case 'completed':
        statusText = 'Selesai';
        statusColor = greenColor;
        statusBgColor = const Color(0xFFE3F6DF);
        break;
      case 'in_progress':
        statusText = 'Proses';
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
        break;
      default:
        statusText = 'Menunggu';
        statusColor = const Color(0xFFB58D00);
        statusBgColor = const Color(0xFFFFF8E0);
    }

    // Membuat tag untuk jenis sampah dan berat
    List<ScheduleTag> tags = [];

    // Tag untuk jenis sampah (waste_type)
    if (schedule['waste_type'] != null) {
      tags.add(
        ScheduleTag(
          label: schedule['waste_type'],
          backgroundColor: schedule['waste_type'] == 'Organik'
              ? const Color(0xFFE3F6DF) // Hijau muda untuk organik
              : const Color(0xFFFFECE3), // Oranye muda untuk anorganik
          textColor: schedule['waste_type'] == 'Organik'
              ? const Color(0xFF5CC488) // Hijau untuk organik
              : const Color(0xFFFF7A30), // Oranye untuk anorganik
        ),
      );
    }

    // Tag untuk berat sampah (waste_weight)
    if (schedule['waste_weight'] != null) {
      tags.add(
        ScheduleTag(
          label: schedule['waste_weight'],
          backgroundColor: Colors.grey.withOpacity(0.1),
          textColor: greyColor,
        ),
      );
    }

    return ScheduleCard(
      time: schedule['time'] ?? '',
      status: statusText,
      name: schedule['customer_name'] ?? '',
      address: schedule['address'] ?? '',
      tags: tags,
      statusColor: statusColor,
      statusBackgroundColor: statusBgColor,
      onTap: () {
        // Handle tap to view details
      },
    );
  }
}
