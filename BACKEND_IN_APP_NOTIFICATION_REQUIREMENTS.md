# 🔔 Backend Requirements untuk In-App Notification Banner

**Date:** November 15, 2025  
**Feature:** In-app notification pop-up saat mitra terima/selesaikan jadwal  
**Backend:** Laravel API  
**Frontend:** Flutter (Sudah Implemented ✅)

---

## 📋 Overview

Frontend Flutter sudah implement **auto-polling system** yang check perubahan status setiap 10 detik. Backend Laravel perlu memastikan:

1. ✅ API `/api/user/pickup-schedules` return data yang benar
2. ✅ Status update saat mitra accept/complete jadwal
3. ✅ Response format sesuai dengan yang diharapkan Flutter

---

## 🎯 Yang Perlu Backend Lakukan

### **TIDAK PERLU:**
- ❌ Firebase Cloud Messaging
- ❌ Push notification service
- ❌ WebSocket / Real-time
- ❌ Notification table baru

### **YANG PERLU:**
- ✅ Ensure status field terupdate dengan benar
- ✅ Return field yang dibutuhkan Flutter
- ✅ Status transition yang proper

---

## 🔄 Status Flow yang Diharapkan

```
User buat jadwal
    ↓
status = 'pending'
    ↓
Mitra accept jadwal
    ↓
status = 'accepted' ✅ (Flutter detect & show banner!)
    ↓
Mitra start perjalanan
    ↓
status = 'on_the_way' ✅ (Flutter detect & show banner!)
    ↓
Mitra sampai lokasi
    ↓
status = 'arrived' ✅ (Flutter detect & show banner!)
    ↓
Mitra selesaikan pickup
    ↓
status = 'completed' ✅ (Flutter detect & show banner!)
```

---

## 📡 API Endpoint yang Digunakan Flutter

### **GET /api/user/pickup-schedules**

**Headers:**
```http
Authorization: Bearer {user_token}
Content-Type: application/json
```

