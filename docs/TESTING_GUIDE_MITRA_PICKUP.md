# 🧪 Testing Guide - Mitra Pickup System

## 📋 Pre-Testing Setup

### 1. Backend Preparation

```bash
# Start backend server
cd backend
php artisan serve

# Start queue worker (for notifications)
php artisan queue:work

# Verify storage linked
php artisan storage:link

# Check database
php artisan migrate:status
```

### 2. Test User Credentials

#### Mitra User
```
Email: driver.jakarta@gerobaks.com
Password: mitra123
Role: mitra
ID: 5
Name: Ahmad Kurniawan
```

#### End User (untuk create schedule)
```
Email: aceng@gmail.com
Password: Password123
Role: end_user
ID: 10
Name: Aceng as
```

### 3. Create Test Schedule (as End User)

1. Login sebagai `aceng@gmail.com`
2. Buat jadwal pengambilan baru:
   - Waste type: B3
   - Day: Kamis
   - Time: 06:00 - 08:00
3. Jadwal akan masuk status `pending`

---

## 🚀 Test Flow

### Test 1: Login as Mitra ✅

**Steps:**
1. Buka app
2. Logout jika sudah login
3. Login dengan: `driver.jakarta@gerobaks.com` / `mitra123`

**Expected Result:**
- ✅ Login successful
- ✅ Token saved
- ✅ Role detected: `mitra`
- ✅ Navigate to `/mitra-dashboard-new`
- ✅ Dashboard mitra displayed

**How to Verify:**
- Check console log: `✅ Navigating to MITRA dashboard`
- Dashboard shows mitra stats

---

### Test 2: Navigate to Mitra Pickup ✅

**Steps:**
1. Dari dashboard mitra
2. Tap menu/button ke Mitra Pickup (if added)
3. OR navigate manual: `Navigator.pushNamed(context, '/mitra-pickup')`

**Expected Result:**
- ✅ Mitra Home Page displayed
- ✅ 3 tabs visible: Tersedia, Aktif, Riwayat
- ✅ Default tab: Tersedia (Available Schedules)

**How to Verify:**
- Bottom navigation shows 3 tabs
- First tab is active (green)

---

### Test 3: View Available Schedules ✅

**Steps:**
1. Di tab "Tersedia"
2. App automatically loads schedules

**Expected Result:**
- ✅ Loading indicator shown
- ✅ API call: GET `/api/mitra/pickup-schedules/available`
- ✅ Console log: `📋 Fetching available schedules`
- ✅ List of pending schedules displayed
- ✅ Each card shows:
  - User name & phone
  - Pickup address
  - Schedule time
  - Waste summary
  - "Terima Jadwal" button

**Backend Response Expected:**
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 42,
        "user_name": "Aceng as",
        "user_phone": "1234567890",
        "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
        "schedule_day": "kamis",
        "pickup_time_start": "06:00",
        "pickup_time_end": "08:00",
        "waste_summary": "B3",
        "status": "pending"
      }
    ]
  }
}
```

**How to Verify:**
- Schedule card displayed
- User info correct
- Address shown
- Status badge: "Pending"

---

### Test 4: Filter Schedules 🔧

**Steps:**
1. Tap filter icon (top right)
2. Select jenis sampah: "B3"
3. Tap "Terapkan"

**Expected Result:**
- ✅ API called with query: `?waste_type=B3`
- ✅ Only B3 schedules shown
- ✅ Filter badge appears on filter icon (red dot)

**How to Verify:**
- Console: `📋 Fetching available schedules: ...?waste_type=B3`
- Filtered list displayed

---

### Test 5: View Schedule Detail ✅

**Steps:**
1. Tap on a schedule card
2. Navigate to detail page

**Expected Result:**
- ✅ API call: GET `/api/mitra/pickup-schedules/{id}`
- ✅ Detail page shows:
  - Status badge (top)
  - User info card (name, phone, profile)
  - Phone & WhatsApp buttons
  - Location card (address + coordinates)
  - "Buka di Google Maps" button
  - Schedule info (day, time)
  - Waste info (type, summary)
  - "Terima Jadwal" button (if pending)

**How to Verify:**
- All sections visible
- Buttons functional
- Data correct

---

### Test 6: Accept Schedule ⚡ **CRITICAL**

**Steps:**
1. From detail page
2. Tap "Terima Jadwal"
3. Confirm dialog

**Expected Result:**
- ✅ Confirmation dialog shown
- ✅ API call: POST `/api/mitra/pickup-schedules/{id}/accept`
- ✅ Loading indicator during request
- ✅ Success snackbar: "✅ Jadwal berhasil diterima"
- ✅ Navigate back to list
- ✅ Schedule removed from "Tersedia" list

**Backend Actions:**
- ✅ Status changed: `pending` → `on_progress`
- ✅ `assigned_mitra_id` = 5 (Ahmad Kurniawan)
- ✅ `assigned_at` timestamp recorded
- ✅ **Notification sent to user**: "Mitra Ahmad Kurniawan accepted your schedule!"

**How to Verify Backend:**
```sql
-- Check schedule
SELECT id, status, assigned_mitra_id, assigned_at 
FROM pickup_schedules 
WHERE id = 42;
-- Should show: status=on_progress, assigned_mitra_id=5

