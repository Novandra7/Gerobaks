# 🔍 DEBUG: Notifikasi Hanya Muncul Saat Completed

**Issue:** Notifikasi muncul saat `completed` tapi **tidak muncul saat diterima** (pending → on_progress)

---

## 🎯 Enhanced Debug Logs

Saya sudah tambahkan **debug logs yang sangat detail** di `global_notification_polling_service.dart`:

### **Logs Yang Akan Muncul:**

#### **1. Saat Polling Check:**
```
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 2 schedules
🔍 [GlobalNotification] Comparing schedules...
   Cached: 2 schedules
   New: 2 schedules
```

#### **2. Saat Check Tiap Schedule:**
```
   Checking schedule ID: 80, New Status: on_progress
   Found in cache: Old Status: pending
```

#### **3. Saat Status Berubah:**
```
🔔 [GlobalNotification] ⚡ STATUS CHANGE DETECTED! ⚡
   Schedule ID: 80
   Old Status: "pending"
   New Status: "on_progress"
   Mitra Name: Ahmad Kurniawan
   Schedule Day: Senin, 18 Nov 2025
   Pickup Time: 10:28
```

#### **4. Saat Show Popup:**
```
📱 [GlobalNotification] _showNotificationBanner called
   Old Status: "pending"
   New Status: "on_progress"
   Schedule Day: Senin, 18 Nov 2025
   Pickup Time: 10:28
   Mitra Name: Ahmad Kurniawan

🎉 [GlobalNotification] ===== SHOWING "JADWAL DITERIMA" POPUP =====
```

#### **5. Jika Status Tidak Match:**
```
⚠️ [GlobalNotification] ===== UNHANDLED STATUS CHANGE =====
   Old Status: "pending"
   New Status: "accepted"  ← Mungkin backend pakai "accepted" bukan "on_progress"?
   Possible reasons:
   1. Status skip steps (e.g. pending → arrived)
   2. Status tidak sesuai flow backend
   3. Custom status yang belum ditangani
```

---

## 🧪 Testing Steps

### **Test 1: Check Console Logs**

```bash
# 1. Run flutter app
flutter run

# 2. Watch console carefully!

# 3. Di backend, update status:
UPDATE pickup_schedules 
SET status = 'on_progress',
    mitra_id = 8,
    updated_at = NOW()
WHERE id = 80 AND status = 'pending';

# 4. Wait max 30 seconds

# 5. Check console for:
#    - "STATUS CHANGE DETECTED!"
#    - "SHOWING JADWAL DITERIMA POPUP"
```

---

## 🔍 Possible Issues & Solutions

### **Issue 1: Backend Pakai Status Lain**

**Symptom:**
```
⚠️ [GlobalNotification] ===== UNHANDLED STATUS CHANGE =====
   Old Status: "pending"
   New Status: "accepted"  ← Bukan "on_progress"!
```

**Cause:** Backend mungkin pakai `accepted` bukan `on_progress`

**Solution:** Cek console log untuk lihat exact status dari backend:
```
🔔 [GlobalNotification] ⚡ STATUS CHANGE DETECTED! ⚡
   Old Status: "pending"
   New Status: "???"  ← Catat ini!
```

Lalu share ke saya status apa yang muncul!

---

### **Issue 2: Cache Kosong (First Load)**

**Symptom:**
```
📋 [GlobalNotification] First load (cache empty), no comparison
   New schedules: 2
   - ID: 80, Status: on_progress  ← Sudah on_progress dari awal!
```

**Cause:** Saat app start, schedule sudah `on_progress`, jadi tidak ada perubahan yang terdeteksi

**Solution:**
1. Pastikan schedule masih `pending` saat user login
2. Atau test dengan schedule baru yang dibuat setelah login

---

### **Issue 3: Status Skip Steps**

**Symptom:**
```
⚠️ [GlobalNotification] ===== UNHANDLED STATUS CHANGE =====
   Old Status: "pending"
   New Status: "completed"  ← Skip on_progress!
```

**Cause:** Backend langsung dari `pending` ke `completed` tanpa melalui `on_progress`

**Solution:** Backend harus follow flow:
```
pending → on_progress → on_the_way → arrived → completed
```

---

