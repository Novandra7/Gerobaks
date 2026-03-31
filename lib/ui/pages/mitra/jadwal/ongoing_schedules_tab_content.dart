import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/mitra_pickup_schedule.dart';
import '../../../../services/mitra_api_service.dart';
import '../../../../services/location_service.dart';

/// Tab content for "Berjalan" tab
/// Shows schedules with status: accepted, on_the_way, arrived, on_progress
class OngoingSchedulesTabContent extends StatefulWidget {
  const OngoingSchedulesTabContent({super.key});

  @override
  State<OngoingSchedulesTabContent> createState() =>
      _OngoingSchedulesTabContentState();
}

class _OngoingSchedulesTabContentState extends State<OngoingSchedulesTabContent>
    with AutomaticKeepAliveClientMixin {
  final MitraApiService _apiService = MitraApiService();
  final LocationService _locationService = LocationService();
  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeService();
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
    });

    try {
      final all = await _apiService.getMyActiveSchedules();
      if (!mounted) return;
      setState(() {
        _schedules = all
            .where((s) => s.isOnTheWay || s.isArrived || s.isOnProgress)
            .toList();
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

  void _viewDetail(MitraPickupSchedule schedule) async {
    final result = await Navigator.pushNamed(
      context,
      '/mitra/schedule-detail',
      arguments: schedule,
    );
    if (result == true) {
      _loadSchedules();
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

  // on_the_way → arrived
  Future<void> _confirmArrival(MitraPickupSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: greenColor, size: 28),
            const SizedBox(width: 8),
            const Text('Konfirmasi Tiba?'),
          ],
        ),
        content: Text(
          'Pastikan Anda sudah berada di lokasi ${schedule.userName}.',
          style: greyTextStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: greyTextStyle),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sudah Tiba'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isProcessing = true);

    try {
      final position = await _locationService.getCurrentPosition();
      await _apiService.confirmArrival(
        schedule.id,
        latitude: position?.latitude ?? schedule.latitude,
        longitude: position?.longitude ?? schedule.longitude,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kedatangan dikonfirmasi!'),
            backgroundColor: greenColor,
          ),
        );
        _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal konfirmasi kedatangan: $e'),
            backgroundColor: redcolor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _releaseSchedule(MitraPickupSchedule schedule) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: redcolor, size: 28),
            const SizedBox(width: 8),
            const Text('Lepaskan Jadwal?')
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda yakin ingin melepas assignment pickup untuk ${schedule.userName} agar kembali ke pending?',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan pelepasan jadwal...',
                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: redcolor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Kembali', style: greyTextStyle),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan pelepasan wajib diisi'),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redcolor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.releaseSchedule(
        schedule.id,
        reasonController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jadwal berhasil dikembalikan ke pending'),
            backgroundColor: greenColor,
          ),
        );
        _loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melepas jadwal: $e'),
            backgroundColor: redcolor,
          ),
        );
      }
    }
  }

  String _getHeaderLabel(MitraPickupSchedule schedule) {
    if (schedule.isOnTheWay) return 'Menuju Lokasi';
    if (schedule.isArrived) return 'Tiba di Lokasi';
    if (schedule.isOnProgress) return 'Sedang Proses';
    return 'Berjalan';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                Icons.directions_car_outlined,
                size: 64,
                color: greyColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada jadwal berjalan',
              style: greyTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadwal dalam perjalanan akan muncul di sini',
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
          return _OngoingScheduleCard(
            schedule: schedule,
            headerLabel: _getHeaderLabel(schedule),
            isProcessing: _isProcessing,
            onTap: () => _viewDetail(schedule),
            onNavigate: () => _openGoogleMaps(schedule),
            onCall: () => _callUser(schedule),
            onConfirmArrival: () => _confirmArrival(schedule),
            onCancel: () => _releaseSchedule(schedule),
          );
        },
      ),
    );
  }
}

class _OngoingScheduleCard extends StatelessWidget {
  final MitraPickupSchedule schedule;
  final String headerLabel;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  final VoidCallback onConfirmArrival;
  final VoidCallback onCancel;

  const _OngoingScheduleCard({
    required this.schedule,
    required this.headerLabel,
    required this.isProcessing,
    required this.onTap,
    required this.onNavigate,
    required this.onCall,
    required this.onConfirmArrival,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: orangeColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: orangeColor.withOpacity(0.1), width: 1),
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
                // Header with Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      headerLabel,
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
                        if (schedule.additionalWastes != null &&
                            schedule.additionalWastes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ...schedule.additionalWastes!.map((w) {
                            return Padding(
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
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Action buttons — dynamic per status
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // on_the_way → "Sudah Tiba" + "Batalkan" + "Navigasi"
    if (schedule.isOnTheWay) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onConfirmArrival,
              icon: isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.location_on, size: 18),
              label: Text(
                'Sudah Tiba',
                style: whiteTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: whiteColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(Icons.close, size: 18, color: redcolor),
                  label: Text(
                    'Batalkan',
                    style: TextStyle(
                      color: redcolor,
                      fontSize: 13,
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
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: Icon(Icons.navigation, size: 18, color: blueColor),
                  label: Text(
                    'Navigasi',
                    style: TextStyle(
                      color: blueColor,
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
            ],
          ),
        ],
      );
    }

    // arrived → "Lihat Detail" (to complete from detail page)
    if (schedule.isArrived) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.done_all, size: 18),
          label: Text(
            'Selesaikan Pickup',
            style: whiteTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: greenColor,
            foregroundColor: whiteColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    // on_progress → "Lihat Detail"
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.visibility, size: 18, color: orangeColor),
        label: Text(
          'Lihat Detail',
          style: TextStyle(
            color: orangeColor,
            fontSize: 14,
            fontWeight: semiBold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: orangeColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