-- Check notification
SELECT * FROM notifications 
WHERE notifiable_id = 10 
ORDER BY created_at DESC 
LIMIT 1;
-- Should show: MitraAssigned notification
```

**How to Verify Flutter:**
- Console: `✅ Schedule accepted successfully`
- Snackbar shown
- Back to list automatically
- Schedule not in "Tersedia" anymore

---

### Test 7: View Active Schedules ✅

**Steps:**
1. Switch to "Aktif" tab
2. App loads active schedules

**Expected Result:**
- ✅ API call: GET `/api/mitra/pickup-schedules/my-active`
- ✅ Accepted schedule displayed
- ✅ Card shows:
  - User info
  - Address
  - Schedule time
  - Waste summary
  - Action buttons:
    - "Navigasi" (Google Maps)
    - "Sampai" (Confirm arrival)
    - "Selesaikan" (Complete pickup)
    - "Batalkan" (Cancel)

**How to Verify:**
- Schedule ID 42 shown
- Status: "Sedang Berlangsung"
- All buttons visible

---

### Test 8: Navigate to Location 🗺️

**Steps:**
1. From active schedule
2. Tap "Navigasi"

**Expected Result:**
- ✅ Google Maps app opens
- ✅ Location pinned: 37.785834, -122.406417
- ✅ Navigation route shown

**How to Verify:**
- Maps app opened
- Location correct

---

### Test 9: Call User 📞

**Steps:**
1. From active schedule
2. Tap phone icon

**Expected Result:**
- ✅ Phone dialer opens
- ✅ Number: 1234567890

---

### Test 10: Confirm Arrival (Optional) 🚗

**Steps:**
1. Tap "Sampai" button

**Expected Result:**
- ✅ API call: POST `/api/mitra/pickup-schedules/{id}/arrive`
- ✅ Request body: `{latitude: x, longitude: y}`
- ✅ Success message
- ✅ `picked_up_at` timestamp recorded

**How to Verify:**
```sql
SELECT picked_up_at FROM pickup_schedules WHERE id = 42;
-- Should show timestamp
```

---

### Test 11: Complete Pickup ⚡ **CRITICAL**

**Steps:**
1. Tap "Selesaikan" button
2. Navigate to completion form
3. Upload photos:
   - Tap "Tambah Foto"
   - Choose "Ambil Foto dari Kamera" or "Pilih dari Galeri"
   - Select/capture 2-3 photos
4. Input weights:
   - Organik: 3.5
   - B3: 1.2
   - (leave others empty)
5. Add notes: "Sampah sudah dipilah"
6. Tap "Selesaikan Pengambilan"
7. Confirm dialog

**Expected Result:**
- ✅ Photos uploaded successfully
- ✅ Form validation passed
- ✅ Confirmation dialog shows:
  - Total weight: 4.7 kg
  - Photo count: 2
- ✅ API call: POST `/api/mitra/pickup-schedules/{id}/complete`
- ✅ Request type: `multipart/form-data`
- ✅ Request contains:
  - `actual_weights[Organik]`: 3.5
  - `actual_weights[B3]`: 1.2
  - `photos[]`: [file1, file2]
  - `notes`: "Sampah sudah dipilah"
- ✅ Success snackbar: "✅ Pengambilan berhasil diselesaikan!"
- ✅ Navigate back to active schedules
- ✅ Schedule removed from active list

**Backend Actions:**
- ✅ Photos saved to: `storage/app/public/pickups/42/photo1.jpg`, `photo2.jpg`
- ✅ Total weight calculated: 4.7 kg
- ✅ Points calculated: 47 points (4.7 × 10)
- ✅ **User points incremented: +47**
- ✅ Status changed: `on_progress` → `completed`
- ✅ `completed_at` timestamp recorded
- ✅ **Notification sent to user**: "Pickup completed! +47 points"

**How to Verify Backend:**
```sql
-- Check schedule completion
SELECT id, status, total_weight, completed_at 
FROM pickup_schedules 
WHERE id = 42;
-- Should show: status=completed, total_weight=4.7

