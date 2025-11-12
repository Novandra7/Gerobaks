# Testing Pickup Schedules API Implementation

## ✅ Implementasi Selesai

### Perubahan yang Dilakukan:

1. **ApiRoutes** (`lib/utils/api_routes.dart`)
   - ✅ Ditambahkan endpoint: `pickupSchedules = '/api/pickup-schedules'`
   - ✅ Ditambahkan endpoint: `pickupSchedule(int id)`

2. **ScheduleApiService** (`lib/services/schedule_api_service.dart`)
   - ✅ Method `createPickupSchedule()` - POST untuk membuat jadwal
   - ✅ Method `listPickupSchedules()` - GET untuk list jadwal

3. **AddSchedulePage** (`lib/ui/pages/user/schedule/add_schedule_page.dart`)
   - ✅ Updated `_submitSchedule()` menggunakan endpoint baru
   - ✅ Mendukung scheduled waste (sampah sesuai jadwal)
   - ✅ Mendukung additional wastes (multi-select + weight per type)
   - ✅ Auto-detect hari penjemputan (besok)
   - ✅ Notes/catatan

---

## 📋 Test Results

### Test 1: GET All Pickup Schedules ✅
```bash
curl http://127.0.0.1:8000/api/pickup-schedules \
  -H "Authorization: Bearer TOKEN"
```

**Result:** 
- Status: ✅ Success
- Total schedules: 21
- Response structure validated

### Test 2: POST Create New Schedule ✅
```bash
curl -X POST http://127.0.0.1:8000/api/pickup-schedules \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "schedule_day": "senin",
    "waste_type_scheduled": "B3",
    "is_scheduled_active": false,
    "pickup_time_start": "08:00",
    "pickup_time_end": "10:00",
    "has_additional_waste": true,
    "additional_wastes": [
      {"type": "organik", "estimated_weight": 2.5},
      {"type": "anorganik", "estimated_weight": 1.8}
    ],
    "notes": "Test dari Copilot"
  }'
```

**Result:**
```json
{
  "success": true,
  "message": "Jadwal penjemputan berhasil dibuat",
  "data": {
    "id": 22,
    "scheduled_pickup_at": "2025-11-13 08:00:00",
    "pickup_address": "Jl. Merdeka No. 1, Jakarta",
    "waste_summary": "Organik, Anorganik",
    "total_estimated_weight": 4.3,
    "status": "pending"
  }
}
```

### Test 3: Flutter App Integration ✅
- ✅ App builds successfully (no compilation errors)
- ✅ API endpoint configured correctly (localhost:8000)
- ✅ Authentication token working
- ✅ Ready for manual UI testing

---

## 🧪 Manual Testing Steps

### Cara Test di Flutter App:

1. **Buka App** (sudah running di simulator)

2. **Login** dengan credentials:
   - Email: `daffa@gmail.com`
   - Password: (sesuai database)

3. **Navigate ke Add Schedule Page**:
   - Dari home screen → pilih menu "Jadwal" atau "Schedule"
   - Klik tombol "+" atau "Buat Jadwal Baru"

4. **Test Scenario 1 - Scheduled Waste Only**:
   - ✅ Toggle "Sampah Sesuai Jadwal" **ON**
   - ✅ Toggle "Sampah Tambahan" **OFF**
   - ✅ Isi notes (opsional): "Test scheduled waste only"
   - ✅ Klik "Buat Jadwal"
   - **Expected:** Success dialog dengan info jadwal

5. **Test Scenario 2 - With Additional Wastes**:
   - ✅ Toggle "Sampah Sesuai Jadwal" **ON**
   - ✅ Toggle "Sampah Tambahan" **ON** (requires active subscription)
   - ✅ Pilih jenis sampah: Organik, Anorganik
   - ✅ Isi berat untuk masing-masing:
     - Organik: 3.5 kg
     - Anorganik: 2.0 kg
   - ✅ Isi notes: "Test dengan sampah tambahan"
   - ✅ Klik "Buat Jadwal"
   - **Expected:** Success dialog dengan total berat 5.5 kg

6. **Test Scenario 3 - Additional Wastes Only**:
   - ✅ Toggle "Sampah Sesuai Jadwal" **OFF**
   - ✅ Toggle "Sampah Tambahan" **ON**
   - ✅ Pilih: Elektronik
   - ✅ Berat: 10 kg
   - ✅ Notes: "Laptop rusak"
   - ✅ Klik "Buat Jadwal"
   - **Expected:** Success dengan waste_summary: "Elektronik"

---

## 🔍 Verifikasi Database

### Cek di phpMyAdmin:

1. **Buka phpMyAdmin**: http://localhost/phpmyadmin
2. **Pilih database**: `gerobaks_db`
3. **Buka tabel**: `pickup_schedules`
4. **Filter by user**: `WHERE user_id = 2` (daffa@gmail.com)
5. **Check fields**:
   - ✅ `id` - Auto increment
   - ✅ `user_id` - Harus 2
   - ✅ `schedule_day` - Hari dalam bahasa Indonesia
   - ✅ `waste_type_scheduled` - Jenis sampah jadwal (B3, Campuran, dll)
   - ✅ `is_scheduled_active` - true/false
   - ✅ `has_additional_waste` - true/false
   - ✅ `additional_wastes` - JSON array dengan type & estimated_weight
   - ✅ `waste_summary` - String gabungan jenis sampah
   - ✅ `total_estimated_weight` - Total berat (decimal)
   - ✅ `notes` - Catatan user
   - ✅ `status` - pending
   - ✅ `created_at` - Timestamp

