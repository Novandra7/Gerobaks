# 🔥 Firebase Push Notification - Flutter Implementation Guide

**Date:** November 14, 2025  
**Status:** ✅ READY FOR INTEGRATION  
**Backend:** ✅ Complete  
**Frontend:** ✅ Code Ready, Needs Firebase Setup  

---

## 📋 Implementation Summary

### ✅ Yang Sudah Dibuat:

1. **Dependencies Added** (`pubspec.yaml`)
   - `firebase_core: ^3.1.0`
   - `firebase_messaging: ^15.0.1`

2. **FirebaseMessagingService Created** (`lib/services/firebase_messaging_service.dart`)
   - FCM token management
   - Push notification handling
   - Local notification display
   - Backend API integration

3. **NotificationApiService Updated** (`lib/services/notification_api_service.dart`)
   - `registerFcmToken()` method
   - `removeFcmToken()` method

---

## 🚀 Setup Steps

### Step 1: Install Dependencies

```bash
cd /Users/ajiali/Development/projects/Gerobaks
flutter pub get
```

### Step 2: Firebase Project Setup

#### A. Create/Configure Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select existing project or create new one: **"Gerobaks"**
3. Add Android app:
   - Package name: `com.example.bank_sha` (check di `android/app/build.gradle`)
   - Download `google-services.json`
   - Place in `android/app/google-services.json`

4. Add iOS app (if needed):
   - Bundle ID: check di `ios/Runner.xcodeproj`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

#### B. Android Configuration

**File:** `android/build.gradle`

Add Google Services classpath:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**File:** `android/app/build.gradle`

Add plugin at the bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Add dependency:
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

**File:** `android/app/src/main/AndroidManifest.xml`

