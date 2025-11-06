# Plan untuk 100% Pass Rate

## Current Status: 37.5% (9/24)

### Issues Breakdown:

1. **403 Forbidden (2):** Role-based access - butuh user dengan role yang tepat
2. **422 Validation (7):** Data validation - butuh payload yang valid
3. **404 Not Found (6):** Wrong endpoint paths

---

## Strategy untuk Fix

### Phase 1: Fix Role-Based Issues (403) - 2 tests

- POST /tracking - butuh role `mitra`
- POST /schedules - butuh role `mitra` atau `admin`
- **Solution:** Login dengan user mitra yang sudah dibuat

### Phase 2: Fix Endpoint Paths (404) - 6 tests

1. GET /balance → Cek route yang benar
2. GET /subscriptions → Cek route yang benar
3. POST /subscriptions → Cek route yang benar
4. PUT /notifications/mark-all-read → Cek method/path yang benar
5. GET /users → Cek route yang benar (admin only)
6. POST /balance/topup → Cek validation

### Phase 3: Fix Validation Errors (422) - 7 tests

- POST /ratings - butuh order_id, rating, comment
- POST /chats - butuh message, receiver_id
- POST /payments - butuh order_id, amount, method
- POST /orders - butuh service_id, schedule_id, address
- POST /feedback - butuh subject, message
- GET /balance/ledger - cek query params
- GET /balance/summary - cek query params

---

## Execution Plan

### Step 1: Update test script untuk support multiple users

- Add login with mitra user
- Add login with admin user
- Use appropriate token for each test

### Step 2: Check all route definitions

- Read routes/api.php completely
- Match with test endpoints
- Fix test script paths

### Step 3: Add valid data for POST requests

- Check controller validation rules
- Provide minimal valid data
- Handle optional fields

### Step 4: Run comprehensive test

- Test all endpoints
- Document results
- Fix any remaining issues

---

## Files to Edit:

1. test-all-mobile-services.ps1 - Update with fixes
2. May need to check backend routes if paths are wrong
