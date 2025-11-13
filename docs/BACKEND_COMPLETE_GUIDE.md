# 📘 COMPLETE BACKEND DOCUMENTATION - Mitra Pickup System

> **Dokumentasi Lengkap untuk Backend Team**  
> **Tanggal:** 13 November 2025  
> **Status:** 🔴 URGENT - Core Feature Aplikasi  
> **Priority:** CRITICAL  

---

## 📋 Table of Contents

1. [🚀 Quick Start](#quick-start)
2. [🎯 Overview](#overview)
3. [📊 API Endpoints](#api-endpoints)
4. [🗄️ Database Schema](#database-schema)
5. [💻 Implementation Code](#implementation-code)
6. [🔔 Notification System](#notification-system)
7. [📱 Visual Flow Diagram](#visual-flow-diagram)
8. [🧪 Testing Guide](#testing-guide)
9. [✅ Checklist](#checklist)

---

<a name="quick-start"></a>
## 🚀 Quick Start

### Apa yang Harus Diimplementasikan?

**Fitur:** User membuat jadwal pengambilan sampah → Mitra melihat, menerima, dan menyelesaikan → Status otomatis update ke User → User dapat poin

**Flow Singkat:**
```
[User] Buat jadwal (PENDING)
   ↓
[Mitra] Lihat list jadwal tersedia
   ↓
[Mitra] Accept jadwal
   ↓
[Backend] Update status → ON_PROGRESS
   ↓
[Backend] Send notification ke User
   ↓
[Mitra] Complete dengan foto + berat sampah
   ↓
[Backend] Calculate points (1kg = 10 poin)
   ↓
[Backend] User.points += calculated_points
   ↓
[Backend] Update status → COMPLETED
   ↓
[Backend] Send notification ke User
   ↓
[User] Terima notifikasi + lihat poin bertambah
```

### 7 Steps Implementation

**Step 1: Database Setup (30 menit)**
```bash
php artisan make:migration add_mitra_fields_to_pickup_schedules
# Copy migration code dari section "Database Schema"
php artisan migrate
```

**Step 2: Notification Classes (1 jam)**
```bash
php artisan make:notification MitraAssigned
php artisan make:notification PickupCompleted
php artisan make:notification PickupCancelled
# Copy code dari section "Notification System"
```

**Step 3: Event Class (30 menit) - Optional**
```bash
php artisan make:event PickupStatusUpdated
# Copy code dari section "Notification System"
```

**Step 4: Controller (2-3 jam)**
```bash
php artisan make:controller Api/Mitra/MitraPickupController
# Copy methods dari section "Implementation Code"
```

**Step 5: Routes (15 menit)**
```php
// Tambahkan di routes/api.php
// Copy dari section "Implementation Code"
```

**Step 6: Model Relationships (15 menit)**
```php
// Update PickupSchedule model
// Copy dari section "Implementation Code"
```

**Step 7: Testing (1-2 jam)**
```bash
# Test dengan curl commands dari section "Testing Guide"
```

---

<a name="overview"></a>
## 🎯 Overview

### User Flow:
1. User membuat jadwal penjemputan → Status: **PENDING**
2. Jadwal muncul di list Mitra yang available
3. Mitra menerima jadwal → Status: **ON_PROGRESS** (otomatis update di User)
4. Mitra perjalanan ke lokasi → User bisa track realtime
5. Mitra selesai → Status: **COMPLETED**

### Mitra Flow:
1. Melihat list jadwal PENDING dari semua user
2. Klik detail jadwal → Lihat info lengkap (nama, telpon, alamat, map)
3. Terima jadwal → Status berubah PENDING → ON_PROGRESS
4. Update lokasi saat perjalanan (optional realtime tracking)
5. Konfirmasi selesai → Upload foto, input berat sampah

### Status Flow:
```
pending → on_progress → completed
   ↓
cancelled
```

**Status Definitions:**
- `pending`: Jadwal baru dibuat user, menunggu mitra accept
- `on_progress`: Mitra sudah accept, sedang dalam perjalanan
- `completed`: Pengambilan selesai
- `cancelled`: Dibatalkan oleh user atau mitra

---

<a name="api-endpoints"></a>
## 📊 API Endpoints

### Summary Table

| Priority | Method | Endpoint | Fungsi |
|----------|--------|----------|--------|
| 🔴 HIGH | **GET** | `/api/mitra/pickup-schedules/available` | List jadwal PENDING |
| 🔴 HIGH | **GET** | `/api/mitra/pickup-schedules/{id}` | Detail jadwal (nama, telpon, alamat) |
| 🔴 HIGH | **POST** | `/api/mitra/pickup-schedules/{id}/accept` | Mitra terima jadwal |
| 🔴 HIGH | **POST** | `/api/mitra/pickup-schedules/{id}/complete` | Upload foto + berat sampah |
| 🟡 MEDIUM | **POST** | `/api/mitra/pickup-schedules/{id}/start-journey` | Mulai perjalanan |
| 🟡 MEDIUM | **POST** | `/api/mitra/pickup-schedules/{id}/arrive` | Sampai di lokasi |
| 🟡 MEDIUM | **POST** | `/api/mitra/pickup-schedules/{id}/cancel` | Batalkan jadwal |
| 🟢 LOW | **GET** | `/api/mitra/pickup-schedules/my-active` | Jadwal aktif mitra |
| 🟢 LOW | **GET** | `/api/mitra/pickup-schedules/history` | Riwayat completed |

---

### 1. GET /api/mitra/pickup-schedules/available
**Fungsi:** Mitra melihat semua jadwal PENDING yang belum diambil

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/available`

**Headers:**
```
Authorization: Bearer {mitra_token}
Accept: application/json
```

**Query Parameters (Optional):**
```
area         // Filter berdasarkan area kerja mitra
waste_type   // Filter jenis sampah
date         // Filter tanggal (YYYY-MM-DD)
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 36,
        "user_id": 15,
        "user_name": "Ali",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
        "latitude": -6.208763,
        "longitude": 106.845599,
        "schedule_day": "rabu",
        "waste_type_scheduled": "B3",
        "scheduled_pickup_at": "2025-11-13 06:00:00",
        "pickup_time_start": "06:00:00",
        "pickup_time_end": "08:00:00",
        "waste_summary": "B3",
        "notes": "Sampah sudah dipilah",
        "status": "pending",
        "created_at": "2025-11-12 14:12:48"
      }
    ],
    "total": 15
  }
}
```

**Backend Logic:**
- Query: `WHERE status = 'pending' AND assigned_mitra_id IS NULL`
- Include: User relationship (name, phone)
- Order by: `scheduled_pickup_at ASC`
- Optional: Calculate distance from mitra location

---

### 2. GET /api/mitra/pickup-schedules/{id}
**Fungsi:** Mitra melihat detail jadwal sebelum accept

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/36`

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule detail retrieved successfully",
  "data": {
    "schedule": {
      "id": 36,
      "user_id": 15,
      "user": {
        "id": 15,
        "name": "Ali",
        "email": "ali@gmail.com",
        "phone": "081234567890",
        "address": "Jl. Sudirman No. 123, Jakarta Pusat",
        "profile_picture": "https://example.com/photo.jpg"
      },
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "latitude": -6.208763,
      "longitude": 106.845599,
      "waste_type_scheduled": "B3",
      "scheduled_pickup_at": "2025-11-13 06:00:00",
      "notes": "Sampah sudah dipilah. Mohon tepat waktu.",
      "status": "pending"
    }
  }
}
```

---

### 3. POST /api/mitra/pickup-schedules/{id}/accept ⭐ CRITICAL
**Fungsi:** Mitra menerima jadwal penjemputan

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept`

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule accepted successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "on_progress",
      "assigned_mitra_id": 8,
      "assigned_at": "2025-11-12 15:30:00",
      "mitra": {
        "id": 8,
        "name": "John Doe",
        "phone": "081987654321",
        "vehicle_type": "Truk",
        "vehicle_plate": "B 1234 XYZ"
      }
    }
  }
}
```

**What Happens Backend (CRITICAL):**
```php
DB::transaction(function() {
    // 1. Update schedule
    $schedule->update([
        'assigned_mitra_id' => $mitra->id,
        'status' => 'on_progress',
        'assigned_at' => now()
    ]);
    
    // 2. Send notification to USER
    $schedule->user->notify(new MitraAssigned($schedule, $mitra));
    
    // 3. Broadcast realtime event (optional)
    broadcast(new PickupStatusUpdated($schedule));
});
```

**Validasi:**
- Schedule status must be `pending`
- `assigned_mitra_id` must be NULL
- Prevent race condition (use `lockForUpdate()`)

**Error Response (409 Conflict):**
```json
{
  "success": false,
  "message": "Schedule already accepted by another mitra"
}
```

---

### 4. POST /api/mitra/pickup-schedules/{id}/complete ⭐ CRITICAL
**Fungsi:** Mitra menyelesaikan penjemputan (upload foto, input berat)

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
```
actual_weights[Organik]    = 3.5
actual_weights[Anorganik]  = 2.0
actual_weights[B3]         = 1.2
notes                      = "Pengambilan selesai tepat waktu"
photos[]                   = file1.jpg
photos[]                   = file2.jpg
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Pickup completed successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "completed",
      "completed_at": "2025-11-13 06:30:00",
      "actual_weights": {
        "Organik": 3.5,
        "Anorganik": 2.0,
        "B3": 1.2
      },
      "total_weight": 6.7,
      "pickup_photos": [
        "https://storage.com/pickup/36/photo1.jpg",
        "https://storage.com/pickup/36/photo2.jpg"
      ],
      "points_earned": 67
    }
  }
}
```

**What Happens Backend (CRITICAL):**
```php
DB::transaction(function() {
    // 1. Calculate total weight
    $totalWeight = array_sum($request->actual_weights);
    
    // 2. Upload photos
    $photoUrls = [];
    foreach ($request->file('photos') as $photo) {
        $path = $photo->store("pickups/{$schedule->id}", 'public');
        $photoUrls[] = Storage::url($path);
    }
    
    // 3. Update schedule
    $schedule->update([
        'status' => 'completed',
        'completed_at' => now(),
        'actual_weights' => $request->actual_weights,
        'total_weight' => $totalWeight,
        'pickup_photos' => $photoUrls
    ]);
    
    // 4. ADD POINTS TO USER (1 kg = 10 points)
    $points = (int)($totalWeight * 10);
    $schedule->user->increment('points', $points);
    
    // 5. Send notification to USER
    $schedule->user->notify(new PickupCompleted($schedule, $points));
    
    // 6. Update mitra statistics
    $mitra->increment('total_collections');
    
    // 7. Broadcast event
    broadcast(new PickupStatusUpdated($schedule));
});
```

**Validasi:**
- Status must be `on_progress`
- Mitra must be assigned to this schedule
- Minimal 1 photo required
- Total weight must be > 0
- Photo max 5MB each

---

### 5. POST /api/mitra/pickup-schedules/{id}/cancel
**Fungsi:** Mitra membatalkan jadwal (dengan alasan)

**Request Body:**
```json
{
  "reason": "User tidak ada di lokasi setelah 3x kontak"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule cancelled",
  "data": {
    "schedule": {
      "id": 36,
      "status": "pending",
      "assigned_mitra_id": null,
      "cancelled_at": "2025-11-13 06:10:00",
      "cancellation_reason": "User tidak ada di lokasi"
    }
  }
}
```

**What Happens:**
- Reset status to `pending`
- Clear `assigned_mitra_id`
- Save cancellation reason
- Send notification to user
- Schedule becomes available again

---

<a name="database-schema"></a>
## 🗄️ Database Schema

### Migration Code (Copy-Paste Ready)

```sql
-- Add columns to pickup_schedules table
ALTER TABLE pickup_schedules 

