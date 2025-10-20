# 🗺️ API ENDPOINT MAPPING - BACKEND vs MOBILE SERVICES

## Complete Endpoint Path Corrections Required

**Source:** `backend/API_ENDPOINTS_COMPLETE.md`  
**Date:** October 15, 2025  
**Status:** ❌ Multiple mismatches found - REQUIRES FIXING

---

## 🔴 CRITICAL FIXES REQUIRED

### 1. **Tracking Service** - tracking_service_complete.dart

| Method | Mobile Service (WRONG) | Backend API (CORRECT)         | Status          | Auth   |
| ------ | ---------------------- | ----------------------------- | --------------- | ------ |
| GET    | `/api/trackings`       | `/api/tracking`               | ❌ FIX REQUIRED | Public |
| GET    | `/api/trackings/{id}`  | `/api/tracking/schedule/{id}` | ❌ FIX REQUIRED | Public |
| POST   | `/api/trackings`       | `/api/tracking`               | ❌ FIX REQUIRED | mitra  |
| PUT    | `/api/trackings/{id}`  | ❌ NOT EXISTS                 | ❌ REMOVE       | N/A    |
| DELETE | `/api/trackings/{id}`  | ❌ NOT EXISTS                 | ❌ REMOVE       | N/A    |

**Correct Endpoints:**

- ✅ `GET /api/tracking` - List all tracking (public)
- ✅ `GET /api/tracking?schedule_id={id}` - Filter by schedule
- ✅ `GET /api/tracking/schedule/{id}` - Tracking by schedule
- ✅ `POST /api/tracking` - Create tracking (mitra only)

---

### 2. **Balance Service** - balance_service_complete.dart

| Method | Mobile Service          | Backend API             | Status     | Auth     |
| ------ | ----------------------- | ----------------------- | ---------- | -------- |
| GET    | `/api/balance`          | ❌ NOT EXISTS           | ❌ WRONG   | N/A      |
| GET    | `/api/balance/ledger`   | `/api/balance/ledger`   | ✅ CORRECT | Required |
| GET    | `/api/balance/summary`  | `/api/balance/summary`  | ✅ CORRECT | Required |
| POST   | `/api/balance/topup`    | `/api/balance/topup`    | ✅ CORRECT | Required |
| POST   | `/api/balance/withdraw` | `/api/balance/withdraw` | ✅ CORRECT | Required |

**Fix Required:**

