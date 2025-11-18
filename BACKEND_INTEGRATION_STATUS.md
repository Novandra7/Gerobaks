# ✅ Backend Integration - Status Update

**Date:** November 17, 2025  
**Status:** ✅ **READY TO TEST**

---

## 📋 Backend API Documentation

### **Endpoint:**
```
GET /api/user/pickup-schedules
```

### **Authentication:**
```
Authorization: Bearer YOUR_TOKEN
```

### **Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "id": 80,
      "status": "on_progress",
      "schedule_day": "Sabtu, 15 Nov 2025",
      "pickup_time_start": "14:00",
      "pickup_address": "Jl. Sudirman No. 123",
      "mitra_name": "Ahmad Kurniawan",
      "mitra_phone": "081345678901",
      "total_weight_kg": 4.6,
      "total_points": 46,
      "updated_at": "2025-11-14T05:58:47+00:00"
    }
  ]
}
```

---

## 🔄 Status Flow (Backend)

```
pending → on_progress → on_the_way → arrived → completed
   ↓
cancelled
```

### **Status Mapping:**

| Backend Status | Flutter Detection | Notification Banner |
|---------------|-------------------|---------------------|
| `pending` | Initial state | - |
| `on_progress` | Mitra accept | 🎉 "Jadwal Diterima!" (green) |
| `on_the_way` | Mitra on the way | 🚛 "Mitra Dalam Perjalanan" (blue) |
| `arrived` | Mitra arrived | 📍 "Mitra Sudah Tiba!" (orange) |
| `completed` | Pickup done | ✅ "Penjemputan Selesai!" (dark green) |
| `cancelled` | Schedule cancelled | ❌ "Jadwal Dibatalkan" (orange) |

---

## ✅ Flutter Implementation - UPDATED

### **File Updated:**
- `lib/services/global_notification_polling_service.dart`

### **Changes Made:**

1. **Status Flow Updated:**
   ```dart
   // OLD (not matching backend):
   if (oldStatus == 'pending' && newStatus == 'accepted')
   
   // NEW (matching backend):
   if (oldStatus == 'pending' && newStatus == 'on_progress')
   ```

2. **Mitra Name Display:**
   ```dart
   final mitraName = schedule['mitra_name'];
   
   message: mitraName != null 
       ? 'Mitra $mitraName telah menerima jadwal penjemputan Anda'
       : 'Mitra telah menerima jadwal penjemputan Anda',
   ```

3. **Cancelled Status Handling:**
   ```dart
   else if (newStatus == 'cancelled') {
     InAppNotificationService.show(
       title: 'Jadwal Dibatalkan ❌',
       message: 'Jadwal penjemputan telah dibatalkan',
       type: InAppNotificationType.warning,
     );
   }
   ```

---

## 🧪 Testing Guide

### **Step 1: Verify Backend Ready**

```bash
curl -X GET "YOUR_API_URL/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN" | jq '.'
```

**Expected:**
```json
{
  "success": true,
  "data": [...]
}
```

✅ Backend ready!

---

### **Step 2: Run Flutter App**

```bash
flutter run
```

**Check console on login:**
```
✅ Global notification polling started for end_user
🚀 [GlobalNotification] Polling started (every 30 seconds)
📦 [GlobalNotification] Initial cache loaded: X schedules
```

---

### **Step 3: Test Status Changes**

#### **Test A: Mitra Accept (pending → on_progress)**

**Action:**
- Mitra accept jadwal via mitra app OR manual database:
  ```sql
  UPDATE pickup_schedules 
  SET status = 'on_progress', 
      mitra_id = 8,
      updated_at = NOW()
  WHERE id = 80 AND status = 'pending';
  ```

**Expected Console (within 30s):**
```
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 1 schedules

🔔 [GlobalNotification] Status Change Detected!
   Schedule ID: 80
   Old Status: pending
   New Status: on_progress

✅ Showing "Jadwal Diterima" banner...
```

**Expected UI:**
- ✅ Green banner slides from top
- 🎉 Title: "Jadwal Diterima! 🎉"
- 📝 Message: "Mitra Ahmad Kurniawan telah menerima jadwal penjemputan Anda"
- 📅 Subtitle: "Sabtu, 15 Nov 2025 • 14:00"

---

#### **Test B: Mitra On The Way (on_progress → on_the_way)**

**Action:**
```sql
UPDATE pickup_schedules 
SET status = 'on_the_way', 
    updated_at = NOW()
WHERE id = 80 AND status = 'on_progress';
```

**Expected Console:**
```
🔔 [GlobalNotification] Status Change Detected!
   Old Status: on_progress
   New Status: on_the_way

🚛 Showing "Mitra On The Way" banner...
```

**Expected UI:**
- 🔵 Blue banner
- 🚛 Title: "Mitra Dalam Perjalanan 🚛"
- 📝 Message: "Mitra sedang menuju ke Jl. Sudirman No. 123"

---

#### **Test C: Mitra Arrived (on_the_way → arrived)**

**Action:**
```sql
UPDATE pickup_schedules 
SET status = 'arrived', 
    updated_at = NOW()
WHERE id = 80 AND status = 'on_the_way';
```

**Expected Console:**
```
🔔 [GlobalNotification] Status Change Detected!
   Old Status: on_the_way
   New Status: arrived

📍 Showing "Mitra Arrived" banner...
```

**Expected UI:**
- 🟠 Orange banner
- 📍 Title: "Mitra Sudah Tiba! 📍"
- 📝 Message: "Mitra sudah sampai di lokasi penjemputan"

---

#### **Test D: Pickup Completed (arrived → completed)**

**Action:**
```sql
UPDATE pickup_schedules 
SET status = 'completed',
    total_weight_kg = 4.6,
    total_points = 46,
    updated_at = NOW()