-- Mitra Assignment
ADD COLUMN assigned_mitra_id BIGINT UNSIGNED NULL COMMENT 'ID Mitra yang menerima',
ADD COLUMN assigned_at DATETIME NULL COMMENT 'Kapan mitra accept',

-- Tracking Status
ADD COLUMN on_the_way_at DATETIME NULL COMMENT 'Kapan mitra mulai perjalanan',
ADD COLUMN picked_up_at DATETIME NULL COMMENT 'Kapan sampai lokasi user',
ADD COLUMN completed_at DATETIME NULL COMMENT 'Kapan selesai',

-- Completion Data
ADD COLUMN actual_weights JSON NULL COMMENT 'Berat aktual per jenis sampah',
ADD COLUMN total_weight DECIMAL(8,2) NULL COMMENT 'Total berat (kg)',
ADD COLUMN pickup_photos JSON NULL COMMENT 'Array foto bukti pengambilan',

-- Cancellation
ADD COLUMN cancelled_at DATETIME NULL,
ADD COLUMN cancellation_reason TEXT NULL,

-- Foreign Key
ADD CONSTRAINT fk_assigned_mitra 
    FOREIGN KEY (assigned_mitra_id) 
    REFERENCES users(id) 
    ON DELETE SET NULL,

-- Indexes
ADD INDEX idx_assigned_mitra (assigned_mitra_id),
ADD INDEX idx_status_mitra (status, assigned_mitra_id);
```

### Laravel Migration File

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            // Mitra assignment
            $table->unsignedBigInteger('assigned_mitra_id')->nullable()->after('user_id');
            $table->timestamp('assigned_at')->nullable()->after('assigned_mitra_id');
            
            // Tracking timestamps
            $table->timestamp('on_the_way_at')->nullable()->after('assigned_at');
            $table->timestamp('picked_up_at')->nullable()->after('on_the_way_at');
            $table->timestamp('completed_at')->nullable()->after('picked_up_at');
            
            // Completion data
            $table->json('actual_weights')->nullable()->after('completed_at');
            $table->decimal('total_weight', 8, 2)->nullable()->after('actual_weights');
            $table->json('pickup_photos')->nullable()->after('total_weight');
            
            // Cancellation
            $table->timestamp('cancelled_at')->nullable()->after('pickup_photos');
            $table->text('cancellation_reason')->nullable()->after('cancelled_at');
            
            // Foreign key
            $table->foreign('assigned_mitra_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('set null');
            
            // Indexes
            $table->index('assigned_mitra_id');
            $table->index(['status', 'assigned_mitra_id']);
        });
    }

    public function down(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            $table->dropForeign(['assigned_mitra_id']);
            $table->dropIndex(['assigned_mitra_id']);
            $table->dropIndex(['status', 'assigned_mitra_id']);
            
            $table->dropColumn([
                'assigned_mitra_id',
                'assigned_at',
                'on_the_way_at',
                'picked_up_at',
                'completed_at',
                'actual_weights',
                'total_weight',
                'pickup_photos',
                'cancelled_at',
                'cancellation_reason'
            ]);
        });
    }
};
```

