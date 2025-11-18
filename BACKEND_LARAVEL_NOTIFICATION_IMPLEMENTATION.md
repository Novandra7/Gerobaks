# 🚀 Backend Laravel - Notification System Implementation

**Project:** Gerobaks - User App Notification System  
**Date:** November 17, 2025  
**Purpose:** User app akan polling status perubahan jadwal dan menampilkan notifikasi banner saat mitra accept/complete jadwal  

---

## 📋 Overview

### **Sistem Notifikasi:**
- ✅ **Flutter App** polling API setiap 30 detik
- ✅ **No Firebase/Pusher** - Pure polling based
- ✅ **Banner notification** muncul dari atas ke bawah
- ✅ **Status tracking:** pending → accepted → on_the_way → arrived → completed

### **User Experience:**
1. User create jadwal → Status: `pending`
2. Mitra terima jadwal → Status: `accepted` → **🔔 Banner muncul: "Jadwal Diterima!"**
3. Mitra on the way → Status: `on_the_way` → **🔔 Banner: "Mitra Sedang Menuju Lokasi"**
4. Mitra arrived → Status: `arrived` → **🔔 Banner: "Mitra Sudah Tiba"**
5. Mitra complete → Status: `completed` → **🔔 Banner: "Penjemputan Selesai"**

---

## 🎯 Required Backend Changes

### **1. API Endpoint Must Exist**

**Endpoint:** `GET /api/user/pickup-schedules`

**Headers:**
```
Authorization: Bearer {user_token}
Accept: application/json
```

**Purpose:**
- Flutter app memanggil endpoint ini setiap 30 detik
- Untuk detect perubahan status jadwal
- Hanya return jadwal milik user yang login

---

## 📊 API Response Format

### **Required Response Structure:**

```json
{
  "success": true,
  "message": "Pickup schedules retrieved successfully",
  "data": [
    {
      "id": 75,
      "user_id": 15,
      "status": "accepted",
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Selatan",
      "scheduled_pickup_at": "2025-11-17 10:28:00",
      "schedule_day": "Minggu, 17 Nov 2025",
      "pickup_time_start": "10:28",
      "mitra_id": 8,
      "mitra_name": "John Doe",
      "mitra_phone": "081234567890",
      "total_weight_kg": null,
      "total_points": null,
      "created_at": "2025-11-17T08:15:00.000000Z",
      "updated_at": "2025-11-17T09:30:00.000000Z"
    },
    {
      "id": 74,
      "user_id": 15,
      "status": "completed",
      "pickup_address": "Jl. Thamrin No. 45",
      "scheduled_pickup_at": "2025-11-16 14:00:00",
      "schedule_day": "Sabtu, 16 Nov 2025",
      "pickup_time_start": "14:00",
      "mitra_id": 5,
      "mitra_name": "Jane Smith",
      "mitra_phone": "081987654321",
      "total_weight_kg": 5.5,
      "total_points": 550,
      "created_at": "2025-11-16T10:00:00.000000Z",
      "updated_at": "2025-11-16T15:30:00.000000Z"
    }
  ]
}
```

---

## 🔑 Critical Fields

### **Must Have Fields:**

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `id` | integer | ✅ | Schedule ID | 75 |
| `status` | string | ✅ | Status jadwal | "accepted" |
| `pickup_address` | string | ✅ | Alamat penjemputan | "Jl. Sudirman..." |
| `schedule_day` | string | ✅ | Hari formatted (Indonesia) | "Minggu, 17 Nov 2025" |
| `pickup_time_start` | string | ✅ | Jam pickup (HH:mm) | "10:28" |

### **Optional But Recommended:**

| Field | Type | When Needed | Description |
|-------|------|-------------|-------------|
| `mitra_id` | integer | When accepted+ | ID mitra yang terima |
| `mitra_name` | string | When accepted+ | Nama mitra |
| `mitra_phone` | string | When accepted+ | No HP mitra |
| `total_weight_kg` | decimal | When completed | Total berat sampah |
| `total_points` | integer | When completed | Total poin earned |

---

## 💾 Database Schema

### **Table: `pickup_schedules`**

Pastikan table sudah ada field berikut:

```sql
CREATE TABLE pickup_schedules (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    mitra_id BIGINT UNSIGNED NULL,
    status ENUM('pending', 'accepted', 'on_the_way', 'arrived', 'completed', 'cancelled') DEFAULT 'pending',
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8) NULL,
    pickup_longitude DECIMAL(11, 8) NULL,
    scheduled_pickup_at DATETIME NOT NULL,
    total_weight_kg DECIMAL(8, 2) NULL,
    total_points INT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mitra_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_scheduled_pickup_at (scheduled_pickup_at)
);
```

