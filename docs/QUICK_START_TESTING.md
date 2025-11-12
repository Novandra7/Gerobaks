# 🚀 Quick Start: Testing Notification Feature

## Prerequisites:
- ✅ Backend Laravel running
- ✅ User sudah terdaftar dan bisa login
- ✅ Database sudah di-migrate

---

## Step 1: Dapatkan Credentials User 📝

### Option A: Cek User yang Ada
```bash
cd /path/to/laravel/project
php artisan tinker

# Lihat semua user
>>> \App\Models\User::all(['id', 'name', 'email', 'role', 'status']);

# Cari user dengan role end_user
>>> \App\Models\User::where('role', 'end_user')->first();
```

**Note:** Catat `email` dan `id` user yang akan digunakan untuk testing.

### Option B: Create User Baru
```bash
php artisan tinker

# Create user baru
>>> $user = \App\Models\User::create([
...   'name' => 'Test User',
...   'email' => 'testuser@example.com',
...   'password' => bcrypt('password123'),
...   'role' => 'end_user',
...   'status' => 'active',
... ]);

>>> echo "User ID: " . $user->id;
>>> echo "Email: " . $user->email;
```

**Credentials:**
- Email: `testuser@example.com`
- Password: `password123`
- User ID: (catat untuk step selanjutnya)

---

## Step 2: Test Login Manual 🔐

```bash
# Test login dengan credentials yang benar
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "1|xxxxxxxxxxxxxxxxxxxx",
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "name": "Test User",
      "email": "testuser@example.com",
      "role": "end_user"
    }
  }
}
```

✅ **Jika berhasil**, catat token-nya untuk step selanjutnya.

❌ **Jika gagal**, pastikan:
- Email & password benar
- User exists di database
- User status = 'active'
- Backend running di port 8000

---

## Step 3: Create Test Notifications 📬

```bash
cd /path/to/laravel/project
php artisan tinker
```

**Copy-paste code ini:**
```php
// Ganti USER_ID dengan ID user dari Step 1
$userId = 1; // ⚠️  GANTI SESUAI USER ID

// 1. High Priority Schedule
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'schedule',
    'category' => 'waste_pickup',
    'title' => 'Pengambilan Sampah Organik Hari Ini!',
    'message' => 'Jangan lupa! Hari ini adalah jadwal pengambilan sampah Organik.',
    'icon' => 'eco',
    'priority' => 'high',
    'is_read' => 0,
    'data' => json_encode(['waste_type' => 'Organik']),
]);

// 2. Urgent Notification (untuk test red dot)
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'reminder',
    'category' => 'waste_pickup',
    'title' => 'URGENT: Truk Sudah Dekat!',
    'message' => 'Truk pengangkut sampah sudah ada di area Anda!',
    'icon' => 'warning',
    'priority' => 'urgent',
    'is_read' => 0,
    'data' => json_encode(['distance' => '200m']),
]);

// 3. Normal Reminder
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'reminder',
    'category' => 'waste_schedule',
    'title' => 'Besok Jadwal Sampah Anorganik',
    'message' => 'Besok adalah hari pengambilan sampah Anorganik.',
    'icon' => 'calendar_today',
    'priority' => 'normal',
    'is_read' => 0,
    'data' => json_encode(['waste_type' => 'Anorganik']),
]);

echo "✅ Created 3 test notifications!\n";

// Verify
$count = \App\Models\Notification::where('user_id', $userId)->count();
echo "Total notifications for user $userId: $count\n";
```

---

## Step 4: Test API Endpoint 🧪

```bash
# Ganti TOKEN dengan token dari Step 2
TOKEN="1|xxxxxxxxxxxxxxxxx"

# Test 1: Get unread count
curl -X GET "http://127.0.0.1:8000/api/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq .

# Test 2: Get notifications list
curl -X GET "http://127.0.0.1:8000/api/notifications?page=1&per_page=10" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq .

# Test 3: Get unread notifications only
curl -X GET "http://127.0.0.1:8000/api/notifications?is_read=0" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq .
```

**Expected Results:**
- unread-count endpoint: `{"data": {"unread_count": 3, "has_urgent": true}}`
- notifications endpoint: List dengan 3 notifications
- Filter is_read=0: Semua 3 notifications (karena semua unread)

