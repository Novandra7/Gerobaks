# 📚 Backend Documentation Index - Mitra Pickup System

> **Panduan lengkap untuk backend team mengimplementasikan sistem penjemputan User-Mitra**

---

## 🎯 Apa yang Harus Diimplementasikan?

**Fitur:** User membuat jadwal pengambilan sampah → Mitra melihat, menerima, dan menyelesaikan → Status otomatis update ke User → User dapat poin

**Status:** 🔴 URGENT - Core Feature Aplikasi

---

## 📖 Dokumentasi yang Tersedia

### 1. **MITRA_PICKUP_SYSTEM.md** (Dokumentasi Utama)
**File:** `docs/MITRA_PICKUP_SYSTEM.md`  
**Isi:**
- ✅ Overview lengkap feature
- ✅ Flow User dan Mitra
- ✅ Database schema & migration
- ✅ 10 API endpoints detail dengan contoh request/response
- ✅ Laravel implementation lengkap
- ✅ Notification events
- ✅ WebSocket/Pusher integration (optional)
- ✅ Testing checklist

**Baca ini PERTAMA untuk memahami keseluruhan sistem**

---

### 2. **QUICK_MITRA_API.md** (Quick Reference)
**File:** `docs/QUICK_MITRA_API.md`  
**Isi:**
- ✅ Tabel endpoint summary
- ✅ Database changes yang diperlukan
- ✅ Status flow diagram
- ✅ Critical implementation points
- ✅ Response format examples
- ✅ Testing commands dengan curl
- ✅ Implementation priority order

**Gunakan ini untuk quick reference saat coding**

---

### 3. **VISUAL_FLOW_DIAGRAM.md** (Visual Guide)
**File:** `docs/VISUAL_FLOW_DIAGRAM.md`  
**Isi:**
- ✅ Complete user journey (step-by-step)
- ✅ Database state changes per step
- ✅ UI flow diagram (User app & Mitra app)
- ✅ Notification timeline
- ✅ Security & validation rules
- ✅ API response time expectations

**Baca ini untuk memahami flow secara visual**

---

### 4. **NOTIFICATION_CODE_EXAMPLES.md** (Implementation Code)
**File:** `docs/NOTIFICATION_CODE_EXAMPLES.md`  
**Isi:**
- ✅ Complete notification class code (3 files)
- ✅ Event class untuk broadcasting
- ✅ Controller implementation lengkap
- ✅ Routes configuration
- ✅ Broadcasting setup (Pusher)
- ✅ Model relationships
- ✅ Database migration
- ✅ Testing examples dengan curl

**Copy-paste ready code untuk implementasi**

---

## 🚀 Quick Start Guide

### Step 1: Pahami Flow
1. Baca `VISUAL_FLOW_DIAGRAM.md` untuk overview
2. Lihat user journey dan database state changes
3. Pahami kapan notification dikirim

### Step 2: Database Setup
```bash
# Jalankan migration
php artisan make:migration add_mitra_fields_to_pickup_schedules

# Copy code dari NOTIFICATION_CODE_EXAMPLES.md section "Database Migration"
# Lalu run:
php artisan migrate
```

### Step 3: Buat Notification Classes
```bash
# Buat 3 notification files
php artisan make:notification MitraAssigned
php artisan make:notification PickupCompleted
php artisan make:notification PickupCancelled

# Copy code dari NOTIFICATION_CODE_EXAMPLES.md
```

### Step 4: Buat Event (Optional, untuk realtime)
```bash
php artisan make:event PickupStatusUpdated

# Copy code dari NOTIFICATION_CODE_EXAMPLES.md
```

### Step 5: Implement Controller
```bash
# Buat controller
php artisan make:controller Api/Mitra/MitraPickupController

# Copy methods dari MITRA_PICKUP_SYSTEM.md atau NOTIFICATION_CODE_EXAMPLES.md
```

### Step 6: Add Routes
```php
// Tambahkan di routes/api.php
// Copy dari NOTIFICATION_CODE_EXAMPLES.md section "Routes Configuration"
```

### Step 7: Testing
```bash
# Test dengan curl commands dari QUICK_MITRA_API.md section "Testing Commands"

# 1. Get available schedules
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer {mitra_token}"

# 2. Accept schedule
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept" \
  -H "Authorization: Bearer {mitra_token}"

# 3. Complete pickup
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete" \
  -H "Authorization: Bearer {mitra_token}" \
  -F "actual_weights[Organik]=3.5" \
  -F "photos[]=@photo1.jpg"
```

---

## 📊 API Endpoints Summary

| Priority | Method | Endpoint | Fungsi |
|----------|--------|----------|--------|
| 🔴 HIGH | **GET** | `/api/mitra/pickup-schedules/available` | List jadwal PENDING |
| 🔴 HIGH | **GET** | `/api/mitra/pickup-schedules/{id}` | Detail jadwal |
| 🔴 HIGH | **POST** | `/api/mitra/pickup-schedules/{id}/accept` | Mitra terima jadwal |
| 🔴 HIGH | **POST** | `/api/mitra/pickup-schedules/{id}/complete` | Upload foto + berat |
| 🟡 MEDIUM | **POST** | `/api/mitra/pickup-schedules/{id}/cancel` | Batalkan jadwal |
| 🟡 MEDIUM | **GET** | `/api/mitra/pickup-schedules/my-active` | Jadwal aktif |
| 🟢 LOW | **GET** | `/api/mitra/pickup-schedules/history` | Riwayat |

Detail lengkap: `MITRA_PICKUP_SYSTEM.md`

---

## 🗄️ Database Changes

```sql
ALTER TABLE pickup_schedules ADD:
- assigned_mitra_id (foreign key to users)
- assigned_at, on_the_way_at, picked_up_at, completed_at
- actual_weights (JSON), total_weight (decimal)
- pickup_photos (JSON)
- cancelled_at, cancellation_reason
```

Full migration code: `NOTIFICATION_CODE_EXAMPLES.md`

---

## 🔔 Notification Events

### Kirim ke User:
1. **mitra_assigned** - Saat mitra accept jadwal
2. **pickup_completed** - Saat mitra selesai (+ poin)
3. **pickup_cancelled** - Saat mitra cancel

### Kirim ke Mitra (Optional):
4. **new_schedule_available** - Saat ada jadwal baru

Detail: `MITRA_PICKUP_SYSTEM.md` section "Notification Events"

---

## ✅ Testing Checklist

**Backend Must Test:**
- [ ] Mitra bisa lihat list jadwal pending
- [ ] Mitra bisa accept jadwal → status jadi on_progress
- [ ] User otomatis terima notifikasi
- [ ] Status di app user otomatis update
- [ ] Mitra bisa complete dengan upload foto
- [ ] Points user otomatis bertambah
- [ ] Mitra bisa cancel jadwal
- [ ] Prevent double-accept (race condition)

Full checklist: `MITRA_PICKUP_SYSTEM.md` section "Testing Checklist"

---

## 📱 Implementation Priority

### Week 1 (URGENT):
1. ✅ Database migration
2. ✅ API available schedules
3. ✅ API accept schedule
4. ✅ API complete pickup
5. ✅ Auto-update points
6. ✅ Notification system

### Week 2:
7. ⭕ Cancel feature
8. ⭕ History API
9. ⭕ My active schedules

### Week 3 (Optional):
10. ⭕ Realtime location tracking
11. ⭕ ETA calculation
12. ⭕ Rating system

---

## 🧪 How to Test

### 1. Create Test Data
```sql
-- Buat user dengan role mitra
INSERT INTO users (name, email, password, role, phone, vehicle_type, vehicle_plate)
VALUES ('John Doe', 'mitra@test.com', bcrypt('password'), 'mitra', '081987654321', 'Truk', 'B 1234 XYZ');

-- User sudah punya jadwal pending (ID 36-41 sudah ada)
```

### 2. Login sebagai Mitra
```bash
curl -X POST "http://127.0.0.1:8000/api/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "mitra@test.com", "password": "password"}'

# Save token untuk testing selanjutnya
```

### 3. Test Flow Lengkap
```bash
# Step 1: Get available schedules
curl -X GET ".../available" -H "Authorization: Bearer {token}"

# Step 2: Accept schedule 36
curl -X POST ".../36/accept" -H "Authorization: Bearer {token}"

# Step 3: Complete with photos
curl -X POST ".../36/complete" \
  -H "Authorization: Bearer {token}" \
  -F "actual_weights[Organik]=3.5" \
  -F "photos[]=@test.jpg"

# Step 4: Check user's notifications
curl -X GET "http://127.0.0.1:8000/api/notifications" \
  -H "Authorization: Bearer {user_token}"

# Step 5: Check user's points increased
curl -X GET "http://127.0.0.1:8000/api/user/profile" \
  -H "Authorization: Bearer {user_token}"
```

Full testing guide: `QUICK_MITRA_API.md` section "Testing Commands"

---

## 🔍 Troubleshooting

### Issue: Double Accept (2 mitra accept bersamaan)
**Solution:** Use DB transaction with row locking
```php
$schedule = PickupSchedule::where('id', $id)
    ->where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->lockForUpdate()  // ← Lock row
    ->firstOrFail();
```

### Issue: Notification tidak terkirim
**Check:**
1. Queue worker running? `php artisan queue:work`
2. Notification table exist? Check migration
3. User relationship correct?