### **Important:**
- ✅ `status` harus ENUM dengan values exact: `pending`, `accepted`, `on_the_way`, `arrived`, `completed`, `cancelled`
- ✅ `updated_at` harus auto-update saat status berubah
- ✅ `scheduled_pickup_at` dalam format DATETIME

---

## 🎨 Laravel Model Implementation

### **File: `app/Models/PickupSchedule.php`**

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class PickupSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'mitra_id',
        'status',
        'pickup_address',
        'pickup_latitude',
        'pickup_longitude',
        'scheduled_pickup_at',
        'total_weight_kg',
        'total_points',
        'notes',
    ];

    protected $casts = [
        'scheduled_pickup_at' => 'datetime',
        'total_weight_kg' => 'decimal:2',
        'total_points' => 'integer',
    ];

    /**
     * Relationship dengan User (yang request pickup)
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Relationship dengan Mitra (yang terima pickup)
     */
    public function mitra()
    {
        return $this->belongsTo(User::class, 'mitra_id');
    }

    /**
     * Accessor untuk format hari dalam Bahasa Indonesia
     * Format: "Minggu, 17 Nov 2025"
     */
    public function getScheduleDayAttribute()
    {
        // Set locale ke Indonesia
        Carbon::setLocale('id');
        
        $date = Carbon::parse($this->scheduled_pickup_at);
        
        // Format: Hari, Tanggal Bulan Tahun
        // Contoh: Minggu, 17 Nov 2025
        return $date->translatedFormat('l, d M Y');
    }

    /**
     * Accessor untuk format jam pickup
     * Format: "10:28" (HH:mm)
     */
    public function getPickupTimeStartAttribute()
    {
        $date = Carbon::parse($this->scheduled_pickup_at);
        return $date->format('H:i');
    }

    /**
     * Accessor untuk nama mitra
     */
    public function getMitraNameAttribute()
    {
        return $this->mitra ? $this->mitra->name : null;
    }

    /**
     * Accessor untuk phone mitra
     */
    public function getMitraPhoneAttribute()
    {
        return $this->mitra ? $this->mitra->phone : null;
    }

    /**
     * Scope untuk filter by user
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope untuk filter by status
     */
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope untuk jadwal aktif (belum completed/cancelled)
     */
    public function scopeActive($query)
    {
        return $query->whereIn('status', ['pending', 'accepted', 'on_the_way', 'arrived']);
    }
}
```

---

## 🎯 Controller Implementation

### **File: `app/Http/Controllers/Api/User/PickupScheduleController.php`**

```php
<?php

namespace App\Http\Controllers\Api\User;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use Illuminate\Http\Request;

