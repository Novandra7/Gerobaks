# 🔔 Backend Notification Implementation - Schedule Events

**Date:** November 14, 2025  
**For:** Laravel Backend Team  
**Feature:** Push Notifications untuk End User saat Mitra Accept & Complete Schedule  

---

## 📋 Overview

Saat ini frontend **sudah siap** menerima push notifications. Backend perlu mengirim notifikasi ke end user pada 2 event penting:

1. **Mitra menerima jadwal** → User dapat notifikasi "Jadwal Anda telah diterima oleh mitra"
2. **Mitra selesaikan penjemputan** → User dapat notifikasi "Penjemputan sampah Anda telah selesai"

---

## 🎯 Events yang Memerlukan Notifikasi

### Event 1: Mitra Accept Schedule
**Trigger:** Mitra klik "Terima Jadwal" di aplikasi Mitra  
**Endpoint:** `POST /api/mitra/pickup-schedules/{id}/accept`  
**Action:** Kirim push notification ke end user

### Event 2: Mitra Complete Pickup
**Trigger:** Mitra selesaikan penjemputan sampah  
**Endpoint:** `POST /api/mitra/pickup-schedules/{id}/complete`  
**Action:** Kirim push notification ke end user

---

## 📱 Frontend Status

### ✅ Yang Sudah Ada di Flutter:
- ✅ NotificationService (local notifications)
- ✅ NotificationApiService (API integration)
- ✅ NotificationModel (data model)
- ✅ NotificationScreen (UI untuk list notifikasi)
- ✅ NotificationBloc (state management)
- ✅ Firebase Cloud Messaging (FCM) setup
- ✅ Notification badge & icon di home
- ✅ Sound & vibration support

### ⏳ Yang Perlu Backend:
- ⏳ Kirim push notification via FCM
- ⏳ Save notification ke database
- ⏳ API endpoint untuk fetch notifications

---

## 💾 Database Structure

### Table: `notifications`

```sql
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL COMMENT 'schedule, reminder, info, system, promo',
    category VARCHAR(50) NOT NULL COMMENT 'schedule_accepted, schedule_completed, schedule_reminder, etc',
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    icon VARCHAR(100) DEFAULT 'ic_notification' COMMENT 'Icon name untuk display',
    priority VARCHAR(20) DEFAULT 'normal' COMMENT 'urgent, high, normal, low',
    is_read BOOLEAN DEFAULT FALSE,
    data JSON NULL COMMENT 'Additional data (schedule_id, pickup_time, points, etc)',
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_type (type),
    INDEX idx_category (category),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Table: `user_fcm_tokens`

```sql
CREATE TABLE user_fcm_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    fcm_token VARCHAR(255) NOT NULL,
    device_type VARCHAR(20) NOT NULL COMMENT 'android, ios, web',
    device_name VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_user_token (user_id, fcm_token),
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔧 Implementation

### 1. Install FCM Package

```bash
composer require kreait/firebase-php
```

### 2. Setup Firebase Config

**File:** `config/firebase.php`

```php
<?php

return [
    'credentials' => [
        'file' => env('FIREBASE_CREDENTIALS_PATH', storage_path('app/firebase/firebase-credentials.json')),
    ],
    
    'database' => [
        'url' => env('FIREBASE_DATABASE_URL'),
    ],
    
    'dynamic_links' => [
        'default_domain' => env('FIREBASE_DYNAMIC_LINKS_DOMAIN'),
    ],
    
    'storage' => [
        'default_bucket' => env('FIREBASE_STORAGE_DEFAULT_BUCKET'),
    ],
];
```

**Environment (.env):**

