import 'package:bank_sha/shared/theme.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/mitra_pickup_schedule.dart';
import '../../../../services/mitra_api_service.dart';
import '../../../../services/location_service.dart';
import '../../../../services/realtime_tracking_service.dart';

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
  static const String _trackingReminderShownKey = 'tracking_reminder_shown';

  final MitraApiService _apiService = MitraApiService();
  final LocationService _locationService = LocationService();
  final RealTimeTrackingService _realtimeTrackingService =
      RealTimeTrackingService();
  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isAutoArriving = false;
  String? _error;
  Timer? _arrivalCheckTimer;
  int? _arrivalCheckScheduleId;

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
      final ongoingSchedules = all
          .where(
            (s) =>
                s.isAccepted || s.isOnTheWay || s.isArrived || s.isOnProgress,
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _schedules = ongoingSchedules;
        _isLoading = false;
      });

      await _syncTrackingState(ongoingSchedules);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _stopArrivalMonitor();
    super.dispose();
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

  Future<void> _startJourney(MitraPickupSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: greenColor, size: 28),
            const SizedBox(width: 8),
            const Text('Mulai Perjalanan?'),
          ],
        ),
        content: Text(
          'Mulai perjalanan ke lokasi ${schedule.userName}?\n\n'
          'GPS tracking akan aktif agar user bisa memantau posisi Anda.',
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
            child: const Text('Mulai'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isProcessing = true);

    try {
      final position = await _locationService.getCurrentPosition();
      await _apiService.startJourney(
        schedule.id,
        currentLatitude: position?.latitude,
        currentLongitude: position?.longitude,
      );

      await _showTrackingReminderIfNeeded();
      await _realtimeTrackingService.startMitraTracking(schedule.id);
      _startArrivalMonitor(schedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perjalanan dimulai. GPS tracking aktif'),
            backgroundColor: greenColor,
          ),
        );
      }

      await _loadSchedules();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai perjalanan: $e'),
            backgroundColor: redcolor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showTrackingReminderIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool(_trackingReminderShownKey) ?? false;
    if (hasShown || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: blueColor, size: 26),
            const SizedBox(width: 8),
            const Text('Penting!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agar tracking tetap akurat selama pengantaran:',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildReminderItem('Jangan tutup aplikasi saat delivery aktif'),
            _buildReminderItem('Pastikan GPS tetap menyala'),
            _buildReminderItem('Pastikan koneksi internet stabil'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );

    await prefs.setBool(_trackingReminderShownKey, true);
  }

  Widget _buildReminderItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: greenColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: greyTextStyle.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
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
      await _stopTrackingForSchedule(schedule.id);
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
            const Text('Lepaskan Jadwal?'),
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
                  const SnackBar(content: Text('Alasan pelepasan wajib diisi')),
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
      await _stopTrackingForSchedule(schedule.id);
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
    if (schedule.isAccepted) return 'Siap Berangkat';
    if (schedule.isOnTheWay) return 'Menuju Lokasi';
    if (schedule.isArrived) return 'Tiba di Lokasi';
    if (schedule.isOnProgress) return 'Sedang Proses';
    return 'Berjalan';
  }

  Future<void> _syncTrackingState(List<MitraPickupSchedule> schedules) async {
    final trackedScheduleId = _realtimeTrackingService.currentPickupScheduleId;
    final isTracking = _realtimeTrackingService.isTracking;

    if (trackedScheduleId != null && isTracking) {
      MitraPickupSchedule? trackedSchedule;
      for (final schedule in schedules) {
        if (schedule.id == trackedScheduleId) {
          trackedSchedule = schedule;
          break;
        }
      }

      if (trackedSchedule == null || !trackedSchedule.isOnTheWay) {
        await _stopTrackingForSchedule(trackedScheduleId);
        return;
      }

      _startArrivalMonitor(trackedSchedule);
      return;
    }

    MitraPickupSchedule? onTheWaySchedule;
    for (final schedule in schedules) {
      if (schedule.isOnTheWay) {
        onTheWaySchedule = schedule;
        break;
      }
    }

    if (onTheWaySchedule != null) {
      await _realtimeTrackingService.startMitraTracking(onTheWaySchedule.id);
      _startArrivalMonitor(onTheWaySchedule);
    } else {
      _stopArrivalMonitor();
    }
  }

  void _startArrivalMonitor(MitraPickupSchedule schedule) {
    if (_arrivalCheckScheduleId == schedule.id && _arrivalCheckTimer != null) {
      return;
    }

    _stopArrivalMonitor();
    _arrivalCheckScheduleId = schedule.id;

    _arrivalCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted || _isAutoArriving || _isProcessing) return;

      try {
        final position = await _locationService.getCurrentPosition();
        if (position == null) return;

        final distanceKm = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          schedule.latitude,
          schedule.longitude,
        );

        final distanceMeters = distanceKm * 1000;
        if (distanceMeters > 50) return;

        _isAutoArriving = true;
        await _apiService.confirmArrival(
          schedule.id,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await _stopTrackingForSchedule(schedule.id);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Anda sudah dekat lokasi. Status diubah ke tiba',
            ),
            backgroundColor: greenColor,
          ),
        );
        await _loadSchedules();
      } catch (_) {
        debugPrint('Auto-arrival check failed for schedule ${schedule.id}');
      } finally {
        _isAutoArriving = false;
      }
    });
  }

  void _stopArrivalMonitor() {
    _arrivalCheckTimer?.cancel();
    _arrivalCheckTimer = null;
    _arrivalCheckScheduleId = null;
  }

  Future<void> _stopTrackingForSchedule(int scheduleId) async {
    _stopArrivalMonitor();
    if (_realtimeTrackingService.currentPickupScheduleId != scheduleId &&
        !_realtimeTrackingService.isTracking) {
      return;
    }

    try {
      await _realtimeTrackingService.stopMitraTracking(scheduleId);
    } catch (e) {
      debugPrint('Failed to stop tracking for schedule $scheduleId: $e');
    }
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
            onStartJourney: () => _startJourney(schedule),
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
  final VoidCallback onStartJourney;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  final VoidCallback onConfirmArrival;
  final VoidCallback onCancel;

  const _OngoingScheduleCard({
    required this.schedule,
    required this.headerLabel,
    required this.isProcessing,
    required this.onTap,
    required this.onStartJourney,
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
    // accepted → "Mulai Perjalanan" + "Batalkan" + "Navigasi"
    if (schedule.isAccepted) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onStartJourney,
              icon: isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 18),
              label: Text(
                'Mulai Perjalanan',
                style: whiteTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
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