class PickupScheduleController extends Controller
{
    /**
     * Get user's pickup schedules
     * Endpoint untuk polling dari Flutter app
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        try {
            $user = $request->user();

            // Get semua jadwal user, sorted by newest
            $schedules = PickupSchedule::forUser($user->id)
                ->with('mitra:id,name,phone') // Eager load mitra data
                ->orderBy('scheduled_pickup_at', 'desc')
                ->orderBy('created_at', 'desc')
                ->get();

            // Transform data dengan accessors
            $data = $schedules->map(function ($schedule) {
                return [
                    'id' => $schedule->id,
                    'user_id' => $schedule->user_id,
                    'status' => $schedule->status,
                    'pickup_address' => $schedule->pickup_address,
                    'pickup_latitude' => $schedule->pickup_latitude,
                    'pickup_longitude' => $schedule->pickup_longitude,
                    'scheduled_pickup_at' => $schedule->scheduled_pickup_at->toIso8601String(),
                    
                    // Formatted fields untuk display
                    'schedule_day' => $schedule->schedule_day,        // "Minggu, 17 Nov 2025"
                    'pickup_time_start' => $schedule->pickup_time_start, // "10:28"
                    
                    // Mitra info (null jika belum ada mitra)
                    'mitra_id' => $schedule->mitra_id,
                    'mitra_name' => $schedule->mitra_name,
                    'mitra_phone' => $schedule->mitra_phone,
                    
                    // Completion data (null jika belum completed)
                    'total_weight_kg' => $schedule->total_weight_kg,
                    'total_points' => $schedule->total_points,
                    
                    'notes' => $schedule->notes,
                    'created_at' => $schedule->created_at->toIso8601String(),
                    'updated_at' => $schedule->updated_at->toIso8601String(),
                ];
            });

            return response()->json([
                'success' => true,
                'message' => 'Pickup schedules retrieved successfully',
                'data' => $data
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve pickup schedules',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get active schedules only (belum completed)
     * Optional endpoint untuk optimasi
     */
    public function active(Request $request)
    {
        try {
            $user = $request->user();

            $schedules = PickupSchedule::forUser($user->id)
                ->active() // Only pending, accepted, on_the_way, arrived
                ->with('mitra:id,name,phone')
                ->orderBy('scheduled_pickup_at', 'desc')
                ->get();

            $data = $schedules->map(function ($schedule) {
                return [
                    'id' => $schedule->id,
                    'status' => $schedule->status,
                    'pickup_address' => $schedule->pickup_address,
                    'schedule_day' => $schedule->schedule_day,
                    'pickup_time_start' => $schedule->pickup_time_start,
                    'mitra_id' => $schedule->mitra_id,
                    'mitra_name' => $schedule->mitra_name,
                    'mitra_phone' => $schedule->mitra_phone,
                    'updated_at' => $schedule->updated_at->toIso8601String(),
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
```

---

## 🛣️ Routes Configuration

### **File: `routes/api.php`**

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\User\PickupScheduleController;
use App\Http\Controllers\Api\Mitra\MitraPickupController;

// User routes (authenticated dengan Sanctum/JWT)
Route::middleware(['auth:sanctum', 'role:end_user'])->prefix('user')->group(function () {
    
    // Pickup schedules
    Route::get('/pickup-schedules', [PickupScheduleController::class, 'index']);
    Route::get('/pickup-schedules/active', [PickupScheduleController::class, 'active']);
    
    // ... other user routes
});

// Mitra routes
Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    
    // Accept schedule (ini yang trigger status change)
    Route::post('/pickup-schedules/{id}/accept', [MitraPickupController::class, 'acceptSchedule']);
    Route::post('/pickup-schedules/{id}/on-the-way', [MitraPickupController::class, 'onTheWay']);
    Route::post('/pickup-schedules/{id}/arrived', [MitraPickupController::class, 'arrived']);
    Route::post('/pickup-schedules/{id}/complete', [MitraPickupController::class, 'complete']);
    
    // ... other mitra routes
});
```

---

## 🔄 Mitra Controller (Update Status)

### **File: `app/Http/Controllers/Api/Mitra/MitraPickupController.php`**

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use Illuminate\Http\Request;

class MitraPickupController extends Controller
{
    /**
     * Mitra accept schedule
     * Status: pending → accepted
     */
    public function acceptSchedule(Request $request, $id)
    {
        try {
            $mitra = $request->user();
            
            $schedule = PickupSchedule::findOrFail($id);
            
            // Validasi: hanya bisa accept jika status pending
            if ($schedule->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Schedule already ' . $schedule->status
                ], 400);
            }

            // Update status
            $schedule->update([
                'status' => 'accepted',
                'mitra_id' => $mitra->id,
            ]);

            // PENTING: updated_at akan auto-update
            // Flutter app akan detect perubahan ini!

            return response()->json([
                'success' => true,
                'message' => 'Schedule accepted successfully',
                'data' => [
                    'id' => $schedule->id,
                    'status' => $schedule->status,
                    'mitra_id' => $schedule->mitra_id,
                    'updated_at' => $schedule->updated_at->toIso8601String(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to accept schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mitra on the way
     * Status: accepted → on_the_way
     */
    public function onTheWay(Request $request, $id)
    {
        try {
            $mitra = $request->user();
            $schedule = PickupSchedule::findOrFail($id);

            // Validasi: hanya mitra yang accept yang bisa update
            if ($schedule->mitra_id !== $mitra->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            if ($schedule->status !== 'accepted') {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid status transition'
                ], 400);
            }

            $schedule->update(['status' => 'on_the_way']);

            return response()->json([
                'success' => true,
                'message' => 'Status updated to on the way',
                'data' => [
                    'id' => $schedule->id,
                    'status' => $schedule->status,
                    'updated_at' => $schedule->updated_at->toIso8601String(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mitra arrived
     * Status: on_the_way → arrived
     */
    public function arrived(Request $request, $id)
    {
        try {
            $mitra = $request->user();
            $schedule = PickupSchedule::findOrFail($id);

            if ($schedule->mitra_id !== $mitra->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            if ($schedule->status !== 'on_the_way') {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid status transition'
                ], 400);
            }

            $schedule->update(['status' => 'arrived']);

            return response()->json([
                'success' => true,
                'message' => 'Mitra has arrived',
                'data' => [
                    'id' => $schedule->id,
                    'status' => $schedule->status,
                    'updated_at' => $schedule->updated_at->toIso8601String(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Complete pickup
     * Status: arrived → completed
     */
    public function complete(Request $request, $id)
    {
        $request->validate([
            'total_weight_kg' => 'required|numeric|min:0.1|max:1000',
            'notes' => 'nullable|string|max:1000',
        ]);

        try {
            $mitra = $request->user();
            $schedule = PickupSchedule::findOrFail($id);

            if ($schedule->mitra_id !== $mitra->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            if ($schedule->status !== 'arrived') {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid status transition'
                ], 400);
            }

            // Calculate points (contoh: 100 poin per kg)
            $totalPoints = (int) ($request->total_weight_kg * 100);

            $schedule->update([
                'status' => 'completed',
                'total_weight_kg' => $request->total_weight_kg,
                'total_points' => $totalPoints,
                'notes' => $request->notes,
            ]);

            // TODO: Update user points balance

            return response()->json([
                'success' => true,
                'message' => 'Pickup completed successfully',
                'data' => [
                    'id' => $schedule->id,
                    'status' => $schedule->status,
                    'total_weight_kg' => $schedule->total_weight_kg,
                    'total_points' => $schedule->total_points,
                    'updated_at' => $schedule->updated_at->toIso8601String(),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
```

---

## 🧪 Testing Guide

### **Test 1: Get User Schedules**

```bash
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer {USER_TOKEN}" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Pickup schedules retrieved successfully",
  "data": [
    {
      "id": 75,
      "status": "pending",
      "pickup_address": "Jl. Sudirman No. 123",
      "schedule_day": "Minggu, 17 Nov 2025",
      "pickup_time_start": "10:28",
      "mitra_id": null,
      "mitra_name": null,
      "mitra_phone": null,
      "total_weight_kg": null,
      "total_points": null
    }
  ]
}
```

---

### **Test 2: Mitra Accept Schedule**

```bash
curl -X POST "http://localhost:8000/api/mitra/pickup-schedules/75/accept" \
  -H "Authorization: Bearer {MITRA_TOKEN}" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Schedule accepted successfully",
  "data": {
    "id": 75,
    "status": "accepted",
    "mitra_id": 8,
    "updated_at": "2025-11-17T09:30:00.000000Z"
  }
}
```

---

### **Test 3: Check Status Change (User)**

```bash
# Panggil lagi endpoint user
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer {USER_TOKEN}" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "status": "accepted",  // ✅ Changed!
      "schedule_day": "Minggu, 17 Nov 2025",
      "pickup_time_start": "10:28",
      "mitra_id": 8,
      "mitra_name": "John Doe",
      "mitra_phone": "081234567890",
      "updated_at": "2025-11-17T09:30:00.000000Z"  // ✅ Updated!
    }
  ]
}
```

**Flutter app akan detect:**
- Old status: `pending`
- New status: `accepted`
- **🔔 Banner muncul: "Jadwal Diterima! 🎉"**

---

## ✅ Checklist Implementation

### **Backend Requirements:**

- [ ] **Database Schema**
  - [ ] Table `pickup_schedules` exists
  - [ ] Column `status` is ENUM with correct values
  - [ ] Column `updated_at` auto-updates on change
  - [ ] Foreign keys to `users` table

- [ ] **Model Implementation**
  - [ ] `PickupSchedule` model exists
  - [ ] Accessor `schedule_day` returns Indonesian format
  - [ ] Accessor `pickup_time_start` returns HH:mm format
  - [ ] Accessor `mitra_name` and `mitra_phone` work
  - [ ] Relationships to User/Mitra defined

- [ ] **API Endpoints**
  - [ ] `GET /api/user/pickup-schedules` exists
  - [ ] Requires authentication (Sanctum/JWT)
  - [ ] Returns correct JSON format
  - [ ] Fields `schedule_day` and `pickup_time_start` present

- [ ] **Mitra Actions**
  - [ ] `POST /api/mitra/pickup-schedules/{id}/accept` exists
  - [ ] Updates `status` to 'accepted'
  - [ ] Sets `mitra_id`
  - [ ] Auto-updates `updated_at`

- [ ] **Status Transitions**
  - [ ] pending → accepted (mitra accept)
  - [ ] accepted → on_the_way (mitra on the way)
  - [ ] on_the_way → arrived (mitra arrived)
  - [ ] arrived → completed (mitra complete with weight)

---

## 🔍 Common Issues

### **Issue 1: Format Tanggal Salah**

**Problem:** `schedule_day` return "Sunday, 17 Nov 2025" (English)

**Solution:**
```php
// Set locale di Model atau AppServiceProvider
Carbon::setLocale('id');

// Atau di config/app.php
'locale' => 'id',
```

---

### **Issue 2: Field `schedule_day` Tidak Ada**

**Problem:** Response tidak include accessor fields

**Solution:**
```php
// Di Controller, manual build array dengan accessor:
'schedule_day' => $schedule->schedule_day,
'pickup_time_start' => $schedule->pickup_time_start,

// Atau tambahkan ke $appends di Model:
protected $appends = ['schedule_day', 'pickup_time_start', 'mitra_name', 'mitra_phone'];
```

---

### **Issue 3: updated_at Tidak Update**

**Problem:** Status berubah tapi `updated_at` tetap

**Solution:**
```php
// Pastikan di migration:
$table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

// Atau di Model:
public $timestamps = true;

// Atau force touch:
$schedule->update(['status' => 'accepted']);
$schedule->touch(); // Force update timestamp
```

---

## 📱 How Flutter App Consumes This

### **Polling Flow:**

```
Every 30 seconds:
  1. Flutter call: GET /api/user/pickup-schedules
  2. Get response data
  3. Compare dengan cache:
     - If schedule count changed → New schedule notification
     - If status changed → Status change notification
  4. Update cache
  5. Show banner if changes detected
```

### **Example Status Change Detection:**

```dart
// Old cache
{ "id": 75, "status": "pending", "updated_at": "2025-11-17T08:00:00Z" }

// New response (after 30s)
{ "id": 75, "status": "accepted", "updated_at": "2025-11-17T09:30:00Z" }

// Flutter detect:
OLD STATUS: pending
NEW STATUS: accepted
→ Show banner: "Jadwal Diterima! 🎉"
```

---

## 🚀 Performance Optimization

### **Recommendations:**

1. **Add Index untuk Polling:**
```sql
CREATE INDEX idx_user_status ON pickup_schedules(user_id, status);
CREATE INDEX idx_updated_at ON pickup_schedules(updated_at);
```

2. **Cache Mitra Data:**
```php
// Di Controller, eager load mitra
->with('mitra:id,name,phone')
```

3. **Limit Results (Optional):**
```php
// Only return last 30 days
$schedules = PickupSchedule::forUser($user->id)
    ->where('created_at', '>=', now()->subDays(30))
    ->get();
```

4. **Rate Limiting:**
```php
// Di routes/api.php
Route::middleware(['throttle:120,1'])->group(function () {
    // 120 requests per minute (polling every 30s = 2 req/min per user)
});
```

---

## 📞 Support & Testing

### **Share with Backend Team:**

1. ✅ Implementasi semua endpoints di atas
2. ✅ Test dengan Postman/curl
3. ✅ Verify response format exact seperti contoh
4. ✅ Verify `schedule_day` dalam Bahasa Indonesia
5. ✅ Verify `updated_at` auto-update saat status change

### **Testing Checklist:**

```bash
# 1. User create schedule
POST /api/user/pickup-schedules

# 2. Check user schedules
GET /api/user/pickup-schedules
# Should return: status = "pending"

# 3. Mitra accept
POST /api/mitra/pickup-schedules/{id}/accept

# 4. Check user schedules again
GET /api/user/pickup-schedules
# Should return: status = "accepted", mitra_id filled, updated_at changed

# 5. Wait 30 seconds, Flutter app will detect change!
```

---

## ✅ Success Criteria

**Backend dianggap READY jika:**

1. ✅ Endpoint `GET /api/user/pickup-schedules` returns correct format
2. ✅ Field `schedule_day` dalam Bahasa Indonesia
3. ✅ Field `pickup_time_start` format HH:mm
4. ✅ Status update via mitra endpoints work
5. ✅ `updated_at` auto-updates on status change
6. ✅ Authentication & authorization work

**Test dengan:**
```bash
curl -X GET "YOUR_API/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN" | jq '.'
```

**Jika response sesuai contoh di atas = READY! 🎉**

---

**Questions?** Share hasil testing dan saya akan bantu debug! 🚀
