# 🔔 Pop-Up Notification System - Backend Documentation

**Project:** Gerobaks User App  
**Feature:** Pop-Up Dialog Notification saat Status Change  
**Date:** November 18, 2025  

---

## 📋 Overview

### **Sistem Notifikasi Pop-Up:**
- ✅ **Pop-up dialog** muncul di tengah layar saat status berubah
- ✅ **Flutter app polling** API setiap 30 detik
- ✅ **No Firebase/Pusher** required - Pure polling based
- ✅ **Dialog dengan animasi** scale dan fade

### **User Experience:**
1. User create jadwal → Status: `pending`
2. Mitra terima jadwal → Status: `on_progress` → **🎉 POP-UP MUNCUL: "Jadwal Diterima!"**
3. Mitra on the way → Status: `on_the_way` → **🚛 POP-UP: "Mitra Dalam Perjalanan"**
4. Mitra arrived → Status: `arrived` → **📍 POP-UP: "Mitra Sudah Tiba!"**
5. Mitra complete → Status: `completed` → **✅ POP-UP: "Penjemputan Selesai!"**

---

## 🎯 Backend Requirements (SAMA seperti sebelumnya)

### **API Endpoint:**
```
GET /api/user/pickup-schedules
```

**Headers:**
```
Authorization: Bearer {user_token}
Accept: application/json
```

---

## 📊 Required Response Format

```json
{
  "success": true,
  "message": "Pickup schedules retrieved successfully",
  "data": [
    {
      "id": 80,
      "user_id": 15,
      "status": "on_progress",
      "pickup_address": "Jl. Sudirman No. 123, Jakarta Selatan",
      "scheduled_pickup_at": "2025-11-18 10:28:00",
      "schedule_day": "Senin, 18 Nov 2025",
      "pickup_time_start": "10:28",
      "mitra_id": 8,
      "mitra_name": "Ahmad Kurniawan",
      "mitra_phone": "081234567890",
      "total_weight_kg": null,
      "total_points": null,
      "created_at": "2025-11-18T08:15:00.000000Z",
      "updated_at": "2025-11-18T09:30:00.000000Z"
    }
  ]
}
```

---

## 🔄 Status Flow

```
pending → on_progress → on_the_way → arrived → completed
   ↓
cancelled
```

### **Pop-Up Notifications:**

| Status Transition | Pop-Up Title | Pop-Up Message | Visual |
|------------------|--------------|----------------|--------|
| `pending` → `on_progress` | Jadwal Diterima! 🎉 | Mitra [name] telah menerima jadwal... | Green, Check Icon |
| `on_progress` → `on_the_way` | Mitra Dalam Perjalanan 🚛 | Mitra sedang menuju ke lokasi Anda | Blue, Truck Icon |
| `on_the_way` → `arrived` | Mitra Sudah Tiba! 📍 | Mitra sudah sampai di lokasi... | Orange, Location Icon |
| `arrived` → `completed` | Penjemputan Selesai! ✅ | Terima kasih telah menggunakan... | Dark Green, Check Icon |

---

## 🔑 Critical Fields (MUST HAVE)

| Field | Type | Required | Format | Example |
|-------|------|----------|--------|---------|
| `id` | integer | ✅ | - | 80 |
| `status` | string | ✅ | ENUM | "on_progress" |
| `schedule_day` | string | ✅ | Bahasa Indonesia | "Senin, 18 Nov 2025" |
| `pickup_time_start` | string | ✅ | HH:mm | "10:28" |
| `pickup_address` | string | ✅ | - | "Jl. Sudirman..." |
| `mitra_name` | string | When accepted+ | - | "Ahmad Kurniawan" |
| `mitra_phone` | string | When accepted+ | - | "081234567890" |
| `total_weight_kg` | decimal | When completed | - | 5.5 |
| `total_points` | integer | When completed | - | 55 |
| `updated_at` | string | ✅ | ISO 8601 | "2025-11-18T09:30:00Z" |

---

## 💡 How It Works

### **Flutter Polling Flow:**

```
Every 30 seconds:
  1. Call: GET /api/user/pickup-schedules
  2. Get response data
  3. Compare with cached data:
     - If updated_at changed → Status changed
     - If status changed → Show POP-UP DIALOG
  4. Update cache
  5. Repeat after 30 seconds
```

