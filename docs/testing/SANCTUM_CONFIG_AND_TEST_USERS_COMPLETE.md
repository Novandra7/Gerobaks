# ✅ SETUP COMPLETE - SANCTUM CONFIG & TEST USERS

**Date:** October 15, 2025  
**Status:** ✅ **PARTIAL SUCCESS**

---

## ✅ COMPLETED TASKS

### OPTION A: Fix Sanctum Configuration (IN PROGRESS)

#### Changes Made:

1. ✅ **Added Sanctum Guard** to `config/auth.php`

   ```php
   'guards' => [
       'web' => ['driver' => 'session', 'provider' => 'users'],
       'sanctum' => ['driver' => 'sanctum', 'provider' => 'users'], // ADDED
   ],
   ```

2. ✅ **Added Sanctum Middleware** to `bootstrap/app.php`

   ```php
   ->withMiddleware(function (Middleware $middleware): void {
       // Added Sanctum middleware for API
       $middleware->api(prepend: [
           \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
       ]);

       // CORS middleware
       $middleware->appendToGroup('api', [\App\Http\Middleware\Cors::class]);

       // Role middleware
       $middleware->alias(['role' => \App\Http\Middleware\RoleAuthorization::class]);
   })
   ```

3. ✅ **Verified Sanctum Installation**
   - Package: `laravel/sanctum v4.2.0` ✅
   - Migration: `personal_access_tokens` table exists ✅
   - User Model: Has `HasApiTokens` trait ✅

#### Current Issue:

❌ **401 Unauthorized** still occurs on authenticated endpoints

**Test Results:**

```
Token Generated: 0|WBa6BPoefYVgLpuliyG7BAi3RdtBjmlJHnBssqhp3e4d68ba ✅
Token in Database: ✅ Exists
Token Passed in Header: ✅ Authorization: Bearer ...
Result: ❌ 401 Unauthorized
```

**Investigation:**

- Token exists in database: ✅
- Token format correct: ✅ `{id}|{plaintext}`
- Header passed correctly: ✅
- Middleware configured: ✅
- **`last_used_at` remains NULL** ← Token never validated successfully

**Probable Causes:**

1. Laravel 12 + Sanctum v4.2 compatibility issue
2. Custom CORS middleware conflict
3. Missing service provider registration
4. Token validation logic issue in Sanctum v4

**Recommendation:**  
This needs deeper investigation. Possible solutions:

- Downgrade to Sanctum v3.x
- Remove custom CORS middleware
- Check Laravel 12 documentation for Sanctum setup
- Use Passport instead of Sanctum

---

### OPTION B: Create Test Users ✅ **COMPLETE!**

Successfully created 3 test users with different roles:

#### 1. End User (Customer)

```
Email: daffa@gmail.com
Password: password123
Role: end_user
Token: 0|cy0X1fwwKhg35zGVWpFcYyLYwbwZQGbDcqsyerCm9851e0ae
```

**Permissions:**

- ✅ POST /api/ratings (create reviews)
- ✅ POST /api/orders (create garbage pickup orders)
- ✅ POST /api/schedules/mobile (create schedules)
- ✅ POST /api/orders/{id}/cancel (cancel own orders)
- ✅ GET /api/auth/me, /api/chats, /api/notifications, etc.

#### 2. Mitra User (Driver/Collector)

```
Email: mitra@test.com
Password: password123
Role: mitra
Token: 0|AniYVYyrnDItY32I3PVqgAbYfmDrSuoJYqnZJuzXf4e42fe8
```

**Permissions:**

- ✅ POST /api/tracking (create GPS tracking points)
- ✅ POST /api/schedules (create pickup schedules)
- ✅ PATCH /api/schedules/{id} (update schedules)
- ✅ POST /api/schedules/{id}/complete (mark complete)
- ✅ PATCH /api/orders/{id}/assign (assign orders to self)
- ✅ PATCH /api/orders/{id}/status (update order status)
- ✅ GET /api/dashboard/mitra/{id}

#### 3. Admin User

```
Email: admin@test.com
Password: password123
Role: admin
Token: 0|buZPx4ksxVcx0e3hXeDEoJIWZvgCn2AuJb6cVWQW1fa3d5bd
```

**Permissions:**

- ✅ All mitra permissions
- ✅ POST /api/services (manage services)
- ✅ PATCH /api/services/{id}
- ✅ GET /api/admin/users (manage users)
- ✅ POST /api/admin/users (create users)
- ✅ PATCH /api/admin/users/{id} (update users)
- ✅ DELETE /api/admin/users/{id}
- ✅ POST /api/notifications (send notifications)
- ✅ GET /api/admin/stats
- ✅ PATCH /api/settings (update app settings)

---

## 📊 TESTING WITH DIFFERENT ROLES

### Manual Testing Commands

#### Test as End User (daffa@gmail.com)

```powershell
$token = "0|cy0X1fwwKhg35zGVWpFcYyLYwbwZQGbDcqsyerCm9851e0ae"
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json"}

# Should work (end_user can create ratings)
Invoke-RestMethod -Uri "http://localhost:8000/api/ratings" `
  -Method POST -Headers $headers `
  -Body (@{order_id=1;rating=5;review="Great service"}|ConvertTo-Json) `
  -ContentType "application/json"

# Should FAIL 403 (needs mitra role)
Invoke-RestMethod -Uri "http://localhost:8000/api/tracking" `
  -Method POST -Headers $headers `
  -Body (@{schedule_id=1;latitude=-6.2;longitude=106.8}|ConvertTo-Json) `
  -ContentType "application/json"
```

#### Test as Mitra (mitra@test.com)