---

<a name="implementation-code"></a>
## 💻 Implementation Code

### Controller: MitraPickupController.php (COMPLETE)

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use App\Events\PickupStatusUpdated;
use App\Notifications\MitraAssigned;
use App\Notifications\PickupCompleted;
use App\Notifications\PickupCancelled;

class MitraPickupController extends Controller
{
    /**
     * Get available schedules for mitra
     */
    public function availableSchedules(Request $request)
    {
        $mitra = Auth::user();
        
        $query = PickupSchedule::where('status', 'pending')
                               ->with('user:id,name,phone,address')
                               ->whereNull('assigned_mitra_id');
        
        // Filter by mitra work area (optional)
        if ($mitra->work_area) {
            $query->where('pickup_address', 'LIKE', "%{$mitra->work_area}%");
        }
        
        // Filter by waste type
        if ($request->has('waste_type')) {
            $query->where('waste_type_scheduled', $request->waste_type);
        }
        
        $schedules = $query->orderBy('scheduled_pickup_at', 'asc')
                          ->get();
        
        return response()->json([
            'success' => true,
            'message' => 'Available schedules retrieved',
            'data' => [
                'schedules' => $schedules,
                'total' => $schedules->count()
            ]
        ]);
    }
    
    /**
     * Get schedule detail
     */
    public function showSchedule($id)
    {
        $schedule = PickupSchedule::with('user:id,name,email,phone,address,profile_picture')
                                  ->findOrFail($id);
        
        return response()->json([
            'success' => true,
            'data' => ['schedule' => $schedule]
        ]);
    }
    
