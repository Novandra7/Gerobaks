# API Notifikasi - Spesifikasi Teknis
## Aplikasi Gerobaks - Waste Management System

**Version:** 1.0 (Updated from Backend Implementation)  
**Date:** November 12, 2025  
**Author:** Flutter Development Team  
**Backend Status:** ✅ Implemented & Production Ready  

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Endpoints](#endpoints)
3. [Database Schema](#database-schema)
4. [Automated Notifications](#automated-notifications)
5. [Notification Types & Categories](#notification-types--categories)
6. [Response Examples](#response-examples)
7. [Error Handling](#error-handling)
8. [Implementation Priority](#implementation-priority)

---

## 🎯 Overview

API Notifikasi digunakan untuk mengirimkan pemberitahuan kepada user terkait:
- **Jadwal pengambilan sampah harian** (B3, Organik, Anorganik, dll)
- **Reminder** untuk jadwal besok
- **Status pickup** (selesai, dibatalkan)
- **Poin reward** yang diperoleh
- **Informasi sistem** dan promo

### Key Features:
- ✅ Push notification otomatis berdasarkan jadwal
- ✅ Unread count untuk badge indicator
- ✅ Mark as read functionality
- ✅ Filter by type, category, read status
- ✅ Pagination support
- ✅ Soft delete support

---

## 🔌 Endpoints

### 1. Get Notifications List

**Endpoint:** `GET /api/notifications`

**Authentication:** Required (Bearer Token)

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Page number |
| `per_page` | integer | No | 20 | Items per page (max: 100) |
| `is_read` | integer | No | null | Filter: `0` (unread), `1` (read), `null` (all) |
| `type` | string | No | null | Filter: `schedule`, `reminder`, `info`, `system`, `promo` |
| `category` | string | No | null | Filter: `waste_pickup`, `waste_schedule`, `points`, etc |
| `priority` | string | No | null | Filter: `low`, `normal`, `high`, `urgent` |

**Request Example:**
```http
GET /api/notifications?page=1&per_page=20&is_read=0&type=schedule
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
Accept: application/json
```

**Important Notes:**
- `is_read` uses **integer** (0/1) not boolean
- `data` field returns as **JSON string**, needs to be decoded in frontend
- Response includes `from` and `to` in pagination for easier navigation

**Response Success (200):**
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": 1,
        "user_id": 2,
        "type": "schedule",
        "category": "waste_pickup",
        "title": "Pengambilan Sampah B3 Hari Ini!",
        "message": "Jangan lupa! Hari ini adalah jadwal pengambilan sampah B3. Pastikan sampah sudah dipisahkan dan siap diambil pada pukul 06:00 - 08:00.",
        "icon": "warning",
        "priority": "high",
        "is_read": false,
        "data": {
          "schedule_id": 45,
          "waste_type": "B3",
          "schedule_day": "selasa",
          "pickup_time": "06:00 - 08:00",
          "action_url": "/schedule/45"
        },
        "created_at": "2025-11-12 06:00:00",
        "read_at": null,
        "updated_at": "2025-11-12 06:00:00"
      },
      {
        "id": 2,
        "user_id": 2,
        "type": "reminder",
        "category": "waste_schedule",
        "title": "Besok Jadwal Sampah Organik",
        "message": "Besok adalah hari pengambilan sampah organik. Siapkan sampah Anda sebelum jam 06:00 pagi.",
        "icon": "eco",
        "priority": "normal",
        "is_read": true,
        "data": {
          "waste_type": "Organik",
          "schedule_day": "rabu",
          "pickup_time": "06:00 - 08:00"
        },
        "created_at": "2025-11-11 18:00:00",
        "read_at": "2025-11-11 19:30:00",
        "updated_at": "2025-11-11 19:30:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 15,
      "last_page": 1,
      "from": 1,
      "to": 15
    },
    "summary": {
      "total_notifications": 15,
      "unread_count": 5,
      "by_priority": {
        "urgent": 0,
        "high": 2,
        "normal": 10,
        "low": 3
      }
    }
  }
}
```

---

### 2. Get Unread Count

**Endpoint:** `GET /api/notifications/unread-count`

**Authentication:** Required (Bearer Token)

**Request Example:**
```http
GET /api/notifications/unread-count
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Unread count retrieved successfully",
  "data": {
    "unread_count": 5,
    "by_category": {
      "waste_pickup": 2,
      "waste_schedule": 1,
      "points": 2,
      "system": 0
    },
    "by_priority": {
      "urgent": 0,
      "high": 2,
      "normal": 2,
      "low": 1
    },
    "has_urgent": false
  }
}
```

---

### 3. Mark Notification as Read

**Endpoint:** `POST /api/notifications/{id}/mark-read`

**Authentication:** Required (Bearer Token)

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Notification ID |

**Request Example:**
```http
POST /api/notifications/15/mark-read
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Notification marked as read",
  "data": {
    "id": 15,
    "is_read": true,
    "read_at": "2025-11-12 10:30:00",
    "remaining_unread": 4
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Notification not found",
  "errors": {
    "notification": ["Notification with ID 15 not found or doesn't belong to you"]
  }
}
```

---

### 4. Mark All Notifications as Read

**Endpoint:** `POST /api/notifications/mark-all-read`

**Authentication:** Required (Bearer Token)

**Request Example:**
```http
POST /api/notifications/mark-all-read
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "data": {
    "marked_count": 5,
    "unread_count": 0
  }
}
```

---

### 5. Delete Notification

**Endpoint:** `DELETE /api/notifications/{id}`

**Authentication:** Required (Bearer Token)

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Notification ID |

**Request Example:**
```http
DELETE /api/notifications/15
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Notification deleted successfully",
  "data": {
    "id": 15,
    "deleted_at": "2025-11-12 10:35:00"
  }
}
```

---

### 6. Delete All Read Notifications

**Endpoint:** `DELETE /api/notifications/clear-read`

**Authentication:** Required (Bearer Token)

**Request Example:**
```http
DELETE /api/notifications/clear-read
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "All read notifications deleted",
  "data": {
    "deleted_count": 10
  }
}
```

---

## 🗄️ Database Schema

### Table: `notifications`

```sql
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    
    -- Notification Classification
    type ENUM('schedule', 'reminder', 'info', 'system', 'promo') NOT NULL,
    category VARCHAR(50) NOT NULL,
    
    -- Content
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    icon VARCHAR(50) DEFAULT 'notifications',
    
    -- Priority
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    
    -- Additional Data (JSON format)
    data JSON NULL,
    
    -- Read Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    -- Foreign Keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_type_category (type, category),
    INDEX idx_priority (priority),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Column Descriptions:

