# 🚛 Sistem Penjemputan Sampah: User ↔ Mitra
## Dokumentasi Backend API untuk Interaksi User-Mitra

> **Tanggal:** 12 November 2025  
> **Status:** 🔴 URGENT - Feature Inti Aplikasi  
> **Priority:** CRITICAL

---

## 📋 Overview Feature

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

---

## 🗄️ Database Schema yang Dibutuhkan

### Tabel Utama: `pickup_schedules`

**Fields yang sudah ada + tambahan:**

```sql
ALTER TABLE pickup_schedules ADD COLUMN IF NOT EXISTS:

-- Mitra Assignment
assigned_mitra_id BIGINT UNSIGNED NULL COMMENT 'ID Mitra yang menerima',
assigned_at DATETIME NULL COMMENT 'Kapan mitra accept',

-- Tracking Status
on_the_way_at DATETIME NULL COMMENT 'Kapan mitra mulai perjalanan',
picked_up_at DATETIME NULL COMMENT 'Kapan sampai lokasi user',
completed_at DATETIME NULL COMMENT 'Kapan selesai',

-- Completion Data
actual_weights JSON NULL COMMENT 'Berat aktual per jenis sampah',
total_weight DECIMAL(8,2) NULL COMMENT 'Total berat (kg)',
pickup_photos JSON NULL COMMENT 'Array foto bukti pengambilan',

-- Cancellation
cancelled_at DATETIME NULL,
cancellation_reason TEXT NULL,

-- Foreign Key
FOREIGN KEY (assigned_mitra_id) REFERENCES users(id) ON DELETE SET NULL;

-- Index
CREATE INDEX idx_assigned_mitra ON pickup_schedules(assigned_mitra_id);
CREATE INDEX idx_status_mitra ON pickup_schedules(status, assigned_mitra_id);
```

### Enum Status Flow:

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

## 🔌 API Endpoints yang Dibutuhkan

### 1. **GET /api/mitra/pickup-schedules/available**
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
        "created_at": "2025-11-12 14:12:48",
        "distance_from_mitra": 2.5,
        "estimated_duration": "15 minutes"
      }
    ],
    "total": 15
  }
}
```

**Notes:**
- Hanya tampilkan jadwal dengan `status = 'pending'`
- Urutkan berdasarkan waktu penjemputan terdekat
- Optional: Hitung jarak dari lokasi mitra saat ini

---

### 2. **GET /api/mitra/pickup-schedules/{id}**
**Fungsi:** Mitra melihat detail jadwal sebelum accept

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/36`

**Headers:**
```
Authorization: Bearer {mitra_token}
Accept: application/json
```

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
      "schedule_day": "rabu",
      "waste_type_scheduled": "B3",
      "scheduled_pickup_at": "2025-11-13 06:00:00",
      "pickup_time_start": "06:00:00",
      "pickup_time_end": "08:00:00",
      "has_additional_waste": false,
      "additional_wastes": null,
      "waste_summary": "B3",
      "notes": "Sampah sudah dipilah. Mohon tepat waktu.",
      "status": "pending",
      "created_at": "2025-11-12 14:12:48",
      "distance_from_mitra": 2.5,
      "estimated_duration": "15 minutes",
      "estimated_weight": 0
    }
  }
}
```

**Notes:**
- Include data user lengkap (nama, telpon, alamat, foto)
- Include koordinat untuk tampil di map
- Hitung estimasi jarak dan waktu tempuh

---

### 3. **POST /api/mitra/pickup-schedules/{id}/accept**
**Fungsi:** Mitra menerima jadwal penjemputan

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
Accept: application/json
```

**Request Body (Optional):**
```json
{
  "estimated_arrival": "2025-11-13 06:15:00",
  "notes": "Dalam perjalanan, ETA 15 menit"
}
```

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

**What Happens Backend:**
1. Update `assigned_mitra_id` = mitra yang login
2. Update `status` = 'on_progress'
3. Set `assigned_at` = now()
4. **KIRIM NOTIFIKASI KE USER**: "Mitra sedang dalam perjalanan"
5. Lock jadwal (tidak bisa di-accept mitra lain)

**Validasi:**
- Jadwal harus status `pending`
- Mitra belum punya jadwal active lain (optional)
- Jadwal belum expired

**Error Response (409 Conflict):**
```json
{
  "success": false,
  "message": "Schedule already accepted by another mitra"
}
```

---

### 4. **POST /api/mitra/pickup-schedules/{id}/start-journey**
**Fungsi:** Mitra mulai perjalanan ke lokasi user

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/start-journey`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "current_latitude": -6.200000,
  "current_longitude": 106.816666,
  "estimated_arrival": "2025-11-13 06:20:00"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Journey started",
  "data": {
    "schedule": {
      "id": 36,
      "status": "on_progress",
      "on_the_way_at": "2025-11-12 15:35:00"
    }
  }
}
```

**What Happens:**
- Set `on_the_way_at` = now()
- **KIRIM NOTIFIKASI KE USER**: "Mitra dalam perjalanan, ETA 15 menit"
- Enable realtime location tracking (optional)

---

