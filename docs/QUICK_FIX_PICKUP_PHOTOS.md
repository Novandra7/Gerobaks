# QUICK FIX: Bukti Foto Tidak Muncul

## 🔴 Problem

**Bukti foto yang diupload mitra tidak muncul di halaman history**

---

## 🔍 Root Cause

Backend return **relative path**, Flutter butuh **full URL**:

```json
❌ Current (Wrong):
{
  "pickup_photos": ["/storage/pickups/66/xxx.jpg"]
}

✅ Expected (Correct):
{
  "pickup_photos": ["http://127.0.0.1:8000/storage/pickups/66/xxx.jpg"]
}
```

---

## ✅ Quick Solution (Backend)

### Update Controller Method

**File:** `app/Http/Controllers/Mitra/PickupScheduleController.php`

**Method:** `history()` dan `complete()`

**Add this code:**

```php
// Convert pickup_photos to full URLs
$schedules->getCollection()->transform(function ($schedule) {
    if (!empty($schedule->pickup_photos)) {
        $photos = is_string($schedule->pickup_photos) 
            ? json_decode($schedule->pickup_photos, true) 
            : $schedule->pickup_photos;

        if (is_array($photos)) {
            $schedule->pickup_photos = array_map(function($photo) {
                // If already full URL, return as is
                if (str_starts_with($photo, 'http://') || str_starts_with($photo, 'https://')) {
                    return $photo;
                }
                // Convert relative path to full URL
                return url(ltrim($photo, '/'));
            }, $photos);
        }
    }
    return $schedule;
});
```

---

## 📝 Implementation Steps

### 1. Update `history()` Method

```php
public function history(Request $request)
{
    $query = PickupSchedule::where('assigned_mitra_id', auth()->id())
        ->where('status', 'completed')
        ->orderBy('completed_at', 'desc');

    $schedules = $query->paginate($perPage);

    // 👇 ADD THIS CODE
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
        'data' => [
            'schedules' => $schedules->items(),
            'pagination' => [...],
        ],
    ]);
}
```

### 2. Update `complete()` Method

```php
public function complete(Request $request, $id)
{
    // ... save photos logic ...

    // Upload photos
    if ($request->hasFile('photos')) {
        $photos = [];
        foreach ($request->file('photos') as $photo) {
            $path = $photo->store("pickups/{$schedule->id}", 'public');
            $photos[] = "/storage/{$path}"; // Save relative path in DB
        }
        $schedule->pickup_photos = json_encode($photos);
        $schedule->save();
    }

    // 👇 CONVERT TO FULL URLs BEFORE RETURN
    $photosWithUrls = [];
    if (!empty($schedule->pickup_photos)) {
        $photos = json_decode($schedule->pickup_photos, true);
        foreach ($photos as $photo) {
            $photosWithUrls[] = url(ltrim($photo, '/'));
        }
    }

    return response()->json([
        'success' => true,
        'data' => [
            'schedule' => [
                'id' => $schedule->id,
                'pickup_photos' => $photosWithUrls, // 👈 Full URLs
            ],
        ],
    ]);
}
```

---

## 🧪 Testing

### Test 1: Check History API

```bash
TOKEN="your_token_here"

curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data.schedules[0].pickup_photos'
```

**Expected Output:**
```json
[
  "http://127.0.0.1:8000/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg"
]
```

**❌ Wrong Output:**
```json
[
  "/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg"
]
```

### Test 2: Verify Photo Accessible

```bash
# Copy photo URL from response above and test:
curl -I http://127.0.0.1:8000/storage/pickups/66/tIujXPKZ8PbvkKSB6njXUnrpcctHoFZ0cGLUgpCx.jpg
```

**Expected:** HTTP 200 OK

**If 404:** Run `php artisan storage:link`

---

## 📋 Checklist

- [ ] Update `history()` method
- [ ] Update `complete()` method
- [ ] Test with Postman/curl
- [ ] Verify photos return full URLs
- [ ] Run `php artisan storage:link` if needed
- [ ] Test in Flutter app
- [ ] Deploy to staging
- [ ] Test end-to-end

---

## 📁 Related Files

**Backend:**
- `app/Http/Controllers/Mitra/PickupScheduleController.php`
- `app/Models/PickupSchedule.php`

**Documentation:**
- `docs/BACKEND_PICKUP_PHOTOS_DISPLAY.md` (Full documentation)
- `docs/FLUTTER_PICKUP_PHOTOS_UPDATE.md` (Flutter changes)

---

## ⏱️ Estimated Time

- **Backend Update:** 30 minutes
- **Testing:** 15 minutes
- **Total:** 45 minutes

---

## 🚀 Priority

**HIGH** - Blocking feature (mitra cannot see proof of pickup)

---

## ✅ Summary

1. **Problem:** Foto tidak muncul karena backend return relative path
2. **Solution:** Convert relative path ke full URL sebelum return API
3. **Code:** Add `url(ltrim($photo, '/'))` di `history()` dan `complete()`
4. **Test:** Verify API return full URLs
5. **Done:** Flutter sudah ready untuk terima full URLs ✅

---

**Need Help?** Check full documentation in:
- `docs/BACKEND_PICKUP_PHOTOS_DISPLAY.md`
