# ⚡ Backend Laravel - Quick Reference

**TLDR untuk Backend Team Laravel**  
**Purpose:** User app polling setiap 30 detik untuk detect status change jadwal

---

## 🎯 Yang Perlu Dibuat Backend

### **1. API Endpoint (WAJIB)**

```
GET /api/user/pickup-schedules
```

**Headers:**
```
Authorization: Bearer {user_token}
```

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "status": "accepted",
      "pickup_address": "Jl. Sudirman No. 123",
      "schedule_day": "Minggu, 17 Nov 2025",
      "pickup_time_start": "10:28",
      "mitra_id": 8,
      "mitra_name": "John Doe",
      "mitra_phone": "081234567890",
      "total_weight_kg": null,
      "total_points": null,
      "updated_at": "2025-11-17T09:30:00.000000Z"
    }
  ]
}
```

---

## 🔑 Critical Fields

| Field | Type | Format | Example |
|-------|------|--------|---------|
| `id` | integer | - | 75 |
| `status` | string | enum | "accepted" |
| `schedule_day` | string | **Bahasa Indonesia** | "Minggu, 17 Nov 2025" |
| `pickup_time_start` | string | **HH:mm** | "10:28" |
| `pickup_address` | string | - | "Jl. Sudirman..." |
| `updated_at` | string | ISO 8601 | "2025-11-17T09:30:00.000000Z" |

---

## 📊 Status Flow

```
pending → accepted → on_the_way → arrived → completed
```

**Status Values (ENUM):**
- `pending` - Baru dibuat user
- `accepted` - Mitra sudah terima
- `on_the_way` - Mitra dalam perjalanan
- `arrived` - Mitra sudah sampai
- `completed` - Penjemputan selesai
- `cancelled` - Dibatalkan

---

## 🎨 Model Accessor (WAJIB)

```php
// app/Models/PickupSchedule.php

public function getScheduleDayAttribute()
{
    Carbon::setLocale('id'); // Set Indonesia
    $date = Carbon::parse($this->scheduled_pickup_at);
    return $date->translatedFormat('l, d M Y');
    // Output: "Minggu, 17 Nov 2025"
}

public function getPickupTimeStartAttribute()
{
    $date = Carbon::parse($this->scheduled_pickup_at);
    return $date->format('H:i');
    // Output: "10:28"
}

public function getMitraNameAttribute()
{
    return $this->mitra ? $this->mitra->name : null;
}

public function getMitraPhoneAttribute()
{
    return $this->mitra ? $this->mitra->phone : null;
}
```

---

## 🛣️ Routes

```php
// routes/api.php

Route::middleware(['auth:sanctum', 'role:end_user'])->prefix('user')->group(function () {
    Route::get('/pickup-schedules', [PickupScheduleController::class, 'index']);
});

Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    Route::post('/pickup-schedules/{id}/accept', [MitraPickupController::class, 'acceptSchedule']);
    Route::post('/pickup-schedules/{id}/on-the-way', [MitraPickupController::class, 'onTheWay']);
    Route::post('/pickup-schedules/{id}/arrived', [MitraPickupController::class, 'arrived']);
    Route::post('/pickup-schedules/{id}/complete', [MitraPickupController::class, 'complete']);
});
```

---

## 🎯 Controller Quick Code

```php
// app/Http/Controllers/Api/User/PickupScheduleController.php

public function index(Request $request)
{
    $user = $request->user();

    $schedules = PickupSchedule::forUser($user->id)
        ->with('mitra:id,name,phone')
        ->orderBy('scheduled_pickup_at', 'desc')
        ->get();

    $data = $schedules->map(function ($schedule) {
        return [
            'id' => $schedule->id,
            'status' => $schedule->status,
            'pickup_address' => $schedule->pickup_address,
            'schedule_day' => $schedule->schedule_day,        // Accessor
            'pickup_time_start' => $schedule->pickup_time_start, // Accessor
            'mitra_id' => $schedule->mitra_id,
            'mitra_name' => $schedule->mitra_name,            // Accessor
            'mitra_phone' => $schedule->mitra_phone,          // Accessor
            'total_weight_kg' => $schedule->total_weight_kg,
            'total_points' => $schedule->total_points,
            'updated_at' => $schedule->updated_at->toIso8601String(),
        ];
    });

    return response()->json([
        'success' => true,
        'message' => 'Pickup schedules retrieved successfully',
        'data' => $data
    ]);
}
```

---

## 🔄 Mitra Accept Schedule

```php
// app/Http/Controllers/Api/Mitra/MitraPickupController.php

