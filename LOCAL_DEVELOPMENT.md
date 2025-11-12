# 🛠️ Local Development Setup dengan phpMyAdmin

Panduan untuk menggunakan database lokal saat development sebelum migrasi ke server.

## 📋 Prerequisites

✅ phpMyAdmin sudah aktif
✅ Backend Laravel/PHP sudah running di `http://127.0.0.1:8000`
✅ Database MySQL/MariaDB sudah siap

---

## 🔧 Konfigurasi yang Sudah Dilakukan

### 1. **File `.env` Flutter**
```env
API_BASE_URL=http://127.0.0.1:8000
```

### 2. **App Config (`lib/utils/app_config.dart`)**
```dart
DEFAULT_API_URL = 'http://127.0.0.1:8000'  // Prioritas pertama
```

---

## 🚀 Cara Menggunakan

### **1. Pastikan Backend Lokal Running**

```bash
# Di folder backend Laravel/PHP Anda
php artisan serve
# atau
php artisan serve --host=127.0.0.1 --port=8000
```

Tes di browser: http://127.0.0.1:8000/api

### **2. Cek Koneksi Database**

Buka phpMyAdmin:
```
http://localhost/phpmyadmin
```

Pastikan database `gerobaks` sudah ada dengan tabel:
- `users`
- `schedules`
- `subscriptions`
- `notifications`
- dll.

### **3. Jalankan Flutter App**

```bash
# Clean dan get dependencies
flutter clean
flutter pub get

# Run app
flutter run
```

---

## 📱 Testing API Connection

### **Test Endpoints:**

#### 1. Authentication
```bash
# Login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Get user info
curl http://127.0.0.1:8000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### 2. Schedules
```bash
# Get all schedules
curl http://127.0.0.1:8000/api/schedules

# Create schedule
curl -X POST http://127.0.0.1:8000/api/schedules \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "user_id": 1,
    "scheduled_date": "2025-11-12",
    "scheduled_time": "10:00:00",
    "address": "Jl. Test No. 123",
    "latitude": -6.2088,
    "longitude": 106.8456
  }'
```

#### 3. Check API Health
```bash
curl http://127.0.0.1:8000/api/ping
```

---

## 🔄 Switching Between Local & Production

### **Untuk Development (Local):**
```dart
// Di .env
API_BASE_URL=http://127.0.0.1:8000
```

### **Untuk Production (Server):**
```dart
// Di .env
API_BASE_URL=https://gerobaks.dumeg.com
```

### **Via App Settings (Runtime):**
```dart
// Set manual di app
await AppConfig.setApiBaseUrl('http://127.0.0.1:8000');

// Reset ke default
await AppConfig.resetApiBaseUrl();
```

---

## 🐛 Troubleshooting

### **Error: "Failed to connect to 127.0.0.1:8000"**

**Android Emulator:**
```dart
// Ganti di .env
API_BASE_URL=http://10.0.2.2:8000  // Untuk Android Emulator
```

**iOS Simulator:**
```dart
// Tetap gunakan
API_BASE_URL=http://127.0.0.1:8000  // OK untuk iOS
```

**Physical Device:**
```dart
// Ganti dengan IP komputer Anda di LAN
API_BASE_URL=http://192.168.1.XXX:8000
```

### **Error: "CORS Policy"**

Di backend Laravel, tambahkan ke `config/cors.php`:
```php
'paths' => ['api/*'],
'allowed_origins' => ['*'],  // Untuk development
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

### **Error: "Connection refused"**

1. Cek backend running: `php artisan serve`
2. Cek port 8000 tidak dipakai: `lsof -i :8000`
3. Restart backend

---

## 📊 Database Tables (phpMyAdmin)

### **Tabel Utama:**

| Tabel | Deskripsi |
|-------|-----------|
| `users` | Data user (end user & mitra) |
| `schedules` | Jadwal penjemputan sampah |
| `waste_items` | Detail jenis sampah per schedule |
| `subscriptions` | Langganan premium user |
| `notifications` | Notifikasi ke user |
| `trackings` | Tracking lokasi real-time mitra |

### **Sample Data untuk Testing:**

**User:**
```sql
INSERT INTO users (name, email, password, role) VALUES
('Test User', 'user@test.com', '$2y$10$...', 'user'),
('Test Mitra', 'mitra@test.com', '$2y$10$...', 'mitra');
```

**Schedule:**
```sql
INSERT INTO schedules (user_id, scheduled_at, address, latitude, longitude, status) VALUES
(1, '2025-11-12 10:00:00', 'Jl. Test No. 123', -6.2088, 106.8456, 'pending');
```

---

## ✅ Checklist Development

- [x] phpMyAdmin aktif
- [x] Backend Laravel running di 127.0.0.1:8000
- [x] Database `gerobaks` sudah dibuat
- [x] Tabel-tabel sudah ter-migrate
- [x] `.env` Flutter sudah diupdate
- [x] `app_config.dart` sudah diupdate
- [ ] Test API endpoints dengan Postman/curl
- [ ] Test login dari Flutter app
- [ ] Test create schedule dari app
- [ ] Verify data masuk ke database

---

## 🚀 Next Steps

1. ✅ Test semua API endpoints
2. ✅ Verify data tersimpan di phpMyAdmin
3. ✅ Test CRUD operations dari Flutter
4. 📤 Ready untuk migrasi ke server production

---

## 📞 Support

Jika ada masalah:
1. Cek console log Flutter: `flutter logs`
2. Cek Laravel log: `storage/logs/laravel.log`
3. Cek network tab di Chrome DevTools
4. Test API dengan Postman terlebih dahulu

Happy Coding! 🎉