### Issue: Photos tidak terupload
**Check:**
1. Storage linked? `php artisan storage:link`
2. Permissions correct? `chmod -R 755 storage`
3. Max upload size? Check `php.ini`

### Issue: Points tidak bertambah
**Check:**
1. Transaction success?
2. User model has `increment()` method?
3. Check logs: `tail -f storage/logs/laravel.log`

---

## 📞 Contact & Support

**Flutter Team Status:** ✅ Ready to integrate  
**Backend Team:** Waiting for implementation  
**Priority:** 🔴 URGENT - Core Feature

**Questions?** Check dokumentasi lengkap di:
- `docs/MITRA_PICKUP_SYSTEM.md` (most comprehensive)
- `docs/QUICK_MITRA_API.md` (quick reference)
- `docs/VISUAL_FLOW_DIAGRAM.md` (visual guide)
- `docs/NOTIFICATION_CODE_EXAMPLES.md` (code examples)

---

## 📦 Deliverables

**Yang Harus Backend Team Deliver:**

### API Endpoints (7 endpoints):
- ✅ GET `/api/mitra/pickup-schedules/available`
- ✅ GET `/api/mitra/pickup-schedules/{id}`
- ✅ POST `/api/mitra/pickup-schedules/{id}/accept`
- ✅ POST `/api/mitra/pickup-schedules/{id}/start-journey`
- ✅ POST `/api/mitra/pickup-schedules/{id}/arrive`
- ✅ POST `/api/mitra/pickup-schedules/{id}/complete`
- ✅ POST `/api/mitra/pickup-schedules/{id}/cancel`

### Database:
- ✅ Migration file
- ✅ Update `pickup_schedules` table

### Notification:
- ✅ 3 notification classes
- ✅ Auto-send on events
- ✅ Save to database

### Business Logic:
- ✅ Status transition (pending → on_progress → completed)
- ✅ Points calculation (1 kg = 10 points)
- ✅ Photo upload
- ✅ Prevent double-accept

### Testing:
- ✅ Postman collection
- ✅ Test dengan real data
- ✅ Verify notifications
- ✅ Verify points increment

---

## 🎯 Success Criteria

**Feature dianggap COMPLETE jika:**

1. ✅ Mitra bisa lihat list jadwal pending dari semua user
2. ✅ Mitra bisa klik detail → lihat nama, telpon, alamat, map
3. ✅ Mitra terima jadwal → status auto-update ke user (pending → on_progress)
4. ✅ User terima notification realtime
5. ✅ Mitra complete dengan upload foto → user dapat poin otomatis
6. ✅ Status di user app otomatis update (on_progress → completed)
7. ✅ User terima notification completion dengan jumlah poin
8. ✅ Mitra bisa cancel → status kembali pending
9. ✅ No bug, no crash, tested end-to-end

---

**Dokumentasi dibuat:** 12 November 2025  
**Status:** 🔴 READY TO IMPLEMENT  
**Estimated Backend Work:** 2-3 hari  
**Flutter Team:** Waiting for API integration

**Let's build this! 🚀**
# 🚛 Sistem Penjemputan Sampah: User ↔ Mitra
## Dokumentasi Backend API untuk Interaksi User-Mitra

> **Tanggal:** 12 November 2025  
> **Status:** 🔴 URGENT - Feature Inti Aplikasi  
> **Priority:** CRITICAL

---

## 📋 Overview Feature

### User Flow:
1. User membuat jadwal penjemputan → Status: **PENDING**
2. Jadwal muncul di list Mitra yang available
3. Mitra menerima jadwal → Status: **ON_PROGRESS** (otomatis update di User)
4. Mitra perjalanan ke lokasi → User bisa track realtime
5. Mitra selesai → Status: **COMPLETED**

### Mitra Flow:
1. Melihat list jadwal PENDING dari semua user
2. Klik detail jadwal → Lihat info lengkap (nama, telpon, alamat, map)
3. Terima jadwal → Status berubah PENDING → ON_PROGRESS
4. Update lokasi saat perjalanan (optional realtime tracking)
5. Konfirmasi selesai → Upload foto, input berat sampah

---

## 🗄️ Database Schema yang Dibutuhkan

### Tabel Utama: `pickup_schedules`

**Fields yang sudah ada + tambahan:**

```sql
ALTER TABLE pickup_schedules ADD COLUMN IF NOT EXISTS:

-- Mitra Assignment
assigned_mitra_id BIGINT UNSIGNED NULL COMMENT 'ID Mitra yang menerima',
assigned_at DATETIME NULL COMMENT 'Kapan mitra accept',

-- Tracking Status
on_the_way_at DATETIME NULL COMMENT 'Kapan mitra mulai perjalanan',
picked_up_at DATETIME NULL COMMENT 'Kapan sampai lokasi user',
completed_at DATETIME NULL COMMENT 'Kapan selesai',

-- Completion Data
actual_weights JSON NULL COMMENT 'Berat aktual per jenis sampah',
total_weight DECIMAL(8,2) NULL COMMENT 'Total berat (kg)',
pickup_photos JSON NULL COMMENT 'Array foto bukti pengambilan',

-- Cancellation
cancelled_at DATETIME NULL,
cancellation_reason TEXT NULL,

-- Foreign Key
FOREIGN KEY (assigned_mitra_id) REFERENCES users(id) ON DELETE SET NULL;

-- Index
CREATE INDEX idx_assigned_mitra ON pickup_schedules(assigned_mitra_id);
CREATE INDEX idx_status_mitra ON pickup_schedules(status, assigned_mitra_id);
```

### Enum Status Flow:

```
pending → on_progress → completed
   ↓
cancelled
```

**Status Definitions:**
- `pending`: Jadwal baru dibuat user, menunggu mitra accept
- `on_progress`: Mitra sudah accept, sedang dalam perjalanan
- `completed`: Pengambilan selesai
- `cancelled`: Dibatalkan oleh user atau mitra

---

## 🔌 API Endpoints yang Dibutuhkan

### 1. **GET /api/mitra/pickup-schedules/available**
**Fungsi:** Mitra melihat semua jadwal PENDING yang belum diambil

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/available`

**Headers:**
```
Authorization: Bearer {mitra_token}
Accept: application/json
```

**Query Parameters (Optional):**
```
area         // Filter berdasarkan area kerja mitra
waste_type   // Filter jenis sampah
date         // Filter tanggal (YYYY-MM-DD)
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 36,
        "user_id": 15,
        "user_name": "Ali",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
        "latitude": -6.208763,
        "longitude": 106.845599,
        "schedule_day": "rabu",
        "waste_type_scheduled": "B3",
        "scheduled_pickup_at": "2025-11-13 06:00:00",
        "pickup_time_start": "06:00:00",
        "pickup_time_end": "08:00:00",
        "waste_summary": "B3",
        "notes": "Sampah sudah dipilah",
        "status": "pending",
        "created_at": "2025-11-12 14:12:48",
        "distance_from_mitra": 2.5,
        "estimated_duration": "15 minutes"
      }
    ],
    "total": 15
  }
}
```

**Notes:**
- Hanya tampilkan jadwal dengan `status = 'pending'`
- Urutkan berdasarkan waktu penjemputan terdekat
- Optional: Hitung jarak dari lokasi mitra saat ini

---

### 2. **GET /api/mitra/pickup-schedules/{id}**
**Fungsi:** Mitra melihat detail jadwal sebelum accept

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/36`

**Headers:**
```
Authorization: Bearer {mitra_token}
Accept: application/json
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule detail retrieved successfully",
  "data": {
    "schedule": {
      "id": 36,
      "user_id": 15,
      "user": {
        "id": 15,
        "name": "Ali",
        "email": "ali@gmail.com",
        "phone": "081234567890",
        "address": "Jl. Sudirman No. 123, Jakarta Pusat",
        "profile_picture": "https://example.com/photo.jpg"
      },
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "latitude": -6.208763,
      "longitude": 106.845599,
      "schedule_day": "rabu",
      "waste_type_scheduled": "B3",
      "scheduled_pickup_at": "2025-11-13 06:00:00",
      "pickup_time_start": "06:00:00",
      "pickup_time_end": "08:00:00",
      "has_additional_waste": false,
      "additional_wastes": null,
      "waste_summary": "B3",
      "notes": "Sampah sudah dipilah. Mohon tepat waktu.",
      "status": "pending",
      "created_at": "2025-11-12 14:12:48",
      "distance_from_mitra": 2.5,
      "estimated_duration": "15 minutes",
      "estimated_weight": 0
    }
  }
}
```

**Notes:**
- Include data user lengkap (nama, telpon, alamat, foto)
- Include koordinat untuk tampil di map
- Hitung estimasi jarak dan waktu tempuh

---

