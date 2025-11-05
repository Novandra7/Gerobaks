# Controller destroy() Methods - Implementation Guide

## ✅ Status Tracker

### Controllers with destroy() Added:

- [x] ScheduleController ✅
- [x] ServiceController ✅
- [ ] TrackingController
- [ ] OrderController
- [ ] PaymentController
- [ ] RatingController
- [ ] NotificationController
- [ ] ChatController
- [ ] FeedbackController
- [ ] ReportController
- [ ] SubscriptionPlanController
- [ ] SubscriptionController
- [ ] AdminController (deleteUser, clearLogs)
- [ ] SettingsController

## Method Templates by Controller

### TrackingController::destroy()

```php
public function destroy(int $id)
{
    $tracking = \App\Models\Tracking::findOrFail($id);

    // Only admin can delete tracking records
    if (auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: Admin access required'
        ], 403);
    }

    $tracking->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Tracking record deleted successfully'
    ], 200);
}
```

### OrderController::destroy()

```php
public function destroy(int $id)
{
    $order = \App\Models\Order::findOrFail($id);

    // Authorization: User can delete own orders, admin can delete any
    $user = auth()->user();
    if ($user->role !== 'admin' && $order->user_id !== $user->id) {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: You can only delete your own orders'
        ], 403);
    }

    // Cannot delete orders that are in progress or completed
    if (in_array($order->status, ['in_progress', 'completed', 'delivered'])) {
        return response()->json([
            'status' => 'error',
            'message' => 'Cannot delete order in current status'
        ], 422);
    }

    $order->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Order deleted successfully'
    ], 200);
}
```

### PaymentController::destroy()

```php
public function destroy(int $id)
{
    // Only admin can delete payments
    if (auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: Admin access required'
        ], 403);
    }

    $payment = \App\Models\Payment::findOrFail($id);

    // Cannot delete paid/completed payments
    if ($payment->status === 'paid' || $payment->status === 'completed') {
        return response()->json([
            'status' => 'error',
            'message' => 'Cannot delete completed payments'
        ], 422);
    }

    $payment->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Payment record deleted successfully'
    ], 200);
}
```

### RatingController::destroy()

```php
public function destroy(int $id)
{
    $rating = \App\Models\Rating::findOrFail($id);

    // Only the user who created the rating can delete it
    if ($rating->user_id !== auth()->id()) {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: You can only delete your own ratings'
        ], 403);
    }

    $rating->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Rating deleted successfully'
    ], 200);
}
```

### NotificationController::destroy()

```php
public function destroy(int $id)
{
    $notification = \App\Models\Notification::findOrFail($id);

    // Users can delete their own notifications
    if ($notification->user_id !== auth()->id() && auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: You can only delete your own notifications'
        ], 403);
    }

    $notification->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Notification deleted successfully'
    ], 200);
}
```

### ChatController::destroy()

```php
public function destroy(int $id)
{
    $chat = \App\Models\Chat::findOrFail($id);

    // Users can delete their own messages
    if ($chat->sender_id !== auth()->id() && auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: You can only delete your own messages'
        ], 403);
    }

    $chat->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Message deleted successfully'
    ], 200);
}
```

### FeedbackController::destroy()

```php
public function destroy(int $id)
{
    $feedback = \App\Models\Feedback::findOrFail($id);

    // Users can delete their own feedback
    if ($feedback->user_id !== auth()->id() && auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: You can only delete your own feedback'
        ], 403);
    }

    $feedback->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Feedback deleted successfully'
    ], 200);
}
```

### ReportController::destroy()

```php
public function destroy(int $id)
{
    // Only admin can delete reports
    if (auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: Admin access required'
        ], 403);
    }

    $report = \App\Models\Report::findOrFail($id);
    $report->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Report deleted successfully'
    ], 200);
}
```

### SubscriptionPlanController::destroy()

