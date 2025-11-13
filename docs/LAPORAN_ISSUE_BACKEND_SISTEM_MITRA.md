# 📋 Laporan Issue Backend - Sistem Penjemputan Mitra

**Tanggal**: 13 November 2025  
**Priority**: **TINGGI** - Sistem tidak berfungsi  
**Tim**: Backend Development  

---

## 🎯 Ringkasan Masalah

**Sistem Penjemputan Mitra** di Flutter sudah 100% selesai, tapi **tidak bisa digunakan** karena ada bug di backend:

### ❌ Masalah:
Jadwal penjemputan yang dibuat oleh end user **TIDAK MUNCUL** di daftar "Tersedia" untuk mitra.

### ✅ Yang Sudah Bekerja:
- End user bisa membuat jadwal → Status `pending` tersimpan di database
- Semua endpoint Flutter sudah ready

### ❌ Yang Belum Bekerja:
- Endpoint `/api/mitra/pickup-schedules/available` mengembalikan **array kosong** `[]`
- Mitra tidak bisa melihat jadwal yang bisa diambil

---

## 🧪 Bukti Testing

### Test 1: Buat Jadwal (✅ Berhasil)

```bash
POST /api/pickup-schedules
{
  "schedule_day": "rabu",
  "waste_type_scheduled": "Organik",
  "pickup_time_start": "07:00",
  "pickup_time_end": "09:00"
}

Response: 201 Created
{
  "success": true,
  "data": {
    "id": 46,
    "status": "pending",
    "assigned_mitra_id": null  ← PENTING!
  }
}
```

**✅ Jadwal berhasil tersimpan** dengan:
- `status` = `pending`
- `assigned_mitra_id` = `NULL`
- `deleted_at` = `NULL`
- `is_scheduled_active` = `true`

---

### Test 2: Ambil Jadwal Available (❌ Gagal)

```bash
GET /api/mitra/pickup-schedules/available
Authorization: Bearer [mitra_token]

Response: 200 OK
{
  "success": true,
  "data": {
    "schedules": [],      ← KOSONG!!!
    "total": 0
  }
}
```

**❌ Array kosong**, padahal ada jadwal `pending` dengan `assigned_mitra_id = NULL`

---

## 🔍 Root Cause

Kemungkinan masalah di file **`MitraPickupController.php`** method **`getAvailableSchedules()`**:

### Kemungkinan 1: Filter Work Area Terlalu Ketat ⚠️

```php
// ❌ SALAH - Terlalu restrictive
$schedules = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('work_area', auth()->user()->work_area)  // ← INI MASALAHNYA!
    ->get();
```

**Masalah**: User alamatnya "San Francisco" tapi mitra work area "Jakarta Pusat" → tidak match!

**Solusi**: HAPUS filter work_area atau gunakan radius geografis.

---

### Kemungkinan 2: Filter Hari Terlalu Spesifik ⚠️

```php
// ❌ SALAH - Hanya hari ini
$schedules = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->whereDate('scheduled_pickup_at', today())  // ← Terlalu spesifik!
    ->get();
```

**Solusi**: Tampilkan semua jadwal pending, tidak peduli hari.

---

### Kemungkinan 3: Query Join Error ⚠️

Cek apakah ada JOIN yang salah dengan tabel users atau mitras.

---

## ✅ Query yang BENAR

```php
public function getAvailableSchedules(Request $request)
{
    $schedules = PickupSchedule::with(['user'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->whereNull('deleted_at')
        ->where('is_scheduled_active', true)
        // ❌ JANGAN ada filter work_area di sini!
        // ❌ JANGAN ada filter hari spesifik!
        ->orderBy('scheduled_pickup_at', 'asc')
        ->paginate(20);

    return response()->json([
        'success' => true,
        'message' => 'Available schedules retrieved successfully',
        'data' => [
            'schedules' => $schedules->items(),
            'total' => $schedules->total(),
        ]
    ]);
}
```

**Prinsip**: Available schedules = **SEMUA jadwal pending yang belum ada mitra**

---

## 🧪 Cara Test di Backend

### 1. Cek Database Langsung

```sql
-- Berapa jadwal pending?
SELECT COUNT(*) 
FROM pickup_schedules 
WHERE status = 'pending' 
  AND assigned_mitra_id IS NULL 
  AND deleted_at IS NULL;

-- Harusnya minimal 2 jadwal (ID 42 dan 46)
```

