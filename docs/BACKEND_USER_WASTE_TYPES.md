# Backend Documentation: User Waste Types (Sampah yang Di-input User)

## 📋 Problem Statement

**Current Flow:**
```
User → Jadwalkan "Campuran" (daily)
User → Tambahkan sampah "Organik" saat buat jadwal
Backend → Hanya simpan waste_type_scheduled = "Campuran"
Mitra → Lihat form → Hanya muncul "Campuran"
Mitra → Harus manual tambah "Organik"
```

**Desired Flow:**
```
User → Jadwalkan "Campuran" (daily)
User → Tambahkan sampah "Organik" (additional)
Backend → Simpan:
  - waste_type_scheduled = "Campuran" (daily)
  - user_waste_types = "Campuran,Organik" (all types user input)
Mitra → Lihat form → Otomatis muncul "Campuran" + "Organik"
```

## 🎯 Solution

### 1. Add New Database Field

#### Migration: `add_user_waste_types_to_pickup_schedules`

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
            // Field untuk menyimpan semua jenis sampah yang user input
            // Format: comma-separated string atau JSON array
            $table->text('user_waste_types')->nullable()->after('waste_type_scheduled');
            
            // Optional: Field untuk estimated weights per type
            $table->json('estimated_weights')->nullable()->after('user_waste_types');
            
            // Index untuk performance
            $table->index('user_waste_types');
        });
    }

    public function down(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            $table->dropIndex(['user_waste_types']);
            $table->dropColumn(['user_waste_types', 'estimated_weights']);
        });
    }
};
```

### 2. Update Model

#### File: `app/Models/PickupSchedule.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PickupSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'pickup_address',
        'latitude',
        'longitude',
        'schedule_day',
        'waste_type_scheduled',      // Daily schedule type
        'user_waste_types',           // NEW: All types user inputted
        'estimated_weights',          // NEW: Estimated weights per type
        'scheduled_pickup_at',
        'pickup_time_start',
        'pickup_time_end',
        'waste_summary',
        'notes',
        'status',
        'assigned_mitra_id',
        'assigned_at',
        'completed_at',
        'actual_weights',
        'total_weight',
        'pickup_photos',
    ];

    protected $casts = [
        'scheduled_pickup_at' => 'datetime',
        'assigned_at' => 'datetime',
        'completed_at' => 'datetime',
        'estimated_weights' => 'array',  // Cast to array
        'actual_weights' => 'array',
        'pickup_photos' => 'array',
    ];

    /**
     * Get user waste types as array
     */
    public function getUserWasteTypesAttribute($value)
    {
        if (empty($value)) {
            return [];
        }
        
        // If already JSON array
        if (is_array(json_decode($value))) {
            return json_decode($value);
        }
        
        // If comma-separated string
        return array_map('trim', explode(',', $value));
    }

    /**
     * Set user waste types from array
     */
    public function setUserWasteTypesAttribute($value)
    {
        if (is_array($value)) {
            $this->attributes['user_waste_types'] = implode(',', $value);
        } else {
            $this->attributes['user_waste_types'] = $value;
        }
    }
}
```

### 3. Update Controller - Create Schedule

#### File: `app/Http/Controllers/Api/ScheduleController.php`

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    /**
     * Create new pickup schedule
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'pickup_address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'schedule_day' => 'required|string',
            'waste_type_scheduled' => 'required|string', // Daily type: "Campuran"
            'user_waste_types' => 'nullable|string',     // NEW: All types: "Campuran,Organik,Plastik"
            'estimated_weights' => 'nullable|array',     // NEW: {"Campuran": 5, "Organik": 2}
            'scheduled_pickup_at' => 'required|date',
            'pickup_time_start' => 'required',
            'pickup_time_end' => 'required',
            'notes' => 'nullable|string',
        ]);

        $schedule = PickupSchedule::create([
            'user_id' => auth()->id(),
            'pickup_address' => $validated['pickup_address'],
            'latitude' => $validated['latitude'] ?? 0,
            'longitude' => $validated['longitude'] ?? 0,
            'schedule_day' => $validated['schedule_day'],
            'waste_type_scheduled' => $validated['waste_type_scheduled'],
            
            // NEW: Save user's actual waste types
            'user_waste_types' => $validated['user_waste_types'] ?? $validated['waste_type_scheduled'],
            'estimated_weights' => $validated['estimated_weights'] ?? null,
            
            'scheduled_pickup_at' => $validated['scheduled_pickup_at'],
            'pickup_time_start' => $validated['pickup_time_start'],
            'pickup_time_end' => $validated['pickup_time_end'],
            'waste_summary' => $this->generateWasteSummary($validated),
            'notes' => $validated['notes'] ?? null,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Schedule created successfully',
            'data' => ['schedule' => $schedule],
        ], 201);
    }

    /**
     * Generate waste summary
     */
    private function generateWasteSummary(array $data): string
    {
        $types = $data['user_waste_types'] ?? $data['waste_type_scheduled'];
        return "Sampah: {$types}";
    }
}
```