```env
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

### 3. Create Notification Service

**File:** `app/Services/NotificationService.php`

```php
<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\UserFcmToken;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(config('firebase.credentials.file'));
        $this->messaging = $factory->createMessaging();
    }

    /**
     * Kirim notifikasi ke user
     *
     * @param int $userId
     * @param string $type (schedule, reminder, info, system, promo)
     * @param string $category (schedule_accepted, schedule_completed, etc)
     * @param string $title
     * @param string $message
     * @param array $data Additional data
     * @param string $priority (urgent, high, normal, low)
     * @return bool
     */
    public function sendToUser(
        int $userId,
        string $type,
        string $category,
        string $title,
        string $message,
        array $data = [],
        string $priority = 'normal'
    ): bool {
        try {
            // 1. Save notification to database
            $notification = Notification::create([
                'user_id' => $userId,
                'type' => $type,
                'category' => $category,
                'title' => $title,
                'message' => $message,
                'icon' => $this->getIconForCategory($category),
                'priority' => $priority,
                'is_read' => false,
                'data' => json_encode($data),
            ]);

            Log::info('✅ Notification saved to database', [
                'notification_id' => $notification->id,
                'user_id' => $userId,
                'category' => $category,
            ]);

            // 2. Get user's FCM tokens
            $tokens = UserFcmToken::where('user_id', $userId)
                ->where('is_active', true)
                ->pluck('fcm_token')
                ->toArray();

            if (empty($tokens)) {
                Log::warning('⚠️ No FCM tokens found for user', ['user_id' => $userId]);
                return true; // Notification saved, but no push sent
            }

            // 3. Send push notification via FCM
            $this->sendPushNotification($tokens, $title, $message, $data, $priority);

            return true;
        } catch (\Exception $e) {
            Log::error('❌ Failed to send notification', [
                'error' => $e->getMessage(),
                'user_id' => $userId,
                'category' => $category,
            ]);
            return false;
        }
    }

    /**
     * Kirim push notification via FCM
     */
    protected function sendPushNotification(
        array $tokens,
        string $title,
        string $message,
        array $data,
        string $priority
    ): void {
        try {
            $notification = FirebaseNotification::create($title, $message);

            // Set priority
            $androidPriority = $priority === 'urgent' || $priority === 'high' ? 'high' : 'normal';

            foreach ($tokens as $token) {
                try {
                    $message = CloudMessage::withTarget('token', $token)
                        ->withNotification($notification)
                        ->withData($data)
                        ->withAndroidConfig([
                            'priority' => $androidPriority,
                            'notification' => [
                                'sound' => 'nf_gerobaks.mp3',
                                'channel_id' => 'gerobaks_channel',
                            ],
                        ])
                        ->withApnsConfig([
                            'headers' => [
                                'apns-priority' => '10',
                            ],
                            'payload' => [
                                'aps' => [
                                    'sound' => 'nf_gerobaks.wav',
                                    'badge' => 1,
                                ],
                            ],
                        ]);

                    $this->messaging->send($message);
                    
                    Log::info('✅ Push notification sent', ['token' => substr($token, 0, 20) . '...']);
                } catch (\Exception $e) {
                    Log::error('❌ Failed to send to token', [
                        'token' => substr($token, 0, 20) . '...',
                        'error' => $e->getMessage(),
                    ]);
                    
                    // If token invalid, mark as inactive
                    if (str_contains($e->getMessage(), 'not-registered') || 
                        str_contains($e->getMessage(), 'invalid-registration-token')) {
                        UserFcmToken::where('fcm_token', $token)->update(['is_active' => false]);
                    }
                }
            }
        } catch (\Exception $e) {
            Log::error('❌ Failed to send push notifications', ['error' => $e->getMessage()]);
        }
    }

    /**
     * Get icon name based on category
     */
    protected function getIconForCategory(string $category): string
    {
        return match($category) {
            'schedule_accepted' => 'ic_check',
            'schedule_completed' => 'ic_check_circle',
            'schedule_reminder' => 'ic_calender',
            'schedule_cancelled' => 'ic_trash',
            'points_earned' => 'ic_stars',
            'waste_collected' => 'ic_tracking',
            default => 'ic_notification',
        };
    }
}
```

### 4. Update PickupSchedule Controller

**Event 1: Mitra Accept Schedule**

**File:** `app/Http/Controllers/Api/Mitra/PickupScheduleController.php`

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Models\PickupSchedule;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class PickupScheduleController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Mitra accept schedule
     * POST /api/mitra/pickup-schedules/{id}/accept
     */
    public function acceptSchedule(Request $request, $id)
    {
        try {
            $mitra = $request->user(); // Get authenticated mitra
            
            $schedule = PickupSchedule::findOrFail($id);
            
            // Validate schedule is available
            if ($schedule->status !== 'pending' || $schedule->assigned_mitra_id !== null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Schedule not available or already assigned',
                ], 400);
            }

            // Update schedule
            $schedule->update([
                'assigned_mitra_id' => $mitra->id,
                'assigned_at' => Carbon::now(),
                'status' => 'accepted',
            ]);

            // ✅ SEND NOTIFICATION TO END USER
            $scheduledAt = Carbon::parse($schedule->scheduled_pickup_at);
            $this->notificationService->sendToUser(
                userId: $schedule->user_id,
                type: 'schedule',
                category: 'schedule_accepted',
                title: 'Jadwal Penjemputan Diterima! 🎉',
                message: "Mitra telah menerima jadwal penjemputan Anda pada {$scheduledAt->isoFormat('dddd, DD MMM YYYY')} pukul {$scheduledAt->format('H:i')}. Bersiapkan sampah Anda ya!",
                data: [
                    'schedule_id' => $schedule->id,
                    'schedule_day' => $scheduledAt->isoFormat('dddd, DD MMM YYYY'),
                    'pickup_time' => $scheduledAt->format('H:i'),
                    'mitra_name' => $mitra->name,
                    'action_url' => '/activity',
                ],
                priority: 'high'
            );

            return response()->json([
                'success' => true,
                'message' => 'Schedule accepted successfully',
                'data' => [
                    'schedule' => $schedule,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Error accepting schedule', [
                'error' => $e->getMessage(),
                'schedule_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to accept schedule',
            ], 500);
        }
    }

    /**
     * Mitra complete pickup
     * POST /api/mitra/pickup-schedules/{id}/complete
     */
    public function completePickup(Request $request, $id)
    {
        try {
            $mitra = $request->user();
            
            $schedule = PickupSchedule::where('id', $id)
                ->where('assigned_mitra_id', $mitra->id)
                ->firstOrFail();
            
            // Validate
            if ($schedule->status === 'completed') {
                return response()->json([
                    'success' => false,
                    'message' => 'Schedule already completed',
                ], 400);
            }

            // Validate required data for completion
            $validated = $request->validate([
                'actual_weights' => 'required|array',
                'total_weight' => 'required|numeric|min:0',
                'pickup_photos' => 'nullable|array',
                'notes' => 'nullable|string',
            ]);

            // Calculate points (example: 10 points per kg)
            $pointsEarned = (int) ($validated['total_weight'] * 10);

            // Update schedule
            $schedule->update([
                'status' => 'completed',
                'completed_at' => Carbon::now(),
                'actual_weights' => json_encode($validated['actual_weights']),
                'total_weight' => $validated['total_weight'],
                'pickup_photos' => isset($validated['pickup_photos']) ? json_encode($validated['pickup_photos']) : null,
                'notes' => $validated['notes'] ?? $schedule->notes,
            ]);

            // Update user points
            $user = $schedule->user;
            $previousPoints = $user->points ?? 0;
            $user->increment('points', $pointsEarned);
            $newTotalPoints = $previousPoints + $pointsEarned;

            // ✅ SEND NOTIFICATION TO END USER
            $this->notificationService->sendToUser(
                userId: $schedule->user_id,
                type: 'schedule',
                category: 'schedule_completed',
                title: 'Penjemputan Selesai! ✅',
                message: "Sampah Anda telah berhasil dijemput seberat {$validated['total_weight']} kg. Anda mendapatkan {$pointsEarned} poin! Total poin Anda sekarang {$newTotalPoints} poin.",
                data: [
                    'schedule_id' => $schedule->id,
                    'total_weight' => $validated['total_weight'],
                    'points_earned' => $pointsEarned,
                    'total_points' => $newTotalPoints,
                    'mitra_name' => $mitra->name,
                    'action_url' => '/activity',
                ],
                priority: 'high'
            );

            return response()->json([
                'success' => true,
                'message' => 'Pickup completed successfully',
                'data' => [
                    'schedule' => $schedule,
                    'points_earned' => $pointsEarned,
                    'total_points' => $newTotalPoints,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Error completing pickup', [
                'error' => $e->getMessage(),
                'schedule_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to complete pickup',
            ], 500);
        }
    }
}
```

