# 🎯 API Endpoint: Activity Schedule Management
## Dokumentasi untuk Backend Team

> **Tanggal:** 12 November 2025  
> **Status:** 🔴 URGENT - Flutter sudah ready, menunggu implementasi backend  
> **Priority:** HIGH

---

## 📢 PENTING: Perbedaan Endpoint!

### ⚠️ **CATATAN KRITIS:**
Ada **perbedaan endpoint** antara dokumentasi awal dengan yang digunakan di Flutter:

| Aspek | Dokumentasi Awal | Yang Diimplementasi Flutter |
|-------|------------------|----------------------------|
| **Endpoint Base** | `/api/schedules` | `/api/waste-schedules` |
| **Route Prefix** | `schedules` | `waste-schedules` |

**Mohon gunakan endpoint `/api/waste-schedules` seperti yang sudah diimplementasi di Flutter!**

---

## 📋 Endpoints yang Harus Dibuat

### 1. GET /api/waste-schedules
**Fungsi:** Mendapatkan semua jadwal user dengan filter

**URL:** `GET http://127.0.0.1:8000/api/waste-schedules`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Query Parameters (Semua Optional):**
```
status         // Filter: pending, in_progress, completed, cancelled
date           // Filter tanggal: YYYY-MM-DD (contoh: 2025-11-12)
waste_type     // Filter: Organik, Anorganik, B3, Elektronik
page           // Halaman (default: 1)
per_page       // Items per halaman (default: 20, max: 100)
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 1,
        "user_id": 14,
        "mitra_id": 5,
        "service_type": "Pengambilan Sampah Organik",
        "waste_type": "Organik",
        "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
        "pickup_latitude": -6.208763,
        "pickup_longitude": 106.845599,
        "scheduled_at": "2025-11-12 08:00:00",
        "status": "pending",
        "notes": "Sampah sudah dipilah. Mohon diambil tepat waktu.",
        "estimated_weight": 5.5,
        "actual_weight": null,
        "photo_proof": null,
        "accepted_at": null,
        "started_at": null,
        "completed_at": null,
        "cancelled_at": null,
        "cancellation_reason": null,
        "created_at": "2025-11-10 14:30:00",
        "updated_at": "2025-11-10 14:30:00",
        "mitra": {
          "id": 5,
          "name": "John Doe",
          "vehicle_type": "Truk",
          "vehicle_plate": "B 1234 XYZ",
          "phone": "081234567890"
        }
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 15,
      "last_page": 1,
      "from": 1,
      "to": 15
    },
    "summary": {
      "total_schedules": 15,
      "active_count": 3,
      "completed_count": 10,
      "cancelled_count": 2,
      "by_status": {
        "pending": 2,
        "in_progress": 1,
        "completed": 10,
        "cancelled": 2
      }
    }
  }
}
```