### 3. **POST /api/mitra/pickup-schedules/{id}/accept**
**Fungsi:** Mitra menerima jadwal penjemputan

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
Accept: application/json
```

**Request Body (Optional):**
```json
{
  "estimated_arrival": "2025-11-13 06:15:00",
  "notes": "Dalam perjalanan, ETA 15 menit"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule accepted successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "on_progress",
      "assigned_mitra_id": 8,
      "assigned_at": "2025-11-12 15:30:00",
      "mitra": {
        "id": 8,
        "name": "John Doe",
        "phone": "081987654321",
        "vehicle_type": "Truk",
        "vehicle_plate": "B 1234 XYZ"
      }
    }
  }
}
```

**What Happens Backend:**
1. Update `assigned_mitra_id` = mitra yang login
2. Update `status` = 'on_progress'
3. Set `assigned_at` = now()
4. **KIRIM NOTIFIKASI KE USER**: "Mitra sedang dalam perjalanan"
5. Lock jadwal (tidak bisa di-accept mitra lain)

**Validasi:**
- Jadwal harus status `pending`
- Mitra belum punya jadwal active lain (optional)
- Jadwal belum expired

**Error Response (409 Conflict):**
```json
{
  "success": false,
  "message": "Schedule already accepted by another mitra"
}
```

---

### 4. **POST /api/mitra/pickup-schedules/{id}/start-journey**
**Fungsi:** Mitra mulai perjalanan ke lokasi user

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/start-journey`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "current_latitude": -6.200000,
  "current_longitude": 106.816666,
  "estimated_arrival": "2025-11-13 06:20:00"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Journey started",
  "data": {
    "schedule": {
      "id": 36,
      "status": "on_progress",
      "on_the_way_at": "2025-11-12 15:35:00"
    }
  }
}
```

**What Happens:**
- Set `on_the_way_at` = now()
- **KIRIM NOTIFIKASI KE USER**: "Mitra dalam perjalanan, ETA 15 menit"
- Enable realtime location tracking (optional)

---

### 5. **POST /api/mitra/pickup-schedules/{id}/arrive**
**Fungsi:** Mitra sampai di lokasi user

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/arrive`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "latitude": -6.208763,
  "longitude": 106.845599
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Arrival confirmed",
  "data": {
    "picked_up_at": "2025-11-13 06:15:00"
  }
}
```

**What Happens:**
- Set `picked_up_at` = now()
- **KIRIM NOTIFIKASI KE USER**: "Mitra telah sampai"

---

### 6. **POST /api/mitra/pickup-schedules/{id}/complete**
**Fungsi:** Mitra menyelesaikan penjemputan (upload foto, input berat)

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
```
actual_weights[Organik]    = 3.5
actual_weights[Anorganik]  = 2.0
actual_weights[B3]         = 1.2
notes                      = "Pengambilan selesai tepat waktu"
photos[]                   = file1.jpg
photos[]                   = file2.jpg
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Pickup completed successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "completed",
      "completed_at": "2025-11-13 06:30:00",
      "actual_weights": {
        "Organik": 3.5,
        "Anorganik": 2.0,
        "B3": 1.2
      },
      "total_weight": 6.7,
      "pickup_photos": [
        "https://storage.com/pickup/36/photo1.jpg",
        "https://storage.com/pickup/36/photo2.jpg"
      ],
      "points_earned": 67
    }
  }
}
```

**What Happens Backend:**
1. Update `status` = 'completed'
2. Set `completed_at` = now()
3. Save `actual_weights` (JSON)
4. Calculate `total_weight`
5. Upload photos ke storage
6. **HITUNG POIN USER** (1 kg = 10 poin)
7. **UPDATE points user**
8. **KIRIM NOTIFIKASI KE USER**: "Pengambilan selesai! Anda dapat +67 poin"
9. **UPDATE statistik mitra** (total_collections++)

**Validasi:**
- Jadwal harus status `on_progress`
- Mitra harus yang assigned
- Minimal 1 foto wajib
- Berat harus > 0

---

### 7. **POST /api/mitra/pickup-schedules/{id}/cancel**
**Fungsi:** Mitra membatalkan jadwal (dengan alasan)

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/cancel`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "reason": "User tidak ada di lokasi setelah 3x kontak"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule cancelled",
  "data": {
    "schedule": {
      "id": 36,
      "status": "pending",
      "assigned_mitra_id": null,
      "cancelled_at": "2025-11-13 06:10:00",
      "cancellation_reason": "User tidak ada di lokasi"
    }
  }
}
```

**What Happens:**
- Set `status` = 'pending' (kembali ke available)
- Clear `assigned_mitra_id`
- Set `cancelled_at` dan `cancellation_reason`
- **KIRIM NOTIFIKASI KE USER**: "Mitra membatalkan jadwal dengan alasan: ..."
- Jadwal kembali available untuk mitra lain

---

### 8. **GET /api/mitra/pickup-schedules/my-active**
**Fungsi:** Mitra melihat jadwal yang sedang aktif (on_progress)

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/my-active`

**Headers:**
```
Authorization: Bearer {mitra_token}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 36,
        "user_name": "Ali",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 123",
        "status": "on_progress",
        "assigned_at": "2025-11-13 06:00:00",
        "latitude": -6.208763,
        "longitude": 106.845599
      }
    ]
  }
}
```

---