    /**
     * Accept schedule (CRITICAL)
     */
    public function acceptSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('status', 'pending')
                                  ->whereNull('assigned_mitra_id')
                                  ->lockForUpdate()  // Prevent race condition
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $mitra, $request) {
            // 1. Update schedule
            $schedule->update([
                'assigned_mitra_id' => $mitra->id,
                'status' => 'on_progress',
                'assigned_at' => now(),
            ]);
            
            // 2. Send notification to user
            $schedule->user->notify(new MitraAssigned($schedule, $mitra));
            
            // 3. Broadcast event (optional)
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule accepted successfully',
            'data' => [
                'schedule' => $schedule->load('mitra')
            ]
        ]);
    }
    
    /**
     * Start journey to pickup location
     */
    public function startJourney(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        $schedule->update([
            'on_the_way_at' => now()
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Journey started',
            'data' => ['schedule' => $schedule]
        ]);
    }
    
    /**
     * Confirm arrival at pickup location
     */
    public function arrive(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->firstOrFail();
        
        $schedule->update([
            'picked_up_at' => now()
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Arrival confirmed'
        ]);
    }
    
    /**
     * Complete pickup with photos and weight (CRITICAL)
     */
    public function completePickup(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'actual_weights' => 'required|array',
            'actual_weights.*' => 'numeric|min:0',
            'photos' => 'required|array|min:1',
            'photos.*' => 'image|max:5120',
            'notes' => 'nullable|string'
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $request, $mitra) {
            // 1. Calculate total weight
            $totalWeight = array_sum($request->actual_weights);
            
            // 2. Upload photos
            $photoUrls = [];
            foreach ($request->file('photos') as $photo) {
                $path = $photo->store("pickups/{$schedule->id}", 'public');
                $photoUrls[] = Storage::url($path);
            }
            
            // 3. Update schedule
            $schedule->update([
                'status' => 'completed',
                'completed_at' => now(),
                'actual_weights' => $request->actual_weights,
                'total_weight' => $totalWeight,
                'pickup_photos' => $photoUrls,
                'notes' => $request->notes
            ]);
            
            // 4. Calculate and add points to user (1 kg = 10 points)
            $points = (int)($totalWeight * 10);
            $schedule->user->increment('points', $points);
            
            // 5. Update mitra statistics
            $mitra->increment('total_collections');
            
            // 6. Send notification to user
            $schedule->user->notify(new PickupCompleted($schedule, $points));
            
            // 7. Broadcast event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Pickup completed successfully',
            'data' => [
                'schedule' => $schedule,
                'points_earned' => (int)($schedule->total_weight * 10)
            ]
        ]);
    }
    
    /**
     * Cancel assigned schedule
     */
    public function cancelSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'reason' => 'required|string'
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->whereIn('status', ['on_progress'])
                                  ->firstOrFail();
        
        $schedule->update([
            'status' => 'pending',
            'assigned_mitra_id' => null,
            'assigned_at' => null,
            'on_the_way_at' => null,
            'cancelled_at' => now(),
            'cancellation_reason' => $request->reason
        ]);
        
        // Notify user
        $schedule->user->notify(new PickupCancelled($schedule, $request->reason));
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule cancelled and returned to available pool'
        ]);
    }
    
    /**
     * Get mitra's active schedules
     */
    public function myActiveSchedules()
    {
        $mitra = Auth::user();
        
        $schedules = PickupSchedule::where('assigned_mitra_id', $mitra->id)
                                   ->where('status', 'on_progress')
                                   ->with('user:id,name,phone,address')
                                   ->get();
        
        return response()->json([
            'success' => true,
            'data' => ['schedules' => $schedules]
        ]);
    }
    
    /**
     * Get mitra's completed schedules history
     */
    public function history(Request $request)
    {
        $mitra = Auth::user();
        
        $query = PickupSchedule::where('assigned_mitra_id', $mitra->id)
                               ->where('status', 'completed');
        
        if ($request->has('date_from')) {
            $query->whereDate('completed_at', '>=', $request->date_from);
        }
        
        if ($request->has('date_to')) {
            $query->whereDate('completed_at', '<=', $request->date_to);
        }
        
        $schedules = $query->orderBy('completed_at', 'desc')
                          ->paginate($request->input('per_page', 20));
        
        return response()->json([
            'success' => true,
            'data' => [
                'schedules' => $schedules->items(),
                'pagination' => [
                    'current_page' => $schedules->currentPage(),
                    'total' => $schedules->total()
                ]
            ]
        ]);
    }
}
```

### Routes Configuration (routes/api.php)

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Mitra\MitraPickupController;

// Mitra routes
Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    
    // Pickup schedules
    Route::prefix('pickup-schedules')->group(function () {
        Route::get('/available', [MitraPickupController::class, 'availableSchedules']);
        Route::get('/my-active', [MitraPickupController::class, 'myActiveSchedules']);
        Route::get('/history', [MitraPickupController::class, 'history']);
        Route::get('/{id}', [MitraPickupController::class, 'showSchedule']);
        
        Route::post('/{id}/accept', [MitraPickupController::class, 'acceptSchedule']);
        Route::post('/{id}/start-journey', [MitraPickupController::class, 'startJourney']);
        Route::post('/{id}/arrive', [MitraPickupController::class, 'arrive']);
        Route::post('/{id}/complete', [MitraPickupController::class, 'completePickup']);
        Route::post('/{id}/cancel', [MitraPickupController::class, 'cancelSchedule']);
    });
});
```

