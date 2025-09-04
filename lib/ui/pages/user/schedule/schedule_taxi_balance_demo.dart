import 'package:flutter/material.dart';
import 'package:bank_sha/ui/pages/user/schedule/schedule_with_taxi_and_balance.dart';

class ScheduleTaxiBalanceDemo extends StatelessWidget {
  const ScheduleTaxiBalanceDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScheduleWithTaxiAndBalance();
  }
}

// Petunjuk Penggunaan:
//
// 1. Tambahkan rute ke file route.dart Anda:
//    '/schedule-taxi-demo': (context) => const ScheduleTaxiBalanceDemo(),
//
// 2. Navigasi ke halaman ini dari halaman mana pun dengan:
//    Navigator.pushNamed(context, '/schedule-taxi-demo');
//
// 3. Fitur yang Ditampilkan:
//    - Tampilan saldo yang mengambil data dari API
//    - Tombol panggilan taksi yang responsif
//    - Daftar jadwal pengambilan sampah dengan status
//    - UI yang responsif dan user-friendly
//
// 4. Integrasi:
//    - Anda dapat menggabungkan kode dari ScheduleWithTaxiAndBalance ke halaman yang ada
//    - Semua komponen UI dapat digunakan terpisah (BalanceCard, TaxiCallButton, dll.)
//    - Untuk pengembangan lebih lanjut, sesuaikan URL API saldo dan nomor telepon taksi
