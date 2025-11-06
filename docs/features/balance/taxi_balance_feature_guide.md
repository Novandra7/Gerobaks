# Panduan Fitur Demo Taksi & Balance

## Deskripsi Fitur

Fitur ini menambahkan dua kemampuan baru ke aplikasi Gerobaks:

1. **Tampilan Saldo Pengguna**
   - Mengambil data saldo dari API (https://example.com/saldo/user/123)
   - Menampilkan saldo dalam format mata uang Rupiah
   - Memiliki fitur refresh untuk memperbarui saldo
   - Tombol untuk Top Up dan Withdraw saldo

2. **Panggilan Taksi**
   - Tombol panggilan taksi dengan animasi tekan
   - Otomatis menghubungi nomor taksi yang telah ditentukan
   - Tersedia dalam dua varian: tombol besar dan Floating Action Button (FAB)
   - Desain responsif yang bekerja di berbagai ukuran layar

## Cara Mengakses Demo

1. Buka aplikasi Gerobaks
2. Navigasikan ke halaman demo dengan salah satu cara berikut:
   - Menggunakan Navigator: `Navigator.pushNamed(context, '/schedule-taxi-demo');`
   - Tambahkan tombol di halaman Home atau Menu dengan kode:
     ```dart
     ElevatedButton(
       onPressed: () => Navigator.pushNamed(context, '/schedule-taxi-demo'),
       child: Text('Fitur Taksi & Balance Demo'),
     )
     ```

## Integrasi ke Aplikasi Utama

Jika ingin mengintegrasikan fitur ini ke halaman yang sudah ada:

1. **Untuk fitur saldo:**
   - Import: `import 'package:bank_sha/services/balance_service.dart';`
   - Tambahkan widget BalanceCard di layout yang diinginkan
   - Contoh penggunaan:
     ```dart
     BalanceCard(
       isLoading: _isLoadingBalance,
       balance: _userBalance,
       onRefresh: _fetchBalance,
     )
     ```

2. **Untuk fitur panggilan taksi:**
   - Import: `import 'package:bank_sha/ui/widgets/taxi_call_button.dart';`
   - Tambahkan widget TaxiCallButton atau TaxiCallFAB di layout yang diinginkan
   - Contoh penggunaan:
     ```dart
     // Tombol biasa
     TaxiCallButton(
       phoneNumber: '0812-3456-7890',
       isElevated: true,
     )
     
     // Atau sebagai FAB
     floatingActionButton: TaxiCallFAB(
       phoneNumber: '0812-3456-7890',
     )
     ```

## Kustomisasi

Fitur ini dapat dikustomisasi dengan mudah:

1. **BalanceService:**
   - Ubah URL API di `_apiUrl` untuk menghubungkan ke endpoint saldo yang sebenarnya
   - Sesuaikan format mata uang di `formatCurrency()` jika diperlukan

2. **TaxiCallButton:**
   - Ubah nomor telepon di parameter `phoneNumber`
   - Sesuaikan warna dan gaya dengan mengubah nilai di konstruktor
   - Pilih antara versi elevated atau flat dengan parameter `isElevated`

## Penambahan ke Halaman yang Sudah Ada

Untuk menambahkan fitur ini ke halaman jadwal yang sudah ada, Anda dapat:

1. Salin komponen dari `schedule_with_taxi_and_balance.dart` ke halaman target
2. Sesuaikan state management dan lifecycle methods yang diperlukan
3. Integrasikan dengan data pengguna yang sesungguhnya