### 9. **GET /api/mitra/pickup-schedules/history**
**Fungsi:** Riwayat jadwal completed oleh mitra

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/history`

**Query Parameters:**
```
page      = 1
per_page  = 20
date_from = 2025-11-01
date_to   = 2025-11-30
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 35,
        "user_name": "Ahmad",
        "pickup_address": "Jl. Thamrin",
        "completed_at": "2025-11-12 10:30:00",
        "total_weight": 5.5,
        "status": "completed"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total": 45
    },
    "summary": {
      "total_completed": 45,
      "total_weight_collected": 250.5,
      "total_earnings": 450000
    }
  }
}
```

---

### 10. **POST /api/mitra/location/update**
**Fungsi:** Update lokasi realtime mitra (optional, untuk tracking)

**URL:** `POST http://127.0.0.1:8000/api/mitra/location/update`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "latitude": -6.200000,
  "longitude": 106.816666,
  "heading": 270.5,
  "speed": 40.5
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Location updated"
}
```

**Notes:**
- Broadcast ke user yang sedang menunggu
- Simpan ke tabel `mitra_locations` (last 30 minutes)
- Optional feature untuk live tracking

---

## 📱 Notification Events

### Untuk User:

| Event | Trigger | Message |
|-------|---------|---------|
| `mitra_assigned` | Mitra accept jadwal | "Mitra **{nama}** menerima jadwal Anda!" |
| `mitra_on_the_way` | Mitra start journey | "Mitra dalam perjalanan, ETA 15 menit" |
| `mitra_arrived` | Mitra sampai lokasi | "Mitra telah sampai di lokasi" |
| `pickup_completed` | Mitra complete | "Pengambilan selesai! +67 poin" |
| `pickup_cancelled` | Mitra cancel | "Jadwal dibatalkan: {reason}" |

### Untuk Mitra:

| Event | Trigger | Message |
|-------|---------|---------|
| `new_schedule_available` | User buat jadwal | "Jadwal baru tersedia di area Anda" |
| `user_cancelled` | User cancel | "User membatalkan jadwal #{id}" |

---

## 🔔 WebSocket/Pusher Events (Optional tapi Recommended)

### Channel: `user.{user_id}`
```javascript
// Event yang diterima user
{
  "event": "pickup.status_updated",
  "data": {
    "schedule_id": 36,
    "status": "on_progress",
    "mitra": {
      "name": "John Doe",
      "phone": "081987654321",
      "vehicle": "Truk - B 1234 XYZ",
      "current_location": {
        "lat": -6.200000,
        "lng": 106.816666
      },
      "eta": "15 minutes"
    }
  }
}
```

### Channel: `mitra.{mitra_id}`
```javascript
// Event yang diterima mitra
{
  "event": "schedule.new_available",
  "data": {
    "schedule_id": 37,
    "user_name": "Ahmad",
    "pickup_address": "Jl. Sudirman",
    "distance": 2.5,
    "waste_type": "Organik"
  }
}
```

---

## 💾 Laravel Implementation

### Model: MitraPickupController.php

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use App\Events\PickupStatusUpdated;
use App\Notifications\MitraAssigned;

class MitraPickupController extends Controller
{
    /**
     * Get available schedules for mitra
     */
    public function availableSchedules(Request $request)
    {
        $mitra = Auth::user();
        
        $query = PickupSchedule::where('status', 'pending')
                               ->with('user:id,name,phone,address')
                               ->whereNull('assigned_mitra_id');
        
        // Filter by mitra work area (optional)
        if ($mitra->work_area) {
            $query->where('pickup_address', 'LIKE', "%{$mitra->work_area}%");
        }
        
        // Filter by waste type
        if ($request->has('waste_type')) {
            $query->where('waste_type_scheduled', $request->waste_type);
        }
        
        $schedules = $query->orderBy('scheduled_pickup_at', 'asc')
                          ->get();
        
        return response()->json([
            'success' => true,
            'message' => 'Available schedules retrieved',
            'data' => [
                'schedules' => $schedules,
                'total' => $schedules->count()
            ]
        ]);
    }
    
    /**
     * Get schedule detail
     */
    public function showSchedule($id)
    {
        $schedule = PickupSchedule::with('user:id,name,email,phone,address,profile_picture')
                                  ->findOrFail($id);
        
        return response()->json([
            'success' => true,
            'data' => ['schedule' => $schedule]
        ]);
    }
    
    /**
     * Accept schedule
     */
    public function acceptSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('status', 'pending')
                                  ->whereNull('assigned_mitra_id')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $mitra, $request) {
            $schedule->update([
                'assigned_mitra_id' => $mitra->id,
                'status' => 'on_progress',
                'assigned_at' => now(),
            ]);
            
            // Send notification to user
            $schedule->user->notify(new MitraAssigned($schedule, $mitra));
            
            // Broadcast event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule accepted successfully',
            'data' => [
                'schedule' => $schedule->load('mitra')
            ]
        ]);
    }
    
    /**
     * Start journey to pickup location
     */
    public function startJourney(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        $schedule->update([
            'on_the_way_at' => now()
        ]);
        
        // Notify user
        // broadcast(new MitraOnTheWay($schedule));
        
        return response()->json([
            'success' => true,
            'message' => 'Journey started',
            'data' => ['schedule' => $schedule]
        ]);
    }
    
    /**
     * Confirm arrival at pickup location
     */
    public function arrive(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->firstOrFail();
        
        $schedule->update([
            'picked_up_at' => now()
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Arrival confirmed'
        ]);
    }
    
    /**
     * Complete pickup with photos and weight
     */
    public function completePickup(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'actual_weights' => 'required|array',
            'actual_weights.*' => 'numeric|min:0',
            'photos' => 'required|array|min:1',
            'photos.*' => 'image|max:5120',
            'notes' => 'nullable|string'
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $request, $mitra) {
            // Calculate total weight
            $totalWeight = array_sum($request->actual_weights);
            
            // Upload photos
            $photoUrls = [];
            foreach ($request->file('photos') as $photo) {
                $path = $photo->store("pickups/{$schedule->id}", 'public');
                $photoUrls[] = Storage::url($path);
            }
            
            // Update schedule
            $schedule->update([
                'status' => 'completed',
                'completed_at' => now(),
                'actual_weights' => $request->actual_weights,
                'total_weight' => $totalWeight,
                'pickup_photos' => $photoUrls,
                'notes' => $request->notes
            ]);
            
            // Calculate and add points to user (1 kg = 10 points)
            $points = (int)($totalWeight * 10);
            $schedule->user->increment('points', $points);
            
            // Update mitra statistics
            $mitra->increment('total_collections');
            
            // Notify user
            // $schedule->user->notify(new PickupCompleted($schedule, $points));
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Pickup completed successfully',
            'data' => [
                'schedule' => $schedule,
                'points_earned' => (int)($schedule->total_weight * 10)
            ]
        ]);
    }
    
    /**
     * Cancel assigned schedule
     */
    public function cancelSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'reason' => 'required|string'
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->whereIn('status', ['on_progress'])
                                  ->firstOrFail();
        
        $schedule->update([
            'status' => 'pending',
            'assigned_mitra_id' => null,
            'assigned_at' => null,
            'on_the_way_at' => null,
            'cancelled_at' => now(),
            'cancellation_reason' => $request->reason
        ]);
        
        // Notify user
        // $schedule->user->notify(new PickupCancelled($schedule));
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule cancelled and returned to available pool'
        ]);
    }
    
    /**
     * Get mitra's active schedules
     */
    public function myActiveSchedules()
    {
        $mitra = Auth::user();
        
        $schedules = PickupSchedule::where('assigned_mitra_id', $mitra->id)
                                   ->where('status', 'on_progress')
                                   ->with('user:id,name,phone,address')
                                   ->get();
        
        return response()->json([
            'success' => true,
            'data' => ['schedules' => $schedules]
        ]);
    }
    
    /**
     * Get mitra's completed schedules history
     */
    public function history(Request $request)
    {
        $mitra = Auth::user();
        
        $query = PickupSchedule::where('assigned_mitra_id', $mitra->id)
                               ->where('status', 'completed');
        
        if ($request->has('date_from')) {
            $query->whereDate('completed_at', '>=', $request->date_from);
        }
        
        if ($request->has('date_to')) {
            $query->whereDate('completed_at', '<=', $request->date_to);
        }
        
        $schedules = $query->orderBy('completed_at', 'desc')
                          ->paginate($request->input('per_page', 20));
        
        // Calculate summary
        $summary = [
            'total_completed' => PickupSchedule::where('assigned_mitra_id', $mitra->id)
                                               ->where('status', 'completed')
                                               ->count(),
            'total_weight_collected' => PickupSchedule::where('assigned_mitra_id', $mitra->id)
                                                       ->where('status', 'completed')
                                                       ->sum('total_weight'),
        ];
        
        return response()->json([
            'success' => true,
            'data' => [
                'schedules' => $schedules->items(),
                'pagination' => [
                    'current_page' => $schedules->currentPage(),
                    'total' => $schedules->total()
                ],
                'summary' => $summary
            ]
        ]);
    }
}
```

### Routes (routes/api.php)

```php
// Mitra routes
Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    
    // Pickup schedules
    Route::prefix('pickup-schedules')->group(function () {
        Route::get('/available', [MitraPickupController::class, 'availableSchedules']);
        Route::get('/my-active', [MitraPickupController::class, 'myActiveSchedules']);
        Route::get('/history', [MitraPickupController::class, 'history']);
        Route::get('/{id}', [MitraPickupController::class, 'showSchedule']);
        
        Route::post('/{id}/accept', [MitraPickupController::class, 'acceptSchedule']);
        Route::post('/{id}/start-journey', [MitraPickupController::class, 'startJourney']);
        Route::post('/{id}/arrive', [MitraPickupController::class, 'arrive']);
        Route::post('/{id}/complete', [MitraPickupController::class, 'completePickup']);
        Route::post('/{id}/cancel', [MitraPickupController::class, 'cancelSchedule']);
    });
    
    // Location tracking (optional)
    Route::post('/location/update', [MitraLocationController::class, 'update']);
});
```

---

## ✅ Testing Checklist

### Backend:
- [ ] Mitra bisa lihat list jadwal pending
- [ ] Mitra bisa lihat detail jadwal (nama, telpon, alamat, map)
- [ ] Mitra bisa accept jadwal → status jadi on_progress
- [ ] User otomatis terima notifikasi saat mitra accept
- [ ] Status di app user otomatis update (pending → on_progress)
- [ ] Mitra bisa complete dengan upload foto minimal 1
- [ ] Points user otomatis bertambah setelah complete
- [ ] Mitra bisa cancel jadwal → kembali ke pending
- [ ] Mitra tidak bisa accept jadwal yang sudah di-accept mitra lain
- [ ] History mitra menampilkan semua completed schedules

### Flutter (Mitra App):
- [ ] Tab "Jadwal Tersedia" tampilkan list pending
- [ ] Tap jadwal → Detail page dengan map, nama user, telpon, alamat
- [ ] Button "Terima Jadwal" berfungsi
- [ ] Setelah accept → Pindah ke "Jadwal Aktif"
- [ ] Button "Mulai Perjalanan" update status
- [ ] Button "Sampai di Lokasi" aktif
- [ ] Form complete: input berat per jenis sampah
- [ ] Upload foto bukti pengambilan (min 1, max 3)
- [ ] Button "Selesai" submit data
- [ ] Riwayat tampilkan completed schedules

### Flutter (User App):
- [ ] Status berubah PENDING → ON_PROGRESS realtime
- [ ] Notifikasi muncul saat mitra accept
- [ ] Bisa lihat info mitra (nama, telpon, kendaraan)
- [ ] Points bertambah setelah mitra complete
- [ ] Bisa lihat foto bukti pengambilan

---

## 🚀 Priority Implementation

### Phase 1: Core Feature (URGENT)
1. ✅ API available schedules untuk mitra
2. ✅ API accept schedule
3. ✅ API complete pickup (dengan foto dan berat)
4. ✅ Auto update points user
5. ✅ Notifikasi status change

### Phase 2: Enhancement
6. ⭕ Realtime location tracking
7. ⭕ ETA calculation
8. ⭕ WebSocket/Pusher integration
9. ⭕ Rating system

---

**Status:** 🔴 URGENT - Core Feature  
**Estimated Backend Work:** 2-3 hari  
**Dependencies:** Notification system (sudah ready)

*Dokumentasi dibuat: 12 November 2025*
# 🚀 Quick Reference: Mitra Pickup API

> **TL;DR:** User buat jadwal → Mitra accept → Status auto-update ke User → Mitra complete → User dapat poin

---

## 📌 API Endpoints Summary

| Method | Endpoint | Fungsi | Priority |
|--------|----------|--------|----------|
| **GET** | `/api/mitra/pickup-schedules/available` | List jadwal PENDING | 🔴 HIGH |
| **GET** | `/api/mitra/pickup-schedules/{id}` | Detail jadwal (nama, telpon, alamat) | 🔴 HIGH |
| **POST** | `/api/mitra/pickup-schedules/{id}/accept` | Mitra terima jadwal | 🔴 HIGH |
| **POST** | `/api/mitra/pickup-schedules/{id}/complete` | Upload foto + berat sampah | 🔴 HIGH |
| **POST** | `/api/mitra/pickup-schedules/{id}/cancel` | Batalkan jadwal | 🟡 MEDIUM |
| **GET** | `/api/mitra/pickup-schedules/my-active` | Jadwal aktif mitra | 🟡 MEDIUM |
| **GET** | `/api/mitra/pickup-schedules/history` | Riwayat completed | 🟢 LOW |

