# 🎯 Tutorial: Cara Menggunakan Swagger UI untuk Test API Gerobaks

Panduan lengkap step-by-step untuk menggunakan Swagger UI documentation.

## 📋 Daftar Isi

1. [Setup & Akses](#1-setup--akses)
2. [Memahami Interface](#2-memahami-interface)
3. [Login & Authentication](#3-login--authentication)
4. [Test Endpoint](#4-test-endpoint)
5. [Create Schedule (Mobile Format)](#5-create-schedule-mobile-format)
6. [Multi-Environment Testing](#6-multi-environment-testing)
7. [Tips & Tricks](#7-tips--tricks)

---

## 1. Setup & Akses

### Start Laravel Server

```bash
cd backend
php artisan serve
```

### Buka Swagger UI

Akses di browser:

```
http://127.0.0.1:8000
```

Atau:

```
http://127.0.0.1:8000/docs
http://127.0.0.1:8000/api-docs
```

**Screenshot Area:**

- [ ] Browser dengan URL http://127.0.0.1:8000
- [ ] Halaman landing Swagger UI

---

## 2. Memahami Interface

### 🎨 Layout Utama

```
┌──────────────────────────────────────────────────┐
│  🚛 Gerobaks API Documentation                   │
│  [Dark Mode] [Authorize] [Select Environment]    │
├──────────────────────────────────────────────────┤
│                                                   │
│  📖 Navigation                                    │
│    - Health                                       │
│    - Authentication                               │
│    - Schedules                                    │
│    - Tracking                                     │
│    - Payments                                     │
│    ...                                            │
│                                                   │
│  📋 Endpoint List                                 │
│    GET  /api/health                               │
│    POST /api/login                                │
│    GET  /api/schedules                            │
│    POST /api/schedules/mobile  🆕                 │
│    ...                                            │
│                                                   │
└──────────────────────────────────────────────────┘
```

### Komponen Penting

#### A. Header

- **Logo & Title**: "Gerobaks API Documentation"
- **Dark Mode Toggle**: Switch light/dark theme
- **Authorize Button**: 🔒 Input bearer token
- **Environment Selector**: Pilih Local/Staging/Production

#### B. API Tags (Categories)

- 🏥 **Health**: Health check endpoints
- 🔐 **Authentication**: Login, register, logout
- 📅 **Schedules**: Schedule management
- 📍 **Tracking**: GPS tracking
- 💰 **Balance**: Wallet & payments
- ⭐ **Ratings**: Service reviews
- 👨‍💼 **Admin**: Admin endpoints

#### C. Endpoint Card

Setiap endpoint menampilkan:

- **HTTP Method**: GET, POST, PATCH, DELETE
- **Path**: `/api/schedules/mobile`
- **Summary**: Deskripsi singkat
- **Lock Icon** 🔒: Requires authentication

---

## 3. Login & Authentication

### Step 1: Temukan Endpoint Login

1. Scroll ke section **"Authentication"**
2. Cari endpoint: `POST /api/login`
3. Klik untuk expand

### Step 2: Try It Out

1. Klik tombol **"Try it out"** (pojok kanan)
2. Request Body akan menjadi editable

### Step 3: Masukkan Credentials

Edit JSON di request body:

```json
{
  "email": "daffa@gmail.com",
  "password": "password123"
}
```

**Credentials yang tersedia:**

- **End User**:
  - Email: `daffa@gmail.com`
  - Password: `password123`
- **Mitra**:
  - Email: `mitra@gerobaks.com`
  - Password: `password123`
- **Admin**:
  - Email: `admin@gerobaks.com`
  - Password: `password123`

### Step 4: Execute Request

1. Klik tombol **"Execute"** (biru besar)
2. Tunggu response

### Step 5: Copy Token

Response akan seperti ini:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Daffa",
      "email": "daffa@gmail.com",
      "role": "end_user"
    },
    "token": "33|vPTYQr0DF4ESykfUGg1aly2PKc50273Ex6HH0UC50e894e5d"
  }
}
```

**Copy token** dari field `data.token`:

```
33|vPTYQr0DF4ESykfUGg1aly2PKc50273Ex6HH0UC50e894e5d
```

### Step 6: Authorize

1. Klik tombol **"Authorize"** di kanan atas (🔓 icon)
2. Modal dialog akan muncul
3. Paste token di field "Value" (tanpa kata "Bearer")
4. Klik **"Authorize"**
5. Klik **"Close"**

✅ **Icon berubah dari 🔓 menjadi 🔒** = Authorized!

---

## 4. Test Endpoint

### Contoh: Get User Info

#### Step 1: Pilih Endpoint

- Scroll ke section **"Authentication"**
- Pilih `GET /api/auth/me`
- Klik untuk expand

#### Step 2: Try It Out

- Klik **"Try it out"**

#### Step 3: Execute

- Klik **"Execute"**

#### Step 4: Lihat Response

```json
{
  "success": true,
  "message": "User data retrieved",
  "data": {
    "id": 1,
    "name": "Daffa",
    "email": "daffa@gmail.com",
    "role": "end_user",
    "phone": "08123456789",
    "balance": 50000,
    "created_at": "2025-01-15T10:30:00.000000Z"
  }
}
```

✅ **Jika berhasil**: Status code 200, data user muncul  
❌ **Jika gagal**: Status code 401, message "Unauthenticated"

---

## 5. Create Schedule (Mobile Format)

### Endpoint Khusus Mobile App

`POST /api/schedules/mobile`

Format ini menggunakan **field dalam bahasa Indonesia** sesuai mobile app.

### Step-by-Step

#### Step 1: Pastikan Sudah Login

- Icon authorize harus **locked** 🔒
- Token sudah diset di Step 3

#### Step 2: Buka Endpoint

- Scroll ke section **"Schedules"**
- Cari `POST /api/schedules/mobile`
- Klik untuk expand

#### Step 3: Try It Out

- Klik **"Try it out"**

#### Step 4: Isi Request Body

Edit JSON dengan data berikut:

```json
{
  "alamat": "Jl. Merdeka No. 123, Jakarta Pusat",
  "tanggal": "2025-11-01",
  "waktu": "08:00",
  "catatan": "Tolong ambil di depan rumah",
  "koordinat": {
    "lat": -6.2,
    "lng": 106.816667
  },
  "jenis_layanan": "pickup_sampah_organik",
  "metode_pembayaran": "cash"
}
```

#### Step 5: Penjelasan Field

| Field               | Type          | Required | Deskripsi             | Contoh                  |
| ------------------- | ------------- | -------- | --------------------- | ----------------------- |
| `alamat`            | string        | ✅ Yes   | Alamat lengkap pickup | "Jl. Merdeka No. 123"   |
| `tanggal`           | string (date) | ✅ Yes   | Format: YYYY-MM-DD    | "2025-11-01"            |
| `waktu`             | string (time) | ✅ Yes   | Format: HH:mm         | "08:00"                 |
| `koordinat.lat`     | number        | ✅ Yes   | Latitude              | -6.200000               |
| `koordinat.lng`     | number        | ✅ Yes   | Longitude             | 106.816667              |
| `jenis_layanan`     | string        | ✅ Yes   | Jenis sampah          | "pickup_sampah_organik" |
| `catatan`           | string        | ❌ No    | Catatan tambahan      | "Ambil di depan"        |
| `metode_pembayaran` | string        | ❌ No    | cash/transfer/wallet  | "cash"                  |

#### Step 6: Pilihan Jenis Layanan

```
pickup_sampah_organik     → Sampah Organik (sisa makanan, daun)
pickup_sampah_anorganik   → Sampah Anorganik (plastik, kaleng)
pickup_sampah_daur_ulang  → Sampah Daur Ulang (kertas, botol)
pickup_sampah_b3          → Sampah B3 (baterai, lampu)
pickup_sampah_campuran    → Sampah Campuran
```

#### Step 7: Execute

- Klik **"Execute"**

#### Step 8: Lihat Response Success

```json
{
  "success": true,
  "message": "Jadwal berhasil dibuat",
  "data": {
    "id": 45,
    "user_id": 1,
    "service_type": "pickup_sampah_organik",
    "pickup_address": "Jl. Merdeka No. 123, Jakarta Pusat",
    "pickup_latitude": -6.2,
    "pickup_longitude": 106.816667,
    "scheduled_at": "2025-11-01 08:00:00",
    "status": "pending",
    "payment_method": "cash",
    "notes": "Tolong ambil di depan rumah",
    "created_at": "2025-01-15T12:00:00.000000Z"
  }
}
```

✅ **Status 201**: Schedule created successfully!

#### Step 9: Handle Error 422

Jika ada field yang missing:

```json
{
  "message": "The alamat field is required. (and 5 more errors)",
  "errors": {
    "alamat": ["The alamat field is required."],
    "tanggal": ["The tanggal field is required."],
    "waktu": ["The waktu field is required."],
    "koordinat.lat": ["The koordinat.lat field is required."],
    "koordinat.lng": ["The koordinat.lng field is required."],
    "jenis_layanan": ["The jenis layanan field is required."]
  }
}
```

**Fix**: Pastikan semua field required terisi!

---

## 6. Multi-Environment Testing

### Pilih Environment

1. Klik dropdown **"Select Environment"** di header
2. Pilih salah satu:
   - 🖥️ **Local**: http://127.0.0.1:8000
   - 🧪 **Staging**: https://staging-gerobaks.dumeg.com
   - 🌐 **Production**: https://gerobaks.dumeg.com

### Test Health Check

Setelah pilih environment:

1. Scroll ke section **"Health"**
2. Pilih `GET /api/health`
3. Klik **"Try it out"**
4. Klik **"Execute"**

Response:

```json
{
  "status": "ok"
}
```

✅ **Status 200**: Environment connected!

### Switch Environment

Untuk pindah environment:

1. Login ulang di environment baru
2. Copy token baru
3. Authorize dengan token baru
4. Test endpoint

---

## 7. Tips & Tricks

### 🎯 Keyboard Shortcuts

| Shortcut       | Action          |
| -------------- | --------------- |
| `Ctrl + F`     | Search endpoint |
| `Esc`          | Close modal     |
| Click endpoint | Expand/collapse |

### 💡 Best Practices

#### 1. Save Token

- Copy token ke text editor
- Jangan logout sebelum selesai test
- Token valid untuk beberapa jam

#### 2. Test Flow

Urutan test yang baik:

```
1. Health Check (/api/health)
2. Login (/api/login)
3. Get User Info (/api/auth/me)
4. Create Schedule (/api/schedules/mobile)
5. Get Schedules (/api/schedules)
```

#### 3. Use Filters

Untuk endpoint dengan query parameters:

```
GET /api/schedules?status=pending&per_page=10
```

Edit di "Parameters" section sebelum execute.

#### 4. Copy cURL

Setelah execute, scroll ke response area:

- Klik tab **"cURL"**
- Copy command
- Run di terminal

### 🐛 Troubleshooting

#### Error 401 Unauthorized

**Penyebab**: Token tidak valid/expired  
**Fix**:

1. Login ulang
2. Copy token baru
3. Authorize lagi

#### Error 403 Forbidden

**Penyebab**: Role tidak punya permission  
**Fix**: Login dengan user yang sesuai

- `end_user` → `/api/schedules/mobile`
- `mitra` → `/api/schedules` (update)
- `admin` → `/api/admin/*`

#### Error 422 Validation

**Penyebab**: Field required tidak terisi  
**Fix**: Cek error message, isi field yang kurang

#### Error 500 Server Error

**Penyebab**: Backend error  
**Fix**:

1. Cek terminal Laravel
2. Lihat error log
3. Fix backend code

### 📊 Response Codes

| Code | Meaning             | Action            |
| ---- | ------------------- | ----------------- |
| 200  | ✅ Success          | Data retrieved    |
| 201  | ✅ Created          | Resource created  |
| 401  | ❌ Unauthorized     | Login/authorize   |
| 403  | ❌ Forbidden        | Check permission  |
| 404  | ❌ Not Found        | Check endpoint/ID |
| 422  | ❌ Validation Error | Fix request data  |
| 500  | ❌ Server Error     | Check backend     |

### 🎨 UI Features

#### Dark Mode

- Klik icon 🌙 (moon) di header
- Toggle antara light/dark
- Preference tersimpan di localStorage

#### Collapse All

- Refresh page untuk collapse semua
- Atau klik setiap endpoint untuk close

#### Search

- `Ctrl + F` untuk search
- Ketik nama endpoint
- Browser akan highlight

---

## 📚 Contoh Use Cases

### Use Case 1: Test Schedule Creation Flow

```
1. Login sebagai end_user (daffa@gmail.com)
2. Copy token → Authorize
3. Create schedule via POST /api/schedules/mobile
4. Get schedules via GET /api/schedules
5. Verify schedule muncul di list
```

### Use Case 2: Test Multi-Role Access

```
1. Login sebagai end_user
2. Try POST /api/schedules (standard) → Expect 403
3. Try POST /api/schedules/mobile → Expect 201 ✅
4. Logout
5. Login sebagai mitra
6. Try POST /api/schedules → Expect 201 ✅
```

### Use Case 3: Test Tracking

```
1. Login sebagai mitra
2. Get active schedule via GET /api/schedules?status=in_progress
3. Record GPS via POST /api/tracking
4. Check tracking via GET /api/tracking?schedule_id=X
```

---

## 🔗 Quick Links

- **Swagger UI**: http://127.0.0.1:8000
- **OpenAPI Spec**: http://127.0.0.1:8000/openapi.yaml
- **GitHub**: https://github.com/fk0u/gerobackend
- **Production**: https://gerobaks.dumeg.com

---

## 💬 Support

Jika ada masalah:

1. Cek SWAGGER_DOCUMENTATION.md
2. Cek API_DOCUMENTATION_COMPLETE.md
3. Hubungi [@fk0u](https://github.com/fk0u)

---

**Happy Testing! 🚀**

Made with ❤️ for Gerobaks Team
