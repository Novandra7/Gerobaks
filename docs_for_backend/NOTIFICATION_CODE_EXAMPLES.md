# 🔔 Notification Implementation Code

> **File ini berisi contoh kode lengkap untuk notification system**

---

## 📁 File Structure

```
app/
├── Notifications/
│   ├── MitraAssigned.php
│   ├── PickupCompleted.php
│   └── PickupCancelled.php
├── Events/
│   └── PickupStatusUpdated.php
└── Http/Controllers/Api/Mitra/
    └── MitraPickupController.php
```

---

## 1️⃣ Notification: MitraAssigned.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\DatabaseMessage;
use App\Models\PickupSchedule;
use App\Models\User;

class MitraAssigned extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $mitra;

    public function __construct(PickupSchedule $schedule, User $mitra)
    {
        $this->schedule = $schedule;
        $this->mitra = $mitra;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'mitra_assigned',
            'title' => 'Mitra Menerima Jadwal Anda!',
            'message' => "Mitra {$this->mitra->name} menerima jadwal pengambilan Anda.",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'on_progress',
                'mitra' => [
                    'id' => $this->mitra->id,
                    'name' => $this->mitra->name,
                    'phone' => $this->mitra->phone,
                    'vehicle_type' => $this->mitra->vehicle_type,
                    'vehicle_plate' => $this->mitra->vehicle_plate,
                ],
                'scheduled_pickup_at' => $this->schedule->scheduled_pickup_at,
            ],
            'action_url' => "/activity/schedule/{$this->schedule->id}",
            'icon' => 'ic_truck.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }

    /**
     * Get the broadcastable representation of the notification.
     */
    public function toBroadcast($notifiable)
    {
        return new DatabaseMessage([
            'type' => 'pickup_status',
            'action' => 'mitra_assigned',
            'title' => 'Mitra Menerima Jadwal Anda!',
            'message' => "Mitra {$this->mitra->name} menerima jadwal pengambilan Anda.",
            'schedule_id' => $this->schedule->id,
        ]);
    }
}
```

---

## 2️⃣ Notification: PickupCompleted.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\DatabaseMessage;
use App\Models\PickupSchedule;

class PickupCompleted extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $points;

    public function __construct(PickupSchedule $schedule, int $points)
    {
        $this->schedule = $schedule;
        $this->points = $points;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'pickup_completed',
            'title' => 'Pengambilan Selesai!',
            'message' => "Pengambilan sampah selesai. Anda mendapat +{$this->points} poin!",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'completed',
                'total_weight' => $this->schedule->total_weight,
                'actual_weights' => $this->schedule->actual_weights,
                'points_earned' => $this->points,
                'pickup_photos' => $this->schedule->pickup_photos,
                'completed_at' => $this->schedule->completed_at,
                'mitra' => [
                    'id' => $this->schedule->mitra->id,
                    'name' => $this->schedule->mitra->name,
                ],
            ],
            'action_url' => "/activity/schedule/{$this->schedule->id}",
            'icon' => 'ic_check.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }

    /**
     * Get the broadcastable representation of the notification.
     */
    public function toBroadcast($notifiable)
    {
        return new DatabaseMessage([
            'type' => 'pickup_status',
            'action' => 'pickup_completed',
            'title' => 'Pengambilan Selesai!',
            'message' => "Anda mendapat +{$this->points} poin!",
            'schedule_id' => $this->schedule->id,
            'points_earned' => $this->points,
        ]);
    }
}
```

---

## 3️⃣ Notification: PickupCancelled.php

```php
<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use App\Models\PickupSchedule;

class PickupCancelled extends Notification implements ShouldQueue
{
    use Queueable;

    protected $schedule;
    protected $reason;

    public function __construct(PickupSchedule $schedule, string $reason)
    {
        $this->schedule = $schedule;
        $this->reason = $reason;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable)
    {
        return ['database', 'broadcast'];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray($notifiable)
    {
        return [
            'type' => 'pickup_status',
            'action' => 'pickup_cancelled',
            'title' => 'Jadwal Dibatalkan',
            'message' => "Mitra membatalkan jadwal pengambilan. Alasan: {$this->reason}",
            'data' => [
                'schedule_id' => $this->schedule->id,
                'schedule_status' => 'pending',
                'cancellation_reason' => $this->reason,
                'cancelled_at' => now()->toISOString(),
            ],
            'action_url' => "/activity",
            'icon' => 'ic_notification.png',
            'is_read' => false,
            'created_at' => now()->toISOString(),
        ];
    }
}
```