---

## 🗄️ Database Changes Needed

```sql
-- ALTER TABLE pickup_schedules
ALTER TABLE pickup_schedules 
ADD COLUMN assigned_mitra_id BIGINT UNSIGNED NULL,
ADD COLUMN assigned_at DATETIME NULL,
ADD COLUMN on_the_way_at DATETIME NULL,
ADD COLUMN picked_up_at DATETIME NULL,
ADD COLUMN completed_at DATETIME NULL,
ADD COLUMN actual_weights JSON NULL,
ADD COLUMN total_weight DECIMAL(8,2) NULL,
ADD COLUMN pickup_photos JSON NULL,
ADD COLUMN cancelled_at DATETIME NULL,
ADD COLUMN cancellation_reason TEXT NULL,
ADD FOREIGN KEY (assigned_mitra_id) REFERENCES users(id) ON DELETE SET NULL,
ADD INDEX idx_assigned_mitra (assigned_mitra_id),
ADD INDEX idx_status_mitra (status, assigned_mitra_id);
```

---

## 📋 Status Flow

```
[USER creates schedule]
       ↓
   PENDING ← (visible to all mitra)
       ↓
[MITRA accepts]
       ↓
 ON_PROGRESS ← (auto-update ke user, notifikasi terkirim)
       ↓
[MITRA completes with photo + weight]
       ↓
  COMPLETED ← (user dapat poin, notifikasi)
```

---

## 🔥 Critical Implementation Points

### 1. Accept Schedule - `POST /api/mitra/pickup-schedules/{id}/accept`

**What happens:**
```php
DB::transaction(function() {
    // 1. Update schedule
    $schedule->update([
        'assigned_mitra_id' => $mitra->id,
        'status' => 'on_progress',
        'assigned_at' => now()
    ]);
    
    // 2. Send notification to USER
    $schedule->user->notify(new MitraAssigned($schedule, $mitra));
    
    // 3. Broadcast realtime (optional)
    broadcast(new PickupStatusUpdated($schedule));
});
```

**Validasi:**
- Status harus `pending`
- `assigned_mitra_id` harus NULL
- Prevent double-accept (race condition)

---

### 2. Complete Pickup - `POST /api/mitra/pickup-schedules/{id}/complete`

**Request (multipart/form-data):**
```
actual_weights[Organik]    = 3.5
actual_weights[Anorganik]  = 2.0
actual_weights[B3]         = 1.2
photos[]                   = file1.jpg
photos[]                   = file2.jpg
notes                      = "Selesai tepat waktu"
```

**What happens:**
```php
DB::transaction(function() {
    // 1. Calculate total weight
    $totalWeight = array_sum($request->actual_weights);
    
    // 2. Upload photos
    $photoUrls = [];
    foreach ($request->file('photos') as $photo) {
        $path = $photo->store("pickups/{$schedule->id}", 'public');
        $photoUrls[] = Storage::url($path);
    }
    
    // 3. Update schedule
    $schedule->update([
        'status' => 'completed',
        'completed_at' => now(),
        'actual_weights' => $request->actual_weights,
        'total_weight' => $totalWeight,
        'pickup_photos' => $photoUrls
    ]);
    
    // 4. Add points to user (1 kg = 10 points)
    $points = (int)($totalWeight * 10);
    $schedule->user->increment('points', $points);
    
    // 5. Notify user
    $schedule->user->notify(new PickupCompleted($schedule, $points));
    
    // 6. Update mitra stats
    $mitra->increment('total_collections');
});
```

**Validasi:**
- Status harus `on_progress`
- Mitra harus yang assigned
- Minimal 1 foto wajib
- Berat harus > 0

---

## 📱 Response Format Examples

### Available Schedules
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 36,
        "user_name": "Ali",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 123, Jakarta",
        "latitude": -6.208763,
        "longitude": 106.845599,
        "waste_type_scheduled": "B3",
        "scheduled_pickup_at": "2025-11-13 06:00:00",
        "status": "pending"
      }
    ]
  }
}
```

### Schedule Detail
```json
{
  "success": true,
  "data": {
    "schedule": {
      "id": 36,
      "user": {
        "id": 15,
        "name": "Ali",
        "phone": "081234567890",
        "address": "Jl. Sudirman No. 123, Jakarta Pusat"
      },
      "pickup_address": "Jl. Sudirman No. 123",
      "latitude": -6.208763,
      "longitude": 106.845599,
      "waste_type_scheduled": "B3",
      "notes": "Sampah sudah dipilah"
    }
  }
}
```

---

## 🔔 Notification Events

### Send to User:

```php
// When mitra accepts
$user->notify(new MitraAssigned($schedule, $mitra));
// Message: "Mitra John Doe menerima jadwal Anda!"

// When completed
$user->notify(new PickupCompleted($schedule, $points));
// Message: "Pengambilan selesai! Anda mendapat +67 poin"

// When cancelled by mitra
$user->notify(new PickupCancelled($schedule, $reason));
// Message: "Jadwal dibatalkan: {reason}"
```

### Send to Mitra:

```php
// When user creates new schedule (optional)
$mitras->each->notify(new NewScheduleAvailable($schedule));
// Message: "Jadwal baru tersedia di area Anda"
```

---

## 🧪 Testing Commands

```bash
# 1. Get available schedules (as Mitra)
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Accept: application/json"

# 2. Get schedule detail
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/36" \
  -H "Authorization: Bearer {mitra_token}"

# 3. Accept schedule
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept" \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json" \
  -d '{}'

# 4. Complete pickup (with photos)
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete" \
  -H "Authorization: Bearer {mitra_token}" \
  -F "actual_weights[Organik]=3.5" \
  -F "actual_weights[Anorganik]=2.0" \
  -F "actual_weights[B3]=1.2" \
  -F "photos[]=@photo1.jpg" \
  -F "photos[]=@photo2.jpg" \
  -F "notes=Selesai"

# 5. Check user's points after completion (as User)
curl -X GET "http://127.0.0.1:8000/api/user/profile" \
  -H "Authorization: Bearer {user_token}"
```

---

## ✅ Quick Checklist

**Backend Team:**
- [ ] Run migration untuk tambah kolom di `pickup_schedules`
- [ ] Buat `MitraPickupController.php`
- [ ] Add routes di `routes/api.php`
- [ ] Implement notification classes
- [ ] Test accept schedule
- [ ] Test complete pickup (dengan foto upload)
- [ ] Verify user points bertambah otomatis
- [ ] Test cancel schedule

**Flutter Team (Mitra App):**
- [ ] Screen: Jadwal Tersedia (list pending)
- [ ] Screen: Detail Jadwal (map, user info)
- [ ] Screen: Jadwal Aktif (my on_progress)
- [ ] Form: Complete Pickup (input berat, upload foto)
- [ ] Screen: Riwayat (history completed)

**Flutter Team (User App):**
- [ ] Auto-refresh status saat mitra accept
- [ ] Notifikasi saat status berubah
- [ ] Display mitra info (nama, telpon, kendaraan)
- [ ] Display points yang bertambah

---

## 🎯 Priority Order

**Week 1 (URGENT):**
1. Database migration
2. API available schedules
3. API accept schedule
4. API complete pickup
5. Auto-update points

**Week 2:**
6. Notification system integration
7. Cancel feature
8. History API

**Week 3 (Optional):**
9. Realtime location tracking
10. ETA calculation
11. Rating system

---

**Dokumentasi lengkap:** `docs/MITRA_PICKUP_SYSTEM.md`  
**Status:** 🔴 URGENT - Core Feature  
**Contact:** Flutter Team ready to integrate
# 🔔 Notification Implementation Code

> **File ini berisi contoh kode lengkap untuk notification system**

---

## 📁 File Structure

```
app/
├── Notifications/
│   ├── MitraAssigned.php
│   ├── PickupCompleted.php
│   └── PickupCancelled.php
├── Events/
│   └── PickupStatusUpdated.php
└── Http/Controllers/Api/Mitra/
    └── MitraPickupController.php
```

---

## 1️⃣ Notification: MitraAssigned.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\DatabaseMessage;
use App\Models\PickupSchedule;
use App\Models\User;

class MitraAssigned extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $mitra;

    public function __construct(PickupSchedule $schedule, User $mitra)
    {
        $this->schedule = $schedule;
        $this->mitra = $mitra;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'mitra_assigned',
            'title' => 'Mitra Menerima Jadwal Anda!',
            'message' => "Mitra {$this->mitra->name} menerima jadwal pengambilan Anda.",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'on_progress',
                'mitra' => [
                    'id' => $this->mitra->id,
                    'name' => $this->mitra->name,
                    'phone' => $this->mitra->phone,
                    'vehicle_type' => $this->mitra->vehicle_type,
                    'vehicle_plate' => $this->mitra->vehicle_plate,
                ],
                'scheduled_pickup_at' => $this->schedule->scheduled_pickup_at,
            ],
            'action_url' => "/activity/schedule/{$this->schedule->id}",
            'icon' => 'ic_truck.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }

    /**
     * Get the broadcastable representation of the notification.
     */
    public function toBroadcast($notifiable)
    {
        return new DatabaseMessage([
            'type' => 'pickup_status',
            'action' => 'mitra_assigned',
            'title' => 'Mitra Menerima Jadwal Anda!',
            'message' => "Mitra {$this->mitra->name} menerima jadwal pengambilan Anda.",
            'schedule_id' => $this->schedule->id,
        ]);
    }
}
```

