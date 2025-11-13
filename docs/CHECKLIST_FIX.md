# ✅ CHECKLIST FIX - Backend Team

**Bug:** Available schedules hanya return 1 user  
**Priority:** 🔴 CRITICAL  
**Time:** 15-30 menit

---

## 📋 PRE-FIX CHECKLIST

- [ ] Baca **START_HERE_BACKEND.md** (3 min)
- [ ] Baca **QUICK_FIX_BACKEND.md** (5 min)
- [ ] Siapkan environment (Laravel, database, tinker)
- [ ] Backup code sebelum edit (git commit)

---

## 🔧 FIX CHECKLIST

### Step 1: Diagnostics (5 min)

- [ ] Jalankan `php artisan tinker`
- [ ] Run query base tanpa filter:
  ```php
  $all = PickupSchedule::where('status', 'pending')
      ->whereNull('assigned_mitra_id')
      ->where('is_scheduled_active', true)
      ->get();
  ```
- [ ] Check total count: `echo $all->count();`
- [ ] Check user IDs: `echo $all->pluck('user_id')->unique()->implode(', ');`
- [ ] Verify user_id 10 (Aceng) ada di hasil: `$all->pluck('user_id')->contains(10)`

**Expected:** Total ~33, User IDs include 2, 10, ...

**Jika user 10 ADA:** Problem di controller filter ✅  
**Jika user 10 TIDAK ADA:** Problem di database (cek is_scheduled_active)

---

### Step 2: Locate Code (2 min)

- [ ] Buka file: `app/Http/Controllers/Api/MitraPickupScheduleController.php`
- [ ] Cari method: `getAvailableSchedules(Request $request)`
- [ ] Identifikasi baris problematic:
  ```php
  ->where('work_area', $mitra->work_area)  // ← Cari baris ini
  ```

---

### Step 3: Fix Code (5 min)

**Option A: Remove Filter (Recommended)**

- [ ] HAPUS baris: `->where('work_area', $mitra->work_area)`
- [ ] Code seharusnya jadi:
  ```php
  public function getAvailableSchedules(Request $request)
  {
      $schedules = PickupSchedule::with(['user', 'wasteType'])
          ->where('status', 'pending')
          ->whereNull('assigned_mitra_id')
          ->where('is_scheduled_active', true)
          ->whereNull('deleted_at')
          ->orderBy('created_at', 'desc')
          ->paginate(20);
      
      return response()->json([
          'success' => true,
          'data' => ['schedules' => $schedules->items()]
      ]);
  }
  ```

**Option B: Make Filter Optional**

- [ ] Edit query jadi:
  ```php
  $query = PickupSchedule::with(['user', 'wasteType'])
      ->where('status', 'pending')
      ->whereNull('assigned_mitra_id')
      ->where('is_scheduled_active', true)
      ->whereNull('deleted_at');
  
  // Optional filter
  if ($request->input('filter_by_area') === 'true' && !empty($mitra->work_area)) {
      $query->where('work_area', $mitra->work_area);
  }
  
  $schedules = $query->orderBy('created_at', 'desc')->paginate(20);
  ```

- [ ] Save file
- [ ] Commit changes: `git add . && git commit -m "Fix: Remove work_area filter from available schedules"`

---

### Step 4: Test API (5 min)

**Test 1: Login Mitra**

- [ ] Run command:
  ```bash
  TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
    -H "Content-Type: application/json" \
    -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}' \
    | jq -r '.data.token')
  ```
- [ ] Verify token: `echo $TOKEN`
- [ ] Token should be format: `68|...` (number + pipe + hash)

**Test 2: Get Available Schedules**

- [ ] Run command:
  ```bash
  curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Accept: application/json" \
    | jq .
  ```
- [ ] Response status: 200 OK ✅
- [ ] Response has key: `success: true` ✅
- [ ] Response has key: `data.schedules` ✅

**Test 3: Verify Diverse Users**

- [ ] Run command:
  ```bash
  curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
    -H "Authorization: Bearer $TOKEN" \
    | jq '[.data.schedules[].user_id] | unique'
  ```
- [ ] Should return array like: `[2, 10, ...]` ✅
- [ ] Should NOT return only: `[2]` ❌

**Test 4: Verify Aceng's Schedules**

- [ ] Run command:
  ```bash
  curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
    -H "Authorization: Bearer $TOKEN" \
    | jq '.data.schedules[] | select(.user_id == 10) | {id, user_name, schedule_day}'
  ```
- [ ] Should return 4 schedules from "Aceng as" ✅
- [ ] IDs should include: 42, 46, 48, 49 ✅

**Test 5: Check Pagination**

