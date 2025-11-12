<?php
/**
 * 🧪 Create Test Notifications
 * 
 * Usage di terminal Laravel project:
 * php artisan tinker < docs/create_test_notifications.php
 * 
 * Atau copy-paste ke tinker:
 * php artisan tinker
 * >>> (paste code di bawah)
 */

use App\Models\Notification;
use App\Models\User;

// Get first active end_user
$user = User::where('role', 'end_user')
           ->where('status', 'active')
           ->first();

if (!$user) {
    echo "❌ No active end_user found!\n";
    echo "Please create a user with role='end_user' and status='active'\n";
    exit(1);
}

echo "✅ Using user: {$user->name} (ID: {$user->id})\n\n";

// 1. High Priority Schedule Notification
$notif1 = Notification::create([
    'user_id' => $user->id,
    'type' => 'schedule',
    'category' => 'waste_pickup',
    'title' => 'Pengambilan Sampah Organik Hari Ini!',
    'message' => 'Jangan lupa! Hari ini adalah jadwal pengambilan sampah Organik. Pastikan sampah sudah dipisahkan dan siap diambil pada pukul 06:00 - 08:00.',
    'icon' => 'eco',
    'priority' => 'high',
    'is_read' => 0,
    'data' => json_encode([
        'waste_type' => 'Organik',
        'schedule_day' => 'selasa',
        'pickup_time' => '06:00 - 08:00',
        'schedule_id' => 1,
    ]),
]);

echo "✅ Created: {$notif1->title}\n";

// 2. Urgent Notification (untuk test red dot)
$notif2 = Notification::create([
    'user_id' => $user->id,
    'type' => 'reminder',
    'category' => 'waste_pickup',
    'title' => 'URGENT: Truk Sudah Dekat!',
    'message' => 'Truk pengangkut sampah sudah ada di area Anda. Segera keluarkan sampah Anda!',
    'icon' => 'warning',
    'priority' => 'urgent',
    'is_read' => 0,
    'data' => json_encode([
        'waste_type' => 'B3',
        'distance' => '200m',
        'eta' => '2 menit',
    ]),
]);

echo "✅ Created: {$notif2->title}\n";

// 3. Normal Reminder
$notif3 = Notification::create([
    'user_id' => $user->id,
    'type' => 'reminder',
    'category' => 'waste_schedule',
    'title' => 'Besok Jadwal Sampah Anorganik',
    'message' => 'Besok adalah hari pengambilan sampah Anorganik. Siapkan sampah Anda sebelum jam 06:00 pagi.',
    'icon' => 'calendar_today',
    'priority' => 'normal',
    'is_read' => 0,
    'data' => json_encode([
        'waste_type' => 'Anorganik',
        'schedule_day' => 'rabu',
        'pickup_time' => '06:00 - 08:00',
    ]),
]);

echo "✅ Created: {$notif3->title}\n";

// 4. Info Notification (already read)
$notif4 = Notification::create([
    'user_id' => $user->id,
    'type' => 'info',
    'category' => 'points',
    'title' => 'Selamat! Anda Mendapat 50 Poin',
    'message' => 'Poin reward telah ditambahkan ke akun Anda untuk pengumpulan sampah kemarin.',
    'icon' => 'stars',
    'priority' => 'low',
    'is_read' => 1,
    'read_at' => now(),
    'data' => json_encode([
        'points' => 50,
        'total_points' => 350,
        'reason' => 'waste_pickup_completed',
    ]),
]);

echo "✅ Created: {$notif4->title} (already read)\n";

// 5. System Notification
$notif5 = Notification::create([
    'user_id' => $user->id,
    'type' => 'system',
    'category' => 'update',
    'title' => 'Update Aplikasi Tersedia',
    'message' => 'Versi baru aplikasi Gerobaks tersedia. Update sekarang untuk fitur terbaru!',
    'icon' => 'system_update',
    'priority' => 'normal',
    'is_read' => 0,
    'data' => json_encode([
        'version' => '2.1.0',
        'update_url' => 'https://play.google.com/store/apps/details?id=com.gerobaks',
    ]),
]);

echo "✅ Created: {$notif5->title}\n";

// Summary
echo "\n📊 Summary:\n";
echo "   - Total created: 5 notifications\n";
echo "   - Unread: 4 notifications\n";
echo "   - Read: 1 notification\n";
echo "   - Urgent: 1 notification (red dot should appear)\n";
echo "   - High priority: 1 notification\n";
echo "   - Normal priority: 2 notifications\n";
echo "   - Low priority: 1 notification\n";
echo "\n";

// Verify
$totalCount = Notification::where('user_id', $user->id)->count();
$unreadCount = Notification::where('user_id', $user->id)->where('is_read', 0)->count();

echo "✅ Verification:\n";
echo "   - Total in DB: {$totalCount}\n";
echo "   - Unread in DB: {$unreadCount}\n";
echo "\n";

echo "🎉 Done! You can now test in Flutter app.\n";
