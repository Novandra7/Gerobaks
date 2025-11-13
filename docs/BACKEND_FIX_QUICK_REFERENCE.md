# ⚡ Quick Fix Reference - Backend Mitra Pickup

**File**: `app/Http/Controllers/Api/MitraPickupController.php`  
**Method**: `getAvailableSchedules()`  
**Estimasi**: 15-30 menit

**Status Update (13 Nov 2025, 18:30)**:
- ✅ Backend claim sudah fix - return 33 schedules
- ❌ Password mitra tidak berfungsi - BLOCKER untuk testing
- ❓ Belum bisa verify jadwal user Aceng muncul atau tidak

---

## ❌ BEFORE (Bug)

```php
public function getAvailableSchedules(Request $request)
{
    $mitra = auth()->user();
    
    // ❌ BUG: Filter work_area terlalu restrictive
    $schedules = PickupSchedule::with(['user'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('work_area', $mitra->work_area)  // ← HAPUS INI!
        ->get();
    
    return response()->json([
        'success' => true,
        'data' => ['schedules' => $schedules]
    ]);
}
```

**Masalah**: User di "San Francisco" tidak match dengan mitra "Jakarta Pusat"

---

## ✅ AFTER (Fixed)

```php
public function getAvailableSchedules(Request $request)
{
    // Get pagination parameters
    $perPage = $request->get('per_page', 20);
    
    // Query all pending schedules (no work_area filter!)
    $schedules = PickupSchedule::with(['user'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->whereNull('deleted_at')
        ->where('is_scheduled_active', true)
        ->orderBy('scheduled_pickup_at', 'asc')
        ->paginate($perPage);
    
    return response()->json([
        'success' => true,
        'message' => 'Available schedules retrieved successfully',
        'data' => [
            'schedules' => $schedules->items(),
            'total' => $schedules->total(),
            'current_page' => $schedules->currentPage(),
            'last_page' => $schedules->lastPage(),
            'per_page' => $schedules->perPage(),
        ]
    ]);
}
```

**Key Changes:**
1. ✅ HAPUS filter `work_area`
2. ✅ Tambahkan filter `is_scheduled_active = true`
3. ✅ Tambahkan pagination
4. ✅ Tambahkan order by `scheduled_pickup_at`
5. ✅ Response format yang konsisten

---

## 🧪 Test Query

### Test di Tinker:

```php
php artisan tinker

// Cek jumlah pending schedules
$count = \App\Models\PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->count();
    
echo "Total pending: $count\n";  // Harusnya > 0

// Cek detail
$schedules = \App\Models\PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->get(['id', 'user_id', 'status', 'schedule_day', 'pickup_address']);
    
$schedules->each(function($s) {
    echo "ID: {$s->id} | User: {$s->user_id} | Day: {$s->schedule_day}\n";
});
```

### Test via curl:

```bash
# 1. Login as mitra
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}' \
  | jq -r '.data.token')

# 2. Get available schedules
curl -X GET http://127.0.0.1:8000/api/mitra/pickup-schedules/available \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data.schedules | length'

# Expected: angka > 0 (minimal 2)
```

---

## 🐛 Debugging Tips

### Add Logging:

```php
public function getAvailableSchedules(Request $request)
{
    Log::channel('daily')->info('=== AVAILABLE SCHEDULES DEBUG ===');
    
    // Check total in DB
    $totalInDb = PickupSchedule::where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->count();
    
    Log::info("Total pending in DB: $totalInDb");
    
    // Run query
    $schedules = PickupSchedule::with(['user'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->whereNull('deleted_at')
        ->where('is_scheduled_active', true)
        ->get();
    
    Log::info("Schedules returned: " . $schedules->count());
    
    if ($schedules->isEmpty()) {
        Log::warning("⚠️ No schedules found but DB has $totalInDb pending!");
    }
    
    // ... rest of code
}
```

### Check Logs:

```bash
tail -f storage/logs/laravel.log | grep "AVAILABLE SCHEDULES"
```

---

## ✅ Verification Checklist

Setelah deploy fix, pastikan:

- [ ] Query SQL di tinker return > 0 jadwal
- [ ] curl test return array tidak kosong
- [ ] Flutter app menampilkan jadwal di tab "Tersedia"
- [ ] Mitra bisa tap dan lihat detail jadwal
- [ ] Mitra bisa accept jadwal

---

## 📋 SQL Queries untuk Debug

```sql
-- 1. Cek berapa pending
SELECT COUNT(*) as total_pending
FROM pickup_schedules 
WHERE status = 'pending' 
  AND assigned_mitra_id IS NULL 
  AND deleted_at IS NULL;

-- 2. Lihat detail pending
SELECT id, user_id, status, assigned_mitra_id, 
       schedule_day, scheduled_pickup_at, 
       pickup_address, created_at
FROM pickup_schedules 
WHERE status = 'pending' 
  AND assigned_mitra_id IS NULL 
  AND deleted_at IS NULL
ORDER BY created_at DESC;

-- 3. Cek user info
SELECT ps.id, ps.status, u.name, u.phone, ps.pickup_address
FROM pickup_schedules ps
JOIN users u ON ps.user_id = u.id
WHERE ps.status = 'pending' 
  AND ps.assigned_mitra_id IS NULL;
```

---

## 🚀 Deployment Steps

1. **Backup Controller**
   ```bash
   cp app/Http/Controllers/Api/MitraPickupController.php \
      app/Http/Controllers/Api/MitraPickupController.php.backup
   ```

2. **Apply Fix**
   - Edit `getAvailableSchedules()` method
   - Remove work_area filter
   - Add pagination

3. **Clear Cache**
   ```bash
   php artisan config:clear
   php artisan cache:clear
   php artisan route:clear
   ```

4. **Test**
   ```bash
   # Run tinker test
   php artisan tinker
   # Run curl test
   ```

5. **Monitor Logs**
   ```bash
   tail -f storage/logs/laravel.log
   ```

---

## 📞 Rollback Plan

Jika ada masalah:

```bash
# Restore backup
cp app/Http/Controllers/Api/MitraPickupController.php.backup \
   app/Http/Controllers/Api/MitraPickupController.php

# Clear cache
php artisan config:clear
```

---

## ✅ Success Criteria

Fix dianggap berhasil jika:

1. ✅ curl test return array > 0
2. ✅ Flutter app tab "Tersedia" menampilkan jadwal
3. ✅ Tidak ada error di laravel.log
4. ✅ Mitra bisa accept jadwal

---

**Estimasi Total**: 30 menit (15 menit coding + 15 menit testing)

**Last Updated**: November 13, 2025