### 4. Update Response - Get Schedule

#### File: `app/Http/Controllers/Api/Mitra/PickupScheduleController.php`

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;

class PickupScheduleController extends Controller
{
    /**
     * Get available schedules for mitra
     */
    public function getAvailableSchedules(Request $request)
    {
        $schedules = PickupSchedule::with(['user'])
            ->where('status', 'pending')
            ->whereNull('assigned_mitra_id')
            ->orderBy('scheduled_pickup_at')
            ->paginate($request->get('per_page', 20));

        // Transform data
        $schedules->getCollection()->transform(function ($schedule) {
            return [
                'id' => $schedule->id,
                'user_id' => $schedule->user_id,
                'user_name' => $schedule->user->name,
                'user_phone' => $schedule->user->phone,
                'pickup_address' => $schedule->pickup_address,
                'latitude' => (float) $schedule->latitude,
                'longitude' => (float) $schedule->longitude,
                'schedule_day' => $schedule->schedule_day,
                'waste_type_scheduled' => $schedule->waste_type_scheduled,
                
                // NEW: Include user's actual waste types
                'user_waste_types' => $schedule->user_waste_types, // Returns array or comma-separated
                'estimated_weights' => $schedule->estimated_weights,
                
                'scheduled_pickup_at' => $schedule->scheduled_pickup_at->toISOString(),
                'pickup_time_start' => $schedule->pickup_time_start,
                'pickup_time_end' => $schedule->pickup_time_end,
                'waste_summary' => $schedule->waste_summary,
                'notes' => $schedule->notes,
                'status' => $schedule->status,
                'created_at' => $schedule->created_at->toISOString(),
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Available schedules retrieved successfully',
            'data' => [
                'schedules' => $schedules->items(),
                'pagination' => [
                    'current_page' => $schedules->currentPage(),
                    'per_page' => $schedules->perPage(),
                    'total' => $schedules->total(),
                    'last_page' => $schedules->lastPage(),
                ],
            ],
        ]);
    }

    /**
     * Get my active schedules
     */
    public function getMyActiveSchedules()
    {
        $mitraId = auth()->id();
        
        $schedules = PickupSchedule::with(['user'])
            ->where('assigned_mitra_id', $mitraId)
            ->where('status', 'on_progress')
            ->orderBy('scheduled_pickup_at')
            ->get();

        $schedules = $schedules->map(function ($schedule) {
            return [
                'id' => $schedule->id,
                'user_id' => $schedule->user_id,
                'user_name' => $schedule->user->name,
                'user_phone' => $schedule->user->phone,
                'pickup_address' => $schedule->pickup_address,
                'latitude' => (float) $schedule->latitude,
                'longitude' => (float) $schedule->longitude,
                'schedule_day' => $schedule->schedule_day,
                'waste_type_scheduled' => $schedule->waste_type_scheduled,
                
                // NEW: Include user's actual waste types
                'user_waste_types' => $schedule->user_waste_types,
                'estimated_weights' => $schedule->estimated_weights,
                
                'scheduled_pickup_at' => $schedule->scheduled_pickup_at->toISOString(),
                'pickup_time_start' => $schedule->pickup_time_start,
                'pickup_time_end' => $schedule->pickup_time_end,
                'waste_summary' => $schedule->waste_summary,
                'notes' => $schedule->notes,
                'status' => $schedule->status,
                'assigned_at' => $schedule->assigned_at?->toISOString(),
                'created_at' => $schedule->created_at->toISOString(),
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Active schedules retrieved successfully',
            'data' => ['schedules' => $schedules],
        ]);
    }
}
```

## 📊 API Response Examples

### Before (Current)
```json
{
  "id": 57,
  "waste_type_scheduled": "Campuran",
  "waste_summary": "Campuran"
}
```

### After (With New Fields)
```json
{
  "id": 57,
  "waste_type_scheduled": "Campuran",
  "user_waste_types": "Campuran,Organik,Plastik",
  "estimated_weights": {
    "Campuran": 5.0,
    "Organik": 2.5,
    "Plastik": 1.0
  },
  "waste_summary": "Campuran, Organik, Plastik"
}
```

## 🔄 Data Flow

### User Creates Schedule (Frontend → Backend)

**Request:**
```http
POST /api/schedules
Content-Type: application/json
Authorization: Bearer {token}

{
  "pickup_address": "Jl. Sudirman No. 123",
  "schedule_day": "senin",
  "waste_type_scheduled": "Campuran",
  "user_waste_types": "Campuran,Organik,Plastik",
  "estimated_weights": {
    "Campuran": 5.0,
    "Organik": 2.5,
    "Plastik": 1.0
  },
  "scheduled_pickup_at": "2025-11-14 06:00:00",
  "pickup_time_start": "06:00:00",
  "pickup_time_end": "08:00:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Schedule created successfully",
  "data": {
    "schedule": {
      "id": 57,
      "user_id": 15,
      "waste_type_scheduled": "Campuran",
      "user_waste_types": "Campuran,Organik,Plastik",
      "estimated_weights": {
        "Campuran": 5.0,
        "Organik": 2.5,
        "Plastik": 1.0
      },
      "status": "pending"
    }
  }
}
```

### Mitra Gets Schedule (Backend → Frontend)

**Request:**
```http
GET /api/mitra/pickup-schedules/my-active
Authorization: Bearer {mitra_token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 57,
        "user_name": "Ali",
        "waste_type_scheduled": "Campuran",
        "user_waste_types": "Campuran,Organik,Plastik",
        "estimated_weights": {
          "Campuran": 5.0,
          "Organik": 2.5,
          "Plastik": 1.0
        }
      }
    ]
  }
}
```

## 🎨 Frontend Integration

### Update Model

**File:** `lib/models/mitra_pickup_schedule.dart`

```dart
class MitraPickupSchedule {
  final int id;
  final String wasteTypeScheduled;    // Daily: "Campuran"
  final String? userWasteTypes;       // NEW: All types: "Campuran,Organik,Plastik"
  final Map<String, dynamic>? estimatedWeights; // NEW: Estimated weights

