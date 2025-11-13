# 🧪 Testing Backend Fix - Sistem Penjemputan Mitra

**Tanggal**: 13 November 2025  
**Status**: ✅ Backend Fixed - Ready for Flutter Testing

---

## 📋 Quick Summary

**Backend Status**: ✅ **FIXED & DEPLOYED**

Endpoint `GET /api/mitra/pickup-schedules/available` sekarang:
- ✅ Return 33 jadwal pending (verified)
- ✅ Support pagination `?per_page=20`
- ✅ Support filters optional (`waste_type`, `area`, `date`)
- ✅ Removed restrictive `work_area` filter

---

## 🧪 Manual Testing Steps

### Test 1: Verify Available Schedules Endpoint

#### Via curl:

```bash
# Login sebagai mitra (gunakan token dari Flutter app atau backend)
TOKEN="YOUR_MITRA_TOKEN_HERE"

# Get available schedules
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" | jq '.data.schedules | length'

# Expected output: 33 (or more)
```

#### Expected Response Structure:

```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 42,
        "user_id": 10,
        "user_name": "Aceng as",
        "user_phone": "1234567890",
        "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
        "schedule_day": "kamis",
        "waste_type_scheduled": "B3",
        "pickup_time_start": "06:00:00",
        "pickup_time_end": "08:00:00",
        "scheduled_pickup_at": "2025-11-13T06:00:00.000000Z",
        "waste_summary": "B3",
        "status": "pending",
        "assigned_mitra_id": null
      }
      // ... 32 more schedules
    ],
    "total": 33,
    "current_page": 1,
    "last_page": 2,
    "per_page": 20
  }
}
```

**✅ Verification Points**:
- [ ] `data.schedules` is array with 20-33 items
- [ ] `data.total` = 33 (or more)
- [ ] All `status` = "pending"
- [ ] All `assigned_mitra_id` = null
- [ ] Pagination info present (current_page, last_page, per_page)

---

### Test 2: Verify Pagination

```bash
# Page 1 (first 20 schedules)
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?per_page=20" \
  -H "Authorization: Bearer $TOKEN" | jq '.data | {total, current_page, last_page, count: (.schedules | length)}'

# Expected: 
# {
#   "total": 33,
#   "current_page": 1,
#   "last_page": 2,
#   "count": 20
# }

# Page 2 (remaining 13 schedules)
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?per_page=20&page=2" \
  -H "Authorization: Bearer $TOKEN" | jq '.data | {total, current_page, last_page, count: (.schedules | length)}'

# Expected:
# {
#   "total": 33,
#   "current_page": 2,
#   "last_page": 2,
#   "count": 13
# }
```

**✅ Verification Points**:
- [ ] Page 1 returns 20 schedules
- [ ] Page 2 returns 13 schedules (33 - 20)
- [ ] Total always 33
- [ ] last_page = 2

---

### Test 3: Verify Filters (Optional)

#### Filter by Waste Type:

```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?waste_type=B3" \
  -H "Authorization: Bearer $TOKEN" | jq '.data.schedules | length'

# Expected: Only schedules with waste_type "B3"
```

#### Filter by Area:

```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?area=Jakarta" \
  -H "Authorization: Bearer $TOKEN" | jq '.data.schedules | length'

# Expected: Only schedules in Jakarta area
```

#### Filter by Date:

```bash
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?date=2025-11-13" \
  -H "Authorization: Bearer $TOKEN" | jq '.data.schedules | length'

# Expected: Only schedules for Nov 13, 2025
```

**✅ Verification Points**:
- [ ] Filters reduce total count
- [ ] Filtered results match criteria
- [ ] Pagination still works with filters

---

## 📱 Flutter App Testing

### Prerequisites:

1. ✅ Backend fix deployed
2. ✅ Flutter app running: `flutter run`
3. ✅ Test credentials ready

### Test Credentials:

```
Mitra Account:
Email: driver.jakarta@gerobaks.com
Password: mitra123

End User Account:
Email: aceng@gmail.com
Password: Password123
```

### Test Scenario 1: View Available Schedules

**Steps**:
1. Open Flutter app
2. Login dengan mitra account
3. Dari dashboard, tap card **"Sistem Penjemputan Mitra"**
4. App akan navigate ke Mitra Pickup Home
5. Tab **"Tersedia"** akan terbuka otomatis

**Expected Results**:
- ✅ Tab "Tersedia" menampilkan list jadwal
- ✅ Minimal 20 jadwal muncul (page 1)
- ✅ Setiap card menampilkan:
  - User name & phone
  - Pickup address
  - Waste type & summary
  - Schedule day & time range
  - Status badge: "Menunggu Penjemputan"
- ✅ No error messages
- ✅ Loading indicator hilang setelah data loaded

**Debug Logs to Check**:
```
flutter: 🚛 Fetching available schedules: http://127.0.0.1:8000/api/mitra/pickup-schedules/available
flutter: ✅ Loaded 33 available schedules
```

**❌ If Failed - Check**:
- Token expired? (Re-login)
- Network connection?
- Backend running?
- Check Flutter console for error stack trace

---

### Test Scenario 2: Scroll & Pagination