### **Example Detection:**

```dart
// Cached data (from 30 seconds ago)
{
  "id": 80,
  "status": "pending",
  "updated_at": "2025-11-18T08:00:00Z"
}

// New response (after mitra accept)
{
  "id": 80,
  "status": "on_progress",  // ✅ CHANGED!
  "mitra_name": "Ahmad Kurniawan",  // ✅ NOW FILLED
  "updated_at": "2025-11-18T09:30:00Z"  // ✅ CHANGED!
}

// Flutter detects change → Shows POP-UP DIALOG! 🎉
```

---

## 🎨 Pop-Up Dialog Features

### **Visual Design:**
- ✅ Muncul di tengah layar
- ✅ Background blur/darkened
- ✅ Animasi scale + fade
- ✅ Colored header (green/blue/orange)
- ✅ Icon besar (check/truck/location)
- ✅ Title bold
- ✅ Message
- ✅ Subtitle (schedule day, time, atau weight+points)
- ✅ Button "OK, Mengerti"
- ✅ Auto-dismiss setelah 5 detik

### **User Interaction:**
- Tap anywhere → Close dialog
- Tap button → Close dialog (optional: navigate to activity page)
- Wait 5 seconds → Auto-close

---

## 🧪 Testing Backend

### **Test 1: Get User Schedules**

```bash
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 80,
      "status": "pending",
      "schedule_day": "Senin, 18 Nov 2025",  // ✅ Bahasa Indonesia
      "pickup_time_start": "10:28",          // ✅ HH:mm format
      "mitra_name": null,                    // ✅ Null when pending
      "updated_at": "2025-11-18T08:00:00.000000Z"
    }
  ]
}
```

---

### **Test 2: Mitra Accept Schedule**

**Via Mitra App:**
- Mitra open available schedules
- Mitra tap "Terima Jadwal"
- Backend update status

**Or Manual Database:**
```sql
UPDATE pickup_schedules 
SET status = 'on_progress',
    mitra_id = 8,
    updated_at = NOW()
WHERE id = 80 AND status = 'pending';
```

**Verify:**
```sql
SELECT id, status, mitra_id, updated_at 
FROM pickup_schedules 
WHERE id = 80;
```

---

### **Test 3: Check Status Change (User)**

```bash
# Call API again (simulate polling after 30s)
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer YOUR_USER_TOKEN"
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 80,
      "status": "on_progress",  // ✅ CHANGED!
      "mitra_id": 8,            // ✅ NOW FILLED
      "mitra_name": "Ahmad Kurniawan",  // ✅ NOW FILLED
      "mitra_phone": "081234567890",
      "updated_at": "2025-11-18T09:30:00.000000Z"  // ✅ CHANGED!
    }
  ]
}
```

**Flutter app will detect change and show POP-UP DIALOG! 🎉**

---

## 🎯 Backend Implementation Summary

### **Already Implemented (from previous docs):**

1. ✅ Model: `PickupSchedule` with accessors
   - `schedule_day` accessor (Bahasa Indonesia)
   - `pickup_time_start` accessor (HH:mm)
   - `mitra_name` accessor
   - `mitra_phone` accessor

2. ✅ Controller: `PickupScheduleController@index`
   - Returns user's schedules
   - Includes mitra data
   - Formatted dates/times

3. ✅ Routes: `GET /api/user/pickup-schedules`
   - Authentication required
   - Role: end_user

4. ✅ Mitra Actions:
   - `POST /api/mitra/pickup-schedules/{id}/accept`
   - Updates status to `on_progress`
   - Sets `mitra_id`
   - Auto-updates `updated_at`

### **What You Need to Verify:**

- [ ] Endpoint works and returns correct format
- [ ] `status` values match: `pending`, `on_progress`, `on_the_way`, `arrived`, `completed`
- [ ] `updated_at` auto-updates when status changes
- [ ] `schedule_day` in Bahasa Indonesia format
- [ ] `pickup_time_start` in HH:mm format (no seconds)
- [ ] `mitra_name` filled when status = on_progress+

---

## ✅ Testing Checklist

### **Backend Verification:**