### **Issue 4: No Context Available**

**Symptom:**
```
📱 [GlobalNotification] _showNotificationBanner called
⚠️ [GlobalNotification] No context available for notification
```

**Cause:** Navigator key belum di-set atau user belum login

**Solution:**
- Pastikan `main.dart` sudah ada `_navigatorKey`
- Pastikan user sudah login sebelum test

---

## 📱 What You Should See (Happy Path)

### **Complete Flow:**

```
# User Login
✅ [GlobalNotification] Service initialized
🚀 [GlobalNotification] Polling started (every 30 seconds)
📦 [GlobalNotification] Initial cache loaded: 1 schedules

# First Check (30s later)
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 1 schedules
🔍 [GlobalNotification] Comparing schedules...
   Checking schedule ID: 80, New Status: pending
   Found in cache: Old Status: pending
   ✓ No status change for schedule 80

# After mitra accept (next 30s check)
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 1 schedules
🔍 [GlobalNotification] Comparing schedules...
   Checking schedule ID: 80, New Status: on_progress
   Found in cache: Old Status: pending

🔔 [GlobalNotification] ⚡ STATUS CHANGE DETECTED! ⚡
   Schedule ID: 80
   Old Status: "pending"
   New Status: "on_progress"
   Mitra Name: Ahmad Kurniawan
   Schedule Day: Senin, 18 Nov 2025
   Pickup Time: 10:28

📱 [GlobalNotification] _showNotificationBanner called
   Old Status: "pending"
   New Status: "on_progress"
   Schedule Day: Senin, 18 Nov 2025
   Pickup Time: 10:28
   Mitra Name: Ahmad Kurniawan

🎉 [GlobalNotification] ===== SHOWING "JADWAL DITERIMA" POPUP =====

🎬 [PopupNotification] initState - Starting animation
▶️ [PopupNotification] Animation started
🎨 [PopupNotification] build() called

# Pop-up appears! 🎉
```

---

## 🎯 Action Items

### **Do This Now:**

1. **Run Flutter app:**
   ```bash
   flutter run
   ```

2. **Watch console carefully** (don't miss any logs!)

3. **Update status di backend:**
   ```sql
   UPDATE pickup_schedules 
   SET status = 'on_progress',
       mitra_id = 8,
       updated_at = NOW()
   WHERE id = 80 AND status = 'pending';
   ```

4. **Wait 30 seconds** (max polling interval)

5. **Check console for these EXACT logs:**
   - `🔔 STATUS CHANGE DETECTED!`
   - `Old Status: "pending"`
   - `New Status: "???"` ← **CATAT INI!**
   - `🎉 SHOWING "JADWAL DITERIMA" POPUP`

6. **Share dengan saya:**
   ```
   - Apakah ada log "STATUS CHANGE DETECTED!"? Ya/Tidak
   - Jika Ya, Old Status apa? New Status apa?
   - Apakah ada log "SHOWING JADWAL DITERIMA POPUP"? Ya/Tidak
   - Apakah ada log "UNHANDLED STATUS CHANGE"? Ya/Tidak
   - Apakah popup muncul? Ya/Tidak
   ```

---

## 🔧 Quick Fixes (Jika Ada Masalah)

### **Fix 1: Backend Pakai Status Lain**

Jika console log show:
```
New Status: "accepted"  ← Backend pakai "accepted" bukan "on_progress"
```

Maka kita perlu update code:
```dart
// Change line ~255 in global_notification_polling_service.dart
if (oldStatus == 'pending' && newStatus == 'accepted') {  // Change here!
  // Show popup...
}
```

### **Fix 2: Cache Issue**

Jika schedule sudah `on_progress` saat login:
- Pastikan test dengan schedule yang `pending`
- Atau create schedule baru setelah login

---

## 📞 Next Steps

Setelah test, **share complete console logs** dengan saya:

```bash
# Copy all logs from:
# "Polling started" 
# sampai 
# "SHOWING ... POPUP" atau "UNHANDLED STATUS CHANGE"
```

Dari logs itu saya bisa tau **EXACT** masalahnya! 🎯

---

**Status:** ✅ **ENHANCED DEBUG LOGS ADDED**

**Action:** Run `flutter run` dan share logs! 🚀