-- Check user points
SELECT points FROM users WHERE id = 10;
-- Should be incremented by 47

-- Check photos
SELECT pickup_photos FROM pickup_schedules WHERE id = 42;
-- Should show JSON array of photo URLs

-- Check notification
SELECT * FROM notifications 
WHERE notifiable_id = 10 
AND type = 'App\\Notifications\\PickupCompleted'
ORDER BY created_at DESC 
LIMIT 1;
-- Should show: PickupCompleted notification with points data
```

**How to Verify Flutter:**
- Console: `✅ Completion successful`
- Snackbar shown
- Photos visible in form before submit
- No errors in console

---

### Test 12: View History ✅

**Steps:**
1. Switch to "Riwayat" tab
2. App loads history

**Expected Result:**
- ✅ API call: GET `/api/mitra/pickup-schedules/history`
- ✅ Completed schedule displayed
- ✅ Card shows:
  - Completion date & time
  - User name & address
  - Total weight: 4.7 kg
  - Points earned: 47 pts
  - Photo count: 2 foto
- ✅ Scroll down loads more (pagination)

**How to Verify:**
- Schedule ID 42 shown
- Date is today
- Weight & points correct

---

### Test 13: Filter History by Date 📅

**Steps:**
1. Tap filter icon
2. Select date range: today - today
3. Tap "Terapkan"

**Expected Result:**
- ✅ API called with: `?date_from=2025-11-13&date_to=2025-11-13`
- ✅ Only today's completions shown

---

### Test 14: Pull to Refresh ♻️

**Steps:**
1. On any list (Available, Active, History)
2. Pull down to refresh

**Expected Result:**
- ✅ Refresh indicator shown
- ✅ API called again
- ✅ List updated
- ✅ Indicator hidden

---

### Test 15: Cancel Schedule ⚠️

**Steps:**
1. Accept another schedule
2. Go to "Aktif" tab
3. Tap "Batalkan"
4. Enter reason: "Tidak bisa hadir"
5. Confirm

**Expected Result:**
- ✅ Reason dialog shown
- ✅ API call: POST `/api/mitra/pickup-schedules/{id}/cancel`
- ✅ Request body: `{reason: "Tidak bisa hadir"}`
- ✅ Success message
- ✅ Schedule removed from active
- ✅ Status changed: `on_progress` → `pending` (available for other mitras)
- ✅ **Notification sent to user**: "Schedule cancelled by mitra"

**How to Verify Backend:**
```sql
SELECT status, assigned_mitra_id, cancellation_reason 
FROM pickup_schedules 
WHERE id = X;
-- Should show: status=pending, assigned_mitra_id=NULL
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Empty Available Schedules

**Symptoms:** "Tidak ada jadwal tersedia"

