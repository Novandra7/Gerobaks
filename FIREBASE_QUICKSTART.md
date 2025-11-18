# 🔥 Quick Reference - Push Notification Integration

**Status:** ✅ Code Ready | ⏳ Firebase Setup Needed  
**Time:** 1-2 hours  

---

## ⚡ Quick Setup (30 min)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Add Android app
3. Download `google-services.json` → `android/app/`

### 3. Android Config

**`android/build.gradle`:**
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

**`android/app/build.gradle`:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Initialize in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:bank_sha/services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await FirebaseMessagingService().initialize();
  
  runApp(MyApp());
}
```

---

## 🧪 Quick Test

```bash
# 1. Run app
flutter run

# 2. Check console for:
✅ FCM Token obtained: fKj9X2...
✅ FCM token registered with backend

# 3. Trigger notification from backend
# (Mitra accepts schedule)

# 4. See notification appear!
```

---

## 📁 Files Modified

### Created:
- ✅ `lib/services/firebase_messaging_service.dart`
- ⏳ `android/app/google-services.json` (download from Firebase)

### Modified:
- ✅ `pubspec.yaml` - Firebase dependencies
- ✅ `lib/services/notification_api_service.dart` - FCM methods
- ⏳ `lib/main.dart` - Firebase init
- ⏳ `android/build.gradle` - Google Services
- ⏳ `android/app/build.gradle` - Plugin

---

## 🎯 Notification Flow

```
Backend sends FCM
↓
Firebase delivers to device
↓
FirebaseMessagingService receives
↓
Shows local notification
↓
User taps → opens app
```

---

## ✅ Checklist

- [ ] `flutter pub get`
- [ ] Firebase project setup
- [ ] Download google-services.json
- [ ] Update build.gradle files
- [ ] Initialize in main.dart
- [ ] Test on real device

---

## 🔧 What's Included

### FirebaseMessagingService Features:
- ✅ Auto FCM token registration
- ✅ Push notification handling
- ✅ Local notification display
- ✅ Notification tap handling
- ✅ Background message support
- ✅ Token refresh handling

### NotificationApiService Methods:
- ✅ `registerFcmToken()` - Register with backend
- ✅ `removeFcmToken()` - Remove on logout
- ✅ `getNotifications()` - Get list
- ✅ `markAsRead()` - Mark as read

---

## 🎨 Notification Examples

**Schedule Accepted:**
```
🎉 Jadwal Penjemputan Diterima!
Mitra telah menerima jadwal penjemputan Anda
pada Jumat, 15 Nov 2025 pukul 10:28.
```

**Schedule Completed:**
```
✅ Penjemputan Selesai!
Sampah Anda telah berhasil dijemput seberat 5.5 kg.
Anda mendapatkan 55 poin! Total: 1055 poin.
```

---

## 🐛 Common Issues

**No notifications?**
- Check FCM token in console logs
- Verify token in database
- Test on real device (not emulator)

**Token null?**
- Check internet connection
- Check notification permission

**Sound not playing?**
- Add `nf_gerobaks.mp3` to `android/app/src/main/res/raw/`

---

## 📞 Full Documentation

- **Complete Guide:** `FLUTTER_FIREBASE_PUSH_NOTIFICATION_GUIDE.md`
- **Backend Doc:** `BACKEND_NOTIFICATION_SCHEDULE_EVENTS.md`

---

**Ready to implement!** 🚀
