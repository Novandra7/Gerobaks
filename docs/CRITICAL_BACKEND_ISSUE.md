# 🚨 CRITICAL: Jadwal User Tidak Muncul di Mitra Available View

**Status:** 🔴 CRITICAL BLOCKER  
**Tanggal:** 13 November 2025  
**Priority:** URGENT - Core Business Logic Failure  
**Impact:** Sistem Penjemputan Mitra TIDAK BERFUNGSI

---

## 📋 Executive Summary

Backend API endpoint `/api/mitra/pickup-schedules/available` **HANYA mengembalikan jadwal dari user_id: 2 (User Daffa)**, meskipun ada jadwal pending dari user lain yang memenuhi semua kriteria.

**Dampak Bisnis:**
- ❌ Mitra tidak bisa melihat sebagian besar jadwal penjemputan
- ❌ User lain tidak bisa mendapat layanan penjemputan
- ❌ Sistem tidak bisa digunakan di production

---

## 🔍 Evidence: Masalah Terkonfirmasi

### Test yang Dilakukan:

**1. Login sebagai Mitra:**
```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "68|GFO0QF6...",
    "user": {
      "id": 5,
      "name": "Ahmad Kurniawan",
      "email": "driver.jakarta@gerobaks.com",
      "role": "mitra",
      "work_area": "Jakarta Pusat"
    }
  }
}
```

**2. Cek Available Schedules:**
```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer [TOKEN]" \
  -H "Accept: application/json"
```

**Response:**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {"id": 8,  "user_id": 2, "user_name": "User Daffa"},
      {"id": 10, "user_id": 2, "user_name": "User Daffa"},
      {"id": 11, "user_id": 2, "user_name": "User Daffa"},
      {"id": 13, "user_id": 2, "user_name": "User Daffa"}
      // ... 16 schedules lainnya, SEMUA dari User Daffa (user_id: 2)
      // TIDAK ADA jadwal dari user lain!
    ]
  }
}
```

**3. Verifikasi Data di Database:**

User Aceng (user_id: 10) memiliki **4 jadwal pending** yang seharusnya muncul:

```sql
SELECT id, user_id, status, assigned_mitra_id, is_scheduled_active, 
       schedule_day, waste_type_scheduled, created_at
FROM pickup_schedules
WHERE user_id = 10 
  AND status = 'pending'
  AND assigned_mitra_id IS NULL
  AND deleted_at IS NULL;
```

**Result:**
```
ID  | user_id | status  | assigned_mitra_id | is_scheduled_active | schedule_day
----|---------|---------|-------------------|---------------------|-------------
42  |   10    | pending |       NULL        |         1           | rabu
46  |   10    | pending |       NULL        |         1           | rabu
48  |   10    | pending |       NULL        |         1           | kamis
49  |   10    | pending |       NULL        |         1           | jumat
```

✅ **Semua jadwal memenuhi kriteria:**
- Status: `pending`
- assigned_mitra_id: `NULL`
- is_scheduled_active: `1` (true)
- deleted_at: `NULL`

❌ **Tapi TIDAK MUNCUL di API response!**

---

## 🎯 Root Cause Analysis

### Kemungkinan Penyebab di Backend:

#### **1. Filter by work_area (MOST LIKELY)**

Controller mungkin memfilter berdasarkan work_area mitra:

```php
// ❌ PROBLEMATIC CODE:
public function getAvailableSchedules(Request $request)
{
    $mitra = $request->user();
    
    $schedules = PickupSchedule::where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->where('work_area', $mitra->work_area) // ← INI MASALAHNYA!
        ->paginate(20);
    
    return response()->json([...]);
}
```

**Problem:**
- Mitra work_area: `"Jakarta Pusat"`
- User Aceng address: `"San Francisco"`
- Result: Jadwal Aceng **tidak masuk** karena work_area tidak match!

**Evidence dari Data:**
```
Mitra Ahmad: work_area = "Jakarta Pusat"
User Daffa (visible): pickup_address likely in Jakarta
User Aceng (NOT visible): pickup_address = "San Francisco"
```

#### **2. Hidden User Filter**

Ada whitelist user tertentu:

```php
// ❌ PROBLEMATIC CODE:
->whereIn('user_id', [1, 2, 3, 4]) // Only test users
// OR
->where('user_id', '!=', 10) // Accidentally excluding Aceng
```

#### **3. Ordering Issue**

Jadwal Aceng ada tapi di page 2+:

```php
// Possible issue:
->orderBy('created_at', 'asc') // Oldest first
// Result: Newer Aceng schedules on page 2+
```

#### **4. is_scheduled_active Mismatch**

Database value mungkin berbeda dari yang kita lihat:

```php
// Need to verify actual database value:
SELECT id, is_scheduled_active 
FROM pickup_schedules 
WHERE user_id = 10 AND status = 'pending';

