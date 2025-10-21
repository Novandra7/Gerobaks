# 🔧 Fix Login & Sign Up - Testing Guide

## ✅ Status Backend API

- ✅ **Login API**: `POST /api/login` - WORKING
- ✅ **Register API**: `POST /api/register` - WORKING
- ✅ **Me API**: `GET /api/auth/me` - WORKING (requires token)
- ✅ **Database Seeded**: Test users created

## 📝 Kredensial Test yang Benar

### ❌ JANGAN GUNAKAN (Tidak ada di database):

```
❌ sari@example.com / password123
❌ user@example.com / password123
```

### ✅ GUNAKAN INI (Sudah ada di database):

#### End User Accounts:

```
✅ daffa@gmail.com / password123
✅ sansan@gmail.com / password456
✅ wahyuh@gmail.com / password789
```

#### Mitra Accounts:

```
✅ driver.jakarta@gerobaks.com / mitra123
✅ driver.bandung@gerobaks.com / mitra123
✅ supervisor.surabaya@gerobaks.com / mitra123
```

## 🧪 Cara Testing

### 1. Test Backend API (Local)

```bash
# Di terminal backend
cd backend
php artisan serve

# Di terminal lain, test dengan curl:
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"daffa@gmail.com","password":"password123"}'
```

Expected Response:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "User Daffa",
      "email": "daffa@gmail.com",
      "role": "end_user",
      "points": 50
    },
    "token": "1|AbCdEf..."
  }
}
```

### 2. Test Flutter App

```bash
# Run Flutter app
flutter run

# Login dengan salah satu kredensial:
Email: daffa@gmail.com
Password: password123

# Atau untuk mitra:
Email: driver.jakarta@gerobaks.com
Password: mitra123
```

## 🔍 Troubleshooting

### Masalah: "The provided credentials are incorrect" (422)

**Penyebab**: Email/password salah atau user tidak ada di database

**Solusi**:

1. Pastikan backend sudah di-seed:

   ```bash
   cd backend
   php artisan migrate:fresh --seed
   ```

2. Gunakan kredensial yang benar (lihat daftar di atas)

3. Verifikasi user ada di database:
   ```bash
   cd backend
   php artisan tinker
   # Jalankan di tinker:
   User::where('email', 'daffa@gmail.com')->first()
   ```

### Masalah: CORS Error di Web Documentation

**Penyebab**: Swagger/OpenAPI documentation mencoba fetch dari frontend

**Solusi**: Test menggunakan Postman, curl, atau Flutter app langsung (bukan web docs)

### Masalah: "Connection refused"

**Penyebab**: Backend server tidak berjalan

**Solusi**:

```bash
cd backend
php artisan serve
# Atau gunakan built-in server:
php -S 127.0.0.1:8000 -t public
```

## 📋 Checklist Testing

- [ ] Backend server running di `http://127.0.0.1:8000`
- [ ] Database sudah di-migrate dan di-seed
- [ ] Test login via curl/Postman berhasil
- [ ] Flutter app bisa connect ke backend
- [ ] Login dengan `daffa@gmail.com` / `password123` berhasil
- [ ] Login dengan `driver.jakarta@gerobaks.com` / `mitra123` berhasil
- [ ] Navigation ke home/dashboard sesuai role
- [ ] User data (nama, poin, role) ditampilkan dengan benar

## 🚀 Production Deployment

Untuk production di `https://gerobaks.dumeg.com`:

1. Deploy backend Laravel ke server
2. Setup database production
3. Run migrations & seeders di production
4. Update Flutter app config untuk production URL
5. Test dengan kredensial yang sama

## 📝 Notes

- Backend API sudah menggunakan Laravel Sanctum untuk authentication
- Token disimpan di localStorage setelah login
- Role-based navigation sudah diimplementasi di Flutter app
- Sign-up akan otomatis register ke API dan login
