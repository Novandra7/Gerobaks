# 📱 GEROBAKS MOBILE APP - API INTEGRATION MASTER PLAN

## 🎯 Tujuan

Memastikan **100% API endpoints** dari backend Laravel terintegrasi dengan sempurna ke aplikasi mobile Flutter.

---

## 📊 STATUS SAAT INI

### Backend API Endpoints (70+ endpoints)

✅ **Production URL:** https://gerobaks.dumeg.com/api
✅ **Status:** 100% ERD Compliant
✅ **Test Coverage:** 16/16 public endpoints tested

### Mobile App Structure

```
lib/
├── services/           # API service layer (50+ files)
├── models/            # Data models
├── providers/         # State management
├── screens/           # UI screens
├── utils/
│   ├── api_routes.dart     # ✅ Sudah ada (tapi perlu update)
│   └── api_helper.dart
└── config/
    └── app_config.dart      # Base URL configuration
```

---

## 🔍 ANALISIS GAP - API vs Mobile

### ✅ Endpoints SUDAH Ada di Mobile (api_routes.dart)

| Kategori            | Endpoints                                                 | Status      |
| ------------------- | --------------------------------------------------------- | ----------- |
| **Authentication**  | register, login, logout, me                               | ✅ Complete |
| **User Management** | updateProfile, changePassword, uploadProfileImage         | ✅ Complete |
| **Dashboard**       | dashboard, dashboardMitra, dashboardUser                  | ✅ Complete |
| **Schedules**       | schedules, schedule(id), scheduleComplete, scheduleCancel | ✅ Complete |
| **Trackings**       | trackings, tracking(id), trackingBySchedule               | ✅ Complete |
| **Orders**          | orders, order(id), orderCancel, orderAssign, orderStatus  | ✅ Complete |
| **Payments**        | payments, payment(id), paymentMarkPaid                    | ✅ Complete |
| **Services**        | services, service(id)                                     | ✅ Complete |
| **Ratings**         | ratings, rating(id)                                       | ✅ Complete |
| **Notifications**   | notifications, notification(id), markRead                 | ✅ Complete |
| **Chats**           | chats, chat(id)                                           | ✅ Complete |
| **Balance**         | balance, topup, withdraw, ledger, summary                 | ✅ Complete |
| **Subscriptions**   | plans, subscribe, current, history                        | ✅ Complete |
| **Feedback**        | feedback                                                  | ✅ Complete |
| **Settings**        | settings, apiConfig                                       | ✅ Complete |
| **Reports**         | reports, report(id)                                       | ✅ Complete |
| **Admin**           | stats, users, logs, export, notifications                 | ✅ Complete |
| **Health**          | ping, health                                              | ✅ Complete |

### ❌ Endpoints BELUM Ada di Mobile (Perlu Ditambahkan)

| No  | Endpoint Backend                | Method | Fungsi                           | Priority     |
| --- | ------------------------------- | ------ | -------------------------------- | ------------ |
| 1   | `/api/users`                    | GET    | List all users (dengan filter)   | HIGH         |
| 2   | `/api/users/{id}`               | GET    | User detail                      | HIGH         |
| 3   | `/api/users/{id}`               | PUT    | Update user                      | HIGH         |
| 4   | `/api/users/{id}`               | DELETE | Delete user                      | MEDIUM       |
| 5   | `/api/schedules/{id}`           | PUT    | Update schedule                  | HIGH         |
| 6   | `/api/schedules/{id}`           | DELETE | Delete schedule                  | MEDIUM       |
| 7   | `/api/orders/{id}`              | PUT    | Update order                     | HIGH         |
| 8   | `/api/orders/{id}`              | DELETE | Delete order                     | LOW          |
| 9   | `/api/trackings`                | POST   | Create tracking (GPS update)     | **CRITICAL** |
| 10  | `/api/trackings/{id}`           | PUT    | Update tracking                  | MEDIUM       |
| 11  | `/api/trackings/{id}`           | DELETE | Delete tracking                  | LOW          |
| 12  | `/api/payments`                 | POST   | Create payment                   | **CRITICAL** |
| 13  | `/api/payments/{id}`            | PUT    | Update payment                   | MEDIUM       |
| 14  | `/api/ratings`                  | POST   | Create rating                    | **CRITICAL** |
| 15  | `/api/ratings/{id}`             | PUT    | Update rating                    | LOW          |
| 16  | `/api/ratings/{id}`             | DELETE | Delete rating                    | LOW          |
| 17  | `/api/notifications`            | POST   | Create notification              | MEDIUM       |
| 18  | `/api/notifications/{id}/read`  | PUT    | Mark single notification as read | HIGH         |
| 19  | `/api/chats`                    | POST   | Send message                     | **CRITICAL** |
| 20  | `/api/chats/{id}`               | PUT    | Update message                   | LOW          |
| 21  | `/api/chats/{id}`               | DELETE | Delete message                   | LOW          |
| 22  | `/api/balance/topup`            | POST   | Top-up balance                   | **CRITICAL** |
| 23  | `/api/balance/withdraw`         | POST   | Withdraw balance                 | **CRITICAL** |
| 24  | `/api/subscription/subscribe`   | POST   | Subscribe to plan                | HIGH         |
| 25  | `/api/subscription/{id}/cancel` | POST   | Cancel subscription              | MEDIUM       |
| 26  | `/api/feedback`                 | POST   | Submit feedback                  | MEDIUM       |
| 27  | `/api/services`                 | POST   | Create service (admin)           | MEDIUM       |
| 28  | `/api/services/{id}`            | PUT    | Update service (admin)           | MEDIUM       |
| 29  | `/api/services/{id}`            | DELETE | Delete service (admin)           | LOW          |

