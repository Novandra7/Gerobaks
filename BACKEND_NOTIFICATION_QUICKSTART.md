# 🚀 Quick Start Guide - Backend Notification Implementation

**For:** Backend Laravel Team  
**Time Estimate:** 4 hours total  
**Difficulty:** Medium  

---

## ⚡ TL;DR

**What to do:**
1. Install Firebase PHP SDK
2. Create 2 database tables
3. Create 1 service + 3 controllers
4. Add notification calls to existing accept/complete methods
5. Test & deploy

**Result:** Users get push notifications saat jadwal diterima & selesai

---

## 📦 Quick Setup (30 minutes)

### Step 1: Install Firebase
```bash
composer require kreait/firebase-php
```

### Step 2: Download Firebase Credentials
1. Go to Firebase Console → Project Settings
2. Service Accounts → Generate new private key
3. Save as `storage/app/firebase/firebase-credentials.json`

### Step 3: Config Firebase
```php
// config/firebase.php
<?php
return [
    'credentials' => [
        'file' => storage_path('app/firebase/firebase-credentials.json'),
    ],
];
```

### Step 4: Update .env
```env
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
```

---

## 🗄️ Database (15 minutes)

### Migration 1: Notifications Table
```bash
php artisan make:migration create_notifications_table
```

```php
public function up()
{
    Schema::create('notifications', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->onDelete('cascade');
        $table->string('type', 50);
        $table->string('category', 50);
        $table->string('title');
        $table->text('message');
        $table->string('icon', 100)->default('ic_notification');
        $table->string('priority', 20)->default('normal');
        $table->boolean('is_read')->default(false);
        $table->json('data')->nullable();
        $table->timestamp('read_at')->nullable();
        $table->timestamps();
        
        $table->index(['user_id', 'is_read', 'created_at']);
    });
}
```

### Migration 2: FCM Tokens Table
```bash
php artisan make:migration create_user_fcm_tokens_table
```

```php
public function up()
{
    Schema::create('user_fcm_tokens', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained()->onDelete('cascade');
        $table->string('fcm_token');
        $table->string('device_type', 20);
        $table->string('device_name', 100)->nullable();
        $table->boolean('is_active')->default(true);
        $table->timestamp('last_used_at')->nullable();
        $table->timestamps();
        
        $table->unique(['user_id', 'fcm_token']);
    });
}
```

```bash
php artisan migrate
```

---

## 💻 Code Implementation (2 hours)

### 1. NotificationService (Core Logic)

**File:** `app/Services/NotificationService.php`

```php
<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\UserFcmToken;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

class NotificationService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(config('firebase.credentials.file'));
        $this->messaging = $factory->createMessaging();
    }

    public function sendToUser(
        int $userId,
        string $type,
        string $category,
        string $title,
        string $message,
        array $data = [],
        string $priority = 'normal'
    ): bool {
        // 1. Save to database
        Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'category' => $category,
            'title' => $title,
            'message' => $message,
            'icon' => $this->getIcon($category),
            'priority' => $priority,
            'data' => json_encode($data),
        ]);

        // 2. Get FCM tokens
        $tokens = UserFcmToken::where('user_id', $userId)
            ->where('is_active', true)
            ->pluck('fcm_token')
            ->toArray();

        if (empty($tokens)) return true;

        // 3. Send FCM push
        $notification = FirebaseNotification::create($title, $message);
        
        foreach ($tokens as $token) {
            try {
                $msg = CloudMessage::withTarget('token', $token)
                    ->withNotification($notification)
                    ->withData($data);
                
                $this->messaging->send($msg);
            } catch (\Exception $e) {
                // Token invalid, deactivate
                UserFcmToken::where('fcm_token', $token)
                    ->update(['is_active' => false]);
            }
        }

        return true;
    }

    protected function getIcon(string $category): string
    {
        return match($category) {
            'schedule_accepted' => 'ic_check',
            'schedule_completed' => 'ic_check_circle',
            default => 'ic_notification',
        };
    }
}
```

### 2. Update PickupScheduleController

**File:** `app/Http/Controllers/Api/Mitra/PickupScheduleController.php`

Add to constructor:
```php
protected $notificationService;

public function __construct(NotificationService $notificationService)
{
    $this->notificationService = $notificationService;
}
```

Update `acceptSchedule` method - add AFTER schedule update:
```php
public function acceptSchedule(Request $request, $id)
{
    // ... existing code to update schedule ...
    
    // ✅ ADD THIS: Send notification
    $scheduledAt = Carbon::parse($schedule->scheduled_pickup_at);
    $this->notificationService->sendToUser(
        userId: $schedule->user_id,
        type: 'schedule',
        category: 'schedule_accepted',
        title: 'Jadwal Penjemputan Diterima! 🎉',
        message: "Mitra telah menerima jadwal penjemputan Anda pada {$scheduledAt->isoFormat('dddd, DD MMM YYYY')} pukul {$scheduledAt->format('H:i')}.",
        data: [
            'schedule_id' => $schedule->id,
            'schedule_day' => $scheduledAt->isoFormat('dddd, DD MMM YYYY'),
            'pickup_time' => $scheduledAt->format('H:i'),
        ],
        priority: 'high'
    );
    
    // ... return response ...
}
```

