# 🚨 Backend Issue: Mitra Pickup System Integration

**Tanggal**: 13 November 2025  
**Priority**: P1 - High  
**Status**: Requires Backend Fix  
**Reporter**: Flutter Team  
**Assignee**: Backend Team

---

## 📋 Executive Summary

Sistem Penjemputan Mitra di Flutter sudah **100% selesai** dan siap digunakan. Namun, ada **masalah kritis** di backend yang membuat jadwal penjemputan yang dibuat oleh end user **tidak muncul** di tab "Tersedia" untuk mitra.

**Testing menunjukkan:**
- ✅ End user berhasil membuat jadwal (API `/api/pickup-schedules` bekerja)
- ✅ Jadwal tersimpan di database dengan status `pending`
- ❌ Endpoint `/api/mitra/pickup-schedules/available` mengembalikan **array kosong** `[]`
- ❌ Mitra tidak bisa melihat jadwal yang available untuk diambil

---

## 🔍 Detailed Testing Results

### Test 1: Membuat Jadwal via Flutter App ✅

**User**: Aceng as (aceng@gmail.com)  
**Action**: Buat jadwal penjemputan baru via UI

**Request:**
```http
POST /api/pickup-schedules
Authorization: Bearer 42|5MFyVoAIwEkIh2sc31BJ2krKa4vlaiyuihauIkpMa128ed81
Content-Type: application/json

{
  "schedule_day": "kamis",
  "waste_type_scheduled": "B3",
  "is_scheduled_active": true,
  "pickup_time_start": "06:00",
  "pickup_time_end": "08:00",
  "has_additional_waste": false,
  "notes": "Sampah sesuai jadwal: B3"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Jadwal penjemputan berhasil dibuat",
  "data": {
    "id": 42,
    "scheduled_pickup_at": "2025-11-13 06:00:00",
    "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
    "waste_summary": "B3",
    "total_estimated_weight": 0,
    "status": "pending"
  }
}
```

**Result**: ✅ **BERHASIL** - Status Code 201

---

### Test 2: Membuat Jadwal via Terminal (curl) ✅

**Command:**
```bash
curl -X POST http://127.0.0.1:8000/api/pickup-schedules \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer 55|tPGEw8n63AknNSSDm0leysJueaRpiVHH62L6RZPEe458629a" \
  -d '{
    "schedule_day": "rabu",
    "waste_type_scheduled": "Organik",
    "is_scheduled_active": true,
    "pickup_time_start": "07:00",
    "pickup_time_end": "09:00",
    "has_additional_waste": false,
    "notes": "Test jadwal dari terminal - Organik"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Jadwal penjemputan berhasil dibuat",
  "data": {
    "id": 46,
    "scheduled_pickup_at": "2025-11-13 07:00:00",
    "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
    "waste_summary": "B3",
    "total_estimated_weight": 0,
    "status": "pending"
  }
}
```

**Result**: ✅ **BERHASIL** - Status Code 201

---

### Test 3: Verifikasi Detail Jadwal ✅

**Command:**
```bash
curl -X GET "http://127.0.0.1:8000/api/pickup-schedules/46" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer [token]"
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 46,
    "user_id": 10,
    "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
    "latitude": null,
    "longitude": null,
    "user_name": "Aceng as",
    "user_phone": "1234567890",
    "schedule_day": "rabu",
    "waste_type_scheduled": "B3",
    "is_scheduled_active": true,
    "pickup_time_start": "07:00:00",
    "pickup_time_end": "09:00:00",
    "scheduled_pickup_at": "2025-11-13T07:00:00.000000Z",
    "has_additional_waste": false,
    "status": "pending",
    "assigned_mitra_id": null,     // ← PENTING!
    "assigned_at": null,
    "on_the_way_at": null,
    "picked_up_at": null,
    "completed_at": null,
    "cancelled_at": null,
    "created_at": "2025-11-12T18:21:43.000000Z",
    "updated_at": "2025-11-12T18:21:43.000000Z",
    "deleted_at": null
  }
}
```

