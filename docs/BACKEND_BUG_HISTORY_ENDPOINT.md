# 🐛 BUG REPORT: Mitra History Endpoint

**Dibuat:** 13 November 2025  
**Priority:** 🔴 **CRITICAL**  
**Status:** ⏳ **MENUNGGU BACKEND FIX**

---

## 📋 Executive Summary

**Endpoint yang Bermasalah:**
```
GET /api/mitra/pickup-schedules/history
```

**Symptoms:**
- ❌ Flutter app crash saat load tab "Riwayat"
- ❌ Error: `type 'String' is not a subtype of type 'num' in type cast`
- ❌ User tidak bisa melihat riwayat pengambilan sampah

**Root Cause:**
Backend mengirim response structure yang **BERBEDA** dengan endpoint lain, menyebabkan Flutter parsing error.

**Impact:**
- 🔴 **HIGH**: Fitur riwayat mitra tidak bisa digunakan sama sekali
- 🔴 **HIGH**: App crash setiap kali mitra buka tab "Riwayat"
- 🔴 **HIGH**: Mitra tidak bisa track pengambilan yang sudah selesai

---

## 🔬 Technical Analysis

### 1. **Current Backend Response** ❌

**Endpoint:**
```bash
GET http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1&per_page=20
```

**Current Response Structure:**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 51,
        "total_weight": "6.00",  // ❌ SALAH: STRING instead of NUMBER
        "actual_weights": {      // ❌ SALAH: Inconsistent format
          "Kaca": "1.0",         // Sometimes object with string values
          "Logam": "1.0"
        },
        "latitude": null,        // ⚠️ null instead of 0
        "longitude": null        // ⚠️ null instead of 0
      },
      {
        "id": 2,
        "total_weight": "9.80",  // ❌ SALAH: STRING instead of NUMBER
        "actual_weights": [      // ❌ SALAH: Inconsistent format
          {                      // Sometimes array of objects
            "type": "B3",
            "weight": 3.2
          }
        ]
      }
    ],
    "pagination": {
      "current_page": 1,
      "total": 6,
      "per_page": 5,
      "last_page": 2
    }
  }
}
```

**Problems Identified:**

1. ❌ **`total_weight` is STRING instead of NUMBER**
   - Flutter expects: `6.0` (number/double)
   - Backend sends: `"6.00"` (string)
   - **This causes the type casting error!**

2. ❌ **`actual_weights` has INCONSISTENT format**
   - Schedule #51: `{"Kaca": "1.0", "Logam": "1.0"}` (object with string values)
   - Schedule #2: `[{"type": "B3", "weight": 3.2}]` (array of objects)
   - **Backend should use consistent format for all schedules**

3. ⚠️ **`latitude` and `longitude` are `null` instead of `0`**
   - This is acceptable but less ideal
   - Better to send `0` or `0.0` for consistency

4. ✅ **Response keys are CORRECT now**
   - Backend uses: `data.schedules` ✅
   - Backend uses: `data.pagination` ✅
   - **This part is already fixed by backend!**

---

### 2. **Expected Response Structure** ✅

**What Flutter Expects (Consistent dengan endpoint lain):**

```json
{
  "success": true,
  "message": "History retrieved successfully",
  "data": {
    "schedules": [  // ✅ Must be "schedules", not "items"
      {
        "id": 1,
        "user_id": 2,
        "user_name": "User Daffa",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Merdeka No. 1, Jakarta",
        "latitude": -6.200000,
        "longitude": 106.816666,
        "schedule_day": "senin",
        "waste_type_scheduled": "B3",
        "scheduled_pickup_at": "2025-11-14 08:00:00",
        "pickup_time_start": "08:00:00",
        "pickup_time_end": "10:00:00",
        "waste_summary": "B3, Organik",
        "notes": "Sampah B3 berbahaya",
        "status": "completed",  // completed, cancelled
        "assigned_mitra_id": 5,
        "mitra_name": "Ahmad Kurniawan",
        "accepted_at": "2025-11-13 07:30:00",
        "started_at": "2025-11-13 08:15:00",
        "arrived_at": "2025-11-13 08:45:00",
        "completed_at": "2025-11-13 09:15:00",
        "actual_weights": {
          "B3": 5.5,
          "Organik": 3.2
        },
        "total_weight": 8.7,
        "pickup_photos": [
          "https://example.com/photo1.jpg",
          "https://example.com/photo2.jpg"
        ],
        "created_at": "2025-11-12 10:00:00",
        "updated_at": "2025-11-13 09:15:00"
      }
    ],
    "pagination": {  // ✅ Must be "pagination", not "meta"
      "current_page": 1,
      "last_page": 3,
      "per_page": 20,      // ✅ Must match request
      "total": 52,
      "from": 1,
      "to": 20,
      "has_more": true
    },
    "summary": {  // ✅ Optional: aggregate stats
      "total_completed": 52,
      "total_cancelled": 3,
      "total_weight_collected": 450.5,
      "this_month": {
        "completed": 12,
        "total_weight": 98.3
      }
    }
  }
}
```

---

## 🔍 Comparison: Working vs Broken

### ✅ **Available Schedules Endpoint (WORKING)**

**Request:**
```bash
GET /api/mitra/pickup-schedules/available?page=1
```

**Response:**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [...]  // ✅ Correct key
  }
}
```

