# 🔔 Backend: Setup Notifikasi Jadwal Harian

> **Untuk Backend Developer**  
> **Task:** Kirim notifikasi jadwal pengangkutan sampah otomatis setiap hari

---

## 📋 Yang Harus Dibuat di Backend

### 1. Cron Job untuk Notifikasi Harian

**File:** `app/Console/Commands/SendDailyScheduleNotifications.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Notification;
use App\Models\WasteSchedule;
use Carbon\Carbon;

class SendDailyScheduleNotifications extends Command
{
    protected $signature = 'notifications:send-daily-schedule';
    protected $description = 'Send daily waste pickup schedule notifications to all users';

    public function handle()
    {
        $this->info('🔔 Sending daily schedule notifications...');
        
        // Get today's day name in Indonesian
        $today = Carbon::now()->locale('id')->dayName; // "Senin", "Selasa", etc
        $todayLower = strtolower($today);
        
        $this->info("Today is: $today");
        
        // Get today's waste schedule
        $todaySchedule = WasteSchedule::where('schedule_day', $todayLower)->first();
        
        if (!$todaySchedule) {
            $this->warn("No schedule found for today ($today)");
            return 0;
        }
        
        $wasteType = $todaySchedule->waste_type; // "B3", "Organik", "Anorganik", dll
        $this->info("Waste type today: $wasteType");
        
        // Get all active end users
        $users = User::where('status', 'active')
                    ->where('role', 'end_user') // Only end users, not mitra
                    ->get();
        
        $count = 0;
        
        foreach ($users as $user) {
            // Create notification for each user
            Notification::create([
                'user_id' => $user->id,
                'type' => 'schedule',
                'category' => 'waste_pickup',
                'title' => "Pengambilan Sampah $wasteType Hari Ini!",
                'message' => "Jangan lupa! Hari ini adalah jadwal pengambilan sampah $wasteType. Pastikan sampah sudah dipisahkan dan siap diambil pada pukul 06:00 - 08:00.",
                'icon' => $this->getWasteIcon($wasteType),
                'priority' => 'high',
                'is_read' => 0, // Use integer 0 for false
                'data' => json_encode([
                    'waste_type' => $wasteType,
                    'schedule_day' => $todayLower,
                    'pickup_time' => '06:00 - 08:00',
                    'schedule_id' => $todaySchedule->id ?? null,
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            
            $count++;
        }
        
        $this->info("✅ Sent $count notifications for $wasteType pickup");
        return 0;
    }
    
    private function getWasteIcon($wasteType)
    {
        return match($wasteType) {
            'B3' => 'warning',
            'Organik' => 'eco',
            'Anorganik' => 'recycling',
            'Elektronik' => 'electrical_services',
            default => 'delete_outline'
        };
    }
}
```

---

### 2. Register Cron Job

**File:** `app/Console/Kernel.php`

```php
<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule)
    {
        // Send daily schedule notifications at 06:00 AM every day
        $schedule->command('notifications:send-daily-schedule')
                 ->dailyAt('06:00')
                 ->timezone('Asia/Jakarta');
        
        // Send tomorrow reminder at 06:00 PM (18:00)
        $schedule->command('notifications:send-tomorrow-reminder')
                 ->dailyAt('18:00')
                 ->timezone('Asia/Jakarta');
    }

    protected function commands()
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
```

---

### 3. Cron Job untuk Reminder Besok (Optional)

**File:** `app/Console/Commands/SendTomorrowReminder.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Notification;
use App\Models\WasteSchedule;
use Carbon\Carbon;

class SendTomorrowReminder extends Command
{
    protected $signature = 'notifications:send-tomorrow-reminder';
    protected $description = 'Send reminder for tomorrow waste pickup schedule';

    public function handle()
    {
        $this->info('🔔 Sending tomorrow reminder notifications...');
        
        // Get tomorrow's day name
        $tomorrow = Carbon::tomorrow()->locale('id')->dayName;
        $tomorrowLower = strtolower($tomorrow);
        
        $this->info("Tomorrow is: $tomorrow");
        
        // Get tomorrow's waste schedule
        $tomorrowSchedule = WasteSchedule::where('schedule_day', $tomorrowLower)->first();
        
        if (!$tomorrowSchedule) {
            $this->warn("No schedule found for tomorrow ($tomorrow)");
            return 0;
        }
        
        $wasteType = $tomorrowSchedule->waste_type;
        $this->info("Waste type tomorrow: $wasteType");
        
        // Get all active end users
        $users = User::where('status', 'active')
                    ->where('role', 'end_user')
                    ->get();
        
        $count = 0;
        
        foreach ($users as $user) {
            Notification::create([
                'user_id' => $user->id,
                'type' => 'reminder',
                'category' => 'waste_schedule',
                'title' => "Besok Jadwal Sampah $wasteType",
                'message' => "Besok adalah hari pengambilan sampah $wasteType. Siapkan sampah Anda sebelum jam 06:00 pagi.",
                'icon' => 'calendar_today',
                'priority' => 'normal',
                'is_read' => 0,
                'data' => json_encode([
                    'waste_type' => $wasteType,
                    'schedule_day' => $tomorrowLower,
                    'pickup_time' => '06:00 - 08:00',
                ]),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            
            $count++;
        }
        
        $this->info("✅ Sent $count reminder notifications for tomorrow");
        return 0;
    }
}
```

