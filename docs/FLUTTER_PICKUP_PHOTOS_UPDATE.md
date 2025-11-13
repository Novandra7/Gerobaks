# Flutter Update: Pickup Photos Display

## 🔍 Problem

**Issue:** Bukti foto tidak muncul di halaman history mitra

**Root Cause:** Flutter menggunakan `Image.asset()` yang hanya untuk local assets, tetapi foto berasal dari server (network).

---

## ✅ Solution Implemented

### Change: `Image.asset()` → `Image.network()`

**File:** `lib/ui/pages/mitra/history_page.dart`

---

## 📝 Changes Made

### 1. Grid View Image (Line ~920)

**Before:** ❌
```dart
Image.asset(
  photoPath,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 40,
      ),
    );
  },
),
```

**After:** ✅
```dart
Image.network(
  photoPath,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    print('❌ Error loading image: $photoPath');
    print('❌ Error: $error');
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 4),
          Text(
            'Gagal memuat foto',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  },
),
```

**Benefits:**
- ✅ Added loading indicator
- ✅ Better error handling with debug logs
- ✅ User-friendly error message

---

### 2. Fullscreen Image Dialog (Line ~615)

**Before:** ❌
```dart
child: Image.asset(
  imagePath,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 60, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'Gambar tidak dapat dimuat',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  },
),
```

**After:** ✅
```dart
child: Image.network(
  imagePath,
  fit: BoxFit.contain,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    print('❌ Error loading fullscreen image: $imagePath');
    print('❌ Error: $error');
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 60, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'Gambar tidak dapat dimuat',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  },
),
```

**Benefits:**
- ✅ Loading indicator while image loads
- ✅ Debug logs for troubleshooting
- ✅ Better UX with progress indicator

---

## 🔄 Data Flow

### Current Flow (After Fix)

```
1. Backend Upload Photo
   ↓
2. Backend Save: storage/app/public/pickups/66/xxx.jpg
   ↓
3. Backend Return Full URL: "http://127.0.0.1:8000/storage/pickups/66/xxx.jpg"
   ↓
4. Flutter Parse: List<String> pickupPhotos
   ↓
5. Flutter Display: Image.network(pickupPhotos[0]) ✅
   ↓
6. User Sees Photo! 🎉
```

---

## 🧪 Testing

### Test Scenario 1: View History with Photos

**Steps:**
1. Login as mitra
2. Navigate to History tab
3. Select completed pickup with photos
4. Verify photos display in grid
5. Tap photo to view fullscreen

**Expected Result:**
- ✅ Photos load with progress indicator
- ✅ Photos display correctly in grid
- ✅ Fullscreen view works
- ✅ Zoom and pan works in fullscreen

### Test Scenario 2: No Photos

**Steps:**
1. View completed pickup without photos
2. Verify "Tidak ada foto" message

**Expected Result:**
- ✅ No error
- ✅ Empty state message displayed

### Test Scenario 3: Network Error

**Steps:**
1. Turn off Wi-Fi/Data
2. View history with photos
3. Verify error handling

**Expected Result:**
- ✅ Error icon displayed
- ✅ "Gagal memuat foto" message
- ✅ No app crash

### Test Scenario 4: Invalid URL

**Steps:**
1. Backend returns invalid URL
2. View history
3. Check debug console

**Expected Result:**
- ✅ Error logged: `❌ Error loading image: ...`
- ✅ Error icon displayed
- ✅ App continues working

---

## 🐛 Debug Logs

### Success Case
```
✅ Loaded 1 history items
📸 Loading photo: http://127.0.0.1:8000/storage/pickups/66/xxx.jpg
✅ Photo loaded successfully
```

### Error Case
```
❌ Error loading image: http://127.0.0.1:8000/storage/pickups/66/invalid.jpg
❌ Error: NetworkImageLoadException: HTTP request failed, statusCode: 404
```

---

## 📋 Checklist

### Flutter Changes ✅ COMPLETE

- [x] Update grid view image (line ~920)
  - [x] Change `Image.asset()` to `Image.network()`
  - [x] Add `loadingBuilder` for progress indicator
  - [x] Add debug logs in `errorBuilder`
  - [x] Add user-friendly error message

- [x] Update fullscreen dialog (line ~615)
  - [x] Change `Image.asset()` to `Image.network()`
  - [x] Add `loadingBuilder` with white progress indicator
  - [x] Add debug logs in `errorBuilder`
  - [x] Keep existing error UI

- [x] Test compilation
  - [x] No errors
  - [x] No warnings

### Backend Requirements (From BACKEND_PICKUP_PHOTOS_DISPLAY.md)

- [ ] Update API to return full URLs
- [ ] Test with Postman
- [ ] Verify symlink exists
- [ ] Test photo accessibility