### Model: PickupSchedule.php

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PickupSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'assigned_mitra_id',
        'pickup_address',
        'latitude',
        'longitude',
        'schedule_day',
        'waste_type_scheduled',
        'scheduled_pickup_at',
        'pickup_time_start',
        'pickup_time_end',
        'has_additional_waste',
        'additional_wastes',
        'waste_summary',
        'notes',
        'status',
        'assigned_at',
        'on_the_way_at',
        'picked_up_at',
        'completed_at',
        'actual_weights',
        'total_weight',
        'pickup_photos',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected $casts = [
        'additional_wastes' => 'array',
        'actual_weights' => 'array',
        'pickup_photos' => 'array',
        'scheduled_pickup_at' => 'datetime',
        'assigned_at' => 'datetime',
        'on_the_way_at' => 'datetime',
        'picked_up_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'has_additional_waste' => 'boolean',
        'total_weight' => 'float',
    ];

    /**
     * Get the user who created the schedule
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the mitra assigned to the schedule
     */
    public function mitra()
    {
        return $this->belongsTo(User::class, 'assigned_mitra_id');
    }
}
```

---

<a name="notification-system"></a>
## 🔔 Notification System

### 1. Notification: MitraAssigned.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\DatabaseMessage;
use App\Models\PickupSchedule;
use App\Models\User;

class MitraAssigned extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $mitra;

    public function __construct(PickupSchedule $schedule, User $mitra)
    {
        $this->schedule = $schedule;
        $this->mitra = $mitra;
    }

    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'mitra_assigned',
            'title' => 'Mitra Menerima Jadwal Anda!',
            'message' => "Mitra {$this->mitra->name} menerima jadwal pengambilan Anda.",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'on_progress',
                'mitra' => [
                    'id' => $this->mitra->id,
                    'name' => $this->mitra->name,
                    'phone' => $this->mitra->phone,
                    'vehicle_type' => $this->mitra->vehicle_type,
                    'vehicle_plate' => $this->mitra->vehicle_plate,
                ],
                'scheduled_pickup_at' => $this->schedule->scheduled_pickup_at,
            ],
            'action_url' => "/activity/schedule/{$this->schedule->id}",
            'icon' => 'ic_truck.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }
}
```

### 2. Notification: PickupCompleted.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use App\Models\PickupSchedule;

class PickupCompleted extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $points;

    public function __construct(PickupSchedule $schedule, int $points)
    {
        $this->schedule = $schedule;
        $this->points = $points;
    }

    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'pickup_completed',
            'title' => 'Pengambilan Selesai!',
            'message' => "Pengambilan sampah selesai. Anda mendapat +{$this->points} poin!",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'completed',
                'total_weight' => $this->schedule->total_weight,
                'actual_weights' => $this->schedule->actual_weights,
                'points_earned' => $this->points,
                'pickup_photos' => $this->schedule->pickup_photos,
                'completed_at' => $this->schedule->completed_at,
            ],
            'action_url' => "/activity/schedule/{$this->schedule->id}",
            'icon' => 'ic_check.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }
}
```

### 3. Notification: PickupCancelled.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use App\Models\PickupSchedule;

class PickupCancelled extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $reason;

    public function __construct(PickupSchedule $schedule, string $reason)
    {
        $this->schedule = $schedule;
        $this->reason = $reason;
    }

    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'pickup_cancelled',
            'title' => 'Jadwal Dibatalkan',
            'message' => "Mitra membatalkan jadwal pengambilan. Alasan: {$this->reason}",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'pending',
                'cancellation_reason' => $this->reason,
                'cancelled_at' => now()->toISOString(),
            ],
            'action_url' => "/activity",
            'icon' => 'ic_notification.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }
}
```