```php
public function destroy(int $id)
{
    // Only admin can delete subscription plans
    if (auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: Admin access required'
        ], 403);
    }

    $plan = \App\Models\SubscriptionPlan::findOrFail($id);

    // Check if plan is being used
    $activeSubscriptions = \App\Models\Subscription::where('plan_id', $id)
        ->where('status', 'active')
        ->count();

    if ($activeSubscriptions > 0) {
        return response()->json([
            'status' => 'error',
            'message' => 'Cannot delete subscription plan with active subscriptions'
        ], 422);
    }

    $plan->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Subscription plan deleted successfully'
    ], 200);
}
```

### SubscriptionController::destroy()

```php
public function destroy(int $id)
{
    // Only admin can force-delete subscriptions
    if (auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: Admin access required'
        ], 403);
    }

    $subscription = \App\Models\Subscription::findOrFail($id);

    // Cancel first if active
    if ($subscription->status === 'active') {
        $subscription->update(['status' => 'cancelled', 'cancelled_at' => now()]);
    }

    $subscription->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Subscription deleted successfully'
    ], 200);
}
```

### SettingsController::destroy()

```php
public function destroy(string $key)
{
    // Only admin can delete settings
    if (auth()->user()->role !== 'admin') {
        return response()->json([
            'status' => 'error',
            'message' => 'Forbidden: Admin access required'
        ], 403);
    }

    $setting = \App\Models\Setting::where('key', $key)->first();

    if (!$setting) {
        return response()->json([
            'status' => 'error',
            'message' => 'Setting not found'
        ], 404);
    }

    $setting->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Setting deleted successfully'
    ], 200);
}
```

### AdminController - Additional Methods

#### deleteUser()

```php
public function deleteUser(int $id)
{
    $user = \App\Models\User::findOrFail($id);

    // Cannot delete yourself
    if ($user->id === auth()->id()) {
        return response()->json([
            'status' => 'error',
            'message' => 'You cannot delete your own account'
        ], 422);
    }

    // Soft delete to preserve data integrity
    $user->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'User deleted successfully'
    ], 200);
}
```

#### clearLogs()

```php
public function clearLogs()
{
    // Clear application logs (implementation depends on logging setup)
    // This is a placeholder - adjust based on your logging implementation

    try {
        \Log::info('Admin cleared logs', ['admin_id' => auth()->id()]);

        return response()->json([
            'status' => 'success',
            'message' => 'Logs cleared successfully'
        ], 200);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to clear logs: ' . $e->getMessage()
        ], 500);
    }
}
```

## Implementation Notes

### Authorization Patterns

1. **Admin Only:**

   ```php
   if (auth()->user()->role !== 'admin') {
       return response()->json(['status' => 'error', 'message' => 'Forbidden'], 403);
   }
   ```

2. **Owner or Admin:**

   ```php
   if ($resource->user_id !== auth()->id() && auth()->user()->role !== 'admin') {
       return response()->json(['status' => 'error', 'message' => 'Forbidden'], 403);
   }
   ```

3. **Owner Only:**
   ```php
   if ($resource->user_id !== auth()->id()) {
       return response()->json(['status' => 'error', 'message' => 'Forbidden'], 403);
   }
   ```

### Business Logic Checks

1. **Check Status Before Delete:**

   ```php
   if (in_array($resource->status, ['completed', 'in_progress'])) {
       return response()->json(['status' => 'error', 'message' => 'Cannot delete'], 422);
   }
   ```

2. **Check Dependencies:**
   ```php
   if ($resource->children()->count() > 0) {
       return response()->json(['status' => 'error', 'message' => 'Has dependencies'], 422);
   }
   ```

### Response Format

**Success:**

```json
{
  "status": "success",
  "message": "Resource deleted successfully"
}
```

**Error:**

```json
{
  "status": "error",
  "message": "Forbidden: You can only delete your own resources"
}
```

---

Last Updated: November 5, 2025