Update `completePickup` method - add AFTER points calculation:
```php
public function completePickup(Request $request, $id)
{
    // ... existing code to update schedule & points ...
    
    // ✅ ADD THIS: Send notification
    $pointsEarned = (int) ($validated['total_weight'] * 10);
    $newTotalPoints = $user->points;
    
    $this->notificationService->sendToUser(
        userId: $schedule->user_id,
        type: 'schedule',
        category: 'schedule_completed',
        title: 'Penjemputan Selesai! ✅',
        message: "Sampah Anda telah berhasil dijemput seberat {$validated['total_weight']} kg. Anda mendapatkan {$pointsEarned} poin! Total poin: {$newTotalPoints}.",
        data: [
            'schedule_id' => $schedule->id,
            'total_weight' => $validated['total_weight'],
            'points_earned' => $pointsEarned,
            'total_points' => $newTotalPoints,
        ],
        priority: 'high'
    );
    
    // ... return response ...
}
```

### 3. FCM Token Controller (New)

**File:** `app/Http/Controllers/Api/User/FcmTokenController.php`

```php
<?php

namespace App\Http\Controllers\Api\User;

use App\Models\UserFcmToken;
use Illuminate\Http\Request;

class FcmTokenController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'fcm_token' => 'required|string',
            'device_type' => 'required|in:android,ios,web',
        ]);

        UserFcmToken::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'fcm_token' => $validated['fcm_token'],
            ],
            [
                'device_type' => $validated['device_type'],
                'is_active' => true,
                'last_used_at' => now(),
            ]
        );

        return response()->json(['success' => true]);
    }
}
```

### 4. Notification Controller (New)

**File:** `app/Http/Controllers/Api/User/NotificationController.php`

```php
<?php

namespace App\Http\Controllers\Api\User;

use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications->items(),
                'pagination' => [
                    'current_page' => $notifications->currentPage(),
                    'total' => $notifications->total(),
                    'last_page' => $notifications->lastPage(),
                ],
            ],
        ]);
    }

    public function unreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $count],
        ]);
    }

    public function markAsRead($id)
    {
        Notification::where('id', $id)
            ->where('user_id', auth()->id())
            ->update(['is_read' => true, 'read_at' => now()]);

        return response()->json(['success' => true]);
    }
}
```

---

## 🛣️ Routes (15 minutes)

**File:** `routes/api.php`

```php
// User routes
Route::middleware(['auth:sanctum'])->prefix('user')->group(function () {
    Route::post('/fcm-token', [FcmTokenController::class, 'store']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
});

// Mitra routes (already exist, just verify they work)
Route::middleware(['auth:sanctum'])->prefix('mitra')->group(function () {
    Route::post('/pickup-schedules/{id}/accept', [PickupScheduleController::class, 'acceptSchedule']);
    Route::post('/pickup-schedules/{id}/complete', [PickupScheduleController::class, 'completePickup']);
});
```

---

## 🧪 Testing (1 hour)

### Test 1: Accept Schedule
```bash
# Mitra accepts
curl -X POST http://localhost:8000/api/mitra/pickup-schedules/75/accept \
  -H "Authorization: Bearer {mitra_token}"

# Check database
mysql> SELECT * FROM notifications WHERE user_id = 15 ORDER BY id DESC LIMIT 1;
```

**Expected:** Notification saved with category "schedule_accepted"

### Test 2: Complete Pickup
```bash
# Mitra completes
curl -X POST http://localhost:8000/api/mitra/pickup-schedules/75/complete \
  -H "Authorization: Bearer {mitra_token}" \
  -d '{"actual_weights": {"Campuran": 5}, "total_weight": 5}'

# Check database
mysql> SELECT * FROM notifications WHERE user_id = 15 ORDER BY id DESC LIMIT 1;
mysql> SELECT points FROM users WHERE id = 15;
```

**Expected:** Notification saved with points data

### Test 3: Get Notifications (Frontend)
```bash
# Get notifications
curl http://localhost:8000/api/user/notifications \
  -H "Authorization: Bearer {user_token}"
```

**Expected:** JSON with notifications array

---

## ✅ Checklist

- [ ] Install Firebase PHP SDK
- [ ] Setup Firebase credentials
- [ ] Create notifications table
- [ ] Create user_fcm_tokens table
- [ ] Create NotificationService
- [ ] Update PickupScheduleController (2 methods)
- [ ] Create FcmTokenController
- [ ] Create NotificationController
- [ ] Add API routes
- [ ] Test accept notification
- [ ] Test complete notification
- [ ] Test frontend receives notifications

---

## 🚨 Common Issues

**Issue 1:** "Firebase credentials not found"
- **Fix:** Make sure `firebase-credentials.json` exists in `storage/app/firebase/`

**Issue 2:** "No FCM tokens found"
- **Fix:** User needs to open app first, frontend will save token automatically

**Issue 3:** "Token not valid"
- **Fix:** Token expired, app will get new token automatically

---

## 📞 Need Help?

**Full documentation:** `BACKEND_NOTIFICATION_SCHEDULE_EVENTS.md`  
**Summary:** `NOTIFICATION_FEATURE_SUMMARY.md`

---

**Estimated Time:** 4 hours  
**Difficulty:** Medium  
**Priority:** High