---

## 📡 API Endpoints for Notifications

### 1. Save FCM Token

**Endpoint:** `POST /api/user/fcm-token`

**Controller:** `app/Http/Controllers/Api/User/FcmTokenController.php`

```php
<?php

namespace App\Http\Controllers\Api\User;

use App\Models\UserFcmToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class FcmTokenController extends Controller
{
    /**
     * Save or update FCM token
     * POST /api/user/fcm-token
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'fcm_token' => 'required|string',
                'device_type' => 'required|in:android,ios,web',
                'device_name' => 'nullable|string|max:100',
            ]);

            $user = $request->user();

            // Update or create token
            UserFcmToken::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'fcm_token' => $validated['fcm_token'],
                ],
                [
                    'device_type' => $validated['device_type'],
                    'device_name' => $validated['device_name'] ?? null,
                    'is_active' => true,
                    'last_used_at' => now(),
                ]
            );

            Log::info('✅ FCM token saved', [
                'user_id' => $user->id,
                'device_type' => $validated['device_type'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'FCM token saved successfully',
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Failed to save FCM token', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()?->id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to save FCM token',
            ], 500);
        }
    }

    /**
     * Delete FCM token (logout)
     * DELETE /api/user/fcm-token
     */
    public function destroy(Request $request)
    {
        try {
            $validated = $request->validate([
                'fcm_token' => 'required|string',
            ]);

            $user = $request->user();

            UserFcmToken::where('user_id', $user->id)
                ->where('fcm_token', $validated['fcm_token'])
                ->update(['is_active' => false]);

            return response()->json([
                'success' => true,
                'message' => 'FCM token removed successfully',
            ]);
        } catch (\Exception $e) {
            Log::error('❌ Failed to remove FCM token', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to remove FCM token',
            ], 500);
        }
    }
}
```