  MitraPickupSchedule({
    required this.id,
    required this.wasteTypeScheduled,
    this.userWasteTypes,
    this.estimatedWeights,
    // ... other fields
  });

  factory MitraPickupSchedule.fromJson(Map<String, dynamic> json) {
    return MitraPickupSchedule(
      id: json['id'] ?? 0,
      wasteTypeScheduled: json['waste_type_scheduled'] ?? '',
      userWasteTypes: json['user_waste_types'],
      estimatedWeights: json['estimated_weights'] != null 
          ? Map<String, dynamic>.from(json['estimated_weights'])
          : null,
      // ... other fields
    );
  }
}
```

### Update Complete Pickup Page

**File:** `lib/ui/pages/mitra/complete_pickup_page.dart`

```dart
List<String> _getScheduledWasteTypes() {
  // Priority 1: Use user_waste_types if available
  if (widget.schedule.userWasteTypes != null && 
      widget.schedule.userWasteTypes!.isNotEmpty) {
    
    print('📦 User waste types: ${widget.schedule.userWasteTypes}');
    
    // Parse comma-separated or JSON array
    if (widget.schedule.userWasteTypes!.contains(',')) {
      final types = widget.schedule.userWasteTypes!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      print('✅ Parsed ${types.length} user types: $types');
      return types;
    }
    
    return [widget.schedule.userWasteTypes!];
  }
  
  // Priority 2: Fallback to waste_type_scheduled
  final scheduled = widget.schedule.wasteTypeScheduled.trim();
  print('⚠️  Using fallback waste_type_scheduled: $scheduled');
  
  if (scheduled.isEmpty) {
    return ['Organik', 'Anorganik', 'Kertas', 'Plastik', 'Logam', 'Kaca'];
  }
  
  if (scheduled.contains(',')) {
    return scheduled.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  
  return [scheduled];
}
```

## 📋 Testing Guide

### Test Case 1: User Input Multiple Waste Types

**User Action:**
1. User Ali buat jadwal
2. Pilih daily: "Campuran"
3. Tambahkan: "Organik", "Plastik"

**Backend Should Save:**
```sql
INSERT INTO pickup_schedules (
  user_id, 
  waste_type_scheduled, 
  user_waste_types,
  estimated_weights
) VALUES (
  15,
  'Campuran',
  'Campuran,Organik,Plastik',
  '{"Campuran":5,"Organik":2.5,"Plastik":1}'
);
```

**Mitra Should See:**
- Chip 1: "Campuran" (hijau)
- Chip 2: "Organik" (hijau)
- Chip 3: "Plastik" (hijau)
- Form fields: 3 (Campuran, Organik, Plastik)
- NO manual add needed!

### Test Case 2: User Input Only Daily

**User Action:**
1. User Ali buat jadwal
2. Pilih daily: "Campuran"
3. Tidak tambah apa-apa

**Backend Should Save:**
```sql
INSERT INTO pickup_schedules (
  user_id, 
  waste_type_scheduled, 
  user_waste_types
) VALUES (
  15,
  'Campuran',
  'Campuran'  -- Same as waste_type_scheduled
);
```

**Mitra Should See:**
- Chip 1: "Campuran" (hijau)
- Form fields: 1 (Campuran)

### Test Case 3: Backward Compatibility

**Old Data (No user_waste_types):**
```json
{
  "id": 50,
  "waste_type_scheduled": "Campuran",
  "user_waste_types": null
}
```

**Frontend Behavior:**
- Fallback to `waste_type_scheduled`
- Show "Campuran"
- Everything works as before

## 🔧 Database Commands

### Run Migration
```bash
php artisan make:migration add_user_waste_types_to_pickup_schedules
php artisan migrate
```

### Seed Test Data
```php
// database/seeders/PickupScheduleSeeder.php
PickupSchedule::create([
    'user_id' => 15,
    'waste_type_scheduled' => 'Campuran',
    'user_waste_types' => 'Campuran,Organik,Plastik',
    'estimated_weights' => [
        'Campuran' => 5.0,
        'Organik' => 2.5,
        'Plastik' => 1.0,
    ],
    'status' => 'pending',
    // ... other fields
]);
```

### Verify Data
```sql
SELECT 
  id,
  user_id,
  waste_type_scheduled,
  user_waste_types,
  estimated_weights
FROM pickup_schedules
WHERE user_id = 15;
```

## 📊 Example Scenarios

### Scenario A: Ali with Mixed Waste
```
User: Ali
Daily: Campuran
Additional: Organik, Plastik

Database:
  waste_type_scheduled = "Campuran"
  user_waste_types = "Campuran,Organik,Plastik"
  estimated_weights = {"Campuran": 5, "Organik": 2, "Plastik": 1}

Mitra Form:
  [Campuran] [Organik] [Plastik] (all green, all scheduled)
  3 form fields
```

### Scenario B: Budi with Organic Only
```
User: Budi
Daily: Organik
Additional: (none)

Database:
  waste_type_scheduled = "Organik"
  user_waste_types = "Organik"
  estimated_weights = {"Organik": 3}

Mitra Form:
  [Organik] (green)
  1 form field
```

### Scenario C: Citra with All Types
```
User: Citra
Daily: Campuran
Additional: Organik, Anorganik, Kertas, Plastik, Logam

Database:
  waste_type_scheduled = "Campuran"
  user_waste_types = "Campuran,Organik,Anorganik,Kertas,Plastik,Logam"
  estimated_weights = {...}

Mitra Form:
  [Campuran] [Organik] [Anorganik] [Kertas] [Plastik] [Logam]
  6 form fields (all green)
  Button "Tambah" HIDDEN (semua sudah ada)
```

## ✅ Validation Rules

### Backend Validation

```php
$request->validate([
    'waste_type_scheduled' => 'required|string|max:100',
    'user_waste_types' => 'nullable|string|max:500',
    'estimated_weights' => 'nullable|array',
    'estimated_weights.*.weight' => 'nullable|numeric|min:0',
]);
```

### Frontend Validation

```dart
// Ensure user_waste_types is not empty
if (userWasteTypes == null || userWasteTypes.isEmpty) {
  // Fallback to waste_type_scheduled
  userWasteTypes = wasteTypeScheduled;
}

// Parse and validate
final types = parseWasteTypes(userWasteTypes);
if (types.isEmpty) {
  // Error: No waste types found
}
```

## 🚀 Benefits

### For Users
✅ Input semua jenis sampah saat buat jadwal
✅ Estimated weights disimpan
✅ Tidak perlu komunikasi tambahan dengan mitra

### For Mitra
✅ Otomatis lihat semua jenis yang user input
✅ Tidak perlu manual tambah jenis
✅ Lebih cepat complete pickup
✅ Form langsung ready

### For Business
✅ Data lebih akurat
✅ Mengurangi error
✅ Better analytics
✅ Improved efficiency

## 📝 Implementation Checklist

### Backend Tasks
- [ ] Create migration `add_user_waste_types_to_pickup_schedules`
- [ ] Add `user_waste_types` field (text, nullable)
- [ ] Add `estimated_weights` field (json, nullable)
- [ ] Update `PickupSchedule` model
- [ ] Add accessor/mutator for `user_waste_types`
- [ ] Update `ScheduleController@store`
- [ ] Update `PickupScheduleController@getAvailableSchedules`
- [ ] Update `PickupScheduleController@getMyActiveSchedules`
- [ ] Add validation rules
- [ ] Test API endpoints
- [ ] Update API documentation

### Frontend Tasks
- [ ] Update `MitraPickupSchedule` model
- [ ] Add `userWasteTypes` field
- [ ] Add `estimatedWeights` field
- [ ] Update `fromJson` parsing
- [ ] Update `_getScheduledWasteTypes()` logic
- [ ] Test with real data
- [ ] Test backward compatibility
- [ ] Update documentation

### Testing Tasks
- [ ] Test create schedule with multiple types
- [ ] Test mitra sees all types automatically
- [ ] Test backward compatibility (old data)
- [ ] Test with comma-separated values
- [ ] Test with JSON array values
- [ ] Test empty/null values
- [ ] Test estimated weights display

## 🔄 Migration Strategy

### Phase 1: Add Fields (Backward Compatible)
```php
// Fields are nullable - old data still works
Schema::table('pickup_schedules', function (Blueprint $table) {
    $table->text('user_waste_types')->nullable();
    $table->json('estimated_weights')->nullable();
});
```

### Phase 2: Populate Existing Data (Optional)
```php
// Copy waste_type_scheduled to user_waste_types for old records
PickupSchedule::whereNull('user_waste_types')
    ->update(['user_waste_types' => DB::raw('waste_type_scheduled')]);
```

### Phase 3: Frontend Update
- Update model to read new fields
- Fallback to old field if new field is null
- Test thoroughly

### Phase 4: Full Adoption
- All new schedules use new fields
- Old data gradually updated
- Monitor and fix issues

## 📞 Support & Questions

### Common Questions

**Q: Apakah harus migrasi data lama?**
A: Tidak wajib. Frontend bisa fallback ke `waste_type_scheduled` jika `user_waste_types` null.

**Q: Format apa yang lebih baik: comma-separated atau JSON array?**
A: Comma-separated lebih simple untuk display, JSON array lebih structured. Rekomendasi: comma-separated string untuk compatibility.

**Q: Bagaimana handle user input lebih dari 6 jenis?**
A: Sistem support unlimited types. Frontend bisa show all atau limit display.

**Q: Perlu update existing schedules?**
A: Tidak perlu. New schedules akan pakai new fields, old schedules tetap work dengan fallback.

---

**Ready to Implement! 🚀**

Send this documentation to Laravel backend team. Frontend sudah siap menerima data baru.
