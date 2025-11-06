# 🚀 IMPLEMENTASI API INTEGRATION - STEP BY STEP

## 📋 Summary

Dokumen ini berisi langkah-langkah detail untuk mengintegrasikan seluruh API endpoint ke mobile app.

---

## ✅ YANG SUDAH ADA & WORKING

### 1. api_client.dart - HTTP Client

```dart
✅ GET request
✅ POST request (postJson)
✅ PUT request (putJson)
✅ PATCH request (patchJson)
✅ DELETE request
✅ Token management (saveToken, clearToken, hasToken, getToken)
✅ Error handling (HttpException)
✅ Timeout handling (15 seconds)
✅ JSON parsing dengan error recovery
```

### 2. api_routes.dart - Route Definitions

```dart
✅ Authentication routes
✅ User management routes
✅ Dashboard routes
✅ Mitra routes
✅ Schedule routes
✅ Tracking routes
✅ Order routes
✅ Payment routes
✅ Service routes
✅ Rating routes
✅ Notification routes
✅ Chat routes
✅ Balance routes
✅ Subscription routes
✅ Feedback routes
✅ Settings routes
✅ Report routes
✅ Admin routes
✅ Health check routes
```

**CATATAN:** Routes sudah lengkap, tapi perlu ditambahkan beberapa helper methods untuk POST/PUT operations.

---

## 🎯 PHASE 1: CRITICAL ENDPOINTS (IMPLEMENTASI SEGERA)

### 1.1 📍 Tracking Service - Real-time GPS

**File:** `lib/services/tracking_service_complete.dart` (BARU)

**Features yang perlu ditambahkan:**

```dart
// ✅ Sudah ada di tracking_api_service.dart:
- Future<List<Tracking>> getTrackings({...}) - GET /api/trackings
- Future<Tracking> getTrackingById(int id) - GET /api/trackings/{id}

// ❌ BELUM ADA - Perlu ditambahkan:
- Future<Tracking> createTracking({...}) - POST /api/trackings
- Future<Tracking> updateTracking(int id, {...}) - PUT /api/trackings/{id}
- Future<void> deleteTracking(int id) - DELETE /api/trackings/{id}
- Future<void> startTracking(int orderId) - Start GPS tracking session
- Future<void> stopTracking(int orderId) - Stop GPS tracking session
- Stream<Position> watchPosition() - Real-time GPS stream
```

**Implementation:**

```dart
// POST /api/trackings
Future<Tracking> createTracking({
  required int orderId,
  required int mitraId,
  required double latitude,
  required double longitude,
  double? speed,
  double? heading,
  double? accuracy,
}) async {
  final body = {
    'order_id': orderId,
    'mitra_id': mitraId,
    'latitude': latitude,
    'longitude': longitude,
    if (speed != null) 'speed': speed,
    if (heading != null) 'heading': heading,
    if (accuracy != null) 'accuracy': accuracy,
  };

  final response = await _apiClient.postJson('/api/trackings', body);
  return Tracking.fromJson(response['data']);
}
```

**Use Case:**

1. Mitra start order → Start GPS tracking
2. Setiap 5-10 detik → Send GPS position ke server
3. User open tracking screen → See real-time mitra location
4. Order completed → Stop GPS tracking

---

### 1.2 ⭐ Rating Service - User Feedback

**File:** `lib/services/rating_service_complete.dart` (BARU)

**Features yang perlu ditambahkan:**

```dart
// ✅ Kemungkinan sudah ada di payment_rating_service.dart (perlu check):
- Future<List<Rating>> getRatings({...}) - GET /api/ratings
- Future<Rating> getRatingById(int id) - GET /api/ratings/{id}

// ❌ BELUM ADA - Perlu ditambahkan:
- Future<Rating> createRating({...}) - POST /api/ratings
- Future<Rating> updateRating(int id, {...}) - PUT /api/ratings/{id}
- Future<void> deleteRating(int id) - DELETE /api/ratings/{id}
- Future<double> getMitraAverageRating(int mitraId) - Calculate average
- Future<Map<int, int>> getRatingBreakdown(int mitraId) - Rating distribution
```

**Implementation:**

```dart
// POST /api/ratings
Future<Rating> createRating({
  required int orderId,
  required int userId,
  required int score, // 1-5
  String? comment,
}) async {
  final body = {
    'order_id': orderId,
    'user_id': userId,
    'score': score,
    if (comment != null && comment.isNotEmpty) 'comment': comment,
  };

  final response = await _apiClient.postJson('/api/ratings', body);
  return Rating.fromJson(response['data']);
}
```

**PENTING:**

- `mitra_id` **TIDAK perlu** diinput, karena backend otomatis ambil dari `order.mitra_id`
- Backend sudah validasi: order harus completed, user harus owner, prevent duplicate rating

**Use Case:**