---

## 2️⃣ Notification: PickupCompleted.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\DatabaseMessage;
use App\Models\PickupSchedule;

class PickupCompleted extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $points;

    public function __construct(PickupSchedule $schedule, int $points)
    {
        $this->schedule = $schedule;
        $this->points = $points;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'pickup_completed',
            'title' => 'Pengambilan Selesai!',
            'message' => "Pengambilan sampah selesai. Anda mendapat +{$this->points} poin!",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'completed',
                'total_weight' => $this->schedule->total_weight,
                'actual_weights' => $this->schedule->actual_weights,
                'points_earned' => $this->points,
                'pickup_photos' => $this->schedule->pickup_photos,
                'completed_at' => $this->schedule->completed_at,
                'mitra' => [
                    'id' => $this->schedule->mitra->id,
                    'name' => $this->schedule->mitra->name,
                ],
            ],
            'action_url' => "/activity/schedule/{$this->schedule->id}",
            'icon' => 'ic_check.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }

    /**
     * Get the broadcastable representation of the notification.
     */
    public function toBroadcast($notifiable)
    {
        return new DatabaseMessage([
            'type' => 'pickup_status',
            'action' => 'pickup_completed',
            'title' => 'Pengambilan Selesai!',
            'message' => "Anda mendapat +{$this->points} poin!",
            'schedule_id' => $this->schedule->id,
            'points_earned' => $this->points,
        ]);
    }
}
```

---

## 3️⃣ Notification: PickupCancelled.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use App\Models\PickupSchedule;

class PickupCancelled extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $reason;

    public function __construct(PickupSchedule $schedule, string $reason)
    {
        $this->schedule = $schedule;
        $this->reason = $reason;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'pickup_cancelled',
            'title' => 'Jadwal Dibatalkan',
            'message' => "Mitra membatalkan jadwal pengambilan. Alasan: {$this->reason}",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'pending',
                'cancellation_reason' => $this->reason,
                'cancelled_at' => now()->toISOString(),
            ],
            'action_url' => "/activity",
            'icon' => 'ic_notification.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }
}
```

---

## 4️⃣ Event: PickupStatusUpdated.php (for Realtime Broadcasting)

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\PickupSchedule;

class PickupStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $schedule;

    /**
     * Create a new event instance.
     */
    public function __construct(PickupSchedule $schedule)
    {
        $this->schedule = $schedule->load('mitra', 'user');
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->schedule->user_id);
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith()
    {
        return [
            'schedule_id' => $this->schedule->id,
            'status' => $this->schedule->status,
            'mitra' => $this->schedule->mitra ? [
                'id' => $this->schedule->mitra->id,
                'name' => $this->schedule->mitra->name,
                'phone' => $this->schedule->mitra->phone,
                'vehicle_type' => $this->schedule->mitra->vehicle_type ?? 'Truk',
                'vehicle_plate' => $this->schedule->mitra->vehicle_plate ?? '-',
            ] : null,
            'updated_at' => $this->schedule->updated_at->toISOString(),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs()
    {
        return 'pickup.status_updated';
    }
}
```

---

## 5️⃣ Usage dalam Controller

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Events\PickupStatusUpdated;
use App\Notifications\MitraAssigned;
use App\Notifications\PickupCompleted;
use App\Notifications\PickupCancelled;

class MitraPickupController extends Controller
{
    /**
     * Accept schedule
     */
    public function acceptSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('status', 'pending')
                                  ->whereNull('assigned_mitra_id')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $mitra) {
            // 1. Update schedule
            $schedule->update([
                'assigned_mitra_id' => $mitra->id,
                'status' => 'on_progress',
                'assigned_at' => now(),
            ]);
            
            // 2. Send notification to user
            $schedule->user->notify(new MitraAssigned($schedule, $mitra));
            
            // 3. Broadcast realtime event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule accepted successfully',
            'data' => [
                'schedule' => $schedule->load('mitra')
            ]
        ]);
    }
    
    /**
     * Complete pickup
     */
    public function completePickup(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'actual_weights' => 'required|array',
            'actual_weights.*' => 'numeric|min:0',
            'photos' => 'required|array|min:1',
            'photos.*' => 'image|max:5120',
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $request, $mitra) {
            // 1. Calculate total weight
            $totalWeight = array_sum($request->actual_weights);
            
            // 2. Upload photos
            $photoUrls = [];
            foreach ($request->file('photos') as $photo) {
                $path = $photo->store("pickups/{$schedule->id}", 'public');
                $photoUrls[] = \Storage::url($path);
            }
            
            // 3. Update schedule
            $schedule->update([
                'status' => 'completed',
                'completed_at' => now(),
                'actual_weights' => $request->actual_weights,
                'total_weight' => $totalWeight,
                'pickup_photos' => $photoUrls,
            ]);
            
            // 4. Add points to user (1 kg = 10 points)
            $points = (int)($totalWeight * 10);
            $schedule->user->increment('points', $points);
            
            // 5. Send notification to user
            $schedule->user->notify(new PickupCompleted($schedule, $points));
            
            // 6. Update mitra stats
            $mitra->increment('total_collections');
            
            // 7. Broadcast realtime event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Pickup completed successfully',
            'data' => [
                'schedule' => $schedule,
                'points_earned' => (int)($schedule->total_weight * 10)
            ]
        ]);
    }
    
    /**
     * Cancel schedule
     */
    public function cancelSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'reason' => 'required|string'
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $request, $mitra) {
            // 1. Update schedule back to pending
            $schedule->update([
                'status' => 'pending',
                'assigned_mitra_id' => null,
                'assigned_at' => null,
                'on_the_way_at' => null,
                'cancelled_at' => now(),
                'cancellation_reason' => $request->reason
            ]);
            
            // 2. Send notification to user
            $schedule->user->notify(new PickupCancelled($schedule, $request->reason));
            
            // 3. Broadcast realtime event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule cancelled and returned to available pool'
        ]);
    }
}
```

---

## 6️⃣ Broadcasting Configuration

### config/broadcasting.php

```php
'connections' => [
    
    'pusher' => [
        'driver' => 'pusher',
        'key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'encrypted' => true,
            'host' => env('PUSHER_HOST', 'api-'.env('PUSHER_APP_CLUSTER', 'mt1').'.pusher.com'),
            'port' => env('PUSHER_PORT', 443),
            'scheme' => env('PUSHER_SCHEME', 'https'),
        ],
    ],

],
```

### .env

```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_app_key
PUSHER_APP_SECRET=your_app_secret
PUSHER_APP_CLUSTER=mt1
```

---

## 7️⃣ Routes Configuration

### routes/channels.php

```php
<?php

use Illuminate\Support\Facades\Broadcast;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
*/

// Private channel for user
Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});

// Private channel for mitra
Broadcast::channel('mitra.{mitraId}', function ($user, $mitraId) {
    return (int) $user->id === (int) $mitraId && $user->role === 'mitra';
});
```

### routes/api.php

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Mitra\MitraPickupController;

// Mitra routes
Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    
    // Pickup schedules
    Route::prefix('pickup-schedules')->group(function () {
        Route::get('/available', [MitraPickupController::class, 'availableSchedules']);
        Route::get('/my-active', [MitraPickupController::class, 'myActiveSchedules']);
        Route::get('/history', [MitraPickupController::class, 'history']);
        Route::get('/{id}', [MitraPickupController::class, 'showSchedule']);
        
        Route::post('/{id}/accept', [MitraPickupController::class, 'acceptSchedule']);
        Route::post('/{id}/start-journey', [MitraPickupController::class, 'startJourney']);
        Route::post('/{id}/arrive', [MitraPickupController::class, 'arrive']);
        Route::post('/{id}/complete', [MitraPickupController::class, 'completePickup']);
        Route::post('/{id}/cancel', [MitraPickupController::class, 'cancelSchedule']);
    });
});
```

---

## 8️⃣ Database Migration

### database/migrations/xxxx_add_mitra_fields_to_pickup_schedules.php

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            // Mitra assignment
            $table->unsignedBigInteger('assigned_mitra_id')->nullable()->after('user_id');
            $table->timestamp('assigned_at')->nullable()->after('assigned_mitra_id');
            
            // Tracking timestamps
            $table->timestamp('on_the_way_at')->nullable()->after('assigned_at');
            $table->timestamp('picked_up_at')->nullable()->after('on_the_way_at');
            $table->timestamp('completed_at')->nullable()->after('picked_up_at');
            
            // Completion data
            $table->json('actual_weights')->nullable()->after('completed_at');
            $table->decimal('total_weight', 8, 2)->nullable()->after('actual_weights');
            $table->json('pickup_photos')->nullable()->after('total_weight');
            
            // Cancellation
            $table->timestamp('cancelled_at')->nullable()->after('pickup_photos');
            $table->text('cancellation_reason')->nullable()->after('cancelled_at');
            
            // Foreign key
            $table->foreign('assigned_mitra_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('set null');
            
            // Indexes
            $table->index('assigned_mitra_id');
            $table->index(['status', 'assigned_mitra_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            $table->dropForeign(['assigned_mitra_id']);
            $table->dropIndex(['assigned_mitra_id']);
            $table->dropIndex(['status', 'assigned_mitra_id']);
            
            $table->dropColumn([
                'assigned_mitra_id',
                'assigned_at',
                'on_the_way_at',
                'picked_up_at',
                'completed_at',
                'actual_weights',
                'total_weight',
                'pickup_photos',
                'cancelled_at',
                'cancellation_reason'
            ]);
        });
    }
};
```