**Flutter Code:**
```dart
schedulesList = (data['data']['schedules'] as List?) ?? [];  // ✅ Works
```

---

### ✅ **Active Schedules Endpoint (WORKING)**

**Request:**
```bash
GET /api/mitra/pickup-schedules/my-active
```

**Response:**
```json
{
  "success": true,
  "message": "Active schedules retrieved successfully",
  "data": {
    "schedules": [...]  // ✅ Correct key
  }
}
```

**Flutter Code:**
```dart
schedulesList = (data['data']['schedules'] as List?) ?? [];  // ✅ Works
```

---

### ❌ **History Endpoint (BROKEN)**

**Request:**
```bash
GET /api/mitra/pickup-schedules/history?page=1&per_page=20
```

**Response:**
```json
{
  "success": true,
  "message": "Schedules retrieved successfully",
  "data": {
    "items": [],     // ❌ Wrong key
    "meta": {...}    // ❌ Wrong key
  }
}
```

**Flutter Code:**
```dart
schedulesList = (data['data']['schedules'] as List?) ?? [];  // ❌ Crashes
// Tries to access data['schedules'] but backend sends data['items']
```

**Error:**
```
❌ Error fetching history: type 'String' is not a subtype of type 'num' in type cast
```

---

## 💻 Flutter Implementation (Current)

**File:** `lib/services/mitra_api_service.dart`

**Current Code (Line 420-500):**
```dart
Future<Map<String, dynamic>> getHistory({
  int page = 1,
  int perPage = 20,
  String? dateFrom,
  String? dateTo,
}) async {
  try {
    final token = await _localStorage.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    final uri = Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupHistory}')
        .replace(queryParameters: queryParams);

    _logger.i('📚 Fetching history: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        // ✅ This part tries to handle both formats
        List<dynamic> schedulesList;
        Map<String, dynamic>? pagination;
        Map<String, dynamic>? summary;
        
        if (data['data'] is List) {
          schedulesList = data['data'] as List;
          pagination = null;
          summary = null;
        } else if (data['data'] is Map<String, dynamic>) {
          // ❌ PROBLEM: Expects "schedules" key, but backend sends "items"
          schedulesList = (data['data']['schedules'] as List?) ?? [];
          pagination = data['data']['pagination'] as Map<String, dynamic>?;
          summary = data['data']['summary'] as Map<String, dynamic>?;
        } else {
          schedulesList = [];
          pagination = null;
          summary = null;
        }
        
        final schedules = schedulesList
            .map((json) => MitraPickupSchedule.fromJson(json))
            .toList();
        
        _logger.i('✅ Loaded ${schedules.length} history items');
        
        return {
          'schedules': schedules,
          'pagination': pagination ?? {},
          'summary': summary ?? {},
        };
      }
      return {
        'schedules': <MitraPickupSchedule>[],
        'pagination': {},
        'summary': {},
      };
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Gagal memuat riwayat');
    }
  } catch (e) {
    _logger.e('❌ Error fetching history: $e');
    rethrow;
  }
}
```

**Why It Fails:**
1. Line 468: `data['data']['schedules']` returns `null` because backend sends `items`, not `schedules`
2. Line 469: `data['data']['pagination']` returns `null` because backend sends `meta`, not `pagination`
3. Downstream code tries to cast null as `List` or `Map`, causing type errors

---

## 🛠️ Backend Fix Required

### **CRITICAL: Fix Type Casting Issues** 🔴

**File:** `app/Http/Controllers/MitraPickupScheduleController.php` (or similar)

**Issue 1: `total_weight` returned as STRING** ❌

