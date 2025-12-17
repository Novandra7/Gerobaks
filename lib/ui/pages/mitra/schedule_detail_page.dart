import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/mitra_pickup_schedule.dart';
import '../../../services/mitra_api_service.dart';
import '../../../services/location_service.dart';
import '../../../services/tracking_api_service.dart';

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
            print(
              '✅ GPS location sent: ${position.latitude}, ${position.longitude}',
            );
          } catch (e) {
            print('❌ Failed to send GPS: $e');
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

  Future<void> _cancelSchedule() async {
    // Show reason input dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        String inputReason = '';
        return AlertDialog(
          title: const Text('❌ Batalkan Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Berikan alasan pembatalan:'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan tidak boleh kosong')),
                  );
                  return;
                }
                Navigator.pop(context, inputReason);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Batalkan Jadwal'),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      await _apiService.cancelSchedule(widget.schedule.id, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Jadwal berhasil dibatalkan'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal membatalkan: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _openGoogleMaps,
            tooltip: 'Buka di Maps',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.schedule.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.schedule.statusIcon,
                        color: widget.schedule.statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.schedule.statusDisplay,
                        style: TextStyle(
                          color: widget.schedule.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Pelanggan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[100],
                              radius: 30,
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.schedule.userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.schedule.userPhone,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _callUser,
                                icon: const Icon(Icons.phone, size: 20),
                                label: const Text('Telepon'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _whatsappUser,
                                icon: const Icon(Icons.chat, size: 20),
                                label: const Text('WhatsApp'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi Pengambilan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.schedule.pickupAddress,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lat: ${widget.schedule.latitude.toStringAsFixed(6)}, '
                              'Long: ${widget.schedule.longitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openGoogleMaps,
                            icon: const Icon(Icons.map),
                            label: const Text('Buka di Google Maps'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Schedule Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jadwal Pengambilan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          iconColor: Colors.blue,
                          label: 'Hari',
                          value: widget.schedule.scheduleDay,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.access_time,
                          iconColor: Colors.orange,
                          label: 'Waktu',
                          value: widget.schedule.pickupTimeStart,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Waste Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Sampah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.category,
                          iconColor: Colors.green,
                          label: 'Jenis',
                          value: widget.schedule.wasteTypeScheduled,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.delete_outline,
                          iconColor: Colors.orange,
                          label: 'Ringkasan',
                          value: widget.schedule.wasteSummary,
                        ),
                        if (widget.schedule.notes != null &&
                            widget.schedule.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.note,
                            iconColor: Colors.blue,
                            label: 'Catatan',
                            value: widget.schedule.notes!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),

          // Bottom Action Buttons (Fixed)
          if (widget.schedule.isPending || widget.schedule.isAccepted)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: widget.schedule.isPending
                      ? ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _acceptSchedule,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: Text(
                            _isProcessing ? 'Memproses...' : 'Terima Jadwal',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Navigasi
                            OutlinedButton.icon(
                              onPressed: _isProcessing ? null : _openGoogleMaps,
                              icon: const Icon(Icons.navigation),
                              label: const Text('Navigasi'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tombol Berangkat + Batalkan
                            Row(
                              children: [
                                // Tombol Batalkan
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isProcessing
                                        ? null
                                        : _cancelSchedule,
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Batalkan'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Tombol BERANGKAT
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    onPressed: _isProcessing
                                        ? null
                                        : _startJourney,
                                    icon: _isProcessing
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.directions_car),
                                    label: Text(
                                      _isProcessing
                                          ? 'Loading...'
                                          : 'BERANGKAT',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