// Make sure is_scheduled_active is 1, not 0
```

---

## 🔧 Investigation Steps - Backend Team

### Step 1: Enable Query Logging (5 menit)

Tambahkan di controller method `getAvailableSchedules()`:

```php
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

public function getAvailableSchedules(Request $request)
{
    // Enable query logging
    DB::enableQueryLog();
    
    $mitra = $request->user();
    
    // Your existing query
    $schedules = PickupSchedule::where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        // ... other conditions
        ->paginate(20);
    
    // Log the actual SQL query
    $queries = DB::getQueryLog();
    Log::info('Available Schedules Query:', [
        'mitra_id' => $mitra->id,
        'mitra_work_area' => $mitra->work_area ?? 'N/A',
        'queries' => $queries,
        'total_results' => $schedules->total(),
        'user_ids_in_results' => $schedules->pluck('user_id')->unique()->values()
    ]);
    
    return response()->json([...]);
}
```

**Lalu run test dan check logs:**
```bash
tail -f storage/logs/laravel.log
```

---

### Step 2: Run Tinker Diagnostics (10 menit)

```bash
php artisan tinker
```

**A. Check Base Query (tanpa filter tambahan):**
```php
use App\Models\PickupSchedule;

// Query dasar tanpa filter work_area
$allPending = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->whereNull('deleted_at')
    ->where('is_scheduled_active', true)
    ->get(['id', 'user_id', 'pickup_address', 'work_area']);

echo "Total pending schedules: " . $allPending->count() . "\n";

// Check user IDs
$userIds = $allPending->pluck('user_id')->unique()->sort();
echo "User IDs in results: " . $userIds->implode(', ') . "\n";

if ($userIds->contains(10)) {
    echo "✅ User Aceng (ID 10) IS in base query\n";
    echo "Problem: Filtering happening in controller logic\n";
} else {
    echo "❌ User Aceng (ID 10) NOT in base query\n";
    echo "Problem: Check is_scheduled_active or deleted_at values\n";
}
```

**B. Check Aceng's Schedules Specifically:**
```php
$acengSchedules = PickupSchedule::where('user_id', 10)
    ->where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->whereNull('deleted_at')
    ->get([
        'id', 
        'user_id', 
        'status', 
        'assigned_mitra_id',
        'is_scheduled_active',
        'pickup_address',
        'work_area',
        'created_at'
    ]);

echo "\n=== User Aceng's Schedules ===\n";
foreach ($acengSchedules as $schedule) {
    echo sprintf(
        "ID: %d | Status: %s | Assigned: %s | Active: %d | Area: %s\n",
        $schedule->id,
        $schedule->status,
        $schedule->assigned_mitra_id ?? 'NULL',
        $schedule->is_scheduled_active,
        $schedule->work_area ?? 'NULL'
    );
}
```

**C. Check Work Area Distribution:**
```php
// See all unique work_areas in pending schedules
$workAreas = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->whereNull('deleted_at')
    ->pluck('work_area')
    ->filter()
    ->unique()
    ->sort();

echo "\n=== Work Areas in Pending Schedules ===\n";
foreach ($workAreas as $area) {
    $count = PickupSchedule::where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('work_area', $area)
        ->count();
    echo "$area: $count schedules\n";
}
```

**D. Simulate Controller Query:**
```php
// Simulate what controller might be doing
$mitra = \App\Models\User::where('email', 'driver.jakarta@gerobaks.com')->first();

echo "\n=== Mitra Info ===\n";
echo "ID: " . $mitra->id . "\n";
echo "Name: " . $mitra->name . "\n";
echo "Work Area: " . ($mitra->work_area ?? 'NULL') . "\n";

// Query WITH work_area filter
$withFilter = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('is_scheduled_active', true)
    ->where('work_area', $mitra->work_area)
    ->get(['id', 'user_id']);

echo "\nWith work_area filter: " . $withFilter->count() . " schedules\n";
echo "User IDs: " . $withFilter->pluck('user_id')->unique()->implode(', ') . "\n";

// Query WITHOUT work_area filter
$withoutFilter = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('is_scheduled_active', true)
    ->get(['id', 'user_id']);