### 2. Get Notifications

**Endpoint:** `GET /api/user/notifications`

**Controller:** `app/Http/Controllers/Api/User/NotificationController.php`

```php
<?php

namespace App\Http\Controllers\Api\User;

use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get user notifications
     * GET /api/user/notifications?page=1&is_read=0&type=schedule
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $perPage = $request->get('per_page', 20);

        $query = Notification::where('user_id', $user->id);

        // Filter by is_read
        if ($request->has('is_read')) {
            $query->where('is_read', (bool) $request->get('is_read'));
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->get('type'));
        }

        // Filter by category
        if ($request->has('category')) {
            $query->where('category', $request->get('category'));
        }

        // Order by latest
        $query->orderBy('created_at', 'desc');

        $notifications = $query->paginate($perPage);

        // Get summary
        $summary = [
            'total_notifications' => Notification::where('user_id', $user->id)->count(),
            'unread_count' => Notification::where('user_id', $user->id)
                ->where('is_read', false)
                ->count(),
            'by_priority' => [
                'urgent' => Notification::where('user_id', $user->id)
                    ->where('is_read', false)
                    ->where('priority', 'urgent')
                    ->count(),
                'high' => Notification::where('user_id', $user->id)
                    ->where('is_read', false)
                    ->where('priority', 'high')
                    ->count(),
            ],
        ];

        return response()->json([
            'success' => true,
            'message' => 'Notifications retrieved successfully',
            'data' => [
                'notifications' => $notifications->items(),
                'pagination' => [
                    'current_page' => $notifications->currentPage(),
                    'per_page' => $notifications->perPage(),
                    'total' => $notifications->total(),
                    'last_page' => $notifications->lastPage(),
                    'from' => $notifications->firstItem(),
                    'to' => $notifications->lastItem(),
                ],
                'summary' => $summary,
            ],
        ]);
    }

    /**
     * Mark notification as read
     * PUT /api/user/notifications/{id}/read
     */
    public function markAsRead(Request $request, $id)
    {
        $user = $request->user();
        
        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        $notification->update([
            'is_read' => true,
            'read_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
        ]);
    }

    /**
     * Mark all notifications as read
     * PUT /api/user/notifications/read-all
     */
    public function markAllAsRead(Request $request)
    {
        $user = $request->user();
        
        Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
        ]);
    }

    /**
     * Get unread count
     * GET /api/user/notifications/unread-count
     */
    public function unreadCount(Request $request)
    {
        $user = $request->user();
        
        $unreadCount = Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        $byCategory = Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->selectRaw('category, COUNT(*) as count')
            ->groupBy('category')
            ->pluck('count', 'category')
            ->toArray();

        $byPriority = Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->selectRaw('priority, COUNT(*) as count')
            ->groupBy('priority')
            ->pluck('count', 'priority')
            ->toArray();

        $hasUrgent = Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->where('priority', 'urgent')
            ->exists();

        return response()->json([
            'success' => true,
            'message' => 'Unread count retrieved successfully',
            'data' => [
                'unread_count' => $unreadCount,
                'by_category' => $byCategory,
                'by_priority' => $byPriority,
                'has_urgent' => $hasUrgent,
            ],
        ]);
    }
}
```