**Response Format yang Diharapkan:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": 75,
      "user_id": 15,
      "mitra_id": 8,
      "status": "accepted",              // ⚠️ PENTING: Harus update saat mitra accept
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "schedule_day": "Jumat, 15 Nov 2025",  // Format: "Hari, DD MMM YYYY"
      "pickup_time_start": "10:28",      // Format: "HH:mm"
      "pickup_time_end": "12:00",        // Optional (tidak dipakai Flutter)
      "scheduled_pickup_at": "2025-11-15 10:28:00",
      "total_weight_kg": 5.5,            // Null jika belum selesai
      "total_points": 55,                // Null jika belum selesai
      "created_at": "2025-11-15T08:30:00.000000Z",
      "updated_at": "2025-11-15T09:15:00.000000Z"
    }
  ]
}
```

---

## 🚨 Field yang HARUS Ada

### **Field Wajib untuk Semua Status:**

| Field | Type | Example | Keterangan |
|-------|------|---------|------------|
| `id` | integer | 75 | Schedule ID |
| `status` | string | "accepted" | **PALING PENTING** - Must update |
| `pickup_address` | string | "Jl. Sudirman..." | Alamat penjemputan |
| `schedule_day` | string | "Jumat, 15 Nov 2025" | Format Indonesia |
| `pickup_time_start` | string | "10:28" | Format HH:mm (24 hour) |

### **Field untuk Status `completed`:**

| Field | Type | Example | Keterangan |
|-------|------|---------|------------|
| `total_weight_kg` | float/null | 5.5 | Berat total sampah |
| `total_points` | integer/null | 55 | Poin yang didapat user |

---

## 🔧 Backend Implementation Guide

### **1. Mitra Accept Jadwal**

**Endpoint:** `POST /api/mitra/pickup-schedules/{id}/accept`

**Controller:** `PickupScheduleController@acceptSchedule`

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Models\PickupSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PickupScheduleController extends Controller
{
    /**
     * Mitra accept jadwal penjemputan
     */
    public function acceptSchedule($id)
    {
        try {
            $schedule = PickupSchedule::findOrFail($id);
            $mitra = Auth::user();

            // Validasi
            if ($schedule->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Jadwal sudah tidak tersedia',
                ], 400);
            }

            // ✅ UPDATE STATUS - INI YANG PALING PENTING!
            $schedule->update([
                'status' => 'accepted',           // ⚠️ Flutter detect perubahan ini
                'mitra_id' => $mitra->id,
                'accepted_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Jadwal berhasil diterima',
                'data' => $schedule->load('user', 'mitra'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menerima jadwal: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mitra mulai perjalanan
     */
    public function startJourney($id)
    {
        try {
            $schedule = PickupSchedule::findOrFail($id);
            $mitra = Auth::guard('mitra')->user();

            // Validasi
            if ($schedule->mitra_id !== $mitra->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            if ($schedule->status !== 'accepted') {
                return response()->json([
                    'success' => false,
                    'message' => 'Status jadwal tidak valid',
                ], 400);
            }

            // ✅ UPDATE STATUS
            $schedule->update([
                'status' => 'on_the_way',         // ⚠️ Flutter detect perubahan ini
                'started_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Perjalanan dimulai',
                'data' => $schedule,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mitra sampai di lokasi
     */
    public function markArrived($id)
    {
        try {
            $schedule = PickupSchedule::findOrFail($id);

            // ✅ UPDATE STATUS
            $schedule->update([
                'status' => 'arrived',            // ⚠️ Flutter detect perubahan ini
                'arrived_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Mitra sudah tiba di lokasi',
                'data' => $schedule,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mitra selesaikan pickup (dengan input berat)
     */
    public function completePickup(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'total_weight_kg' => 'required|numeric|min:0.1',
                'photo_proof' => 'nullable|string', // Base64 image
            ]);

            $schedule = PickupSchedule::findOrFail($id);
            $mitra = Auth::guard('mitra')->user();

            // Validasi
            if ($schedule->mitra_id !== $mitra->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            // Hitung poin (contoh: 1kg = 10 poin)
            $points = (int)($validated['total_weight_kg'] * 10);

            // ✅ UPDATE STATUS & WEIGHT & POINTS
            $schedule->update([
                'status' => 'completed',          // ⚠️ Flutter detect perubahan ini
                'total_weight_kg' => $validated['total_weight_kg'],
                'total_points' => $points,
                'completed_at' => now(),
                'photo_proof' => $validated['photo_proof'] ?? null,
            ]);

            // Update user points
            $schedule->user->increment('total_points', $points);

            return response()->json([
                'success' => true,
                'message' => 'Penjemputan selesai!',
                'data' => [
                    'schedule' => $schedule->fresh(),
                    'points_earned' => $points,
                    'total_weight' => $validated['total_weight_kg'],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }
}
```

---

### **2. Model PickupSchedule**

**File:** `app/Models/PickupSchedule.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class PickupSchedule extends Model
{
    protected $table = 'pickup_schedules';

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
        'accepted_at',
        'started_at',
        'arrived_at',
        'completed_at',
        'photo_proof',
    ];

    protected $casts = [
        'scheduled_pickup_at' => 'datetime',
        'accepted_at' => 'datetime',
        'started_at' => 'datetime',
        'arrived_at' => 'datetime',
        'completed_at' => 'datetime',
        'total_weight_kg' => 'float',
        'total_points' => 'integer',
    ];

    // ✅ ACCESSOR untuk format yang diharapkan Flutter
    protected $appends = ['schedule_day', 'pickup_time_start'];

    /**
     * Format schedule_day: "Jumat, 15 Nov 2025"
     */
    public function getScheduleDayAttribute()
    {
        if (!$this->scheduled_pickup_at) {
            return null;
        }

        Carbon::setLocale('id');
        return $this->scheduled_pickup_at->isoFormat('dddd, DD MMM YYYY');
    }

    /**
     * Format pickup_time_start: "10:28"
     */
    public function getPickupTimeStartAttribute()
    {
        if (!$this->scheduled_pickup_at) {
            return null;
        }

        return $this->scheduled_pickup_at->format('H:i');
    }

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mitra()
    {
        return $this->belongsTo(Mitra::class);
    }
}
```

---

### **3. Migration untuk pickup_schedules**