echo "\nWithout work_area filter: " . $withoutFilter->count() . " schedules\n";
echo "User IDs: " . $withoutFilter->pluck('user_id')->unique()->implode(', ') . "\n";
```

---

### Step 3: Check Controller File (5 menit)

**File:** `app/Http/Controllers/Api/MitraPickupScheduleController.php`

Cari method `getAvailableSchedules()` dan periksa:

**❌ REMOVE these if present:**
```php
->where('work_area', $mitra->work_area)
->whereIn('user_id', [1, 2, 3, 4])
->whereRaw("ST_Distance_Sphere(...) < 5000")
```

**✅ SHOULD ONLY HAVE:**
```php
public function getAvailableSchedules(Request $request)
{
    $mitra = $request->user();
    
    $schedules = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at')
        ->orderBy('created_at', 'desc') // Show newest first
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

---

### Step 4: Direct SQL Check (5 menit)

Jalankan langsung di MySQL/PostgreSQL:

```sql
-- 1. Check total pending schedules
SELECT COUNT(*) as total_pending
FROM pickup_schedules
WHERE status = 'pending'
  AND assigned_mitra_id IS NULL
  AND deleted_at IS NULL
  AND is_scheduled_active = 1;

-- Expected: 33 schedules (sesuai yang diklaim backend)

-- 2. Check user distribution
SELECT 
    user_id,
    users.name,
    COUNT(*) as schedule_count
FROM pickup_schedules
LEFT JOIN users ON users.id = pickup_schedules.user_id
WHERE status = 'pending'
  AND assigned_mitra_id IS NULL
  AND deleted_at IS NULL
  AND is_scheduled_active = 1
GROUP BY user_id, users.name
ORDER BY user_id;

-- Expected: Should see user_id 10 (Aceng) with 4 schedules

-- 3. Check work_area distribution
SELECT 
    COALESCE(work_area, 'NULL') as work_area,
    COUNT(*) as count
FROM pickup_schedules
WHERE status = 'pending'
  AND assigned_mitra_id IS NULL
  AND deleted_at IS NULL
  AND is_scheduled_active = 1
GROUP BY work_area
ORDER BY count DESC;

-- 4. Check Aceng's schedules specifically
SELECT 
    id,
    user_id,
    status,
    assigned_mitra_id,
    is_scheduled_active,
    schedule_day,
    waste_type_scheduled,
    pickup_address,
    work_area,
    created_at
FROM pickup_schedules
WHERE user_id = 10
  AND status = 'pending'
  AND assigned_mitra_id IS NULL
  AND deleted_at IS NULL
ORDER BY id;

-- Expected: 4 rows (ID 42, 46, 48, 49)
```

---

## 💡 Recommended Solutions

### Solution 1: Remove Work Area Filter (RECOMMENDED)

**Rationale:** Semua jadwal pending dari semua lokasi harus visible ke semua mitra.

**Implementation:**
```php
// In MitraPickupScheduleController.php

public function getAvailableSchedules(Request $request)
{
    $mitra = $request->user();
    
    $schedules = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at')
        ->orderBy('created_at', 'desc')
        ->paginate(20);
    
    // DO NOT filter by work_area!
    // Let mitra decide which schedules they want to accept
    
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

---

### Solution 2: Optional Work Area Filter (Alternative)

**Rationale:** Jika memang perlu filter by location, buat itu OPTIONAL.

**Implementation:**
```php
public function getAvailableSchedules(Request $request)
{
    $mitra = $request->user();
    
    $query = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at');
    
    // Optional filter by work_area (via query parameter)
    if ($request->has('filter_by_area') && $request->filter_by_area == 'true') {
        if (!empty($mitra->work_area)) {
            $query->where('work_area', $mitra->work_area);
        }
    }
    
    $schedules = $query->orderBy('created_at', 'desc')
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
            ],
            'filters_applied' => [
                'work_area_filter' => $request->has('filter_by_area') ? 'enabled' : 'disabled'
            ]
        ]
    ]);
}
```

Usage:
```bash
# Show all schedules (default)
GET /api/mitra/pickup-schedules/available

# Filter by mitra's work_area only
GET /api/mitra/pickup-schedules/available?filter_by_area=true
```

---

### Solution 3: Distance-Based Filtering (Future Enhancement)

**Rationale:** Filter berdasarkan jarak geografis real.

**Requirements:**
- Perlu lat/long di table `pickup_schedules` dan `users`
- Perlu spatial index di database
- More complex implementation

```php
// Example (requires PostGIS or MySQL spatial extensions):
use Illuminate\Support\Facades\DB;

public function getAvailableSchedules(Request $request)
{
    $mitra = $request->user();
    $maxDistance = $request->input('max_distance_km', 50); // Default 50km
    
    if (empty($mitra->latitude) || empty($mitra->longitude)) {
        // Fallback: show all if mitra location not set
        return $this->getAllAvailableSchedules();
    }
    
    $schedules = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at')
        ->whereRaw(
            "ST_Distance_Sphere(
                POINT(longitude, latitude), 
                POINT(?, ?)
            ) / 1000 <= ?",
            [$mitra->longitude, $mitra->latitude, $maxDistance]
        )
        ->orderBy('created_at', 'desc')
        ->paginate(20);
    
    return response()->json([...]);
}
```

---

## 🧪 Verification Tests

### Test 1: Verify Fix Works

```bash
# 1. Login as mitra
TOKEN=$(curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}' \
  2>/dev/null | jq -r '.data.token')