### 2. Test via curl

```bash
# Login mitra
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}'

# Ambil token, lalu cek available
curl -X GET http://127.0.0.1:8000/api/mitra/pickup-schedules/available \
  -H "Authorization: Bearer [TOKEN]" \
  | jq '.data.schedules | length'

# Harusnya return angka > 0, bukan 0
```

### 3. Tambahkan Logging

```php
public function getAvailableSchedules()
{
    Log::info('=== Available Schedules Debug ===');
    
    $total = PickupSchedule::where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->count();
    
    Log::info("Total pending schedules in DB: $total");
    
    // ... query code ...
    
    Log::info("Schedules returned to mitra: " . $schedules->count());
    
    return response()->json(...);
}
```

---

## 📝 Action Items

### 🔴 Priority 1: Fix Query (Estimasi 30 menit)

- [ ] Buka file `app/Http/Controllers/Api/MitraPickupController.php`
- [ ] Cari method `getAvailableSchedules()`
- [ ] **HAPUS** filter `work_area` jika ada
- [ ] **HAPUS** filter hari spesifik jika ada
- [ ] Pastikan hanya filter: `status='pending'` dan `assigned_mitra_id IS NULL`
- [ ] Test dengan curl

### 🟡 Priority 2: Test & Verify (Estimasi 15 menit)

- [ ] Jalankan query SQL manual untuk verify data
- [ ] Test endpoint dengan Postman/curl
- [ ] Pastikan response `data.schedules` array tidak kosong
- [ ] Test di Flutter app (seharusnya langsung muncul)

### 🟢 Priority 3: Add Logging (Estimasi 15 menit)

- [ ] Tambahkan Log::info di method tersebut
- [ ] Monitor berapa jadwal pending di database
- [ ] Monitor berapa jadwal yang di-return ke mitra

---

## 📊 Data Test yang Sudah Dibuat

### Jadwal Test 1 (ID: 42)
```
User: Aceng as (ID: 10)
Status: pending
Mitra: NULL (belum ada yang ambil)
Hari: Kamis
Waktu: 06:00 - 08:00
Alamat: 1-99 Stockton St, Union Square, San Francisco
```

### Jadwal Test 2 (ID: 46)
```
User: Aceng as (ID: 10)
Status: pending
Mitra: NULL
Hari: Rabu
Waktu: 07:00 - 09:00
Alamat: 1-99 Stockton St, Union Square, San Francisco
```

**Kedua jadwal ini HARUS MUNCUL** di endpoint `/api/mitra/pickup-schedules/available`

---

## 🔍 Debugging Steps

### Step 1: Cek Raw Query
```php
$query = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id');

dd($query->toSql(), $query->getBindings());
```

### Step 2: Cek Count
```php
$count = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->count();

Log::info("Pending schedules count: $count");
```

### Step 3: Cek Response
```php
$schedules = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->get();

Log::info("Schedules data", $schedules->toArray());
```

---

## ✅ Expected Result Setelah Fix

### Response yang Benar:
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 46,
        "user_id": 10,
        "user_name": "Aceng as",
        "user_phone": "1234567890",
        "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
        "schedule_day": "rabu",
        "pickup_time_start": "07:00:00",
        "pickup_time_end": "09:00:00",
        "waste_summary": "B3",
        "status": "pending",
        "assigned_mitra_id": null,
        "scheduled_pickup_at": "2025-11-13T07:00:00.000000Z"
      },
      {
        "id": 42,
        "user_name": "Aceng as",
        "status": "pending",
        // ... data lengkap
      }
    ],
    "total": 2
  }
}
```

---

## 📞 Kontak

**Issue Date**: 13 November 2025  
**Severity**: **BLOCKER** - Sistem tidak bisa digunakan  
**Estimasi Fix**: 1-2 jam  

Jika ada pertanyaan atau butuh info tambahan, silakan hubungi Flutter team.

---

## 📎 File Pendukung

- **Detail Teknis Lengkap**: `BACKEND_ISSUE_MITRA_PICKUP_INTEGRATION.md`
- **API Documentation**: `API_DOCUMENTATION_MITRA_PICKUP.md`
- **Testing Guide**: `TESTING_GUIDE_MITRA_PICKUP.md`

---

**Status**: ⏳ Menunggu Fix dari Backend Team

**Update terakhir**: 13 November 2025
