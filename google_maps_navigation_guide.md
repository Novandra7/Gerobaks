# Panduan Fitur Navigasi Google Maps - Detail Pickup

## Deskripsi Fitur

Fitur ini memungkinkan mitra untuk membuka Google Maps secara otomatis dengan navigasi langsung ke lokasi pengambilan sampah ketika menekan tombol "Mulai Pengambilan" di halaman detail pickup.

## Cara Kerja

### 1. Tombol Mulai Pengambilan

- Lokasi: Halaman `DetailPickupPage` (`lib/ui/pages/mitra/pengambilan/detail_pickup.dart`)
- Ikon: `Icons.navigation` (ikon navigasi)
- Warna: Hijau (`greenColor`)

### 2. Dialog Konfirmasi

Ketika tombol ditekan, akan muncul dialog konfirmasi yang berisi:

- **Judul**: "Mulai Pengambilan"
- **Pesan**: "Anda akan diarahkan ke Google Maps untuk navigasi ke lokasi pengambilan sampah. Lanjutkan?"
- **Tombol Batal**: Menutup dialog tanpa melakukan aksi
- **Tombol Lanjutkan**: Membuka Google Maps

### 3. Pembukaan Google Maps

Sistem akan mencoba membuka Google Maps dengan urutan prioritas:

1. **Koordinat GPS** (prioritas utama):

   ```
   https://www.google.com/maps/dir/?api=1&destination=LATITUDE,LONGITUDE&travelmode=driving
   ```

2. **Alamat Teks** (fallback):
   ```
   https://www.google.com/maps/dir/?api=1&destination=ALAMAT_ENCODED&travelmode=driving
   ```

### 4. Error Handling

Sistem memiliki error handling yang komprehensif:

- Jika Google Maps tidak bisa dibuka dengan koordinat, akan fallback ke alamat
- Jika sama sekali tidak bisa membuka Maps, akan menampilkan SnackBar error
- Semua error handling mempertimbangkan state widget (`mounted`)

## Struktur Data

### Data Jadwal (Mock Data)

```dart
scheduleData = {
  "id": widget.scheduleId,
  "customer_name": "Wahyu Indra",
  "address": "Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur",
  "latitude": -0.5017, // Koordinat Samarinda
  "longitude": 117.1536,
  "time": "08:00 - 09:00",
  "waste_type": "Organik",
  "waste_weight": "3 kg",
  "status": "pending",
  "phone": "+62812345678",
  "notes": "Sampah diletakkan di depan pagar rumah",
};
```

## Dependencies

- **url_launcher**: ^6.3.2 (sudah ada di pubspec.yaml)

## Implementasi Teknis

### Fungsi Utama

```dart
Future<void> _openGoogleMaps() async {
  if (!mounted) return; // Check widget state

  try {
    final address = scheduleData!['address'];
    final latitude = scheduleData!['latitude'];
    final longitude = scheduleData!['longitude'];

    // URL dengan koordinat
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    // URL dengan alamat (fallback)
    final googleMapsUrlWithAddress = 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}&travelmode=driving';

    final uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback logic...
    }
  } catch (e) {
    // Error handling...
  }
}
```

## Fitur yang Dikembangkan

1. ✅ Dialog konfirmasi sebelum membuka Maps
2. ✅ Navigasi dengan koordinat GPS (lebih akurat)
3. ✅ Fallback ke alamat teks jika koordinat gagal
4. ✅ Error handling yang komprehensif
5. ✅ Mode navigasi mobil (driving) sebagai default
6. ✅ Ikon navigasi yang sesuai
7. ✅ UI yang konsisten dengan tema aplikasi

## Testing

- Aplikasi berhasil dikompilasi tanpa error
- Fitur hot reload berfungsi dengan baik
- Dialog konfirmasi muncul dengan benar
- Google Maps terbuka dengan navigasi langsung ke tujuan

## Kegunaan untuk Mitra

1. **Kemudahan Navigasi**: Mitra tidak perlu manual copy-paste alamat ke Maps
2. **Akurasi**: Menggunakan koordinat GPS untuk navigasi yang lebih presisi
3. **Efisiensi**: Satu klik langsung membuka navigasi
4. **User Experience**: Dialog konfirmasi mencegah pembukaan Maps yang tidak disengaja
5. **Integrasi Seamless**: Tidak perlu keluar dari aplikasi untuk mendapatkan alamat

## Catatan

- Fitur ini menggunakan web URL Google Maps yang kompatibel dengan semua platform
- Mode navigasi diset ke "driving" untuk kendaraan mitra
- Koordinat saat ini menggunakan mock data Samarinda, akan disesuaikan dengan data real dari API
