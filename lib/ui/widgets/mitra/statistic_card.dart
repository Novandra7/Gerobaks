import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Gradient background sesuai desain
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC1F2AD), // Warna paling atas (0%)
            const Color(0xFF5CC488), // Warna kedua (55%)
            const Color(0xFF55C080), // Warna ketiga (80%)
            const Color(0xFF46C375), // Warna paling bawah (100%)
          ],
          stops: const [0.0, 0.55, 0.8, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Mengurangi padding sedikit untuk memberi ruang konten
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribusi ruang yang lebih baik
        mainAxisSize: MainAxisSize.min, // Memastikan column hanya mengambil ruang yang diperlukan
        children: [
          // Title and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // Mengembalikan ukuran font judul yang lebih besar
                    fontWeight: medium,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8), // Memberikan jarak yang lebih antara teks dan ikon
              Icon(
                icon,
                color: Colors.white,
                size: 18, // Mengembalikan ukuran ikon yang lebih besar
              ),
            ],
          ),
          
          // Spacer
          const SizedBox(height: 8), // Mengurangi ruang vertikal antara judul dan nilai
          
          // Value display - handle special cases
          if (title == 'Rating') 
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 36, // Mengurangi ukuran font untuk menghindari overflow
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 0.9, // Tetap menggunakan height yang efisien
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/5',
                  style: TextStyle(
                    fontSize: 16, // Mengurangi ukuran font satuan
                    fontWeight: medium,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            )
          else if (title == 'Waktu Aktif')
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 36, // Mengurangi ukuran font untuk menghindari overflow
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 0.9, // Tetap menggunakan height yang efisien
                  ),
                ),
                Text(
                  'j',
                  style: TextStyle(
                    fontSize: 16, // Mengurangi ukuran font satuan
                    fontWeight: medium,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 36, // Mengurangi ukuran font untuk menghindari overflow
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 0.9, // Tetap menggunakan height yang efisien
              ),
            ),
        ],
      ),
    );
  }
}
