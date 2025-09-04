import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/user/schedule/add_schedule_page.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class UserSchedulesPage extends StatefulWidget {
  const UserSchedulesPage({super.key});

  @override
  State<UserSchedulesPage> createState() => _UserSchedulesPageState();
}

class _UserSchedulesPageState extends State<UserSchedulesPage> {
  final ScheduleService _scheduleService = ScheduleService();
  DateTime selectedDate = DateTime.now();
  String? _userId;
  bool _isLoading = false;
  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> _filteredSchedules = [];
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _initialize();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize schedule service
      await _scheduleService.initialize();
      
      // Get user ID
      final localStorage = await LocalStorageService.getInstance();
      final userData = await localStorage.getUserData();
      if (userData != null) {
        _userId = userData['id'] as String;
      }
      
      // Load schedules
      await _loadSchedules();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing schedule page: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadSchedules() async {
    if (_userId == null) return;
    
    try {
      final schedules = await _scheduleService.getUserSchedulesByDate(_userId!, selectedDate);
      
      setState(() {
        _schedules = schedules;
        _filterSchedules();
      });
    } catch (e) {
      print('Error loading schedules: $e');
    }
  }
  
  void _filterSchedules() {
    setState(() {
      _filteredSchedules = _schedules.where((schedule) {
        // Filter by status
        bool statusMatch = _selectedStatusFilter == 'Semua' || 
            _getStatusText(schedule.status) == _selectedStatusFilter;
        
        // Filter by search query
        bool searchMatch = _searchQuery.isEmpty ||
            schedule.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (schedule.notes != null && 
             schedule.notes!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (schedule.wasteType != null && 
             schedule.wasteType!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
            (schedule.contactName != null && 
             schedule.contactName!.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        return statusMatch && searchMatch;
      }).toList();
    });
  }
  
  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.pending:
        return 'Menunggu';
      case ScheduleStatus.inProgress:
        return 'Sedang Berjalan';
      case ScheduleStatus.completed:
        return 'Selesai';
      case ScheduleStatus.cancelled:
        return 'Dibatalkan';
      case ScheduleStatus.missed:
        return 'Terlewat';
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              surface: whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadSchedules();
    }
  }
  
  void _navigateToAddSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSchedulePage()),
    );
    
    if (result != null) {
      _loadSchedules();
    }
  }
  
  Future<void> _cancelSchedule(ScheduleModel schedule) async {
    try {
      final result = await DialogHelper.showConfirmDialog(
        context: context,
        title: 'Batalkan Jadwal',
        message: 'Apakah Anda yakin ingin membatalkan jadwal ini?',
        confirmText: 'Ya, Batalkan',
        cancelText: 'Tidak',
      );
      
      if (result == true) {
        final updatedSchedule = await _scheduleService.updateScheduleStatus(
          schedule.id!, 
          ScheduleStatus.cancelled
        );
        
        if (updatedSchedule != null) {
          DialogHelper.showSuccessDialog(
            context: context,
            title: 'Jadwal Dibatalkan',
            message: 'Jadwal berhasil dibatalkan.',
          );
          _loadSchedules();
        }
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        context: context,
        title: 'Gagal Membatalkan Jadwal',
        message: 'Terjadi kesalahan saat membatalkan jadwal. Silakan coba lagi nanti.',
      );
      print('Error cancelling schedule: $e');
    }
  }
  
  void _viewScheduleDetail(ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildScheduleDetailSheet(schedule),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: greenColor,
        elevation: 0,
        title: Text(
          'Jadwal Pengambilan',
          style: whiteTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSchedule,
        backgroundColor: greenColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Jadwal',
          style: whiteTextStyle.copyWith(fontWeight: semiBold),
        ),
        elevation: 4,
        highlightElevation: 8,
      ),
      body: _isLoading 
          ? Center(
              child: CircularProgressIndicator(color: greenColor),
            )
          : RefreshIndicator(
              onRefresh: _loadSchedules,
              color: greenColor,
              child: Column(
                children: [
                  // Gradient header with stats
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          greenColor,
                          greenColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _buildHeaderStats(),
                  ),
                  
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Search and date row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            children: [
                              // Search box
                              Expanded(
                                flex: 8,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _filterSchedules();
                                      });
                                    },
                                    style: blackTextStyle.copyWith(fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'Cari jadwal...',
                                      hintStyle: greyTextStyle.copyWith(fontSize: 15),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 8),
                                        child: Icon(Icons.search, color: greyColor, size: 22),
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: IconButton(
                                                icon: Icon(Icons.close, color: greyColor, size: 18),
                                                onPressed: () {
                                                  setState(() {
                                                    _searchQuery = '';
                                                    _searchController.clear();
                                                    _filterSchedules();
                                                  });
                                                },
                                              ),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Date picker button
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () => _selectDate(context),
                                  icon: Icon(
                                    Icons.calendar_today_rounded,
                                    color: greenColor,
                                    size: 24,
                                  ),
                                  tooltip: 'Pilih tanggal',
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Status filter chips
                        Container(
                          height: 44,
                          margin: const EdgeInsets.only(top: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildFilterChip('Semua'),
                                _buildFilterChip('Menunggu'),
                                _buildFilterChip('Sedang Berjalan'),
                                _buildFilterChip('Selesai'),
                                _buildFilterChip('Dibatalkan'),
                                _buildFilterChip('Terlewat'),
                              ],
                            ),
                          ),
                        ),
                        
                        // Section title with counter and selected date
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Jadwal ${DateFormat('d MMMM yyyy', 'id_ID').format(selectedDate)}',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: greenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_filteredSchedules.length} Jadwal',
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 12,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Schedule list
                        _filteredSchedules.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                                itemCount: _filteredSchedules.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildScheduleItem(_filteredSchedules[index]),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildScheduleDetailSheet(ScheduleModel schedule) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (schedule.status) {
      case ScheduleStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        statusIcon = Icons.access_time_rounded;
        break;
      case ScheduleStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'Sedang Berjalan';
        statusIcon = Icons.directions_car_rounded;
        break;
      case ScheduleStatus.completed:
        statusColor = Colors.green;
        statusText = 'Selesai';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case ScheduleStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Dibatalkan';
        statusIcon = Icons.cancel_outlined;
        break;
      case ScheduleStatus.missed:
        statusColor = Colors.grey;
        statusText = 'Terlewat';
        statusIcon = Icons.schedule_outlined;
        break;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Jadwal Pengambilan',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Detail items
          _buildDetailItem(
            icon: Icons.calendar_today_rounded,
            title: 'Tanggal',
            value: DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate),
          ),
          
          _buildDetailItem(
            icon: Icons.access_time_rounded,
            title: 'Waktu',
            value: '${schedule.timeSlot.hour}:${schedule.timeSlot.minute.toString().padLeft(2, '0')} WIB',
          ),
          
          _buildDetailItem(
            icon: Icons.location_on_rounded,
            title: 'Alamat',
            value: schedule.address,
          ),
          
          if (schedule.latitude != null && schedule.longitude != null)
            _buildDetailItem(
              icon: Icons.pin_drop_rounded,
              title: 'Koordinat',
              value: '${schedule.latitude}, ${schedule.longitude}',
              isCoordinates: true,
            ),
          
          if (schedule.wasteType != null)
            _buildDetailItem(
              icon: Icons.delete_outline_rounded,
              title: 'Jenis Sampah',
              value: schedule.wasteType!,
            ),
          
          if (schedule.estimatedWeight != null)
            _buildDetailItem(
              icon: Icons.scale_rounded,
              title: 'Estimasi Berat',
              value: '${schedule.estimatedWeight} kg',
            ),
          
          if (schedule.contactName != null)
            _buildDetailItem(
              icon: Icons.person_outline_rounded,
              title: 'Nama Kontak',
              value: schedule.contactName!,
            ),
          
          if (schedule.contactPhone != null)
            _buildDetailItem(
              icon: Icons.phone_rounded,
              title: 'Nomor Telepon',
              value: schedule.contactPhone!,
            ),
          
          if (schedule.notes != null && schedule.notes!.isNotEmpty)
            _buildDetailItem(
              icon: Icons.note_rounded,
              title: 'Catatan',
              value: schedule.notes!,
            ),
          
          _buildDetailItem(
            icon: Icons.repeat_rounded,
            title: 'Frekuensi',
            value: _getFrequencyText(schedule.frequency),
          ),
          
          if (schedule.completedAt != null)
            _buildDetailItem(
              icon: Icons.check_circle,
              title: 'Diselesaikan Pada',
              value: DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(schedule.completedAt!),
            ),
            
          const SizedBox(height: 16),
          
          // Action Buttons
          if (schedule.status == ScheduleStatus.pending)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _cancelSchedule(schedule);
                },
                child: Text(
                  'Batalkan Jadwal',
                  style: whiteTextStyle.copyWith(
                    fontWeight: medium,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon, 
    required String title, 
    required String value,
    bool isCoordinates = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: greenColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: blackTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                    if (isCoordinates)
                      GestureDetector(
                        onTap: () {
                          // TODO: Open map
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.map,
                            color: greenColor,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getFrequencyText(ScheduleFrequency frequency) {
    switch (frequency) {
      case ScheduleFrequency.once:
        return 'Sekali saja';
      case ScheduleFrequency.daily:
        return 'Setiap hari';
      case ScheduleFrequency.weekly:
        return 'Setiap minggu';
      case ScheduleFrequency.biWeekly:
        return 'Setiap 2 minggu';
      case ScheduleFrequency.monthly:
        return 'Setiap bulan';
    }
  }
  
  // Enhanced UI components
  
  Widget _buildHeaderStats() {
    // Count schedules by status
    int pendingCount = _schedules.where((s) => s.status == ScheduleStatus.pending).length;
    int completedCount = _schedules.where((s) => s.status == ScheduleStatus.completed).length;
    int inProgressCount = _schedules.where((s) => s.status == ScheduleStatus.inProgress).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'Jadwal Pengambilan',
              style: whiteTextStyle.copyWith(
                fontSize: 20,
                fontWeight: bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola jadwal pengambilan sampah Anda dengan mudah',
          style: whiteTextStyle.copyWith(
            fontSize: 14, 
            fontWeight: light,
            color: Colors.white.withOpacity(0.9)
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildStatCard(
              'Total',
              _schedules.length.toString(),
              Icons.calendar_today_rounded,
              Colors.white,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Menunggu',
              pendingCount.toString(),
              Icons.access_time_rounded,
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Berjalan',
              inProgressCount.toString(),
              Icons.directions_car_rounded,
              Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: whiteTextStyle.copyWith(
                fontSize: 18,
                fontWeight: bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: whiteTextStyle.copyWith(
                fontSize: 11,
                fontWeight: medium,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String status) {
    final isSelected = _selectedStatusFilter == status;
    
    // Get appropriate color based on status
    Color statusColor = greenColor;
    IconData statusIcon;
    
    switch(status.toLowerCase()) {
      case 'menunggu':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_rounded;
        break;
      case 'sedang berjalan':
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car_rounded;
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'dibatalkan':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'terlewat':
        statusColor = Colors.grey;
        statusIcon = Icons.schedule_outlined;
        break;
      default:
        statusColor = greenColor;
        statusIcon = Icons.list_alt_rounded;
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatusFilter = status;
            _filterSchedules();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? statusColor : whiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Only show icon when selected
              if (isSelected) ...[
                Icon(
                  statusIcon,
                  color: whiteColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                status,
                style: isSelected
                    ? whiteTextStyle.copyWith(
                        fontWeight: semiBold,
                        fontSize: 13,
                      )
                    : blackTextStyle.copyWith(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: greyColor.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Jadwal',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum memiliki jadwal pengambilan sampah untuk tanggal ini.',
            style: greyTextStyle.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomFilledButton(
            title: 'Buat Jadwal Baru',
            width: double.infinity,
            onPressed: _navigateToAddSchedule,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleModel schedule) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (schedule.status) {
      case ScheduleStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        statusIcon = Icons.access_time_rounded;
        break;
      case ScheduleStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'Sedang Berjalan';
        statusIcon = Icons.directions_car_rounded;
        break;
      case ScheduleStatus.completed:
        statusColor = Colors.green;
        statusText = 'Selesai';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case ScheduleStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Dibatalkan';
        statusIcon = Icons.cancel_outlined;
        break;
      case ScheduleStatus.missed:
        statusColor = Colors.grey;
        statusText = 'Terlewat';
        statusIcon = Icons.schedule_outlined;
        break;
    }

    return GestureDetector(
      onTap: () => _viewScheduleDetail(schedule),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status bar at top
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              color: statusColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${schedule.timeSlot.hour}:${schedule.timeSlot.minute.toString().padLeft(2, '0')}',
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: semiBold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: greenColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.address,
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Waste type and weight
                  Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: greenColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${schedule.wasteType ?? 'Sampah'} ${schedule.estimatedWeight != null ? '(${schedule.estimatedWeight!} kg)' : ''}',
                        style: greyTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  ),
                  if (schedule.contactName != null && schedule.contactName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: greenColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          schedule.contactName!,
                          style: greyTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: greenColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _viewScheduleDetail(schedule),
                          child: Text(
                            'Detail',
                            style: TextStyle(
                              color: greenColor,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: schedule.status == ScheduleStatus.pending ? Colors.red[400] : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: schedule.status == ScheduleStatus.pending ? 
                            () => _cancelSchedule(schedule) : null,
                          child: Text(
                            'Batalkan',
                            style: whiteTextStyle.copyWith(
                              fontWeight: medium,
                            ),
                          ),
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
    );
  }
}