### 5. **POST /api/mitra/pickup-schedules/{id}/arrive**
**Fungsi:** Mitra sampai di lokasi user

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/arrive`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "latitude": -6.208763,
  "longitude": 106.845599
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Arrival confirmed",
  "data": {
    "picked_up_at": "2025-11-13 06:15:00"
  }
}
```

**What Happens:**
- Set `picked_up_at` = now()
- **KIRIM NOTIFIKASI KE USER**: "Mitra telah sampai"

---

### 6. **POST /api/mitra/pickup-schedules/{id}/complete**
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

**What Happens Backend:**
1. Update `status` = 'completed'
2. Set `completed_at` = now()
3. Save `actual_weights` (JSON)
4. Calculate `total_weight`
5. Upload photos ke storage
6. **HITUNG POIN USER** (1 kg = 10 poin)
7. **UPDATE points user**
8. **KIRIM NOTIFIKASI KE USER**: "Pengambilan selesai! Anda dapat +67 poin"
9. **UPDATE statistik mitra** (total_collections++)

**Validasi:**
- Jadwal harus status `on_progress`
- Mitra harus yang assigned
- Minimal 1 foto wajib
- Berat harus > 0

---

### 7. **POST /api/mitra/pickup-schedules/{id}/cancel**
**Fungsi:** Mitra membatalkan jadwal (dengan alasan)

**URL:** `POST http://127.0.0.1:8000/api/mitra/pickup-schedules/36/cancel`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

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
- Set `status` = 'pending' (kembali ke available)
- Clear `assigned_mitra_id`
- Set `cancelled_at` dan `cancellation_reason`
- **KIRIM NOTIFIKASI KE USER**: "Mitra membatalkan jadwal dengan alasan: ..."
- Jadwal kembali available untuk mitra lain

---

### 8. **GET /api/mitra/pickup-schedules/my-active**
**Fungsi:** Mitra melihat jadwal yang sedang aktif (on_progress)

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/my-active`

**Headers:**
```
Authorization: Bearer {mitra_token}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 36,
        "user_name": "Ali",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 123",
        "status": "on_progress",
        "assigned_at": "2025-11-13 06:00:00",
        "latitude": -6.208763,
        "longitude": 106.845599
      }
    ]
  }
}
```

---

### 9. **GET /api/mitra/pickup-schedules/history**
**Fungsi:** Riwayat jadwal completed oleh mitra

**URL:** `GET http://127.0.0.1:8000/api/mitra/pickup-schedules/history`

**Query Parameters:**
```
page      = 1
per_page  = 20
date_from = 2025-11-01
date_to   = 2025-11-30
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 35,
        "user_name": "Ahmad",
        "pickup_address": "Jl. Thamrin",
        "completed_at": "2025-11-12 10:30:00",
        "total_weight": 5.5,
        "status": "completed"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total": 45
    },
    "summary": {
      "total_completed": 45,
      "total_weight_collected": 250.5,
      "total_earnings": 450000
    }
  }
}
```

---

### 10. **POST /api/mitra/location/update**
**Fungsi:** Update lokasi realtime mitra (optional, untuk tracking)

**URL:** `POST http://127.0.0.1:8000/api/mitra/location/update`

**Headers:**
```
Authorization: Bearer {mitra_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "latitude": -6.200000,
  "longitude": 106.816666,
  "heading": 270.5,
  "speed": 40.5
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Location updated"
}
```

**Notes:**
- Broadcast ke user yang sedang menunggu
- Simpan ke tabel `mitra_locations` (last 30 minutes)
- Optional feature untuk live tracking

---

## 📱 Notification Events

### Untuk User:

| Event | Trigger | Message |
|-------|---------|---------|
| `mitra_assigned` | Mitra accept jadwal | "Mitra **{nama}** menerima jadwal Anda!" |
| `mitra_on_the_way` | Mitra start journey | "Mitra dalam perjalanan, ETA 15 menit" |
| `mitra_arrived` | Mitra sampai lokasi | "Mitra telah sampai di lokasi" |
| `pickup_completed` | Mitra complete | "Pengambilan selesai! +67 poin" |
| `pickup_cancelled` | Mitra cancel | "Jadwal dibatalkan: {reason}" |

### Untuk Mitra:

| Event | Trigger | Message |
|-------|---------|---------|
| `new_schedule_available` | User buat jadwal | "Jadwal baru tersedia di area Anda" |
| `user_cancelled` | User cancel | "User membatalkan jadwal #{id}" |

---

## 🔔 WebSocket/Pusher Events (Optional tapi Recommended)

### Channel: `user.{user_id}`
```javascript
// Event yang diterima user
{
  "event": "pickup.status_updated",
  "data": {
    "schedule_id": 36,
    "status": "on_progress",
    "mitra": {
      "name": "John Doe",
      "phone": "081987654321",
      "vehicle": "Truk - B 1234 XYZ",
      "current_location": {
        "lat": -6.200000,
        "lng": 106.816666
      },
      "eta": "15 minutes"
    }
  }
}
```