**Current Code (Assumed):**
```php
$schedule->total_weight = $actualWeights->sum('weight');
// Results in: "6.00" (string because DB column is DECIMAL)
```

**Fixed Code:**
```php
// Force cast to float/double
$schedule->total_weight = (float) $actualWeights->sum('weight');
// OR in response transformation:
'total_weight' => (float) $schedule->total_weight,
// Results in: 6.0 (number)
```

---

**Issue 2: `actual_weights` inconsistent format** ❌

**Current Code (Problem):**
```php
// Sometimes returns:
'actual_weights' => json_decode($schedule->actual_weights)  // Object: {"Kaca": "1.0"}

// Other times returns:
'actual_weights' => [
    ['type' => 'B3', 'weight' => 3.2]  // Array of objects
]
```

**Recommended Fix - Standardize to Object Format:**
```php
// Transform all actual_weights to consistent object format
$actualWeights = json_decode($schedule->actual_weights, true);

if (is_array($actualWeights) && isset($actualWeights[0]['type'])) {
    // Convert array format to object format
    $weightsObj = [];
    foreach ($actualWeights as $item) {
        $weightsObj[$item['type']] = (float) $item['weight'];
    }
    $schedule->actual_weights = $weightsObj;
} else {
    // Ensure values are floats, not strings
    foreach ($actualWeights as $type => $weight) {
        $actualWeights[$type] = (float) $weight;
    }
    $schedule->actual_weights = $actualWeights;
}

// Final format should always be:
// {"Kaca": 1.0, "Logam": 1.0, "Kertas": 1.0}  // Numbers, not strings!
```

---

**Issue 3: `latitude` and `longitude` null values** ⚠️

**Current:** Returns `null`
**Better:** Return `0.0` (float)

```php
'latitude' => (float) ($schedule->latitude ?? 0),
'longitude' => (float) ($schedule->longitude ?? 0),
```

---

### **Complete Fixed Response Transformer** ✅

```php
public function getHistory(Request $request) {
    $perPage = $request->input('per_page', 20);
    
    $schedules = PickupSchedule::with(['user'])
        ->where('assigned_mitra_id', auth()->user()->id)
        ->whereIn('status', ['completed', 'cancelled'])
        ->orderBy('completed_at', 'desc')
        ->paginate($perPage);
    
    // Transform each schedule
    $transformedSchedules = $schedules->getCollection()->map(function($schedule) {
        // Parse actual_weights
        $actualWeights = json_decode($schedule->actual_weights, true) ?? [];
        
        // Ensure consistent object format with numeric values
        if (is_array($actualWeights) && isset($actualWeights[0]['type'])) {
            // Array format - convert to object
            $weightsObj = [];
            foreach ($actualWeights as $item) {
                $weightsObj[$item['type']] = (float) ($item['weight'] ?? 0);
            }
            $actualWeights = $weightsObj;
        } else {
            // Object format - ensure numeric values
            foreach ($actualWeights as $type => $weight) {
                $actualWeights[$type] = (float) $weight;
            }
        }
        
        return [
            'id' => $schedule->id,
            'user_id' => $schedule->user_id,
            'user_name' => $schedule->user->name,
            'user_phone' => $schedule->user->phone,
            'pickup_address' => $schedule->pickup_address,
            'latitude' => (float) ($schedule->latitude ?? 0),      // ✅ Force float
            'longitude' => (float) ($schedule->longitude ?? 0),    // ✅ Force float
            'schedule_day' => $schedule->schedule_day,
            'waste_type_scheduled' => $schedule->waste_type_scheduled,
            'scheduled_pickup_at' => $schedule->scheduled_pickup_at,
            'pickup_time_start' => $schedule->pickup_time_start,
            'pickup_time_end' => $schedule->pickup_time_end,
            'waste_summary' => $schedule->waste_summary,
            'notes' => $schedule->notes,
            'status' => $schedule->status,
            'assigned_mitra_id' => $schedule->assigned_mitra_id,
            'assigned_at' => $schedule->assigned_at,
            'completed_at' => $schedule->completed_at,
            'cancelled_at' => $schedule->cancelled_at,
            'cancellation_reason' => $schedule->cancellation_reason,
            'actual_weights' => $actualWeights,                    // ✅ Consistent format
            'total_weight' => (float) ($schedule->total_weight ?? 0),  // ✅ Force float
            'pickup_photos' => $schedule->pickup_photos ? json_decode($schedule->pickup_photos) : [],
            'created_at' => $schedule->created_at,
            'updated_at' => $schedule->updated_at,
        ];
    });
    
    return response()->json([
        'success' => true,
        'data' => [
            'schedules' => $transformedSchedules,  // ✅ Correct key
            'pagination' => [                      // ✅ Correct key
                'current_page' => $schedules->currentPage(),
                'last_page' => $schedules->lastPage(),
                'per_page' => $schedules->perPage(),
                'total' => $schedules->total(),
            ],
        ]
    ]);
}
```