Add inside `<application>`:
```xml
<service
    android:name="com.google.firebase.messaging.MessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

#### C. iOS Configuration (Optional)

**File:** `ios/Podfile`

Add at top:
```ruby
platform :ios, '12.0'
```

Run:
```bash
cd ios
pod install
cd ..
```

### Step 3: Initialize in main.dart

**File:** `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bank_sha/services/firebase_messaging_service.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background notification: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Firebase Messaging Service
  final firebaseMessaging = FirebaseMessagingService();
  await firebaseMessaging.initialize();
  
  runApp(MyApp());
}
```

### Step 4: Login Integration

**Update your login flow to initialize FCM after successful login:**

```dart
Future<void> _handleLogin() async {
  // ... existing login code ...
  
  if (loginSuccess) {
    // Save token to local storage
    await localStorage.saveToken(authToken);
    
    // Initialize Firebase Messaging with new token
    final firebaseMessaging = FirebaseMessagingService();
    await firebaseMessaging.initialize();
    
    // Navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### Step 5: Logout Integration

**Update logout to remove FCM token:**

```dart
Future<void> _handleLogout() async {
  // Remove FCM token from backend
  final firebaseMessaging = FirebaseMessagingService();
  await firebaseMessaging.removeFcmToken();
  
  // Clear local storage
  await localStorage.clearAll();
  
  // Navigate to login
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## 🧪 Testing

### Test 1: FCM Token Registration

1. Run app: `flutter run`
2. Login as user
3. Check console logs:
```
✅ FCM Token obtained: fKj9X2ePT...
✅ FCM token registered with backend
```

4. Verify in backend database:
```sql
SELECT * FROM user_fcm_tokens WHERE user_id = 15;
```

### Test 2: Receive Notification (Schedule Accepted)

1. Login as mitra in separate device/emulator
2. Accept a schedule
3. Check end user app:
   - Should receive push notification
   - Notification appears in notification list
   - Badge count increases

**Console logs:**
```
📨 Foreground message received
   - Title: Jadwal Penjemputan Diterima! 🎉
   - Body: Mitra telah menerima jadwal...
✅ Local notification shown
```

### Test 3: Receive Notification (Schedule Completed)

1. Mitra completes pickup
2. Check end user app:
   - Receives notification with points
   - Points updated in profile
   - Schedule status shows "Selesai"

### Test 4: Background Notification

1. Put app in background (press home button)
2. Trigger notification from backend
3. Should receive notification in system tray
4. Tap notification → app opens to notification list

### Test 5: App Terminated

1. Kill app (swipe away from recent apps)
2. Trigger notification from backend
3. Should receive notification in system tray
4. Tap notification → app launches to notification list

---

## 📊 Notification Flow

### Complete Flow Diagram:

```
1. User creates schedule
   ↓
2. Mitra accepts schedule
   ↓
3. Backend sends notification:
   POST /api/mitra/pickup-schedules/{id}/accept
   ↓
4. NotificationService.sendToUser():
   - Save to notifications table ✅
   - Get FCM tokens from user_fcm_tokens ✅
   - Send FCM push notification ✅
   ↓
5. Firebase Cloud Messaging:
   - Delivers to user's device ✅
   ↓
6. FirebaseMessagingService (Flutter):
   - Receives RemoteMessage ✅
   - Shows local notification ✅
   - Updates badge count ✅
   ↓
7. User sees notification:
   - System tray notification ✅
   - Sound plays (nf_gerobaks) ✅
   - Badge on app icon ✅
   ↓
8. User taps notification:
   - App opens ✅
   - Navigates to activity page ✅
   - Marks as read ✅
```

---

## 🎨 Notification Examples

### Example 1: Schedule Accepted

**Push Notification:**
```
╔════════════════════════════════════╗
║ 🎉 Jadwal Penjemputan Diterima!   ║
║────────────────────────────────────║
║ Mitra telah menerima jadwal        ║
║ penjemputan Anda pada Jumat,       ║
║ 15 Nov 2025 pukul 10:28.          ║
╚════════════════════════════════════╝
```

**Data Payload:**
```json
{
  "schedule_id": "75",
  "schedule_day": "Jumat, 15 Nov 2025",
  "pickup_time": "10:28",
  "action_url": "/activity"
}
```

### Example 2: Schedule Completed

**Push Notification:**
```
╔════════════════════════════════════╗
║ ✅ Penjemputan Selesai!            ║
║────────────────────────────────────║
║ Sampah Anda telah berhasil         ║
║ dijemput seberat 5.5 kg.           ║
║ Anda mendapatkan 55 poin!         ║
╚════════════════════════════════════╝
```

**Data Payload:**
```json
{
  "schedule_id": "75",
  "total_weight": "5.5",
  "points_earned": "55",
  "total_points": "1055",
  "action_url": "/activity"
}
```

---

## 🐛 Troubleshooting

### Issue 1: "Firebase not initialized"
**Error:** `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution:**
```dart
// Make sure Firebase.initializeApp() is called before using Firebase
await Firebase.initializeApp();
```

### Issue 2: "google-services.json not found"
**Error:** `File google-services.json is missing`

**Solution:**
1. Download from Firebase Console
2. Place in `android/app/google-services.json`
3. Rebuild: `flutter clean && flutter run`

### Issue 3: "FCM token is null"
**Error:** FCM token returns null

**Causes:**
- App not connected to internet
- Google Play Services not available (Android)
- Notification permission denied

**Solution:**
- Check internet connection
- Update Google Play Services
- Request notification permission again

### Issue 4: "Notifications not showing"
**Possible causes:**
- No FCM token registered
- User denied notification permission
- Backend not sending FCM push
- Firebase credentials not configured

**Debug steps:**
1. Check console logs for FCM token
2. Verify token in database
3. Check backend logs for FCM send
4. Verify Firebase credentials in backend

### Issue 5: "Sound not playing"
**Solution:**
- Make sure `nf_gerobaks.mp3` exists in `android/app/src/main/res/raw/`
- Make sure `nf_gerobaks.wav` exists in `ios/Runner/` (for iOS)
- Check notification channel settings

---

## ✅ Checklist

### Setup:
- [ ] Install dependencies (`flutter pub get`)
- [ ] Create Firebase project
- [ ] Add Android app to Firebase
- [ ] Download `google-services.json`
- [ ] Update `android/build.gradle`
- [ ] Update `android/app/build.gradle`
- [ ] Add Firebase service in `AndroidManifest.xml`

### Code Integration:
- [ ] Initialize Firebase in `main.dart`
- [ ] Setup background message handler
- [ ] Initialize FirebaseMessagingService
- [ ] Update login flow
- [ ] Update logout flow

### Testing:
- [ ] Test FCM token registration
- [ ] Test schedule accepted notification
- [ ] Test schedule completed notification
- [ ] Test background notifications
- [ ] Test app terminated notifications
- [ ] Test notification tap navigation

---

## 📞 Files Modified/Created

### Created:
- ✅ `lib/services/firebase_messaging_service.dart` - FCM handler
- ✅ `android/app/google-services.json` - Firebase config (needs download)

### Modified:
- ✅ `pubspec.yaml` - Added Firebase dependencies
- ✅ `lib/services/notification_api_service.dart` - Added FCM token methods
- ⏳ `lib/main.dart` - Needs Firebase initialization
- ⏳ `android/build.gradle` - Needs Google Services classpath
- ⏳ `android/app/build.gradle` - Needs Google Services plugin
- ⏳ `android/app/src/main/AndroidManifest.xml` - Needs Firebase service

---

## 🎯 Next Steps

1. **Run `flutter pub get`** - Install dependencies
2. **Setup Firebase project** - Download google-services.json
3. **Update Android configs** - build.gradle files
4. **Initialize in main.dart** - Add Firebase.initializeApp()
5. **Test on real device** - Emulator might not support FCM properly
6. **Verify with backend** - Check notifications are sent

---

## 📱 Backend API Endpoints Used

- `POST /api/user/fcm-token` - Register FCM token
- `DELETE /api/user/fcm-token` - Remove FCM token
- `GET /api/user/notifications` - Get notifications list
- `GET /api/user/notifications/unread-count` - Get unread count
- `PUT /api/user/notifications/{id}/read` - Mark as read

---

**Ready to implement!** 🚀

**Estimated time:** 1-2 hours for complete setup and testing
