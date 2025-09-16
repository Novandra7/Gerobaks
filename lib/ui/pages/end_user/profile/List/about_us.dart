import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(title: 'About Us', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Image
            Center(
              child: Column(
                children: [
                  Image.asset('assets/img_logo.png', width: 100, height: 100),
                  const SizedBox(height: 16),
                  Text(
                    'Selamat Datang di Gerobaku!',
                    style: blackTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: semiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Solusi cerdas untuk pengelolaan sampah berkelanjutan',
                    style: greyTextStyle.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Card Deskripsi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Gerobaku adalah aplikasi pengambilan dan pemilahan sampah yang bertujuan menciptakan lingkungan yang bersih dan berkelanjutan. '
                'Setiap hari, tim kami akan menjemput dan memilah sampah Anda secara langsung untuk mendukung proses daur ulang yang lebih efisien.\n\n'
                'Dengan Gerobaku, kami ingin membangun budaya peduli sampah sejak dari rumah. Bersama, kita bisa menciptakan masa depan yang lebih hijau dan sehat.',
                style: greyTextStyle.copyWith(fontSize: 14, height: 1.6),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 24),

            // Misi Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Misi Kami',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Mengurangi beban tempat pembuangan akhir (TPA).\n'
                    '• Meningkatkan kesadaran masyarakat dalam memilah sampah.\n'
                    '• Mendukung gerakan daur ulang dan pengelolaan sampah berkelanjutan.',
                    style: greyTextStyle.copyWith(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Call to action
            Text(
              'Mari ubah sampah menjadi berkah.\nBersama Gerobaku, wujudkan lingkungan yang lestari!',
              style: greenTextStyle.copyWith(fontSize: 14, fontWeight: medium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