---

## ✅ Flutter Fix Applied (Temporary Workaround)

**While waiting for backend fix, Flutter has been updated with defensive parsing:**

**File:** `lib/models/mitra_pickup_schedule.dart`

**Added Helper Method:**
```dart
/// Helper method untuk parse double dari berbagai format
static double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}
```

**Updated `fromJson` Method:**
```dart
factory MitraPickupSchedule.fromJson(Map<String, dynamic> json) {
  return MitraPickupSchedule(
    // ... other fields
    latitude: _parseDouble(json['latitude']) ?? 0.0,     // ✅ Handles null, string, or number
    longitude: _parseDouble(json['longitude']) ?? 0.0,   // ✅ Handles null, string, or number
    totalWeight: _parseDouble(json['total_weight']),     // ✅ Handles string "6.00" or number 6.0
    // ... other fields
  );
}
```

**What This Fix Does:**
- ✅ Accepts `total_weight` as STRING `"6.00"` and converts to `double 6.0`
- ✅ Accepts `total_weight` as NUMBER `6.0` directly
- ✅ Accepts `latitude`/`longitude` as `null` and converts to `0.0`
- ✅ Prevents type casting crashes
- ⚠️ **This is a WORKAROUND** - Backend should still fix to send proper types

**Why Backend Should Still Fix:**
1. **Consistency**: Other endpoints send numbers, not strings
2. **Performance**: String parsing is slower than direct number access
3. **Type Safety**: Proper types prevent bugs in other places
4. **API Standards**: REST APIs should use correct JSON types
5. **Mobile Apps**: iOS/Android native code expects correct types

---

## 🧪 Testing Instructions

### **For Backend Developer:**

**Step 1: Apply Fix**
```bash
# Edit: app/Http/Controllers/MitraPickupScheduleController.php
# Implement changes from "Option 1" above
```

**Step 2: Test with curl**
```bash
# Login sebagai mitra
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}' \
  | jq -r '.data.token')

# Test history endpoint
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1&per_page=20" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  | jq '.'
```

**Expected Result After Fix:**
```json
{
  "success": true,
  "message": "History retrieved successfully",
  "data": {
    "schedules": [  // ✅ Must be "schedules"
      {
        "id": 1,
        "user_id": 2,
        "user_name": "User Daffa",
        "status": "completed",
        ...
      }
    ],
    "pagination": {  // ✅ Must be "pagination"
      "current_page": 1,
      "last_page": 3,
      "per_page": 20,  // ✅ Must match request
      "total": 52,
      "has_more": true
    },
    "summary": {  // ✅ Optional
      "total_completed": 52,
      "total_cancelled": 3
    }
  }
}
```

**Step 3: Verify per_page Works**
```bash
# Test with per_page=10
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1&per_page=10" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data.pagination.per_page'

# Expected output: 10 (not 100)
```

**Step 4: Create Test Data (if needed)**
```bash
php artisan tinker
```

```php
// Create completed schedule
$schedule = PickupSchedule::find(52);  // Use existing schedule
$schedule->assigned_mitra_id = 5;  // Assign to mitra
$schedule->status = 'completed';
$schedule->completed_at = now();
$schedule->actual_weights = ['B3' => 5.5, 'Organik' => 3.2];
$schedule->total_weight = 8.7;
$schedule->save();

// Create cancelled schedule
$schedule2 = PickupSchedule::find(51);
$schedule2->assigned_mitra_id = 5;
$schedule2->status = 'cancelled';
$schedule2->cancelled_at = now();
$schedule2->cancel_reason = 'User tidak di tempat';
$schedule2->save();

// Verify count
PickupSchedule::where('assigned_mitra_id', 5)
    ->whereIn('status', ['completed', 'cancelled'])
    ->count();
// Should return at least 2
```

---

## 📝 Full Response Example (After Fix)