---

## Step 5: Test di Flutter App 📱

### A. Pastikan User Login di App
```bash
# Run Flutter app
cd /Users/ajiali/Development/projects/Gerobaks
flutter run
```

1. **Login** dengan credentials yang sama (testuser@example.com / password123)
2. Setelah login, cek **home screen**
3. **Lihat icon notification** di AppBar (kanan atas)

### B. Yang Harus Terlihat:
- ✅ **Badge merah** dengan angka "3" (unread count)
- ✅ **Red dot kecil** di pojok icon (urgent indicator)
- ✅ Icon notification bisa diklik

### C. Tap Icon Notification:
- ✅ Muncul **NotificationScreen** dengan 3 notifications
- ✅ Tab "Semua" menunjukkan 3 items
- ✅ Tab "Belum Dibaca" menunjukkan 3 items
- ✅ Tab "Sudah Dibaca" kosong (0 items)
- ✅ Notification URGENT warna **merah/orange**
- ✅ Notification HIGH warna **oranye**
- ✅ Notification NORMAL warna **biru**

### D. Test Interaksi:
1. **Tap notification** → Badge berkurang, notification berubah warna abu-abu
2. **Swipe to delete** → Notification hilang dari list
3. **Pull to refresh** → List reload
4. **Tap "Tandai Semua Dibaca"** → Semua jadi abu-abu, badge = 0

---

## Troubleshooting 🔍

### ❌ Login Gagal di Curl
**Error:** `The provided credentials are incorrect`

**Solution:**
1. Check email & password benar
2. Cek database: `SELECT * FROM users WHERE email='testuser@example.com'`
3. Password di-hash dengan bcrypt? `bcrypt('password123')`
4. User status = 'active'?

### ❌ Token Invalid (401 Unauthorized)
**Error:** `Unauthorized: Token invalid atau expired`

**Solution:**
1. Get token baru via login
2. Check format header: `Authorization: Bearer TOKEN` (ada spasi setelah Bearer)
3. Token tidak expired?

### ❌ No Notifications (0 items)
**Error:** Notifications list kosong

**Solution:**
1. Check database: `SELECT COUNT(*) FROM notifications WHERE user_id=1`
2. Create notifications dengan Step 3
3. Pastikan `user_id` sesuai dengan user yang login
4. Check `is_read = 0` (integer, bukan boolean)

### ❌ Notification Tidak Muncul di App
**Error:** Badge tidak muncul atau count = 0

**Solution:**
1. Check user sudah login? (ada token di LocalStorage)
2. Check backend running? `curl http://127.0.0.1:8000/api`
3. Check base URL di `lib/shared/config.dart`
4. Lihat Flutter console logs untuk error details
5. Restart app: Stop → `flutter run`

---

## Quick Commands Summary 📋

```bash
# 1. Check user
php artisan tinker
>>> \App\Models\User::where('role', 'end_user')->first();

# 2. Create test notifications
php artisan tinker < docs/create_test_notifications.php

# 3. Test login
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "EMAIL", "password": "PASSWORD"}'

# 4. Test API (ganti TOKEN)
curl -X GET "http://127.0.0.1:8000/api/notifications" \
  -H "Authorization: Bearer TOKEN" | jq .

# 5. Run Flutter
flutter run
```

---

## Expected Flow ✅

1. **Login di app** → Token saved
2. **Home screen loads** → Badge count fetched from API
3. **Badge shows "3"** → 3 unread notifications
4. **Red dot visible** → Has urgent notification
5. **Tap icon** → Open NotificationScreen
6. **List shows 3 items** → All unread
7. **Tap notification** → Mark as read, badge = 2
8. **Swipe delete** → Remove, badge = 1
9. **Pull refresh** → Reload from API

---

## Next Steps After Testing 🎯

Jika semua test berhasil:
1. ✅ Commit changes
2. ✅ Push ke branch
3. ✅ Backend team setup cron jobs (BACKEND_CRON_SETUP.md)
4. ✅ Production deployment

---

**Need Help?** Check `docs/DEBUG_NOTIFICATION.md` untuk troubleshooting lengkap.