---

## 4️⃣ Event: PickupStatusUpdated.php (for Realtime Broadcasting)

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\PickupSchedule;

class PickupStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $schedule;

    /**
     * Create a new event instance.
     */
    public function __construct(PickupSchedule $schedule)
    {
        $this->schedule = $schedule->load('mitra', 'user');
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->schedule->user_id);
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith()
    {
        return [
            'schedule_id' => $this->schedule->id,
            'status' => $this->schedule->status,
            'mitra' => $this->schedule->mitra ? [
                'id' => $this->schedule->mitra->id,
                'name' => $this->schedule->mitra->name,
                'phone' => $this->schedule->mitra->phone,
                'vehicle_type' => $this->schedule->mitra->vehicle_type ?? 'Truk',
                'vehicle_plate' => $this->schedule->mitra->vehicle_plate ?? '-',
            ] : null,
            'updated_at' => $this->schedule->updated_at->toISOString(),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs()
    {
        return 'pickup.status_updated';
    }
}
```

---

## 5️⃣ Usage dalam Controller

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use App\Http\Controllers\Controller;
use App\Models\PickupSchedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Events\PickupStatusUpdated;
use App\Notifications\MitraAssigned;
use App\Notifications\PickupCompleted;
use App\Notifications\PickupCancelled;

class MitraPickupController extends Controller
{
    /**
     * Accept schedule
     */
    public function acceptSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('status', 'pending')
                                  ->whereNull('assigned_mitra_id')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $mitra) {
            // 1. Update schedule
            $schedule->update([
                'assigned_mitra_id' => $mitra->id,
                'status' => 'on_progress',
                'assigned_at' => now(),
            ]);
            
            // 2. Send notification to user
            $schedule->user->notify(new MitraAssigned($schedule, $mitra));
            
            // 3. Broadcast realtime event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule accepted successfully',
            'data' => [
                'schedule' => $schedule->load('mitra')
            ]
        ]);
    }
    
    /**
     * Complete pickup
     */
    public function completePickup(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'actual_weights' => 'required|array',
            'actual_weights.*' => 'numeric|min:0',
            'photos' => 'required|array|min:1',
            'photos.*' => 'image|max:5120',
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $request, $mitra) {
            // 1. Calculate total weight
            $totalWeight = array_sum($request->actual_weights);
            
            // 2. Upload photos
            $photoUrls = [];
            foreach ($request->file('photos') as $photo) {
                $path = $photo->store("pickups/{$schedule->id}", 'public');
                $photoUrls[] = \Storage::url($path);
            }
            
            // 3. Update schedule
            $schedule->update([
                'status' => 'completed',
                'completed_at' => now(),
                'actual_weights' => $request->actual_weights,
                'total_weight' => $totalWeight,
                'pickup_photos' => $photoUrls,
            ]);
            
            // 4. Add points to user (1 kg = 10 points)
            $points = (int)($totalWeight * 10);
            $schedule->user->increment('points', $points);
            
            // 5. Send notification to user
            $schedule->user->notify(new PickupCompleted($schedule, $points));
            
            // 6. Update mitra stats
            $mitra->increment('total_collections');
            
            // 7. Broadcast realtime event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Pickup completed successfully',
            'data' => [
                'schedule' => $schedule,
                'points_earned' => (int)($schedule->total_weight * 10)
            ]
        ]);
    }
    
    /**
     * Cancel schedule
     */
    public function cancelSchedule(Request $request, $id)
    {
        $mitra = Auth::user();
        
        $request->validate([
            'reason' => 'required|string'
        ]);
        
        $schedule = PickupSchedule::where('id', $id)
                                  ->where('assigned_mitra_id', $mitra->id)
                                  ->where('status', 'on_progress')
                                  ->firstOrFail();
        
        DB::transaction(function() use ($schedule, $request, $mitra) {
            // 1. Update schedule back to pending
            $schedule->update([
                'status' => 'pending',
                'assigned_mitra_id' => null,
                'assigned_at' => null,
                'on_the_way_at' => null,
                'cancelled_at' => now(),
                'cancellation_reason' => $request->reason
            ]);
            
            // 2. Send notification to user
            $schedule->user->notify(new PickupCancelled($schedule, $request->reason));
            
            // 3. Broadcast realtime event
            broadcast(new PickupStatusUpdated($schedule))->toOthers();
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Schedule cancelled and returned to available pool'
        ]);
    }
}
```

---

## 6️⃣ Broadcasting Configuration

### config/broadcasting.php

```php
'connections' => [
    
    'pusher' => [
        'driver' => 'pusher',
        'key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'encrypted' => true,
            'host' => env('PUSHER_HOST', 'api-'.env('PUSHER_APP_CLUSTER', 'mt1').'.pusher.com'),
            'port' => env('PUSHER_PORT', 443),
            'scheme' => env('PUSHER_SCHEME', 'https'),
        ],
    ],

],
```

### .env

```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=your_app_id
PUSHER_APP_KEY=your_app_key
PUSHER_APP_SECRET=your_app_secret
PUSHER_APP_CLUSTER=mt1
```

---

## 7️⃣ Routes Configuration

### routes/channels.php

```php
<?php

use Illuminate\Support\Facades\Broadcast;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
*/

// Private channel for user
Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});

// Private channel for mitra
Broadcast::channel('mitra.{mitraId}', function ($user, $mitraId) {
    return (int) $user->id === (int) $mitraId && $user->role === 'mitra';
});
```

### routes/api.php

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Mitra\MitraPickupController;

// Mitra routes
Route::middleware(['auth:sanctum', 'role:mitra'])->prefix('mitra')->group(function () {
    
    // Pickup schedules
    Route::prefix('pickup-schedules')->group(function () {
        Route::get('/available', [MitraPickupController::class, 'availableSchedules']);
        Route::get('/my-active', [MitraPickupController::class, 'myActiveSchedules']);
        Route::get('/history', [MitraPickupController::class, 'history']);
        Route::get('/{id}', [MitraPickupController::class, 'showSchedule']);
        
        Route::post('/{id}/accept', [MitraPickupController::class, 'acceptSchedule']);
        Route::post('/{id}/start-journey', [MitraPickupController::class, 'startJourney']);
        Route::post('/{id}/arrive', [MitraPickupController::class, 'arrive']);
        Route::post('/{id}/complete', [MitraPickupController::class, 'completePickup']);
        Route::post('/{id}/cancel', [MitraPickupController::class, 'cancelSchedule']);
    });
});
```

---

## 8️⃣ Database Migration

### database/migrations/xxxx_add_mitra_fields_to_pickup_schedules.php

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            // Mitra assignment
            $table->unsignedBigInteger('assigned_mitra_id')->nullable()->after('user_id');
            $table->timestamp('assigned_at')->nullable()->after('assigned_mitra_id');
            
            // Tracking timestamps
            $table->timestamp('on_the_way_at')->nullable()->after('assigned_at');
            $table->timestamp('picked_up_at')->nullable()->after('on_the_way_at');
            $table->timestamp('completed_at')->nullable()->after('picked_up_at');
            
            // Completion data
            $table->json('actual_weights')->nullable()->after('completed_at');
            $table->decimal('total_weight', 8, 2)->nullable()->after('actual_weights');
            $table->json('pickup_photos')->nullable()->after('total_weight');
            
            // Cancellation
            $table->timestamp('cancelled_at')->nullable()->after('pickup_photos');
            $table->text('cancellation_reason')->nullable()->after('cancelled_at');
            
            // Foreign key
            $table->foreign('assigned_mitra_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('set null');
            
            // Indexes
            $table->index('assigned_mitra_id');
            $table->index(['status', 'assigned_mitra_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('pickup_schedules', function (Blueprint $table) {
            $table->dropForeign(['assigned_mitra_id']);
            $table->dropIndex(['assigned_mitra_id']);
            $table->dropIndex(['status', 'assigned_mitra_id']);
            
            $table->dropColumn([
                'assigned_mitra_id',
                'assigned_at',
                'on_the_way_at',
                'picked_up_at',
                'completed_at',
                'actual_weights',
                'total_weight',
                'pickup_photos',
                'cancelled_at',
                'cancellation_reason'
            ]);
        });
    }
};
```

---

## 9️⃣ Model Relationships

### app/Models/PickupSchedule.php

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PickupSchedule extends Model
{
    protected $fillable = [
        'user_id',
        'assigned_mitra_id',
        'pickup_address',
        'latitude',
        'longitude',
        'schedule_day',
        'waste_type_scheduled',
        'scheduled_pickup_at',
        'pickup_time_start',
        'pickup_time_end',
        'has_additional_waste',
        'additional_wastes',
        'waste_summary',
        'notes',
        'status',
        'assigned_at',
        'on_the_way_at',
        'picked_up_at',
        'completed_at',
        'actual_weights',
        'total_weight',
        'pickup_photos',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected $casts = [
        'additional_wastes' => 'array',
        'actual_weights' => 'array',
        'pickup_photos' => 'array',
        'scheduled_pickup_at' => 'datetime',
        'assigned_at' => 'datetime',
        'on_the_way_at' => 'datetime',
        'picked_up_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'has_additional_waste' => 'boolean',
        'total_weight' => 'float',
    ];

    /**
     * Get the user who created the schedule
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the mitra assigned to the schedule
     */
    public function mitra()
    {
        return $this->belongsTo(User::class, 'assigned_mitra_id');
    }
}
```

### app/Models/User.php (tambahan)

```php
/**
 * Get pickup schedules created by this user
 */
public function pickupSchedules()
{
    return $this->hasMany(PickupSchedule::class, 'user_id');
}

/**
 * Get pickup schedules assigned to this mitra
 */
public function assignedSchedules()
{
    return $this->hasMany(PickupSchedule::class, 'assigned_mitra_id');
}
```

---

## 🧪 Testing Examples

### Test Accept Schedule

```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept" \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Schedule accepted successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "on_progress",
      "assigned_mitra_id": 8,
      "assigned_at": "2025-11-12 15:30:00"
    }
  }
}
```

**Expected Side Effects:**
1. Database updated
2. Notification created in `notifications` table
3. User receives notification (check `/api/notifications`)
4. Realtime event broadcasted (check Pusher dashboard)

### Test Complete Pickup

```bash
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete" \
  -H "Authorization: Bearer {mitra_token}" \
  -F "actual_weights[Organik]=3.5" \
  -F "actual_weights[Anorganik]=2.0" \
  -F "actual_weights[B3]=1.2" \
  -F "photos[]=@photo1.jpg" \
  -F "photos[]=@photo2.jpg" \
  -F "notes=Selesai tepat waktu"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Pickup completed successfully",
  "data": {
    "schedule": {
      "id": 36,
      "status": "completed",
      "total_weight": 6.7,
      "pickup_photos": [
        "http://localhost/storage/pickups/36/photo1.jpg",
        "http://localhost/storage/pickups/36/photo2.jpg"
      ]
    },
    "points_earned": 67
  }
}
```

**Verify User Points:**
```bash
curl -X GET "http://127.0.0.1:8000/api/user/profile" \
  -H "Authorization: Bearer {user_token}"
```

Should show `points` increased by 67.

---

## ✅ Implementation Checklist

**Backend:**
- [ ] Run migration untuk tambah kolom
- [ ] Buat notification classes (3 files)
- [ ] Buat event class untuk broadcasting
- [ ] Implement controller methods
- [ ] Add routes
- [ ] Test accept schedule
- [ ] Test complete pickup
- [ ] Test cancel schedule
- [ ] Verify notifications sent
- [ ] Verify points auto-increment
- [ ] Test realtime broadcasting (optional)

**Frontend (Flutter):**
- [ ] Handle notification when status changes
- [ ] Update UI when schedule status changes
- [ ] Display mitra info in user app
- [ ] Implement mitra app screens
- [ ] Test end-to-end flow

---

**Status:** Ready to implement  
**Priority:** 🔴 URGENT - Core Feature