1. Order completed → Show rating dialog
2. User kasih rating 1-5 stars + comment
3. Submit → POST /api/ratings
4. Success → Update UI, show thank you message

---

### 1.3 💬 Chat Service - Real-time Messaging

**File:** `lib/services/chat_service_complete.dart` (UPDATE existing)

**Features yang perlu ditambahkan:**

```dart
// ✅ Kemungkinan sudah ada di chat_service.dart:
- Future<List<Chat>> getChats({...}) - GET /api/chats
- Future<Chat> getChatById(int id) - GET /api/chats/{id}

// ❌ BELUM ADA - Perlu ditambahkan:
- Future<Chat> sendMessage({...}) - POST /api/chats
- Future<Chat> updateMessage(int id, {...}) - PUT /api/chats/{id}
- Future<void> deleteMessage(int id) - DELETE /api/chats/{id}
- Stream<List<Chat>> watchMessages(int userId) - Real-time message stream
- Future<void> markAsRead(int chatId) - Mark message as read
```

**Implementation:**

```dart
// POST /api/chats
Future<Chat> sendMessage({
  required int receiverId,
  required String message,
  String type = 'text', // text, image, location
  String? metadata, // JSON string untuk additional data
}) async {
  final body = {
    'receiver_id': receiverId,
    'message': message,
    'type': type,
    if (metadata != null) 'metadata': metadata,
  };

  final response = await _apiClient.postJson('/api/chats', body);
  return Chat.fromJson(response['data']);
}
```

**Use Case:**

1. User open chat dengan mitra → Load chat history
2. User ketik & send → POST /api/chats
3. Real-time listener → Receive new messages
4. Support text, image (base64), location (lat/lng)

---

### 1.4 💳 Payment Service - Transaction Processing

**File:** `lib/services/payment_service_complete.dart` (UPDATE existing)

**Features yang perlu ditambahkan:**

```dart
// ✅ Kemungkinan sudah ada di payment_gateway_service.dart:
- Future<List<Payment>> getPayments({...}) - GET /api/payments
- Future<Payment> getPaymentById(int id) - GET /api/payments/{id}

// ❌ BELUM ADA - Perlu ditambahkan:
- Future<Payment> createPayment({...}) - POST /api/payments
- Future<Payment> updatePayment(int id, {...}) - PUT /api/payments/{id}
- Future<Payment> markAsPaid(int id) - PUT /api/payments/{id}/mark-paid
- Future<String> generateQRIS(int orderId) - Generate QRIS code
- Future<PaymentStatus> checkPaymentStatus(int paymentId) - Check status
```

**Implementation:**

```dart
// POST /api/payments
Future<Payment> createPayment({
  required int orderId,
  required String method, // cash, transfer, ewallet, qris
  required double amount,
  String? proofImage, // Base64 untuk bukti transfer
  String? transactionId, // Untuk ewallet/qris
}) async {
  final body = {
    'order_id': orderId,
    'method': method,
    'amount': amount,
    if (proofImage != null) 'proof_image': proofImage,
    if (transactionId != null) 'transaction_id': transactionId,
  };

  final response = await _apiClient.postJson('/api/payments', body);
  return Payment.fromJson(response['data']);
}
```

**Payment Methods:**

1. **cash** - Bayar tunai, mark as paid when delivered
2. **transfer** - Upload bukti transfer (image)
3. **ewallet** - Integration dengan OVO/GoPay/Dana
4. **qris** - Generate QR code, scan & pay

---

### 1.5 💰 Balance Service - Wallet Management

**File:** `lib/services/balance_service_complete.dart` (UPDATE existing)

**Features yang perlu ditambahkan:**

```dart
// ✅ Sudah ada di balance_service.dart:
- Future<Balance> getBalance() - GET /api/balance
- Future<List<BalanceLedger>> getLedger({...}) - GET /api/balance/ledger
- Future<BalanceSummary> getSummary() - GET /api/balance/summary

// ❌ BELUM ADA - Perlu ditambahkan:
- Future<BalanceLedger> topUp({...}) - POST /api/balance/topup
- Future<BalanceLedger> withdraw({...}) - POST /api/balance/withdraw
- Future<bool> checkSufficientBalance(double amount) - Validate balance
- Future<List<PaymentMethod>> getTopUpMethods() - Available top-up methods
```

**Implementation:**

```dart
// POST /api/balance/topup
Future<BalanceLedger> topUp({
  required double amount,
  required String method, // transfer, va, qris
  String? proofImage,
}) async {
  final body = {
    'amount': amount,
    'method': method,
    if (proofImage != null) 'proof_image': proofImage,
  };

  final response = await _apiClient.postJson('/api/balance/topup', body);
  return BalanceLedger.fromJson(response['data']);
}

// POST /api/balance/withdraw
Future<BalanceLedger> withdraw({
  required double amount,
  required String bankAccount,
  required String bankName,
  required String accountHolder,
}) async {
  final body = {
    'amount': amount,
    'bank_account': bankAccount,
    'bank_name': bankName,
    'account_holder': accountHolder,
  };

  final response = await _apiClient.postJson('/api/balance/withdraw', body);
  return BalanceLedger.fromJson(response['data']);
}
```