**File:** `database/migrations/xxxx_create_pickup_schedules_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Support;

return new class extends Migration
{
    public function up()
    {
        Schema::create('pickup_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('mitra_id')->nullable()->constrained('mitras')->onDelete('set null');
            
            // ✅ STATUS - Field paling penting untuk notification
            $table->enum('status', [
                'pending',      // User buat jadwal
                'accepted',     // Mitra terima
                'on_the_way',   // Mitra dalam perjalanan
                'arrived',      // Mitra sudah tiba
                'completed',    // Penjemputan selesai
                'cancelled',    // Dibatalkan
            ])->default('pending');

            // Alamat & lokasi
            $table->text('pickup_address');
            $table->decimal('pickup_latitude', 10, 8)->nullable();
            $table->decimal('pickup_longitude', 11, 8)->nullable();

            // Jadwal pickup (dari user)
            $table->timestamp('scheduled_pickup_at');

            // ✅ Weight & Points - Wajib untuk status completed
            $table->decimal('total_weight_kg', 8, 2)->nullable();
            $table->integer('total_points')->nullable();

            // Timestamps untuk tracking
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('arrived_at')->nullable();
            $table->timestamp('completed_at')->nullable();

            // Photo proof
            $table->text('photo_proof')->nullable();

            $table->timestamps();

            // Indexes
            $table->index('status');
            $table->index(['user_id', 'status']);
            $table->index(['mitra_id', 'status']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('pickup_schedules');
    }
};
```

---

### **4. API Routes**

**File:** `routes/api.php`

```php
<?php

use App\Http\Controllers\Api\Mitra\PickupScheduleController;
use App\Http\Controllers\Api\User\UserPickupScheduleController;

// ✅ USER ROUTES
Route::middleware(['auth:sanctum', 'user'])->prefix('user')->group(function () {
    // Get all user pickup schedules (digunakan Flutter untuk polling)
    Route::get('/pickup-schedules', [UserPickupScheduleController::class, 'index']);
    
    // Create new schedule
    Route::post('/pickup-schedules', [UserPickupScheduleController::class, 'store']);
});

// ✅ MITRA ROUTES
Route::middleware(['auth:sanctum', 'mitra'])->prefix('mitra')->group(function () {
    // Get available schedules (pending)
    Route::get('/pickup-schedules/available', [PickupScheduleController::class, 'available']);
    
    // Accept schedule
    Route::post('/pickup-schedules/{id}/accept', [PickupScheduleController::class, 'acceptSchedule']);
    
    // Start journey
    Route::post('/pickup-schedules/{id}/start-journey', [PickupScheduleController::class, 'startJourney']);
    
    // Mark arrived
    Route::post('/pickup-schedules/{id}/arrived', [PickupScheduleController::class, 'markArrived']);
    
    // Complete pickup
    Route::post('/pickup-schedules/{id}/complete', [PickupScheduleController::class, 'completePickup']);
});
```

---

## 🧪 Testing Backend

### **Test 1: User Get Schedules**

```bash
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "status": "pending",
      "pickup_address": "Jl. Sudirman No. 123",
      "schedule_day": "Jumat, 15 Nov 2025",
      "pickup_time_start": "10:28",
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
  -H "Authorization: Bearer MITRA_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Jadwal berhasil diterima",
  "data": {
    "id": 75,
    "status": "accepted",  // ✅ Changed from "pending"
    "mitra_id": 8,
    "accepted_at": "2025-11-15T10:15:00.000000Z"
  }
}
```

**⚠️ IMPORTANT:** Setelah response ini, Flutter akan detect status change dalam max 10 detik dan show banner!

---

### **Test 3: User Get Schedules Again (Polling)**

```bash
# Flutter call endpoint yang sama lagi setelah 10 detik
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "status": "accepted",  // ✅ Status changed!
      "pickup_address": "Jl. Sudirman No. 123",
      "schedule_day": "Jumat, 15 Nov 2025",
      "pickup_time_start": "10:28"
    }
  ]
}
```

**Flutter Detection:**
```dart
// Old status: "pending"
// New status: "accepted"
// Trigger: Show banner "Jadwal Diterima! 🎉"
```

---

### **Test 4: Complete Pickup**

