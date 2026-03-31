import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';
import '../../../services/location_service.dart';
import '../../../services/tracking_api_service.dart';
import 'complete_pickup_page.dart';

class ScheduleDetailPage extends StatefulWidget {
  final MitraPickupSchedule schedule;

  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  final MitraApiService _apiService = MitraApiService();
  final LocationService _locationService = LocationService();
  final TrackingApiService _trackingApi = TrackingApiService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _apiService.initialize();
  }

  Future<void> _acceptSchedule() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Jadwal?'),
        content: Text(
          'Apakah Anda yakin ingin menerima jadwal pengambilan dari ${widget.schedule.userName}?\n\n'
          'Pastikan Anda dapat mengambil sampah pada waktu yang ditentukan.',
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

    setState(() => _isProcessing = true);

    try {
      await _apiService.acceptSchedule(widget.schedule.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Jadwal berhasil diterima'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menerima jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _startJourney() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚗 Berangkat Sekarang?'),
        content: Text(
          'Apakah Anda yakin ingin memulai perjalanan ke lokasi ${widget.schedule.userName}?\n\n'
          '📍 GPS tracking akan aktif\n'
          '⏱️ User dapat melacak lokasi Anda secara real-time',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Berangkat!'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      // 1. Update status ke backend
      await _apiService.startJourney(widget.schedule.id);

      // 2. Start GPS tracking (auto send every 15 seconds)
      bool trackingStarted = await _locationService.startTracking(
        intervalSeconds: 15,
        onUpdate: (position) async {
          try {
            await _trackingApi.updateMitraLocation(position);
            debugPrint(
              '✅ GPS location sent: ${position.latitude}, ${position.longitude}',
            );
          } catch (e) {
            debugPrint('❌ Failed to send GPS: $e');
          }
        },
      );

      if (mounted) {
        if (trackingStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Perjalanan dimulai! GPS tracking aktif'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Perjalanan dimulai, tapi GPS gagal aktif. Periksa izin GPS.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal memulai perjalanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _releaseSchedule() async {
    // Show reason input dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        String inputReason = '';
        return AlertDialog(
          title: const Text('🔄 Lepaskan Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Berikan alasan pelepasan jadwal:'),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Kendaraan rusak, tidak bisa hadir',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => inputReason = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (inputReason.trim().isEmpty) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan tidak boleh kosong')),
                  );
                  return;
                }
                Navigator.pop(context, inputReason);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Lepaskan Jadwal'),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      await _apiService.releaseSchedule(widget.schedule.id, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Jadwal berhasil dikembalikan ke pending'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal melepas jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _confirmArrival() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📍 Konfirmasi Kedatangan?'),
        content: Text(
          'Apakah Anda sudah tiba di lokasi ${widget.schedule.userName}?\n\n'
          'Pastikan Anda sudah berada di lokasi pengambilan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Ya, Sudah Tiba'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final position = await _locationService.getCurrentPosition();
      await _apiService.confirmArrival(
        widget.schedule.id,
        latitude: position?.latitude ?? widget.schedule.latitude,
        longitude: position?.longitude ?? widget.schedule.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kedatangan dikonfirmasi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal konfirmasi kedatangan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _goToCompletePickup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletePickupPage(schedule: widget.schedule),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.schedule.latitude},${widget.schedule.longitude}',
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

  Future<void> _callUser() async {
    final url = Uri.parse('tel:${widget.schedule.userPhone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
        );
      }
    }
  }

  Future<void> _whatsappUser() async {
    final url = Uri.parse(
      'https://wa.me/${widget.schedule.userPhone.replaceAll(RegExp(r'[^0-9]'), '')}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  bool get _hasBottomActions {
    final schedule = widget.schedule;
    return schedule.isPending ||
        schedule.isAssigned ||
        schedule.isAccepted ||
        schedule.isOnTheWay ||
        schedule.isArrived;
  }

  Widget _buildActionButtons() {
    final schedule = widget.schedule;

    // Pending: Terima Jadwal
    if (schedule.isPending) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : _acceptSchedule,
          icon: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: whiteColor,
                  ),
                )
              : const Icon(Icons.check_circle),
          label: Text(_isProcessing ? 'Memproses...' : 'Terima Jadwal'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: greenColor,
            foregroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    // Accepted/Assigned: Batalkan + BERANGKAT
    if (schedule.isAssigned || schedule.isAccepted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : _releaseSchedule,
              icon: const Icon(Icons.cancel_outlined, size: 20),
              label: const Text('Batalkan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: redcolor,
                side: BorderSide(color: redcolor.withAlpha(128)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _startJourney,
              icon: _isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: whiteColor,
                      ),
                    )
                  : const Icon(Icons.directions_car),
              label: Text(_isProcessing ? 'Loading...' : 'BERANGKAT'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: greenColor,
                foregroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    // On The Way: Navigasi + Tiba di Lokasi
    if (schedule.isOnTheWay) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _openGoogleMaps,
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('Navigasi ke Lokasi'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: blueColor,
                  side: BorderSide(color: blueColor.withAlpha(128)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _confirmArrival,
                icon: _isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: whiteColor,
                        ),
                      )
                    : const Icon(Icons.location_on),
                label: Text(_isProcessing ? 'Memproses...' : 'Tiba di Lokasi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: blueColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Arrived: Hubungi + Selesaikan Pickup
    if (schedule.isArrived) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _callUser,
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Hubungi Pelanggan'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: blueColor,
                  side: BorderSide(color: blueColor.withAlpha(128)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _goToCompletePickup,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Selesaikan Pickup'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: orangeColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  double _parseWeight(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalizedValue = value.trim().replaceAll(',', '.');
      return double.tryParse(normalizedValue) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;
    final pickupLatLng = LatLng(schedule.latitude, schedule.longitude);
    final additionalWastes = schedule.additionalWastes ?? const <AdditionalWaste>[];
    final additionalWasteTypes = additionalWastes
        .map((w) => w.type.trim().toLowerCase())
        .where((type) => type.isNotEmpty)
        .toSet();

    final scheduledEstimatedWeights = <String, double>{};
    (schedule.estimatedWeights ?? const <String, dynamic>{}).forEach((type, value) {
      final normalizedType = type.trim().toLowerCase();
      if (normalizedType.isEmpty || additionalWasteTypes.contains(normalizedType)) {
        return;
      }

      final parsedWeight = _parseWeight(value);
      if (parsedWeight <= 0) return;

      scheduledEstimatedWeights[type] = parsedWeight;
    });

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Detail Jadwal',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        backgroundColor: whiteColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: blackColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_new, color: greenColor, size: 22),
            onPressed: _openGoogleMaps,
            tooltip: 'Buka di Google Maps',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: schedule.statusColor.withAlpha(64),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        schedule.statusIcon,
                        color: schedule.statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        schedule.statusDisplay,
                        style: TextStyle(
                          color: schedule.statusColor,
                          fontWeight: semiBold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Customer Info ──
                _buildSection(
                  icon: Icons.person_outline,
                  iconColor: greenColor,
                  title: 'Informasi Pelanggan',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: greenColor.withAlpha(26),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: greenColor.withAlpha(64),
                                width: 1.5,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                (widget.schedule.profilePicture?.trim().isNotEmpty ??
                                    false)
                                ? Image.network(
                                    widget.schedule.profilePicture!.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        (schedule.userName.trim().isNotEmpty
                                                ? schedule.userName.trim()[0]
                                                : '?')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: greenColor,
                                          fontSize: 26,
                                          fontWeight: bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      (schedule.userName.trim().isNotEmpty
                                              ? schedule.userName.trim()[0]
                                              : '?')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: greenColor,
                                        fontSize: 26,
                                        fontWeight: bold,
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
                                    fontSize: 16,
                                    fontWeight: bold,
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
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildContactButton(
                              icon: Icons.phone_outlined,
                              label: 'Telepon',
                              color: blueColor,
                              onTap: _callUser,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildContactButton(
                              icon: Icons.chat_outlined,
                              label: 'WhatsApp',
                              color: greenColor,
                              onTap: _whatsappUser,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Embedded Map ──
                _buildSection(
                  icon: Icons.map_outlined,
                  iconColor: greenColor,
                  title: 'Lokasi Pengambilan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _openGoogleMaps,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: greyColor.withAlpha(51)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              AbsorbPointer(
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: pickupLatLng,
                                    initialZoom: 15.0,
                                    minZoom: 12.0,
                                    maxZoom: 18.0,
                                    interactionOptions:
                                        const InteractionOptions(
                                          flags: InteractiveFlag.none,
                                        ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c', 'd'],
                                      userAgentPackageName: 'com.gerobaks.app',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: pickupLatLng,
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            Icons.location_on,
                                            color: redcolor,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: whiteColor.withAlpha(235),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: blackColor.withAlpha(20),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.open_in_new,
                                        size: 14,
                                        color: greenColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Buka Maps',
                                        style: greenTextStyle.copyWith(
                                          fontSize: 11,
                                          fontWeight: semiBold,
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
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: redcolor.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: 16,
                              color: redcolor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              schedule.pickupAddress,
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Schedule ──
                _buildSection(
                  icon: Icons.calendar_today_outlined,
                  iconColor: blueColor,
                  title: 'Jadwal Pengambilan',
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        iconColor: blueColor,
                        label: 'Hari',
                        value: schedule.scheduleDay,
                      ),
                      Divider(height: 20, color: greyColor.withAlpha(38)),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        iconColor: orangeColor,
                        label: 'Waktu',
                        value:
                            '${schedule.pickupTimeStart} - ${schedule.pickupTimeEnd}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Waste Info ──
                _buildSection(
                  icon: Icons.delete_outline,
                  iconColor: orangeColor,
                  title: 'Informasi Sampah',
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        iconColor: greenColor,
                        label: 'Jenis Sampah',
                        value: schedule.wasteTypeScheduled,
                      ),
                      Divider(height: 20, color: greyColor.withAlpha(38)),
                      _buildDetailRow(
                        icon: Icons.scale_outlined,
                        iconColor: blueColor,
                        label: 'Berat Terjadwal',
                        value: '${schedule.scheduledWeight} kg',
                      ),
                      Divider(height: 20, color: greyColor.withAlpha(38)),
                      _buildDetailRow(
                        icon: Icons.summarize_outlined,
                        iconColor: orangeColor,
                        label: 'Ringkasan',
                        value: schedule.wasteSummary,
                      ),
                      Divider(height: 20, color: greyColor.withAlpha(38)),
                      _buildDetailRow(
                        icon: Icons.note_alt_outlined,
                        iconColor: blueColor,
                        label: 'Catatan',
                        value:
                            (schedule.notes == null ||
                                schedule.notes!.trim().isEmpty)
                            ? '-'
                            : schedule.notes!,
                      ),
                    ],
                  ),
                ),

                // ── Estimated Weights ──
                if (scheduledEstimatedWeights.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildEstimatedWeightsSection(scheduledEstimatedWeights),
                ],

                // ── Additional Wastes ──
                if (additionalWastes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAdditionalWastesSection(additionalWastes),
                ],

                // ── Waste Image (if available) ──
                if (widget.schedule.wasteImage?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildSection(
                    icon: Icons.photo_library_outlined,
                    iconColor: greenColor,
                    title: 'Foto Sampah dari User',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.schedule.wasteImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: greyColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: greyColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: greyTextStyle.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: greyColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: greenColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                SizedBox(height: _hasBottomActions ? 96 : 20),
              ],
            ),
          ),

          // ── Bottom Action Buttons ──
          if (_hasBottomActions)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withAlpha(15),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(child: _buildActionButtons()),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section card builder ──
  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
              ),
            ],
          ),
          Divider(height: 20, color: greyColor.withAlpha(38)),
          child,
        ],
      ),
    );
  }

  // ── Detail row ──
  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: greyTextStyle.copyWith(fontSize: 12)),
              const SizedBox(height: 3),
              Text(
                value,
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Estimated weights card ──
  Widget _buildEstimatedWeightsSection(Map<String, dynamic> weights) {
    final entries = weights.entries.toList();
    final totalWeight = entries.fold<double>(
      0,
      (sum, e) => sum + ((e.value as num?)?.toDouble() ?? 0.0),
    );

    final List<Color> itemColors = [
      greenColor,
      blueColor,
      orangeColor,
      redcolor,
      const Color(0xff8B5CF6),
      const Color(0xff0D9488),
    ];

    IconData iconForType(String type) {
      final t = type.toLowerCase();
      if (t.contains('plastik')) return Icons.shopping_bag_outlined;
      if (t.contains('kertas') || t.contains('koran')) return Icons.article_outlined;
      if (t.contains('logam') || t.contains('besi') || t.contains('aluminium')) return Icons.hardware_outlined;
      if (t.contains('kaca') || t.contains('botol')) return Icons.local_bar_outlined;
      if (t.contains('b3') || t.contains('kimia')) return Icons.warning_amber_rounded;
      if (t.contains('elektro')) return Icons.devices_outlined;
      if (t.contains('organik')) return Icons.eco_outlined;
      return Icons.recycling_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: blueColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.scale_outlined, size: 18, color: blueColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Estimasi Berat Terjadwal',
                  style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: blueColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entries.length} jenis',
                  style: TextStyle(
                    color: blueColor,
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20, color: greyColor.withAlpha(38)),

          // Item list
          ...entries.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final e = mapEntry.value;
            final color = itemColors[index % itemColors.length];
            final weight = (e.value as num?)?.toDouble() ?? 0.0;

            return Padding(
              padding: EdgeInsets.only(bottom: index < entries.length - 1 ? 10 : 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconForType(e.key), size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.key,
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withAlpha(51)),
                    ),
                    child: Text(
                      '${weight % 1 == 0 ? weight.toInt() : weight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Total
          Divider(height: 20, color: greyColor.withAlpha(38)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Estimasi',
                style: greyTextStyle.copyWith(fontSize: 13, fontWeight: medium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: blueColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor.withAlpha(64)),
                ),
                child: Text(
                  '${totalWeight % 1 == 0 ? totalWeight.toInt() : totalWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: blueColor,
                    fontSize: 14,
                    fontWeight: bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Additional wastes card ──
  Widget _buildAdditionalWastesSection(List<AdditionalWaste> wastes) {
    final List<Color> itemColors = [
      orangeColor,
      redcolor,
      const Color(0xff8B5CF6),
      const Color(0xff0D9488),
      greenColor,
      blueColor,
    ];

    IconData iconForType(String type) {
      final t = type.toLowerCase();
      if (t.contains('plastik')) return Icons.shopping_bag_outlined;
      if (t.contains('kertas') || t.contains('koran')) return Icons.article_outlined;
      if (t.contains('logam') || t.contains('besi') || t.contains('aluminium')) return Icons.hardware_outlined;
      if (t.contains('kaca') || t.contains('botol')) return Icons.local_bar_outlined;
      if (t.contains('b3') || t.contains('kimia')) return Icons.warning_amber_rounded;
      if (t.contains('elektro')) return Icons.devices_outlined;
      if (t.contains('organik')) return Icons.eco_outlined;
      return Icons.recycling_outlined;
    }

    final totalWeight = wastes.fold<double>(
      0,
      (sum, w) => sum + w.estimatedWeight,
    );

    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: orangeColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_circle_outline, size: 18, color: orangeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sampah Tambahan',
                  style: blackTextStyle.copyWith(fontSize: 16, fontWeight: bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: orangeColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${wastes.length} jenis',
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20, color: greyColor.withAlpha(38)),

          // Item list
          ...List.generate(wastes.length, (index) {
            final waste = wastes[index];
            final color = itemColors[index % itemColors.length];
            final weight = waste.estimatedWeight;

            return Padding(
              padding: EdgeInsets.only(bottom: index < wastes.length - 1 ? 10 : 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconForType(waste.type), size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      waste.type,
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withAlpha(51)),
                    ),
                    child: Text(
                      '${weight % 1 == 0 ? weight.toInt() : weight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Total
          Divider(height: 20, color: greyColor.withAlpha(38)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Estimasi',
                style: greyTextStyle.copyWith(fontSize: 13, fontWeight: medium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: orangeColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: orangeColor.withAlpha(64)),
                ),
                child: Text(
                  '${totalWeight % 1 == 0 ? totalWeight.toInt() : totalWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 14,
                    fontWeight: bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact button ──
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(89)),
          borderRadius: BorderRadius.circular(12),
          color: color.withAlpha(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: semiBold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