### SQL Query untuk Cek Data Terbaru:
```sql
SELECT 
  id,
  schedule_day,
  waste_type_scheduled,
  is_scheduled_active,
  has_additional_waste,
  additional_wastes,
  waste_summary,
  total_estimated_weight,
  notes,
  status,
  created_at
FROM pickup_schedules
WHERE user_id = 2
ORDER BY created_at DESC
LIMIT 5;
```

---

## 🎯 Expected Results

### Success Indicators:

1. **API Response**:
   - ✅ `success: true`
   - ✅ `data.id` exists (new schedule ID)
   - ✅ `data.waste_summary` matches selected wastes
   - ✅ `data.total_estimated_weight` calculated correctly
   - ✅ `data.status` = "pending"

2. **Flutter App**:
   - ✅ Success dialog appears
   - ✅ Shows schedule ID
   - ✅ Shows waste summary
   - ✅ Shows estimated weight
   - ✅ No errors in console

3. **Database**:
   - ✅ New row created in `pickup_schedules`
   - ✅ All fields populated correctly
   - ✅ JSON data valid in `additional_wastes`
   - ✅ Timestamps recorded

---

## 🐛 Troubleshooting

### Issue 1: Authentication Error
**Error:** `Route [login] not defined`

**Solution:** 
- Pastikan menggunakan Bearer token
- Token format: `Bearer 19|Imswwq7lr2RPRjcGv2xMEj37IwEvVu6a748jeSHrf145a4c7`

### Issue 2: Validation Error
**Error:** `The pickup time start field must match the format H:i`

**Solution:**
- Gunakan format waktu: `HH:MM` (contoh: `08:00`)
- Jangan gunakan detik: ~~`08:00:00`~~

### Issue 3: Subscription Required
**Error:** Dialog "Fitur ini memerlukan langganan aktif"

**Solution:**
- User `daffa@gmail.com` sudah memiliki active subscription
- Jika masih error, cek `users.subscription_status = 'active'`

### Issue 4: Data Tidak Masuk Database
**Check:**
1. Backend Laravel running di port 8000
2. Database connection di `.env` Laravel benar
3. Migrations sudah dijalankan
4. Check Laravel logs: `storage/logs/laravel.log`

---

## 📊 Database Schema Reference

### Table: `pickup_schedules`

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| user_id | INT | Foreign key to users |
| pickup_address | VARCHAR | Alamat penjemputan |
| latitude | DECIMAL | Optional |
| longitude | DECIMAL | Optional |
| user_name | VARCHAR | Nama user |
| user_phone | VARCHAR | Nomor HP |
| schedule_day | ENUM | senin, selasa, rabu, dst |
| waste_type_scheduled | VARCHAR | B3, Organik, Anorganik, dll |
| is_scheduled_active | BOOLEAN | Aktif/tidak |
| pickup_time_start | TIME | Waktu mulai |
| pickup_time_end | TIME | Waktu selesai |
| scheduled_pickup_at | DATETIME | Tanggal & waktu penjemputan |
| has_additional_waste | BOOLEAN | Ada sampah tambahan |
| additional_wastes | JSON | Array of {type, estimated_weight} |
| waste_summary | VARCHAR | Ringkasan jenis sampah |
| notes | TEXT | Catatan dari user |
| status | ENUM | pending, assigned, completed, dll |
| created_at | TIMESTAMP | - |
| updated_at | TIMESTAMP | - |

---

## ✨ Features Implemented

### 1. Scheduled Waste (Sampah Sesuai Jadwal)
- Toggle ON/OFF
- Auto-detect hari ini dari WasteScheduleService
- Info card dengan icon & deskripsi
- Termasuk dalam notes jika aktif

### 2. Additional Wastes (Sampah Tambahan)
- **Subscription-gated** feature
- Multi-select dropdown dengan checkbox
- Weight input per waste type
- Chips untuk selected items
- Validasi: minimal 1 jenis jika toggle ON
- Validasi: berat harus diisi untuk setiap jenis

### 3. Auto Schedule Info
- Waktu penjemputan fixed: 06:00 - 08:00
- Hari otomatis: besok (tomorrow)
- Hari dalam bahasa Indonesia
- Lokasi dari user profile

### 4. UI/UX Improvements
- ✅ Toggle switches dengan visual feedback
- ✅ Info cards dengan icons
- ✅ Conditional rendering (active/inactive states)
- ✅ Summary di bottom navigation
- ✅ Success dialog dengan detail lengkap
- ✅ Loading states

---

## 📝 Next Steps

### Recommended Enhancements:

1. **List Schedules Page**
   - Implementasikan `listPickupSchedules()` di UI
   - Filter by status
   - Pagination
   - Pull to refresh

2. **Schedule Details Page**
   - Show full schedule info
   - Status timeline
   - Assigned mitra info
   - Cancel/reschedule options

3. **Real-time Updates**
   - WebSocket untuk status changes
   - Push notifications
   - In-app notifications

4. **Error Handling**
   - Better error messages
   - Retry mechanism
   - Offline mode support

---

## 🎉 Status: READY FOR TESTING

**Last Updated:** November 12, 2025

**Test Status:**
- ✅ API Integration Complete
- ✅ Backend Validation Passed
- ✅ Database Persistence Verified
- ✅ No Compilation Errors
- ⏳ Manual UI Testing (Ready)
- ⏳ User Acceptance Testing (Pending)

**Test in Flutter App Now!** 🚀
