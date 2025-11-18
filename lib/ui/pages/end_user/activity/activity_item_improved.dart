import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/utils/activity_helpers.dart';
import 'package:flutter/material.dart';

class ActivityItemImproved extends StatelessWidget {
  final ActivityModel activity;

  const ActivityItemImproved({super.key, required this.activity});

  Color getStatusColor() {
    switch (activity.status.toLowerCase()) {
      case 'dibatalkan':
        return Colors.red;
      case 'dijadwalkan':
        return Colors.orange;
      case 'sedang diproses': // ✅ Blue for on_progress
        return Colors.blue;
      case 'menuju lokasi':
      case 'mitra menuju lokasi':
        return Colors.blue;
      case 'selesai':
      default:
        return greenColor;
    }
  }

  // Format datetime string dengan benar, menangani baik '\n' atau '\\n' sebagai separator
  String _formatDateTime(String dateTimeStr) {
    // Cek apakah string mengandung karakter escape '\\n'
    if (dateTimeStr.contains('\\n')) {
      final parts = dateTimeStr.split('\\n');
      return parts.length > 1 ? '${parts[0]}, ${parts[1]}' : dateTimeStr;
    }
    // Cek apakah string mengandung newline '\n'
    else if (dateTimeStr.contains('\n')) {
      final parts = dateTimeStr.split('\n');
      return parts.length > 1 ? '${parts[0]}, ${parts[1]}' : dateTimeStr;
    }
    // Jika tidak ada separator, kembalikan string asli
    else {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor();

    return GestureDetector(
      onTap: () => showActivityDetailModal(context, activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon dengan animasi yang lebih baik
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: activity.status.toLowerCase() == 'selesai'
                  ? Icon(Icons.check_circle, size: 24, color: statusColor)
                  : Image.asset(
                      activity.getIcon(),
                      width: 24,
                      height: 24,
                      color: statusColor, // Warna ikon sesuai dengan status
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: blackTextStyle.copyWith(
                      fontWeight: semiBold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tampilkan alamat dengan icon lokasi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 12, color: greyColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.address,
                          style: greyTextStyle.copyWith(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Tampilkan tanggal dan waktu dalam satu baris dengan formatting yang lebih baik
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: greyColor),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(activity.dateTime),
                        style: greyTextStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon ceklis untuk status selesai
                                if (activity.status.toLowerCase() == 'selesai')
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 12,
                                      color: statusColor,
                                    ),
                                  ),
                                Text(
                                  activity.status,
                                  style: blackTextStyle.copyWith(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tampilkan badge poin jika aktivitas sudah selesai dan memiliki total poin
                          if (activity.status.toLowerCase() == 'selesai' &&
                              activity.totalPoints != null)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/ic_stars.png',
                                    width: 10,
                                    height: 10,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '+${activity.totalPoints}',
                                    style: greentextstyle2.copyWith(
                                      fontSize: 10,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            showActivityDetailModal(context, activity),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Detail',
                          style: greentextstyle2.copyWith(
                            fontWeight: medium,
                            fontSize: 12,
                          ),
                        ),
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