**Response Error (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized. Please login again.",
  "errors": {
    "auth": ["Token is invalid or expired"]
  }
}
```

**Response Error (404 Not Found - Saat ini):**
```json
{
  "error": "http_error",
  "message": "The route waste-schedules could not be found."
}
```

---

### 2. GET /api/waste-schedules/{id}
**Fungsi:** Mendapatkan detail 1 jadwal

**URL:** `GET http://127.0.0.1:8000/api/waste-schedules/1`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule detail retrieved successfully",
  "data": {
    "schedule": {
      "id": 1,
      "user_id": 14,
      "mitra_id": 5,
      "service_type": "Pengambilan Sampah Organik",
      "waste_type": "Organik",
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "pickup_latitude": -6.208763,
      "pickup_longitude": 106.845599,
      "scheduled_at": "2025-11-12 08:00:00",
      "status": "pending",
      "notes": "Sampah sudah dipilah",
      "estimated_weight": 5.5,
      "created_at": "2025-11-10 14:30:00",
      "updated_at": "2025-11-10 14:30:00",
      "mitra": {
        "id": 5,
        "name": "John Doe",
        "vehicle_type": "Truk",
        "vehicle_plate": "B 1234 XYZ",
        "phone": "081234567890",
        "rating": 4.8
      }
    }
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Schedule not found"
}
```

---

### 3. POST /api/waste-schedules
**Fungsi:** Membuat jadwal pengambilan sampah baru

**URL:** `POST http://127.0.0.1:8000/api/waste-schedules`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "service_type": "Pengambilan Sampah Organik",
  "waste_type": "Organik",
  "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
  "pickup_latitude": -6.208763,
  "pickup_longitude": 106.845599,
  "scheduled_at": "2025-11-15 08:00:00",
  "notes": "Sampah sudah dipilah. Mohon tepat waktu.",
  "estimated_weight": 5.5
}
```

**Field Validasi:**
- `service_type`: **Required**, string, max 100 char
- `waste_type`: **Required**, enum: `Organik`, `Anorganik`, `B3`, `Elektronik`
- `pickup_address`: **Required**, string/text
- `pickup_latitude`: Optional, numeric (decimal)
- `pickup_longitude`: Optional, numeric (decimal)
- `scheduled_at`: **Required**, datetime, harus lebih besar dari waktu sekarang
- `notes`: Optional, string/text
- `estimated_weight`: Optional, numeric, minimum 0

**Response Success (201):**
```json
{
  "success": true,
  "message": "Schedule created successfully",
  "data": {
    "schedule": {
      "id": 16,
      "user_id": 14,
      "service_type": "Pengambilan Sampah Organik",
      "waste_type": "Organik",
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "pickup_latitude": -6.208763,
      "pickup_longitude": 106.845599,
      "scheduled_at": "2025-11-15 08:00:00",
      "status": "pending",
      "notes": "Sampah sudah dipilah. Mohon tepat waktu.",
      "estimated_weight": 5.5,
      "created_at": "2025-11-12 10:30:00",
      "updated_at": "2025-11-12 10:30:00"
    }
  }
}
```

**Response Error (422 Validation):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "waste_type": ["The selected waste type is invalid."],
    "scheduled_at": ["The scheduled at must be a date after now."]
  }
}
```

---

### 4. POST /api/waste-schedules/{id}/cancel
**Fungsi:** Membatalkan jadwal

**URL:** `POST http://127.0.0.1:8000/api/waste-schedules/1/cancel`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

**Request Body:**
```json
{
  "reason": "Ada perubahan rencana mendadak"
}
```

**Field:**
- `reason`: Optional, string (default: "Cancelled by user")

**Response Success (200):**
```json
{
  "success": true,
  "message": "Schedule cancelled successfully",
  "data": {
    "schedule": {
      "id": 1,
      "status": "cancelled",
      "cancelled_at": "2025-11-12 11:00:00",
      "cancellation_reason": "Ada perubahan rencana mendadak"
    }
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Schedule not found or cannot be cancelled"
}
```

**Catatan:** Hanya jadwal dengan status `pending` atau `in_progress` yang bisa dibatalkan.

---

## 🗄️ Database Schema

### Tabel: `waste_schedules`

