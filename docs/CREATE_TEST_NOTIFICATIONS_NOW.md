# 🧪 Cara Buat Test Notifications (SEKARANG)

Karena backend belum setup cron job, kita buat test notifications manual.

## Opsi 1: Via Tinker (Recommended)

```bash
cd /path/to/laravel/project
php artisan tinker
```

Paste ini di tinker:

```php
// Buat 5 test notifications untuk user ID 14 (Ageng)
$userId = 14; // User yang login sekarang
$now = now();

// 1. Urgent - Truk Sudah Dekat (untuk test red dot)
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'schedule',
    'category' => 'waste_pickup',
    'title' => '🚨 Truk Sudah Dekat!',
    'message' => 'Truk pengangkut sampah akan tiba dalam 5 menit. Mohon persiapkan sampah Anda.',
    'icon' => 'local_shipping',
    'priority' => 'urgent',
    'is_read' => 0,
    'data' => json_encode(['waste_type' => 'B3', 'eta_minutes' => 5]),
    'created_at' => $now,
    'updated_at' => $now,
]);

// 2. High - Jadwal Hari Ini
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'schedule',
    'category' => 'waste_pickup',
    'title' => 'Pengambilan Sampah Organik Hari Ini!',
    'message' => 'Jangan lupa! Hari ini adalah jadwal pengambilan sampah Organik. Pastikan sampah sudah dipisahkan.',
    'icon' => 'eco',
    'priority' => 'high',
    'is_read' => 0,
    'data' => json_encode(['waste_type' => 'Organik', 'schedule_day' => 'selasa', 'pickup_time' => '06:00 - 08:00']),
    'created_at' => $now,
    'updated_at' => $now,
]);

// 3. Normal - Reminder Besok
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'reminder',
    'category' => 'waste_schedule',
    'title' => 'Besok Jadwal Sampah Anorganik',
    'message' => 'Besok adalah hari pengambilan sampah Anorganik. Siapkan sampah Anda sebelum jam 06:00 pagi.',
    'icon' => 'calendar_today',
    'priority' => 'normal',
    'is_read' => 0,
    'data' => json_encode(['waste_type' => 'Anorganik', 'schedule_day' => 'rabu']),
    'created_at' => $now->subHours(2),
    'updated_at' => $now->subHours(2),
]);

// 4. Read - Info (untuk test Read tab)
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'info',
    'category' => 'announcement',
    'title' => 'Tips Memilah Sampah',
    'message' => 'Tahukah Anda? Sampah organik seperti sisa makanan bisa dijadikan kompos!',
    'icon' => 'lightbulb',
    'priority' => 'low',
    'is_read' => 1,
    'read_at' => $now->subHour(),
    'data' => json_encode(['tips_category' => 'organic_waste']),
    'created_at' => $now->subHours(5),
    'updated_at' => $now->subHour(),
]);

// 5. System - Update
\App\Models\Notification::create([
    'user_id' => $userId,
    'type' => 'system',
    'category' => 'app_update',
    'title' => 'Fitur Notifikasi Aktif!',
    'message' => 'Anda sekarang akan menerima notifikasi otomatis untuk jadwal pengambilan sampah.',
    'icon' => 'notifications_active',
    'priority' => 'normal',
    'is_read' => 0,
    'data' => json_encode(['feature' => 'notifications', 'version' => '1.0.0']),
    'created_at' => $now->subMinutes(10),
    'updated_at' => $now->subMinutes(10),
]);

// Verify
echo "✅ Created 5 notifications!\n";
echo "Unread: " . \App\Models\Notification::where('user_id', $userId)->where('is_read', 0)->count() . "\n";
echo "Total: " . \App\Models\Notification::where('user_id', $userId)->count() . "\n";
```

## Opsi 2: Via SQL (Jika tinker tidak tersedia)

```sql
-- Ganti 14 dengan user_id yang aktif
SET @user_id = 14;
SET @now = NOW();

INSERT INTO notifications (user_id, type, category, title, message, icon, priority, is_read, data, created_at, updated_at) VALUES
(@user_id, 'schedule', 'waste_pickup', '🚨 Truk Sudah Dekat!', 'Truk pengangkut sampah akan tiba dalam 5 menit. Mohon persiapkan sampah Anda.', 'local_shipping', 'urgent', 0, '{"waste_type":"B3","eta_minutes":5}', @now, @now),
(@user_id, 'schedule', 'waste_pickup', 'Pengambilan Sampah Organik Hari Ini!', 'Jangan lupa! Hari ini adalah jadwal pengambilan sampah Organik. Pastikan sampah sudah dipisahkan.', 'eco', 'high', 0, '{"waste_type":"Organik","schedule_day":"selasa","pickup_time":"06:00 - 08:00"}', @now, @now),
(@user_id, 'reminder', 'waste_schedule', 'Besok Jadwal Sampah Anorganik', 'Besok adalah hari pengambilan sampah Anorganik. Siapkan sampah Anda sebelum jam 06:00 pagi.', 'calendar_today', 'normal', 0, '{"waste_type":"Anorganik","schedule_day":"rabu"}', DATE_SUB(@now, INTERVAL 2 HOUR), DATE_SUB(@now, INTERVAL 2 HOUR)),
(@user_id, 'info', 'announcement', 'Tips Memilah Sampah', 'Tahukah Anda? Sampah organik seperti sisa makanan bisa dijadikan kompos!', 'lightbulb', 'low', 1, '{"tips_category":"organic_waste"}', DATE_SUB(@now, INTERVAL 5 HOUR), DATE_SUB(@now, INTERVAL 1 HOUR)),
(@user_id, 'system', 'app_update', 'Fitur Notifikasi Aktif!', 'Anda sekarang akan menerima notifikasi otomatis untuk jadwal pengambilan sampah.', 'notifications_active', 'normal', 0, '{"feature":"notifications","version":"1.0.0"}', DATE_SUB(@now, INTERVAL 10 MINUTE), DATE_SUB(@now, INTERVAL 10 MINUTE));

-- Verify
SELECT COUNT(*) as total, 
       SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END) as unread
FROM notifications 
WHERE user_id = @user_id;
```

## Expected Result

Setelah buat notifications:
- Badge count: **4** (4 unread)
- Red dot: **Tampil** (ada 1 urgent)
- Tab All: **5 notifications**
- Tab Unread: **4 notifications**
- Tab Read: **1 notification**

## Test di Flutter App

1. Pull to refresh di notification screen
2. Badge seharusnya update otomatis
3. Red dot muncul karena ada urgent notification
4. Tap notification → Mark as read → Badge berkurang

---

**Setelah ini selesai, minta backend team setup cron job untuk otomatis notifications!**