---

## 🛣️ Routes

**File:** `routes/api.php`

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\User\FcmTokenController;
use App\Http\Controllers\Api\User\NotificationController;
use App\Http\Controllers\Api\Mitra\PickupScheduleController;

// User routes (End User App)
Route::middleware(['auth:sanctum', 'role:user'])->prefix('user')->group(function () {
    // FCM Token
    Route::post('/fcm-token', [FcmTokenController::class, 'store']);
    Route::delete('/fcm-token', [FcmTokenController::class, 'destroy']);
    
    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
});

// Mitra routes (Mitra App)
Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    // Pickup Schedules
    Route::post('/pickup-schedules/{id}/accept', [PickupScheduleController::class, 'acceptSchedule']);
    Route::post('/pickup-schedules/{id}/complete', [PickupScheduleController::class, 'completePickup']);
});
```

---

## 📊 Notification Data Structure

### Schedule Accepted Notification

```json
{
  "id": 123,
  "user_id": 15,
  "type": "schedule",
  "category": "schedule_accepted",
  "title": "Jadwal Penjemputan Diterima! 🎉",
  "message": "Mitra telah menerima jadwal penjemputan Anda pada Jumat, 15 Nov 2025 pukul 10:28. Bersiapkan sampah Anda ya!",
  "icon": "ic_check",
  "priority": "high",
  "is_read": 0,
  "data": {
    "schedule_id": 75,
    "schedule_day": "Jumat, 15 Nov 2025",
    "pickup_time": "10:28",
    "mitra_name": "Driver Jakarta",
    "action_url": "/activity"
  },
  "read_at": null,
  "created_at": "2025-11-15 09:30:00",
  "updated_at": "2025-11-15 09:30:00"
}
```

### Schedule Completed Notification

```json
{
  "id": 124,
  "user_id": 15,
  "type": "schedule",
  "category": "schedule_completed",
  "title": "Penjemputan Selesai! ✅",
  "message": "Sampah Anda telah berhasil dijemput seberat 5.5 kg. Anda mendapatkan 55 poin! Total poin Anda sekarang 1055 poin.",
  "icon": "ic_check_circle",
  "priority": "high",
  "is_read": 0,
  "data": {
    "schedule_id": 75,
    "total_weight": 5.5,
    "points_earned": 55,
    "total_points": 1055,
    "mitra_name": "Driver Jakarta",
    "action_url": "/activity"
  },
  "read_at": null,
  "created_at": "2025-11-15 11:45:00",
  "updated_at": "2025-11-15 11:45:00"
}
```

---

## 🧪 Testing

### Test Schedule Accepted Notification

```bash
# Mitra accepts schedule
POST http://localhost:8000/api/mitra/pickup-schedules/75/accept
Authorization: Bearer {mitra_token}

# Expected:
# 1. Schedule status = 'accepted'
# 2. assigned_mitra_id set
# 3. Notification saved to database
# 4. Push notification sent to end user
# 5. End user app shows notification badge
```

### Test Schedule Completed Notification

```bash
# Mitra completes pickup
POST http://localhost:8000/api/mitra/pickup-schedules/75/complete
Authorization: Bearer {mitra_token}
Content-Type: application/json