WHERE id = 80 AND status = 'arrived';
```

**Expected Console:**
```
🔔 [GlobalNotification] Status Change Detected!
   Old Status: arrived
   New Status: completed

✅ Showing "Pickup Completed" banner...
```

**Expected UI:**
- 🟢 Dark green banner
- ✅ Title: "Penjemputan Selesai! ✅"
- 📝 Message: "Terima kasih telah menggunakan layanan kami"
- 📊 Subtitle: "4.6 kg • +46 poin"

---

## 🎯 Success Criteria

### **Backend Integration:**
- ✅ Endpoint `/api/user/pickup-schedules` works
- ✅ Response format matches documentation
- ✅ Status values: `pending`, `on_progress`, `on_the_way`, `arrived`, `completed`, `cancelled`
- ✅ Fields `schedule_day` in Bahasa Indonesia
- ✅ Field `pickup_time_start` in HH:mm format
- ✅ Field `updated_at` auto-updates on status change

### **Flutter App:**
- ✅ Polling starts on login
- ✅ Polling runs every 30 seconds
- ✅ Status changes detected correctly
- ✅ Banner displays with correct:
  - Title
  - Message
  - Subtitle
  - Color (green/blue/orange/dark green)
  - Animation (slide from top)
- ✅ Banner auto-dismisses after 5 seconds
- ✅ Banner can be dismissed by tap/swipe

---

## 🔍 Debugging

### **Issue: Banner Tidak Muncul**

**Check Console Logs:**

1. **Polling tidak jalan:**
   ```
   Expected: 🔄 [GlobalNotification] Checking for updates...
   If missing: Service not started (check sign_in_page.dart)
   ```

2. **API error:**
   ```
   Expected: 📦 [GlobalNotification] Got X schedules
   If missing: API endpoint issue (check backend)
   ```

3. **Status tidak berubah:**
   ```
   Expected: 🔔 [GlobalNotification] Status Change Detected!
   If missing: Backend not updating status or updated_at
   ```

4. **Banner tidak muncul:**
   ```
   Expected: ✅ Showing "..." banner...
   If present but no UI: Context issue (check main.dart navigator key)
   ```

---

### **Quick Test Commands:**

```bash
# 1. Check backend API
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer YOUR_TOKEN" | jq '.data[0].status'

# 2. Update status manually
mysql -u root -p gerobaks -e "UPDATE pickup_schedules SET status='on_progress', updated_at=NOW() WHERE id=80;"

# 3. Check Flutter console (wait max 30s)
# Should see: 🔔 Status Change Detected!

# 4. Force refresh (optional - untuk testing)
# Add button di UI:
# GlobalNotificationPollingService().forceRefresh();
```

---

## 📱 Expected User Experience

1. **User creates schedule** → Status: `pending`
   - No notification (initial state)

2. **Mitra accepts** (via mitra app) → Status: `on_progress`
   - ⏱️ Within 30 seconds
   - 🔔 Banner muncul: "Jadwal Diterima! 🎉"
   - 🟢 Green color
   - 📱 Shows mitra name

3. **Mitra starts journey** → Status: `on_the_way`
   - ⏱️ Within 30 seconds
   - 🔔 Banner: "Mitra Dalam Perjalanan 🚛"
   - 🔵 Blue color
   - 📍 Shows address

4. **Mitra arrives** → Status: `arrived`
   - ⏱️ Within 30 seconds
   - 🔔 Banner: "Mitra Sudah Tiba! 📍"
   - 🟠 Orange color

5. **Pickup completed** → Status: `completed`
   - ⏱️ Within 30 seconds
   - 🔔 Banner: "Penjemputan Selesai! ✅"
   - 🟢 Dark green
   - 📊 Shows weight & points

---

## ✅ Implementation Checklist

### **Flutter Side (DONE):**
- [x] GlobalNotificationPollingService updated
- [x] Status flow matching backend (on_progress, on_the_way, etc)
- [x] Mitra name display
- [x] Cancelled status handling
- [x] Debug logs for all status changes
- [x] Banner colors and messages

### **Backend Side (CHECK WITH TEAM):**
- [ ] Endpoint `/api/user/pickup-schedules` works
- [ ] Authentication required
- [ ] Response format correct
- [ ] Status values correct (on_progress, not accepted)
- [ ] `updated_at` auto-updates
- [ ] Mitra endpoints update status correctly

### **Testing:**
- [ ] Backend API tested with curl
- [ ] Flutter app tested with debug logs
- [ ] Status change tested (pending → on_progress)
- [ ] Banner appears visually
- [ ] All 4 status transitions tested
- [ ] Performance OK (30s polling interval)

---

## 🚀 Next Steps

1. **Test Backend API:**
   ```bash
   curl -X GET "YOUR_API/api/user/pickup-schedules" \
     -H "Authorization: Bearer TOKEN" | jq '.'
   ```

2. **Run Flutter App:**
   ```bash
   flutter run
   ```

3. **Trigger Status Change:**
   - Via mitra app (recommended)
   - OR manual database update (for testing)

4. **Verify Banner Appears:**
   - Check console logs
   - Check UI for banner animation
   - Check auto-dismiss after 5s

5. **Report Results:**
   - Screenshot banner
   - Share console logs
   - Report any issues

---

**Status:** ✅ **Code updated and ready for testing!**

**Contact:** Share console logs and API response if issues occur.
