# API Notifikasi - Quick Reference
## Ringkasan untuk Backend Developer

---

## 🎯 Apa yang Dibutuhkan?

Sistem notifikasi untuk memberitahu user tentang:
- ✅ **Jadwal sampah hari ini** (B3, Organik, dll) → Notif otomatis jam 06:00 pagi
- ✅ **Reminder besok** → Notif otomatis jam 18:00 sore
- ✅ **Status pickup** (selesai/batal)
- ✅ **Poin reward** yang didapat

---

## 📋 Endpoints yang Dibutuhkan

### 1. GET /api/notifications
**Fungsi:** Ambil list notifikasi user (dengan pagination & filter)

**Query Params:**
- `page` (int, default: 1)
- `per_page` (int, default: 20, max: 100)
- `type` (string: schedule/reminder/info/system/promo)
- `is_read` (boolean: true/false/null)
- `category` (string: waste_pickup, waste_schedule, points, etc)

**Response:**
```json
{
  "success": true,
  "data": {
    "notifications": [...],
    "pagination": {...},
    "summary": {"unread_count": 5}
  }
}
```

---

### 2. GET /api/notifications/unread-count
**Fungsi:** Hitung jumlah notif yang belum dibaca (untuk badge)

**Response:**
```json
{
  "success": true,
  "data": {
    "unread_count": 5,
    "by_category": {"waste_pickup": 2, "points": 3}
  }
}
```

---

### 3. POST /api/notifications/{id}/mark-read
**Fungsi:** Mark notifikasi sebagai sudah dibaca

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 15,
    "is_read": true,
    "read_at": "2025-11-12 10:30:00"
  }
}
```

---

### 4. POST /api/notifications/mark-all-read
**Fungsi:** Mark semua notifikasi sebagai sudah dibaca

---

### 5. DELETE /api/notifications/{id}
**Fungsi:** Hapus notifikasi (soft delete)

---

## 🗄️ Database Schema (Simple)

```sql
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('schedule', 'reminder', 'info', 'system', 'promo'),
    category VARCHAR(50),
    title VARCHAR(255),
    message TEXT,
    icon VARCHAR(50) DEFAULT 'notifications',
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    data JSON NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read)
);
```

---

## ⚙️ Automated Notifications (PENTING!)

### 1. Notifikasi Hari Ini (Cron Job)

**Schedule:** Setiap hari jam **06:00 AM**

**Logic:**
```
1. Ambil hari ini (misal: Selasa)
2. Cek waste_schedules → hari Selasa = Sampah B3
3. Kirim notif ke SEMUA user:
   - Title: "Pengambilan Sampah B3 Hari Ini!"
   - Message: "Jangan lupa! Hari ini adalah jadwal..."
   - Icon: "warning" (untuk B3)
   - Priority: "high"
   - Category: "waste_pickup"
```

**Laravel Example:**
```php
// Kernel.php
$schedule->command('notifications:daily-schedule')->dailyAt('06:00');

// Command
foreach (User::all() as $user) {
    Notification::create([
        'user_id' => $user->id,
        'type' => 'schedule',
        'category' => 'waste_pickup',
        'title' => "Pengambilan Sampah B3 Hari Ini!",
        'message' => "Jangan lupa! Hari ini jadwal sampah B3...",
        'icon' => 'warning',
        'priority' => 'high',
        'data' => json_encode([
            'waste_type' => 'B3',
            'pickup_time' => '06:00 - 08:00'
        ])
    ]);
}
```

---

### 2. Reminder Besok (Cron Job)

**Schedule:** Setiap hari jam **06:00 PM** (18:00)

**Logic:** Sama seperti di atas, tapi untuk besok

```php
$schedule->command('notifications:tomorrow-reminder')->dailyAt('18:00');
```

---

### 3. Notifikasi Event-Based

**Trigger:** Saat event terjadi

#### A. Pickup Selesai
```php
// Saat pickup status = completed
Notification::create([
    'user_id' => $schedule->user_id,
    'type' => 'info',
    'category' => 'pickup_completed',
    'title' => 'Sampah Berhasil Diambil!',
    'message' => 'Sampah Anda sudah diambil...',
    'icon' => 'check_circle',
    'priority' => 'normal'
]);
```

#### B. Poin Bertambah
```php
// Setelah pickup completed
Notification::create([
    'user_id' => $user->id,
    'type' => 'info',
    'category' => 'points',
    'title' => 'Poin Reward Bertambah!',
    'message' => "Selamat! Anda dapat +{$points} poin",
    'icon' => 'stars',
    'priority' => 'low'
]);
```

---

## 🎨 Notification Content Guide

### Types
- `schedule` → Jadwal hari ini
- `reminder` → Pengingat besok
- `info` → Informasi umum
- `system` → Update sistem
- `promo` → Promosi

### Categories
- `waste_pickup` → Pickup hari ini
- `waste_schedule` → Jadwal mendatang
- `points` → Poin reward
- `pickup_completed` → Pickup selesai
- `pickup_cancelled` → Pickup batal

### Icons (Material Icons)
- `warning` → B3, urgent
- `eco` → Organik
- `recycling` → Anorganik
- `delete_outline` → Campuran
- `electrical_services` → Elektronik
- `stars` → Points
- `check_circle` → Success
- `calendar_today` → Schedule

### Priority
- `urgent` → Darurat
- `high` → Jadwal hari ini
- `normal` → Info biasa
- `low` → Info tambahan

---

## 📊 Sample Notification Data

```json
{
  "id": 1,
  "user_id": 2,
  "type": "schedule",
  "category": "waste_pickup",
  "title": "Pengambilan Sampah B3 Hari Ini!",
  "message": "Jangan lupa! Hari ini adalah jadwal pengambilan sampah B3. Pastikan sampah sudah dipisahkan.",
  "icon": "warning",
  "priority": "high",
  "is_read": false,
  "data": {
    "waste_type": "B3",
    "schedule_day": "selasa",
    "pickup_time": "06:00 - 08:00"
  },
  "created_at": "2025-11-12 06:00:00",
  "read_at": null
}
```

---

## ✅ Priority Checklist

### Phase 1 (Minimal MVP)
- [ ] Create `notifications` table
- [ ] Endpoint GET /api/notifications
- [ ] Endpoint GET /api/notifications/unread-count
- [ ] Endpoint POST /api/notifications/{id}/mark-read
- [ ] Cron job: Daily notification (06:00 AM)

### Phase 2
- [ ] Endpoint POST /api/notifications/mark-all-read
- [ ] Endpoint DELETE /api/notifications/{id}
- [ ] Cron job: Tomorrow reminder (06:00 PM)
- [ ] Event: Pickup completed notification
- [ ] Event: Points notification

---

## 🔍 Testing

**Test Cases:**
1. ✅ Notif list bisa di-paginate
2. ✅ Filter by type & category works
3. ✅ Unread count akurat
4. ✅ Mark as read update timestamp
5. ✅ Cron job jalan jam 06:00 & 18:00
6. ✅ User hanya bisa akses notif mereka sendiri
7. ✅ JSON data field berfungsi

---

## 📞 Questions?

**Perlu penjelasan lebih detail?** 
Lihat file: `API_NOTIFICATION_SPEC.md`

**Ada pertanyaan teknis?**
Contact Flutter team via Slack/Email

---

**TL;DR:**
1. Buat 5 endpoints untuk CRUD notifications
2. Buat tabel `notifications` di database
3. Setup 2 cron jobs (jam 06:00 & 18:00)
4. Trigger notif saat event terjadi (pickup selesai, poin tambah)
5. Done! 🎉