### Channel: `mitra.{mitra_id}`
```javascript
// Event yang diterima mitra
{
  "event": "schedule.new_available",
  "data": {
    "schedule_id": 37,
    "user_name": "Ahmad",
    "pickup_address": "Jl. Sudirman",
    "distance": 2.5,
    "waste_type": "Organik"
  }
}
```

---

## 💾 Laravel Implementation

### Model: MitraPickupController.php

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
     * Accept schedule
     */
    public function acceptSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('status', 'pending')
                                  ->whereNull('assigned_mitra_id')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $mitra, $request) {
            $schedule->update([
                'assigned_mitra_id' => $mitra->id,
                'status' => 'on_progress',
                'assigned_at' => now(),
            ]);
            
            // Send notification to user
            $schedule->user->notify(new MitraAssigned($schedule, $mitra));
            
            // Broadcast event
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
        
        // Notify user
        // broadcast(new MitraOnTheWay($schedule));
        
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
     * Complete pickup with photos and weight
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
            // Calculate total weight
            $totalWeight = array_sum($request->actual_weights);
            
            // Upload photos
            $photoUrls = [];
            foreach ($request->file('photos') as $photo) {
                $path = $photo->store("pickups/{$schedule->id}", 'public');
                $photoUrls[] = Storage::url($path);
            }
            
            // Update schedule
            $schedule->update([
                'status' => 'completed',
                'completed_at' => now(),
                'actual_weights' => $request->actual_weights,
                'total_weight' => $totalWeight,
                'pickup_photos' => $photoUrls,
                'notes' => $request->notes
            ]);
            
            // Calculate and add points to user (1 kg = 10 points)
            $points = (int)($totalWeight * 10);
            $schedule->user->increment('points', $points);
            
            // Update mitra statistics
            $mitra->increment('total_collections');
            
            // Notify user
            // $schedule->user->notify(new PickupCompleted($schedule, $points));
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
        // $schedule->user->notify(new PickupCancelled($schedule));
        
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
        
        // Calculate summary
        $summary = [
            'total_completed' => PickupSchedule::where('assigned_mitra_id', $mitra->id)
                                               ->where('status', 'completed')
                                               ->count(),
            'total_weight_collected' => PickupSchedule::where('assigned_mitra_id', $mitra->id)
                                                       ->where('status', 'completed')
                                                       ->sum('total_weight'),
        ];
        
        return response()->json([
            'success' => true,
            'data' => [
                'schedules' => $schedules->items(),
                'pagination' => [
                    'current_page' => $schedules->currentPage(),
                    'total' => $schedules->total()
                ],
                'summary' => $summary
            ]
        ]);
    }
}
```

### Routes (routes/api.php)

```php
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
    
    // Location tracking (optional)
    Route::post('/location/update', [MitraLocationController::class, 'update']);
});
```

---

## ✅ Testing Checklist

### Backend:
- [ ] Mitra bisa lihat list jadwal pending
- [ ] Mitra bisa lihat detail jadwal (nama, telpon, alamat, map)
- [ ] Mitra bisa accept jadwal → status jadi on_progress
- [ ] User otomatis terima notifikasi saat mitra accept
- [ ] Status di app user otomatis update (pending → on_progress)
- [ ] Mitra bisa complete dengan upload foto minimal 1
- [ ] Points user otomatis bertambah setelah complete
- [ ] Mitra bisa cancel jadwal → kembali ke pending
- [ ] Mitra tidak bisa accept jadwal yang sudah di-accept mitra lain
- [ ] History mitra menampilkan semua completed schedules

### Flutter (Mitra App):
- [ ] Tab "Jadwal Tersedia" tampilkan list pending
- [ ] Tap jadwal → Detail page dengan map, nama user, telpon, alamat
- [ ] Button "Terima Jadwal" berfungsi
- [ ] Setelah accept → Pindah ke "Jadwal Aktif"
- [ ] Button "Mulai Perjalanan" update status
- [ ] Button "Sampai di Lokasi" aktif
- [ ] Form complete: input berat per jenis sampah
- [ ] Upload foto bukti pengambilan (min 1, max 3)
- [ ] Button "Selesai" submit data
- [ ] Riwayat tampilkan completed schedules

### Flutter (User App):
- [ ] Status berubah PENDING → ON_PROGRESS realtime
- [ ] Notifikasi muncul saat mitra accept
- [ ] Bisa lihat info mitra (nama, telpon, kendaraan)
- [ ] Points bertambah setelah mitra complete
- [ ] Bisa lihat foto bukti pengambilan

---

## 🚀 Priority Implementation

### Phase 1: Core Feature (URGENT)
1. ✅ API available schedules untuk mitra
2. ✅ API accept schedule
3. ✅ API complete pickup (dengan foto dan berat)
4. ✅ Auto update points user
5. ✅ Notifikasi status change

### Phase 2: Enhancement
6. ⭕ Realtime location tracking
7. ⭕ ETA calculation
8. ⭕ WebSocket/Pusher integration
9. ⭕ Rating system

---

**Status:** 🔴 URGENT - Core Feature  
**Estimated Backend Work:** 2-3 hari  
**Dependencies:** Notification system (sudah ready)

*Dokumentasi dibuat: 12 November 2025*