**Request:**
```bash
GET /api/mitra/pickup-schedules/history?page=1&per_page=20
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "History retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 1,
        "user_id": 2,
        "user_name": "User Daffa",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Merdeka No. 1, Jakarta",
        "latitude": -6.200000,
        "longitude": 106.816666,
        "schedule_day": "senin",
        "waste_type_scheduled": "B3",
        "scheduled_pickup_at": "2025-11-14 08:00:00",
        "pickup_time_start": "08:00:00",
        "pickup_time_end": "10:00:00",
        "waste_summary": "B3, Organik (8.7 kg)",
        "notes": "Sampah B3 berbahaya",
        "status": "completed",
        "assigned_mitra_id": 5,
        "mitra_name": "Ahmad Kurniawan",
        "accepted_at": "2025-11-13 07:30:00",
        "started_at": "2025-11-13 08:15:00",
        "arrived_at": "2025-11-13 08:45:00",
        "completed_at": "2025-11-13 09:15:00",
        "actual_weights": {
          "B3": 5.5,
          "Organik": 3.2
        },
        "total_weight": 8.7,
        "pickup_photos": [
          "https://example.com/storage/pickups/photo1.jpg",
          "https://example.com/storage/pickups/photo2.jpg"
        ],
        "created_at": "2025-11-12 10:00:00",
        "updated_at": "2025-11-13 09:15:00"
      },
      {
        "id": 2,
        "user_id": 10,
        "user_name": "Aceng as",
        "user_phone": "1234567890",
        "pickup_address": "1-99 Stockton St, San Francisco",
        "latitude": 37.7749,
        "longitude": -122.4194,
        "schedule_day": "selasa",
        "waste_type_scheduled": "Plastik",
        "scheduled_pickup_at": "2025-11-13 10:00:00",
        "pickup_time_start": "10:00:00",
        "pickup_time_end": "12:00:00",
        "waste_summary": "Plastik",
        "notes": null,
        "status": "cancelled",
        "assigned_mitra_id": 5,
        "mitra_name": "Ahmad Kurniawan",
        "accepted_at": "2025-11-13 08:00:00",
        "started_at": null,
        "arrived_at": null,
        "completed_at": null,
        "cancelled_at": "2025-11-13 09:00:00",
        "cancel_reason": "User tidak di tempat",
        "actual_weights": null,
        "total_weight": 0,
        "pickup_photos": [],
        "created_at": "2025-11-12 14:00:00",
        "updated_at": "2025-11-13 09:00:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 3,
      "per_page": 20,
      "total": 52,
      "from": 1,
      "to": 20,
      "has_more": true
    },
    "summary": {
      "total_completed": 50,
      "total_cancelled": 2,
      "total_weight_collected": 423.5,
      "this_month": {
        "completed": 12,
        "cancelled": 1,
        "total_weight": 98.3
      }
    }
  }
}
```

---

## 📊 Field Requirements

### **Required Fields in Each Schedule:**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | integer | ✅ | Primary key |
| user_id | integer | ✅ | Schedule creator |
| user_name | string | ✅ | User full name |
| user_phone | string | ✅ | User contact |
| pickup_address | string | ✅ | Full address |
| latitude | float | ✅ | GPS coordinate |
| longitude | float | ✅ | GPS coordinate |
| schedule_day | string | ✅ | Day name |
| waste_type_scheduled | string | ✅ | Main waste type |
| scheduled_pickup_at | datetime | ✅ | Scheduled time |
| pickup_time_start | time | ✅ | Time window start |
| pickup_time_end | time | ✅ | Time window end |
| waste_summary | string | ✅ | Summary text |
| notes | string | nullable | User notes |
| status | string | ✅ | completed/cancelled |
| assigned_mitra_id | integer | ✅ | Mitra ID |
| mitra_name | string | ✅ | Mitra full name |
| accepted_at | datetime | ✅ | When accepted |
| started_at | datetime | nullable | Journey start |
| arrived_at | datetime | nullable | Arrival time |
| completed_at | datetime | conditional | If completed |
| cancelled_at | datetime | conditional | If cancelled |
| cancel_reason | string | conditional | If cancelled |
| actual_weights | object | conditional | If completed |
| total_weight | float | ✅ | Total weight (kg) |
| pickup_photos | array | ✅ | Photo URLs (can be empty) |
| created_at | datetime | ✅ | Record creation |
| updated_at | datetime | ✅ | Last update |

---

## ✅ Checklist untuk Backend

### **Pre-Implementation:**
- [ ] Baca dokumentasi ini lengkap
- [ ] Understand current vs expected structure
- [ ] Backup database (if testing with real data)

