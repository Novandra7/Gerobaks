# Petunjuk Mengatasi Masalah Login API

## Permasalahan Yang Terjadi

Berdasarkan analisis, masalah login/register API yang dialami terdiri dari beberapa kemungkinan:

1. **Koneksi API tidak berfungsi** - Aplikasi mobile tidak dapat terhubung ke server Laravel
2. **Konfigurasi URL tidak tepat** - URL API berbeda tergantung perangkat (emulator vs perangkat fisik)
3. **Server Laravel tidak berjalan dengan konfigurasi yang tepat**

## Langkah-langkah Perbaikan

Berikut adalah langkah-langkah untuk mengatasi masalah:

### 1. Pastikan Server Laravel Berjalan dengan Benar

```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```

Opsi `--host=0.0.0.0` sangat penting agar server dapat diakses dari perangkat lain di jaringan (termasuk perangkat fisik).

### 2. Sesuaikan Konfigurasi API URL di Flutter

File `.env` di Flutter harus menggunakan URL yang berbeda tergantung perangkat:

- **Emulator Android**: `API_BASE_URL=http://10.0.2.2:8000`
- **Simulator iOS**: `API_BASE_URL=http://127.0.0.1:8000`
- **Perangkat Fisik**: `API_BASE_URL=http://192.168.1.x:8000` (ganti x dengan IP komputer)

### 3. Jalankan Script Test Koneksi

Jalankan script `test_api_connection.bat` untuk memeriksa koneksi ke server:

```bash
./test_api_connection.bat
```

Atau jalankan script PHP di folder backend untuk menguji API endpoints:

```bash
cd backend
php test_laravel_api.php
```

### 4. Jalankan Aplikasi Flutter

Setelah konfigurasi selesai, jalankan aplikasi Flutter:

```bash
flutter clean
flutter pub get
flutter run
```

## File-file yang Telah Dimodifikasi

1. **api_client.dart** - Ditambahkan diagnostik error dan handling koneksi yang lebih baik
2. **routes/api.php** - Ditambahkan endpoint `/api/ping` untuk test koneksi
3. **api_troubleshooting_guide.md** - Panduan mengatasi masalah koneksi API
4. **test_api_connection.bat** - Script untuk menguji koneksi API dari Windows
5. **backend/test_laravel_api.php** - Script PHP untuk menguji endpoint API Laravel

## Catatan Penting

Pastikan tidak ada isu CORS di server Laravel. Jika masalah masih berlanjut, coba tambahkan header CORS berikut di Laravel:

```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization, X-Request-With');
```

Atau gunakan package Laravel CORS dengan konfigurasi yang tepat.
