# Implementasi Notifikasi Suara di Aplikasi Gerobaks

## Pengenalan
Dokumen ini menjelaskan bagaimana suara notifikasi diimplementasikan di aplikasi Gerobaks.

## File Suara yang Digunakan

### Format File
Beberapa perangkat Android mungkin memiliki dukungan yang terbatas untuk file WAV. File MP3 biasanya merupakan pilihan yang lebih kompatibel.

Untuk memastikan notifikasi suara berfungsi, sebaiknya gunakan file dengan spesifikasi:
- Bitrate: 128kbps
- Sample rate: 44.1kHz
- Mono atau stereo
- Durasi pendek (1-3 detik)

### File Suara
- `nf_gerobaks.wav` - Suara notifikasi kustom untuk semua jenis notifikasi

### Lokasi File
- Android: `android/app/src/main/res/raw/notification_sound.wav`
- iOS: `ios/Runner/Resources/notification_sound.caf`

## Implementasi

### Konfigurasi Android
Semua channel notifikasi menggunakan suara notifikasi kustom:
- Notifikasi chat: `nf_gerobaks.wav`
- Notifikasi pengambilan sampah: `nf_gerobaks.wav`
- Pantun harian: `nf_gerobaks.wav`
- Pantun rutin: `nf_gerobaks.wav`
- Notifikasi langganan: `nf_gerobaks.wav`
- Notifikasi OTP: `nf_gerobaks.wav`

### Konfigurasi iOS
Semua notifikasi iOS memiliki suara yang diaktifkan melalui:
```dart
const DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
);
```

## Cara Menambahkan Suara Notifikasi Baru

Untuk menambahkan suara notifikasi baru:

1. Buat file WAV atau MP3 dengan suara notifikasi Anda
2. Letakkan di direktori `android/app/src/main/res/raw/`
3. Untuk iOS, letakkan di `ios/Runner/Resources/` (format .caf disarankan)
4. Referensikan dalam kode menggunakan:
```dart
sound: const RawResourceAndroidNotificationSound('nama_file_suara_anda'),
```

## Helper Class

Aplikasi Gerobaks menggunakan class helper `NotificationSoundHelper` untuk memudahkan pengelolaan suara notifikasi. Class ini menyediakan metode untuk membuat notifikasi dengan konfigurasi suara yang tepat.

## Praktik Terbaik

- Jaga ukuran file suara tetap kecil (<200KB) untuk menghindari masalah performa
- Gunakan suara notifikasi pendek (1-2 detik) untuk pengalaman pengguna yang lebih baik
- Untuk notifikasi penting (seperti pengingat pengambilan), gunakan suara yang berbeda
- Untuk notifikasi rutin, pertimbangkan untuk menggunakan suara yang lebih halus

## Pengujian

Saat menguji notifikasi, verifikasi:
1. Suara diputar pada perangkat Android dan iOS
2. Suara diputar dalam berbagai status aplikasi (foreground, background, terminated)
3. Suara menghormati pengaturan sistem untuk suara notifikasi
