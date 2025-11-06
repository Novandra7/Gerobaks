# Fitur Taksi & Balance untuk Gerobaks

## Ikhtisar

Fitur Taksi & Balance adalah penambahan baru untuk aplikasi Gerobaks yang menyediakan dua kemampuan penting:

1. **Tampilan dan Manajemen Saldo Pengguna** - Memungkinkan pengguna melihat saldo mereka yang diambil dari API
2. **Kemampuan Panggilan Taksi** - Memudahkan pengguna memanggil taksi untuk mengangkut barang besar atau tambahan

## Cara Mengakses Demo

Fitur ini telah diintegrasikan ke aplikasi Gerobaks dan dapat diakses melalui:

1. Menu **"Demo Taksi & Saldo"** di halaman utama bagian "Pilihan"
2. Atau dengan menggunakan navigasi: `Navigator.pushNamed(context, '/schedule-taxi-demo');`

## Komponen Utama

### 1. BalanceService

Layanan untuk mengambil dan mengelola informasi saldo pengguna.

**Fitur:**
- Pemanggilan API untuk mendapatkan saldo (`https://example.com/saldo/user/123`)
- Caching data untuk mengurangi pemanggilan API berulang
- Pemformatan saldo ke format mata uang Rupiah
- Widget BalanceCard untuk menampilkan saldo dengan UI yang menarik

### 2. TaxiCallButton

Komponen UI untuk memanggil layanan taksi.

**Fitur:**
- Tersedia dalam dua varian: tombol reguler dan Floating Action Button (FAB)
- Efek animasi ketika ditekan untuk umpan balik visual
- Menggunakan URL launcher untuk memanggil nomor telepon taksi
- Desain adaptif yang bekerja di berbagai ukuran layar

### 3. ScheduleWithTaxiAndBalance

Implementasi lengkap yang menggabungkan semua fitur dalam satu halaman.

**Fitur:**
- Tampilan daftar jadwal pengambilan sampah
- Kartu saldo dengan kemampuan refresh
- Tombol panggilan taksi
- Tampilan status jadwal (Dijadwalkan, Selesai, Dibatalkan)

## Integrasi ke Aplikasi Utama

Jika ingin mengintegrasikan fitur ini ke halaman lain:

### Untuk Fitur Saldo

```dart
import 'package:bank_sha/services/balance_service.dart';

// Di dalam State
bool _isLoadingBalance = true;
int _userBalance = 0;

Future<void> _fetchBalance() async {
  setState(() {
    _isLoadingBalance = true;
  });
  
  try {
    final balance = await BalanceService.fetchUserBalance();
    setState(() {
      _userBalance = balance;
      _isLoadingBalance = false;
    });
  } catch (e) {
    setState(() {
      _isLoadingBalance = false;
    });
  }
}

// Di dalam build method
BalanceCard(
  isLoading: _isLoadingBalance,
  balance: _userBalance,
  onRefresh: _fetchBalance,
)
```

### Untuk Fitur Taksi

```dart
import 'package:bank_sha/ui/widgets/taxi_call_button.dart';

// Sebagai tombol biasa
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

### URL API Saldo

Ubah URL API di `balance_service.dart`:

```dart
static const String _apiUrl = 'https://your-api-endpoint.com/balance/user/123';
```

### Nomor Taksi

Ubah nomor telepon taksi saat menambahkan TaxiCallButton:

```dart
TaxiCallButton(
  phoneNumber: '021-1234567',
  isElevated: true,
)
```

## Dependensi

Fitur ini menggunakan paket berikut:
- `http` - Untuk panggilan API
- `intl` - Untuk pemformatan mata uang
- `url_launcher` - Untuk panggilan telepon

## Panduan Pengembangan Lanjutan

Untuk pengembangan lebih lanjut:

1. Implementasikan otentikasi untuk API saldo
2. Tambahkan kemampuan top-up dan withdraw saldo
3. Integrasi dengan penyedia layanan taksi yang sebenarnya
4. Tambahkan riwayat transaksi saldo
5. Implementasikan fitur estimasi harga taksi

## Kontributor

Fitur ini dibuat oleh tim pengembangan Gerobaks sebagai bagian dari peningkatan pengalaman pengguna aplikasi.