### **Implementation:**
- [ ] Change `items` → `schedules`
- [ ] Change `meta` → `pagination`
- [ ] Fix `per_page` parameter handling
- [ ] Add `.with(['user', 'wasteType'])` untuk eager loading
- [ ] Add `summary` calculation (optional but recommended)
- [ ] Update message to "History retrieved successfully"

### **Testing:**
- [ ] Test dengan curl (see instructions above)
- [ ] Verify response structure matches expected
- [ ] Test `per_page=10` - should return 10, not 100
- [ ] Test `per_page=5` - should return 5
- [ ] Test pagination (`page=1`, `page=2`, etc.)
- [ ] Test dengan empty result (no history)
- [ ] Test dengan 1 completed schedule
- [ ] Test dengan 1 cancelled schedule
- [ ] Test dengan mixed (completed + cancelled)

### **Validation:**
- [ ] Response has `data.schedules` (not `data.items`)
- [ ] Response has `data.pagination` (not `data.meta`)
- [ ] `pagination.per_page` matches request parameter
- [ ] All required fields present in each schedule
- [ ] Timestamps are in correct format (Y-m-d H:i:s)
- [ ] Weights are floats, not strings
- [ ] Photos array (can be empty array `[]`)

### **Documentation:**
- [ ] Update API documentation
- [ ] Add example request/response
- [ ] Document query parameters
- [ ] Document response fields

---

## 🔄 Comparison: All Mitra Endpoints

### **Summary Table:**

| Endpoint | Response Key | Pagination Key | Works? |
|----------|--------------|----------------|--------|
| `/available` | ✅ `schedules` | N/A | ✅ YES |
| `/my-active` | ✅ `schedules` | N/A | ✅ YES |
| `/history` | ❌ `items` | ❌ `meta` | ❌ NO |

**After Fix, all should be:**

| Endpoint | Response Key | Pagination Key | Works? |
|----------|--------------|----------------|--------|
| `/available` | ✅ `schedules` | ✅ `pagination` | ✅ YES |
| `/my-active` | ✅ `schedules` | N/A | ✅ YES |
| `/history` | ✅ `schedules` | ✅ `pagination` | ✅ YES |

---

## 🚀 After Fix is Applied

### **Flutter Side (No Changes Needed):**

Once backend is fixed, Flutter code will automatically work because it already handles the correct structure.

**Current Flutter code already expects:**
```dart
schedulesList = (data['data']['schedules'] as List?) ?? [];
pagination = data['data']['pagination'] as Map<String, dynamic>?;
```

**This will match fixed backend response:**
```json
{
  "data": {
    "schedules": [...],  // ✅ Matches
    "pagination": {...}   // ✅ Matches
  }
}
```

### **Expected Behavior After Fix:**

1. ✅ User login sebagai mitra
2. ✅ Buka tab "Riwayat"
3. ✅ Muncul list pengambilan yang sudah selesai
4. ✅ Bisa scroll pagination (load more)
5. ✅ Bisa lihat detail setiap riwayat
6. ✅ Bisa filter by date range
7. ✅ No crashes, no errors

---

## 📞 Contact & Support

**Jika ada pertanyaan tentang dokumentasi ini:**

1. **Review Code di:**
   - Flutter: `lib/services/mitra_api_service.dart` (line 420-500)
   - Flutter: `lib/ui/pages/mitra/history_page.dart`

2. **Test Endpoint:**
   ```bash
   curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1&per_page=20" \
     -H "Authorization: Bearer <token>" | jq '.'
   ```

3. **Expected Fix Time:** 15-30 minutes

4. **Priority:** 🔴 CRITICAL - Blocking mitra history feature

---

## 📝 Summary

**Problem:** History endpoint uses different response structure (`items`, `meta`) than other endpoints (`schedules`, `pagination`)

**Solution:** Change backend response to use consistent structure

**Impact:** After fix, mitra can view their pickup history without crashes

**Changes Required:**
```diff
- "items": [...]
+ "schedules": [...]

- "meta": {...}
+ "pagination": {...}

- $perPage = $request->input('per_page', 100);
+ $perPage = $request->input('per_page', 20);
```

**Testing:** Use curl commands provided above

**Status:** ⏳ **WAITING FOR BACKEND FIX**

---

*Dokumentasi dibuat: 13 November 2025*  
*Last Updated: 13 November 2025*

---

## 🔗 Related Documentation

- **Pagination Feature:** `docs/PAGINATION_FEATURE.md`
- **Real-Time Status Update:** `docs/REALTIME_STATUS_UPDATE.md`
- **Backend Fix Index:** `docs/README_BACKEND_DOCS.md`