**Steps**:
1. Di tab "Tersedia"
2. Scroll ke bawah list
3. App akan auto-load more schedules
4. Continue scrolling sampai habis

**Expected Results**:
- ✅ Auto-load next page (schedules 21-33)
- ✅ Total 33 jadwal dapat di-scroll
- ✅ No duplicate schedules
- ✅ Smooth scrolling, no jank

---

### Test Scenario 3: View Schedule Details

**Steps**:
1. Di tab "Tersedia"
2. Tap salah satu schedule card
3. Detail modal/page terbuka

**Expected Results**:
- ✅ Modal menampilkan full schedule details:
  - User info (name, phone, address)
  - Waste details (type, estimated weight)
  - Schedule time
  - Notes
- ✅ Button "Terima Jadwal" muncul
- ✅ Can close modal

---

### Test Scenario 4: Accept Schedule (Full Workflow)

**Steps**:
1. View schedule details
2. Tap button **"Terima Jadwal"**
3. Confirm dialog muncul
4. Tap "Ya, Terima"

**Expected Results**:
- ✅ Success message muncul
- ✅ Schedule hilang dari tab "Tersedia"
- ✅ Schedule muncul di tab "Aktif"
- ✅ Status berubah dari "pending" → "on_the_way"
- ✅ assigned_mitra_id terisi dengan mitra ID

**API Call**:
```
POST /api/mitra/pickup-schedules/{id}/accept
Response: {"success": true, "message": "Jadwal berhasil diterima"}
```

---

### Test Scenario 5: Complete Pickup Flow

**Steps**:
1. Di tab "Aktif", pilih schedule yang sudah di-accept
2. Tap "Mulai Perjalanan"
3. Tap "Sampai di Lokasi"
4. Upload 2 foto
5. Input berat sampah (Organik, Anorganik, B3)
6. Tap "Selesaikan Penjemputan"

**Expected Results**:
- ✅ Status updates: on_the_way → arrived → completed
- ✅ Photos uploaded
- ✅ Weights saved
- ✅ Schedule moves to "Riwayat" tab
- ✅ Points added to user account
- ✅ Notification sent to user

---

## 🔍 Debugging Tips

### If Schedules Not Showing:

1. **Check Flutter Console**:
   ```
   flutter: ❌ Error fetching available schedules: [ERROR_MESSAGE]
   ```

2. **Check API Response**:
   - Add breakpoint in `MitraApiService.getAvailableSchedules()`
   - Check `response.statusCode` and `response.body`

3. **Check Token**:
   ```dart
   final token = await _localStorage.getToken();
   print('Token: $token');
   ```

4. **Test API Directly**:
   ```bash
   # Use token from Flutter app
   curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
     -H "Authorization: Bearer YOUR_TOKEN" | jq '.'
   ```

### Common Issues:

| Issue | Cause | Solution |
|-------|-------|----------|
| Empty list | Token expired | Re-login |
| 401 Unauthorized | Token invalid | Clear app data, login again |
| No pagination | Backend issue | Check backend logs |
| Duplicate items | Pagination bug | Check page tracking in Flutter |
| Can't accept | Permission issue | Verify mitra role |

---

## ✅ Success Criteria

### Backend:
- [x] Endpoint returns 200 OK
- [x] Response has 33 schedules
- [x] All schedules status = "pending"
- [x] Pagination working
- [x] Filters working (optional)

### Flutter:
- [ ] App displays 33 schedules in "Tersedia" tab
- [ ] Pagination works (can scroll all 33)
- [ ] Can view schedule details
- [ ] Can accept schedule
- [ ] Schedule moves to "Aktif" after accept
- [ ] Can complete full pickup workflow
- [ ] Schedule moves to "Riwayat" after complete

---

## 📊 Test Results Template

Copy & paste ini untuk report hasil testing:

```markdown
## Test Results - [DATE]

**Tester**: [YOUR_NAME]
**Environment**: [Local/Staging/Production]

### Backend Tests:
- [ ] Available schedules endpoint returns 33 items: ✅/❌
- [ ] Pagination working: ✅/❌
- [ ] Filters working: ✅/❌
- [ ] Response structure correct: ✅/❌

### Flutter Tests:
- [ ] Schedules display in "Tersedia" tab: ✅/❌
- [ ] Count matches backend (33): ✅/❌
- [ ] Pagination/scrolling works: ✅/❌
- [ ] Schedule details view works: ✅/❌
- [ ] Accept schedule works: ✅/❌
- [ ] Full pickup flow works: ✅/❌

### Issues Found:
1. [Issue description]
2. [Issue description]

### Screenshots:
- [ ] "Tersedia" tab with schedules
- [ ] Schedule details modal
- [ ] "Aktif" tab after accept
- [ ] "Riwayat" tab after complete

### Notes:
[Any additional observations]
```

---

## 🎯 Next Steps

1. ✅ **Backend**: Fix deployed and verified (33 schedules)
2. 🔄 **Flutter**: Run testing scenarios above
3. 📸 **Document**: Take screenshots of working features
4. ✅ **Verify**: Complete end-to-end pickup workflow
5. 🚀 **Deploy**: If all tests pass

---

**Status**: 🟢 Ready for Flutter Testing  
**Last Updated**: November 13, 2025  
**Contact**: [Your Team Contact]