- ❌ REMOVE `GET /api/balance` (doesn't exist)
- ✅ Use `GET /api/balance/summary` instead for balance info

---

### 3. **Users Service** - users_service.dart

| Method | Mobile Service (WRONG) | Backend API (CORRECT)   | Status                    | Auth  |
| ------ | ---------------------- | ----------------------- | ------------------------- | ----- |
| GET    | `/api/users`           | `/api/admin/users`      | ❌ FIX REQUIRED           | admin |
| GET    | `/api/users/{id}`      | `/api/admin/users/{id}` | ❌ FIX REQUIRED (assumed) | admin |
| POST   | `/api/users`           | `/api/admin/users`      | ❌ FIX REQUIRED           | admin |
| PUT    | `/api/users/{id}`      | `/api/admin/users/{id}` | ❌ FIX REQUIRED (assumed) | admin |
| DELETE | `/api/users/{id}`      | `/api/admin/users/{id}` | ❌ FIX REQUIRED (assumed) | admin |

**Correct Endpoints:**

- ✅ `GET /api/admin/users` - List users (admin only)
- ✅ `POST /api/admin/users` - Create user (admin only)
- ✅ `PATCH /api/admin/users/{id}` - Update user (admin only)
- ✅ `DELETE /api/admin/users/{id}` - Delete user (admin only) [assumed]

---

### 4. **Subscription Service** - subscription_service_complete.dart

| Method | Mobile Service (WRONG)    | Backend API (CORRECT)             | Status          | Auth     |
| ------ | ------------------------- | --------------------------------- | --------------- | -------- |
| GET    | `/api/subscriptions`      | `/api/subscription/plans`         | ❌ FIX REQUIRED | Required |
| GET    | `/api/subscriptions/{id}` | `/api/subscription/plans/{id}`    | ❌ FIX REQUIRED | Required |
| GET    | -                         | `/api/subscription/current`       | ➕ ADD          | Required |
| GET    | -                         | `/api/subscription/history`       | ➕ ADD          | Required |
| POST   | `/api/subscriptions`      | `/api/subscription/subscribe`     | ❌ FIX REQUIRED | Required |
| POST   | -                         | `/api/subscription/{id}/activate` | ➕ ADD          | Required |
| POST   | -                         | `/api/subscription/{id}/cancel`   | ➕ ADD          | Required |
| PUT    | `/api/subscriptions/{id}` | ❌ NOT EXISTS                     | ❌ REMOVE       | N/A      |
| DELETE | `/api/subscriptions/{id}` | Use `/subscription/{id}/cancel`   | ❌ CHANGE       | Required |

**Correct Endpoints:**

- ✅ `GET /api/subscription/plans` - List plans
- ✅ `GET /api/subscription/plans/{id}` - Plan details
- ✅ `GET /api/subscription/current` - Current subscription
- ✅ `GET /api/subscription/history` - History
- ✅ `POST /api/subscription/subscribe` - Subscribe
- ✅ `POST /api/subscription/{id}/activate` - Activate
- ✅ `POST /api/subscription/{id}/cancel` - Cancel

---

### 5. **Notification Service** - notification_service_complete.dart

| Method | Mobile Service                      | Backend API          | Status     | Auth     |
| ------ | ----------------------------------- | -------------------- | ---------- | -------- |
| GET    | `/api/notifications`                | `/api/notifications` | ✅ CORRECT | Required |
| POST   | `/api/notifications`                | `/api/notifications` | ✅ CORRECT | admin    |
| PUT    | `/api/notifications/{id}/mark-read` | ❌ WRONG PATH        | ❌ FIX     | Required |
| PUT    | `/api/notifications/mark-all-read`  | ❌ WRONG PATH        | ❌ FIX     | Required |
| DELETE | `/api/notifications/{id}`           | ❌ NOT EXISTS        | ❌ REMOVE  | N/A      |

**Correct Endpoints:**

- ✅ `GET /api/notifications` - List notifications
- ✅ `POST /api/notifications` - Create (admin only)
- ✅ `POST /api/notifications/mark-read` - Mark as read (with body: {notification_ids: [1,2,3]})
- ❌ REMOVE individual mark-read endpoint
- ❌ REMOVE delete endpoint

**Fix Required:**

- Change `PUT /notifications/{id}/mark-read` to `POST /notifications/mark-read` with IDs array
- Change `PUT /notifications/mark-all-read` to `POST /notifications/mark-read` with all IDs

---

### 6. **Chat Service** - chat_service_complete.dart

| Method | Mobile Service    | Backend API   | Status     | Auth     |
| ------ | ----------------- | ------------- | ---------- | -------- |
| GET    | `/api/chats`      | `/api/chats`  | ✅ CORRECT | Required |
| POST   | `/api/chats`      | `/api/chats`  | ✅ CORRECT | Required |
| PUT    | `/api/chats/{id}` | ❌ NOT EXISTS | ❌ REMOVE  | N/A      |
| DELETE | `/api/chats/{id}` | ❌ NOT EXISTS | ❌ REMOVE  | N/A      |

**Correct Endpoints:**

- ✅ `GET /api/chats` - List chats
- ✅ `POST /api/chats` - Send message
- ❌ REMOVE update endpoint
- ❌ REMOVE delete endpoint

---

### 7. **Payment Service** - payment_service_complete.dart

| Method | Mobile Service                 | Backend API                           | Status     | Auth     |
| ------ | ------------------------------ | ------------------------------------- | ---------- | -------- |
| GET    | `/api/payments`                | `/api/payments`                       | ✅ CORRECT | Required |
| POST   | `/api/payments`                | `/api/payments`                       | ✅ CORRECT | Required |
| PUT    | `/api/payments/{id}`           | `/api/payments/{id}` (PATCH)          | ⚠️ METHOD  | Required |
| PUT    | `/api/payments/{id}/mark-paid` | `/api/payments/{id}/mark-paid` (POST) | ⚠️ METHOD  | Required |
| DELETE | `/api/payments/{id}`           | ❌ NOT EXISTS                         | ❌ REMOVE  | N/A      |

**Correct Endpoints:**

- ✅ `GET /api/payments` - List payments
- ✅ `POST /api/payments` - Create payment
- ✅ `PATCH /api/payments/{id}` - Update payment (change PUT to PATCH)
- ✅ `POST /api/payments/{id}/mark-paid` - Mark paid (change PUT to POST)

---

### 8. **Order Service** - order_service_complete.dart

| Method | Mobile Service     | Backend API               | Status     | Auth        |
| ------ | ------------------ | ------------------------- | ---------- | ----------- |
| GET    | `/api/orders`      | `/api/orders`             | ✅ CORRECT | Required    |
| GET    | `/api/orders/{id}` | `/api/orders/{id}`        | ✅ CORRECT | Required    |
| POST   | `/api/orders`      | `/api/orders`             | ✅ CORRECT | end_user    |
| POST   | -                  | `/api/orders/{id}/cancel` | ➕ ADD     | end_user    |
| PATCH  | -                  | `/api/orders/{id}/assign` | ➕ ADD     | mitra       |
| PATCH  | -                  | `/api/orders/{id}/status` | ➕ ADD     | mitra/admin |
| PUT    | `/api/orders/{id}` | ❌ NOT EXISTS             | ❌ REMOVE  | N/A         |
| DELETE | `/api/orders/{id}` | ❌ NOT EXISTS             | ❌ REMOVE  | N/A         |

**Correct Endpoints:**

- ✅ `GET /api/orders` - List orders
- ✅ `GET /api/orders/{id}` - Get by ID
- ✅ `POST /api/orders` - Create order (end_user)
- ✅ `POST /api/orders/{id}/cancel` - Cancel order (end_user)
- ✅ `PATCH /api/orders/{id}/assign` - Assign to mitra
- ✅ `PATCH /api/orders/{id}/status` - Update status

---

### 9. **Schedule Service** - schedule_service_complete.dart

| Method | Mobile Service        | Backend API                    | Status     | Auth     |
| ------ | --------------------- | ------------------------------ | ---------- | -------- |
| GET    | `/api/schedules`      | `/api/schedules`               | ✅ CORRECT | Required |
| GET    | `/api/schedules/{id}` | `/api/schedules/{id}`          | ✅ CORRECT | Required |
| POST   | `/api/schedules`      | `/api/schedules`               | ✅ CORRECT | end_user |
| PUT    | `/api/schedules/{id}` | `/api/schedules/{id}` (PATCH?) | ⚠️ VERIFY  | Required |
| DELETE | `/api/schedules/{id}` | `/api/schedules/{id}`          | ⚠️ VERIFY  | Required |

**Status:** ✅ MOSTLY CORRECT (verify PATCH vs PUT)

---

### 10. **Rating Service** - rating_service_complete.dart

| Method | Mobile Service      | Backend API    | Status     | Auth     |
| ------ | ------------------- | -------------- | ---------- | -------- |
| GET    | `/api/ratings`      | `/api/ratings` | ✅ CORRECT | Public   |
| POST   | `/api/ratings`      | `/api/ratings` | ✅ CORRECT | end_user |
| PUT    | `/api/ratings/{id}` | ❌ NOT EXISTS  | ❌ REMOVE  | N/A      |
| DELETE | `/api/ratings/{id}` | ❌ NOT EXISTS  | ❌ REMOVE  | N/A      |

**Correct Endpoints:**

- ✅ `GET /api/ratings` - List ratings (public)
- ✅ `POST /api/ratings` - Create rating (end_user)

---

### 11. **Feedback Service** - feedback_service.dart

| Method | Mobile Service       | Backend API     | Status     | Auth     |
| ------ | -------------------- | --------------- | ---------- | -------- |
| GET    | `/api/feedback`      | `/api/feedback` | ✅ CORRECT | Required |
| POST   | `/api/feedback`      | `/api/feedback` | ✅ CORRECT | Required |
| PUT    | `/api/feedback/{id}` | ❌ NOT EXISTS   | ❌ REMOVE  | N/A      |
| DELETE | `/api/feedback/{id}` | ❌ NOT EXISTS   | ❌ REMOVE  | N/A      |

**Correct Endpoints:**

- ✅ `GET /api/feedback` - List feedback
- ✅ `POST /api/feedback` - Submit feedback

---

### 12. **Admin Service** - admin_service.dart

| Method | Mobile Service     | Backend API             | Status     | Auth     |
| ------ | ------------------ | ----------------------- | ---------- | -------- |
| GET    | `/api/admin/stats` | `/api/admin/stats`      | ✅ CORRECT | admin    |
| GET    | `/api/admin/users` | `/api/admin/users`      | ✅ CORRECT | admin    |
| POST   | -                  | `/api/admin/users`      | ➕ ADD     | admin    |
| PATCH  | -                  | `/api/admin/users/{id}` | ➕ ADD     | admin    |
| GET    | `/api/reports`     | `/api/reports`          | ✅ CORRECT | Required |
| POST   | `/api/reports`     | `/api/reports`          | ✅ CORRECT | Required |

**Status:** ✅ MOSTLY CORRECT (add user management)

---

## 📊 SUMMARY OF FIXES NEEDED

### Critical (Must Fix Immediately)

1. **Tracking Service** ❌

   - Change ALL `/trackings` to `/tracking` (singular)
   - Remove PUT and DELETE endpoints
   - Update `getById()` to use `/tracking/schedule/{id}`

2. **Balance Service** ❌

   - Remove `/api/balance` endpoint
   - Use `/api/balance/summary` for balance info

3. **Users Service** ❌

   - Change ALL `/users` to `/admin/users`
   - Requires admin role

4. **Subscription Service** ❌

   - Complete rewrite needed
   - Path: `/subscriptions` → `/subscription/...`
   - Multiple new endpoints

5. **Notification Service** ❌
   - Change mark-read from PUT to POST
   - Use single endpoint with IDs array

### Medium Priority (Should Fix)

6. **Chat Service** ⚠️

   - Remove PUT and DELETE (not supported)

7. **Payment Service** ⚠️

   - Change PUT to PATCH
   - Change PUT `/mark-paid` to POST

8. **Order Service** ⚠️

   - Remove generic PUT and DELETE
   - Add specific action endpoints (cancel, assign, status)

9. **Rating Service** ⚠️

   - Remove PUT and DELETE (not supported)

10. **Feedback Service** ⚠️
    - Remove PUT and DELETE (not supported)

### Already Correct ✅

11. **Schedule Service** ✅ (mostly correct)
12. **Admin Service** ✅ (mostly correct)

---

## 🎯 FIX PRIORITY ORDER

1. **Tracking** - Most failures (404 errors)
2. **Users** - Wrong path (`/admin/users` required)
3. **Balance** - Wrong GET endpoint
4. **Subscription** - Complete path mismatch
5. **Notification** - Method mismatch (PUT → POST)
6. **Others** - Minor fixes (remove unsupported endpoints)

---

## ✅ NEXT ACTIONS

1. ✅ Create this mapping table (DONE)
2. ⏳ Fix tracking_service_complete.dart (HIGH PRIORITY)
3. ⏳ Fix users_service.dart (HIGH PRIORITY)
4. ⏳ Fix balance_service_complete.dart (HIGH PRIORITY)
5. ⏳ Fix subscription_service_complete.dart (HIGH PRIORITY)
6. ⏳ Fix notification_service_complete.dart (MEDIUM)
7. ⏳ Fix other services (MEDIUM)
8. ⏳ Update test script with correct paths
9. ⏳ Re-run comprehensive tests
10. ⏳ Document final results

---

**Status:** 🔧 Ready to start fixing  
**Expected Impact:** Pass rate should improve from 12.5% to >80%
