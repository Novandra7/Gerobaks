import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';
import 'complete_pickup_page.dart';

class ActiveSchedulesPage extends StatefulWidget {
  const ActiveSchedulesPage({super.key});

  @override
  State<ActiveSchedulesPage> createState() => _ActiveSchedulesPageState();
}

class _ActiveSchedulesPageState extends State<ActiveSchedulesPage> {
  final MitraApiService _apiService = MitraApiService();
  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _apiService.initialize();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final schedules = await _apiService.getMyActiveSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openGoogleMaps(MitraPickupSchedule schedule) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${schedule.latitude},${schedule.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  Future<void> _callUser(MitraPickupSchedule schedule) async {
    final url = Uri.parse('tel:${schedule.userPhone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _goToCompletePickup(MitraPickupSchedule schedule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletePickupPage(schedule: schedule),
      ),
    );

    if (result == true) {
      _loadSchedules(); // Refresh if completed
    }
  }

  Future<void> _cancelSchedule(MitraPickupSchedule schedule) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: redcolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded, color: redcolor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Batalkan Jadwal',
              style: blackTextStyle.copyWith(fontSize: 18, fontWeight: bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Anda yakin ingin membatalkan jadwal ini?',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: blackTextStyle,
              decoration: InputDecoration(
                labelText: 'Alasan pembatalan',
                labelStyle: greyTextStyle,
                hintText: 'Masukkan alasan...',
                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: redcolor, width: 2),
                ),
                filled: true,
                fillColor: whiteColor,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Tidak',
              style: greyTextStyle.copyWith(fontWeight: semiBold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: redcolor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Ya, Batalkan',
              style: whiteTextStyle.copyWith(fontWeight: semiBold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || reasonController.text.isEmpty) return;

    try {
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
                CircularProgressIndicator(color: redcolor),
                const SizedBox(height: 16),
                Text(
                  'Membatalkan jadwal...',
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
              ],
            ),
          ),
        ),
      );

      await _apiService.cancelSchedule(schedule.id, reasonController.text);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Jadwal berhasil dibatalkan',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: orangeColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _loadSchedules(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal membatalkan jadwal: $e',
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

  @override
  Widget build(BuildContext context) {
    return _buildBody();
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
                Icons.work_off_outlined,
                size: 64,
                color: greyColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada jadwal aktif',
              style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Terima jadwal dari tab "Tersedia"',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return _ActiveScheduleCard(
            schedule: schedule,
            onNavigate: () => _openGoogleMaps(schedule),
            onCall: () => _callUser(schedule),
            onComplete: () => _goToCompletePickup(schedule),
            onCancel: () => _cancelSchedule(schedule),
          );
        },
      ),
    );
  }
}

class _ActiveScheduleCard extends StatelessWidget {
  final MitraPickupSchedule schedule;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _ActiveScheduleCard({
    required this.schedule,
    required this.onNavigate,
    required this.onCall,
    required this.onComplete,
    required this.onCancel,
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
              // Header with Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal Aktif',
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: medium,
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
                          size: 14,
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

              // User Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: greenColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.person, color: greenColor, size: 24),
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
                    decoration: BoxDecoration(
                      color: blueColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.phone, color: blueColor),
                      onPressed: onCall,
                      tooltip: 'Telepon',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: redcolor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: redcolor.withOpacity(0.1)),
                ),
                child: Row(
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
              ),
              const SizedBox(height: 12),

              // Schedule
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
                            schedule.pickupTimeStart,
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

              // Waste Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: orangeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: orangeColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: orangeColor),
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
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNavigate,
                      icon: Icon(Icons.map, size: 18, color: blueColor),
                      label: Text(
                        'Navigasi',
                        style: blueTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: semiBold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: blueColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: Icon(Icons.cancel, size: 18, color: redcolor),
                      label: Text(
                        'Batalkan',
                        style: TextStyle(
                          fontSize: 13,
                          color: redcolor,
                          fontWeight: semiBold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: redcolor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(
                    'Selesaikan',
                    style: whiteTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: semiBold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    foregroundColor: whiteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