- [ ] Run command:
  ```bash
  curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
    -H "Authorization: Bearer $TOKEN" \
    | jq '.data.pagination'
  ```
- [ ] Total should be ~33 ✅
- [ ] Per page should be 20 ✅
- [ ] Current page should be 1 ✅

---

### Step 5: Verify Database (Optional - 3 min)

- [ ] Run SQL query:
  ```sql
  SELECT 
      user_id,
      users.name,
      COUNT(*) as schedule_count
  FROM pickup_schedules
  LEFT JOIN users ON users.id = pickup_schedules.user_id
  WHERE status = 'pending'
    AND assigned_mitra_id IS NULL
    AND deleted_at IS NULL
    AND is_scheduled_active = 1
  GROUP BY user_id, users.name
  ORDER BY user_id;
  ```
- [ ] User Aceng (ID 10) should have 4 schedules ✅
- [ ] User Daffa (ID 2) should have multiple schedules ✅

---

## 📊 POST-FIX VERIFICATION

### Backend Checklist:

- [ ] All tests passing ✅
- [ ] Diverse user_ids in response ✅
- [ ] User Aceng (ID 10) visible ✅
- [ ] Pagination working ✅
- [ ] Response format correct ✅
- [ ] No errors in logs ✅
- [ ] Code committed to git ✅

### Notify Frontend:

- [ ] Send message: "✅ Available schedules bug fixed"
- [ ] Share test token for verification
- [ ] Coordinate integration testing time
- [ ] Monitor logs during frontend test

---

## 🧪 INTEGRATION TEST (Frontend)

Wait for frontend team to:

- [ ] Hot reload Flutter app
- [ ] Login as mitra: `driver.jakarta@gerobaks.com` / `password123`
- [ ] Navigate to "Sistem Penjemputan Mitra"
- [ ] Tab "Tersedia" shows berbagai user (not just 1 user)
- [ ] Verify Aceng's schedules visible
- [ ] Test pagination (page 1, 2, 3...)
- [ ] Test accept schedule workflow
- [ ] Test complete end-to-end flow

---

## 🚀 PRODUCTION READY

Final checklist before production:

- [ ] Backend tests passing ✅
- [ ] Frontend tests passing ✅
- [ ] Integration tests passing ✅
- [ ] No errors in logs ✅
- [ ] Performance acceptable ✅
- [ ] Code reviewed ✅
- [ ] Documented ✅
- [ ] Deployed to staging ✅
- [ ] Staging tested ✅
- [ ] Ready for production 🎉

---

## 📞 SUPPORT

**Jika ada masalah:**

1. **Tinker fails:** Check Laravel connection, database access
2. **Token empty:** Check login credentials, API response
3. **Still returns only 1 user:** Check if filter still exists in code
4. **404 error:** Check routes, endpoint URL
5. **500 error:** Check Laravel logs: `tail -f storage/logs/laravel.log`

**Documentation:**
- Troubleshooting lengkap: **CRITICAL_BACKEND_ISSUE.md**
- FAQ: **QUICK_FIX_BACKEND.md**
- Full guide: **LAPORAN_BACKEND_URGENT.md**

---

## ⏰ TIME TRACKING

Expected time per step:

```
[ ] Pre-fix checklist:     8 min
[ ] Step 1 Diagnostics:    5 min
[ ] Step 2 Locate:         2 min
[ ] Step 3 Fix:            5 min
[ ] Step 4 Test:           5 min
[ ] Step 5 Verify:         3 min
[ ] Post-fix:              2 min
─────────────────────────────────
    TOTAL:                30 min
```

Actual time: _____ min

---

## ✅ SIGN OFF

**Backend Developer:**
- Name: _________________
- Date: _________________
- Time completed: _______
- All tests passed: [ ] YES [ ] NO
- Ready for frontend: [ ] YES [ ] NO

**Frontend Developer:**
- Name: _________________
- Date: _________________
- Integration test: [ ] PASS [ ] FAIL
- Production ready: [ ] YES [ ] NO

---

## 🎯 SUCCESS CRITERIA

Fix dianggap sukses jika:

✅ API returns berbagai user_id (not just 1)  
✅ User Aceng (ID 10) visible di mitra view  
✅ Total ~33 schedules available  
✅ Pagination working correctly  
✅ No errors in logs  
✅ Frontend integration test pass  
✅ Complete workflow working  

---

**STATUS:** [ ] NOT STARTED  [ ] IN PROGRESS  [ ] ✅ COMPLETED

**PRIORITY:** 🔴 CRITICAL BLOCKER

**NEXT STEP:** Baca **QUICK_FIX_BACKEND.md** dan mulai Step 1!

---

*Checklist v1.0 - 13 November 2025*
