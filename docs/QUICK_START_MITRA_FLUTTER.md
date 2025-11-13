# Quick Start - Mitra Pickup System Integration

## 🚀 Setup (5 minutes)

### 1. Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  logger: ^2.0.2
  intl: ^0.19.0
  image_picker: ^1.0.4
  url_launcher: ^6.2.1
```

Run:
```bash
flutter pub get
```

### 2. Configure API Base URL
Open `lib/utils/api_routes.dart` and update:
```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### 3. Add Route
In your main app routes, add:
```dart
import 'package:your_app/ui/pages/mitra/mitra_home_page.dart';

// In MaterialApp or route configuration:
routes: {
  '/mitra/home': (context) => const MitraHomePage(),
  // ... other routes
}
```

### 4. Add Navigation
Where you want to show mitra features (e.g., after login):
```dart
// Check if user is mitra
if (userRole == 'mitra') {
  Navigator.pushNamed(context, '/mitra/home');
}
```

## 📱 Permissions

### Android
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS
`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Untuk mengambil foto sampah</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Untuk memilih foto sampah</string>
```

## 🧪 Test Integration

### Quick Test Flow:
1. Run app: `flutter run`
2. Login as mitra user
3. Navigate to `/mitra/home`
4. Check "Tersedia" tab - should load pending schedules
5. Accept a schedule
6. Check "Aktif" tab - should show accepted schedule
7. Complete pickup with photos + weights
8. Check "Riwayat" tab - should show completed schedule

### Debug API Calls
The service uses Logger. Check console for:
```
📋 Fetching available schedules: ...
✅ Accepting schedule: ...
📦 Completing pickup: ...
```

## 🔧 Troubleshooting

### Problem: "Token tidak ditemukan"
**Solution:** Ensure user is logged in and token is saved in LocalStorage:
```dart
await localStorage.saveToken(token);
```

### Problem: Network errors
**Solution:** Check:
1. API base URL is correct
2. Backend is running
3. Device has internet connection
4. CORS enabled on backend (if testing on web)

### Problem: Photos not uploading
**Solution:** Check:
1. Permissions granted (camera, storage)
2. Photos exist at path
3. Backend accepts multipart/form-data
4. File size limits on backend

### Problem: Empty schedule list
**Solution:** Check:
1. Backend has pending schedules in database
2. User is authenticated as mitra
3. API endpoint returns correct response format
4. Check backend logs for errors

## 📡 API Response Format

Your backend should return responses matching this format:

### GET /api/mitra/pickup-schedules/available
```json
{
  "success": true,
  "message": "Jadwal tersedia",
  "data": {
    "schedules": [
      {
        "id": 1,
        "user_id": 123,
        "user_name": "John Doe",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 1",
        "latitude": -6.2088,
        "longitude": 106.8456,
        "schedule_day": "Senin",
        "scheduled_pickup_at": "2024-01-15T10:00:00Z",
        "pickup_time_start": "10:00",
        "pickup_time_end": "12:00",
        "waste_type_scheduled": "Organik,Plastik",
        "waste_summary": "Organik: 5kg, Plastik: 3kg",
        "status": "pending",
        "created_at": "2024-01-10T08:00:00Z"
      }
    ]
  }
}
```

### POST /api/mitra/pickup-schedules/{id}/complete
Request (multipart/form-data):
```
actual_weights[Organik]: 5.5
actual_weights[Plastik]: 3.2
notes: Sampah sudah dipilah dengan baik
photos[]: file1.jpg
photos[]: file2.jpg
```

Response:
```json
{
  "success": true,
  "message": "Pengambilan berhasil diselesaikan",
  "data": {
    "schedule": { /* updated schedule */ },
    "points_earned": 87,
    "total_weight": 8.7
  }
}
```

## 🎯 Next Steps

1. ✅ Setup complete
2. Test with backend API
3. Customize UI colors/branding if needed
4. Add push notifications (optional)
5. Deploy to production

## 📚 Documentation

- **Full Documentation:** `docs/MITRA_FLUTTER_IMPLEMENTATION.md`
- **Backend Documentation:** `docs/BACKEND_COMPLETE_GUIDE.md`
- **API Service:** `lib/services/mitra_api_service.dart`
- **Models:** `lib/models/mitra_pickup_schedule.dart`

## ✅ Verification Checklist

- [ ] Dependencies installed
- [ ] API base URL configured
- [ ] Routes added
- [ ] Permissions configured
- [ ] Backend API running
- [ ] Test user created (role: mitra)
- [ ] Sample schedules in database
- [ ] App runs without errors
- [ ] Can view available schedules
- [ ] Can accept schedule
- [ ] Can upload photos
- [ ] Can complete pickup
- [ ] History shows completed schedules

Ready to go! 🚀
