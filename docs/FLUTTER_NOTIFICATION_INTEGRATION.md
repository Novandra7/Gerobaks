# 📱 Notification Feature - Flutter Implementation Guide

> **App:** Gerobaks - Waste Management System  
> **Feature:** Push Notification & In-App Notifications  
> **Backend API Version:** 1.0.0  
> **Date:** November 12, 2025  
> **Status:** ✅ Ready for Integration

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [File Structure](#file-structure)
3. [Models](#models)
4. [API Service](#api-service)
5. [UI Components](#ui-components)
6. [Integration Guide](#integration-guide)
7. [Usage Examples](#usage-examples)
8. [Testing](#testing)

---

## 🎯 Overview

Fitur notifikasi terintegrasi dengan backend API untuk:
- Menerima notifikasi jadwal pengangkutan sampah
- Reminder untuk jadwal besok
- Update status pickup (completed, cancelled)
- Informasi poin reward
- Sistem & promo notifications

### Key Features Implemented:
✅ 6 REST API endpoints fully integrated  
✅ Real-time unread count & badge indicator  
✅ Mark as read (single & bulk)  
✅ Swipe to delete notifications  
✅ Filter by status (All, Unread, Read)  
✅ Priority-based colors & icons  
✅ Pull-to-refresh  
✅ Urgent indicator (red dot)  
✅ JSON data field parsing  
✅ Error handling & retry logic  

---

## 📁 File Structure

```
lib/
├── models/
│   └── notification_model.dart          # Data models
├── services/
│   └── notification_api_service.dart    # API integration
├── widgets/
│   └── notification_badge.dart          # Reusable badge widget
└── ui/pages/user/
    └── notification_screen.dart         # Main notification screen
```

---

## 📦 Models

### File: `lib/models/notification_model.dart`

#### NotificationModel

```dart
class NotificationModel {
  final int id;
  final int userId;
  final String type;           // schedule, reminder, info, system, promo
  final String category;       // waste_pickup, waste_schedule, points, etc
  final String title;
  final String message;
  final String icon;           // Material icon name
  final String priority;       // urgent, high, normal, low
  final bool isRead;
  final Map<String, dynamic>? data;  // Parsed JSON data
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime updatedAt;
  
  // Helper getters
  int? get scheduleId => data?['schedule_id'];
  String? get wasteType => data?['waste_type'];
  bool get isUrgent => priority == 'urgent';
  bool get isSchedule => type == 'schedule';
}
```

**Important Notes:**
- `isRead` converted from backend integer (0/1) to boolean
- `data` field automatically parsed from JSON string
- Helper getters for common data fields

#### NotificationResponse

```dart
class NotificationResponse {
  final List<NotificationModel> notifications;
  final Pagination pagination;
  final Summary summary;
}
```

#### UnreadCountResponse

```dart
class UnreadCountResponse {
  final int unreadCount;
  final Map<String, int> byCategory;
  final Map<String, int> byPriority;
  final bool hasUrgent;
}
```

---

## 🔌 API Service

### File: `lib/services/notification_api_service.dart`

#### Initialization

```dart
final dio = Dio();
final notificationApi = NotificationApiService(dio: dio);

// Set auth token
final token = await localStorage.getToken();
notificationApi.setAuthToken(token);
```

#### Available Methods

##### 1. Get Notifications

```dart
Future<NotificationResponse> getNotifications({
  int page = 1,
  int perPage = 20,
  bool? isRead,        // null=all, false=unread, true=read
  String? type,        // schedule, reminder, info, etc
  String? category,
  String? priority,
})
```

**Example:**
```dart
// Get unread notifications only
final response = await notificationApi.getNotifications(
  page: 1,
  perPage: 20,
  isRead: false,
);

print('Unread: ${response.summary.unreadCount}');
for (var notif in response.notifications) {
  print('${notif.title}: ${notif.message}');
}
```

##### 2. Get Unread Count

```dart
Future<UnreadCountResponse> getUnreadCount()
```

**Example:**
```dart
final count = await notificationApi.getUnreadCount();
print('Total unread: ${count.unreadCount}');
print('Has urgent: ${count.hasUrgent}');
print('Urgent count: ${count.byPriority['urgent']}');
```

##### 3. Mark as Read

```dart
Future<Map<String, dynamic>> markAsRead(int notificationId)
```

**Example:**
```dart
await notificationApi.markAsRead(123);
print('Notification #123 marked as read');
```

##### 4. Mark All as Read

```dart
Future<Map<String, dynamic>> markAllAsRead()
```

**Example:**
```dart
final result = await notificationApi.markAllAsRead();
print('${result['marked_count']} notifications marked as read');
```

##### 5. Delete Notification

```dart
Future<Map<String, dynamic>> deleteNotification(int notificationId)
```

**Example:**
```dart
await notificationApi.deleteNotification(456);
print('Notification deleted');
```

##### 6. Clear Read Notifications

```dart
Future<int> clearReadNotifications()
```

**Example:**
```dart
final deletedCount = await notificationApi.clearReadNotifications();
print('$deletedCount read notifications deleted');
```

---

## 🎨 UI Components

### 1. NotificationScreen

**File:** `lib/ui/pages/user/notification_screen.dart`

Complete notification screen with:
- 3 tabs: Semua, Belum Dibaca, Sudah Dibaca
- Badge counter in AppBar
- Pull-to-refresh
- Swipe-to-delete
- Mark all as read button
- Clear read notifications menu
- Priority-based colors
- Urgent indicator

**Navigate to screen:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NotificationScreen(),
  ),
);
```

### 2. NotificationBadge Widget

**File:** `lib/widgets/notification_badge.dart`

Reusable badge widget untuk notification icon.

**Usage:**
```dart
// In AppBar
AppBar(
  actions: [
    NotificationAppBarIcon(
      onPressed: () {
        Navigator.pushNamed(context, '/notifications');
      },
    ),
  ],
)

// Custom usage
NotificationBadge(
  showLabel: true,
  iconSize: 24,
  onTap: () {
    // Handle tap
  },
)
```

**Features:**
- Auto-loads unread count
- Shows badge with number (max 99+)
- Red dot indicator for urgent notifications
- Glow effect on urgent dot

---

## 🚀 Integration Guide

### Step 1: Add Route

Add notification route to your router:

```dart
// In your route configuration
'/notifications': (context) => const NotificationScreen(),
```

### Step 2: Add Badge to AppBar

Update your main AppBar to show notification badge:

```dart
AppBar(
  title: Text('Home'),
  actions: [
    NotificationAppBarIcon(),  // Auto-navigates to notification screen
    // Or custom:
    NotificationBadge(
      onTap: () {
        Navigator.pushNamed(context, '/notifications');
      },
    ),
  ],
)
```

### Step 3: Handle Notification Taps

Notifications navigate based on type:

```dart
void _handleNotificationTap(NotificationModel notif) {
  switch (notif.type) {
    case 'schedule':
      // Navigate to schedule detail
      if (notif.scheduleId != null) {
        Navigator.pushNamed(
          context,
          '/schedule-detail',
          arguments: notif.scheduleId,
        );
      }
      break;
      
    case 'reminder':
      Navigator.pushNamed(context, '/schedule');
      break;
      
    case 'info':
    case 'system':
    case 'promo':
      // Show dialog with details
      showDialog(...);
      break;
  }
}
```

### Step 4: Periodic Updates (Optional)

Add background polling for real-time updates:

```dart
Timer? _pollTimer;

@override
void initState() {
  super.initState();
  
  // Poll every 60 seconds
  _pollTimer = Timer.periodic(
    const Duration(seconds: 60),
    (timer) {
      _loadUnreadCount();
    },
  );
}

@override
void dispose() {
  _pollTimer?.cancel();
  super.dispose();
}
```

---

## 💡 Usage Examples

### Example 1: Show Unread Count in Bottom Navigation

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: NotificationBadge(showLabel: true),
      label: 'Notifikasi',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

### Example 2: Custom Notification Card

```dart
Widget buildNotificationCard(NotificationModel notif) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: getPriorityColor(notif.priority),
        child: Icon(getIcon(notif.icon), color: Colors.white),
      ),
      title: Text(
        notif.title,
        style: TextStyle(
          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notif.message),
      trailing: !notif.isRead 
        ? Icon(Icons.circle, size: 8, color: Colors.blue)
        : null,
      onTap: () => handleTap(notif),
    ),
  );
}
```

### Example 3: Filter by Type

```dart
// Get only schedule notifications
final scheduleNotifs = await notificationApi.getNotifications(
  type: 'schedule',
  isRead: false,
);

// Get only urgent notifications
final urgentNotifs = await notificationApi.getNotifications(
  priority: 'urgent',
);
```

### Example 4: Parse Data Field

```dart
final notif = notifications.first;

// Access common fields
final scheduleId = notif.scheduleId;
final wasteType = notif.wasteType;
final pickupTime = notif.pickupTime;

// Or access raw data
final customField = notif.data?['custom_field'];
```

---

## 🧪 Testing

### Test API Integration

```dart
void testNotificationApi() async {
  final dio = Dio();
  final api = NotificationApiService(dio: dio);
  api.setAuthToken('your_test_token');
  
  // Test 1: Get notifications
  print('Test 1: Get notifications');
  final response = await api.getNotifications();
  print('✅ Got ${response.notifications.length} notifications');
  
  // Test 2: Get unread count
  print('Test 2: Get unread count');
  final count = await api.getUnreadCount();
  print('✅ Unread: ${count.unreadCount}');
  
  // Test 3: Mark as read
  if (response.notifications.isNotEmpty) {
    print('Test 3: Mark as read');
    final firstId = response.notifications.first.id;
    await api.markAsRead(firstId);
    print('✅ Marked #$firstId as read');
  }
  
  // Test 4: Mark all as read
  print('Test 4: Mark all as read');
  final result = await api.markAllAsRead();
  print('✅ Marked ${result['marked_count']} as read');
}
```

### Test with cURL

```bash
# Get notifications
curl -X GET "http://127.0.0.1:8000/api/notifications?is_read=0" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get unread count
curl -X GET "http://127.0.0.1:8000/api/notifications/unread-count" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Mark as read
curl -X POST "http://127.0.0.1:8000/api/notifications/1/mark-read" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ⚙️ Configuration

### Base URL

Update base URL in `NotificationApiService`:

```dart
// Development
final api = NotificationApiService(
  dio: dio,
  baseUrl: 'http://127.0.0.1:8000/api',
);

// Production
final api = NotificationApiService(
  dio: dio,
  baseUrl: 'https://api.gerobaks.com/api',
);
```

### Polling Interval

Adjust polling interval based on needs:

```dart
// Real-time (every 30 seconds)
Timer.periodic(Duration(seconds: 30), (timer) => loadUnread());

// Normal (every 60 seconds)
Timer.periodic(Duration(seconds: 60), (timer) => loadUnread());

// Minimal (every 5 minutes)
Timer.periodic(Duration(minutes: 5), (timer) => loadUnread());
```

---

## 🎨 Customization

### Priority Colors

```dart
Color getPriorityColor(String priority) {
  switch (priority) {
    case 'urgent':
      return Colors.red;
    case 'high':
      return Colors.orange;
    case 'normal':
      return Colors.blue;
    case 'low':
      return Colors.grey;
    default:
      return Colors.blue;
  }
}
```

### Icon Mapping

```dart
IconData getIcon(String iconName) {
  switch (iconName) {
    case 'calendar':
      return Icons.calendar_today;
    case 'warning':
      return Icons.warning;
    case 'eco':
      return Icons.eco;
    case 'recycling':
      return Icons.recycling;
    case 'stars':
      return Icons.stars;
    default:
      return Icons.notifications;
  }
}
```

---

## ❗ Error Handling

### Common Errors

**401 Unauthorized:**
```dart
// Token expired - redirect to login
if (error.response?.statusCode == 401) {
  Navigator.pushReplacementNamed(context, '/login');
}
```

**404 Not Found:**
```dart
// Notification not found or deleted
if (error.response?.statusCode == 404) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Notifikasi tidak ditemukan')),
  );
}
```

**Network Error:**
```dart
// No internet connection
try {
  await api.getNotifications();
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tidak ada koneksi'),
        content: Text('Periksa koneksi internet Anda'),
      ),
    );
  }
}
```

---

## ✅ Checklist

Implementation checklist:

- [x] NotificationModel created
- [x] NotificationResponse created
- [x] NotificationApiService implemented
- [x] All 6 API endpoints integrated
- [x] NotificationScreen UI created
- [x] NotificationBadge widget created
- [x] TabBar filters (All/Unread/Read)
- [x] Pull-to-refresh
- [x] Swipe-to-delete
- [x] Mark as read functionality
- [x] Mark all as read
- [x] Clear read notifications
- [x] Priority-based colors
- [x] Icon mapping
- [x] Urgent indicator
- [x] Error handling
- [ ] Add route to app router
- [ ] Integrate badge in AppBar
- [ ] Test with real backend API
- [ ] Handle notification taps/navigation
- [ ] Add periodic polling (optional)

---

## 📞 Support

**Issues?**
- Check token validity
- Verify backend API is running
- Check network connectivity
- Review console logs for errors

**Backend API Documentation:**
- See: `docs/API_NOTIFICATION_SPEC.md`
- Backend endpoint: `http://127.0.0.1:8000/api/notifications`

---

**Last Updated:** November 12, 2025  
**Flutter SDK:** ^3.0.0  
**Backend API:** v1.0.0  
**Status:** ✅ Ready for Integration

