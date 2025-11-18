# 🔧 Backend API Fix - Pemisahan Status untuk Tab Aktif dan Riwayat

## 📋 Problem Statement

Saat ini, jadwal dengan status `on_progress` muncul di tab **Riwayat**, padahal seharusnya hanya muncul di tab **Aktif**. Tab Riwayat seharusnya hanya menampilkan jadwal yang sudah selesai (`completed`) atau dibatalkan (`cancelled`).

### Screenshot Issue:
- Status "ON PROGRESS" berwarna hijau
- Status "ON PROGRESS" muncul di tab Riwayat
- Seharusnya status ini tetap di tab Aktif dengan warna biru

---

## 🎯 Solution Required

### 1. **Endpoint: `/api/mitra/pickup-schedules/my-active`**

**Current Behavior:** ❌
- Mungkin hanya menampilkan status `pending`
- Atau tidak konsisten dalam mengembalikan status `on_progress`

**Expected Behavior:** ✅
```php
// Harus mengembalikan jadwal dengan status:
$activeStatuses = ['pending', 'on_progress'];

$schedules = PickupSchedule::where('mitra_id', auth()->id())
    ->whereIn('status', $activeStatuses)
    ->orderBy('scheduled_at', 'asc')
    ->get();
```

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "user_name": "John Doe",
      "status": "on_progress",  // ← Status ini harus berwarna BIRU di frontend
      "scheduled_at": "2025-11-14T08:00:00Z",
      // ... field lainnya
    }
  ]
}
```

---

### 2. **Endpoint: `/api/mitra/pickup-schedules/history`**

**Current Behavior:** ❌
- Mengembalikan semua status termasuk `on_progress`
- Tidak ada filter status yang proper

**Expected Behavior:** ✅
```php
// Harus HANYA mengembalikan jadwal dengan status completed atau cancelled
$historyStatuses = ['completed', 'cancelled'];

