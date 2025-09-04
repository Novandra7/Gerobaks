import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String status;
  final VoidCallback onTap;

  const ScheduleItem({
    Key? key,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    // Set status color and text based on status
    switch (status.toLowerCase()) {
      case 'completed':
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      case 'cancelled':
      case 'dibatalkan':
        statusColor = Colors.red;
        statusText = 'Dibatalkan';
        break;
      case 'inprogress':
      case 'dalam proses':
        statusColor = Colors.blue;
        statusText = 'Dalam Proses';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: medium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: greyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: greyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: greyTextStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: greenColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(56),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Detail',
                      style: TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (status.toLowerCase() == 'inprogress' || 
                    status.toLowerCase() == 'dalam proses')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to tracking page for in-progress schedules
                        Navigator.pushNamed(context, '/tracking');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'Lacak',
                        style: whiteTextStyle.copyWith(
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
