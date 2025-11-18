# 🧪 Quick Testing Guide - In-App Notification Banner

**Date:** November 15, 2025  
**Status:** Ready to Test  

---

## 🎯 Objective

Test apakah notification banner muncul saat mitra accept jadwal.

---

## 📋 Prerequisites

### Backend Laravel:
- [ ] API `/api/user/pickup-schedules` working
- [ ] Database table `pickup_schedules` ada
- [ ] Status field bisa update dari `pending` → `accepted`

### Flutter App:
- [ ] Activity page sudah implemented
- [ ] Debug mode enabled (`_debugMode = true`)
- [ ] App running di real device atau emulator

---

## 🚀 Test Scenarios

### **Test 1: Manual Status Change (Database)**

**Purpose:** Verify Flutter detect status change & show banner

**Steps:**

1. **Run Flutter app:**
   ```bash
   flutter run
   ```

2. **Login sebagai user**
   - Email: `user@example.com`
   - Password: `password123`

3. **Buat jadwal baru:**
   - Masuk ke halaman create schedule
   - Pilih tanggal: Besok
   - Pilih waktu: 10:28
   - Submit

4. **Buka Activity Page:**
   - Tab "Aktif"
   - Lihat jadwal dengan status "Menunggu"

5. **Check Flutter console logs:**
   ```
   🔄 [Polling] Checking for schedule updates...
   📦 [Polling] Got 1 schedules from API
   ⏹️ [Polling] No changes detected
   ```
   **Logs ini akan muncul setiap 10 detik** ✅

6. **Ubah status di database (manual):**
   ```sql
   -- Check schedule ID dulu
   SELECT id, status FROM pickup_schedules 
   WHERE user_id = 15 
   ORDER BY created_at DESC 
   LIMIT 1;
   -- Result: id=75, status='pending'
   
   -- Update status
   UPDATE pickup_schedules 
   SET status = 'accepted', 
       mitra_id = 8,
       accepted_at = NOW()
   WHERE id = 75;
   
   -- Verify
   SELECT id, status FROM pickup_schedules WHERE id = 75;
   -- Result: id=75, status='accepted' ✅
   ```

7. **Tunggu max 10 detik & lihat console:**
   ```
   🔄 [Polling] Checking for schedule updates...
   📦 [Polling] Got 1 schedules from API
   
   🔔 [Status Change Detected!]
      Schedule ID: 75
      Old Status: pending
      New Status: accepted
      Address: Jl. Sudirman No. 123, Jakarta
      Day: Sabtu, 16 Nov 2025
      Time: 10:28
   
   ✅ Showing "Jadwal Diterima" banner...
   ♻️ [Polling] Updating UI with new data...
   ```

8. **EXPECTED RESULT:**
   ```
   ╔══════════════════════════════════════╗
   ║ ✅  Jadwal Diterima! 🎉              ║ <- Banner muncul dari atas!
   ║                                      ║    Warna HIJAU
   ║ Mitra telah menerima jadwal          ║
   ║ penjemputan Anda                     ║
   ║                                      ║
   ║ Sabtu, 16 Nov 2025 • 10:28         ║
   ╚══════════════════════════════════════╝
   ```

---

### **Test 2: Via API (Mitra Accept)**

**Purpose:** Test real flow dengan mitra app/API

**Steps:**

1. **User buat jadwal** (sama seperti Test 1 step 1-4)

2. **Get schedule ID dari console log atau database:**
   ```sql
   SELECT id FROM pickup_schedules 
   WHERE user_id = 15 
   AND status = 'pending' 
   ORDER BY created_at DESC 
   LIMIT 1;
   -- Result: id=75
   ```

3. **Test API endpoint (sebagai mitra):**
   ```bash
   # Get mitra token dulu
   curl -X POST "http://localhost:8000/api/mitra/login" \
     -H "Content-Type: application/json" \
     -d '{
       "email": "driver.jakarta@gerobaks.com",
       "password": "password123"
     }'
   # Copy token dari response
   
   # Mitra accept jadwal
   curl -X POST "http://localhost:8000/api/mitra/pickup-schedules/75/accept" \
     -H "Authorization: Bearer MITRA_TOKEN_HERE" \
     -H "Content-Type: application/json"
   ```

4. **Expected API Response:**
   ```json
   {
     "success": true,
     "message": "Jadwal berhasil diterima",
     "data": {
       "id": 75,
       "status": "accepted",
       "mitra_id": 8,
       "accepted_at": "2025-11-15T10:30:00.000000Z"
     }
   }
   ```