```bash
curl -X POST "http://localhost:8000/api/mitra/pickup-schedules/75/complete" \
  -H "Authorization: Bearer MITRA_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "total_weight_kg": 5.5
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Penjemputan selesai!",
  "data": {
    "schedule": {
      "id": 75,
      "status": "completed",  // ✅ Changed to completed
      "total_weight_kg": 5.5,
      "total_points": 55,
      "schedule_day": "Jumat, 15 Nov 2025",
      "pickup_time_start": "10:28"
    },
    "points_earned": 55
  }
}
```

**Flutter Detection:**
```dart
// Old status: "arrived" atau "on_the_way"
// New status: "completed"
// Trigger: Show banner "Penjemputan Selesai! ✅" dengan "5.5 kg • +55 poin"
```

---

## 🔍 Debugging Guide

### **Problem: Banner tidak muncul**

#### **Step 1: Check Flutter Polling**

Tambahkan debug log di `activity_content_improved.dart`:

```dart
Future<void> _refreshSchedulesInBackground() async {
  if (_isRefreshing) return;

  _isRefreshing = true;
  try {
    print('🔄 Polling API...'); // Debug
    final schedules = await _apiService.getUserPickupSchedules();
    print('📦 Got ${schedules.length} schedules'); // Debug

    for (int i = 0; i < schedules.length; i++) {
      print('Schedule ${schedules[i]['id']}: status=${schedules[i]['status']}'); // Debug
      
      final oldSchedule = _schedules.firstWhere(
        (s) => s['id'] == schedules[i]['id'],
        orElse: () => {},
      );

      if (oldSchedule.isNotEmpty) {
        print('  Old status: ${oldSchedule['status']}'); // Debug
        print('  New status: ${schedules[i]['status']}'); // Debug
        
        if (oldSchedule['status'] != schedules[i]['status']) {
          print('  ✅ STATUS CHANGED! Showing banner...'); // Debug
        }
      }
    }
  } catch (e) {
    print('❌ Polling error: $e'); // Debug
  }
}
```

#### **Step 2: Check Backend Response**

```bash
# Check apa backend return status yang benar
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN" | jq '.'
```

**Checklist:**
- [ ] Response code 200?
- [ ] `data` array ada?
- [ ] Field `status` ada di setiap schedule?
- [ ] Field `schedule_day` format: "Jumat, 15 Nov 2025"?
- [ ] Field `pickup_time_start` format: "10:28"?

#### **Step 3: Test Status Change Manually**

Di database:
```sql
-- Sebelum
SELECT id, status FROM pickup_schedules WHERE id = 75;
-- Result: id=75, status='pending'

-- Mitra accept via API
-- POST /api/mitra/pickup-schedules/75/accept

-- Sesudah
SELECT id, status FROM pickup_schedules WHERE id = 75;
-- Result: id=75, status='accepted' ✅

-- Flutter polling (max 10 detik) akan detect perubahan ini!
```

---

## ⚙️ Configuration

### **Polling Interval**

**Current:** 10 seconds (good for testing)  
**Recommended Production:** 30 seconds

**Change di Flutter:**
```dart
// File: activity_content_improved.dart
_refreshTimer = Timer.periodic(
  const Duration(seconds: 30), // Change here
  (timer) { ... }
);
```

---

## 📊 Status Transition Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    STATUS FLOW                              │
└─────────────────────────────────────────────────────────────┘

User buat jadwal
    ↓
[pending] ─────────────────────────────────────────────┐
    ↓                                                   │
    │ Mitra accept                                      │
    ↓                                                   │ User cancel
[accepted] ✅ Banner: "Jadwal Diterima!"               │
    ↓                                                   │
    │ Mitra start journey                               │
    ↓                                                   │
[on_the_way] ✅ Banner: "Mitra Dalam Perjalanan"       │
    ↓                                                   │
    │ Mitra arrived                                     │
    ↓                                                   │
[arrived] ✅ Banner: "Mitra Sudah Tiba!"                │
    ↓                                                   │
    │ Mitra complete (input weight)                     │
    ↓                                                   │
[completed] ✅ Banner: "Penjemputan Selesai!"           │
    │                                                   │
    └───────────────────────────────────────────────────┴──> [cancelled]
