# 🔍 DEBUG GUIDE - Notifikasi Tidak Muncul

**Problem:** Notifikasi tidak muncul saat mitra terima jadwal  
**Date:** November 17, 2025  

---

## 📋 Checklist Debugging

### **1. Check Console Logs**

Saat run app dengan `flutter run`, check console untuk logs berikut:

#### **✅ On App Start:**
```
✅ Global notification service initialized
```
**Jika tidak ada:** Navigator key belum terpasang di MaterialApp

---

#### **✅ On Login (End User):**
```
✅ Global notification polling started for end_user
🚀 [GlobalNotification] Polling started (every 30 seconds)
📦 [GlobalNotification] Initial cache loaded: X schedules
```

**Jika tidak ada:**
- Check apakah user login sebagai `end_user` (bukan mitra)
- Check `startPolling()` dipanggil di sign_in_page.dart
- Check token valid

---

#### **✅ Every 30 Seconds:**
```
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got X schedules
```

**Jika tidak ada:**
- Polling tidak jalan
- Token expired
- API error

---

#### **✅ When Status Changes:**
```
🔔 [GlobalNotification] Status Change Detected!
   Schedule ID: 75
   Old Status: pending
   New Status: accepted

✅ Showing "Jadwal Diterima" banner...
```

**Jika tidak ada:**
- Status tidak berubah di backend
- Backend tidak return field yang benar

---

## 🔧 Step-by-Step Debugging

### **Step 1: Verify Service Initialized**

```bash
# Run app
flutter run

# Check console saat app start
# Should see:
✅ Global notification service initialized
```

**If NOT appearing:**

Check `lib/main.dart`:
```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    _initializeGlobalNotification(); // ✅ Must call this
  }
  
  Future<void> _initializeGlobalNotification() async {
    final notificationService = GlobalNotificationPollingService();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notificationService.initialize(_navigatorKey);
    });
  }
}
```

---

### **Step 2: Verify Polling Started After Login**

```bash
# Login sebagai END USER (bukan mitra!)
# Check console:
✅ Global notification polling started for end_user
🚀 [GlobalNotification] Polling started (every 30 seconds)
```

**If NOT appearing:**

Check `lib/ui/pages/sign_in/sign_in_page.dart`:
```dart
case 'end_user':
default:
  print("✅ Navigating to END USER home");
  
  // ✅ Must have this code
  try {
    final notificationService = GlobalNotificationPollingService();
    await notificationService.startPolling();
    print('✅ Global notification polling started');
  } catch (e) {
    print('⚠️ Failed to start polling: $e');
  }
  
  Navigator.pushNamedAndRemoveUntil(...);
  break;
```

---

### **Step 3: Verify Polling Running**

```bash
# Wait 30 seconds after login
# Check console every 30 seconds:
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 1 schedules
```

**If NOT appearing:**

**Problem A: Timer not created**
```dart
// Check global_notification_polling_service.dart line ~95
_pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
  _checkForUpdates(); // ✅ Must be called
});
```

**Problem B: Token expired**
```dart
// Service checks token, if null = stop
final token = await authService.getToken();
if (token == null) {
  print('⚠️ No token'); // You'll see this
  return;
}
```

**Problem C: API error**
```dart
// Check _checkForUpdates() method
try {
  final schedules = await _apiService!.getUserPickupSchedules();
  print('📦 Got ${schedules.length} schedules');
} catch (e) {
  print('❌ API Error: $e'); // You'll see this
}
```

---

### **Step 4: Test Status Change Detection**

#### **A. Create Schedule**
```bash
# 1. Login sebagai user
# 2. Create new schedule
# 3. Check console:
🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 1 schedules
📊 [GlobalNotification] Schedule count changed: 0 → 1
```

#### **B. Mitra Accept (Manual Database)**
```sql
-- Update status di database
UPDATE pickup_schedules 
SET status = 'accepted', 
    mitra_id = 8,
    accepted_at = NOW(),
    updated_at = NOW()
WHERE id = 75;

-- Verify
SELECT id, status, updated_at FROM pickup_schedules WHERE id = 75;
```

#### **C. Wait & Check Console**
```bash
# Wait max 30 seconds
# Should see:

🔄 [GlobalNotification] Checking for updates...
📦 [GlobalNotification] Got 1 schedules

🔔 [GlobalNotification] Status Change Detected!
   Schedule ID: 75
   Old Status: pending
   New Status: accepted
   Address: Jl. Sudirman...
   Day: Minggu, 17 Nov 2025
   Time: 10:28

✅ Showing "Jadwal Diterima" banner...
```

**If shows status change BUT banner NOT appearing:**

**Problem: Context is null**
```dart
// Check global_notification_polling_service.dart line ~193
final context = _navigatorKey?.currentContext;
if (context == null) {
  print('⚠️ [GlobalNotification] No context available'); // You'll see this
  return;
}
```

**Solution:** Check MaterialApp has navigatorKey:
```dart
// main.dart
MaterialApp(
  navigatorKey: _navigatorKey, // ✅ Must be here
  routes: {...},
)
```

---

### **Step 5: Test Banner Display**

**Manual Test:**
```dart
// Add test button di home page atau anywhere:
ElevatedButton(
  onPressed: () {
    InAppNotificationService.show(
      context: context,
      title: 'Test Notification',
      message: 'This is a test message',
      subtitle: 'Test subtitle',
      type: InAppNotificationType.success,
    );
  },
  child: Text('Test Banner'),
)
```

**Expected:** Banner muncul dari atas dengan animasi slide.

**If NOT appearing:**
- Context invalid
- Overlay not found
- Z-index issue

---

## 🧪 Complete Test Flow

### **Test 1: Manual Database Update**

