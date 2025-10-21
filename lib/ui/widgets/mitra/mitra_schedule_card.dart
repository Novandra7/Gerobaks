import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/models/waste_item.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mitra Schedule Card - Display schedule with multiple waste items
/// Shows: date, time, user, address, waste items list, total weight, status, actions
class MitraScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const MitraScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.onAccept,
    this.onStart,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date & Time
              _buildDateTimeRow(),
              const SizedBox(height: 12),

              // User Info
              _buildUserInfo(),
              const SizedBox(height: 12),

              // Waste Items Section
              _buildWasteItemsSection(),
              const SizedBox(height: 12),

              // Total Weight
              _buildTotalWeight(),
              const SizedBox(height: 12),

              // Status Badge
              _buildStatusBadge(),
              const SizedBox(height: 12),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    final dateFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: greyColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${dateFormat.format(schedule.scheduledDate)} • ${timeFormat.format(
              DateTime(
                schedule.scheduledDate.year,
                schedule.scheduledDate.month,
                schedule.scheduledDate.day,
                schedule.timeSlot.hour,
                schedule.timeSlot.minute,
              ),
            )} WIB',
            style: blackTextStyle.copyWith(
              fontSize: 12,
              fontWeight: medium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 16, color: greyColor),
            const SizedBox(width: 8),
            Text(
              schedule.userId ?? 'Pengguna',
              style: blackTextStyle.copyWith(
                fontSize: 14,
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: greyColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schedule.address,
                style: greyTextStyle.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWasteItemsSection() {
    // Parse waste items from dynamic list
    final wasteItems = _parseWasteItems();

    if (wasteItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lightBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: greyColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 16, color: greyColor),
            const SizedBox(width: 8),
            Text(
              'Tidak ada info sampah',
              style: greyTextStyle.copyWith(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: greyColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recycling, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Sampah yang dijemput:',
                style: blackTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...wasteItems.map((item) => _buildWasteItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildWasteItemRow(WasteItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            item.getEmoji(),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.getDisplayName(),
              style: blackTextStyle.copyWith(fontSize: 12),
            ),
          ),
          Text(
            '${item.estimatedWeight.toStringAsFixed(1)} ${item.unit}',
            style: blackTextStyle.copyWith(
              fontSize: 12,
              fontWeight: semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalWeight() {
    final wasteItems = _parseWasteItems();
    final totalWeight = _calculateTotalWeight(wasteItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Estimasi:',
            style: blackTextStyle.copyWith(
              fontSize: 12,
              fontWeight: medium,
            ),
          ),
          Text(
            '${totalWeight.toStringAsFixed(1)} kg',
            style: blackTextStyle.copyWith(
              fontSize: 14,
              fontWeight: bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = schedule.status;
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (status) {
      case ScheduleStatus.pending:
        badgeColor = Colors.orange;
        badgeText = 'Menunggu';
        badgeIcon = Icons.schedule;
        break;
      case ScheduleStatus.accepted:
        badgeColor = Colors.blue;
        badgeText = 'Diterima';
        badgeIcon = Icons.check_circle_outline;
        break;
      case ScheduleStatus.inProgress:
        badgeColor = primaryColor;
        badgeText = 'Sedang Diproses';
        badgeIcon = Icons.local_shipping;
        break;
      case ScheduleStatus.completed:
        badgeColor = Colors.green;
        badgeText = 'Selesai';
        badgeIcon = Icons.check_circle;
        break;
      case ScheduleStatus.cancelled:
        badgeColor = Colors.red;
        badgeText = 'Dibatalkan';
        badgeIcon = Icons.cancel;
        break;
      default:
        badgeColor = greyColor;
        badgeText = 'Unknown';
        badgeIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: semiBold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = schedule.status;

    // Show different buttons based on status
    if (status == ScheduleStatus.pending && onAccept != null) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Terima Jadwal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Detail'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (status == ScheduleStatus.accepted && onStart != null) {
      return ElevatedButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text('Mulai Pengambilan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          minimumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    if (status == ScheduleStatus.inProgress && onComplete != null) {
      return ElevatedButton.icon(
        onPressed: onComplete,
        icon: const Icon(Icons.check_circle, size: 18),
        label: const Text('Selesaikan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: whiteColor,
          minimumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    // Default: just show detail button
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.info_outline, size: 16),
      label: const Text('Lihat Detail'),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Helper: Parse waste items from schedule
  List<WasteItem> _parseWasteItems() {
    if (schedule.wasteItems.isEmpty) return [];

    try {
      return schedule.wasteItems
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

  // Helper: Calculate total weight
  double _calculateTotalWeight(List<WasteItem> items) {
    return items.fold(0.0, (sum, item) {
      // Convert to kg if unit is gram
      if (item.unit.toLowerCase() == 'gram' || item.unit.toLowerCase() == 'g') {
        return sum + (item.estimatedWeight / 1000);
      }
      return sum + item.estimatedWeight;
    });
  }
}