```

---

## ✅ Backend Checklist

Sebelum testing dengan Flutter, pastikan backend sudah:

### **Database:**
- [ ] Table `pickup_schedules` ada dengan kolom:
  - [ ] `status` (enum: pending, accepted, on_the_way, arrived, completed, cancelled)
  - [ ] `pickup_address` (text)
  - [ ] `scheduled_pickup_at` (timestamp)
  - [ ] `total_weight_kg` (decimal, nullable)
  - [ ] `total_points` (integer, nullable)

### **Model:**
- [ ] PickupSchedule model ada
- [ ] Accessor `schedule_day` return format: "Jumat, 15 Nov 2025"
- [ ] Accessor `pickup_time_start` return format: "10:28"
- [ ] Carbon locale set ke 'id' (Indonesia)

### **API Endpoints:**
- [ ] `GET /api/user/pickup-schedules` (untuk user polling)
- [ ] `POST /api/mitra/pickup-schedules/{id}/accept` (update status ke 'accepted')
- [ ] `POST /api/mitra/pickup-schedules/{id}/start-journey` (update ke 'on_the_way')
- [ ] `POST /api/mitra/pickup-schedules/{id}/arrived` (update ke 'arrived')
- [ ] `POST /api/mitra/pickup-schedules/{id}/complete` (update ke 'completed', save weight & points)

### **Controllers:**
- [ ] UserPickupScheduleController@index return semua schedules user
- [ ] PickupScheduleController@acceptSchedule update status ke 'accepted'
- [ ] PickupScheduleController@completePickup update status, weight, points

### **Testing:**
- [ ] Test dengan curl/Postman semua endpoint
- [ ] Verify status berubah di database
- [ ] Verify response format sesuai

---

## 🚀 Quick Start untuk Backend

### **1. Install Dependencies**
```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

### **2. Create Migration**
```bash
php artisan make:migration create_pickup_schedules_table
# Copy code dari section "3. Migration" di atas
php artisan migrate
```

### **3. Create Model**
```bash
php artisan make:model PickupSchedule
# Copy code dari section "2. Model" di atas
```

### **4. Create Controllers**
```bash
php artisan make:controller Api/Mitra/PickupScheduleController
php artisan make:controller Api/User/UserPickupScheduleController
# Copy code dari section "1. Controller" di atas
```

### **5. Add Routes**
```bash
# Edit routes/api.php
# Copy code dari section "4. API Routes" di atas
```

### **6. Test**
```bash
php artisan serve

# Test dengan curl (lihat section "Testing Backend")
```

---

## 📞 Support

### **Jika banner masih tidak muncul:**

1. **Check Flutter logs:**
   ```
   flutter run
   # Lihat console untuk:
   # "🔄 Polling API..."
   # "📦 Got X schedules"
   # "✅ STATUS CHANGED!"
   ```

2. **Check backend logs:**
   ```bash
   tail -f storage/logs/laravel.log
   ```

3. **Check database:**
   ```sql
   SELECT * FROM pickup_schedules ORDER BY updated_at DESC LIMIT 10;
   ```

4. **Test manual status change:**
   ```sql
   UPDATE pickup_schedules SET status = 'accepted' WHERE id = 75;
   # Tunggu max 10 detik, banner harus muncul!
   ```

---

## 📋 Summary

### **Backend Requirements:**
✅ **Simple!** Tidak perlu Firebase, WebSocket, atau notification service.

**Yang perlu:**
1. API `/api/user/pickup-schedules` return correct data
2. Update `status` field saat mitra accept/complete
3. Return `schedule_day`, `pickup_time_start`, `total_weight_kg`, `total_points`

**How it works:**
- Flutter polling setiap 10 detik
- Detect status change
- Show banner automatically

**Status flow:**
```
pending → accepted → on_the_way → arrived → completed
  ↓         ↓           ↓            ↓          ↓
 (wait)   Banner!    Banner!      Banner!   Banner!
```

---

**Status:** ✅ Ready untuk backend implementation!  
**Complexity:** Low (hanya update status)  
**Time:** ~2 jam untuk setup lengkap  

🚀 **Let's implement!**
