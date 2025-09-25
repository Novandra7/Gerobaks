# Dokumentasi Komponen Reusable Jadwal Mitra

## Pengenalan

Dokumen ini berisi informasi tentang komponen-komponen reusable yang telah dibuat untuk digunakan dalam aplikasi Gerobaks, khususnya untuk halaman Jadwal Mitra. Komponen-komponen ini dirancang untuk:

1. Meningkatkan konsistensi UI
2. Mengurangi duplikasi kode
3. Mempermudah pengembangan lebih lanjut
4. Mendukung responsivitas pada berbagai ukuran layar

## Komponen Reusable

### 1. JadwalMitraHeader

**File**: `lib/ui/widgets/mitra/jadwal_mitra_header.dart`

**Deskripsi**: Komponen header untuk halaman jadwal mitra yang menampilkan logo, ikon notifikasi, judul halaman, dan statistik pengambilan sampah.

**Properti**:

- `locationCount`: Jumlah lokasi pengambilan
- `pendingCount`: Jumlah pengambilan yang menunggu
- `completedCount`: Jumlah pengambilan yang selesai
- `onChatPressed`: Callback saat ikon chat ditekan
- `onNotificationPressed`: Callback saat ikon notifikasi ditekan

**Contoh Penggunaan**:

```dart
JadwalMitraHeader(
  locationCount: 7,
  pendingCount: 5,
  completedCount: 2,
  onChatPressed: () {
    // Navigasi ke halaman chat
  },
  onNotificationPressed: () {
    // Navigasi ke halaman notifikasi
  },
)
```

### 2. StatCard

**File**: `lib/ui/widgets/shared/stat_card.dart`

**Deskripsi**: Card untuk menampilkan statistik atau angka dengan ikon.

**Properti**:

- `icon`: Ikon yang ditampilkan
- `label`: Label untuk statistik
- `count`: Nilai statistik
- `backgroundColor`: Warna latar belakang card (default: putih)
- `textColor`: Warna teks (default: hitam)
- `iconColor`: Warna ikon (default: hijau)

**Contoh Penggunaan**:

```dart
StatCard(
  icon: Icons.location_on_outlined,
  label: 'Lokasi',
  count: 7,
  backgroundColor: Colors.white.withOpacity(0.2),
  textColor: Colors.white,
  iconColor: Colors.white,
)
```

### 3. FilterTab

**File**: `lib/ui/widgets/shared/filter_tab.dart`

**Deskripsi**: Tab untuk memfilter konten atau mengubah tampilan.

**Properti**:

- `label`: Teks pada tab
- `isSelected`: Status tab (terpilih atau tidak)
- `onTap`: Callback saat tab ditekan
- `selectedColor`: Warna latar belakang saat terpilih
- `unselectedColor`: Warna latar belakang saat tidak terpilih
- `selectedTextColor`: Warna teks saat terpilih
- `unselectedTextColor`: Warna teks saat tidak terpilih

**Contoh Penggunaan**:

```dart
FilterTab(
  label: 'Semua',
  isSelected: selectedFilter == 'semua',
  onTap: () {
    setState(() {
      selectedFilter = 'semua';
    });
  },
  selectedColor: greenColor,
  unselectedColor: Colors.white,
  selectedTextColor: Colors.white,
  unselectedTextColor: greenColor,
)
```

## Fitur Responsivitas

Semua komponen di atas menggunakan `ResponsiveHelper` untuk memastikan tampilan yang konsisten pada berbagai ukuran layar. Implementasi responsif meliputi:

1. Penyesuaian ukuran font
2. Penyesuaian padding dan margin
3. Penyesuaian ukuran ikon
4. Penyesuaian border radius

## Menggunakan Komponen dalam Halaman Baru

Untuk menggunakan komponen-komponen ini dalam halaman baru, ikuti langkah-langkah berikut:

1. Import komponen yang diperlukan:

```dart
import 'package:bank_sha/ui/widgets/mitra/jadwal_mitra_header.dart';
import 'package:bank_sha/ui/widgets/shared/filter_tab.dart';
import 'package:bank_sha/ui/widgets/shared/stat_card.dart';
```

2. Gunakan komponen dalam build method:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        JadwalMitraHeader(
          locationCount: _locationCount,
          pendingCount: _pendingCount,
          completedCount: _completedCount,
          onChatPressed: _handleChatPressed,
          onNotificationPressed: _handleNotificationPressed,
        ),
        Row(
          children: [
            Expanded(
              child: FilterTab(
                label: 'Semua',
                isSelected: _selectedFilter == 'semua',
                onTap: () => _setFilter('semua'),
              ),
            ),
            // Tambahkan filter tab lainnya...
          ],
        ),
        // Konten lainnya...
      ],
    ),
  );
}
```

## Kesimpulan

Dengan menggunakan komponen-komponen reusable ini, pengembangan UI menjadi lebih efisien dan konsisten. Pastikan untuk menambahkan komponen baru ke dalam dokumentasi ini saat Anda mengembangkan lebih banyak komponen reusable.
