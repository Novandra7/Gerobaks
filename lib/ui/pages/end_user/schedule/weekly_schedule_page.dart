import 'package:bank_sha/services/waste_schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:flutter/material.dart';

class WeeklySchedulePage extends StatelessWidget {
  const WeeklySchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklySchedule = WasteScheduleService.getWeeklySchedule();
    final today = DateTime.now().weekday;

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Jadwal Mingguan',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Header with current day info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Pengambilan Sampah',
                  style: blackTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jadwal tetap setiap minggu untuk pengambilan sampah',
                  style: greyTextStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),

          // Schedule list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: weeklySchedule.length,
              itemBuilder: (context, index) {
                final schedule = weeklySchedule[index];
                final isToday = schedule['dayNumber'] == today;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isToday ? greenColor.withOpacity(0.1) : whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday ? greenColor : Colors.grey.shade200,
                      width: isToday ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Day indicator
                      SizedBox(
                        width: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule['day'],
                              style: (isToday ? greenTextStyle : blackTextStyle)
                                  .copyWith(fontWeight: bold, fontSize: 16),
                            ),
                            if (isToday) ...[
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'HARI INI',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 10,
                                    fontWeight: bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color:
                              (isToday
                                      ? greenColor
                                      : _getColorForType(schedule['type']))
                                  .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForType(schedule['icon']),
                          color: isToday
                              ? greenColor
                              : _getColorForType(schedule['type']),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sampah ${schedule['type']}',
                              style: (isToday ? greenTextStyle : blackTextStyle)
                                  .copyWith(fontWeight: semiBold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              schedule['description'],
                              style: greyTextStyle.copyWith(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Time badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isToday ? greenColor : greyColor)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: isToday ? greenColor : greyColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    schedule['time'],
                                    style:
                                        (isToday
                                                ? greenTextStyle
                                                : greyTextStyle)
                                            .copyWith(
                                              fontWeight: medium,
                                              fontSize: 12,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'recycling':
        return Icons.recycling;
      case 'warning':
        return Icons.warning;
      case 'delete':
        return Icons.delete_outline;
      default:
        return Icons.delete_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'organik':
        return Colors.green;
      case 'anorganik':
        return Colors.blue;
      case 'b3':
        return Colors.red;
      case 'campuran':
      default:
        return greyColor;
    }
  }
}
