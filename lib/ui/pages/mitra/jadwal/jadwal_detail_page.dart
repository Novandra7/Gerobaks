import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/mitra_service.dart';
import 'package:bank_sha/services/schedule_service_new.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';

class JadwalDetailPage extends StatefulWidget {
  final String scheduleId;

  const JadwalDetailPage({super.key, required this.scheduleId});

  @override
  State<JadwalDetailPage> createState() => _JadwalDetailPageState();
}

class _JadwalDetailPageState extends State<JadwalDetailPage> {
  final ScheduleService _scheduleService = ScheduleService();
  final MitraService _mitraService = MitraService();

  bool _isLoading = true;
  String? _errorMessage;
  ScheduleModel? _schedule;

  @override
  void initState() {
    super.initState();
    _loadScheduleDetail();
  }

  Future<void> _loadScheduleDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedule = await _scheduleService.getSchedule(
        int.parse(widget.scheduleId),
      );

      if (mounted) {
        setState(() {
          _schedule = schedule;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (_schedule == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _mitraService.updateScheduleStatus(
        int.parse(widget.scheduleId),
        status,
      );

      await _loadScheduleDetail();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diperbarui'),
          backgroundColor: greenColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitTracking() async {
    if (_schedule == null || !_schedule!.location.latitude.isFinite) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _mitraService.submitTracking(
        scheduleId: int.parse(widget.scheduleId),
        latitude: _schedule!.location.latitude,
        longitude: _schedule!.location.longitude,
        status: 'in_progress',
        notes: 'Menuju lokasi',
      );

      await _updateStatus('in_progress');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi berhasil diperbarui'),
          backgroundColor: greenColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui lokasi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openMapsNavigation() async {
    if (_schedule == null || !_schedule!.location.latitude.isFinite) return;

    final lat = _schedule!.location.latitude;
    final lng = _schedule!.location.longitude;

    final googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    try {
      await launchUrl(Uri.parse(googleUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka peta: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
        backgroundColor: greenColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadScheduleDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _schedule == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_schedule!.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: whiteTextStyle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusText(_schedule!.status),
                          style: whiteTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: whiteColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                              ).format(_schedule!.scheduledDate),
                              style: whiteTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: whiteColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _schedule!.timeSlot.format(context),
                              style: whiteTextStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location section
                  Text(
                    'Lokasi',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _schedule!.address,
                                style: blackTextStyle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: _schedule!.location.latitude.isFinite
                                ? FlutterMap(
                                    options: MapOptions(
                                      center: _schedule!.location,
                                      zoom: 15.0,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        subdomains: const ['a', 'b', 'c'],
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            width: 40,
                                            height: 40,
                                            point: _schedule!.location,
                                            builder: (ctx) => const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Text('Lokasi tidak tersedia'),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openMapsNavigation,
                            icon: const Icon(Icons.directions),
                            label: const Text('Navigasi ke Lokasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact section
                  if (_schedule!.contactName != null ||
                      _schedule!.contactPhone != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kontak',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (_schedule!.contactName != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _schedule!.contactName!,
                                      style: blackTextStyle,
                                    ),
                                  ],
                                ),
                              if (_schedule!.contactName != null &&
                                  _schedule!.contactPhone != null)
                                const SizedBox(height: 8),
                              if (_schedule!.contactPhone != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _schedule!.contactPhone!,
                                      style: blackTextStyle,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Notes section
                  if (_schedule!.notes != null && _schedule!.notes!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(_schedule!.notes!, style: blackTextStyle),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Action buttons
                  if (_schedule!.status != ScheduleStatus.completed &&
                      _schedule!.status != ScheduleStatus.cancelled)
                    Row(
                      children: [
                        if (_schedule!.status == ScheduleStatus.pending)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _submitTracking(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Mulai Pengambilan'),
                            ),
                          ),
                        if (_schedule!.status == ScheduleStatus.inProgress) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus('completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Selesaikan'),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.completed:
        return greenColor;
      case ScheduleStatus.inProgress:
        return blueColor;
      case ScheduleStatus.cancelled:
        return redcolor;
      case ScheduleStatus.missed:
        return orangeColor;
      default:
        return purpleColor;
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.completed:
        return 'Selesai';
      case ScheduleStatus.inProgress:
        return 'Dalam Proses';
      case ScheduleStatus.cancelled:
        return 'Dibatalkan';
      case ScheduleStatus.missed:
        return 'Terlewat';
      default:
        return 'Menunggu';
    }
  }
}