echo "Token: $TOKEN"

# 2. Get available schedules
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  2>/dev/null | jq '.data.schedules[] | {id, user_id, user_name}'

# 3. Check for diverse user_ids
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '[.data.schedules[].user_id] | unique'

# Expected output should include: [2, 10, ...] (not just [2])
```

### Test 2: Verify Aceng's Schedules Appear

```bash
# Check if Aceng's schedules (ID 42, 46, 48, 49) are in results
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '.data.schedules[] | select(.user_id == 10) | {id, user_name, schedule_day}'

# Expected: Should return 4 schedules from "Aceng as"
```

### Test 3: Check Pagination

```bash
# Page 1
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?page=1" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '.data.pagination'

# Page 2
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?page=2" \
  -H "Authorization: Bearer $TOKEN" \
  2>/dev/null | jq '.data.schedules[] | {id, user_id}'

# Expected: Should see schedules from various users across pages
```

---

## 📊 Expected Results After Fix

### Before Fix:
```json
{
  "data": {
    "schedules": [
      {"id": 8,  "user_id": 2, "user_name": "User Daffa"},
      {"id": 10, "user_id": 2, "user_name": "User Daffa"},
      {"id": 11, "user_id": 2, "user_name": "User Daffa"}
      // All 20 schedules from same user
    ]
  }
}
```

### After Fix:
```json
{
  "data": {
    "schedules": [
      {"id": 49, "user_id": 10, "user_name": "Aceng as"},
      {"id": 48, "user_id": 10, "user_name": "Aceng as"},
      {"id": 46, "user_id": 10, "user_name": "Aceng as"},
      {"id": 42, "user_id": 10, "user_name": "Aceng as"},
      {"id": 11, "user_id": 2,  "user_name": "User Daffa"},
      {"id": 10, "user_id": 2,  "user_name": "User Daffa"},
      {"id": 8,  "user_id": 2,  "user_name": "User Daffa"}
      // Mixed users - showing all pending schedules
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 2,
      "per_page": 20,
      "total": 33
    }
  }
}
```

---

## 🎯 Action Items

### Backend Team - URGENT:

- [ ] **Run tinker diagnostics** (Step 2) - Share results
- [ ] **Check controller file** (Step 3) - Identify filtering logic
- [ ] **Enable query logging** (Step 1) - Share SQL query
- [ ] **Run SQL checks** (Step 4) - Verify database state
- [ ] **Implement Solution 1** (recommended) - Remove work_area filter
- [ ] **Test with verification steps** - Confirm fix works
- [ ] **Deploy to staging** - Ready for frontend testing
- [ ] **Update API documentation** - Document expected behavior

### Frontend Team - After Backend Fix:

- [ ] Hot reload Flutter app
- [ ] Login as mitra
- [ ] Check "Tersedia" tab shows diverse users
- [ ] Verify Aceng's schedules visible
- [ ] Test pagination (page 1, 2, 3...)
- [ ] Test complete workflow: view → accept → track
- [ ] Mark as Production Ready ✅

---

## 📞 Contact & Questions

**Jika ada pertanyaan tentang issue ini:**

**Frontend Developer:** Available for clarification
- Test credentials ready
- Flutter app ready for testing
- Documentation complete

**Backend Developer:** Please investigate ASAP
- All diagnostic steps provided above
- Multiple solution options available
- Critical blocker for production launch

**Timeline:** This is a **CRITICAL BLOCKER** - system cannot go to production until fixed.

**Expected Resolution Time:** 1-2 hours (investigation + fix + testing)

---

## 📎 Related Documentation

- [BUGFIX_USER_ID_TYPE_CASTING.md](./BUGFIX_USER_ID_TYPE_CASTING.md) - Type casting issues (RESOLVED)
- [FIX_MITRA_PASSWORDS.md](./FIX_MITRA_PASSWORDS.md) - Password issues (RESOLVED - use password123)
- [BACKEND_FIX_QUICK_REFERENCE.md](./BACKEND_FIX_QUICK_REFERENCE.md) - Quick reference guide
- [TESTING_GUIDE_MITRA_PICKUP.md](./TESTING_GUIDE_MITRA_PICKUP.md) - Complete testing guide

---

**Generated:** 13 November 2025  
**Version:** 1.0  
**Status:** 🔴 ACTIVE CRITICAL ISSUE
