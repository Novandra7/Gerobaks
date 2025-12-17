import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/utils/toast_helper.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:bank_sha/ui/widgets/shared/reschedule_dialog.dart';

class ActivityDetailModal extends StatelessWidget {
  final ActivityModel activity;

  const ActivityDetailModal({super.key, required this.activity});

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

  // Format methods moved to RescheduleDialog class

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG LOGGING - Cek kenapa tombol tracking tidak muncul
    print('🔍 ===== ACTIVITY DETAIL DEBUG =====');
    print('🔍 ID: ${activity.id}');
    print('🔍 Status (original): "${activity.status}"');
    print('🔍 Status (lowercase): "${activity.status.toLowerCase()}"');
    print('🔍 Status (trimmed): "${activity.status.toLowerCase().trim()}"');
    print('🔍 Is Active: ${activity.isActive}');

    // Check tracking button condition
    final isMenujuLokasi =
        activity.status.toLowerCase().trim() == 'menuju lokasi';
    final isSedangDiproses =
        activity.status.toLowerCase().trim() == 'sedang diproses';
    final isOnTheWay = activity.status.toLowerCase().trim() == 'on_the_way';
    final isArrived = activity.status.toLowerCase().trim() == 'arrived';

    print('🔍 Check conditions:');
    print('   - Is "menuju lokasi": $isMenujuLokasi');
    print('   - Is "sedang diproses": $isSedangDiproses');
    print('   - Is "on_the_way": $isOnTheWay');
    print('   - Is "arrived": $isArrived');
    print(
      '🔍 Should show tracking button: ${activity.isActive && (isMenujuLokasi || isSedangDiproses || isOnTheWay || isArrived)}',
    );
    print('🔍 ===================================');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Text(
                'Detail Aktivitas',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: blackColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(height: 24),

          // Status Badge
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(activity.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(activity.getIcon(), width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text(
                    activity.status,
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                      color: _getStatusColor(activity.status),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Section
          _buildInfoItem('Judul', activity.title),
          _buildInfoItem('Alamat', activity.address),
          _buildInfoItem('Waktu', _formatDateTime(activity.dateTime)),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // ✅ NEW: Button tracking untuk status trackable (support backend status)
              if (activity.isActive && _isTrackableStatus(activity.status))
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate langsung ke halaman tracking dengan scheduleId
                      final scheduleId = int.tryParse(activity.id);
                      if (scheduleId != null) {
                        Navigator.pushNamed(
                          context,
                          '/user-tracking-by-id',
                          arguments: scheduleId,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID jadwal tidak valid'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.gps_fixed, size: 20),
                    label: Text('Lacak Mitra'),
                  ),
                ),

              if (activity.isActive &&
                  activity.status.toLowerCase() == 'dijadwalkan')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRescheduleDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Atur Ulang Jadwal'),
                  ),
                ),

              if (activity.isActive) const SizedBox(width: 12),

              if (activity.isActive)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCancelConfirmationDialog(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Batalkan',
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: semiBold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

              if (!activity.isActive &&
                  activity.status.toLowerCase() == 'selesai')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCompletedDetails(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Lihat Detail Lengkap'),
                  ),
                ),

              if (!activity.isActive &&
                  activity.status.toLowerCase() != 'selesai')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Tutup'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: greyTextStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: medium),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  // ✅ Helper method untuk cek apakah status trackable
  bool _isTrackableStatus(String status) {
    final trackableStatuses = [
      'menuju lokasi', // Frontend status
      'sedang diproses', // Frontend status
      'on_the_way', // Backend status
      'arrived', // Backend status
    ];
    return trackableStatuses.contains(status.toLowerCase().trim());
  }

  void _showRescheduleDialog(BuildContext context) {
    RescheduleDialog.show(
      context: context,
      initialDate: activity.date,
      onReschedule: (newDate, newTime) {
        // Combine date and time into a single DateTime
        DateTime rescheduledDateTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );

        // Show success message
        ToastHelper.showToast(
          context: context,
          message:
              'Jadwal berhasil diperbarui ke ${rescheduledDateTime.toString()}',
          isSuccess: true,
        );

        // In a real app, you would update the activity in your backend
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    DialogHelper.showConfirmDialog(
      context: context,
      title: 'Konfirmasi Pembatalan',
      message: 'Apakah Anda yakin ingin membatalkan aktivitas ini?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
      icon: Icons.cancel_outlined,
      isDestructiveAction: true,
    ).then((confirmed) {
      if (confirmed) {
        // Simulasi pembatalan
        ToastHelper.showToast(
          context: context,
          message: 'Aktivitas berhasil dibatalkan',
          isSuccess: true,
        );
      }
    });
  }

  void _showCompletedDetails(BuildContext context) {
    if (activity.trashDetails == null || activity.totalPoints == null) {
      ToastHelper.showToast(
        context: context,
        message: 'Data detail tidak tersedia',
        isSuccess: false,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header dengan handle dan judul
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Handle Bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Title
                        Row(
                          children: [
                            Text(
                              'Detail Pengambilan Sampah',
                              style: blackTextStyle.copyWith(
                                fontSize: 18,
                                fontWeight: semiBold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: blackColor),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content area
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Summary info
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildSummaryRow(
                                  'Total Berat',
                                  '${activity.totalWeight} kg',
                                ),
                                _buildSummaryRow(
                                  'Total Jenis',
                                  '${activity.trashDetails!.length} jenis',
                                ),
                                _buildSummaryRow(
                                  'Total Poin',
                                  '${activity.totalPoints} poin',
                                  isHighlighted: true,
                                ),
                                if (activity.completedBy != null)
                                  _buildSummaryRow(
                                    'Petugas',
                                    activity.completedBy!,
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Trash details
                        Text(
                          'Detail Sampah',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // List trash details
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activity.trashDetails!.length,
                          itemBuilder: (context, index) {
                            final trashDetail = activity.trashDetails![index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: greenColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    trashDetail.icon ?? 'assets/ic_trash.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                title: Text(
                                  trashDetail.type,
                                  style: blackTextStyle.copyWith(
                                    fontWeight: medium,
                                  ),
                                ),
                                subtitle: Text(
                                  '${trashDetail.weight} kg',
                                  style: greyTextStyle,
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: greenColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '+${trashDetail.points} poin',
                                    style: greentextstyle2.copyWith(
                                      fontWeight: medium,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Photo proofs
                        if (activity.photoProofs != null &&
                            activity.photoProofs!.isNotEmpty) ...[
                          Text(
                            'Bukti Foto',
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Grid of photos
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: activity.photoProofs!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _showFullScreenImage(
                                  context,
                                  activity.photoProofs![index],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        activity.photoProofs![index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

                        if (activity.notes != null &&
                            activity.notes!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Catatan',
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              activity.notes!,
                              style: greyTextStyle.copyWith(height: 1.5),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: greyTextStyle),
          Text(
            value,
            style: isHighlighted
                ? greentextstyle2.copyWith(fontWeight: semiBold, fontSize: 16)
                : blackTextStyle.copyWith(fontWeight: medium),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with pinch to zoom
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),

              // Close button
              Positioned(
                right: 16,
                top: 40,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