| Column | Type | Description | Example Values |
|--------|------|-------------|----------------|
| `type` | ENUM | Tipe notifikasi | `schedule`, `reminder`, `info`, `system`, `promo` |
| `category` | VARCHAR(50) | Kategori spesifik | `waste_pickup`, `waste_schedule`, `points`, `subscription` |
| `title` | VARCHAR(255) | Judul notifikasi | "Pengambilan Sampah B3 Hari Ini!" |
| `message` | TEXT | Isi pesan lengkap | "Jangan lupa! Hari ini adalah jadwal..." |
| `icon` | VARCHAR(50) | Material Icon name | `warning`, `eco`, `recycling`, `stars` |
| `priority` | ENUM | Tingkat prioritas | `low`, `normal`, `high`, `urgent` |
| `data` | JSON | Data tambahan | `{"schedule_id": 45, "waste_type": "B3"}` |

---

## ⚙️ Automated Notifications

Backend harus membuat **cron jobs** atau **scheduled tasks** untuk mengirim notifikasi otomatis.

### 1. Daily Schedule Notification

**Schedule:** Setiap hari jam **06:00 AM**

**Logic:**
1. Ambil hari ini (contoh: Selasa)
2. Cek `waste_schedules` tabel untuk jenis sampah hari ini
3. Kirim notifikasi ke **semua user** dengan kategori `waste_pickup`

**Pseudocode (Laravel Example):**
```php
// app/Console/Commands/SendDailyScheduleNotifications.php

public function handle()
{
    $today = now()->locale('id')->dayName; // "Selasa"
    
    // Get today's waste type from schedule
    $todaySchedule = WasteSchedule::where('schedule_day', strtolower($today))->first();
    
    if (!$todaySchedule) {
        $this->info('No schedule for today');
        return;
    }
    
    $wasteType = $todaySchedule->waste_type; // "B3"
    
    // Get all active users
    $users = User::where('status', 'active')
                 ->where('role', 'end_user')
                 ->get();
    
    foreach ($users as $user) {
        Notification::create([
            'user_id' => $user->id,
            'type' => 'schedule',
            'category' => 'waste_pickup',
            'title' => "Pengambilan Sampah {$wasteType} Hari Ini!",
            'message' => "Jangan lupa! Hari ini adalah jadwal pengambilan sampah {$wasteType}. Pastikan sampah sudah dipisahkan dan siap diambil pada pukul 06:00 - 08:00.",
            'icon' => $this->getWasteIcon($wasteType),
            'priority' => 'high',
            'data' => json_encode([
                'waste_type' => $wasteType,
                'schedule_day' => strtolower($today),
                'pickup_time' => '06:00 - 08:00'
            ])
        ]);
    }
    
    $this->info("Sent {$users->count()} notifications for {$wasteType}");
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
```

