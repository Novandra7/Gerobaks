import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppNotif(
        title: 'Privacy Policy',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi Gerobaku',
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
              '1. Informasi yang Kami Kumpulkan',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami mengumpulkan informasi seperti nama, nomor telepon, alamat penjemputan, serta lokasi perangkat Anda untuk mempermudah layanan pengambilan sampah.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '2. Penggunaan Informasi',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Informasi digunakan untuk menyediakan layanan pengangkutan dan pemilahan sampah, serta meningkatkan kualitas layanan Gerobaku.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '3. Perlindungan Data',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami melindungi data Anda dengan standar keamanan dan enkripsi yang memadai.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '4. Berbagi Informasi',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami tidak membagikan informasi Anda kepada pihak ketiga tanpa izin, kecuali diperlukan secara hukum atau untuk keperluan operasional layanan.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '5. Hak Anda',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda dapat meminta akses, perubahan, atau penghapusan data pribadi Anda kapan saja.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              '6. Perubahan Kebijakan',
              style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
            ),
            const SizedBox(height: 8),
            Text(
              'Kebijakan ini dapat berubah sewaktu-waktu dan akan diinformasikan melalui aplikasi Gerobaku.',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 32),
            Text(
              'Jika Anda memiliki pertanyaan terkait kebijakan privasi ini, silakan hubungi kami di: support@gerobaku.app',
              style: blackTextStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
