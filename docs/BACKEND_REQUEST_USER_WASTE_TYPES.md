# REQUEST: Add User Waste Types Field

## 📋 Problem

User Ali input sampah: **Campuran + Organik**  
Backend hanya simpan: `waste_type_scheduled = "Campuran"`  
Mitra lihat form: Hanya "Campuran", harus manual tambah "Organik" ❌

## ✅ Solution

Backend perlu simpan **semua jenis sampah yang user input** ke field baru: `user_waste_types`

## 🔧 Implementation

### 1. Migration

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
            $table->text('user_waste_types')->nullable()->after('waste_type_scheduled');
            $table->json('estimated_weights')->nullable()->after('user_waste_types');
        });
    }

    public function down(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            $table->dropColumn(['user_waste_types', 'estimated_weights']);
        });
    }
};
```

### 2. Model Update

```php
// app/Models/PickupSchedule.php

protected $fillable = [
    // ... existing fields
    'user_waste_types',    // NEW
    'estimated_weights',   // NEW
];

protected $casts = [
    // ... existing casts
    'estimated_weights' => 'array',
];
```

### 3. Controller - Save Data

```php
// app/Http/Controllers/Api/ScheduleController.php

public function store(Request $request)
{
    $validated = $request->validate([
        'waste_type_scheduled' => 'required|string',
        'user_waste_types' => 'nullable|string',     // NEW
        'estimated_weights' => 'nullable|array',     // NEW
        // ... other validations
    ]);

    $schedule = PickupSchedule::create([
        'user_id' => auth()->id(),
        'waste_type_scheduled' => $validated['waste_type_scheduled'],
        'user_waste_types' => $validated['user_waste_types'] ?? $validated['waste_type_scheduled'], // NEW
        'estimated_weights' => $validated['estimated_weights'] ?? null, // NEW
        // ... other fields
        'status' => 'pending',
    ]);

    return response()->json([
        'success' => true,
        'data' => ['schedule' => $schedule],
    ]);
}
```

### 4. Controller - Return Data

```php
// app/Http/Controllers/Api/Mitra/PickupScheduleController.php

public function getAvailableSchedules()
{
    $schedules = PickupSchedule::where('status', 'pending')
        ->orderBy('scheduled_pickup_at')
        ->get()
        ->map(function ($schedule) {
            return [
                'id' => $schedule->id,
                'waste_type_scheduled' => $schedule->waste_type_scheduled,
                'user_waste_types' => $schedule->user_waste_types,           // NEW
                'estimated_weights' => $schedule->estimated_weights,         // NEW
                // ... other fields
            ];
        });

    return response()->json([
        'success' => true,
        'data' => ['schedules' => $schedules],
    ]);
}
```

## 📊 Example Data

### User Creates Schedule

**Request:**
```json
POST /api/schedules
{
  "waste_type_scheduled": "Campuran",
  "user_waste_types": "Campuran,Organik,Plastik",
  "estimated_weights": {
    "Campuran": 5.0,
    "Organik": 2.5,
    "Plastik": 1.0
  }
}
```

**Database:**
```sql
INSERT INTO pickup_schedules (
  waste_type_scheduled,
  user_waste_types,
  estimated_weights
) VALUES (
  'Campuran',
  'Campuran,Organik,Plastik',
  '{"Campuran":5,"Organik":2.5,"Plastik":1}'
);
```

### Mitra Gets Schedule

**Response:**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 57,
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

## ✅ Result

**Before:**
- Mitra sees: [Campuran]
- Mitra must manually add: Organik, Plastik ❌

**After:**
- Mitra sees: [Campuran] [Organik] [Plastik] ✅
- Automatic! No manual add needed! 🎉

## 🔄 Backward Compatible

- ✅ Fields are `nullable` - old data still works
- ✅ If `user_waste_types` is null, frontend fallback to `waste_type_scheduled`
- ✅ No breaking changes

## 📋 Checklist

- [ ] Create migration
- [ ] Run `php artisan migrate`
- [ ] Update model `$fillable`
- [ ] Update model `$casts`
- [ ] Update `ScheduleController@store` validation
- [ ] Update `ScheduleController@store` to save `user_waste_types`
- [ ] Update `PickupScheduleController` API response
- [ ] Test create schedule
- [ ] Test get schedule
- [ ] Test with Postman
- [ ] Deploy

## 📞 Questions?

Lihat dokumentasi lengkap:
- `docs/BACKEND_USER_WASTE_TYPES.md` - Full implementation guide
- `docs/SUMMARY_AUTOMATIC_WASTE_TYPES.md` - Summary & flow

Frontend sudah ready menerima data ini! ✅

---

**Priority: HIGH**  
**Impact: User Experience Improvement**  
**Effort: LOW (1-2 hours)**  

Terima kasih! 🙏