5. **Tunggu max 10 detik di Flutter app:**
   - Banner "Jadwal Diterima!" harus muncul
   - Console log show status change
   - Card di list berubah dari "Menunggu" → "Diterima"

---

### **Test 3: Multiple Status Changes**

**Purpose:** Test semua 4 jenis notifikasi

**Steps:**

1. **Start dengan schedule accepted** (dari Test 1 atau 2)

2. **Update ke on_the_way:**
   ```sql
   UPDATE pickup_schedules 
   SET status = 'on_the_way', 
       started_at = NOW()
   WHERE id = 75;
   ```
   
   **Expected Banner:**
   ```
   ╔══════════════════════════════════════╗
   ║ ℹ️  Mitra Dalam Perjalanan 🚛        ║ <- BIRU
   ║                                      ║
   ║ Mitra sedang menuju ke Jl. Sudirman ║
   ║ No. 123, Jakarta                     ║
   ║                                      ║
   ║ Sabtu, 16 Nov 2025 • 10:28         ║
   ╚══════════════════════════════════════╝
   ```

3. **Update ke arrived:**
   ```sql
   UPDATE pickup_schedules 
   SET status = 'arrived', 
       arrived_at = NOW()
   WHERE id = 75;
   ```
   
   **Expected Banner:**
   ```
   ╔══════════════════════════════════════╗
   ║ ⚠️  Mitra Sudah Tiba! 📍             ║ <- ORANGE
   ║                                      ║
   ║ Mitra sudah sampai di lokasi         ║
   ║ penjemputan                          ║
   ║                                      ║
   ║ Sabtu, 16 Nov 2025 • 10:28         ║
   ╚══════════════════════════════════════╝
   ```

4. **Update ke completed:**
   ```sql
   UPDATE pickup_schedules 
   SET status = 'completed',
       total_weight_kg = 5.5,
       total_points = 55,
       completed_at = NOW()
   WHERE id = 75;
   ```
   
   **Expected Banner:**
   ```
   ╔══════════════════════════════════════╗
   ║ ✅  Penjemputan Selesai! ✅          ║ <- HIJAU TUA
   ║                                      ║
   ║ Terima kasih telah menggunakan       ║
   ║ layanan kami                         ║
   ║                                      ║
   ║ 5.5 kg • +55 poin                   ║
   ╚══════════════════════════════════════╝
   ```

---

## 🔍 Debugging

### **Problem: Polling tidak jalan**

**Check console logs:**
```
# Jika tidak ada log "🔄 [Polling]..." setiap 10 detik
# Kemungkinan:
```

**Solution:**
```dart
// Check di activity_content_improved.dart line 39
static const bool _debugMode = true; // ✅ Must be true

// Check di line 61
void _startAutoRefresh() {
  _refreshTimer?.cancel();
  _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
    if (mounted && !_isRefreshing && widget.showActive) {
      _refreshSchedulesInBackground();
    }
  });
}
```

---

### **Problem: Status change tidak terdeteksi**

**Check console logs:**
```
🔄 [Polling] Checking for schedule updates...
📦 [Polling] Got 1 schedules from API
⏹️ [Polling] No changes detected  <- Problem disini!
```

**Possible causes:**

1. **Backend tidak return status baru:**
   ```bash
   # Test manual
   curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
     -H "Authorization: Bearer USER_TOKEN" | jq '.'
   
   # Check response:
   {
     "data": [{
       "id": 75,
       "status": "pending"  // ❌ Masih pending, harusnya 'accepted'
     }]
   }
   ```
   
   **Solution:** Fix backend controller, pastikan update status.

2. **Field name salah:**
   ```bash
   # Backend return "state" instead of "status"
   {
     "data": [{
       "state": "accepted"  // ❌ Wrong field name
     }]
   }
   ```
   
   **Solution:** Backend harus return field `status`, bukan `state`.

3. **Schedule ID berbeda:**
   ```bash
   # Check di database vs API response
   # Database: id = 75
   # API: id = 76  <- Different ID!
   ```
   
   **Solution:** Pastikan query schedule yang benar untuk user.

---

### **Problem: Banner tidak muncul meski status change detected**

**Check console logs:**
```
🔔 [Status Change Detected!]
   Schedule ID: 75
   Old Status: pending
   New Status: accepted
   ...

✅ Showing "Jadwal Diterima" banner...  <- Log ini ada
```

**But banner tidak muncul visually.**

**Possible causes:**

1. **Context tidak valid:**
   ```dart
   // Check di activity_content_improved.dart
   if (!mounted) return; // ✅ Harus check mounted
   ```