### 4. Event: PickupStatusUpdated.php (Optional - for Realtime)

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\PickupSchedule;

class PickupStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $schedule;

    public function __construct(PickupSchedule $schedule)
    {
        $this->schedule = $schedule->load('mitra', 'user');
    }

    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->schedule->user_id);
    }

    public function broadcastWith()
    {
        return [
            'schedule_id' => $this->schedule->id,
            'status' => $this->schedule->status,
            'mitra' => $this->schedule->mitra ? [
                'id' => $this->schedule->mitra->id,
                'name' => $this->schedule->mitra->name,
                'phone' => $this->schedule->mitra->phone,
            ] : null,
            'updated_at' => $this->schedule->updated_at->toISOString(),
        ];
    }

    public function broadcastAs()
    {
        return 'pickup.status_updated';
    }
}
```

---

<a name="visual-flow-diagram"></a>
## 📱 Visual Flow Diagram

### Complete User Journey

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SIDE                                │
└─────────────────────────────────────────────────────────────────┘

[User membuka app]
       ↓
[Tap FAB "+" button]
       ↓
[Form: Pilih jenis sampah, jadwal, alamat]
       ↓
[Submit → POST /api/pickup-schedules]
       ↓
[Status: PENDING ⏳]
       │
       │ (Menunggu mitra...)
       │
       ↓
[🔔 Notifikasi: "Mitra John Doe menerima jadwal Anda!"]
       ↓
[Status auto-update: ON_PROGRESS 🚛]
       │
       │ (Display info mitra: nama, telpon, kendaraan)
       │
       ↓
[🔔 Notifikasi: "Mitra telah sampai"]
       ↓
[Mitra mengambil sampah...]
       ↓
[🔔 Notifikasi: "Pengambilan selesai! +67 poin"]
       ↓
[Status: COMPLETED ✅]
       ↓
[Points bertambah: 150 → 217 poin]


┌─────────────────────────────────────────────────────────────────┐
│                       MITRA SIDE                                │
└─────────────────────────────────────────────────────────────────┘

[Mitra membuka app]
       ↓
[Tab "Jadwal Tersedia"]
       ↓
[GET /api/mitra/pickup-schedules/available]
       ↓
[Melihat list jadwal PENDING:]
  • Ali - Jl. Sudirman (2.5 km)
  • Ahmad - Jl. Thamrin (3.1 km)
       ↓
[Tap salah satu jadwal]
       ↓
[Detail Page: Map, Nama, Telpon, Alamat]
       ↓
[Mitra tap "Terima Jadwal"]
       ↓
[POST /api/mitra/pickup-schedules/36/accept]
       ↓
[Backend: Update status → ON_PROGRESS, Send notification]
       ↓
[Jadwal pindah ke tab "Jadwal Aktif"]
       ↓
[Mitra perjalanan ke lokasi...]
       ↓
[Tap "Selesai"]
       ↓
[Form: Input berat, upload foto]
       ↓
[POST /api/mitra/pickup-schedules/36/complete]
       ↓
[Backend: Calculate points, Update user.points, Send notification]
       ↓
[Success: "Pengambilan berhasil dicatat!"]
```

### Database State Changes

```
STATE 1: User baru buat jadwal
─────────────────────────────────────
id: 36
user_id: 15
status: "pending"
assigned_mitra_id: NULL


STATE 2: Mitra accept jadwal
─────────────────────────────────────
id: 36
status: "on_progress"  ← CHANGED
assigned_mitra_id: 8   ← CHANGED
assigned_at: "2025-11-12 15:30:00"  ← NEW


STATE 3: Mitra complete
─────────────────────────────────────
id: 36
status: "completed"  ← CHANGED
completed_at: "2025-11-13 06:20:00"  ← NEW
actual_weights: {"Organik": 3.5, "B3": 1.2}  ← NEW
total_weight: 4.7  ← NEW
pickup_photos: ["url1.jpg"]  ← NEW


USER TABLE: points updated
─────────────────────────────────────
BEFORE: points: 150
AFTER:  points: 197  (+47 dari 4.7 kg × 10)
```

---

<a name="testing-guide"></a>
## 🧪 Testing Guide

### Prerequisites

1. **Create Test Mitra User:**
```sql
INSERT INTO users (name, email, password, role, phone, vehicle_type, vehicle_plate)
VALUES ('John Doe', 'mitra@test.com', '$2y$10$...', 'mitra', '081987654321', 'Truk', 'B 1234 XYZ');
```