### 🔴 Endpoints CRITICAL yang Harus Segera Ditambahkan

1. **POST /api/trackings** - Real-time GPS tracking
2. **POST /api/ratings** - User rating system
3. **POST /api/payments** - Payment processing
4. **POST /api/chats** - Chat messaging
5. **POST /api/balance/topup** - Balance top-up
6. **POST /api/balance/withdraw** - Balance withdrawal

---

## 📁 STRUKTUR FILE YANG PERLU DIBUAT/UPDATE

### 1. Update api_routes.dart (LENGKAP)

```dart
// ✅ Sudah ada, tapi perlu tambahan method POST/PUT/DELETE
```

### 2. Buat Service Files Baru

```
lib/services/
├── users_service.dart              # ❌ BELUM ADA - Perlu dibuat
├── tracking_service.dart           # ✅ Ada tapi perlu update POST
├── payment_service.dart            # ✅ Ada tapi perlu update POST
├── rating_service.dart             # ⚠️ Ada di payment_rating_service.dart (perlu check)
├── chat_service.dart               # ✅ Ada tapi perlu update POST
├── balance_service.dart            # ✅ Ada tapi perlu update POST/Withdraw
└── admin_service.dart              # ❌ BELUM ADA - Perlu dibuat
```

### 3. Update Existing Services

```
✅ auth_api_service.dart           - Login/Register/Logout
⚠️ schedule_api_service.dart       - Perlu tambah PUT/DELETE
⚠️ tracking_api_service.dart       - Perlu tambah POST
⚠️ order_service_new.dart          - Perlu tambah PUT
⚠️ chat_service.dart               - Perlu tambah POST
⚠️ balance_service.dart            - Perlu tambah POST (topup/withdraw)
⚠️ subscription_service.dart       - Perlu tambah POST (subscribe)
```

---

## 🛠️ IMPLEMENTATION PLAN

### PHASE 1: CRITICAL ENDPOINTS (Hari 1-2)

**Priority:** Real-time features yang sangat dibutuhkan

#### 1.1 Tracking Service - GPS Real-time

```dart
File: lib/services/tracking_service.dart

Features:
✅ GET /api/trackings - List tracking
✅ GET /api/trackings/{id} - Detail tracking
❌ POST /api/trackings - Create/update GPS position [TAMBAHKAN]
❌ PUT /api/trackings/{id} - Update tracking [TAMBAHKAN]

Use Case:
- Mitra mengirim GPS location saat on-duty
- User melihat real-time posisi mitra
- System tracking untuk audit
```

#### 1.2 Rating Service - User Feedback

```dart
File: lib/services/rating_service.dart (atau update payment_rating_service.dart)

Features:
✅ GET /api/ratings - List ratings
❌ POST /api/ratings - Create rating [TAMBAHKAN]
   Input: { order_id, user_id, score, comment }
   Note: mitra_id auto-populate dari order

Use Case:
- User kasih rating setelah order completed
- Mitra lihat rating mereka
- System calculate average rating
```

#### 1.3 Chat Service - Real-time Messaging

```dart
File: lib/services/chat_service.dart

Features:
✅ GET /api/chats - List messages
❌ POST /api/chats - Send message [TAMBAHKAN]
   Input: { receiver_id, message, type }

Use Case:
- User chat dengan mitra
- Mitra chat dengan user
- Support untuk text, image, location
```

#### 1.4 Payment Service - Transaction Processing

