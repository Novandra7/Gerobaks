import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class TermsAndCondtions extends StatelessWidget {
  const TermsAndCondtions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(
        title: 'Terms and Conditions',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syarat dan Ketentuan Penggunaan Gerobaku',
              style: blackTextStyle.copyWith(
                fontSize: 20,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tanggal Berlaku: 22 Juli 2025',
              style: greyTextStyle.copyWith(fontSize: 14, fontWeight: regular),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Penerimaan Syarat',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Dengan menggunakan aplikasi Gerobaku, Anda dianggap telah membaca, memahami, dan menyetujui seluruh Syarat dan Ketentuan ini.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '2. Layanan yang Disediakan',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerobaku menyediakan layanan penjadwalan, pelacakan, dan pengangkutan sampah dari lokasi pengguna ke tempat pengelolaan yang sesuai.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '3. Akun Pengguna',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Pengguna wajib memberikan informasi yang benar saat mendaftar. Anda bertanggung jawab penuh atas keamanan akun Anda.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '4. Penggunaan yang Diperbolehkan',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikasi hanya boleh digunakan untuk kebutuhan penjemputan sampah rumah tangga dan non-berbahaya. Penyalahgunaan aplikasi dapat menyebabkan penangguhan akun.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '5. Pembayaran dan Biaya',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Jika layanan dikenakan biaya, rincian akan ditampilkan sebelum Anda mengonfirmasi jadwal. Pembayaran dilakukan melalui metode yang tersedia di aplikasi.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '6. Pembatalan Layanan',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Pembatalan dapat dilakukan maksimal 2 jam sebelum waktu penjemputan. Pembatalan mendadak dapat dikenakan biaya.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '7. Batasan Tanggung Jawab',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami tidak bertanggung jawab atas kerugian langsung maupun tidak langsung yang timbul akibat penggunaan aplikasi secara tidak sah.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '8. Perubahan Ketentuan',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Syarat dan Ketentuan ini dapat diperbarui sewaktu-waktu dan akan diinformasikan melalui aplikasi.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 32),
            Text(
              'Untuk pertanyaan atau masukan, silakan hubungi kami di: support@gerobaku.app',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
