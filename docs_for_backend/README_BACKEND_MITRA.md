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
