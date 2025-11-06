# 🚀 QUICK START - Local API Testing

## ⚡ Quick Test (30 seconds)

```bash
# 1. Go to backend directory
cd C:\Users\HP VICTUS\Documents\GitHub\Gerobaks\backend

# 2. Run comprehensive test
php test_final_100.php
```

**Expected Result:**

```
🎉🎉🎉 100% PASS RATE ACHIEVED! 🎉🎉🎉
Total Tests: 25
Passed: 25
Failed: 0
Pass Rate: 100%
```

---

## 📋 Prerequisites

✅ **Server Running:**

```bash
cd C:\Users\HP VICTUS\Documents\GitHub\Gerobaks\backend
php artisan serve
```

✅ **Database Connected:**

- Host: 202.10.35.161:3306
- Database: gerobaks_production
- User: gerobaks_admin

✅ **Test Users Exist:**

```bash
php create_test_users.php  # Creates mitra & admin
php create_end_user.php     # Creates end_user
```

---

## 🧪 Test Users

| Role     | Email           | Password    | Usage              |
| -------- | --------------- | ----------- | ------------------ |
| End User | daffa@gmail.com | password123 | Customer endpoints |
| Mitra    | mitra@test.com  | password123 | Mitra endpoints    |
| Admin    | admin@test.com  | password123 | Admin endpoints    |

---

## 🔧 Troubleshooting

### ❌ Tests Failing?

**1. Clear Caches:**

```bash
cd backend
php artisan config:clear
php artisan cache:clear
```

**2. Check Server:**

```bash
# Should return: Local: http://127.0.0.1:8000
php artisan serve --verbose
```

**3. Recreate Users:**

```bash
php create_test_users.php
php create_end_user.php
```

**4. Verify Database:**

```bash
php check_token_table.php
php check_users_table.php
```

---

## 📦 All Test Files

### Recommended (PHP)

- ✅ `backend/test_final_100.php` - **BEST** - Reliable, fast, accurate

### Alternative (PowerShell)

- ⚠️ `test-100-percent.ps1` - Has JSON serialization issues

### Debug Tools

- `backend/test_validation_errors.php` - Check specific validation errors
- `backend/check_token_table.php` - Verify personal_access_tokens structure
- `backend/check_users_table.php` - Verify users table structure

---

## 🎯 What Gets Tested

### 25 Endpoints Total:

**Authentication (3):**

- POST /api/login (end_user)
- POST /api/login (mitra)
- POST /api/login (admin)

**Tracking (2):**

- GET /api/tracking
- POST /api/tracking

**Rating (2):**

- GET /api/ratings
- POST /api/ratings

**Chat (2):**

- GET /api/chats
- POST /api/chats

**Payment (2):**

- GET /api/payments
- POST /api/payments

**Balance (3):**

- GET /api/balance/summary
- GET /api/balance/ledger
- POST /api/balance/topup

**Schedule (2):**

- GET /api/schedules
- POST /api/schedules

**Order (2):**

- GET /api/orders
- POST /api/orders

**Notification (2):**

- GET /api/notifications
- POST /api/notifications/mark-read

**Subscription (2):**

- GET /api/subscription/plans
- POST /api/subscription/subscribe

**Feedback (2):**

- GET /api/feedback
- POST /api/feedback

**Admin (1):**

- GET /api/admin/users

---

## 💡 Pro Tips

### Fast Testing Workflow:

```bash
# Terminal 1: Keep server running
cd backend
php artisan serve

# Terminal 2: Run tests anytime
cd backend
php test_final_100.php
```

### Frontend Development:

```dart
// lib/app_config.dart
const String apiBaseUrl = 'http://localhost:8000/api';

// Use these test credentials:
// Email: daffa@gmail.com
// Password: password123
```

---

## 📊 Success Criteria

✅ All 25 tests PASS  
✅ No 401 (authentication) errors  
✅ No 422 (validation) errors  
✅ No 404 (not found) errors  
✅ No 500 (server) errors

---

## 🆘 Emergency Recovery

### If Everything Breaks:

**1. Restore Database Tables:**

```bash
cd backend
php fix_users_table_manual.php
php artisan migrate:fresh --force
```

**2. Recreate Test Users:**

```bash
php create_test_users.php
php create_end_user.php
```

**3. Clear Everything:**

```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

**4. Test Again:**

```bash
php test_final_100.php
```

---

## 📞 Need Help?

See detailed documentation:

- `100_PERCENT_ACHIEVEMENT.md` - Full report
- `SANCTUM_FIX_SUCCESS.md` - Authentication fix details
- `PLAN_100_PERCENT.md` - Strategy document

---

**Last Updated:** January 15, 2025  
**Status:** ✅ 100% Pass Rate Achieved
