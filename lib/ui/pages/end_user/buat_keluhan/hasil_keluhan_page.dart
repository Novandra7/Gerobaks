import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class HasilKeluhanPage extends StatelessWidget {
  final Map<String, dynamic> keluhanData;

  const HasilKeluhanPage({super.key, required this.keluhanData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(
        title: 'Hasil Keluhan Anda',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Success dengan animasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [greenColor, greenColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: greenColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: whiteColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: whiteColor,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '🎉 Keluhan Berhasil Dikirim!',
                    style: whiteTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: whiteColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ID: ${keluhanData['id']}',
                      style: whiteTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: semiBold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tim kami akan segera menindaklanjuti keluhan Anda.\nTerima kasih atas kepercayaan Anda! 🙏',
                    style: whiteTextStyle.copyWith(fontSize: 13, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Informasi Pelapor dengan desain lebih menarik
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: greenColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '👤 Informasi Pelapor',
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildOutputField('📝 Nama Lengkap', keluhanData['nama']),
                  _buildOutputField('📞 Nomor Telepon', keluhanData['phone']),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detail Keluhan dengan tampilan menarik
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.report_problem_rounded,
                          color: Colors.orange.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '📋 Detail Keluhan',
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildOutputField('🏷️ Kategori', keluhanData['kategori']),
                  _buildOutputField(
                    '⚡ Tingkat Prioritas',
                    keluhanData['prioritas'],
                    isPrioritas: true,
                  ),
                  _buildOutputField('📌 Judul Keluhan', keluhanData['judul']),
                  _buildOutputField(
                    '📍 Lokasi Kejadian',
                    keluhanData['lokasi'],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.description_rounded,
                        color: greyColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '📝 Deskripsi Keluhan:',
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade50, Colors.grey.shade100],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      keluhanData['deskripsi'],
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status & Informasi Pengiriman
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          color: Colors.blue.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '⏰ Informasi Pengiriman',
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildOutputField(
                    '📅 Tanggal Dibuat',
                    keluhanData['tanggal'],
                  ),
                  _buildOutputField('🕐 Waktu Dibuat', keluhanData['waktu']),
                  _buildOutputField(
                    '🔄 Status Saat Ini',
                    keluhanData['status'],
                    isStatus: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Timeline Tracking dengan desain yang lebih menarik
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.timeline_rounded,
                          color: Colors.purple.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '📈 Timeline Keluhan',
                        style: blackTextStyle.copyWith(
                          fontWeight: bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTimelineItem(
                    '✅ Keluhan Diterima',
                    '${keluhanData['tanggal']} ${keluhanData['waktu']}',
                    true,
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                  _buildTimelineItem(
                    '⏳ Sedang Diproses',
                    'Menunggu penanganan...',
                    false,
                    Icons.hourglass_empty_rounded,
                    Colors.orange,
                  ),
                  _buildTimelineItem(
                    '🎯 Selesai Ditangani',
                    'Belum selesai...',
                    false,
                    Icons.task_alt_rounded,
                    Colors.blue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons dengan desain menarik
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: greenColor, width: 1.5),
                      ),
                      child: CustomTextButton(
                        title: '📝 Buat Keluhan Lagi',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [greenColor, greenColor.withOpacity(0.8)],
                        ),
                      ),
                      child: CustomFilledButton(
                        title: '🏠 Kembali ke Beranda',
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputField(
    String label,
    String value, {
    bool isStatus = false,
    bool isPrioritas = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: greyTextStyle.copyWith(fontSize: 13, fontWeight: medium),
            ),
          ),
          Expanded(
            child: isStatus
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '🔄 $value',
                      style: whiteTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : isPrioritas
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getPrioritasColor(value),
                          _getPrioritasColor(value).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: _getPrioritasColor(value).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '⚡ $value',
                      style: whiteTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Text(
                    value,
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                      color: Colors.grey.shade700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    bool isCompleted,
    IconData icon,
    Color timelineColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [timelineColor, timelineColor.withOpacity(0.8)],
                    )
                  : LinearGradient(
                      colors: [
                        greyColor.withOpacity(0.3),
                        greyColor.withOpacity(0.2),
                      ],
                    ),
              shape: BoxShape.circle,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: timelineColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isCompleted ? whiteColor : greyColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? timelineColor.withOpacity(0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? timelineColor.withOpacity(0.2)
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: blackTextStyle.copyWith(
                      fontWeight: bold,
                      fontSize: 14,
                      color: isCompleted ? timelineColor : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPrioritasColor(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'rendah':
        return Colors.green.shade600;
      case 'normal':
        return Colors.blue.shade600;
      case 'tinggi':
        return Colors.orange.shade600;
      case 'urgent':
        return Colors.red.shade600;
      default:
        return greyColor;
    }
  }
}