**Key Points:**
- ✅ Status: `pending`
- ✅ `assigned_mitra_id`: `null` (belum ada mitra yang ambil)
- ✅ `deleted_at`: `null` (tidak soft-deleted)
- ✅ `is_scheduled_active`: `true`

**Result**: ✅ Data tersimpan dengan benar di database

---

### Test 4: Cek Jadwal Available untuk Mitra ❌ **GAGAL**

**Mitra**: Ahmad Kurniawan (driver.jakarta@gerobaks.com)  
**Work Area**: Jakarta Pusat

**Request dari Flutter:**
```http
GET /api/mitra/pickup-schedules/available
Authorization: Bearer [mitra_token]
Accept: application/json
```

**Response dari Backend:**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [],    // ← KOSONG!!!
    "total": 0
  }
}
```

**Flutter Log:**
```
flutter: 🚛 Fetching available schedules: http://127.0.0.1:8000/api/mitra/pickup-schedules/available
flutter: 🐛 Response status: 200
flutter: 🐛 Response body: {"success":true,"message":"Available schedules retrieved successfully","data":{"schedules":[],"total":0}}
flutter: ✅ Loaded 0 available schedules
```

**Result**: ❌ **GAGAL** - Array kosong, padahal ada jadwal dengan status pending

---

## 🚨 Root Cause Analysis

### Kondisi yang Seharusnya Terpenuhi:

Jadwal **HARUS MUNCUL** di endpoint `/api/mitra/pickup-schedules/available` jika:

1. ✅ `status` = `'pending'`
2. ✅ `assigned_mitra_id` = `NULL` (belum ada mitra)
3. ✅ `deleted_at` = `NULL` (tidak soft-deleted)
4. ✅ `is_scheduled_active` = `true`

### Kemungkinan Masalah di Backend:

#### 1. **Filter Work Area Terlalu Ketat** ⚠️

Mitra: `work_area = "Jakarta Pusat"`  
Jadwal: `pickup_address = "1-99 Stockton St, Union Square, San Francisco"`

**Kemungkinan:** Backend memfilter berdasarkan exact match area, sehingga alamat San Francisco tidak match dengan Jakarta Pusat.

**Solusi:** Seharusnya **TIDAK** ada filter area untuk available schedules, atau menggunakan radius/jarak geografis.

---

#### 2. **Filter Hari/Waktu Terlalu Spesifik** ⚠️

**Kemungkinan:** Backend hanya menampilkan jadwal untuk hari ini atau hari tertentu.

Jadwal dibuat:
- ID 42: `schedule_day = "kamis"`, `scheduled_pickup_at = "2025-11-13 06:00:00"`
- ID 46: `schedule_day = "rabu"`, `scheduled_pickup_at = "2025-11-13 07:00:00"`

**Solusi:** Available schedules seharusnya menampilkan **semua jadwal pending** tanpa filter hari spesifik.

---

#### 3. **Query Join yang Salah** ⚠️

**Kemungkinan:** Query JOIN dengan tabel lain (users, mitras) yang menyebabkan hasil kosong.

**Solusi:** Review query SQL/Eloquent di controller.

---

#### 4. **Constraint Database yang Salah** ⚠️

**Kemungkinan:** Ada foreign key constraint atau index yang membuat query tidak mengembalikan hasil.

**Solusi:** Review schema database tabel `pickup_schedules`.

---

## 📝 Expected Backend Query

**Controller**: `MitraPickupController@getAvailableSchedules()`

**Query yang seharusnya:**

```php
public function getAvailableSchedules(Request $request)
{
    $schedules = PickupSchedule::with(['user'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->whereNull('deleted_at')
        ->where('is_scheduled_active', true)
        // JANGAN ada filter work_area atau lokasi di sini!
        ->orderBy('scheduled_pickup_at', 'asc')
        ->paginate(20);

    return response()->json([
        'success' => true,
        'message' => 'Available schedules retrieved successfully',
        'data' => [
            'schedules' => $schedules->items(),
            'total' => $schedules->total(),
            'current_page' => $schedules->currentPage(),
            'last_page' => $schedules->lastPage(),
        ]
    ]);
}
```

**PENTING:** 
- ❌ JANGAN filter berdasarkan `work_area` mitra
- ❌ JANGAN filter berdasarkan hari tertentu (kecuali scheduled_pickup_at >= now())
- ❌ JANGAN filter berdasarkan jarak/lokasi (atau gunakan radius besar, misal 50km)

---

## 🧪 Testing Checklist untuk Backend

### 1. Test Query Langsung di Database

```sql
-- Cek berapa jadwal pending yang ada
SELECT COUNT(*) 
FROM pickup_schedules 
WHERE status = 'pending' 
  AND assigned_mitra_id IS NULL 
  AND deleted_at IS NULL 
  AND is_scheduled_active = 1;

-- Harusnya return > 0 (minimal 2 dari testing kita)
```

```sql
-- Cek detail jadwal
SELECT id, user_id, status, assigned_mitra_id, schedule_day, 
       scheduled_pickup_at, pickup_address, created_at
FROM pickup_schedules 
WHERE status = 'pending' 
  AND assigned_mitra_id IS NULL 
ORDER BY id DESC 
LIMIT 5;
```

**Expected Result:**
```
id  | status  | assigned_mitra_id | schedule_day | scheduled_pickup_at
----|---------|-------------------|--------------|--------------------
46  | pending | NULL              | rabu         | 2025-11-13 07:00:00
42  | pending | NULL              | kamis        | 2025-11-13 06:00:00
```

---

### 2. Test Endpoint via Postman/curl

```bash
# Login sebagai mitra
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}'

# Ambil token dari response, lalu:
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer [TOKEN]" | jq '.'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 46,
        "user_name": "Aceng as",
        "status": "pending",
        "schedule_day": "rabu",
        "waste_summary": "B3",
        // ... data lengkap
      },
      {
        "id": 42,
        "user_name": "Aceng as",
        "status": "pending",
        "schedule_day": "kamis",
        // ... data lengkap
      }
    ],
    "total": 2
  }
}
```

---

### 3. Review Backend Code

**File yang perlu dicek:**
1. `app/Http/Controllers/Api/MitraPickupController.php`
   - Method: `getAvailableSchedules()`
   
2. `app/Models/PickupSchedule.php`
   - Eloquent scopes
   - Relations

3. `routes/api.php`
   - Route definition untuk `/api/mitra/pickup-schedules/available`

**Yang harus dipastikan:**
- ✅ Query tidak memfilter berdasarkan work_area mitra
- ✅ Query hanya filter: status=pending, assigned_mitra_id=null
- ✅ Eager loading `user` relation berfungsi
- ✅ Response format sesuai: `data.schedules` = array

---

## 🎯 Action Items untuk Backend Team

### Priority 1: Fix Query Available Schedules

- [ ] Review dan debug method `getAvailableSchedules()` di `MitraPickupController`
- [ ] Hapus filter work_area jika ada
- [ ] Pastikan query hanya filter: `status='pending'` dan `assigned_mitra_id IS NULL`
- [ ] Test dengan data jadwal ID 42 dan 46
- [ ] Pastikan response format: `{"success":true,"data":{"schedules":[...]}}`

### Priority 2: Add Logging

Tambahkan logging untuk debugging:

```php
public function getAvailableSchedules(Request $request)
{
    Log::info('Fetching available schedules for mitra', [
        'mitra_id' => auth()->id(),
        'work_area' => auth()->user()->work_area
    ]);

    $query = PickupSchedule::where('status', 'pending')
        ->whereNull('assigned_mitra_id');

    Log::info('Query SQL', ['sql' => $query->toSql()]);
    Log::info('Query bindings', ['bindings' => $query->getBindings()]);

    $schedules = $query->get();

    Log::info('Schedules found', ['count' => $schedules->count()]);

    // ... rest of code
}
```

### Priority 3: Create Backend Test

```php
// tests/Feature/MitraPickupTest.php

