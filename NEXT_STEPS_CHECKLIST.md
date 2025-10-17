# 🎯 NEXT STEPS CHECKLIST - Model Creation & Testing

## ✅ Phase 1: Service Files - COMPLETE! (12/12)

All service files have been created successfully with 100% API coverage!

---

## ⏳ Phase 2: Model Creation (NEXT STEP)

Create Dart model classes for data serialization/deserialization.

### Models to Create (10 files)

- [ ] **lib/models/tracking_model.dart**

  ```dart
  class TrackingModel {
    final int id;
    final int orderId;
    final double latitude;
    final double longitude;
    final DateTime timestamp;

    TrackingModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/rating_model.dart** (CRITICAL - causing compile errors)

  ```dart
  class RatingModel {
    final int id;
    final int orderId;
    final int userId;
    final int mitraId; // Auto-populated by backend
    final int score; // 1-5
    final String? review;
    final DateTime createdAt;

    RatingModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/chat_model.dart**

  ```dart
  class ChatModel {
    final int id;
    final int senderId;
    final int receiverId;
    final String message;
    final String type; // text, image, location
    final bool isRead;
    final DateTime createdAt;

    ChatModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/payment_model.dart**

  ```dart
  class PaymentModel {
    final int id;
    final int orderId;
    final double amount;
    final String method; // cash, transfer, ewallet, qris
    final String status; // pending, completed, failed
    final String? proofImage;
    final DateTime createdAt;

    PaymentModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/balance_model.dart**

  ```dart
  class BalanceModel {
    final int id;
    final int userId;
    final double amount;
    final DateTime updatedAt;

    BalanceModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }

  class BalanceLedgerModel {
    final int id;
    final int balanceId;
    final String type; // credit, debit
    final double amount;
    final String description;
    final DateTime createdAt;

    BalanceLedgerModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/subscription_model.dart**

  ```dart
  class SubscriptionModel {
    final int id;
    final int userId;
    final String plan; // basic, premium, enterprise
    final String billingCycle; // monthly, quarterly, yearly
    final String status; // active, expired, cancelled
    final bool autoRenew;
    final DateTime startDate;
    final DateTime? endDate;

    SubscriptionModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/feedback_model.dart**

  ```dart
  class FeedbackModel {
    final int id;
    final int userId;
    final String type; // bug_report, feature_request, etc.
    final String subject;
    final String message;
    final String status; // pending, reviewed, resolved
    final String? priority;
    final String? adminResponse;
    final DateTime createdAt;

    FeedbackModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/notification_model.dart**

  ```dart
  class NotificationModel {
    final int id;
    final int userId;
    final String type;
    final String title;
    final String message;
    final bool isRead;
    final DateTime createdAt;

    NotificationModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/order_model.dart**

  ```dart
  class OrderModel {
    final int id;
    final int userId;
    final int scheduleId;
    final int? mitraId;
    final String wasteType;
    final double estimatedWeight;
    final double? actualWeight;
    final String pickupAddress;
    final double? latitude;
    final double? longitude;
    final String status;
    final double? totalPrice;
    final DateTime createdAt;

    OrderModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

- [ ] **lib/models/schedule_model.dart**
  ```dart
  class ScheduleModel {
    final int id;
    final int userId;
    final String pickupDate;
    final String pickupTime;
    final String address;
    final double? latitude;
    final double? longitude;
    final String status;
    final DateTime createdAt;

    ScheduleModel.fromJson(Map<String, dynamic> json);
    Map<String, dynamic> toJson();
  }
  ```

---

## ⏳ Phase 3: Update Services to Use Models

Replace `dynamic` return types with proper models:

### Before (Current)

```dart
Future<dynamic> getRatingById(int ratingId) async {
  // ...
  return response['data'];
}
```

### After (With Models)

```dart
Future<RatingModel> getRatingById(int ratingId) async {
  // ...
  return RatingModel.fromJson(response['data']);
}

Future<List<RatingModel>> getRatings() async {
  // ...
  final List<dynamic> data = response['data'] ?? [];
  return data.map((json) => RatingModel.fromJson(json)).toList();
}
```

### Files to Update

- [ ] tracking_service_complete.dart
- [ ] rating_service_complete.dart
- [ ] chat_service_complete.dart
- [ ] payment_service_complete.dart
- [ ] balance_service_complete.dart
- [ ] subscription_service_complete.dart
- [ ] feedback_service.dart
- [ ] notification_service_complete.dart
- [ ] order_service_complete.dart
- [ ] schedule_service_complete.dart

---

## ⏳ Phase 4: Integration Testing

### Unit Testing

- [ ] **Test Tracking Service**

  - [ ] Create tracking
  - [ ] Update GPS coordinates
  - [ ] Real-time streaming
  - [ ] Distance calculation

- [ ] **Test Rating Service**

  - [ ] Create rating (verify mitra_id not sent)
  - [ ] Get average rating
  - [ ] Get rating breakdown
  - [ ] Prevent duplicate ratings

- [ ] **Test Chat Service**

  - [ ] Send text message
  - [ ] Send image message
  - [ ] Send location message
  - [ ] Real-time polling
  - [ ] Mark as read

- [ ] **Test Payment Service**

  - [ ] Create payment
  - [ ] Generate QRIS code
  - [ ] Upload proof of payment
  - [ ] Poll payment status
  - [ ] Mark as paid

- [ ] **Test Balance Service**

  - [ ] Top-up via transfer
  - [ ] Top-up via QRIS
  - [ ] Withdraw to bank
  - [ ] Check sufficient balance
  - [ ] Get ledger history

- [ ] **Test Order Service**

  - [ ] Create order
  - [ ] Update order status
  - [ ] Status transition validation
  - [ ] Calculate earnings

- [ ] **Test Notification Service**

  - [ ] Mark single as read
  - [ ] Mark all as read
  - [ ] Get unread count
  - [ ] Delete notification

- [ ] **Test Subscription Service**

  - [ ] Subscribe to plan
  - [ ] Upgrade plan
  - [ ] Cancel subscription
  - [ ] Check active subscription

- [ ] **Test Admin Service**
  - [ ] Get dashboard stats
  - [ ] Generate reports
  - [ ] Broadcast notifications
  - [ ] Get system logs

### Integration Testing with Production API

Test against: **https://gerobaks.dumeg.com/api**

- [ ] Test authentication (login/register)
- [ ] Test all POST endpoints
- [ ] Test all PUT endpoints
- [ ] Test all DELETE endpoints
- [ ] Test real-time features
- [ ] Test error handling (invalid data, network errors)
- [ ] Test pagination
- [ ] Test filtering
- [ ] Test search functionality

---

## ⏳ Phase 5: UI Integration

### Update Screens to Use New Services

- [ ] **Home Screen**

  - [ ] Use OrderService.getActiveOrders()
  - [ ] Use NotificationService.getUnreadCount()
  - [ ] Use BalanceService.getBalance()

- [ ] **Order Tracking Screen**

  - [ ] Use TrackingService.startTracking()
  - [ ] Display real-time GPS on map
  - [ ] Show order status updates

- [ ] **Chat Screen**

  - [ ] Use ChatService.startMessagePolling()
  - [ ] Send messages with ChatService
  - [ ] Display unread count

- [ ] **Payment Screen**

  - [ ] Use PaymentService.generateQRIS()
  - [ ] Upload proof with PaymentService
  - [ ] Poll payment status

- [ ] **Wallet Screen**

  - [ ] Use BalanceService.getBalance()
  - [ ] Top-up with BalanceService.topUp()
  - [ ] Withdraw with BalanceService.withdraw()
  - [ ] Show ledger history

- [ ] **Profile Screen**

  - [ ] Use SubscriptionService.getActiveSubscription()
  - [ ] Show subscription details
  - [ ] Upgrade/cancel subscription

- [ ] **Rating Screen**

  - [ ] Use RatingService.createRating()
  - [ ] Show mitra average rating
  - [ ] Show rating breakdown

- [ ] **Admin Dashboard**
  - [ ] Use AdminService.getDashboardStats()
  - [ ] Display charts and metrics
  - [ ] Broadcast notifications

### Add Loading States

- [ ] Show loading indicator during API calls
- [ ] Add skeleton loaders for lists
- [ ] Add pull-to-refresh functionality

### Add Error Handling

- [ ] Show user-friendly error messages
- [ ] Add retry mechanism for failed requests
- [ ] Handle network timeout errors
- [ ] Handle validation errors

---

## ⏳ Phase 6: Performance Optimization

- [ ] **Implement Caching**

  - [ ] Cache user profile
  - [ ] Cache balance
  - [ ] Cache subscription status
  - [ ] Set cache expiration times

- [ ] **Optimize Real-time Features**

  - [ ] Adjust polling intervals based on battery
  - [ ] Stop polling when app in background
  - [ ] Use WebSockets for chat (if available)

- [ ] **Add Offline Support**

  - [ ] Queue failed requests for retry
  - [ ] Show offline indicator
  - [ ] Cache data for offline viewing

- [ ] **Optimize Image Uploads**
  - [ ] Compress images before upload
  - [ ] Show upload progress
  - [ ] Handle large images (>5MB)

---

## ⏳ Phase 7: Documentation & Deployment

- [ ] **Update README.md**

  - [ ] Add service usage examples
  - [ ] Document all endpoints
  - [ ] Add troubleshooting guide

- [ ] **Create API Documentation**

  - [ ] Document request/response formats
  - [ ] Add error codes reference
  - [ ] Create Postman collection

- [ ] **Deployment Checklist**
  - [ ] Test on Android devices
  - [ ] Test on iOS devices
  - [ ] Check production API stability
  - [ ] Monitor error rates
  - [ ] Set up crash reporting (Sentry/Firebase)

---

## 📊 Progress Tracking

### Overall Progress

| Phase                        | Status      | Progress     |
| ---------------------------- | ----------- | ------------ |
| Phase 1: Service Files       | ✅ Complete | 100% (12/12) |
| Phase 2: Model Creation      | ⏳ Pending  | 0% (0/10)    |
| Phase 3: Update Services     | ⏳ Pending  | 0% (0/10)    |
| Phase 4: Integration Testing | ⏳ Pending  | 0%           |
| Phase 5: UI Integration      | ⏳ Pending  | 0%           |
| Phase 6: Optimization        | ⏳ Pending  | 0%           |
| Phase 7: Documentation       | ⏳ Pending  | 0%           |

**Total Project Progress: 14% (1 of 7 phases complete)**

---

## 🎯 Priority Actions (Do This First!)

### Immediate Next Steps (This Week)

1. **Create RatingModel** (CRITICAL - fixes compile errors)

   - File: `lib/models/rating_model.dart`
   - Fix import errors in `rating_service_complete.dart`

2. **Create TrackingModel**

   - File: `lib/models/tracking_model.dart`
   - Support for GPS coordinates

3. **Create ChatModel**

   - File: `lib/models/chat_model.dart`
   - Support for message types (text/image/location)

4. **Test Basic Flow**

   - Create order → Track → Complete → Rate
   - Verify all services work end-to-end

5. **Update One Screen**
   - Pick the most critical screen (e.g., Order Tracking)
   - Integrate all relevant services
   - Test thoroughly

---

## 💡 Tips & Best Practices

### Model Creation Tips

- Use `nullable` types for optional fields (`String?`, `int?`)
- Add validation in `fromJson` for required fields
- Use `DateTime.parse()` for date strings
- Handle null values gracefully

### Testing Tips

- Start with production API for real data
- Use Postman to verify endpoint responses
- Test error scenarios (invalid data, expired tokens)
- Monitor API response times

### UI Integration Tips

- Use `FutureBuilder` for loading states
- Show error messages in `SnackBar` or `Dialog`
- Add pull-to-refresh with `RefreshIndicator`
- Cache data to reduce API calls

---

**Last Updated**: January 2025  
**Current Phase**: Phase 2 - Model Creation  
**Next Milestone**: Create all 10 model classes  
**Estimated Time**: 2-3 hours for model creation