{
  "actual_weights": {
    "Campuran": 3.5,
    "Organik": 2.0
  },
  "total_weight": 5.5,
  "pickup_photos": ["photo1.jpg", "photo2.jpg"],
  "notes": "Penjemputan lancar"
}

# Expected:
# 1. Schedule status = 'completed'
# 2. User points increased
# 3. Notification saved to database
# 4. Push notification sent to end user
# 5. End user app shows notification
```

### Test Get Notifications

```bash
# Get all notifications
GET http://localhost:8000/api/user/notifications?page=1
Authorization: Bearer {user_token}

# Get unread only
GET http://localhost:8000/api/user/notifications?is_read=0&page=1
Authorization: Bearer {user_token}

# Get unread count
GET http://localhost:8000/api/user/notifications/unread-count
Authorization: Bearer {user_token}
```

---

## 🎨 Frontend Display

### Push Notification Display (When App Closed)

```
╔════════════════════════════════════╗
║ 🎉 Jadwal Penjemputan Diterima!   ║
║────────────────────────────────────║
║ Mitra telah menerima jadwal        ║
║ penjemputan Anda pada Jumat,       ║
║ 15 Nov 2025 pukul 10:28.          ║
║ Bersiapkan sampah Anda ya!        ║
╚════════════════════════════════════╝
```

### In-App Notification List

```
┌─────────────────────────────────────┐
│ 🔔 Notifikasi                 [3]  │
├─────────────────────────────────────┤
│ ✅ Penjemputan Selesai!            │
│ Sampah Anda telah berhasil...      │
│ 2 jam yang lalu             [NEW]  │
├─────────────────────────────────────┤
│ 🎉 Jadwal Penjemputan Diterima!   │
│ Mitra telah menerima jadwal...     │
│ 5 jam yang lalu             [NEW]  │
├─────────────────────────────────────┤
│ 📅 Pengingat Jadwal                │
│ Jangan lupa! Besok ada jadwal...   │
│ 1 hari yang lalu                   │
└─────────────────────────────────────┘
```

---

## ✅ Checklist Implementation

### Backend Setup:
- [ ] Install `kreait/firebase-php` package
- [ ] Setup Firebase credentials file
- [ ] Add `firebase.php` config
- [ ] Create `notifications` table migration
- [ ] Create `user_fcm_tokens` table migration
- [ ] Run migrations

### Service & Controllers:
- [ ] Create `NotificationService.php`
- [ ] Create `FcmTokenController.php`
- [ ] Create `NotificationController.php`
- [ ] Update `PickupScheduleController.php` (add notifications)

### API Routes:
- [ ] Add FCM token routes
- [ ] Add notification routes
- [ ] Add schedule accept/complete routes

### Testing:
- [ ] Test schedule accepted notification
- [ ] Test schedule completed notification
- [ ] Test FCM token save/remove
- [ ] Test notification list API
- [ ] Test unread count API
- [ ] Test mark as read functionality

### Deployment:
- [ ] Upload Firebase credentials to server
- [ ] Update .env with Firebase config
- [ ] Test on staging
- [ ] Deploy to production

---

## 📞 Support

**Jika ada pertanyaan atau butuh klarifikasi:**
- Frontend Developer (Flutter) - Sudah siap
- Backend Developer (Laravel) - Perlu implement dokumentasi ini
- Firebase Console - Perlu credentials file

---

## 🎯 Priority

**HIGH PRIORITY** - Notification adalah fitur penting untuk user engagement

**Impact:**
- ✅ User tahu saat jadwal diterima
- ✅ User tahu saat penjemputan selesai
- ✅ User dapat poin dan lihat riwayat
- ✅ Meningkatkan kepuasan user

---

**Dokumentasi ini dibuat:** November 14, 2025  
**Untuk:** Tim Backend Laravel  
**Status:** ✅ Frontend Ready, ⏳ Menunggu Backend Implementation  
**Version:** 1.0