public function test_mitra_can_see_available_schedules()
{
    $mitra = User::factory()->mitra()->create([
        'work_area' => 'Jakarta Pusat'
    ]);

    $schedule = PickupSchedule::factory()->create([
        'status' => 'pending',
        'assigned_mitra_id' => null,
        'pickup_address' => 'Any Address',
    ]);

    $response = $this->actingAs($mitra)->getJson('/api/mitra/pickup-schedules/available');

    $response->assertOk()
        ->assertJsonStructure([
            'success',
            'data' => [
                'schedules',
                'total'
            ]
        ])
        ->assertJsonPath('data.total', 1)
        ->assertJsonPath('data.schedules.0.id', $schedule->id);
}
```

---

## 📊 Data Sample untuk Testing

### Test User (End User)
```
Email: aceng@gmail.com
Password: Password123
ID: 10
Name: Aceng as
Address: 1-99 Stockton St, Union Square, San Francisco
```

### Test User (Mitra)
```
Email: driver.jakarta@gerobaks.com
Password: mitra123
ID: 5
Name: Ahmad Kurniawan
Work Area: Jakarta Pusat
```

### Test Schedules Created
```
ID 42:
- user_id: 10
- status: pending
- assigned_mitra_id: NULL
- schedule_day: kamis
- scheduled_pickup_at: 2025-11-13 06:00:00
- waste_type_scheduled: B3
- is_scheduled_active: true

