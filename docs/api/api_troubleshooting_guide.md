# Panduan Troubleshooting API Laravel - Flutter

## Cek Koneksi API

1. **Perangkat Fisik vs Emulator**

   - Emulator Android: gunakan `http://10.0.2.2:8000` (akan otomatis digunakan)
   - Emulator iOS: gunakan `http://127.0.0.1:8000`
   - Perangkat Fisik: gunakan IP LAN komputer Anda, misal `http://192.168.1.100:8000`

2. **Modifikasi file .env**

   - Buat file `.env` di root project Flutter (jika belum ada)
   - Tambahkan baris: `API_BASE_URL=http://192.168.1.x:8000` (ganti dengan IP komputer Anda)

3. **Pastikan server Laravel berjalan**
   - Jalankan perintah `php artisan serve --host=0.0.0.0` di terminal
   - Server akan menyala di semua interface jaringan (bisa diakses dari perangkat lain)

## Debugging Login/Register

1. **Cek Server Laravel**

   - Pastikan API routes `/api/login` dan `/api/register` sudah terdaftar
   - Gunakan Postman untuk test API endpoints secara langsung

2. **Cek Logs**

   - Buka Debug Console di VS Code saat aplikasi berjalan
   - Perhatikan log dengan format: `🖥️ API POST Request` dan `📥 API Response`

3. **Setting CORS di Laravel**
   - Buka file `app/Http/Middleware/Cors.php`
   - Pastikan header berikut diizinkan:
     ```php
     header('Access-Control-Allow-Origin: *');
     header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
     header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization, X-Request-With');
     ```

## Solusi Umum

1. **Restart Server Laravel**

   ```
   php artisan cache:clear
   php artisan config:clear
   php artisan serve --host=0.0.0.0
   ```

2. **Restart Aplikasi Flutter**

   ```
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Cek Firewall & Antivirus**

   - Pastikan port 8000 tidak diblokir
   - Nonaktifkan sementara firewall untuk testing

4. **Periksa Kredensial**
   - Pastikan format email dan password sudah benar
   - Periksa apakah user dengan email tersebut sudah terdaftar
