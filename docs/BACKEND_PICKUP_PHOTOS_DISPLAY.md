# Backend Documentation: Pickup Photos Display Issue

## 🔍 Problem Identified

**Issue:** Bukti foto tidak muncul di aplikasi Flutter pada halaman history mitra

**Root Cause:** Backend mengembalikan path relatif (`/storage/pickups/...`) tetapi Flutter menggunakan `Image.asset()` yang mengharapkan local asset path, bukan URL.

**Current Backend Response:**
```json
{
  "pickup_photos": [
    "/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg"
  ]
}
```

**What Flutter Needs:**
```json
{
  "pickup_photos": [
    "http://127.0.0.1:8000/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg"
  ]
}
```

---

## 📊 Analysis

### Current Flow

```
1. Mitra Upload Photo
   ↓
2. Backend Save to: storage/app/public/pickups/{schedule_id}/{filename}
   ↓
3. Backend Create Symlink: public/storage → storage/app/public
   ↓
4. Backend Save to DB: "/storage/pickups/66/xxx.jpg" (❌ Relative path)
   ↓
5. API Return: "/storage/pickups/66/xxx.jpg"
   ↓
6. Flutter Parse: Image.asset("/storage/pickups/66/xxx.jpg") (❌ Error!)
```

### Problem

- **Backend returns:** `/storage/pickups/66/xxx.jpg` (relative path)
- **Flutter expects:** Full URL `http://127.0.0.1:8000/storage/pickups/66/xxx.jpg`
- **Flutter uses:** `Image.asset()` yang hanya untuk local assets
- **Should use:** `Image.network()` untuk gambar dari server

---

## ✅ Solution

Ada 2 pendekatan:

### **Option A: Backend Returns Full URL** ⭐ RECOMMENDED

Backend sudah menyimpan file dengan benar, tapi perlu return full URL ke Flutter.

### **Option B: Flutter Parse Relative Path**

Flutter parse path relatif menjadi full URL (less preferred, butuh update banyak tempat).

---

## 🔧 Backend Implementation (Option A)

### 1. Create URL Helper Method in Model

**File:** `app/Models/PickupSchedule.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class PickupSchedule extends Model
{
    // ... existing code ...

    /**
     * Get pickup photos with full URL
     * 
     * @return array
     */
    public function getPickupPhotosUrlAttribute()
    {
        if (empty($this->pickup_photos)) {
            return [];
        }

        // Jika sudah array JSON
        $photos = is_string($this->pickup_photos) 
            ? json_decode($this->pickup_photos, true) 
            : $this->pickup_photos;

        if (!is_array($photos)) {
            return [];
        }

        // Convert relative paths to full URLs
        return array_map(function($photo) {
            // Jika sudah full URL, return as is
            if (str_starts_with($photo, 'http://') || str_starts_with($photo, 'https://')) {
                return $photo;
            }

            // Remove leading slash if exists
            $photo = ltrim($photo, '/');

            // Return full URL
            return url($photo);
        }, $photos);
    }

    /**
     * Accessor for pickup_photos attribute
     * Auto-convert to full URLs when accessing
     */
    protected function pickupPhotos(): Attribute
    {
        return Attribute::make(
            get: fn ($value) => $this->getPickupPhotosUrlAttribute(),
        );
    }
}
```

### 2. Update API Response to Use Full URLs

**Option 2A: Use Resource (Recommended)**

