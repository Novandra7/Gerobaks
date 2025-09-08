# Custom Dialog Integration in Gerobaks App

Berikut adalah dokumentasi perubahan yang telah dibuat untuk menerapkan dialog custom ke seluruh aplikasi Gerobaks.

## Komponen Dialog Custom

1. **CustomDialog**
   - Kelas untuk menampilkan dialog dengan tema putih-hijau yang sesuai dengan brand Gerobaks
   - Mendukung: title, content, positiveButton, negativeButton, icon, dan customContent
   - Mendukung state loading untuk menampilkan loading indicator pada tombol utama

2. **DialogHelper**
   - Utilitas untuk menampilkan berbagai jenis dialog dengan lebih mudah
   - Metode yang tersedia:
     - `showInfoDialog`: Dialog informasi umum
     - `showSuccessDialog`: Dialog untuk pesan sukses
     - `showErrorDialog`: Dialog untuk pesan error
     - `showConfirmDialog`: Dialog untuk konfirmasi (return boolean)
     - `showDeleteConfirmDialog`: Dialog untuk konfirmasi penghapusan
     - `showLoadingDialog`: Dialog loading
     - `showCustomDialog`: Dialog dengan widget konten kustom
     - `closeDialog`: Untuk menutup dialog loading

3. **RescheduleDialog**
   - Dialog khusus untuk pengaturan ulang jadwal
   - Mendukung pemilihan tanggal dan waktu

## Dialog yang Telah Diperbarui

1. **Subscription Cancellation Dialog**
   - File: `my_subscription_page.dart`
   - Menggunakan `DialogHelper.showConfirmDialog` untuk konfirmasi pembatalan langganan

2. **Logout Dialog**
   - File: `profile_content.dart`
   - Menggunakan `DialogHelper.showConfirmDialog` untuk konfirmasi logout

3. **Activity Cancellation Dialog**
   - File: `activity_detail_modal.dart`
   - Menggunakan `DialogHelper.showConfirmDialog` dengan parameter `isDestructiveAction: true`

4. **Reschedule Dialog**
   - File: `activity_detail_modal.dart`
   - Menggunakan `DialogHelper.showCustomDialog` dengan konten kustom untuk pengaturan tanggal dan waktu

## Cara Penggunaan

### Dialog Informasi
```dart
DialogHelper.showInfoDialog(
  context: context,
  title: 'Informasi',
  message: 'Ini adalah pesan informasi',
  buttonText: 'Mengerti',
);
```

### Dialog Sukses
```dart
DialogHelper.showSuccessDialog(
  context: context,
  title: 'Berhasil',
  message: 'Operasi berhasil dilakukan',
  buttonText: 'OK',
);
```

### Dialog Error
```dart
DialogHelper.showErrorDialog(
  context: context,
  title: 'Error',
  message: 'Terjadi kesalahan',
  buttonText: 'OK',
);
```

### Dialog Konfirmasi
```dart
final result = await DialogHelper.showConfirmDialog(
  context: context,
  title: 'Konfirmasi',
  message: 'Apakah Anda yakin?',
  confirmText: 'Ya',
  cancelText: 'Tidak',
  icon: Icons.help_outline,
);

if (result) {
  // User menekan tombol "Ya"
} else {
  // User menekan tombol "Tidak" atau menutup dialog
}
```

### Dialog Penghapusan
```dart
final result = await DialogHelper.showDeleteConfirmDialog(
  context: context,
  title: 'Hapus Data',
  message: 'Apakah Anda yakin ingin menghapus data ini?',
);

if (result) {
  // Lakukan penghapusan
}
```

### Dialog Loading
```dart
// Tampilkan dialog loading
DialogHelper.showLoadingDialog(
  context: context,
  message: 'Memuat data...',
);

// Lakukan operasi
await Future.delayed(Duration(seconds: 2));

// Tutup dialog loading
DialogHelper.closeDialog(context);
```

### Dialog dengan Konten Kustom
```dart
DialogHelper.showCustomDialog(
  context: context,
  title: 'Dialog Kustom',
  positiveButtonText: 'Simpan',
  negativeButtonText: 'Batal',
  icon: Icons.settings,
  customContent: YourCustomWidget(), // Widget konten kustom
  onPositivePressed: () {
    // Handler untuk tombol positif
    Navigator.pop(context);
  },
);
```

## Pengembangan Selanjutnya

Dialog kustom dapat diterapkan pada lebih banyak bagian aplikasi, terutama:

1. Form validasi
2. Dialog konfirmasi pembayaran
3. Dialog informasi tutorial
4. Dialog rating dan feedback

Untuk menambahkan lebih banyak dialog kustom, dapat memanfaatkan fungsi-fungsi yang sudah ada dalam `DialogHelper` atau membuat dialog spesifik jika diperlukan seperti `RescheduleDialog`.
