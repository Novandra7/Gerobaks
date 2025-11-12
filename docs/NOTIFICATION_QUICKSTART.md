# 🎉 Notification Feature - Quick Start Guide

> **Status:** ✅ **READY TO USE**  
> **Commit:** `d632a0f`  
> **Files:** 5 new files created, 1995 lines added

---

## 📦 What's Included

### ✅ Complete Implementation

1. **Models** (`lib/models/notification_model.dart`)
   - NotificationModel
   - NotificationResponse  
   - UnreadCountResponse
   - Pagination & Summary models
   - Auto JSON parsing from backend

2. **API Service** (`lib/services/notification_api_service.dart`)
   - 6 endpoints fully integrated
   - Error handling
   - Token authentication
   - Backend compatibility (integer → boolean conversion)

3. **UI Screen** (`lib/ui/pages/user/notification_screen.dart`)
   - Complete notification screen
   - 3 tabs (All, Unread, Read)
   - Pull-to-refresh
   - Swipe-to-delete
   - Priority colors

4. **Widget** (`lib/widgets/notification_badge.dart`)
   - Reusable badge for AppBar
   - Auto-updates unread count
   - Urgent indicator (red dot)

5. **Documentation** (`docs/FLUTTER_NOTIFICATION_INTEGRATION.md`)
   - Complete integration guide
   - API usage examples
   - Testing instructions

---

## 🚀 How to Use (2 Steps!)

### Step 1: Add Route

Open your route configuration file and add:

```dart
'/notifications': (context) => const NotificationScreen(),
```

**Example in MaterialApp:**
```dart
MaterialApp(
  routes: {
    '/': (context) => HomePage(),
    '/notifications': (context) => const NotificationScreen(),
    // ... other routes
  },
)
```

### Step 2: Add Badge to AppBar

Open your main AppBar (Home, Dashboard, etc) and add:

```dart
import 'package:bank_sha/widgets/notification_badge.dart';

AppBar(
  title: Text('Home'),
  actions: [
    NotificationAppBarIcon(),  // ← Add this!
  ],
)
```

**That's it! You're done! 🎉**

---

## 🎯 How It Works

### User Flow:
1. User taps notification icon in AppBar
2. NotificationScreen opens with list of notifications
3. Badge shows unread count automatically
4. Red dot appears if urgent notification exists
5. User can:
   - Tap to read & navigate
   - Swipe to delete
   - Mark all as read
   - Filter by status (tabs)

### Backend Integration:
- Automatically fetches from: `http://127.0.0.1:8000/api/notifications`
- Uses Bearer token from localStorage
- Handles all 6 API endpoints
- Converts backend data format (integer is_read → boolean)
- Parses JSON string data field

---

## 📱 Features Demo

### Badge Counter
```
🔔 [5]  ← Shows unread count
🔔 •    ← Red dot for urgent notifications
```

### Notification Types
- 🗓️ **Schedule** - Pengangkutan hari ini (high priority, orange)
- ⏰ **Reminder** - Jadwal besok (normal priority, blue)
- ✅ **Info** - Pickup completed, points earned (normal, blue)
- 🔧 **System** - Updates & maintenance (low, grey)
- 🎁 **Promo** - Offers & discounts (low, grey)

