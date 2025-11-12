# 📅 Backend API: Activity & Schedule Management

> **Untuk Backend Developer**  
> **Task:** Menyediakan API untuk menampilkan history dan aktivitas jadwal pengambilan sampah user

---

## 📋 Endpoint yang Dibutuhkan

### 1. Get User Schedules (History & Active)

**Endpoint:** `GET /api/schedules`

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
```

**Query Parameters (Optional):**
```
?status=pending        // Filter by status
?date=2025-11-12      // Filter by date (YYYY-MM-DD)
?per_page=20          // Items per page (default: 20)
?page=1               // Page number (default: 1)
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
        "service_type": "Pengambilan Sampah Organik",
        "waste_type": "Organik",
        "pickup_address": "Jl. Sudirman No. 123, Jakarta Pusat",
        "scheduled_at": "2025-11-12 08:00:00",
        "status": "pending",
        "notes": "Sampah sudah dipilah. Mohon diambil tepat waktu.",
        "created_at": "2025-11-10 14:30:00",
        "updated_at": "2025-11-10 14:30:00",
        "mitra": {
          "id": 5,
          "name": "John Doe",
          "vehicle_type": "Truk",
          "vehicle_plate": "B 1234 XYZ",
          "phone": "081234567890"
        }
      },
      {
        "id": 2,
        "user_id": 14,
        "service_type": "Pengambilan Sampah Anorganik",
        "waste_type": "Anorganik",
        "pickup_address": "Jl. Thamrin No. 45, Jakarta Pusat",
        "scheduled_at": "2025-11-11 09:00:00",
        "status": "completed",
        "notes": "Terima kasih sudah membantu!",
        "completed_at": "2025-11-11 09:45:00",
        "created_at": "2025-11-09 10:00:00",
        "updated_at": "2025-11-11 09:45:00",
        "mitra": {
          "id": 3,
          "name": "Jane Smith",
          "vehicle_type": "Motor",
          "vehicle_plate": "B 5678 ABC",
          "phone": "081298765432"
        }
      },
      {
        "id": 3,
        "user_id": 14,
        "service_type": "Pengambilan Sampah B3",
        "waste_type": "B3",
        "pickup_address": "Jl. Gatot Subroto No. 78, Jakarta Selatan",
        "scheduled_at": "2025-11-10 07:30:00",
        "status": "cancelled",
        "notes": "Dibatalkan karena mitra tidak tersedia",
        "cancelled_at": "2025-11-10 06:00:00",
        "cancellation_reason": "Mitra sakit mendadak",
        "created_at": "2025-11-08 16:00:00",
        "updated_at": "2025-11-10 06:00:00"
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

**Response Error (401):**
```json
{
  "success": false,
  "message": "Unauthorized. Please login again.",
  "errors": {
    "auth": ["Token is invalid or expired"]
  }
}
```

---

## 🗄️ Database Schema

### Tabel: `waste_schedules`

```sql
CREATE TABLE waste_schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    mitra_id BIGINT UNSIGNED NULL,
    service_type VARCHAR(100) NOT NULL,
    waste_type ENUM('Organik', 'Anorganik', 'B3', 'Elektronik') NOT NULL,
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8) NULL,
    pickup_longitude DECIMAL(11, 8) NULL,
    scheduled_at DATETIME NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    notes TEXT NULL,
    
    -- Timestamps untuk tracking
    accepted_at DATETIME NULL,
    started_at DATETIME NULL,
    completed_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    cancellation_reason TEXT NULL,
    
    -- Metadata
    estimated_weight DECIMAL(8, 2) NULL COMMENT 'in kg',
    actual_weight DECIMAL(8, 2) NULL COMMENT 'in kg',
    photo_proof VARCHAR(255) NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mitra_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_user_id (user_id),
    INDEX idx_mitra_id (mitra_id),
    INDEX idx_status (status),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 💻 Backend Implementation (Laravel)

### Controller: `ScheduleController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WasteSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ScheduleController extends Controller
{
    /**
     * Get user schedules with filtering
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
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
            
            // Filter by date
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
     * 
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        try {
            $user = Auth::user();
            
            $schedule = WasteSchedule::where('id', $id)
                                    ->where('user_id', $user->id)
                                    ->with('mitra:id,name,vehicle_type,vehicle_plate,phone,rating')
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
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
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
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
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

---

## 🛣️ Routes Configuration

**File:** `routes/api.php`

```php
<?php

use App\Http\Controllers\Api\ScheduleController;

// Protected routes (require authentication)
Route::middleware(['auth:sanctum'])->group(function () {
    
    // Schedule Management
    Route::prefix('schedules')->group(function () {
        Route::get('/', [ScheduleController::class, 'index']);           // Get all schedules
        Route::get('/{id}', [ScheduleController::class, 'show']);        // Get schedule detail
        Route::post('/', [ScheduleController::class, 'store']);          // Create new schedule
        Route::post('/{id}/cancel', [ScheduleController::class, 'cancel']); // Cancel schedule
    });
    
});
```

---

## 🧪 Testing

### 1. Get User Schedules

```bash
# Get all schedules
curl -X GET "http://127.0.0.1:8000/api/schedules" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Get schedules with filter
curl -X GET "http://127.0.0.1:8000/api/schedules?status=pending&per_page=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Get schedules by date
curl -X GET "http://127.0.0.1:8000/api/schedules?date=2025-11-12" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### 2. Create Schedule

```bash
curl -X POST "http://127.0.0.1:8000/api/schedules" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "service_type": "Pengambilan Sampah Organik",
    "waste_type": "Organik",
    "pickup_address": "Jl. Sudirman No. 123, Jakarta",
    "pickup_latitude": -6.208763,
    "pickup_longitude": 106.845599,
    "scheduled_at": "2025-11-15 08:00:00",
    "notes": "Sampah sudah dipilah",
    "estimated_weight": 5.5
  }'
```

### 3. Get Schedule Detail

```bash
curl -X GET "http://127.0.0.1:8000/api/schedules/1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### 4. Cancel Schedule

```bash
curl -X POST "http://127.0.0.1:8000/api/schedules/1/cancel" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "reason": "Ada perubahan rencana"
  }'
```

---

## 📊 Status Flow

```
pending → in_progress → completed
   ↓
cancelled
```

**Status Definitions:**
- `pending`: Jadwal baru dibuat, menunggu mitra menerima
- `in_progress`: Mitra sedang dalam perjalanan/mengambil sampah
- `completed`: Pengambilan sampah selesai
- `cancelled`: Jadwal dibatalkan (oleh user atau mitra)

---

## 🔍 Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `service_type` | string | Yes | Nama layanan (e.g., "Pengambilan Sampah Organik") |
| `waste_type` | enum | Yes | Jenis sampah: Organik, Anorganik, B3, Elektronik |
| `pickup_address` | text | Yes | Alamat lengkap pickup |
| `pickup_latitude` | decimal | No | Koordinat latitude |
| `pickup_longitude` | decimal | No | Koordinat longitude |
| `scheduled_at` | datetime | Yes | Waktu jadwal (format: YYYY-MM-DD HH:MM:SS) |
| `status` | enum | Auto | Status: pending, in_progress, completed, cancelled |
| `notes` | text | No | Catatan tambahan dari user |
| `estimated_weight` | decimal | No | Estimasi berat sampah (kg) |
| `mitra_id` | bigint | Auto | ID mitra yang mengambil (assigned otomatis) |

---

## ⚠️ Important Notes

1. **Authentication Required:** Semua endpoint memerlukan Bearer token
2. **User Scoping:** User hanya bisa melihat jadwal miliknya sendiri
3. **Timezone:** Gunakan timezone Asia/Jakarta untuk semua datetime
4. **Pagination:** Default 20 items per page, max 100
5. **Soft Delete:** Gunakan `deleted_at` untuk soft delete
6. **Status Validation:** Hanya jadwal dengan status `pending` atau `in_progress` yang bisa dibatalkan

---

## ✅ Checklist Implementation

- [ ] Create `waste_schedules` table migration
- [ ] Create `WasteSchedule` model with relationships
- [ ] Implement `ScheduleController` with all methods
- [ ] Add routes to `api.php`
- [ ] Add validation rules
- [ ] Test all endpoints manually
- [ ] Setup pagination
- [ ] Add error handling
- [ ] Test with real data from Flutter app
- [ ] Setup auto-assignment to mitra (optional)
- [ ] Create notification integration (optional)

---

## 🔗 Related Documentation

- **Notification API:** See `BACKEND_CRON_SETUP.md` for notification integration
- **Authentication:** Laravel Sanctum with Bearer token
- **Database:** MySQL/MariaDB with InnoDB engine

---

**Setelah implementasi selesai, activity page Flutter akan otomatis menampilkan semua jadwal user dengan filter yang lengkap!** 🚀