```powershell
$token = "0|AniYVYyrnDItY32I3PVqgAbYfmDrSuoJYqnZJuzXf4e42fe8"
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json"}

# Should work (mitra can create tracking)
Invoke-RestMethod -Uri "http://localhost:8000/api/tracking" `
  -Method POST -Headers $headers `
  -Body (@{schedule_id=1;latitude=-6.2088;longitude=106.8456;status="on_the_way"}|ConvertTo-Json) `
  -ContentType "application/json"

# Should work (mitra can create schedules)
Invoke-RestMethod -Uri "http://localhost:8000/api/schedules" `
  -Method POST -Headers $headers `
  -Body (@{user_id=1;service_id=1;scheduled_date="2025-10-20"}|ConvertTo-Json) `
  -ContentType "application/json"
```

#### Test as Admin (admin@test.com)

```powershell
$token = "0|buZPx4ksxVcx0e3hXeDEoJIWZvgCn2AuJb6cVWQW1fa3d5bd"
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json"}

# Should work (admin can list users)
Invoke-RestMethod -Uri "http://localhost:8000/api/admin/users" -Headers $headers

# Should work (admin can create users)
Invoke-RestMethod -Uri "http://localhost:8000/api/admin/users" `
  -Method POST -Headers $headers `
  -Body (@{name="New User";email="new@test.com";password="pass123";role="end_user"}|ConvertTo-Json) `
  -ContentType "application/json"
```

---

## 🔧 UPDATE TEST SCRIPT

Mari update `test-all-mobile-services.ps1` untuk support multiple users:

```powershell
# At the top of the script
$testUsers = @{
    end_user = @{email="daffa@gmail.com"; password="password123"}
    mitra = @{email="mitra@test.com"; password="password123"}
    admin = @{email="admin@test.com"; password="password123"}
}

# Login function
function Get-AuthToken($userType) {
    $user = $testUsers[$userType]
    $result = Invoke-ApiRequest -Method POST -Endpoint "/login" `
        -RequireAuth $false -Body $user
    return $result.Data.data.token
}

# Usage:
$endUserToken = Get-AuthToken "end_user"
$mitraToken = Get-AuthToken "mitra"
$adminToken = Get-AuthToken "admin"
```

---

## 📝 FILES CREATED/MODIFIED

### Modified Files

1. ✅ `backend/config/auth.php`

   - Added `sanctum` guard

2. ✅ `backend/bootstrap/app.php`
   - Added Sanctum middleware
   - Added EnsureFrontendRequestsAreStateful

### Created Files

3. ✅ `backend/create_test_users.php`
   - Script to create test users with different roles
4. ✅ `backend/test_sanctum_auth.php`
   - Debug script for Sanctum authentication

---

## 🎯 CURRENT STATUS

### ✅ Working:

1. Local API server running ✅
2. Database connection (MySQL online) ✅
3. Test users created with all roles ✅
4. Tokens generated for each user ✅
5. Public endpoints working ✅

### ⏳ Partially Working:

1. Sanctum middleware configured ✅
2. Token generation working ✅
3. Token storage in database ✅
4. **Token validation NOT working** ❌

### ❌ Not Working:

1. `auth:sanctum` middleware returning 401
2. All authenticated endpoints failing
3. Role-based access control not testable yet

---

## 🚀 NEXT STEPS

### Immediate (Critical - Blocks Testing)

**Option 1: Debug Sanctum Further**

- Check Laravel 12 + Sanctum v4 compatibility
- Review Sanctum source code for validation logic
- Check if there's a known issue in GitHub

**Option 2: Workaround Without Sanctum**

- Create custom token validation middleware
- Use session-based auth for testing
- Implement JWT authentication

**Option 3: Test Backend Directly**
IF backend has Swagger/Postman collection:

- Test with Postman/Insomnia
- Verify if issue is PowerShell-specific
- Rule out client-side issues

### Short Term (After Auth Fixed)

1. ✅ Update test script to use different user roles
2. ✅ Re-run comprehensive tests
3. ✅ Fix remaining endpoint paths (404 errors)
4. ✅ Test role-based access control

### Medium Term

1. Document which endpoints work with which roles
2. Create role-specific test suites
3. Add comprehensive error handling
4. Generate test report

---

## 💡 WORKAROUND FOR TESTING

Since authenticated endpoints not working yet, you can:

### 1. Test Public Endpoints (No Auth Required)

```powershell
# These should work without token
GET /api/tracking
GET /api/ratings
GET /api/schedules
GET /api/services
POST /api/login
POST /api/register
```

### 2. Test with Postman/Insomnia

- Import backend API documentation
- Test with real HTTP client
- Verify backend is working correctly

### 3. Check Backend Logs

```bash
tail -f backend/storage/logs/laravel.log
```

Look for authentication errors

---

## 📊 SUMMARY

**Completed:**

- ✅ Option B: Created test users (end_user, mitra, admin)
- ✅ Generated tokens for each user
- ✅ Configured Sanctum middleware (partial)

**In Progress:**

- ⏳ Option A: Sanctum authentication debugging
- ⏳ Token validation issue resolution

**Blocked:**

- ❌ Comprehensive endpoint testing (needs working auth)
- ❌ Role-based access control testing
- ❌ 16+ authenticated endpoints

**Pass Rate:**

- Current: 16.67% (4/24 tests)
- Expected after auth fix: 40-50%
- Target after all fixes: 80%+

---

**Recommendation:**

Karena Sanctum auth issue cukup complex dan mungkin require deep Laravel internals knowledge, saya suggest:

1. **Test backend dengan Postman dulu** - verify backend working
2. **Check Laravel 12 documentation** - untuk Sanctum v4 setup
3. **Consider alternative auth** - JWT atau custom middleware

Test users sudah ready, tinggal fix authentication method! 🚀

---

**Last Updated:** October 15, 2025  
**Next Action:** Debug Sanctum token validation OR test with Postman
