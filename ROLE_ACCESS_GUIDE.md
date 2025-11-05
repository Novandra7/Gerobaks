# Quick Reference: Role-Based Access Control

## 🎭 Roles Overview

### 1. **admin** - Administrator (Super User)

**Akses Level:** FULL ACCESS

#### Permissions:

- ✅ **Services:** Full CRUD (Create, Read, Update, Delete)
- ✅ **Schedules:** Full CRUD + Complete/Cancel
- ✅ **Tracking:** Full CRUD
- ✅ **Orders:** Full CRUD + Assign + Update Status
- ✅ **Payments:** Full CRUD including Delete
- ✅ **Reports:** Full CRUD
- ✅ **Settings:** Full CRUD
- ✅ **Subscription Plans:** Full CRUD
- ✅ **Subscriptions:** Delete any subscription
- ✅ **User Management:** Create, Read, Update, Delete users
- ✅ **System Operations:** Stats, Logs, Export, Health Monitoring
- ✅ **Notifications:** Send to all users

#### Example Use Cases:

- Mengelola seluruh sistem
- Menambah/menghapus layanan
- Melihat dan mengubah data semua user
- Monitoring kesehatan sistem
- Export data untuk reporting

---

### 2. **mitra** - Service Provider (Driver/Collector)

**Akses Level:** OPERATIONAL

#### Permissions:

- ✅ **Schedules:** Create, Read, Update, Delete (jadwal sendiri)
- ✅ **Tracking:** Create, Read, Update tracking data
- ✅ **Orders:** Read, Assign (assign order ke diri sendiri), Update Status
- ✅ **Balance:** View ledger/summary, Top up, Withdraw
- ✅ **Dashboard:** View mitra dashboard
- ✅ **Chats:** Full CRUD
- ✅ **Notifications:** Read, Update, Delete (notifikasi sendiri)
- ✅ **Feedback:** Submit dan manage feedback
- ❌ Cannot modify Services (read only)
- ❌ Cannot delete Payments
- ❌ Cannot access Admin operations

#### Example Use Cases:

- Membuat jadwal penjemputan sampah
- Update lokasi real-time (tracking)
- Assign order yang tersedia ke diri sendiri
- Update status order (picked up, delivered, completed)
- Cek balance dan withdraw pendapatan
- Chat dengan end users

---

### 3. **end_user** - Mobile App User (Customer)

**Akses Level:** CUSTOMER

#### Permissions:

- ✅ **Orders:** Create, Read, Update, Delete, Cancel (order sendiri)
- ✅ **Ratings:** Full CRUD (rating sendiri)
- ✅ **Schedules:** Create via `/schedules/mobile` endpoint
- ✅ **Payments:** Create, Read, Update, Mark as Paid
- ✅ **Balance:** View ledger/summary, Top up, Withdraw
- ✅ **Dashboard:** View user dashboard
- ✅ **Chats:** Full CRUD
- ✅ **Notifications:** Read, Update, Delete (notifikasi sendiri)
- ✅ **Feedback:** Submit dan manage feedback
- ❌ Cannot modify Services (read only)
- ❌ Cannot modify Schedules (except mobile endpoint)
- ❌ Cannot create/modify Tracking
- ❌ Cannot delete Payments
- ❌ Cannot access Admin operations

#### Example Use Cases:

- Membuat order penjemputan sampah
- Cancel order sebelum diambil
- Memberikan rating setelah layanan selesai
- Cek status tracking penjemputan
- Top up balance untuk pembayaran
- Chat dengan mitra

---

## 📊 Quick Access Matrix

| Resource               | admin    | mitra              | end_user   | Public    |
| ---------------------- | -------- | ------------------ | ---------- | --------- |
| **Services**           | CRUD     | R                  | R          | R         |
| **Schedules**          | CRUD     | CRUD               | C (mobile) | R         |
| **Tracking**           | CRUD     | CRU                | R          | R         |
| **Orders**             | CRUD     | RU (assign/status) | CRUD (own) | -         |
| **Payments**           | CRUD     | CRU                | CRU        | -         |
| **Ratings**            | R        | R                  | CRUD (own) | R         |
| **Notifications**      | CRUD     | RUD (own)          | RUD (own)  | -         |
| **Chats**              | CRUD     | CRUD               | CRUD       | -         |
| **Feedback**           | CRUD     | CRUD               | CRUD       | -         |
| **Reports**            | CRUD     | CR                 | CR         | -         |
| **Settings**           | CRUD     | R                  | R          | R (basic) |
| **Subscription Plans** | CRUD     | R                  | R          | -         |
| **Subscriptions**      | D        | CRUD (own)         | CRUD (own) | -         |
| **Balance**            | View All | CRUD (own)         | CRUD (own) | -         |
| **Users**              | CRUD     | R (self)           | R (self)   | -         |
| **Dashboard**          | All      | Mitra              | User       | -         |
| **Admin Operations**   | Full     | -                  | -          | -         |

**Legend:**

