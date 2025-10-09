import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final Function(ScheduleStatus)? onStatusChange;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStatusText(),
                    style: whiteTextStyle.copyWith(fontWeight: semiBold),
                  ),
                  Text(
                    '${schedule.scheduledDate.day}/${schedule.scheduledDate.month}/${schedule.scheduledDate.year} · ${schedule.timeSlot.format(context)}',
                    style: whiteTextStyle,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.address,
                          style: blackTextStyle.copyWith(fontWeight: medium),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Waste type & weight
                  if (schedule.wasteType != null ||
                      schedule.estimatedWeight != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          schedule.wasteType != null
                              ? '${schedule.wasteType} · '
                              : '',
                          style: greyTextStyle,
                        ),
                        if (schedule.estimatedWeight != null)
                          Text(
                            '${schedule.estimatedWeight} kg',
                            style: greyTextStyle,
                          ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Notes
                  if (schedule.notes != null && schedule.notes!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.note_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(schedule.notes!, style: greyTextStyle),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Action buttons
                  if (onStatusChange != null)
                    Row(
                      children: [
                        if (schedule.status == ScheduleStatus.pending)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  onStatusChange!(ScheduleStatus.inProgress),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Mulai'),
                            ),
                          ),
                        if (schedule.status == ScheduleStatus.inProgress) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  onStatusChange!(ScheduleStatus.completed),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Selesai'),
                            ),
                          ),
                        ],
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

  Color _getStatusColor() {
    switch (schedule.status) {
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

  String _getStatusText() {
    switch (schedule.status) {
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