### Priority Colors
- 🔴 **Urgent** - Red with glow effect
- 🟠 **High** - Orange (today's schedule)
- 🔵 **Normal** - Blue (most notifications)
- ⚪ **Low** - Grey (info, promos)

---

## 🔧 Advanced Usage (Optional)

### Custom Badge Position

```dart
// In BottomNavigationBar
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: NotificationBadge(
        showLabel: true,
        iconSize: 24,
      ),
      label: 'Notifikasi',
    ),
  ],
)
```

### Navigate from Notification

Automatically handled! Taps navigate based on type:
- **schedule** → `/schedule-detail` with schedule_id
- **reminder** → `/schedule`
- **info/system/promo** → Show detail dialog

### Change Base URL

For production, update in your API service:

```dart
final api = NotificationApiService(
  dio: dio,
  baseUrl: 'https://api.gerobaks.com/api',  // Production URL
);
```

---

## 🧪 Testing

### Test the API

```dart
// Get notifications
final response = await notificationApi.getNotifications();
print('Got ${response.notifications.length} notifications');

// Check unread count
final count = await notificationApi.getUnreadCount();
print('Unread: ${count.unreadCount}');

// Mark as read
await notificationApi.markAsRead(123);
```

### Test with Backend

```bash
# Make sure backend is running
php artisan serve

# Check endpoint
curl -X GET "http://127.0.0.1:8000/api/notifications/unread-count" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📋 Backend Requirements

Ensure backend has these endpoints:
- ✅ `GET /api/notifications`
- ✅ `GET /api/notifications/unread-count`
- ✅ `POST /api/notifications/{id}/mark-read`
- ✅ `POST /api/notifications/mark-all-read`
- ✅ `DELETE /api/notifications/{id}`
- ✅ `DELETE /api/notifications/clear-read`

**Backend Documentation:** `docs/API_NOTIFICATION_SPEC.md`

---

## ❗ Important Notes

### Backend Data Format
- Backend sends `is_read` as integer (0/1)
- Frontend converts to boolean automatically
- Backend sends `data` as JSON string
- Frontend parses to Map automatically

### Authentication
- Requires Bearer token
- Auto-fetched from localStorage
- If token invalid → shows error message
- User needs to re-login if 401 error

### Error Handling
All errors are handled gracefully:
- Network errors → Retry button
- 401 → "Please login again"
- 404 → "Notification not found"
- 500 → "Server error, try later"

---

## 📊 Project Stats

```
Files Created:      5
Lines Added:        1,995
API Endpoints:      6/6 (100%)
UI Components:      2 (Screen + Widget)
Models:            4 (Notification, Response, Pagination, Summary)
Error Handlers:    5 (401, 404, 422, 500, Network)
Documentation:     2 files (Integration Guide + API Spec)
Status:            ✅ Production Ready
```

---

## ✅ Final Checklist

Before deploying:
- [ ] Added `/notifications` route to app
- [ ] Added `NotificationAppBarIcon()` to AppBar
- [ ] Tested with backend API running
- [ ] Verified token authentication works
- [ ] Checked unread count displays correctly
- [ ] Tested mark as read functionality
- [ ] Tested swipe to delete
- [ ] Verified navigation from notifications works
- [ ] Updated backend base URL for production
- [ ] Tested error scenarios (no internet, invalid token)

---

## 🎓 Learn More

**Full Documentation:**
- Flutter Integration: `docs/FLUTTER_NOTIFICATION_INTEGRATION.md`
- Backend API Spec: `docs/API_NOTIFICATION_SPEC.md`

**Code Files:**
- Models: `lib/models/notification_model.dart`
- API Service: `lib/services/notification_api_service.dart`
- UI Screen: `lib/ui/pages/user/notification_screen.dart`
- Badge Widget: `lib/widgets/notification_badge.dart`

---

## 💬 Need Help?

**Common Issues:**

1. **Badge not showing count**
   - Check backend API is running
   - Verify token is valid
   - Check console for errors

2. **401 Unauthorized**
   - Token expired, user needs to re-login
   - Check token in localStorage

3. **Notifications not loading**
   - Backend API not running
   - Wrong base URL
   - Network connection issue

4. **Can't navigate to route**
   - Route not added to app router
   - Check route name matches

---

## 🎉 Success!

Your notification feature is now ready! Just add the route and badge, and you're good to go.

**Next Steps:**
1. Add route: `'/notifications': (context) => const NotificationScreen()`
2. Add badge: `NotificationAppBarIcon()` in AppBar
3. Test with backend running
4. Deploy! 🚀

---

**Created:** November 12, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready  
**Commit:** `d632a0f`

