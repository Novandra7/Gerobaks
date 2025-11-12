# ⚡ Quick Backend Checklist
## Activity Schedule API Implementation

> **Status:** 🔴 URGENT - Flutter Ready, Waiting for Backend  
> **Time Estimate:** 2-3 hours

---

## 🎯 Yang Harus Dibuat

### 1️⃣ Database Migration
```bash
php artisan make:migration create_waste_schedules_table
```

**Tabel:** `waste_schedules`
- ✅ 22 columns (lihat detail di `UNTUK_BACKEND_TEAM.md`)
- ✅ Foreign keys: user_id, mitra_id
- ✅ Indexes: user_id, status, scheduled_at
- ✅ Soft delete support

---

### 2️⃣ Model
```bash
php artisan make:model WasteSchedule
```

**Relationships:**
- `belongsTo(User::class, 'user_id')` - Owner
- `belongsTo(User::class, 'mitra_id')` - Mitra assigned

---

### 3️⃣ Controller
```bash
php artisan make:controller Api/WasteScheduleController
```

**4 Methods:**
1. `index()` - Get all schedules (with filters)
2. `show($id)` - Get detail
3. `store()` - Create new
4. `cancel($id)` - Cancel schedule

---

### 4️⃣ Routes (routes/api.php)

```php
Route::middleware(['auth:sanctum'])->group(function () {
    Route::prefix('waste-schedules')->group(function () {
        Route::get('/', [WasteScheduleController::class, 'index']);
        Route::get('/{id}', [WasteScheduleController::class, 'show']);
        Route::post('/', [WasteScheduleController::class, 'store']);
        Route::post('/{id}/cancel', [WasteScheduleController::class, 'cancel']);
    });
});
```

**⚠️ CRITICAL:** Gunakan prefix `waste-schedules` (BUKAN `schedules`)

---

## 🚀 Quick Implementation Steps

### Step 1: Copy-Paste Code (5 menit)
1. Migration schema → dari `UNTUK_BACKEND_TEAM.md` baris 330-370
2. Model code → dari `UNTUK_BACKEND_TEAM.md` baris 380-420
3. Controller code → dari `UNTUK_BACKEND_TEAM.md` baris 430-680
4. Routes → dari `UNTUK_BACKEND_TEAM.md` baris 690-710

### Step 2: Run Migration (1 menit)
```bash
php artisan migrate
```

### Step 3: Create Test Data (5 menit)
```bash
php artisan tinker
```
Copy-paste test data generator dari `UNTUK_BACKEND_TEAM.md` baris 780-880

### Step 4: Test Endpoints (10 menit)
```bash
# Test GET
curl -X GET "http://127.0.0.1:8000/api/waste-schedules" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

Lihat semua curl commands di `UNTUK_BACKEND_TEAM.md` baris 730-780

---

## ✅ Testing Checklist

**Minimum Requirements:**
- [ ] GET /api/waste-schedules returns 200
- [ ] Response format: `{success, message, data: {schedules, pagination, summary}}`
- [ ] Filter by status works: `?status=pending`
- [ ] Filter by date works: `?date=2025-11-12`
- [ ] GET /api/waste-schedules/1 returns detail
- [ ] POST /api/waste-schedules creates schedule
- [ ] POST /api/waste-schedules/1/cancel cancels schedule

**Complete Checklist:** See `UNTUK_BACKEND_TEAM.md` baris 900-930

---

## 📋 4 Endpoints Summary

| Method | Endpoint | Function |
|--------|----------|----------|
| GET | /api/waste-schedules | Get all (dengan filter) |
| GET | /api/waste-schedules/{id} | Get detail |
| POST | /api/waste-schedules | Create new |
| POST | /api/waste-schedules/{id}/cancel | Cancel |

**Query Parameters untuk GET:**
- `status` - Filter: pending, in_progress, completed, cancelled
- `date` - Filter: YYYY-MM-DD (contoh: 2025-11-12)
- `waste_type` - Filter: Organik, Anorganik, B3, Elektronik
- `page` - Pagination (default: 1)
- `per_page` - Items per page (default: 20, max: 100)

---

## 🎯 Expected Response Format

```json
{
  "success": true,
  "message": "Schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 1,
        "user_id": 14,
        "waste_type": "Organik",
        "status": "pending",
        "scheduled_at": "2025-11-12 08:00:00",
        "mitra": {...}
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 15,
      "from": 1,
      "to": 15
    },
    "summary": {
      "total_schedules": 15,
      "active_count": 3,
      "completed_count": 10,
      "cancelled_count": 2,
      "by_status": {...}
    }
  }
}
```

---

## ⚠️ Critical Notes

1. **Endpoint URL:** Harus `/api/waste-schedules` (sudah di-hardcode di Flutter)
2. **Response Structure:** Harus nested dalam `data` key
3. **Pagination:** Harus return `from` dan `to` (bisa null)
4. **Summary:** Harus return `by_status` object
5. **Mitra Relation:** Harus include dengan `with('mitra:id,name,...')`

---

## 📚 Full Documentation

Untuk detail lengkap, lihat:
- **📄 UNTUK_BACKEND_TEAM.md** (1000+ baris) - Complete guide
- **📄 ACTIVITY_API_STATUS.md** - Current status & fixes
- **📄 TESTING_ACTIVITY_API.md** - Testing guide
- **📄 BACKEND_API_ACTIVITY_SCHEDULES.md** - Original specs

---

## 🆘 Need Help?

**Common Issues:**
1. **404 Error?** → Check route prefix (`waste-schedules` bukan `schedules`)
2. **401 Error?** → Check Bearer token authentication
3. **500 Error?** → Check relationships in Model (user, mitra)
4. **Wrong format?** → Check response nested in `data` key
5. **Summary empty?** → Check by_status calculation

**Contact:**
- Koordinasi dengan Flutter team setelah API ready
- Test dengan curl sebelum notify Flutter
- Provide test token untuk integration testing

---

**Priority:** 🔴 **HIGHEST**  
**Impact:** High - Flutter app blocked without this API  
**Effort:** Low - 2-3 hours with provided code  
**Status:** ⏳ Pending backend implementation

---

*Quick Reference - See UNTUK_BACKEND_TEAM.md for complete documentation*