```sql
CREATE TABLE waste_schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    mitra_id BIGINT UNSIGNED NULL,
    
    -- Service info
    service_type VARCHAR(100) NOT NULL,
    waste_type ENUM('Organik', 'Anorganik', 'B3', 'Elektronik') NOT NULL,
    
    -- Location
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8) NULL,
    pickup_longitude DECIMAL(11, 8) NULL,
    
    -- Schedule
    scheduled_at DATETIME NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    notes TEXT NULL,
    
    -- Status timestamps
    accepted_at DATETIME NULL COMMENT 'Kapan mitra accept',
    started_at DATETIME NULL COMMENT 'Kapan mitra mulai perjalanan',
    completed_at DATETIME NULL COMMENT 'Kapan selesai',
    cancelled_at DATETIME NULL COMMENT 'Kapan dibatalkan',
    cancellation_reason TEXT NULL,
    
    -- Weight tracking
    estimated_weight DECIMAL(8, 2) NULL COMMENT 'Estimasi berat (kg)',
    actual_weight DECIMAL(8, 2) NULL COMMENT 'Berat aktual setelah ditimbang (kg)',
    
    -- Proof
    photo_proof VARCHAR(255) NULL COMMENT 'Foto bukti pengambilan',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    -- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mitra_id) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes untuk performa
    INDEX idx_user_id (user_id),
    INDEX idx_mitra_id (mitra_id),
    INDEX idx_status (status),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 💻 Laravel Implementation Guide

### Step 1: Create Migration

```bash
php artisan make:migration create_waste_schedules_table
```

Copy schema di atas ke migration file.

### Step 2: Create Model

```bash
php artisan make:model WasteSchedule
```

**File:** `app/Models/WasteSchedule.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class WasteSchedule extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'mitra_id',
        'service_type',
        'waste_type',
        'pickup_address',
        'pickup_latitude',
        'pickup_longitude',
        'scheduled_at',
        'status',
        'notes',
        'accepted_at',
        'started_at',
        'completed_at',
        'cancelled_at',
        'cancellation_reason',
        'estimated_weight',
        'actual_weight',
        'photo_proof',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'accepted_at' => 'datetime',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'estimated_weight' => 'decimal:2',
        'actual_weight' => 'decimal:2',
        'pickup_latitude' => 'decimal:8',
        'pickup_longitude' => 'decimal:8',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function mitra()
    {
        return $this->belongsTo(User::class, 'mitra_id');
    }
}
```

### Step 3: Create Controller

```bash
php artisan make:controller Api/WasteScheduleController
```

**File:** `app/Http/Controllers/Api/WasteScheduleController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WasteSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class WasteScheduleController extends Controller
{
    /**
     * Get user schedules with filtering
     */
    public function index(Request $request)
    {
        try {
            $user = Auth::user();
            
            // Query builder
            $query = WasteSchedule::where('user_id', $user->id)
                                  ->with('mitra:id,name,vehicle_type,vehicle_plate,phone');
            
            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }
            
            // Filter by date (YYYY-MM-DD)
            if ($request->has('date')) {
                $date = \Carbon\Carbon::parse($request->date);
                $query->whereDate('scheduled_at', $date);
            }
            
            // Filter by waste_type
            if ($request->has('waste_type')) {
                $query->where('waste_type', $request->waste_type);
            }
            
            // Pagination
            $perPage = $request->input('per_page', 20);
            $schedules = $query->orderBy('scheduled_at', 'desc')
                              ->paginate($perPage);
            
            // Summary statistics
            $summary = [
                'total_schedules' => WasteSchedule::where('user_id', $user->id)->count(),
                'active_count' => WasteSchedule::where('user_id', $user->id)
                                              ->whereIn('status', ['pending', 'in_progress'])
                                              ->count(),
                'completed_count' => WasteSchedule::where('user_id', $user->id)
                                                  ->where('status', 'completed')
                                                  ->count(),
                'cancelled_count' => WasteSchedule::where('user_id', $user->id)
                                                  ->where('status', 'cancelled')
                                                  ->count(),
                'by_status' => [
                    'pending' => WasteSchedule::where('user_id', $user->id)->where('status', 'pending')->count(),
                    'in_progress' => WasteSchedule::where('user_id', $user->id)->where('status', 'in_progress')->count(),
                    'completed' => WasteSchedule::where('user_id', $user->id)->where('status', 'completed')->count(),
                    'cancelled' => WasteSchedule::where('user_id', $user->id)->where('status', 'cancelled')->count(),
                ],
            ];
            
            return response()->json([
                'success' => true,
                'message' => 'Schedules retrieved successfully',
                'data' => [
                    'schedules' => $schedules->items(),
                    'pagination' => [
                        'current_page' => $schedules->currentPage(),
                        'per_page' => $schedules->perPage(),
                        'total' => $schedules->total(),
                        'last_page' => $schedules->lastPage(),
                        'from' => $schedules->firstItem(),
                        'to' => $schedules->lastItem(),
                    ],
                    'summary' => $summary,
                ],
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve schedules',
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    
    /**
     * Get schedule detail
     */
    public function show($id)
    {
        try {
            $user = Auth::user();
            
            $schedule = WasteSchedule::where('id', $id)
                                    ->where('user_id', $user->id)
                                    ->with('mitra:id,name,vehicle_type,vehicle_plate,phone')
                                    ->first();
            
            if (!$schedule) {
                return response()->json([
                    'success' => false,
                    'message' => 'Schedule not found',
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'message' => 'Schedule detail retrieved successfully',
                'data' => [
                    'schedule' => $schedule,
                ],
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve schedule detail',
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    
    /**
     * Create new schedule
     */
    public function store(Request $request)
    {
        try {
            $user = Auth::user();
            
            // Validation
            $validator = Validator::make($request->all(), [
                'service_type' => 'required|string|max:100',
                'waste_type' => 'required|in:Organik,Anorganik,B3,Elektronik',
                'pickup_address' => 'required|string',
                'pickup_latitude' => 'nullable|numeric',
                'pickup_longitude' => 'nullable|numeric',
                'scheduled_at' => 'required|date|after:now',
                'notes' => 'nullable|string',
                'estimated_weight' => 'nullable|numeric|min:0',
            ]);
            
            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }
            
            // Create schedule
            $schedule = WasteSchedule::create([
                'user_id' => $user->id,
                'service_type' => $request->service_type,
                'waste_type' => $request->waste_type,
                'pickup_address' => $request->pickup_address,
                'pickup_latitude' => $request->pickup_latitude,
                'pickup_longitude' => $request->pickup_longitude,
                'scheduled_at' => $request->scheduled_at,
                'notes' => $request->notes,
                'estimated_weight' => $request->estimated_weight,
                'status' => 'pending',
            ]);
            
            // TODO: Send notification to available mitra
            // TODO: Create notification for user
            
            return response()->json([
                'success' => true,
                'message' => 'Schedule created successfully',
                'data' => [
                    'schedule' => $schedule,
                ],
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create schedule',
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
    
    /**
     * Cancel schedule
     */
    public function cancel(Request $request, $id)
    {
        try {
            $user = Auth::user();
            
            $schedule = WasteSchedule::where('id', $id)
                                    ->where('user_id', $user->id)
                                    ->whereIn('status', ['pending', 'in_progress'])
                                    ->first();
            
            if (!$schedule) {
                return response()->json([
                    'success' => false,
                    'message' => 'Schedule not found or cannot be cancelled',
                ], 404);
            }
            
            $schedule->update([
                'status' => 'cancelled',
                'cancelled_at' => now(),
                'cancellation_reason' => $request->input('reason', 'Cancelled by user'),
            ]);
            
            // TODO: Send notification to mitra if assigned
            // TODO: Create notification for user
            
            return response()->json([
                'success' => true,
                'message' => 'Schedule cancelled successfully',
                'data' => [
                    'schedule' => $schedule,
                ],
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel schedule',
                'errors' => ['server' => [$e->getMessage()]],
            ], 500);
        }
    }
}
```

### Step 4: Add Routes

**File:** `routes/api.php`

```php
<?php

use App\Http\Controllers\Api\WasteScheduleController;

// Protected routes (require authentication)
Route::middleware(['auth:sanctum'])->group(function () {
    
    // ⚠️ PENTING: Gunakan prefix 'waste-schedules', BUKAN 'schedules'
    Route::prefix('waste-schedules')->group(function () {
        Route::get('/', [WasteScheduleController::class, 'index']);
        Route::get('/{id}', [WasteScheduleController::class, 'show']);
        Route::post('/', [WasteScheduleController::class, 'store']);
        Route::post('/{id}/cancel', [WasteScheduleController::class, 'cancel']);
    });
    
});
```

### Step 5: Run Migration

```bash
php artisan migrate
```

---

## 🧪 Testing dengan cURL

### 1. Get All Schedules

```bash
curl -X GET "http://127.0.0.1:8000/api/waste-schedules" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### 2. Get with Filters

```bash
# Filter by status
curl -X GET "http://127.0.0.1:8000/api/waste-schedules?status=pending" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Filter by date
curl -X GET "http://127.0.0.1:8000/api/waste-schedules?date=2025-11-12" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Multiple filters
curl -X GET "http://127.0.0.1:8000/api/waste-schedules?status=pending&waste_type=Organik&per_page=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### 3. Get Schedule Detail

```bash
curl -X GET "http://127.0.0.1:8000/api/waste-schedules/1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### 4. Create Schedule

```bash
curl -X POST "http://127.0.0.1:8000/api/waste-schedules" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "service_type": "Pengambilan Sampah Organik",
    "waste_type": "Organik",
    "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
    "pickup_latitude": -6.208763,
    "pickup_longitude": 106.845599,
    "scheduled_at": "2025-11-15 08:00:00",
    "notes": "Sampah sudah dipilah",
    "estimated_weight": 5.5
  }'
```

### 5. Cancel Schedule

```bash
curl -X POST "http://127.0.0.1:8000/api/waste-schedules/1/cancel" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "reason": "Ada perubahan rencana"
  }'
```

---

## 🎯 Test Data Generator

### Buat Test Data via Tinker

```bash
php artisan tinker
```

```php
// Get user ID (ganti dengan user ID yang valid)
$userId = 14;

// Create 6 sample schedules
$schedules = [
    [
        'user_id' => $userId,
        'service_type' => 'Pengambilan Sampah Organik',
        'waste_type' => 'Organik',
        'pickup_address' => 'Jl. Sudirman No. 123, Jakarta Pusat',
        'pickup_latitude' => -6.208763,
        'pickup_longitude' => 106.845599,
        'scheduled_at' => now()->addDays(2)->setTime(8, 0),
        'status' => 'pending',
        'notes' => 'Sampah organik dari rumah',
        'estimated_weight' => 5.5,
    ],
    [
        'user_id' => $userId,
        'service_type' => 'Pengambilan Sampah Anorganik',
        'waste_type' => 'Anorganik',
        'pickup_address' => 'Jl. Thamrin No. 45, Jakarta Pusat',
        'pickup_latitude' => -6.195143,
        'pickup_longitude' => 106.822786,
        'scheduled_at' => now()->addDays(3)->setTime(9, 0),
        'status' => 'pending',
        'notes' => 'Plastik dan kertas',
        'estimated_weight' => 3.2,
    ],
    [
        'user_id' => $userId,
        'mitra_id' => 5, // Ganti dengan mitra ID yang valid
        'service_type' => 'Pengambilan Sampah Organik',
        'waste_type' => 'Organik',
        'pickup_address' => 'Jl. Gatot Subroto No. 78, Jakarta Selatan',
        'pickup_latitude' => -6.225014,
        'pickup_longitude' => 106.808107,
        'scheduled_at' => now()->addHours(2),
        'status' => 'in_progress',
        'notes' => 'Mitra sedang dalam perjalanan',
        'estimated_weight' => 4.0,
        'accepted_at' => now()->subMinutes(30),
        'started_at' => now()->subMinutes(10),
    ],
    [
        'user_id' => $userId,
        'mitra_id' => 3,
        'service_type' => 'Pengambilan Sampah B3',
        'waste_type' => 'B3',
        'pickup_address' => 'Jl. Kuningan No. 12, Jakarta Selatan',
        'pickup_latitude' => -6.229728,
        'pickup_longitude' => 106.831154,
        'scheduled_at' => now()->subDays(1),
        'status' => 'completed',
        'notes' => 'Baterai bekas',
        'estimated_weight' => 1.5,
        'actual_weight' => 1.3,
        'accepted_at' => now()->subDays(1)->subHours(2),
        'started_at' => now()->subDays(1)->subHours(1),
        'completed_at' => now()->subDays(1),
    ],
    [
        'user_id' => $userId,
        'mitra_id' => 4,
        'service_type' => 'Pengambilan Sampah Elektronik',
        'waste_type' => 'Elektronik',
        'pickup_address' => 'Jl. Senopati No. 88, Jakarta Selatan',
        'pickup_latitude' => -6.233985,
        'pickup_longitude' => 106.804260,
        'scheduled_at' => now()->subDays(5),
        'status' => 'completed',
        'notes' => 'Laptop rusak',
        'estimated_weight' => 2.0,
        'actual_weight' => 2.1,
        'accepted_at' => now()->subDays(5)->subHours(3),
        'started_at' => now()->subDays(5)->subHours(2),
        'completed_at' => now()->subDays(5)->subHours(1),
    ],
    [
        'user_id' => $userId,
        'service_type' => 'Pengambilan Sampah Anorganik',
        'waste_type' => 'Anorganik',
        'pickup_address' => 'Jl. Rasuna Said No. 5, Jakarta Selatan',
        'pickup_latitude' => -6.224448,
        'pickup_longitude' => 106.830635,
        'scheduled_at' => now()->subDays(2),
        'status' => 'cancelled',
        'notes' => 'Jadwal berubah',
        'estimated_weight' => 3.0,
        'cancelled_at' => now()->subDays(2)->addHours(1),
        'cancellation_reason' => 'User membatalkan karena tidak ada di rumah',
    ],
];

foreach ($schedules as $schedule) {
    \App\Models\WasteSchedule::create($schedule);
}

echo "✅ 6 test schedules created successfully!\n";
```

---

## ✅ Testing Checklist

### Backend Testing:
- [ ] Migration berjalan sukses
- [ ] Test data berhasil dibuat via tinker
- [ ] GET /api/waste-schedules returns 200
- [ ] Response format sesuai dokumentasi
- [ ] Pagination berfungsi
- [ ] Filter status berfungsi
- [ ] Filter date berfungsi
- [ ] Filter waste_type berfungsi
- [ ] Summary statistics akurat
- [ ] GET /api/waste-schedules/{id} berfungsi
- [ ] POST /api/waste-schedules creates schedule
- [ ] Validation errors return 422
- [ ] POST /api/waste-schedules/{id}/cancel berfungsi
- [ ] Cannot cancel completed/cancelled schedules

### Flutter Testing (Setelah backend ready):
- [ ] App tidak crash saat buka Activity page
- [ ] Data muncul di tab "Aktif"
- [ ] Data muncul di tab "Riwayat"
- [ ] Date filter berfungsi
- [ ] Category filter berfungsi
- [ ] Pull to refresh berfungsi
- [ ] Status badge warna sesuai
- [ ] Loading skeleton muncul saat load
- [ ] Empty state hilang setelah ada data

---

## 📊 Status Flow

```
pending → in_progress → completed
   ↓
cancelled
```

**Status Definitions:**
- `pending`: Jadwal baru dibuat, menunggu mitra
- `in_progress`: Mitra sedang dalam perjalanan
- `completed`: Pengambilan selesai
- `cancelled`: Jadwal dibatalkan

---

## ⚠️ Important Notes

1. **Endpoint URL:** Gunakan `/api/waste-schedules` (BUKAN `/api/schedules`)
2. **Authentication:** Semua endpoint butuh Bearer token
3. **User Scoping:** User hanya bisa lihat jadwal sendiri
4. **Timezone:** Asia/Jakarta untuk semua datetime
5. **Pagination:** Default 20, max 100 items per page
6. **Soft Delete:** Gunakan `deleted_at` column
7. **Status Validation:** Hanya `pending` dan `in_progress` bisa dibatalkan

---

## 🎯 Priority Tasks

1. **URGENT:** Buat endpoint `/api/waste-schedules` (Flutter sudah ready!)
2. **HIGH:** Buat test data minimal 6 schedules
3. **HIGH:** Test semua endpoint dengan cURL
4. **MEDIUM:** Koordinasi dengan Flutter team untuk integration testing
5. **LOW:** Implement notification integration (optional)

---

## 📞 Contact & Support

**Jika ada pertanyaan:**
- Check dokumentasi lengkap: `BACKEND_API_ACTIVITY_SCHEDULES.md`
- Check testing guide: `TESTING_ACTIVITY_API.md`
- Check implementation status: `ACTIVITY_API_STATUS.md`

**Setelah implementation selesai:**
1. Konfirmasi endpoint URL sudah live
2. Share test token untuk Flutter team
3. Test dengan curl dulu sebelum notify Flutter team
4. Koordinasi untuk integration testing bersama

---

**Status:** 🔴 **URGENT - Waiting for Backend Implementation**  
**Flutter Status:** ✅ **READY - Waiting for API**  
**ETA:** Tergantung backend team availability

---

*Dokumentasi dibuat: 12 November 2025*  
*Last Updated: 12 November 2025 - Setelah discovery endpoint `/waste-schedules`*