**Register Command:**
```php
// app/Console/Kernel.php

protected function schedule(Schedule $schedule)
{
    $schedule->command('notifications:daily-schedule')->dailyAt('06:00');
}
```

---

### 2. Tomorrow Reminder Notification

**Schedule:** Setiap hari jam **06:00 PM** (18:00)

**Logic:**
1. Ambil hari besok
2. Cek jenis sampah untuk besok
3. Kirim reminder ke semua user dengan kategori `waste_schedule`

**Pseudocode:**
```php
// app/Console/Commands/SendTomorrowReminder.php

public function handle()
{
    $tomorrow = now()->addDay()->locale('id')->dayName;
    
    $tomorrowSchedule = WasteSchedule::where('schedule_day', strtolower($tomorrow))->first();
    
    if (!$tomorrowSchedule) {
        return;
    }
    
    $wasteType = $tomorrowSchedule->waste_type;
    
    $users = User::where('status', 'active')
                 ->where('role', 'end_user')
                 ->get();
    
    foreach ($users as $user) {
        Notification::create([
            'user_id' => $user->id,
            'type' => 'reminder',
            'category' => 'waste_schedule',
            'title' => "Besok Jadwal Sampah {$wasteType}",
            'message' => "Besok adalah hari pengambilan sampah {$wasteType}. Siapkan sampah Anda sebelum jam 06:00 pagi.",
            'icon' => 'calendar_today',
            'priority' => 'normal',
            'data' => json_encode([
                'waste_type' => $wasteType,
                'schedule_day' => strtolower($tomorrow),
                'pickup_time' => '06:00 - 08:00'
            ])
        ]);
    }
}
```

**Register Command:**
```php
$schedule->command('notifications:tomorrow-reminder')->dailyAt('18:00');
```

---

### 3. Pickup Completed Notification

**Trigger:** Event `PickupCompleted` atau saat pickup status = 'completed'

**Logic:**
```php
// app/Events/PickupCompleted.php
// Triggered when mitra completes a pickup

public function handle(PickupCompleted $event)
{
    $schedule = $event->schedule;
    
    Notification::create([
        'user_id' => $schedule->user_id,
        'type' => 'info',
        'category' => 'pickup_completed',
        'title' => 'Sampah Berhasil Diambil!',
        'message' => "Sampah Anda sudah diambil oleh mitra pada pukul {$schedule->completed_at->format('H:i')}. Terima kasih telah berkontribusi untuk lingkungan yang lebih bersih!",
        'icon' => 'check_circle',
        'priority' => 'normal',
        'data' => json_encode([
            'schedule_id' => $schedule->id,
            'pickup_time' => $schedule->completed_at->format('H:i'),
            'weight' => $schedule->total_weight,
            'mitra_name' => $schedule->mitra->name
        ])
    ]);
}
```

---

### 4. Points Earned Notification

**Trigger:** Event `PointsEarned` atau setelah pickup completed

**Logic:**
```php
// app/Events/PointsEarned.php

public function handle(PointsEarned $event)
{
    $user = $event->user;
    $points = $event->points;
    $schedule = $event->schedule;
    
    Notification::create([
        'user_id' => $user->id,
        'type' => 'info',
        'category' => 'points',
        'title' => 'Poin Reward Bertambah!',
        'message' => "Selamat! Anda mendapat {$points} poin dari pengambilan sampah. Total poin Anda sekarang: {$user->points}",
        'icon' => 'stars',
        'priority' => 'low',
        'data' => json_encode([
            'points_earned' => $points,
            'total_points' => $user->points,
            'schedule_id' => $schedule->id,
            'reason' => 'pickup_completed'
        ])
    ]);
}
```

---

### 5. Pickup Cancelled Notification