```bash
# 1. Run app
flutter run

# 2. Login as end_user
# Console should show:
✅ Global notification polling started
🚀 [GlobalNotification] Polling started

# 3. Create schedule via app

# 4. Open database and update:
UPDATE pickup_schedules 
SET status = 'accepted' 
WHERE status = 'pending' 
LIMIT 1;

# 5. Wait max 30 seconds

# 6. Console should show:
🔔 [GlobalNotification] Status Change Detected!
✅ Showing "Jadwal Diterima" banner...

# 7. Banner should appear on screen! 🎉
```

---

### **Test 2: Via API (Mitra Accept)**

```bash
# 1. User: Login & create schedule
# 2. Get schedule ID from database or console

# 3. Test mitra accept API:
curl -X POST "http://localhost:8000/api/mitra/pickup-schedules/75/accept" \
  -H "Authorization: Bearer MITRA_TOKEN" \
  -H "Content-Type: application/json"

# 4. Check response:
{
  "success": true,
  "data": {
    "status": "accepted" // ✅ Status changed
  }
}

# 5. Wait max 30 seconds
# 6. Banner should appear! 🎉
```

---

## 📊 Common Issues & Solutions

### **Issue 1: "Polling tidak jalan"**

**Symptoms:**
- No logs "🔄 Checking for updates..."
- No logs every 30 seconds

**Causes:**
1. `startPolling()` tidak dipanggil
2. User role bukan 'end_user'
3. Token null/expired

**Solutions:**
```dart
// Check sign_in_page.dart
// Make sure only for end_user:
case 'end_user':
  await GlobalNotificationPollingService().startPolling(); // ✅
  break;

case 'mitra':
  // No polling for mitra ✅
  break;
```

---

### **Issue 2: "Status change detected tapi banner tidak muncul"**

**Symptoms:**
- Log shows: "🔔 Status Change Detected!"
- Log shows: "✅ Showing banner..."
- But NO visual banner

**Causes:**
1. Context null
2. Navigator key tidak terpasang
3. Overlay issue

**Solutions:**
```dart
// 1. Check main.dart
MaterialApp(
  navigatorKey: _navigatorKey, // ✅ MUST BE HERE
)

// 2. Check service can get context
final context = _navigatorKey?.currentContext;
if (context == null) {
  print('❌ CONTEXT NULL!'); // This is the problem
}

// 3. Test banner manual
InAppNotificationService.show(
  context: context,
  title: 'Test',
  message: 'Test',
  type: InAppNotificationType.success,
);
```

---

### **Issue 3: "Banner muncul tapi tidak dari atas"**

**Cause:** Animation issue

**Solution:**
```dart
// Check in_app_notification_service.dart
_slideAnimation = Tween<Offset>(
  begin: const Offset(0, -1), // ✅ Must be negative Y for top
  end: Offset.zero,
).animate(...)
```

---

### **Issue 4: "Backend tidak return field yang benar"**

**Symptoms:**
- Polling works
- Status change detected
- But some field missing in schedule data

**Check backend response:**
```bash
curl -X GET "http://localhost:8000/api/user/pickup-schedules" \
  -H "Authorization: Bearer USER_TOKEN" | jq '.'
```

**Expected fields:**
```json
{
  "data": [{
    "id": 75,
    "status": "accepted",           // ✅ Must have
    "pickup_address": "...",        // ✅ Must have
    "schedule_day": "Minggu, 17 Nov 2025",  // ✅ Must have
    "pickup_time_start": "10:28",   // ✅ Must have
    "total_weight_kg": null,        // For completed
    "total_points": null            // For completed
  }]
}
```

**Missing fields?** Share `BACKEND_IN_APP_NOTIFICATION_REQUIREMENTS.md` dengan backend team.

---

## 🎯 Quick Debug Commands

### **Check if polling is running:**
```dart
// Add to home page or anywhere:
void _checkPollingStatus() {
  final service = GlobalNotificationPollingService();
  print('Polling running: ${service.isRunning}');
  print('Cached schedules: ${service.cachedSchedulesCount}');
}
```

### **Force refresh polling:**
```dart
// Trigger polling immediately (not wait 30s)
await GlobalNotificationPollingService().forceRefresh();
```

### **Test banner manual:**
```dart
// Show test banner
InAppNotificationService.show(
  context: context,
  title: 'Test Notification',
  message: 'If you see this, banner works!',
  type: InAppNotificationType.success,
);
```

---

## ✅ Success Checklist

When everything works, you should see:

- [x] ✅ Service initialized on app start
- [x] 🚀 Polling started after login
- [x] 🔄 Polling logs every 30 seconds
- [x] 🔔 Status change detected
- [x] ✅ Banner displayed visually
- [x] 📱 Banner animates from top
- [x] ⏱️ Banner auto-dismisses after 5s
- [x] 👆 Banner responds to tap/swipe

---

## 📞 Still Not Working?

### **Share these with me:**

1. **Console logs dari app start sampai 1 menit:**
   ```
   Copy semua output dari:
   flutter run
   ```

2. **Backend API response:**
   ```bash
   curl -X GET "YOUR_API/api/user/pickup-schedules" \
     -H "Authorization: Bearer YOUR_TOKEN" | jq '.'
   ```

3. **Database schedule data:**
   ```sql
   SELECT id, status, pickup_address, scheduled_pickup_at, updated_at 
   FROM pickup_schedules 
   WHERE user_id = YOUR_USER_ID 
   ORDER BY created_at DESC 
   LIMIT 5;
   ```

4. **User role:**
   ```
   Login sebagai: end_user / mitra / admin?
   ```

---

**Next:** Run app dengan debug mode dan share console output lengkap! 🔍
