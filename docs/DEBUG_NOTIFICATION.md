# 🐛 Debug Guide: Notification Feature

## Issue: "0 items" dan "Error loading notifications"

### Kemungkinan Penyebab:

#### 1. ❌ Backend Tidak Running
```bash
# Check apakah Laravel serve running
curl http://127.0.0.1:8000/api/notifications

# Jika gagal, start backend:
cd /path/to/laravel/project
php artisan serve
```

#### 2. ❌ Token Invalid atau Expired
```bash
# Test login dulu
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "YOUR_TOKEN_HERE",
    "token_type": "Bearer",
    "user": {...}
  }
}
```

#### 3. ❌ Tidak Ada Data Notification
```bash
# Create test notification via tinker
php artisan tinker

# Copy paste code dari docs/create_test_notifications.php
# Atau manual:
\App\Models\Notification::create([
    'user_id' => 1,  // Ganti dengan user_id yang valid
    'type' => 'schedule',
    'category' => 'waste_pickup',
    'title' => 'Test Notification',
    'message' => 'This is a test',
    'priority' => 'high',
    'is_read' => 0,
    'data' => json_encode(['test' => true]),
]);

# Check count
\App\Models\Notification::count();
```

#### 4. ❌ API Response Format Salah

**Expected API Response Format:**
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": 1,
        "user_id": 1,
        "type": "schedule",
        "category": "waste_pickup",
        "title": "Pengambilan Sampah Organik Hari Ini!",
        "message": "Jangan lupa!...",
        "icon": "eco",
        "priority": "high",
        "data": "{\"waste_type\":\"Organik\"}",
        "is_read": 0,
        "read_at": null,
        "created_at": "2024-01-15T06:00:00.000000Z",
        "updated_at": "2024-01-15T06:00:00.000000Z",
        "user": {
          "id": 1,
          "name": "John Doe",
          "email": "user@example.com"
        }
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 10,
      "total": 5,
      "last_page": 1
    },
    "summary": {
      "total_count": 5,
      "unread_count": 4,
      "read_count": 1
    }
  }
}
```

#### 5. ❌ CORS Issue
```bash
# Check Laravel CORS config
# File: config/cors.php

return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],  // Atau specific domain
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

---

## Langkah Debug:

### Step 1: Check Flutter Logs
```bash
flutter run --verbose
```

Look for:
```
🔔 Fetching notifications...
   - Page: 1, Per Page: 10
📦 Response status: 200
📦 Response data: {...}
✅ Notifications fetched: X items
```

### Step 2: Check Backend Logs
```bash
# Terminal backend
tail -f storage/logs/laravel.log
```

### Step 3: Test API Manual
```bash
# Run test script
bash docs/TEST_NOTIFICATION_BACKEND.sh

# Atau manual
TOKEN="your_token_here"

curl -X GET "http://127.0.0.1:8000/api/notifications" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq .
```

### Step 4: Check Database
```bash
php artisan tinker

# Check notifications table
>>> \App\Models\Notification::count()
>>> \App\Models\Notification::where('is_read', 0)->count()
>>> \App\Models\Notification::latest()->first()
```

---

## Common Errors:

### Error 401: Unauthorized
```
🔒 Unauthorized: Token invalid atau expired
```

**Solution:**
- User belum login
- Token expired
- Token tidak di-set di API service
- Re-login dan get new token

### Error 404: Not Found
```
🔍 Not Found: Resource tidak ditemukan
```

**Solution:**
- Route `/api/notifications` tidak terdaftar
- Check `routes/api.php`
- Check API base URL

### Error 422: Validation Error
```
⚠️ Validation Error
```

**Solution:**
- Parameter query invalid
- Check format `is_read` (harus 0 atau 1, bukan true/false)
- Check format date jika ada filter by date

### Error 500: Server Error
```
🔥 Server Error
```

**Solution:**
- Check Laravel logs
- Database connection error
- Missing table/column
- Run migration: `php artisan migrate`

### Network Error
```
🌐 Network Error: Failed host lookup
```

**Solution:**
- Backend tidak running
- Wrong base URL
- Firewall blocking
- Check `lib/shared/config.dart` untuk base URL

---

## Quick Test Checklist:

- [ ] Backend running (`php artisan serve`)
- [ ] User sudah login dengan token valid
- [ ] Ada data di tabel `notifications`
- [ ] API endpoint return 200
- [ ] Response format sesuai expected
- [ ] Token di-set di NotificationApiService
- [ ] Base URL correct di config
- [ ] CORS configured properly
- [ ] No errors di console log

---

## Debug Output yang Harus Muncul:

### Di Flutter Console:
```
🔄 NotificationScreen: Loading notifications...
   - Current tab: 0
   - Filter isRead: null
🔔 Fetching notifications...
   - Page: 1, Per Page: 10
📦 Response status: 200
📦 Response data: {success: true, data: {...}}
✅ Notifications fetched: 5 items
✅ NotificationScreen: Received 5 notifications
   - Unread count: 4
```

### Di Backend Terminal:
```
[2024-01-15 10:30:45] local.INFO: GET /api/notifications
[2024-01-15 10:30:45] local.INFO: Auth user: 1
[2024-01-15 10:30:45] local.INFO: Query: SELECT * FROM notifications WHERE user_id = 1
[2024-01-15 10:30:45] local.INFO: Found: 5 notifications
```

---

## Test Script Usage:

```bash
# 1. Make script executable
chmod +x docs/TEST_NOTIFICATION_BACKEND.sh

# 2. Edit credentials di script
# EMAIL="user@example.com"
# PASSWORD="password"

# 3. Run test
bash docs/TEST_NOTIFICATION_BACKEND.sh

# 4. Create test data
php artisan tinker < docs/create_test_notifications.php
```

---

## Still Not Working?

1. **Check API Response di Postman/Insomnia:**
   - Import collection dari `docs/API_NOTIFICATION_SPEC.md`
   - Test manual semua endpoint

2. **Enable Debug Mode:**
   ```dart
   // lib/services/notification_api_service.dart
   // All print statements sudah ada untuk debug
   ```

3. **Check Network Inspector:**
   - Chrome DevTools → Network tab
   - Filter: `/notifications`
   - Check request headers, response

4. **Restart Everything:**
   ```bash
   # Kill backend
   killall php
   
   # Restart backend
   php artisan serve
   
   # Kill Flutter
   # Tekan q di terminal flutter
   
   # Restart Flutter
   flutter run
   ```

---

**Next:** Jika masih error, paste output lengkap dari:
1. Flutter console (dengan `flutter run --verbose`)
2. Backend response (dari curl/test script)
3. Laravel logs (`storage/logs/laravel.log`)