2. **Overlay issue:**
   ```dart
   // in_app_notification_service.dart line 15
   final overlay = Overlay.of(context);
   // Error: No Overlay widget found
   ```
   
   **Solution:** Pastikan activity page di-wrap dengan Scaffold yang punya Overlay.

3. **Z-index issue:**
   Banner tertutup widget lain.
   
   **Solution:** In-app banner menggunakan Overlay dengan Positioned(top: 0), seharusnya selalu di atas.

---

### **Problem: Banner muncul berulang-ulang**

**Cause:** Cache `_schedules` tidak terupdate

**Solution:**
```dart
// activity_content_improved.dart line 152
if (hasChanges) {
  setState(() {
    _schedules = schedules; // ✅ Ini penting! Update cache
  });
}
```

---

## 📊 Expected Console Output (Success Case)

### **Initial Load:**
```
🔄 [Polling] Checking for schedule updates...
📦 [Polling] Got 1 schedules from API
📊 [Polling] Schedule count changed: 0 → 1
♻️ [Polling] Updating UI with new data...
```

### **Every 10 seconds (no change):**
```
🔄 [Polling] Checking for schedule updates...
📦 [Polling] Got 1 schedules from API
⏹️ [Polling] No changes detected
```

### **When status changes:**
```
🔄 [Polling] Checking for schedule updates...
📦 [Polling] Got 1 schedules from API

🔔 [Status Change Detected!]
   Schedule ID: 75
   Old Status: pending
   New Status: accepted
   Address: Jl. Sudirman No. 123, Jakarta
   Day: Sabtu, 16 Nov 2025
   Time: 10:28

✅ Showing "Jadwal Diterima" banner...
♻️ [Polling] Updating UI with new data...
```

---

## ✅ Success Checklist

Setelah testing, pastikan:

### **Backend:**
- [ ] API `/api/user/pickup-schedules` return data benar
- [ ] Field `status` terupdate saat mitra accept
- [ ] Field `schedule_day` format: "Sabtu, 16 Nov 2025"
- [ ] Field `pickup_time_start` format: "10:28"
- [ ] Field `total_weight_kg` & `total_points` ada untuk completed

### **Flutter:**
- [ ] Console log show polling setiap 10 detik
- [ ] Status change detected di console
- [ ] Banner muncul dengan animasi slide dari atas
- [ ] Banner auto-dismiss setelah 5 detik
- [ ] Banner bisa di-dismiss dengan swipe up
- [ ] Tap banner refresh data
- [ ] Card status terupdate di list

### **User Experience:**
- [ ] Banner tidak overlap dengan widget lain
- [ ] Animation smooth (tidak lag)
- [ ] Text readable (tidak terlalu panjang)
- [ ] Colors appropriate (green=success, blue=info, etc)
- [ ] Subtitle showing schedule details

---

## 🎬 Video Test Flow

### **Ideal Test Recording:**

```
0:00 - User login
0:05 - User create schedule
0:10 - Navigate to Activity page (tab Aktif)
0:15 - See schedule with status "Menunggu"
0:20 - [Backend] Mitra accept via API or manual DB update
0:25 - [Wait] 5-10 seconds...
0:30 - ✅ BANNER MUNCUL dari atas! "Jadwal Diterima! 🎉"
0:35 - Banner auto-dismiss atau swipe up
0:37 - Card status berubah jadi "Diterima"
0:40 - Done! ✅
```

**Duration:** ~40 seconds for full test

---

## 🚀 Production Checklist

Before deploying:

- [ ] Change `_debugMode = false` (disable debug logs)
- [ ] Change polling interval to 30 seconds
- [ ] Test on real device (Android & iOS)
- [ ] Test with slow internet connection
- [ ] Test with multiple users
- [ ] Verify no memory leaks
- [ ] Check battery usage

---

## 📞 Need Help?

### **Jika Test 1 gagal:**
1. Check console logs untuk error
2. Check backend response format
3. Verify database status berubah
4. Share console logs dengan backend team

### **Jika API bermasalah:**
1. Share `BACKEND_IN_APP_NOTIFICATION_REQUIREMENTS.md` dengan backend
2. Test API dengan Postman/curl
3. Check Laravel logs: `storage/logs/laravel.log`

### **Jika Flutter error:**
1. Check import statement ada semua
2. Run `flutter clean && flutter pub get`
3. Restart app
4. Check device storage (pastikan cukup untuk logs)

---

**Status:** ✅ Ready to test!  
**Estimated Test Time:** 5 minutes per scenario  
**Total Test Time:** ~15 minutes for all scenarios  

🧪 **Happy Testing!**
