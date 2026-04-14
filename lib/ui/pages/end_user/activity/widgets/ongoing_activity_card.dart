import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/activity/ongoing_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card untuk activity yang sedang berlangsung
/// Card dapat diklik untuk melihat detail dan live tracking
class OngoingActivityCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onRefresh;
  final VoidCallback onChat;

  const OngoingActivityCard({
    super.key,
    required this.schedule,
    required this.onRefresh,
    required this.onChat,
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

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OngoingDetailPage(schedule: schedule),
      ),
    );
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

    return InkWell(
      onTap: () => _navigateToDetail(context),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Status Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _mapStatusToReadable(status),
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                      color: _getStatusColor(status),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: _getStatusColor(status),
                    size: 24,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waste Type
                  Text(
                    wasteSummary?.isNotEmpty == true
                        ? 'Pickup $wasteSummary'
                        : wasteType?.isNotEmpty == true
                            ? 'Pickup $wasteType'
                            : 'Layanan Sampah',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: greyTextStyle.copyWith(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Mitra Info (compact version)
                  if (mitraName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: mitraPhoto != null
                                ? NetworkImage(mitraPhoto)
                                : null,
                            child: mitraPhoto == null
                                ? const Icon(Icons.person, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mitra Pickup',
                                  style: greyTextStyle.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mitraName,
                                  style: blackTextStyle.copyWith(
                                    fontSize: 13,
                                    fontWeight: medium,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (mitraPhone != null && mitraPhone.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.phone, color: greenColor, size: 20),
                              onPressed: () => _callMitra(context, mitraPhone),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(
                              Icons.chat_bubble_outline,
                              color: blueColor,
                              size: 20,
                            ),
                            onPressed: onChat,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                  // Hint untuk tap
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Ketuk untuk melihat detail ${status == 'on_the_way' ? '& live tracking' : ''}',
                      style: greyTextStyle.copyWith(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