**File:** `app/Http/Resources/PickupScheduleResource.php`

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PickupScheduleResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'user_name' => $this->user_name,
            'user_phone' => $this->user_phone,
            'pickup_address' => $this->pickup_address,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'schedule_day' => $this->schedule_day,
            'waste_type_scheduled' => $this->waste_type_scheduled,
            'user_waste_types' => $this->user_waste_types, // NEW
            'estimated_weights' => $this->estimated_weights, // NEW
            'scheduled_pickup_at' => $this->scheduled_pickup_at,
            'pickup_time_start' => $this->pickup_time_start,
            'pickup_time_end' => $this->pickup_time_end,
            'waste_summary' => $this->waste_summary,
            'notes' => $this->notes,
            'status' => $this->status,
            'created_at' => $this->created_at,
            'assigned_mitra_id' => $this->assigned_mitra_id,
            'assigned_at' => $this->assigned_at,
            'completed_at' => $this->completed_at,
            'actual_weights' => $this->actual_weights,
            'total_weight' => $this->total_weight,
            
            // CONVERT TO FULL URLs
            'pickup_photos' => $this->getPickupPhotosWithFullUrl(),
        ];
    }

    /**
     * Get pickup photos with full URL
     */
    private function getPickupPhotosWithFullUrl()
    {
        if (empty($this->pickup_photos)) {
            return [];
        }

        $photos = is_string($this->pickup_photos) 
            ? json_decode($this->pickup_photos, true) 
            : $this->pickup_photos;

        if (!is_array($photos)) {
            return [];
        }

        return array_map(function($photo) {
            // Already full URL
            if (str_starts_with($photo, 'http://') || str_starts_with($photo, 'https://')) {
                return $photo;
            }

            // Remove leading slash
            $photo = ltrim($photo, '/');

            // Return full URL
            return url($photo);
        }, $photos);
    }
}
```

**Option 2B: Update Controller Directly**

**File:** `app/Http/Controllers/Mitra/PickupScheduleController.php`

```php
public function history(Request $request)
{
    $query = PickupSchedule::where('assigned_mitra_id', auth()->id())
        ->where('status', 'completed')
        ->orderBy('completed_at', 'desc');

    // ... filtering logic ...

    $schedules = $query->paginate($perPage);

    // Transform pickup_photos to full URLs
    $schedules->getCollection()->transform(function ($schedule) {
        if (!empty($schedule->pickup_photos)) {
            $photos = is_string($schedule->pickup_photos) 
                ? json_decode($schedule->pickup_photos, true) 
                : $schedule->pickup_photos;

            if (is_array($photos)) {
                $schedule->pickup_photos = array_map(function($photo) {
                    if (str_starts_with($photo, 'http://') || str_starts_with($photo, 'https://')) {
                        return $photo;
                    }
                    return url(ltrim($photo, '/'));
                }, $photos);
            }
        }
        return $schedule;
    });

    return response()->json([
        'success' => true,
        'message' => 'History retrieved successfully',
        'data' => [
            'schedules' => $schedules->items(),
            'pagination' => [
                'total' => $schedules->total(),
                'per_page' => $schedules->perPage(),
                'current_page' => $schedules->currentPage(),
                'last_page' => $schedules->lastPage(),
            ],
        ],
    ]);
}
```

### 3. Update Complete Pickup Response

**File:** `app/Http/Controllers/Mitra/PickupScheduleController.php`

```php
public function complete(Request $request, $id)
{
    // ... validation and save logic ...

    // Upload photos
    if ($request->hasFile('photos')) {
        $photos = [];
        foreach ($request->file('photos') as $photo) {
            $path = $photo->store("pickups/{$schedule->id}", 'public');
            
            // SAVE RELATIVE PATH IN DB (for consistency)
            $photos[] = "/storage/{$path}";
        }
        $schedule->pickup_photos = json_encode($photos);
        $schedule->save();
    }

    // RETURN WITH FULL URLs
    $photosWithUrls = [];
    if (!empty($schedule->pickup_photos)) {
        $photos = json_decode($schedule->pickup_photos, true);
        foreach ($photos as $photo) {
            $photosWithUrls[] = url(ltrim($photo, '/'));
        }
    }

    return response()->json([
        'success' => true,
        'message' => 'Pickup completed successfully',
        'data' => [
            'schedule' => [
                'id' => $schedule->id,
                'status' => $schedule->status,
                'completed_at' => $schedule->completed_at,
                'actual_weights' => $schedule->actual_weights,
                'total_weight' => $schedule->total_weight,
                'pickup_photos' => $photosWithUrls, // FULL URLs
                'points_earned' => $pointsEarned,
            ],
        ],
    ]);
}
```

---

## 🔍 Testing

### Test 1: Complete Pickup
```bash
TOKEN="your_token_here"

curl -X POST http://127.0.0.1:8000/api/mitra/pickup-schedules/66/complete \
  -H "Authorization: Bearer $TOKEN" \
  -F "actual_weights[Campuran]=1.0" \
  -F "actual_weights[Organik]=1.0" \
  -F "photos[]=@/path/to/photo1.jpg"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "schedule": {
      "pickup_photos": [
        "http://127.0.0.1:8000/storage/pickups/66/xxx.jpg"
      ]
    }
  }
}
```

### Test 2: Get History
```bash
TOKEN="your_token_here"

curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history" \
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 66,
        "pickup_photos": [
          "http://127.0.0.1:8000/storage/pickups/66/xxx.jpg",
          "http://127.0.0.1:8000/storage/pickups/66/yyy.jpg"
        ]
      }
    ]
  }
}
```

### Test 3: Verify Photo Accessible
```bash
# Test if photo is accessible via browser or curl
curl -I http://127.0.0.1:8000/storage/pickups/66/xxx.jpg
```

**Expected:** HTTP 200 OK

---

## 📋 Implementation Checklist

### Backend Tasks

- [ ] **Update Model** (if using accessor)
  - [ ] Add `getPickupPhotosUrlAttribute()` method
  - [ ] Add `pickupPhotos()` accessor
  
- [ ] **Update API Responses**
  - [ ] Create/Update `PickupScheduleResource`
  - [ ] OR update `complete()` method to return full URLs
  - [ ] Update `history()` method to return full URLs
  - [ ] Update `getScheduleDetail()` method (if exists)

- [ ] **Verify Storage Setup**
  - [ ] Check `php artisan storage:link` is run
  - [ ] Verify symlink: `public/storage → storage/app/public`
  - [ ] Test file access: `http://your-domain/storage/pickups/test.jpg`

- [ ] **Test Endpoints**
  - [ ] Test `/api/mitra/pickup-schedules/{id}/complete`
  - [ ] Test `/api/mitra/pickup-schedules/history`
  - [ ] Test `/api/mitra/pickup-schedules/{id}` (detail)
  - [ ] Verify photos return full URLs
  - [ ] Verify photos accessible via browser

### Frontend Tasks (Already Done ✅)

- [x] Model already has `pickupPhotos` field
- [x] Model parsing already supports `List<String>`
- [ ] **NEED TO UPDATE:** Change `Image.asset()` to `Image.network()` in history page

---

## 🐛 Common Issues & Solutions

### Issue 1: Symlink Not Created
```bash
# Error: 404 when accessing photos
# Solution:
php artisan storage:link

# Verify:
ls -la public/storage
# Should show: public/storage -> ../storage/app/public
```

### Issue 2: Permission Denied
```bash
# Error: Permission denied when saving photos
# Solution:
chmod -R 775 storage
chown -R www-data:www-data storage
```

### Issue 3: Photos Return Relative Path
```bash
# Error: Flutter gets "/storage/pickups/..." instead of full URL
# Solution: Implement URL conversion in backend (see above)
```

### Issue 4: Mixed Content (HTTP/HTTPS)
```bash
# Error: Can't load HTTP images on HTTPS app
# Solution: Update .env
APP_URL=https://your-domain.com
```

---

## 📸 Example Response Comparison

### ❌ Current (Wrong - Relative Path)
```json
{
  "id": 66,
  "pickup_photos": [
    "/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg"
  ]
}
```

### ✅ Expected (Correct - Full URL)
```json
{
  "id": 66,
  "pickup_photos": [
    "http://127.0.0.1:8000/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg"
  ]
}
```

---

## 🚀 Deployment Steps

### Development
1. Update backend code (Resource or Controller)
2. Run `php artisan storage:link` (if not done)
3. Test API endpoints with Postman
4. Verify photos return full URLs
5. Test in Flutter app

### Staging
1. Deploy backend changes
2. Run `php artisan storage:link` on server
3. Update `.env`: `APP_URL=https://staging.gerobaks.com`
4. Test API endpoints
5. Deploy Flutter app
6. End-to-end testing

### Production
1. Backup database
2. Deploy backend changes
3. Run `php artisan storage:link` on server
4. Update `.env`: `APP_URL=https://gerobaks.com`
5. Test API endpoints
6. Deploy Flutter app
7. Monitor for errors

---

## 📝 Notes

### Why Full URL?

1. **Cross-platform compatibility:** Works on Android, iOS, Web
2. **CDN support:** Easy to migrate to CDN later
3. **HTTPS support:** Works with secure connections
4. **Simplicity:** Flutter doesn't need to know base URL

### Storage Structure

```
storage/
  app/
    public/
      pickups/
        66/
          tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg
          anotherphoto.jpg
        67/
          photo1.jpg

public/
  storage/ → ../storage/app/public (symlink)
```

### URL Access

```
File: storage/app/public/pickups/66/photo.jpg
URL:  http://127.0.0.1:8000/storage/pickups/66/photo.jpg
```

---

## ✅ Summary

**Problem:** Foto tidak muncul karena backend return relative path

**Solution:** Backend harus return full URL

**Implementation:**
1. Update Model dengan accessor (optional)
2. Update API response di Controller/Resource
3. Convert relative path ke full URL: `url(ltrim($photo, '/'))`
4. Test dengan Postman
5. Verify di Flutter app

**Priority:** HIGH (Blocking feature)

**Estimated Time:** 2-3 hours

---

**Status:** Ready for Backend Implementation 🚀