**Use Case:**

1. **User Top-Up:**

   - User pilih nominal top-up
   - Pilih metode (transfer/VA/QRIS)
   - Upload bukti bayar
   - Admin approve → Balance bertambah

2. **Mitra Withdraw:**
   - Mitra lihat earnings
   - Request withdraw ke bank account
   - Admin process → Balance berkurang
   - Transfer masuk ke rekening

---

## 🎯 PHASE 2: HIGH PRIORITY ENDPOINTS

### 2.1 👥 Users Service (NEW)

**File:** `lib/services/users_service.dart` (BUAT BARU)

```dart
class UsersService {
  final ApiClient _apiClient = ApiClient();

  // GET /api/users
  Future<List<User>> getUsers({
    String? role, // end_user, mitra, admin
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = {
      if (role != null) 'role': role,
      if (search != null) 'search': search,
      'page': page,
      'per_page': perPage,
    };

    final response = await _apiClient.getJson('/api/users', query: query);
    final List<dynamic> data = response['data'];
    return data.map((json) => User.fromJson(json)).toList();
  }

  // GET /api/users/{id}
  Future<User> getUserById(int id) async {
    final response = await _apiClient.get('/api/users/$id');
    return User.fromJson(response['data']);
  }

  // PUT /api/users/{id}
  Future<User> updateUser(int id, {
    String? name,
    String? email,
    String? phone,
    String? role,
    double? latitude,
    double? longitude,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await _apiClient.putJson('/api/users/$id', body);
    return User.fromJson(response['data']);
  }

  // DELETE /api/users/{id}
  Future<void> deleteUser(int id) async {
    await _apiClient.delete('/api/users/$id');
  }
}
```

**Use Case:**

- Admin manage users (list, view, edit, delete)
- Get list of mitras untuk assign order
- Search users by name/email/phone
- Filter users by role

---

### 2.2 📅 Schedule Service - Full CRUD

**File:** Update `lib/services/schedule_api_service.dart`

**Tambahkan methods:**

```dart
// PUT /api/schedules/{id}
Future<Schedule> updateSchedule(int id, {
  double? pickupLat,
  double? pickupLng,
  double? dropoffLat,
  double? dropoffLng,
  String? pickupAddress,
  String? dropoffAddress,
  DateTime? scheduledAt,
  String? notes,
}) async {
  final body = {
    if (pickupLat != null) 'pickup_lat': pickupLat,
    if (pickupLng != null) 'pickup_lng': pickupLng,
    if (dropoffLat != null) 'dropoff_lat': dropoffLat,
    if (dropoffLng != null) 'dropoff_lng': dropoffLng,
    if (pickupAddress != null) 'pickup_address': pickupAddress,
    if (dropoffAddress != null) 'dropoff_address': dropoffAddress,
    if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
    if (notes != null) 'notes': notes,
  };

  final response = await _apiClient.putJson('/api/schedules/$id', body);
  return Schedule.fromJson(response['data']);
}

// DELETE /api/schedules/{id}
Future<void> deleteSchedule(int id) async {
  await _apiClient.delete('/api/schedules/$id');
}
```

---

### 2.3 📦 Order Service - Full CRUD

**File:** Update `lib/services/order_service_new.dart`

**Tambahkan methods:**

```dart
// PUT /api/orders/{id}
Future<Order> updateOrder(int id, {
  int? serviceId,
  int? scheduleId,
  int? mitraId,
  String? notes,
  double? totalPrice,
}) async {
  final body = {
    if (serviceId != null) 'service_id': serviceId,
    if (scheduleId != null) 'schedule_id': scheduleId,
    if (mitraId != null) 'mitra_id': mitraId,
    if (notes != null) 'notes': notes,
    if (totalPrice != null) 'total_price': totalPrice,
  };

  final response = await _apiClient.putJson('/api/orders/$id', body);
  return Order.fromJson(response['data']);
}
```

---

### 2.4 🔔 Notification Service - Mark Single as Read

**File:** Update `lib/services/notification_service.dart`

**Tambahkan method:**

```dart
// PUT /api/notifications/{id}/read
Future<Notification> markAsRead(int id) async {
  final response = await _apiClient.putJson('/api/notifications/$id/read', {});
  return Notification.fromJson(response['data']);
}
```

---

## 🎯 PHASE 3: MEDIUM PRIORITY

### 3.1 🎁 Subscription Service - Subscribe & Cancel

**File:** Update `lib/services/subscription_service.dart`

