import 'package:bank_sha/blocs/schedule/schedule_bloc.dart';
import 'package:bank_sha/blocs/schedule/schedule_event.dart';
import 'package:bank_sha/blocs/schedule/schedule_state.dart';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/models/waste_item.dart';
import 'package:bank_sha/services/schedule_service_new.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/mitra/waste_items_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';

/// Mitra Schedule Detail Page (BLoC version)
/// Shows detailed information about a schedule with multiple waste items
/// Uses BLoC pattern for state management
class JadwalDetailPageBloc extends StatefulWidget {
  final String scheduleId;

  const JadwalDetailPageBloc({super.key, required this.scheduleId});

  @override
  State<JadwalDetailPageBloc> createState() => _JadwalDetailPageBlocState();
}

class _JadwalDetailPageBlocState extends State<JadwalDetailPageBloc> {
  final ScheduleService _scheduleService = ScheduleService();
  ScheduleModel? _schedule;
  bool _isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    _loadScheduleDetail();
  }

  Future<void> _loadScheduleDetail() async {
    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final schedule = await _scheduleService.getSchedule(
        int.parse(widget.scheduleId),
      );

      if (mounted) {
        setState(() {
          _schedule = schedule;
          _isLoadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  void _onAcceptSchedule() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terima Jadwal'),
        content: const Text('Apakah Anda yakin ingin menerima jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleBloc>().add(
                    ScheduleAccept(scheduleId: widget.scheduleId),
                  );
            },
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  void _onStartSchedule() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mulai Pengambilan'),
        content: const Text(
          'Apakah Anda yakin ingin memulai pengambilan sampah?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleBloc>().add(
                    ScheduleStart(scheduleId: widget.scheduleId),
                  );
            },
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }

  void _onCompleteSchedule() {
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Selesaikan Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Berat Aktual (kg)',
                  hintText: 'Masukkan berat sampah yang dijemput',
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  hintText: 'Tambahkan catatan jika ada',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final actualWeight = double.tryParse(weightController.text);
              context.read<ScheduleBloc>().add(
                    ScheduleComplete(
                      scheduleId: widget.scheduleId,
                      actualWeight: actualWeight,
                      notes: notesController.text.isEmpty
                          ? null
                          : notesController.text,
                    ),
                  );
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _onCancelSchedule() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Jadwal'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Alasan pembatalan',
            hintText: 'Masukkan alasan pembatalan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleBloc>().add(
                    ScheduleCancel(
                      scheduleId: widget.scheduleId,
                      reason: reasonController.text.isEmpty
                          ? null
                          : reasonController.text,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka peta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<WasteItem> _parseWasteItems() {
    if (_schedule == null || _schedule!.wasteItems.isEmpty) return [];

    try {
      return _schedule!.wasteItems
          .map((item) {
            if (item is WasteItem) return item;
            if (item is Map<String, dynamic>) return WasteItem.fromJson(item);
            return null;
          })
          .whereType<WasteItem>()
          .toList();
    } catch (e) {
      return [];
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
      body: BlocListener<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jadwal berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload detail
            _loadScheduleDetail();
          } else if (state is ScheduleUpdateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _isLoadingDetail
            ? const Center(child: CircularProgressIndicator())
            : _schedule == null
                ? _buildErrorView()
                : RefreshIndicator(
                    onRefresh: _loadScheduleDetail,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status card
                          _buildStatusCard(),
                          const SizedBox(height: 24),

                          // Waste Items Section
                          _buildWasteItemsSection(),
                          const SizedBox(height: 24),

                          // Location section
                          _buildLocationSection(),
                          const SizedBox(height: 24),

                          // Contact section
                          if (_schedule!.contactName != null ||
                              _schedule!.contactPhone != null)
                            _buildContactSection(),

                          // Notes section
                          if (_schedule!.notes != null &&
                              _schedule!.notes!.isNotEmpty)
                            _buildNotesSection(),

                          // Action buttons
                          if (_schedule!.status != ScheduleStatus.completed &&
                              _schedule!.status != ScheduleStatus.cancelled)
                            _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          const Text(
            'Data tidak ditemukan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
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
              Icon(Icons.calendar_today, color: whiteColor, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMMM yyyy').format(_schedule!.scheduledDate),
                style: whiteTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: whiteColor, size: 16),
              const SizedBox(width: 8),
              Text(
                _schedule!.timeSlot.format(context),
                style: whiteTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasteItemsSection() {
    final wasteItems = _parseWasteItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sampah yang Dijemput',
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
          child: wasteItems.isEmpty
              ? Row(
                  children: [
                    Icon(Icons.delete_outline, color: greyColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tidak ada info sampah',
                      style: greyTextStyle.copyWith(fontSize: 13),
                    ),
                  ],
                )
              : WasteItemsListView(
                  wasteItems: wasteItems,
                  showTotal: true,
                ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  const Icon(Icons.location_on, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_schedule!.address, style: blackTextStyle),
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
                      : const Center(child: Text('Lokasi tidak tersedia')),
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
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
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
                    const Icon(Icons.person, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(_schedule!.contactName!, style: blackTextStyle),
                  ],
                ),
              if (_schedule!.contactName != null &&
                  _schedule!.contactPhone != null)
                const SizedBox(height: 8),
              if (_schedule!.contactPhone != null)
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(_schedule!.contactPhone!, style: blackTextStyle),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
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
    );
  }

  Widget _buildActionButtons() {
    final status = _schedule!.status;

    return Column(
      children: [
        if (status == ScheduleStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onAcceptSchedule,
              icon: const Icon(Icons.check),
              label: const Text('Terima Jadwal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _onCancelSchedule,
              icon: const Icon(Icons.cancel),
              label: const Text('Tolak Jadwal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        if (status == ScheduleStatus.accepted) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onStartSchedule,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Mulai Pengambilan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        if (status == ScheduleStatus.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onCompleteSchedule,
              icon: const Icon(Icons.check_circle),
              label: const Text('Selesaikan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
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
      case ScheduleStatus.accepted:
        return 'Diterima';
      default:
        return 'Menunggu';
    }
  }
}