**Trigger:** Event `PickupCancelled`

**Logic:**
```php
public function handle(PickupCancelled $event)
{
    $schedule = $event->schedule;
    
    Notification::create([
        'user_id' => $schedule->user_id,
        'type' => 'info',
        'category' => 'pickup_cancelled',
        'title' => 'Penjemputan Dibatalkan',
        'message' => "Jadwal penjemputan sampah Anda pada {$schedule->scheduled_date->format('d M Y')} telah dibatalkan. Silakan buat jadwal baru.",
        'icon' => 'cancel',
        'priority' => 'normal',
        'data' => json_encode([
            'schedule_id' => $schedule->id,
            'cancelled_at' => now()->format('Y-m-d H:i:s'),
            'reason' => $schedule->cancellation_reason
        ])
    ]);
}
```

---

## 📚 Notification Types & Categories

### Types

| Type | Description | Usage |
|------|-------------|-------|
| `schedule` | Jadwal hari ini | Notifikasi pengambilan sampah hari ini |
| `reminder` | Pengingat | Reminder untuk besok atau event mendatang |
| `info` | Informasi | Status pickup, poin, update |
| `system` | Sistem | Maintenance, update aplikasi |
| `promo` | Promosi | Diskon, event, promo khusus |

### Categories

| Category | Description | Icon | Priority |
|----------|-------------|------|----------|
| `waste_pickup` | Pengambilan sampah hari ini | Depends on waste type | `high` |
| `waste_schedule` | Jadwal mendatang | `calendar_today` | `normal` |
| `points` | Poin reward | `stars` | `low` |
| `pickup_completed` | Pickup selesai | `check_circle` | `normal` |
| `pickup_cancelled` | Pickup dibatalkan | `cancel` | `normal` |
| `subscription` | Status langganan | `card_membership` | `normal` |
| `system_update` | Update sistem | `system_update` | `low` |

### Icons (Material Icons)

| Icon Name | Usage | Color Suggestion |
|-----------|-------|------------------|
| `warning` | B3, urgent | Orange/Red |
| `eco` | Organik | Green |
| `recycling` | Anorganik | Blue |
| `delete_outline` | Campuran | Grey |
| `electrical_services` | Elektronik | Yellow |
| `stars` | Points, rewards | Gold/Amber |
| `check_circle` | Success | Green |
| `cancel` | Cancelled | Red |
| `info` | Information | Blue |
| `calendar_today` | Schedule | Blue |
| `notifications` | Default | Grey |

### Priority Levels

| Priority | Description | Badge Color | Sound |
|----------|-------------|-------------|-------|
| `urgent` | Darurat, butuh action segera | Red | Loud |
| `high` | Penting, jadwal hari ini | Orange | Normal |
| `normal` | Informasi standar | Blue | Normal |
| `low` | Informasi biasa | Grey | Soft |

---

## 🔔 Push Notification (Optional - Future Enhancement)

Jika ingin **real-time push notification** menggunakan **Firebase Cloud Messaging (FCM)**:

### Additional Endpoints Needed:

#### Register FCM Token

**Endpoint:** `POST /api/user/fcm-token`

**Request:**
```json
{
  "fcm_token": "firebaseCloudMessagingTokenHere123456789",
  "device_type": "android",
  "device_id": "unique-device-identifier"
}
```

**Response:**
```json
{
  "success": true,
  "message": "FCM token registered successfully",
  "data": {
    "user_id": 2,
    "fcm_token": "firebaseCloudMessagingTokenHere123456789",
    "registered_at": "2025-11-12 10:00:00"
  }
}
```

### Backend Implementation (Laravel + Firebase):

```php
// Install: composer require kreait/firebase-php

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FcmNotification;

class FirebaseNotificationService
{
    private $messaging;
    
    public function __construct()
    {
        $this->messaging = (new Factory)
            ->withServiceAccount(config('firebase.credentials'))
            ->createMessaging();
    }
    
    public function sendToUser($userId, $title, $body, $data = [])
    {
        $user = User::find($userId);
        
        if (!$user || !$user->fcm_token) {
            return false;
        }
        
        $message = CloudMessage::withTarget('token', $user->fcm_token)
            ->withNotification(FcmNotification::create($title, $body))
            ->withData($data);
        
        try {
            $this->messaging->send($message);
            return true;
        } catch (\Exception $e) {
            \Log::error('FCM send failed: ' . $e->getMessage());
            return false;
        }
    }
}
```

