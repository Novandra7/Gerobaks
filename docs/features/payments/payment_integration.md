# Payment Gateway Integration

Gerobaks mendukung integrasi dengan berbagai metode pembayaran untuk memberikan fleksibilitas kepada pengguna dalam melakukan pembayaran layanan.

## Metode Pembayaran yang Didukung

1. **QRIS**
   - Mendukung semua e-wallet dan mobile banking yang menggunakan QRIS
   - Implementasi pembayaran menggunakan QR Code standar

2. **E-Wallet**
   - **ShopeePay** - Deep link ke aplikasi ShopeePay
   - **GoPay** - Deep link ke aplikasi Gojek untuk pembayaran melalui GoPay
   - **DANA** - Deep link ke aplikasi DANA

3. **Transfer Bank**
   - Bank BCA
   - Bank BNI
   - Bank Mandiri

## Implementasi Deep Link

Aplikasi mengimplementasikan kemampuan deep link untuk membuka aplikasi pembayaran langsung dari Gerobaks. Jika aplikasi pembayaran tidak terinstal, pengguna akan diarahkan ke versi web atau diberikan instruksi untuk menginstal aplikasi yang diperlukan.

### Konfigurasi Android

AndroidManifest.xml telah dikonfigurasi untuk mendukung package visibility untuk deep linking:

```xml
<queries>
    <!-- For ShopeePay -->
    <package android:name="com.shopee.id" />
    <!-- For GoPay -->
    <package android:name="com.gojek.app" />
    <!-- For DANA -->
    <package android:name="id.dana" />
</queries>
```

### Package yang Digunakan

Fitur ini diimplementasikan menggunakan package `url_launcher` untuk membuka aplikasi eksternal atau URL.

## Alur Pembayaran

1. Pengguna memilih metode pembayaran dari daftar yang tersedia
2. Sistem menampilkan loading dialog sebagai indikator proses
3. Aplikasi pembayaran yang sesuai dibuka secara otomatis
4. Pengguna menyelesaikan pembayaran di aplikasi tersebut
5. Setelah pembayaran berhasil, pengguna akan melihat halaman konfirmasi pembayaran

## Penanganan Error

Jika aplikasi pembayaran tidak dapat dibuka, sistem akan:
1. Menampilkan pesan error yang informatif
2. Menyarankan untuk menggunakan metode pembayaran alternatif
3. Memberikan opsi untuk mencoba kembali