2. **Login as Mitra:**
```bash
curl -X POST "http://127.0.0.1:8000/api/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "mitra@test.com",
    "password": "password"
  }'

# Save the token!
export MITRA_TOKEN="your_token_here"
```

### Test Flow

**1. Get Available Schedules**
```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $MITRA_TOKEN" \
  -H "Accept: application/json"
```

**Expected:** List of pending schedules

---

**2. Get Schedule Detail**
```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/36" \
  -H "Authorization: Bearer $MITRA_TOKEN"
```

**Expected:** Full user info (name, phone, address, map coordinates)

---

**3. Accept Schedule**
```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept" \
  -H "Authorization: Bearer $MITRA_TOKEN" \
  -H "Content-Type: application/json"
```

**Expected:**
- Response: `status: "on_progress"`
- Database: `assigned_mitra_id` set, `status` changed
- Notification created in `notifications` table
- User receives notification

**Verify Notification:**
```bash
# Login as user first
export USER_TOKEN="user_token_here"

curl -X GET "http://127.0.0.1:8000/api/notifications" \
  -H "Authorization: Bearer $USER_TOKEN"
```

---

**4. Complete Pickup**
```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete" \
  -H "Authorization: Bearer $MITRA_TOKEN" \
  -F "actual_weights[Organik]=3.5" \
  -F "actual_weights[Anorganik]=2.0" \
  -F "actual_weights[B3]=1.2" \
  -F "photos[]=@test_photo1.jpg" \
  -F "photos[]=@test_photo2.jpg" \
  -F "notes=Selesai tepat waktu"
```

**Expected:**
- Response: `status: "completed"`, `points_earned: 67`
- Database: Photos uploaded, weights saved
- User points increased

**Verify User Points:**
```bash
curl -X GET "http://127.0.0.1:8000/api/user/profile" \
  -H "Authorization: Bearer $USER_TOKEN"
```

**Expected:** `points` field increased by calculated amount

---

**5. Test Cancel**
```bash
# Accept another schedule first
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/37/accept" \
  -H "Authorization: Bearer $MITRA_TOKEN"

# Then cancel
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/37/cancel" \
  -H "Authorization: Bearer $MITRA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "User tidak ada di lokasi"
  }'
```

**Expected:**
- Schedule back to `pending`
- `assigned_mitra_id` cleared
- User receives cancellation notification

---

### Test Race Condition (Double Accept)

**Terminal 1:**
```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/38/accept" \
  -H "Authorization: Bearer $MITRA_TOKEN_1"
```

**Terminal 2 (simultaneously):**
```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/38/accept" \
  -H "Authorization: Bearer $MITRA_TOKEN_2"
```

**Expected:** 
- One succeeds (200)
- One fails (409 Conflict)
- Only one mitra assigned

---

<a name="checklist"></a>
## ✅ Implementation Checklist

### Backend Tasks

**Database:**
- [ ] Run migration untuk tambah kolom di `pickup_schedules`
- [ ] Verify foreign key created
- [ ] Verify indexes created
- [ ] Test rollback migration

**Notification:**
- [ ] Create `MitraAssigned.php` notification
- [ ] Create `PickupCompleted.php` notification
- [ ] Create `PickupCancelled.php` notification
- [ ] Test notification queue worker running
- [ ] Verify notifications saved to database

**Controller:**
- [ ] Create `MitraPickupController.php`
- [ ] Implement `availableSchedules()` method
- [ ] Implement `showSchedule()` method
- [ ] Implement `acceptSchedule()` method ⭐
- [ ] Implement `completePickup()` method ⭐
- [ ] Implement `cancelSchedule()` method
- [ ] Implement `myActiveSchedules()` method
- [ ] Implement `history()` method

**Routes:**
- [ ] Add mitra routes to `routes/api.php`
- [ ] Test route middleware (auth + role check)
- [ ] Verify route names correct

**Model:**
- [ ] Update `PickupSchedule` model fillable
- [ ] Add casts for JSON fields
- [ ] Add relationship methods
- [ ] Test model relationships

**Testing:**
- [ ] Test get available schedules
- [ ] Test get schedule detail
- [ ] Test accept schedule ⭐
- [ ] Test notification sent to user ⭐
- [ ] Test complete pickup ⭐
- [ ] Test points auto-increment ⭐
- [ ] Test photo upload
- [ ] Test cancel schedule
- [ ] Test race condition (double accept)
- [ ] Test invalid data validation
- [ ] Test unauthorized access

**Validation:**
- [ ] Only pending schedules appear in available list
- [ ] Mitra can only accept unassigned schedules
- [ ] Mitra can only complete their own schedules
- [ ] Minimum 1 photo required for completion
- [ ] Weight must be greater than 0
- [ ] Points calculation correct (1 kg = 10 points)