### Database Schema for FCM Tokens:

```sql
CREATE TABLE user_fcm_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    fcm_token VARCHAR(255) NOT NULL,
    device_type ENUM('android', 'ios', 'web') NOT NULL,
    device_id VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_fcm_token (fcm_token),
    INDEX idx_is_active (is_active)
);
```

---

## 📝 Response Examples

### Success Response Format

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  }
}
```

### Error Response Format

```json
{
  "success": false,
  "message": "Error message here",
  "errors": {
    "field_name": ["Error detail 1", "Error detail 2"]
  }
}
```

### Common HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid input parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource not found |
| 422 | Unprocessable Entity | Validation failed |
| 500 | Internal Server Error | Server error |

---

## ⚠️ Error Handling

### Error Scenarios:

#### 1. Notification Not Found
```json
{
  "success": false,
  "message": "Notification not found",
  "errors": {
    "notification": ["Notification with ID 999 not found or doesn't belong to you"]
  }
}
```

#### 2. Unauthorized Access
```json
{
  "success": false,
  "message": "Unauthorized",
  "errors": {
    "auth": ["You are not authorized to access this notification"]
  }
}
```

#### 3. Invalid Parameters
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "type": ["The selected type is invalid"],
    "per_page": ["The per_page must not be greater than 100"]
  }
}
```

---

## 🚀 Implementation Priority

### Phase 1 (MVP - Must Have) ✅

1. ✅ **GET /api/notifications** - List notifications with pagination
2. ✅ **GET /api/notifications/unread-count** - Get unread count for badge
3. ✅ **POST /api/notifications/{id}/mark-read** - Mark as read
4. ✅ **Daily Schedule Notification** - Cron job untuk notif hari ini (06:00 AM)
5. ✅ **Database Schema** - Create `notifications` table

**Timeline:** Sprint 1 (1-2 weeks)

### Phase 2 (Important Features) 📌

6. 📌 **POST /api/notifications/mark-all-read** - Mark all as read
7. 📌 **DELETE /api/notifications/{id}** - Delete notification
8. 📌 **Tomorrow Reminder** - Cron job untuk reminder besok (06:00 PM)
9. 📌 **Pickup Completed Notification** - Event-based notification
10. 📌 **Points Notification** - Event-based notification

**Timeline:** Sprint 2 (1 week)

### Phase 3 (Nice to Have) 🎯

11. 🎯 **DELETE /api/notifications/clear-read** - Clear all read
12. 🎯 **Pickup Cancelled Notification** - Event-based
13. 🎯 **System & Promo Notifications** - Admin panel untuk create notification
14. 🎯 **Notification Preferences** - User settings untuk on/off notif per category

**Timeline:** Sprint 3 (1-2 weeks)

### Phase 4 (Future Enhancement) 🔮

15. 🔮 **Firebase Cloud Messaging** - Real-time push notification
16. 🔮 **POST /api/user/fcm-token** - Register device token
17. 🔮 **Notification Analytics** - Track open rate, click rate
18. 🔮 **Scheduled Notifications** - Admin schedule notif untuk waktu tertentu

**Timeline:** Future release

---

## 📞 Contact & Support

**Flutter Team:**
- Developer: [Your Name]
- Email: [your.email@example.com]

**Questions?**
- Slack: #backend-api-discussion
- Jira: Create issue dengan label `api-notification`

---

## 📄 Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-12 | Initial specification created |

---

## ✅ Testing Checklist for Backend

- [ ] Endpoint `/api/notifications` returns paginated list
- [ ] Filtering by `type`, `category`, `is_read` works correctly
- [ ] Endpoint `/api/notifications/unread-count` returns correct count
- [ ] Mark as read updates `is_read` and `read_at` timestamp
- [ ] Mark all as read updates all user's notifications
- [ ] Delete notification soft-deletes record
- [ ] Daily cron job creates notifications at 06:00 AM
- [ ] Reminder cron job creates notifications at 06:00 PM
- [ ] Event listeners trigger notifications correctly
- [ ] Notifications only visible to owner (user_id match)
- [ ] Authorization checks prevent unauthorized access
- [ ] Pagination works with large datasets (1000+ records)
- [ ] JSON data field stores and retrieves correctly
- [ ] Response format matches specification

---

**End of Document**

*This specification is subject to change based on project requirements and feedback.*
