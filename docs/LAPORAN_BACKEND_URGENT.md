# 🚨 LAPORAN URGENT: Jadwal Tidak Muncul di Mitra

**Tanggal:** 13 November 2025  
**Status:** 🔴 CRITICAL BLOCKER  
**Priority:** URGENT

---

## ❌ MASALAH

Endpoint `/api/mitra/pickup-schedules/available` **HANYA mengembalikan jadwal dari 1 user saja** (User Daffa, ID: 2).

Padahal ada **jadwal pending dari user lain** yang sudah memenuhi semua syarat tapi **TIDAK MUNCUL**.

**Dampak:**
- Mitra tidak bisa lihat sebagian besar jadwal penjemputan
- User lain tidak bisa dapat layanan
- Sistem tidak bisa dipakai

---

## 🔍 BUKTI

### 1. Test API

```bash
# Login mitra
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}'

# Cek jadwal available
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer [TOKEN]"
```

**Hasil:**
```json
{
  "data": {
    "schedules": [
      {"id": 8,  "user_id": 2, "user_name": "User Daffa"},
      {"id": 10, "user_id": 2, "user_name": "User Daffa"},
      {"id": 11, "user_id": 2, "user_name": "User Daffa"}
      // ... 20 jadwal, SEMUA dari User Daffa
      // TIDAK ADA jadwal dari user lain!
    ]
  }
}
```

### 2. Cek Database

User Aceng (ID: 10) punya **4 jadwal pending**:

```sql
SELECT id, user_id, status, assigned_mitra_id, is_scheduled_active
FROM pickup_schedules
WHERE user_id = 10 AND status = 'pending' AND assigned_mitra_id IS NULL;
```

**Hasil:**
```
ID  | user_id | status  | assigned_mitra_id | is_scheduled_active
----|---------|---------|-------------------|--------------------
42  |   10    | pending |       NULL        |         1
46  |   10    | pending |       NULL        |         1
48  |   10    | pending |       NULL        |         1
49  |   10    | pending |       NULL        |         1
```

✅ Semua syarat terpenuhi  
❌ Tapi TIDAK MUNCUL di API!

---

## 💡 KEMUNGKINAN PENYEBAB

### Penyebab 1: Filter by work_area (PALING MUNGKIN)

Controller mungkin filter berdasarkan lokasi:

```php
// Di MitraPickupScheduleController.php
$schedules = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('work_area', $mitra->work_area) // ← INI MASALAHNYA!
    ->paginate(20);
```

**Problem:**
- Mitra: work_area = "Jakarta Pusat"
- User Aceng: alamat = "San Francisco"
- Hasil: Jadwal Aceng tidak masuk karena beda area!

### Penyebab 2: Ada whitelist user

```php
->whereIn('user_id', [1, 2, 3, 4]) // Hanya user tertentu
```

### Penyebab 3: Urutan salah

```php
->orderBy('created_at', 'asc') // Jadwal lama duluan
// Jadwal Aceng yang baru jadi di page 2+
```

---

## 🔧 CARA CEK (Backend Team)

### Langkah 1: Cek dengan Tinker

```bash
php artisan tinker
```

```php
use App\Models\PickupSchedule;

// Cek SEMUA pending tanpa filter work_area
$all = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('is_scheduled_active', true)
    ->get(['id', 'user_id', 'work_area']);

echo "Total: " . $all->count() . "\n";
echo "User IDs: " . $all->pluck('user_id')->unique()->sort()->implode(', ') . "\n";

// Cek user 10 (Aceng) ada atau tidak
if ($all->pluck('user_id')->contains(10)) {
    echo "✅ Aceng ADA di query dasar\n";
    echo "Problem: Ada filter di controller\n";
} else {
    echo "❌ Aceng TIDAK ADA di query dasar\n";
    echo "Problem: Cek is_scheduled_active atau deleted_at\n";
}
```

### Langkah 2: Cek Controller

**File:** `app/Http/Controllers/Api/MitraPickupScheduleController.php`

Cari method `getAvailableSchedules()` dan cek apakah ada:

**❌ HAPUS INI:**
```php
->where('work_area', $mitra->work_area)
->whereIn('user_id', [1, 2, 3, 4])
```

**✅ SEHARUSNYA HANYA INI:**
```php
public function getAvailableSchedules(Request $request)
{
    $schedules = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at')
        ->orderBy('created_at', 'desc')
        ->paginate(20);
    
    return response()->json([
        'success' => true,
        'data' => ['schedules' => $schedules->items()]
    ]);
}
```

### Langkah 3: Enable Logging

Tambahkan di method `getAvailableSchedules()`:

```php
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

DB::enableQueryLog();

// ... query anda ...

$queries = DB::getQueryLog();
Log::info('Available Schedules Query:', [
    'sql' => $queries,
    'total_results' => $schedules->total(),
    'user_ids' => $schedules->pluck('user_id')->unique()->values()
]);
```

Lalu cek log:
```bash
tail -f storage/logs/laravel.log
```

### Langkah 4: Cek Langsung di Database