---

## 9️⃣ Model Relationships

### app/Models/PickupSchedule.php

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PickupSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'assigned_mitra_id',
        'pickup_address',
        'latitude',
        'longitude',
        'schedule_day',
        'waste_type_scheduled',
        'scheduled_pickup_at',
        'pickup_time_start',
        'pickup_time_end',
        'has_additional_waste',
        'additional_wastes',
        'waste_summary',
        'notes',
        'status',
        'assigned_at',
        'on_the_way_at',
        'picked_up_at',
        'completed_at',
        'actual_weights',
        'total_weight',
        'pickup_photos',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected $casts = [
        'additional_wastes' => 'array',
        'actual_weights' => 'array',
        'pickup_photos' => 'array',
        'scheduled_pickup_at' => 'datetime',
        'assigned_at' => 'datetime',
        'on_the_way_at' => 'datetime',
        'picked_up_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'has_additional_waste' => 'boolean',
        'total_weight' => 'float',
    ];

    /**
     * Get the user who created the schedule
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the mitra assigned to the schedule
     */
    public function mitra()
    {
        return $this->belongsTo(User::class, 'assigned_mitra_id');
    }
}
```

### app/Models/User.php (tambahan)

```php
/**
 * Get pickup schedules created by this user
 */
public function pickupSchedules()
{
    return $this->hasMany(PickupSchedule::class, 'user_id');
}

/**
 * Get pickup schedules assigned to this mitra
 */
public function assignedSchedules()
{
    return $this->hasMany(PickupSchedule::class, 'assigned_mitra_id');
}
```

---

## 🧪 Testing Examples

### Test Accept Schedule

```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept" \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Schedule accepted successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "on_progress",
      "assigned_mitra_id": 8,
      "assigned_at": "2025-11-12 15:30:00"
    }
  }
}
```

**Expected Side Effects:**
1. Database updated
2. Notification created in `notifications` table
3. User receives notification (check `/api/notifications`)
4. Realtime event broadcasted (check Pusher dashboard)

### Test Complete Pickup

```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete" \
  -H "Authorization: Bearer {mitra_token}" \
  -F "actual_weights[Organik]=3.5" \
  -F "actual_weights[Anorganik]=2.0" \
  -F "actual_weights[B3]=1.2" \
  -F "photos[]=@photo1.jpg" \
  -F "photos[]=@photo2.jpg" \
  -F "notes=Selesai tepat waktu"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Pickup completed successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "completed",
      "total_weight": 6.7,
      "pickup_photos": [
        "http://localhost/storage/pickups/36/photo1.jpg",
        "http://localhost/storage/pickups/36/photo2.jpg"
      ]
    },
    "points_earned": 67
  }
}
```

**Verify User Points:**
```bash
curl -X GET "http://127.0.0.1:8000/api/user/profile" \
  -H "Authorization: Bearer {user_token}"
```

Should show `points` increased by 67.

---

## ✅ Implementation Checklist

**Backend:**
- [ ] Run migration untuk tambah kolom
- [ ] Buat notification classes (3 files)
- [ ] Buat event class untuk broadcasting
- [ ] Implement controller methods
- [ ] Add routes
- [ ] Test accept schedule
- [ ] Test complete pickup
- [ ] Test cancel schedule
- [ ] Verify notifications sent
- [ ] Verify points auto-increment
- [ ] Test realtime broadcasting (optional)

**Frontend (Flutter):**
- [ ] Handle notification when status changes
- [ ] Update UI when schedule status changes
- [ ] Display mitra info in user app
- [ ] Implement mitra app screens
- [ ] Test end-to-end flow

---

**Status:** Ready to implement  
**Priority:** 🔴 URGENT - Core Feature
# 📊 Visual Flow: User-Mitra Pickup System

## 🔄 Complete User Journey

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SIDE                                │
└─────────────────────────────────────────────────────────────────┘

[User membuka app]
       ↓
[Tap FAB "+" button]
       ↓
[Form: Pilih jenis sampah, jadwal, alamat]
       ↓
[Submit → POST /api/pickup-schedules]
       ↓
[Status: PENDING ⏳]
       │
       │ (Menunggu mitra...)
       │
       ↓
[🔔 Notifikasi: "Mitra John Doe menerima jadwal Anda!"]
       ↓
[Status auto-update: ON_PROGRESS 🚛]
       │
       │ (Display info mitra: nama, telpon, kendaraan)
       │ (Optional: Live tracking di map)
       │
       ↓
[🔔 Notifikasi: "Mitra telah sampai"]
       ↓
[Mitra mengambil sampah...]
       ↓
[🔔 Notifikasi: "Pengambilan selesai! +67 poin"]
       ↓
[Status: COMPLETED ✅]
       ↓
[Points bertambah: 150 → 217 poin]
       ↓
[Bisa lihat:
 - Foto bukti pengambilan
 - Berat sampah per jenis
 - Rating mitra (optional)]


┌─────────────────────────────────────────────────────────────────┐
│                       MITRA SIDE                                │
└─────────────────────────────────────────────────────────────────┘

[Mitra membuka app]
       ↓
[Tab "Jadwal Tersedia"]
       ↓
[GET /api/mitra/pickup-schedules/available]
       ↓
[Melihat list jadwal PENDING:]
  • Ali - Jl. Sudirman (2.5 km)
  • Ahmad - Jl. Thamrin (3.1 km)
  • Budi - Jl. Gatot Subroto (1.8 km)
       ↓
[Tap salah satu jadwal]
       ↓
[GET /api/mitra/pickup-schedules/36]
       ↓
[Detail Page tampilkan:
 ┌─────────────────────────────────┐
 │ 📍 Map dengan pin lokasi        │
 │                                 │
 │ 👤 Ali                          │
 │ 📱 081234567890                 │
 │ 🏠 Jl. Sudirman No. 123         │
 │    Jakarta Pusat                │
 │                                 │
 │ 🗑️  Jenis: B3                   │
 │ ⏰ Jadwal: Rabu, 06:00-08:00    │
 │ 📝 Catatan: Sampah sudah dipilah│
 │                                 │
 │ [Button: TERIMA JADWAL]         │
 └─────────────────────────────────┘
       ↓
[Mitra tap "Terima Jadwal"]
       ↓
[POST /api/mitra/pickup-schedules/36/accept]
       ↓
[Backend:
 1. Update status → ON_PROGRESS
 2. Set assigned_mitra_id
 3. Send notification ke User
 4. Broadcast realtime event]
       ↓
[Jadwal pindah ke tab "Jadwal Aktif"]
       ↓
[Button "Mulai Perjalanan" muncul]
       ↓
[Tap "Mulai Perjalanan"]
       ↓
[POST /api/mitra/pickup-schedules/36/start-journey]
       ↓
[Navigation ke lokasi user (Google Maps integration)]
       ↓
[... Perjalanan ...]
       ↓
[Sampai di lokasi]
       ↓
[Tap "Sampai di Lokasi"]
       ↓
[POST /api/mitra/pickup-schedules/36/arrive]
       ↓
[Ambil sampah dari user...]
       ↓
[Tap "Selesai"]
       ↓
[Form Complete Pickup:
 ┌─────────────────────────────────┐
 │ Input Berat Sampah:             │
 │ • Organik: [3.5] kg             │
 │ • Anorganik: [2.0] kg           │
 │ • B3: [1.2] kg                  │
 │ ═══════════════════════           │
 │ Total: 6.7 kg                   │
 │                                 │
 │ Upload Foto Bukti (min 1):      │
 │ [📷 Photo 1] [📷 Photo 2]       │
 │                                 │
 │ Catatan:                        │
 │ [Selesai tepat waktu]           │
 │                                 │
 │ [Button: KONFIRMASI SELESAI]    │
 └─────────────────────────────────┘
       ↓
[POST /api/mitra/pickup-schedules/36/complete]
       ↓
[Backend:
 1. Upload photos ke storage
 2. Update status → COMPLETED
 3. Calculate points: 6.7 kg × 10 = 67 poin
 4. User.points += 67
 5. Mitra.total_collections += 1
 6. Send notification ke User
 7. Broadcast event]
       ↓
[Success: "Pengambilan berhasil dicatat!"]
       ↓
[Jadwal pindah ke "Riwayat"]
       ↓
[Mitra bisa ambil jadwal baru]
```

---

## 🗄️ Database State Changes