---

### 4. Setup Cron di Server

Tambahkan ke crontab server:

```bash
# Edit crontab
crontab -e

# Tambahkan baris ini:
* * * * * cd /path/to/your/laravel/project && php artisan schedule:run >> /dev/null 2>&1
```

**Atau jika di localhost untuk testing:**

```bash
# Run scheduler manually setiap menit (untuk development)
php artisan schedule:work
```

---

### 5. Test Manual

```bash
# Test daily notification
php artisan notifications:send-daily-schedule

# Test tomorrow reminder
php artisan notifications:send-tomorrow-reminder

# Check hasil
php artisan tinker
>>> Notification::latest()->first();
```

---

## 🗄️ Database Schema

Pastikan tabel `notifications` sudah ada:

```sql
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('schedule', 'reminder', 'info', 'system', 'promo') NOT NULL,
    category VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    icon VARCHAR(50) DEFAULT 'notifications',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    data JSON NULL,
    is_read TINYINT(1) DEFAULT 0, -- 0 = unread, 1 = read
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_type_category (type, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🧪 Testing

### 1. Create Test Data

```bash
php artisan tinker

# Create test notification manually
\App\Models\Notification::create([
    'user_id' => 1, // Ganti dengan user ID yang aktif
    'type' => 'schedule',
    'category' => 'waste_pickup',
    'title' => 'Pengambilan Sampah Organik Hari Ini!',
    'message' => 'Jangan lupa! Hari ini adalah jadwal pengambilan sampah Organik.',
    'icon' => 'eco',
    'priority' => 'high',
    'is_read' => 0,
    'data' => json_encode([
        'waste_type' => 'Organik',
        'schedule_day' => 'selasa',
        'pickup_time' => '06:00 - 08:00'
    ]),
]);

# Check
\App\Models\Notification::count();
```

### 2. Test API Endpoint

```bash
# Login dulu untuk dapat token
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'

# Get unread count
curl -X GET "http://127.0.0.1:8000/api/notifications/unread-count" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Get notifications list
curl -X GET "http://127.0.0.1:8000/api/notifications?is_read=0" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 📊 Expected Results

Setelah setup selesai:

### Every Day at 06:00 AM:
```
✅ Semua user end_user menerima notifikasi:
   Title: "Pengambilan Sampah [Jenis] Hari Ini!"
   Type: schedule
   Priority: high
   Icon: warning/eco/recycling (tergantung jenis)
```

### Every Day at 06:00 PM (18:00):
```
✅ Semua user end_user menerima reminder:
   Title: "Besok Jadwal Sampah [Jenis]"
   Type: reminder
   Priority: normal
   Icon: calendar_today
```

---

## ⚠️ Important Notes

1. **Timezone:** Pastikan server timezone = Asia/Jakarta
2. **User Role:** Hanya kirim ke `role = 'end_user'`, bukan mitra
3. **Status:** Hanya kirim ke user `status = 'active'`
4. **Data Field:** Gunakan `json_encode()`, bukan JSON object langsung
5. **is_read:** Gunakan integer 0/1, bukan boolean true/false
6. **Schedule Day:** Simpan lowercase: "senin", "selasa", dll

---

## 🔍 Troubleshooting

### Cron tidak jalan?
```bash
# Check cron service
sudo systemctl status cron

# Check Laravel scheduler
php artisan schedule:list

# Run manually untuk test
php artisan schedule:run
```

### Notifikasi tidak muncul di app?
1. Check user sudah login dengan token valid
2. Check API endpoint response
3. Check user_id di tabel notifications
4. Check is_read = 0 (integer, bukan boolean)

### Wrong day/time?
```bash
# Check server timezone
date
timedatectl

# Set timezone di Laravel config/app.php
'timezone' => 'Asia/Jakarta',
```

---

## ✅ Checklist

- [ ] Create `SendDailyScheduleNotifications.php` command
- [ ] Create `SendTomorrowReminder.php` command (optional)
- [ ] Register commands in `Kernel.php`
- [ ] Setup crontab di server
- [ ] Test manual dengan `php artisan notifications:send-daily-schedule`
- [ ] Verify data masuk ke tabel `notifications`
- [ ] Test API endpoint dari Flutter app
- [ ] Check badge count di app setelah notifikasi masuk

---

**Setelah setup ini, notifikasi jadwal harian akan otomatis terkirim setiap hari pukul 06:00 pagi! 🎉**