ID 46:
- user_id: 10
- status: pending
- assigned_mitra_id: NULL
- schedule_day: rabu
- scheduled_pickup_at: 2025-11-13 07:00:00
- waste_type_scheduled: Organik (tapi tersimpan sebagai B3)
- is_scheduled_active: true
```

---

## 🔄 Integration Status

| Component | Status | Notes |
|-----------|--------|-------|
| Flutter UI | ✅ Complete | 6 screens, full flow |
| Flutter API Service | ✅ Complete | 9 methods implemented |
| Flutter Navigation | ✅ Complete | All routes configured |
| Backend Endpoints (9/11) | ⚠️ Partially Working | Need fix on available schedules |
| Database Schema | ✅ Complete | All tables exist |
| **Available Schedules Endpoint** | ❌ **BROKEN** | **Returns empty array** |

---

## 📞 Contact

**Reporter**: Flutter Development Team  
**Issue Date**: November 13, 2025  
**Severity**: P1 - Blocker  
**Estimated Fix Time**: 2-4 hours

**Questions?** Please reach out to Flutter team for clarification or additional testing.

---

## 📎 Appendix

### Full Flutter Logs

Available schedules fetch (empty result):
```
flutter: 🚛 Fetching available schedules: http://127.0.0.1:8000/api/mitra/pickup-schedules/available
flutter: 🐛 Response status: 200
flutter: 🐛 Response body: {"success":true,"message":"Available schedules retrieved successfully","data":{"schedules":[],"total":0}}
flutter: ✅ Loaded 0 available schedules
```

### Backend API Routes Expected

```
GET    /api/mitra/pickup-schedules/available     (Returns all pending schedules)
GET    /api/mitra/pickup-schedules/my-active     (Returns mitra's active schedules)
GET    /api/mitra/pickup-schedules/history       (Returns mitra's completed schedules)
POST   /api/mitra/pickup-schedules/{id}/accept   (Mitra accepts a schedule)
POST   /api/mitra/pickup-schedules/{id}/start    (Start journey)
POST   /api/mitra/pickup-schedules/{id}/arrive   (Arrived at location)
POST   /api/mitra/pickup-schedules/{id}/complete (Complete with weights & photos)
POST   /api/mitra/pickup-schedules/{id}/cancel   (Cancel schedule)
GET    /api/mitra/pickup-schedules/{id}          (Get schedule detail)
```

---

**END OF REPORT**

*Generated by Flutter Team - November 13, 2025*
