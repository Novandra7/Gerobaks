# API Credentials - Gerobaks Backend

## Production API

```
Base URL: https://gerobaks.dumeg.com
```

## Local Development API

```
Base URL: http://127.0.0.1:8000
```

## Test Accounts (Already Seeded in Database)

### End Users (Pelanggan)

1. **User Daffa**

   - Email: `daffa@gmail.com`
   - Password: `password123`
   - Role: `end_user`
   - Points: 50

2. **Jane San**

   - Email: `sansan@gmail.com`
   - Password: `password456`
   - Role: `end_user`
   - Points: 125

3. **Lionel Wahyu**
   - Email: `wahyuh@gmail.com`
   - Password: `password789`
   - Role: `end_user`
   - Points: 75

### Mitra (Driver/Petugas)

1. **Ahmad Kurniawan** (Jakarta)

   - Email: `driver.jakarta@gerobaks.com`
   - Password: `mitra123`
   - Role: `mitra`
   - Employee ID: DRV-JKT-001
   - Vehicle: Truck Sampah (B 1234 ABC)

2. **Budi Santoso** (Bandung)

   - Email: `driver.bandung@gerobaks.com`
   - Password: `mitra123`
   - Role: `mitra`
   - Employee ID: DRV-BDG-002
   - Vehicle: Truck Sampah (D 5678 EFG)

3. **Siti Nurhaliza** (Surabaya)
   - Email: `supervisor.surabaya@gerobaks.com`
   - Password: `mitra123`
   - Role: `mitra`
   - Employee ID: SPV-SBY-003
   - Vehicle: Motor Supervisor (L 9012 HIJ)

## API Endpoints

### Authentication

- `POST /api/register` - Register new user
- `POST /api/login` - Login user
- `GET /api/auth/me` - Get current user (requires token)
- `POST /api/auth/logout` - Logout user (requires token)

### Request Example (Login)

```json
POST /api/login
Content-Type: application/json

{
  "email": "daffa@gmail.com",
  "password": "password123"
}
```

### Response Example (Success)

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
      "points": 50,
      "profile_picture": "assets/img_friend1.png"
    },
    "token": "1|AbCdEf123456..."
  }
}
```

### Response Example (Failed - 422)

```json
{
  "message": "The provided credentials are incorrect.",
  "errors": {
    "email": ["The provided credentials are incorrect."]
  }
}
```

## Notes

- ✅ Backend Laravel API sudah berjalan dengan benar
- ✅ Login dan Register endpoint sudah tersedia
- ✅ Sanctum authentication sudah dikonfigurasi
- ⚠️ Pastikan menggunakan kredensial yang sudah di-seed di database
- ⚠️ User `sari@example.com` tidak ada - gunakan `daffa@gmail.com` sebagai gantinya