```sql
-- Cek total pending
SELECT COUNT(*) FROM pickup_schedules
WHERE status = 'pending' AND assigned_mitra_id IS NULL 
  AND deleted_at IS NULL AND is_scheduled_active = 1;

-- Cek distribusi user
SELECT user_id, users.name, COUNT(*) as jumlah
FROM pickup_schedules
LEFT JOIN users ON users.id = pickup_schedules.user_id
WHERE status = 'pending' AND assigned_mitra_id IS NULL
  AND deleted_at IS NULL AND is_scheduled_active = 1
GROUP BY user_id, users.name;

-- Harusnya ada user_id 10 (Aceng) dengan 4 jadwal
```

---

## ✅ SOLUSI (Pilih Salah Satu)

### Solusi 1: Hapus Filter work_area (RECOMMENDED)

Tampilkan SEMUA jadwal pending, biarkan mitra pilih sendiri:

```php
public function getAvailableSchedules(Request $request)
{
    $schedules = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at')
        ->orderBy('created_at', 'desc')
        ->paginate(20);
    
    return response()->json([
        'success' => true,
        'message' => 'Available schedules retrieved successfully',
        'data' => [
            'schedules' => $schedules->items(),
            'pagination' => [
                'current_page' => $schedules->currentPage(),
                'total_pages' => $schedules->lastPage(),
                'per_page' => $schedules->perPage(),
                'total' => $schedules->total(),
            ]
        ]
    ]);
}
```

### Solusi 2: Buat Filter Optional

```php
public function getAvailableSchedules(Request $request)
{
    $mitra = $request->user();
    
    $query = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at');
    
    // Filter optional lewat parameter
    if ($request->input('filter_by_area') === 'true' && !empty($mitra->work_area)) {
        $query->where('work_area', $mitra->work_area);
    }
    
    $schedules = $query->orderBy('created_at', 'desc')->paginate(20);
    
    return response()->json([...]);
}
```

Usage:
```bash
# Default: tampilkan semua
GET /api/mitra/pickup-schedules/available

# Filter by area
GET /api/mitra/pickup-schedules/available?filter_by_area=true
```

---

## 🧪 TEST SETELAH FIX

```bash
# 1. Login
TOKEN=$(curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}' \
  2>/dev/null | jq -r '.data.token')

# 2. Cek available schedules
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '.data.schedules[] | {id, user_id, user_name}'

# 3. Cek apakah ada user_id selain 2
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '[.data.schedules[].user_id] | unique'

# Harusnya return: [2, 10, ...] bukan cuma [2]
```

**Cek jadwal Aceng muncul:**
```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '.data.schedules[] | select(.user_id == 10)'

# Harusnya return 4 jadwal dari "Aceng as"
```

---

## 📊 HASIL YANG DIHARAPKAN

### Sebelum Fix:
```json
{
  "schedules": [
    {"id": 8,  "user_id": 2, "user_name": "User Daffa"},
    {"id": 10, "user_id": 2, "user_name": "User Daffa"}
    // Semua dari user yang sama
  ]
}
```

### Setelah Fix:
```json
{
  "schedules": [
    {"id": 49, "user_id": 10, "user_name": "Aceng as"},
    {"id": 48, "user_id": 10, "user_name": "Aceng as"},
    {"id": 46, "user_id": 10, "user_name": "Aceng as"},
    {"id": 42, "user_id": 10, "user_name": "Aceng as"},
    {"id": 11, "user_id": 2,  "user_name": "User Daffa"},
    {"id": 10, "user_id": 2,  "user_name": "User Daffa"}
    // Campuran dari berbagai user
  ],
  "pagination": {
    "total": 33
  }
}
```

---

## ✅ CHECKLIST

### Backend Team:
- [ ] Jalankan tinker diagnostics
- [ ] Cek controller file `MitraPickupScheduleController.php`
- [ ] Identifikasi filter yang bermasalah
- [ ] Hapus filter work_area atau buat optional
- [ ] Test dengan curl command di atas
- [ ] Confirm jadwal Aceng (user_id 10) muncul
- [ ] Deploy ke staging

### Frontend Team (Setelah Backend Fix):
- [ ] Hot reload Flutter app
- [ ] Login sebagai mitra
- [ ] Buka "Sistem Penjemputan Mitra"
- [ ] Tab "Tersedia" harus tampil jadwal dari berbagai user
- [ ] Verify jadwal Aceng muncul
- [ ] Test pagination
- [ ] Test workflow lengkap

---

## 📞 KONTAK

**Frontend Team:** Siap test setelah fix  
**Backend Team:** Mohon prioritas tinggi - sistem tidak bisa production

**Target:** Fix dalam 1-2 jam

---

**Dokumen Terkait:**
- [CRITICAL_BACKEND_ISSUE.md](./CRITICAL_BACKEND_ISSUE.md) - Versi lengkap bahasa Inggris
- [BACKEND_FIX_QUICK_REFERENCE.md](./BACKEND_FIX_QUICK_REFERENCE.md) - Quick reference

**Status:** 🔴 ACTIVE - Menunggu backend investigation