```dart
File: lib/services/payment_gateway_service.dart

Features:
✅ GET /api/payments - List payments
❌ POST /api/payments - Create payment [TAMBAHKAN]
   Input: { order_id, method, amount, proof_image }
   Methods: cash, transfer, ewallet, qris

Use Case:
- User bayar order
- Upload bukti transfer
- QRIS payment
```

#### 1.5 Balance Service - Wallet Management

```dart
File: lib/services/balance_service.dart

Features:
✅ GET /api/balance - Get balance
✅ GET /api/balance/ledger - Transaction history
❌ POST /api/balance/topup - Top-up balance [TAMBAHKAN]
❌ POST /api/balance/withdraw - Withdraw balance [TAMBAHKAN]

Use Case:
- User top-up saldo
- Mitra withdraw earnings
- Transaction ledger
```

---

### PHASE 2: HIGH PRIORITY ENDPOINTS (Hari 3-4)

**Priority:** CRUD operations yang sering digunakan

#### 2.1 Users Service (NEW)

```dart
File: lib/services/users_service.dart [BUAT BARU]

Features:
- GET /api/users - List users (dengan filter role)
- GET /api/users/{id} - User detail
- PUT /api/users/{id} - Update user
- DELETE /api/users/{id} - Delete user (admin only)

Use Case:
- Admin manage users
- Mitra list untuk assign order
- User profile management
```

#### 2.2 Schedule Service - Full CRUD

```dart
File: lib/services/schedule_api_service.dart [UPDATE]

Features:
✅ GET /api/schedules - List
✅ POST /api/schedules - Create
❌ PUT /api/schedules/{id} - Update [TAMBAHKAN]
❌ DELETE /api/schedules/{id} - Delete [TAMBAHKAN]

Use Case:
- User edit pickup/dropoff location
- Cancel schedule
- Admin manage schedules
```

#### 2.3 Order Service - Full CRUD

```dart
File: lib/services/order_service_new.dart [UPDATE]

Features:
✅ GET /api/orders - List
✅ POST /api/orders - Create
❌ PUT /api/orders/{id} - Update [TAMBAHKAN]
✅ PUT /api/orders/{id}/status - Update status

Use Case:
- Mitra accept/reject order
- Update order details
- Status management
```

#### 2.4 Notification Service - Mark Read

```dart
File: lib/services/notification_service.dart [UPDATE]

Features:
✅ GET /api/notifications - List
❌ PUT /api/notifications/{id}/read - Mark single as read [TAMBAHKAN]
✅ POST /api/notifications/mark-read - Mark multiple as read

Use Case:
- Mark notification as read satu-persatu
- Clear all notifications
```

---

### PHASE 3: MEDIUM PRIORITY (Hari 5-6)

**Priority:** Features tambahan & admin

#### 3.1 Subscription Service - Full Features

```dart
File: lib/services/subscription_service.dart [UPDATE]

Features:
✅ GET /api/subscription/plans - List plans
✅ GET /api/subscription/current - Current subscription
❌ POST /api/subscription/subscribe - Subscribe [TAMBAHKAN]
❌ POST /api/subscription/{id}/cancel - Cancel [TAMBAHKAN]

Use Case:
- User subscribe to premium
- Cancel subscription
- View history
```

#### 3.2 Feedback Service

```dart
File: lib/services/feedback_service.dart [BUAT BARU atau UPDATE]

Features:
✅ GET /api/feedback - List feedback (admin)
❌ POST /api/feedback - Submit feedback [TAMBAHKAN]

Use Case:
- User submit feedback/complaint
- Admin view feedback
```

#### 3.3 Admin Service (NEW)

```dart
File: lib/services/admin_service.dart [BUAT BARU]

Features:
- GET /api/admin/stats - Dashboard statistics
- GET /api/admin/users - User management
- GET /api/admin/logs - Activity logs
- POST /api/admin/notifications - Broadcast notification

Use Case:
- Admin dashboard
- User management
- System monitoring
```

#### 3.4 Service Management (Admin)

```dart
File: lib/services/service_management_service.dart [UPDATE]

Features:
✅ GET /api/services - List services
❌ POST /api/services - Create service [TAMBAHKAN]
❌ PUT /api/services/{id} - Update service [TAMBAHKAN]
❌ DELETE /api/services/{id} - Delete service [TAMBAHKAN]

Use Case:
- Admin add new service type
- Update pricing
- Disable service
```

---

### PHASE 4: LOW PRIORITY (Hari 7)

**Priority:** Delete operations & cleanup

#### 4.1 Delete Operations