public function acceptSchedule(Request $request, $id)
{
    $mitra = $request->user();
    $schedule = PickupSchedule::findOrFail($id);

    if ($schedule->status !== 'pending') {
        return response()->json([
            'success' => false,
            'message' => 'Schedule already ' . $schedule->status
        ], 400);
    }

    $schedule->update([
        'status' => 'accepted',
        'mitra_id' => $mitra->id,
    ]);
    // updated_at akan auto-update!

    return response()->json([
        'success' => true,
        'message' => 'Schedule accepted successfully',
        'data' => [
            'id' => $schedule->id,
            'status' => $schedule->status,
            'mitra_id' => $schedule->mitra_id,
            'updated_at' => $schedule->updated_at->toIso8601String(),
        ]
    ]);
}
```

---

## 🧪 Quick Test

### **Test 1: Get Schedules**
```bash
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN" | jq '.'
```

**Expected:**
```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "status": "pending",
      "schedule_day": "Minggu, 17 Nov 2025",  // ✅ Bahasa Indonesia
      "pickup_time_start": "10:28"             // ✅ Format HH:mm
    }
  ]
}
```

---

### **Test 2: Mitra Accept**
```bash
curl -X POST "http://localhost:8000/api/mitra/pickup-schedules/75/accept" \
  -H "Authorization: Bearer MITRA_TOKEN"
```

**Expected:**
```json
{
  "success": true,
  "data": {
    "status": "accepted",
    "mitra_id": 8,
    "updated_at": "2025-11-17T09:30:00.000000Z"  // ✅ Updated!
  }
}
```

---

### **Test 3: Check Again (User)**
```bash
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN" | jq '.'
```

**Expected:**
```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "status": "accepted",           // ✅ Changed!
      "mitra_id": 8,                  // ✅ Filled!
      "mitra_name": "John Doe",       // ✅ From accessor
      "updated_at": "..."             // ✅ Updated!
    }
  ]
}
```

**→ Flutter app detect change → 🔔 Banner muncul!**

---

## ⚠️ Common Mistakes

### **1. Format Tanggal Salah**
```php
❌ "Sunday, 17 Nov 2025"     // English
✅ "Minggu, 17 Nov 2025"     // Indonesia

// Fix:
Carbon::setLocale('id');
```

---

### **2. Field Tidak Ada**
```json
❌ { "id": 75, "status": "accepted" }  // Missing fields

✅ {
  "id": 75,
  "status": "accepted",
  "schedule_day": "Minggu, 17 Nov 2025",    // Must have
  "pickup_time_start": "10:28"               // Must have
}
```

---

### **3. updated_at Tidak Update**
```php
// Make sure di migration:
$table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

// Or force update:
$schedule->touch();
```

---

## ✅ Success Checklist

- [ ] Endpoint `GET /api/user/pickup-schedules` works
- [ ] Response format exact seperti contoh
- [ ] `schedule_day` dalam Bahasa Indonesia
- [ ] `pickup_time_start` format HH:mm (not HH:mm:ss)
- [ ] `updated_at` auto-updates saat status change
- [ ] Mitra can accept schedule via API
- [ ] Authentication works (Sanctum/JWT)

---

## 📚 Full Documentation

Lihat file lengkap untuk detail:
- `BACKEND_LARAVEL_NOTIFICATION_IMPLEMENTATION.md` - Full guide dengan code lengkap
- `DEBUG_NOTIFICATION_NOT_SHOWING.md` - Flutter app debugging guide

---

## 🚀 Next Step

1. ✅ Implementasi endpoint & model
2. ✅ Test dengan curl/Postman
3. ✅ Verify response format
4. ✅ Deploy ke server
5. ✅ Test dengan Flutter app (polling setiap 30s)
6. 🎉 Banner muncul saat status change!

---

**Questions?** Share hasil testing! 🚀