- **C** = Create (POST)
- **R** = Read (GET)
- **U** = Update (PUT/PATCH)
- **D** = Delete (DELETE)
- **CRUD** = Full access
- **(own)** = Only their own data
- **-** = No access

---

## 🔐 Authentication Flow

### 1. Register

```http
POST /api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "end_user",  // or "mitra", "admin"
  "phone": "081234567890"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Registration successful",
  "data": {
    "user": {...},
    "token": "1|abc123..."
  }
}
```

### 2. Login

```http
POST /api/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "end_user"
    },
    "token": "2|xyz789..."
  }
}
```

### 3. Use Token in Requests

```http
GET /api/orders
Authorization: Bearer 2|xyz789...
```

### 4. Logout

```http
POST /api/auth/logout
Authorization: Bearer 2|xyz789...
```

---

## 🎯 Common Scenarios

### Scenario 1: End User Orders Pickup

```http
# 1. User creates order
POST /api/orders
Authorization: Bearer {end_user_token}
{
  "service_id": 1,
  "alamat_penjemputan": "Jl. Sudirman No. 123",
  "tanggal_penjemputan": "2025-01-20"
}

# 2. User tracks order
GET /api/tracking?order_id=1
Authorization: Bearer {end_user_token}

# 3. After completion, user rates service
POST /api/ratings
Authorization: Bearer {end_user_token}
{
  "order_id": 1,
  "rating": 5,
  "komentar": "Excellent service!"
}
```

### Scenario 2: Mitra Handles Order

```http
# 1. Mitra views available orders
GET /api/orders?status=pending
Authorization: Bearer {mitra_token}

# 2. Mitra assigns order to self
PATCH /api/orders/1/assign
Authorization: Bearer {mitra_token}

# 3. Mitra updates tracking
POST /api/tracking
Authorization: Bearer {mitra_token}
{
  "order_id": 1,
  "latitude": -6.2088,
  "longitude": 106.8456,
  "status": "on_the_way"
}

# 4. Mitra updates order status
PATCH /api/orders/1/status
Authorization: Bearer {mitra_token}
{
  "status": "picked_up"
}
```

### Scenario 3: Admin Manages System

```http
# 1. Admin creates new service
POST /api/services
Authorization: Bearer {admin_token}
{
  "nama": "Pickup Organik",
  "deskripsi": "Penjemputan sampah organik",
  "harga": 25000
}

# 2. Admin views system stats
GET /api/admin/stats
Authorization: Bearer {admin_token}

# 3. Admin sends notification to all users
POST /api/admin/notifications
Authorization: Bearer {admin_token}
{
  "title": "Promo Akhir Tahun",
  "message": "Diskon 50% untuk semua layanan!",
  "target": "all"
}
```

---

## ⚠️ Error Responses

### 401 Unauthorized

```json
{
  "status": "error",
  "message": "Unauthenticated"
}
```

**Solution:** Include valid `Authorization: Bearer {token}` header

### 403 Forbidden

```json
{
  "status": "error",
  "message": "Unauthorized. Required role: admin"
}
```

**Solution:** User doesn't have required role permissions

### 422 Unprocessable Entity

```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."]
  }
}
```

**Solution:** Fix validation errors in request body

### 404 Not Found

```json
{
  "status": "error",
  "message": "Resource not found"
}
```

**Solution:** Check if resource ID exists

---

## 📝 Best Practices

### For Frontend Developers

1. **Store Token Securely**

   - Use secure storage (e.g., Flutter Secure Storage)
   - Never log tokens to console
   - Clear token on logout

2. **Check User Role**

   ```dart
   if (user.role == 'admin') {
     // Show admin menu
   } else if (user.role == 'mitra') {
     // Show mitra menu
   } else {
     // Show end user menu
   }
   ```

3. **Handle 403 Errors**

   - Show appropriate error message
   - Redirect to allowed pages
   - Don't expose role-restricted features in UI

4. **Refresh Token**
   - Implement token refresh mechanism
   - Handle token expiration gracefully

### For Backend Developers

1. **Always Validate Ownership**

   ```php
   // Ensure user can only modify their own data
   if ($order->user_id !== auth()->id() && auth()->user()->role !== 'admin') {
       return response()->json(['error' => 'Forbidden'], 403);
   }
   ```

2. **Use Middleware Correctly**

   ```php
   // Correct: Multiple roles
   Route::middleware(['auth:sanctum', 'role:mitra,admin'])->group(...)

   // Incorrect: Only one role
   Route::middleware(['auth:sanctum', 'role:mitra'])->group(...)
   ```

3. **Consistent Responses**
   - Use same response format across all endpoints
   - Include proper HTTP status codes
   - Return meaningful error messages

---

## 🔗 Related Documentation

- [COMPLETE_CRUD_IMPLEMENTATION.md](./COMPLETE_CRUD_IMPLEMENTATION.md) - Detailed endpoint documentation
- [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md) - Quick API reference
- [SWAGGER_DOCUMENTATION.md](./SWAGGER_DOCUMENTATION.md) - Swagger UI guide

---

**Last Updated:** January 2025  
**Version:** 1.0.0
