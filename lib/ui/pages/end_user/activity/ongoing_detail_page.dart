import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/activity/widgets/gps_tracking_view.dart';
import 'package:bank_sha/ui/pages/end_user/activity/widgets/mitra_info_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman detail untuk pickup yang sedang berlangsung
/// Menampilkan: GPS Tracking Map, Mitra Info, Detail lengkap
class OngoingDetailPage extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const OngoingDetailPage({
    super.key,
    required this.schedule,
  });

  String _mapStatusToReadable(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned':
      case 'accepted':
        return 'Mitra Ditemukan';
      case 'on_progress':
        return 'Sedang Diproses';
      case 'on_the_way':
        return 'Mitra Menuju Lokasi';
      case 'arrived':
        return 'Mitra Sudah Tiba';
      default:
        return status?.replaceAll('_', ' ').toUpperCase() ?? 'Unknown';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned':
      case 'accepted':
        return Colors.blue;
      case 'on_progress':
        return Colors.orange;
      case 'on_the_way':
        return greenColor;
      case 'arrived':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned':
      case 'accepted':
        return Icons.person_search;
      case 'on_progress':
        return Icons.autorenew;
      case 'on_the_way':
        return Icons.local_shipping;
      case 'arrived':
        return Icons.location_on;
      default:
        return Icons.info;
    }
  }

  Future<void> _callMitra(BuildContext context, String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon mitra tidak tersedia')),
      );
      return;
    }

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
      );
    }
  }

  String _formatDateTime(String? date, String? time) {
    if (date == null) return '-';
    try {
      final dateParts = date.split('-');
      final year = dateParts[0];
      final month = dateParts[1];
      final day = dateParts[2];

      if (time != null && time.isNotEmpty) {
        return '$day/$month/$year • $time';
      }
      return '$day/$month/$year';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = schedule['status']?.toString();
    final mitraName = schedule['assigned_mitra']?['name']?.toString();
    final mitraPhone = schedule['assigned_mitra']?['phone']?.toString();
    final mitraPhoto = schedule['assigned_mitra']?['photo']?.toString();
    final wasteSummary = schedule['waste_summary']?.toString();
    final wasteType = schedule['waste_type_scheduled']?.toString();
    final address = schedule['pickup_address']?.toString() ?? 'Alamat tidak tersedia';
    final notes = schedule['notes']?.toString();
    final scheduleDate = schedule['schedule_date']?.toString();
    final pickupTimeStart = schedule['pickup_time_start']?.toString();

    final showGpsTracking = status == 'on_the_way' || status == 'arrived';

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Pickup'),
        backgroundColor: whiteColor,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _mapStatusToReadable(status),
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: semiBold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // GPS Tracking Map (only for on_the_way and arrived)
            if (showGpsTracking) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Tracking',
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GpsTrackingView(
                        scheduleId: schedule['id']?.toString() ?? '',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Detail Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Pickup',
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Waste Type
                      _buildDetailRow(
                        icon: Icons.delete_outline,
                        label: 'Jenis Sampah',
                        value: wasteSummary?.isNotEmpty == true
                            ? wasteSummary!
                            : wasteType?.isNotEmpty == true
                                ? wasteType!
                                : 'Layanan Sampah',
                      ),

                      const SizedBox(height: 12),

                      // Schedule Date & Time
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Jadwal Pickup',
                        value: _formatDateTime(scheduleDate, pickupTimeStart),
                      ),

                      const SizedBox(height: 12),

                      // Address
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: 'Alamat',
                        value: address,
                        maxLines: 3,
                      ),

                      if (notes != null && notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.note,
                          label: 'Catatan',
                          value: notes,
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mitra Info Card
            if (mitraName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Mitra',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MitraInfoCard(
                          mitraName: mitraName,
                          mitraPhone: mitraPhone,
                          mitraPhoto: mitraPhoto,
                          onCallPressed: () => _callMitra(context, mitraPhone),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: greyTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: medium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