```
┌─────────────────────────────────────────────────────────────────┐
│ TABEL: pickup_schedules (id: 36)                                │
└─────────────────────────────────────────────────────────────────┘

STATE 1: User baru buat jadwal
─────────────────────────────────────
id: 36
user_id: 15
status: "pending"
assigned_mitra_id: NULL
scheduled_pickup_at: "2025-11-13 06:00:00"
waste_type_scheduled: "B3"
notes: "Sampah sudah dipilah"


STATE 2: Mitra accept jadwal
─────────────────────────────────────
id: 36
user_id: 15
status: "on_progress"  ← CHANGED
assigned_mitra_id: 8   ← CHANGED
assigned_at: "2025-11-12 15:30:00"  ← NEW
scheduled_pickup_at: "2025-11-13 06:00:00"
waste_type_scheduled: "B3"
notes: "Sampah sudah dipilah"


STATE 3: Mitra start journey
─────────────────────────────────────
id: 36
user_id: 15
status: "on_progress"
assigned_mitra_id: 8
assigned_at: "2025-11-12 15:30:00"
on_the_way_at: "2025-11-13 05:45:00"  ← NEW
scheduled_pickup_at: "2025-11-13 06:00:00"


STATE 4: Mitra arrive
─────────────────────────────────────
id: 36
user_id: 15
status: "on_progress"
assigned_mitra_id: 8
assigned_at: "2025-11-12 15:30:00"
on_the_way_at: "2025-11-13 05:45:00"
picked_up_at: "2025-11-13 06:05:00"  ← NEW


STATE 5: Mitra complete
─────────────────────────────────────
id: 36
user_id: 15
status: "completed"  ← CHANGED
assigned_mitra_id: 8
assigned_at: "2025-11-12 15:30:00"
on_the_way_at: "2025-11-13 05:45:00"
picked_up_at: "2025-11-13 06:05:00"
completed_at: "2025-11-13 06:20:00"  ← NEW
actual_weights: {"Organik": 3.5, "Anorganik": 2.0, "B3": 1.2}  ← NEW
total_weight: 6.7  ← NEW
pickup_photos: ["url1.jpg", "url2.jpg"]  ← NEW


┌─────────────────────────────────────────────────────────────────┐
│ TABEL: users (id: 15 - User Ali)                                │
└─────────────────────────────────────────────────────────────────┘

BEFORE:
points: 150

AFTER (auto-increment by backend):
points: 217  (+67 dari 6.7 kg × 10)


┌─────────────────────────────────────────────────────────────────┐
│ TABEL: users (id: 8 - Mitra John)                               │
└─────────────────────────────────────────────────────────────────┘

BEFORE:
total_collections: 42

AFTER:
total_collections: 43  (+1)
```

---

## 📱 UI Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                    USER APP - Activity Page                      │
└──────────────────────────────────────────────────────────────────┘

BEFORE (Status: pending):
┌─────────────────────────────────┐
│ Jadwal Pengambilan              │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📅 Rabu, 13 Nov 2025        │ │
│ │ ⏰ 06:00 - 08:00            │ │
│ │ 🗑️  B3                       │ │
│ │ 📍 Jl. Sudirman No. 123     │ │
│ │                             │ │
│ │ Status: ⏳ MENUNGGU MITRA   │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘


AFTER (Status: on_progress):
┌─────────────────────────────────┐
│ Jadwal Pengambilan              │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📅 Rabu, 13 Nov 2025        │ │
│ │ ⏰ 06:00 - 08:00            │ │
│ │ 🗑️  B3                       │ │
│ │ 📍 Jl. Sudirman No. 123     │ │
│ │                             │ │
│ │ Status: 🚛 DALAM PERJALANAN │ │
│ │                             │ │
│ │ Mitra:                      │ │
│ │ 👤 John Doe                 │ │
│ │ 📱 081987654321             │ │
│ │ 🚗 Truk - B 1234 XYZ        │ │
│ │                             │ │
│ │ [Button: HUBUNGI MITRA]     │ │
│ │ [Button: LACAK LOKASI]      │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘


AFTER COMPLETED:
┌─────────────────────────────────┐
│ Riwayat Pengambilan             │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ✅ SELESAI                   │ │
│ │ 📅 Rabu, 13 Nov 2025        │ │
│ │ ⏰ Diselesaikan: 06:20      │ │
│ │                             │ │
│ │ Total Berat: 6.7 kg         │ │
│ │ • Organik: 3.5 kg           │ │
│ │ • Anorganik: 2.0 kg         │ │
│ │ • B3: 1.2 kg                │ │
│ │                             │ │
│ │ 🎁 Poin Didapat: +67        │ │
│ │                             │ │
│ │ Mitra: John Doe             │ │
│ │ [Button: LIHAT FOTO]        │ │
│ │ [Button: RATING MITRA]      │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────┐
│                  MITRA APP - Main Navigation                     │
└──────────────────────────────────────────────────────────────────┘

Tab 1: Jadwal Tersedia
┌─────────────────────────────────┐
│ Jadwal Tersedia (15)            │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Ali - Jl. Sudirman          │ │
│ │ 🗑️  B3 | ⏰ 06:00-08:00      │ │
│ │ 📍 2.5 km dari Anda         │ │
│ │ [LIHAT DETAIL]              │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Ahmad - Jl. Thamrin         │ │
│ │ 🗑️  Organik | ⏰ 07:00-09:00 │ │
│ │ 📍 3.1 km dari Anda         │ │
│ │ [LIHAT DETAIL]              │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘


Tab 2: Jadwal Aktif (My Active)
┌─────────────────────────────────┐
│ Jadwal Aktif (1)                │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🚛 DALAM PERJALANAN          │ │
│ │                             │ │
│ │ Ali - Jl. Sudirman No. 123  │ │
│ │ 🗑️  B3 | ⏰ 06:00-08:00      │ │
│ │                             │ │
│ │ [NAVIGASI KE LOKASI]        │ │
│ │ [HUBUNGI USER]              │ │
│ │ [SAMPAI DI LOKASI]          │ │
│ │ [SELESAI]                   │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘


Tab 3: Riwayat
┌─────────────────────────────────┐
│ Riwayat Pengambilan             │
│                                 │
│ Bulan ini: 12 pengambilan       │
│ Total berat: 85.5 kg            │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ✅ Ali - B3                  │ │
│ │ 13 Nov 2025 | 6.7 kg        │ │
│ │ +67 poin                    │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ✅ Ahmad - Organik           │ │
│ │ 12 Nov 2025 | 8.2 kg        │ │
│ │ +82 poin                    │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

---

## 🔔 Notification Timeline

```
TIME: 15:30:00
EVENT: Mitra accepts schedule
─────────────────────────────────────
USER receives:
┌─────────────────────────────────┐
│ 🔔 Gerobaks                     │
│                                 │
│ Mitra John Doe menerima         │
│ jadwal pengambilan Anda!        │
│                                 │
│ Kendaraan: Truk - B 1234 XYZ    │
│ Kontak: 081987654321            │
│                                 │
│ Tap untuk detail →              │
└─────────────────────────────────┘


TIME: 05:45:00
EVENT: Mitra starts journey
─────────────────────────────────────
USER receives:
┌─────────────────────────────────┐
│ 🔔 Gerobaks                     │
│                                 │
│ Mitra dalam perjalanan          │
│                                 │
│ ETA: 15 menit                   │
│                                 │
│ Tap untuk lacak lokasi →        │
└─────────────────────────────────┘


TIME: 06:05:00
EVENT: Mitra arrives
─────────────────────────────────────
USER receives:
┌─────────────────────────────────┐
│ 🔔 Gerobaks                     │
│                                 │
│ Mitra telah sampai di lokasi!   │
│                                 │
│ Silakan serahkan sampah Anda    │
│                                 │
│ Tap untuk detail →              │
└─────────────────────────────────┘


TIME: 06:20:00
EVENT: Pickup completed
─────────────────────────────────────
USER receives:
┌─────────────────────────────────┐
│ 🔔 Gerobaks                     │
│                                 │
│ Pengambilan selesai!            │
│                                 │
│ 🎁 Anda mendapat +67 poin       │
│                                 │
│ Total berat: 6.7 kg             │
│                                 │
│ Tap untuk lihat detail →        │
└─────────────────────────────────┘
```

---

## 🔐 Security & Validation

```
┌─────────────────────────────────────────────────────────────────┐
│ VALIDATION RULES                                                │
└─────────────────────────────────────────────────────────────────┘

Accept Schedule:
✓ User harus role: mitra
✓ Schedule status = 'pending'
✓ assigned_mitra_id = NULL
✓ Prevent double-accept (use DB transaction lock)
✓ Check mitra tidak punya jadwal active lain (optional)


Complete Pickup:
✓ User harus role: mitra
✓ Schedule status = 'on_progress'
✓ assigned_mitra_id = mitra yang login
✓ Minimal 1 foto wajib
✓ Total weight > 0
✓ Photo max 5MB each
✓ Photo format: jpg, png


Cancel Schedule:
✓ User harus role: mitra
✓ assigned_mitra_id = mitra yang login
✓ Status = 'on_progress'
✓ Reason wajib diisi
```

---

## 📊 API Response Time Expectations

```
GET  /available         → < 500ms   (with pagination)
GET  /{id}              → < 200ms   (single record)
POST /accept            → < 300ms   (with notification)
POST /start-journey     → < 200ms
POST /arrive            → < 200ms
POST /complete          → < 1000ms  (with photo upload)
POST /cancel            → < 300ms
```

---

**Dokumentasi lengkap:** `docs/MITRA_PICKUP_SYSTEM.md`  
**Quick reference:** `docs/QUICK_MITRA_API.md`