```bash
# 1. Check endpoint works
curl -X GET "YOUR_API/api/user/pickup-schedules" \
  -H "Authorization: Bearer TOKEN" | jq '.data[0]'

# Expected output:
{
  "id": 80,
  "status": "pending",
  "schedule_day": "Senin, 18 Nov 2025",  // ✅ Indonesian
  "pickup_time_start": "10:28",          // ✅ No seconds
  "mitra_name": null,
  "updated_at": "..."
}

# 2. Update status manually
mysql> UPDATE pickup_schedules SET status='on_progress', mitra_id=8, updated_at=NOW() WHERE id=80;

# 3. Check again
curl -X GET "YOUR_API/api/user/pickup-schedules" \
  -H "Authorization: Bearer TOKEN" | jq '.data[0].status'

# Expected: "on_progress"

# 4. Check mitra name filled
curl -X GET "YOUR_API/api/user/pickup-schedules" \
  -H "Authorization: Bearer TOKEN" | jq '.data[0].mitra_name'

# Expected: "Ahmad Kurniawan" (or actual mitra name)
```

---

## 🚀 Flutter App Behavior

### **When Status Changes:**

```
User login → Polling starts (every 30s)
    ↓
30 seconds later → Call API
    ↓
Response: status changed (pending → on_progress)
    ↓
🎉 POP-UP DIALOG MUNCUL di tengah layar!
    ↓
Title: "Jadwal Diterima! 🎉"
Message: "Mitra Ahmad Kurniawan telah menerima jadwal penjemputan Anda"
Subtitle: "Senin, 18 Nov 2025 • 10:28"
Button: "OK, Mengerti"
    ↓
Auto-dismiss after 5 seconds OR user tap button
```

---

## 📱 Visual Examples

### **Pop-Up Dialog Specs:**

```
╔════════════════════════════════╗
║     [Green Header Background]  ║
║                                ║
║        [✓ Large Icon]          ║
║                                ║
║      Jadwal Diterima! 🎉      ║
║                                ║
╠════════════════════════════════╣
║                                ║
║  Mitra Ahmad Kurniawan telah   ║
║  menerima jadwal penjemputan   ║
║  Anda                          ║
║                                ║
║  ┌──────────────────────────┐  ║
║  │ Senin, 18 Nov 2025 •     │  ║
║  │ 10:28                    │  ║
║  └──────────────────────────┘  ║
║                                ║
║  ┌──────────────────────────┐  ║
║  │    OK, Mengerti          │  ║
║  └──────────────────────────┘  ║
║                                ║
║  Akan tertutup otomatis        ║
║  dalam 5 detik                 ║
║                                ║
╚════════════════════════════════╝
```

---

## 🎯 Success Criteria

**Backend is READY when:**

1. ✅ Endpoint `GET /api/user/pickup-schedules` works
2. ✅ Response format matches documentation exactly
3. ✅ Status values: `on_progress` (NOT `accepted`!)
4. ✅ `updated_at` auto-updates on status change
5. ✅ `schedule_day` in Bahasa Indonesia
6. ✅ `pickup_time_start` in HH:mm format
7. ✅ `mitra_name` filled when status >= on_progress

**Test Command:**
```bash
curl -X GET "YOUR_API/api/user/pickup-schedules" \
  -H "Authorization: Bearer TOKEN" | jq '.'
```

**If response matches examples above → READY! 🎉**

---

## 📞 Support

**Questions about:**
- ✅ Status values
- ✅ Date/time formatting
- ✅ Response structure
- ✅ Testing procedures

**Share:**
1. API response (curl output)
2. Database schema for `pickup_schedules`
3. Current implementation of Model accessors

---

## 🔗 Related Documentation

- `BACKEND_INTEGRATION_STATUS.md` - Complete backend guide
- `BACKEND_QUICK_REFERENCE.md` - Quick API reference
- `test_notification_system.sh` - Testing script

---

**Status:** ✅ **BACKEND REQUIREMENTS UNCHANGED**  
**Pop-Up:** ✅ **IMPLEMENTED IN FLUTTER**  
**Next:** Test dengan backend dan verify pop-up muncul!

---

**Key Points:**
- ⚡ No changes needed on backend (sama dengan sebelumnya)
- ⚡ Pop-up lebih visible daripada banner
- ⚡ User akan langsung tau saat status berubah
- ⚡ Auto-dismiss tapi bisa manual close juga
- ⚡ Animasi smooth dan professional