**Edge Cases:**
- [ ] Handle schedule already accepted by another mitra
- [ ] Handle mitra cancelling after accepting
- [ ] Handle user cancelling after mitra accepted
- [ ] Handle photo upload failures
- [ ] Handle large file uploads
- [ ] Handle network timeouts

---

## 🚀 Priority Timeline

### Week 1 (URGENT - Core Features)
1. ✅ Database migration
2. ✅ GET available schedules API
3. ✅ GET schedule detail API
4. ✅ POST accept schedule API
5. ✅ POST complete pickup API
6. ✅ Notification system (3 notifications)
7. ✅ Points auto-increment logic

### Week 2 (Important)
8. ⭕ POST cancel schedule API
9. ⭕ GET my-active schedules API
10. ⭕ GET history API
11. ⭕ Photo upload optimization
12. ⭕ Comprehensive testing

### Week 3 (Optional Enhancements)
13. ⭕ Realtime location tracking
14. ⭕ ETA calculation
15. ⭕ Rating system
16. ⭕ Push notifications (FCM)

---

## 🔍 Troubleshooting

### Issue: Double Accept (Race Condition)
**Problem:** Two mitras accept same schedule simultaneously

**Solution:** Use database transaction with row lock
```php
$schedule = PickupSchedule::where('id', $id)
    ->where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->lockForUpdate()  // ← This prevents race condition
    ->firstOrFail();
```

---

### Issue: Notification Not Sent
**Check:**
1. Queue worker running? `php artisan queue:work`
2. Notifications table exists? Check migration
3. User relationship correct in model?
4. Notification class in correct namespace?

**Debug:**
```bash
# Check queue
php artisan queue:work --verbose

# Check logs
tail -f storage/logs/laravel.log
```

---

### Issue: Photos Not Uploaded
**Check:**
1. Storage linked? `php artisan storage:link`
2. Permissions correct? `chmod -R 755 storage`
3. Max upload size in php.ini? `upload_max_filesize = 10M`
4. Disk config in `config/filesystems.php`?

**Test:**
```bash
# Manual test
curl -X POST "http://127.0.0.1:8000/api/test/upload" \
  -F "photo=@test.jpg"
```

---

### Issue: Points Not Incremented
**Check:**
1. Transaction succeeded?
2. User model has `increment()` available?
3. Points field exists in users table?
4. Check database logs

**Debug:**
```php
DB::enableQueryLog();
$schedule->user->increment('points', $points);
dd(DB::getQueryLog());
```

---

### Issue: Status Not Updated in User App
**Check:**
1. Auto-refresh implemented in Flutter?
2. WebSocket/Pusher configured?
3. Broadcasting working?
4. Channel subscription correct?

**Test Notification:**
```bash
# Check if notification created
SELECT * FROM notifications 
WHERE notifiable_id = {user_id} 
ORDER BY created_at DESC 
LIMIT 5;
```

---

## 📞 Support & Contact

**Flutter Team Status:** ✅ Ready to integrate  
**Backend Team:** Implementation in progress  
**Priority:** 🔴 URGENT - Core Feature

**Questions?**
- Check this complete documentation
- Test with provided curl commands
- Review troubleshooting section
- Contact project lead if stuck

---

## 📦 Deliverables Summary

### What Backend Must Deliver:

**1. API Endpoints (7 endpoints):**
- ✅ GET `/api/mitra/pickup-schedules/available`
- ✅ GET `/api/mitra/pickup-schedules/{id}`
- ✅ POST `/api/mitra/pickup-schedules/{id}/accept`
- ✅ POST `/api/mitra/pickup-schedules/{id}/start-journey`
- ✅ POST `/api/mitra/pickup-schedules/{id}/arrive`
- ✅ POST `/api/mitra/pickup-schedules/{id}/complete`
- ✅ POST `/api/mitra/pickup-schedules/{id}/cancel`

**2. Database:**
- ✅ Migration file
- ✅ 11 new columns in `pickup_schedules`
- ✅ Foreign keys & indexes

**3. Notification:**
- ✅ 3 notification classes
- ✅ Auto-send on events
- ✅ Save to database
- ✅ Broadcast support (optional)

**4. Business Logic:**
- ✅ Status transition (pending → on_progress → completed)
- ✅ Points calculation (1 kg = 10 points)
- ✅ Photo upload to storage
- ✅ Prevent double-accept (race condition)
- ✅ Transaction safety

**5. Testing:**
- ✅ Postman collection / curl commands
- ✅ Test with real data
- ✅ Verify notifications sent
- ✅ Verify points increment
- ✅ Edge case testing

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
10. ✅ All curl tests pass

---

## 📅 Timeline

**Estimated Backend Work:** 2-3 hari (with testing)  
**Flutter Integration:** 1-2 hari (UI Mitra app)  
**End-to-End Testing:** 1 hari  
**Total:** 4-6 hari sampai production ready

---

**Dokumentasi dibuat:** 13 November 2025  
**Status:** 🔴 READY TO IMPLEMENT  
**Version:** 1.0.0  
**Flutter Team:** Waiting for API ready  

**Let's build this! 🚀**

---

**END OF DOCUMENTATION**
