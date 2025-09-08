import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/end_user/tracking/tracking_full_screen.dart';
import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final String title;
  final String address;
  final String dateTime;
  final String status;

  const ActivityItem({
    super.key,
    required this.title,
    required this.address,
    required this.dateTime,
    required this.status,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'dibatalkan':
        return Colors.red;
      case 'dijadwalkan':
        return Colors.orange;
      case 'menuju lokasi':
        return Colors.blue;
      case 'selesai':
      default:
        return greenColor;
    }
  }

  void _handleTap(BuildContext context) {
    if (status.toLowerCase() == 'menuju lokasi') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TrackingFullScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.recycling, size: 40, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: blackTextStyle.copyWith(fontWeight: semiBold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$address\n$dateTime',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: blackTextStyle.copyWith(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {}, // Opsional: atau hapus saja
                        child: Text('Detail', style: greyTextStyle.copyWith()),
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