**Checks:**
- [ ] Backend has pending schedules?
  ```sql
  SELECT COUNT(*) FROM pickup_schedules WHERE status = 'pending';
  ```
- [ ] Logged in as mitra (not end_user)?
- [ ] API base URL correct?
- [ ] Network connection?

**Solution:** Create test schedule as end user first.

---

### Issue 2: "Token tidak ditemukan"

**Symptoms:** Error on API calls

**Checks:**
- [ ] User logged in?
- [ ] Token saved after login?
- [ ] Check LocalStorage:
  ```dart
  final token = await localStorage.getToken();
  print('Token: $token');
  ```

**Solution:** Re-login

---

### Issue 3: Photos Not Uploading

**Symptoms:** Complete pickup fails

**Checks:**
- [ ] Camera permission granted?
- [ ] Gallery permission granted?
- [ ] Photos selected successfully?
- [ ] Check file size (<10MB per photo)
- [ ] Backend storage writable?

**Solution:** 
```bash
# Backend
chmod -R 775 storage/app/public/pickups
php artisan storage:link
```

---

### Issue 4: 401 Unauthorized

**Symptoms:** API returns 401

**Checks:**
- [ ] Token in request headers?
- [ ] Token not expired?
- [ ] User has mitra role?

**Solution:** Check backend logs, re-login

---

### Issue 5: Notification Not Received

**Symptoms:** User doesn't get notification

**Checks:**
- [ ] Queue worker running?
  ```bash
  php artisan queue:work
  ```
- [ ] Check notifications table:
  ```sql
  SELECT * FROM notifications WHERE notifiable_id = X;
  ```

**Solution:** Start queue worker

---

## 📊 Test Results Checklist

### Pre-Test
- [ ] Backend server running
- [ ] Queue worker running
- [ ] Storage linked
- [ ] Database migrated
- [ ] Test users exist

### Core Functions
- [ ] Login as mitra
- [ ] View available schedules
- [ ] Filter schedules
- [ ] View schedule detail
- [ ] Accept schedule
- [ ] View active schedules
- [ ] Navigate to location (Maps)
- [ ] Call user (Phone)
- [ ] Complete pickup with photos
- [ ] View history
- [ ] Filter history

### Backend Verification
- [ ] Schedule status changed correctly
- [ ] Mitra assigned correctly
- [ ] User received MitraAssigned notification
- [ ] Photos uploaded to storage
- [ ] Total weight calculated correctly
- [ ] User points incremented
- [ ] User received PickupCompleted notification
- [ ] Schedule appears in history

### UI/UX
- [ ] All screens display correctly
- [ ] No UI glitches
- [ ] Loading indicators work
- [ ] Error messages clear
- [ ] Snackbars appear
- [ ] Pull-to-refresh works
- [ ] Pagination works
- [ ] Back navigation works

### Edge Cases
- [ ] Empty lists handled
- [ ] Network errors handled
- [ ] Invalid input rejected
- [ ] Race condition prevented (2 mitras can't accept same schedule)
- [ ] Cancel schedule works

---

## 🎯 Success Criteria

**Integration is successful if:**

✅ All 15 tests pass  
✅ Photos upload correctly  
✅ Points increment automatically  
✅ Notifications sent to users  
✅ No crash or freeze  
✅ Data syncs with backend  
✅ UI responsive and smooth  

---

## 📞 Support

**If tests fail:**

1. Check console logs (both Flutter & Backend)
2. Check database directly
3. Test endpoints with Postman
4. Review backend test results
5. Check permissions (camera, storage)

**Backend logs:**
```bash
tail -f storage/logs/laravel.log
```

**Database check:**
```sql
-- Quick check
SELECT * FROM pickup_schedules WHERE id = X;
SELECT * FROM notifications WHERE notifiable_id = X;
SELECT points FROM users WHERE id = X;
```

---

**Testing Date:** November 13, 2025  
**Tester:** _____________  
**Result:** ⬜ PASS / ⬜ FAIL  
**Notes:** _____________

**Happy Testing! 🚀**