```dart
Tambahkan delete methods untuk:
- DELETE /api/orders/{id}
- DELETE /api/trackings/{id}
- DELETE /api/ratings/{id}
- DELETE /api/chats/{id}
- DELETE /api/users/{id}
```

#### 4.2 Update Operations (Minor)

```dart
Tambahkan update methods untuk:
- PUT /api/trackings/{id}
- PUT /api/payments/{id}
- PUT /api/ratings/{id}
- PUT /api/chats/{id}
```

---

## 📝 CHECKLIST IMPLEMENTASI

### Step-by-Step Implementation Guide

#### ✅ STEP 1: Update api_routes.dart

- [ ] Tambahkan route untuk POST operations
- [ ] Tambahkan route untuk PUT operations
- [ ] Tambahkan route untuk DELETE operations
- [ ] Tambahkan query parameter helpers

#### ✅ STEP 2: Update api_client.dart

- [ ] Verify POST method working
- [ ] Verify PUT method working
- [ ] Verify DELETE method working
- [ ] Add multipart/form-data support (untuk upload image)
- [ ] Add error handling improvements

#### ✅ STEP 3: Create/Update Service Files

- [ ] tracking_service.dart - Add POST method
- [ ] rating_service.dart - Add POST method
- [ ] chat_service.dart - Add POST method
- [ ] payment_service.dart - Add POST method
- [ ] balance_service.dart - Add POST topup/withdraw
- [ ] users_service.dart - Create new file
- [ ] admin_service.dart - Create new file
- [ ] subscription_service.dart - Add POST subscribe
- [ ] schedule_api_service.dart - Add PUT/DELETE
- [ ] order_service_new.dart - Add PUT

#### ✅ STEP 4: Create Models

- [ ] Verify all models match backend response
- [ ] Add toJson() methods untuk POST/PUT
- [ ] Add fromJson() methods untuk GET
- [ ] Ensure nullable fields handled correctly

#### ✅ STEP 5: Update Providers/Blocs

- [ ] Update state management untuk new endpoints
- [ ] Add loading states
- [ ] Add error handling
- [ ] Add success callbacks

#### ✅ STEP 6: Update UI Screens

- [ ] Connect screens dengan new services
- [ ] Add form validation
- [ ] Add loading indicators
- [ ] Add error messages
- [ ] Add success feedback

#### ✅ STEP 7: Testing

- [ ] Test all CRITICAL endpoints
- [ ] Test all HIGH priority endpoints
- [ ] Test all MEDIUM priority endpoints
- [ ] Test error scenarios
- [ ] Test offline handling

---

## 🎯 EXPECTED RESULTS

Setelah implementasi selesai:

1. ✅ **100% API Coverage** - Semua 70+ endpoints terintegrasi
2. ✅ **Real-time Features** - GPS tracking, chat, notifications working
3. ✅ **Payment System** - All payment methods functional
4. ✅ **Rating System** - User can rate mitras (mitra_id auto-populated)
5. ✅ **Balance Management** - Topup & withdraw working
6. ✅ **Admin Panel** - Full admin features accessible
7. ✅ **Error Handling** - Proper error messages & retry logic
8. ✅ **Offline Support** - Queue actions when offline

---

## 📊 PROGRESS TRACKING

| Phase       | Tasks                        | Status         | Progress |
| ----------- | ---------------------------- | -------------- | -------- |
| **Phase 1** | Critical Endpoints (6 tasks) | 🔴 Not Started | 0%       |
| **Phase 2** | High Priority (4 tasks)      | 🔴 Not Started | 0%       |
| **Phase 3** | Medium Priority (4 tasks)    | 🔴 Not Started | 0%       |
| **Phase 4** | Low Priority (2 tasks)       | 🔴 Not Started | 0%       |
| **Testing** | End-to-end testing           | 🔴 Not Started | 0%       |

**Overall Progress: 0%**

---

## 🚀 NEXT ACTIONS

### Immediate (Now)

1. Review this document dengan user
2. Confirm priorities
3. Start Phase 1 implementation

### Short-term (Hari 1-2)

1. Implement tracking POST (GPS updates)
2. Implement rating POST
3. Implement chat POST
4. Implement payment POST
5. Implement balance topup/withdraw

### Medium-term (Hari 3-7)

1. Complete all HIGH priority endpoints
2. Complete all MEDIUM priority endpoints
3. Add comprehensive testing
4. Deploy & monitor

---

**Document Created:** October 2025  
**Status:** 🔴 Ready for Implementation  
**Owner:** Gerobaks Development Team
