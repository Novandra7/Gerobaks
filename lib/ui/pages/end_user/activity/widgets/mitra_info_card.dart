import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

/// Widget untuk menampilkan informasi mitra
/// Menampilkan: Nama, Foto, Tombol Call
class MitraInfoCard extends StatelessWidget {
  final String mitraName;
  final String? mitraPhone;
  final String? mitraPhoto;
  final VoidCallback onCallPressed;

  const MitraInfoCard({
    super.key,
    required this.mitraName,
    this.mitraPhone,
    this.mitraPhoto,
    required this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Mitra Photo or Initial
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: mitraPhoto != null && mitraPhoto!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      mitraPhoto!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialAvatar();
                      },
                    ),
                  )
                : _buildInitialAvatar(),
          ),
          const SizedBox(width: 12),

          // Mitra Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mitraName,
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: semiBold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mitra Pengambil',
                  style: greyTextStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          // Call Button
          IconButton(
            onPressed: onCallPressed,
            icon: Icon(Icons.phone, color: greenColor),
            style: IconButton.styleFrom(
              backgroundColor: greenColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar() {
    final initial = mitraName.isNotEmpty ? mitraName[0].toUpperCase() : 'M';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: greenColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