```dart
// POST /api/subscription/subscribe
Future<Subscription> subscribe({
  required int planId,
  required String paymentMethod,
}) async {
  final body = {
    'plan_id': planId,
    'payment_method': paymentMethod,
  };

  final response = await _apiClient.postJson('/api/subscription/subscribe', body);
  return Subscription.fromJson(response['data']);
}

// POST /api/subscription/{id}/cancel
Future<void> cancelSubscription(int subscriptionId) async {
  await _apiClient.postJson('/api/subscription/$subscriptionId/cancel', {});
}
```

---

### 3.2 📝 Feedback Service

**File:** `lib/services/feedback_service.dart` (BUAT BARU)

```dart
// POST /api/feedback
Future<Feedback> submitFeedback({
  required String subject,
  required String message,
  String? category, // complaint, suggestion, praise
}) async {
  final body = {
    'subject': subject,
    'message': message,
    if (category != null) 'category': category,
  };

  final response = await _apiClient.postJson('/api/feedback', body);
  return Feedback.fromJson(response['data']);
}
```

---

### 3.3 👨‍💼 Admin Service

**File:** `lib/services/admin_service.dart` (BUAT BARU)

```dart
// GET /api/admin/stats
Future<AdminStats> getStats() async {
  final response = await _apiClient.get('/api/admin/stats');
  return AdminStats.fromJson(response['data']);
}

// POST /api/admin/notifications
Future<void> broadcastNotification({
  required String title,
  required String message,
  String? targetRole, // end_user, mitra, admin, or null for all
}) async {
  final body = {
    'title': title,
    'message': message,
    if (targetRole != null) 'target_role': targetRole,
  };

  await _apiClient.postJson('/api/admin/notifications', body);
}
```

---

## 📝 CHECKLIST IMPLEMENTASI

### ✅ Phase 1 - Critical (Prioritas Tertinggi)

- [ ] Create `tracking_service_complete.dart`
  - [ ] Add `createTracking()` method
  - [ ] Add `updateTracking()` method
  - [ ] Add `startTracking()` & `stopTracking()` helpers
  - [ ] Add GPS stream listener
- [ ] Create `rating_service_complete.dart`
  - [ ] Add `createRating()` method
  - [ ] Add `getMitraAverageRating()` helper
  - [ ] Add validation helpers
- [ ] Update `chat_service.dart`
  - [ ] Add `sendMessage()` method
  - [ ] Add `markAsRead()` method
  - [ ] Add real-time listener
- [ ] Update `payment_gateway_service.dart`
  - [ ] Add `createPayment()` method
  - [ ] Add `generateQRIS()` method
  - [ ] Add `checkPaymentStatus()` method
- [ ] Update `balance_service.dart`
  - [ ] Add `topUp()` method
  - [ ] Add `withdraw()` method
  - [ ] Add validation helpers

### ✅ Phase 2 - High Priority

- [ ] Create `users_service.dart`
  - [ ] Add `getUsers()` with filters
  - [ ] Add `getUserById()`
  - [ ] Add `updateUser()`
  - [ ] Add `deleteUser()`
- [ ] Update `schedule_api_service.dart`
  - [ ] Add `updateSchedule()`
  - [ ] Add `deleteSchedule()`
- [ ] Update `order_service_new.dart`
  - [ ] Add `updateOrder()`
- [ ] Update `notification_service.dart`
  - [ ] Add `markAsRead()` for single notification

### ✅ Phase 3 - Medium Priority

- [ ] Update `subscription_service.dart`
  - [ ] Add `subscribe()`
  - [ ] Add `cancelSubscription()`
- [ ] Create `feedback_service.dart`
  - [ ] Add `submitFeedback()`
  - [ ] Add `getFeedbacks()` (admin only)
- [ ] Create `admin_service.dart`
  - [ ] Add `getStats()`
  - [ ] Add `broadcastNotification()`
  - [ ] Add `getActivityLogs()`

### ✅ Testing

- [ ] Test all POST endpoints
- [ ] Test all PUT endpoints
- [ ] Test all DELETE endpoints
- [ ] Test error handling
- [ ] Test offline scenarios
- [ ] Test with real backend (gerobaks.dumeg.com)

---

## 🚀 MULAI IMPLEMENTASI

Saya siap mulai implementasi. Konfirmasi:

1. ✅ Mau saya mulai dari **Phase 1 - Critical Endpoints**?
2. ✅ Atau ada endpoint spesifik yang prioritas lebih tinggi?
3. ✅ Apakah perlu saya buat semua file sekaligus atau satu-persatu?

Saya rekomendasikan mulai dengan:

1. **Tracking Service** (GPS real-time) - Paling penting untuk tracking mitra
2. **Rating Service** - User experience improvement
3. **Payment Service** - Core business functionality

Mari kita mulai! 🚀