### End-to-End Testing

- [ ] Complete pickup and upload photo
- [ ] Verify photo appears in history
- [ ] Test fullscreen view
- [ ] Test zoom/pan in fullscreen
- [ ] Test error handling (no network)

---

## 🔍 How to Verify Fix

### Step 1: Run Flutter App
```bash
cd /Users/ajiali/Development/projects/Gerobaks
flutter run
```

### Step 2: Check Backend Returns Full URLs

**Option A: Use curl**
```bash
TOKEN="your_token_here"

curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/history?page=1&per_page=1" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data.schedules[0].pickup_photos'
```

**Expected:**
```json
[
  "http://127.0.0.1:8000/storage/pickups/66/xxx.jpg"
]
```

**Option B: Check Flutter Debug Console**
```
flutter: ✅ Loaded 1 history items
flutter: 📸 Photo URL: http://127.0.0.1:8000/storage/pickups/66/xxx.jpg
```

### Step 3: Verify Photo Loads

**In Flutter App:**
1. Go to History tab
2. Select completed pickup
3. Check if photos display (should see loading spinner then photo)
4. If error, check debug console for error message

---

## 🚨 Common Issues

### Issue 1: Photos Still Not Showing

**Symptom:** Empty grid or broken image icon

**Debug:**
```
Check Flutter console:
❌ Error loading image: /storage/pickups/66/xxx.jpg
❌ Error: Unable to load asset: /storage/pickups/66/xxx.jpg
```

**Root Cause:** Backend still returning relative path

**Solution:** Backend needs to implement full URL conversion (see BACKEND_PICKUP_PHOTOS_DISPLAY.md)

---

### Issue 2: 404 Not Found

**Symptom:** Photos show error icon

**Debug:**
```
❌ Error loading image: http://127.0.0.1:8000/storage/pickups/66/xxx.jpg
❌ Error: NetworkImageLoadException: HTTP request failed, statusCode: 404
```

**Root Cause:** Symlink not created or file doesn't exist

**Solution:**
```bash
# On backend server
php artisan storage:link
```

---

### Issue 3: Slow Loading

**Symptom:** Photos take long to load

**Possible Causes:**
- Large image file size
- Slow network connection
- Server performance issue

**Solution:**
- Backend: Resize images on upload
- Backend: Optimize image compression
- Flutter: Already shows loading indicator ✅

---

### Issue 4: Mixed Content (HTTP on HTTPS)

**Symptom:** Photos don't load on production (HTTPS app)

**Debug:**
```
Mixed Content: The page at 'https://app.gerobaks.com' was loaded over HTTPS, 
but requested an insecure image 'http://api.gerobaks.com/storage/...'.
```

**Solution:**
```bash
# Backend .env
APP_URL=https://api.gerobaks.com
```

---

## 📸 Screenshots Expected

### History Page
```
┌─────────────────────────────────┐
│ 📅 13 Nov 2025, 14:03          │
│                                 │
│ 📍 1-99 Stockton St            │
│ 👤 Test User                   │
│                                 │
│ 📦 BERAT SAMPAH                 │
│ • Campuran: 1.0 kg (10 pts)    │
│ • Organik: 1.0 kg (10 pts)     │
│ • Anorganik: 1.0 kg (10 pts)   │
│ Total: 3.0 kg (30 pts)         │
│                                 │
│ 📸 BUKTI FOTO                   │
│ ┌────────┐ ┌────────┐          │
│ │ Photo1 │ │ Photo2 │          │ ← Shows actual photos ✅
│ │  🔍    │ │  🔍    │          │
│ └────────┘ └────────┘          │
└─────────────────────────────────┘
```

### Fullscreen View
```
┌─────────────────────────────────┐
│                            ✕    │ ← Close button
│                                 │
│        [PHOTO ZOOMED]          │ ← Pinch to zoom, drag to pan
│                                 │
└─────────────────────────────────┘
```

---

## ✅ Summary

### Problem
- Bukti foto tidak muncul di history
- Flutter menggunakan `Image.asset()` untuk network images

### Solution
- Changed `Image.asset()` → `Image.network()`
- Added loading indicators
- Added debug logs for troubleshooting
- Better error handling

### Status
- ✅ Flutter code updated
- ✅ Compilation successful
- ⏳ Waiting for backend to return full URLs
- ⏳ End-to-end testing pending

### Next Steps
1. Backend implement full URL conversion
2. Test API endpoints
3. Deploy backend changes
4. Test in Flutter app
5. Verify photos display correctly

---

**Priority:** HIGH (Blocking feature)

**Estimated Testing Time:** 1 hour

**Status:** Flutter Changes Complete ✅ | Backend Pending ⏳