$schedules = PickupSchedule::where('mitra_id', auth()->id())
    ->whereIn('status', $historyStatuses)
    ->orderBy('completed_at', 'desc') // atau updated_at
    ->paginate($perPage);
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 456,
        "user_name": "Jane Smith",
        "status": "completed",  // ← HANYA completed atau cancelled
        "completed_at": "2025-11-13T15:30:00Z",
        // ... field lainnya
      }
    ],
    "pagination": {
      "total": 10,
      "current_page": 1,
      "per_page": 20
    }
  }
}
```

---

## 📊 Status Flow & Color Mapping

### Status Lifecycle:
```
1. PENDING (Orange #FF8C00)
   ↓ Mitra accepts schedule
   
2. ON_PROGRESS (Blue #53C1F9)  ← Harus tetap di Tab Aktif!
   ↓ Mitra completes pickup
   
3. COMPLETED (Green #00BB38)  ← Pindah ke Tab Riwayat
```

### Alternative Flow:
```
1. PENDING → 2. ON_PROGRESS → CANCELLED (Red #F30303) → Tab Riwayat
```

---

## 🔍 Validation Checklist

Setelah fix diterapkan, pastikan:

### ✅ Tab Aktif (`/api/mitra/pickup-schedules/my-active`)
- [ ] Menampilkan status `pending` (orange)
- [ ] Menampilkan status `on_progress` (blue)
- [ ] TIDAK menampilkan status `completed`
- [ ] TIDAK menampilkan status `cancelled`

### ✅ Tab Riwayat (`/api/mitra/pickup-schedules/history`)
- [ ] Menampilkan status `completed` (green)
- [ ] Menampilkan status `cancelled` (red)
- [ ] TIDAK menampilkan status `pending`
- [ ] TIDAK menampilkan status `on_progress`

---

## 💻 Sample Laravel Controller Code

### PickupScheduleController.php

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use Illuminate\Http\Request;

class PickupScheduleController extends Controller
{
    /**
     * Get mitra's active schedules
     * Should only return: pending, on_progress
     */
    public function myActive()
    {
        try {
            $mitra = auth()->user();
            
            $schedules = PickupSchedule::where('mitra_id', $mitra->id)
                ->whereIn('status', ['pending', 'on_progress'])
                ->with(['user', 'wasteTypes'])
                ->orderBy('scheduled_at', 'asc')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Active schedules retrieved successfully',
                'data' => $schedules
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve active schedules',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get mitra's history (completed/cancelled schedules)
     * Should only return: completed, cancelled
     */
    public function history(Request $request)
    {
        try {
            $mitra = auth()->user();
            $perPage = $request->input('per_page', 20);
            
            $schedules = PickupSchedule::where('mitra_id', $mitra->id)
                ->whereIn('status', ['completed', 'cancelled'])
                ->with(['user', 'wasteTypes', 'pickupPhotos'])
                ->orderBy('updated_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'message' => 'History retrieved successfully',
                'data' => [
                    'schedules' => $schedules->items(),
                    'pagination' => [
                        'total' => $schedules->total(),
                        'current_page' => $schedules->currentPage(),
                        'per_page' => $schedules->perPage(),
                        'last_page' => $schedules->lastPage(),
                        'from' => $schedules->firstItem(),
                        'to' => $schedules->lastItem(),
                    ]
                ]
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve history',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
```

---

## 🧪 Testing Commands

### Test Active Schedules Endpoint:
```bash
# Login dan get token
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}' \
  | jq -r '.data.token')

# Test my-active endpoint
curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/my-active" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  | jq '.data[] | {id, status, user_name}'

# Expected: Hanya status "pending" dan "on_progress"
```

### Test History Endpoint:
```bash
# Test history endpoint
curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1&per_page=5" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  | jq '.data.schedules[] | {id, status, user_name}'

# Expected: Hanya status "completed" dan "cancelled"
```

---

## 📝 Database Migration (Jika Diperlukan)

Jika kolom `status` belum memiliki index atau constraint yang benar:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            // Add index for better query performance
            $table->index(['mitra_id', 'status']);
            
            // Optional: Add check constraint for valid statuses
            DB::statement("
                ALTER TABLE pickup_schedules 
                ADD CONSTRAINT check_status 
                CHECK (status IN ('pending', 'on_progress', 'completed', 'cancelled'))
            ");
        });
    }

    public function down()
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            $table->dropIndex(['mitra_id', 'status']);
            DB::statement("ALTER TABLE pickup_schedules DROP CONSTRAINT check_status");
        });
    }
};
```

---

## 🎨 Frontend Color Reference

Untuk memastikan konsistensi warna, berikut referensi warna yang digunakan di frontend:

```dart
// Status Colors (from theme.dart)
pending:      #FF8C00  // orangeColor
on_progress:  #53C1F9  // blueColor
completed:    #00BB38  // greenColor
cancelled:    #F30303  // redcolor
```

---

## ⚠️ Important Notes

1. **Status Field**: Pastikan field `status` di database menggunakan nilai yang konsisten:
   - ✅ `on_progress` (dengan underscore)
   - ❌ BUKAN `in_progress`, `onprogress`, atau variasi lainnya

2. **Migration Plan**: 
   - Jika ada data existing dengan status yang salah, buat script untuk update
   - Backup database sebelum migration

3. **API Versioning**: 
   - Jika ini breaking change, pertimbangkan versioning API
   - Atau update dokumentasi API dengan jelas

4. **Cache Clearing**:
   ```bash
   php artisan cache:clear
   php artisan config:clear
   php artisan route:clear
   ```

---

## 📞 Questions?

Jika ada pertanyaan atau butuh klarifikasi lebih lanjut:
- Frontend: Status sudah siap dengan warna yang benar
- Backend: Perlu fix filter di 2 endpoint (my-active & history)
- Testing: Gunakan curl commands di atas untuk validasi

---

## ✅ TESTING RESULTS - BACKEND VERIFIED

**Test Date**: November 14, 2025  
**Test Environment**: Local (http://127.0.0.1:8000)  
**Test Credentials**: driver.jakarta@gerobaks.com

### Test 1: Active Tab Endpoint ✅
```bash
GET /api/mitra/pickup-schedules/my-active
```
**Result**: ✅ PASSED
- Returns only schedules with status `pending` and `on_progress`
- No `completed` or `cancelled` found in response
- Response structure: `{success: true, data: {schedules: [...]}}`

### Test 2: History Tab Endpoint ✅
```bash
GET /api/mitra/pickup-schedules/history?per_page=10
```
**Result**: ✅ PASSED
- Returns only schedules with status `completed` and `cancelled`
- No `pending` or `on_progress` found in response
- Response structure: `{success: true, data: {schedules: [...], pagination: {...}}}`

### Sample Response - History Tab:
```json
{
  "id": 54,
  "status": "completed",
  "user_name": "ali"
}
```

### Conclusion:
✅ **BACKEND IMPLEMENTATION: COMPLETE**
- Tab separation logic correctly implemented
- Filter by status working as expected
- No on_progress items in history tab
- No completed items in active tab

---

**Last Updated**: 2025-11-14
**Version**: 1.1 (Tested & Verified ✅)
**Priority**: HIGH 🔴
**Status**: BACKEND COMPLETE - FRONTEND UPDATED
