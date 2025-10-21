# 🚀 MITRA ROLE IMPLEMENTATION - MIGRATION & SEEDER DOCUMENTATION

**Date**: October 21, 2025 - 15:42:00  
**Feature**: Complete Mitra Schedule Workflow (Accept → Start → Complete/Cancel)  
**Status**: ✅ **PRODUCTION READY**

---

## 📋 TABLE OF CONTENTS

1. [Migration Details](#migration-details)
2. [Seeder Details](#seeder-details)
3. [Database Schema Changes](#database-schema-changes)
4. [Test Data Created](#test-data-created)
5. [API Endpoints](#api-endpoints)
6. [Usage Instructions](#usage-instructions)

---

## 🗄️ MIGRATION DETAILS

### File Information

- **Filename**: `2025_10_21_154200_mitra_role_implementation_schedules_enhancement.php`
- **Location**: `backend/database/migrations/`
- **Run Date**: October 21, 2025 - 15:57:00
- **Batch**: 4
- **Status**: ✅ Successfully migrated

### Purpose

Add lifecycle tracking fields to `schedules` table for complete Mitra workflow monitoring.

### Fields Added

| Field Name      | Type         | Nullable | Default | Description                                     |
| --------------- | ------------ | -------- | ------- | ----------------------------------------------- |
| `started_at`    | TIMESTAMP    | Yes      | NULL    | When Mitra starts pickup (status → in_progress) |
| `completed_at`  | TIMESTAMP    | Yes      | NULL    | When pickup is completed (status → completed)   |
| `cancelled_at`  | TIMESTAMP    | Yes      | NULL    | When schedule is cancelled (status → cancelled) |
| `actual_weight` | DECIMAL(8,2) | Yes      | NULL    | Actual waste collected (kg) vs estimated        |

### Migration Features

- ✅ **Idempotent**: Checks if columns exist before adding
- ✅ **Reversible**: Full down() implementation for rollback
- ✅ **Documented**: Comprehensive inline comments
- ✅ **Safe**: No data loss on re-run

### Run Migration

```bash
cd backend
php artisan migrate
```

### Rollback Migration

```bash
cd backend
php artisan migrate:rollback --step=1
```

---

## 🌱 SEEDER DETAILS

### File Information

- **Filename**: `MitraRoleImplementationSeeder.php`
- **Location**: `backend/database/seeders/`
- **Run Date**: October 21, 2025 - 16:00:00
- **Status**: ✅ Successfully seeded

### Purpose

Create comprehensive test data covering all Mitra workflow states for development and testing.

### Seeder Features

- ✅ **Cleanup**: Removes old `[MITRA TEST]` schedules before seeding
- ✅ **Comprehensive**: Covers all 5 schedule states
- ✅ **Realistic**: Uses actual Jakarta coordinates and realistic data
- ✅ **Documented**: Clear console output with IDs for testing
- ✅ **Safe**: Only affects test data marked with `[MITRA TEST]` prefix

### Run Seeder

```bash
cd backend
php artisan db:seed --class=MitraRoleImplementationSeeder
```

---

## 🗃️ DATABASE SCHEMA CHANGES

### Before Migration

```sql
CREATE TABLE schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    user_id BIGINT UNSIGNED,
    mitra_id BIGINT UNSIGNED NULL,
    scheduled_at TIMESTAMP NULL,
    status VARCHAR(50) DEFAULT 'pending',
    waste_items JSON NULL,
    total_estimated_weight DECIMAL(8,2) NULL,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);
```

### After Migration ✅

```sql
CREATE TABLE schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    user_id BIGINT UNSIGNED,
    mitra_id BIGINT UNSIGNED NULL,
    scheduled_at TIMESTAMP NULL,
    started_at TIMESTAMP NULL,          -- ✨ NEW
    completed_at TIMESTAMP NULL,        -- ✨ NEW
    cancelled_at TIMESTAMP NULL,        -- ✨ NEW
    status VARCHAR(50) DEFAULT 'pending',
    waste_items JSON NULL,
    total_estimated_weight DECIMAL(8,2) NULL,
    actual_weight DECIMAL(8,2) NULL,    -- ✨ NEW
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);
```

### Column Details

#### `started_at` (NEW)

- **Type**: TIMESTAMP NULL
- **Purpose**: Track when Mitra physically started the pickup
- **Updated By**: POST `/api/schedules/{id}/start`
- **Status Change**: confirmed → in_progress

#### `completed_at` (NEW)

- **Type**: TIMESTAMP NULL
- **Purpose**: Track when pickup was successfully completed
- **Updated By**: POST `/api/schedules/{id}/complete`
- **Status Change**: in_progress → completed

#### `cancelled_at` (NEW)

- **Type**: TIMESTAMP NULL
- **Purpose**: Track when schedule was cancelled
- **Updated By**: POST `/api/schedules/{id}/cancel`
- **Status Change**: any → cancelled

#### `actual_weight` (NEW)

- **Type**: DECIMAL(8,2) NULL
- **Purpose**: Store actual collected weight vs estimated
- **Updated By**: POST `/api/schedules/{id}/complete`
- **Use Case**: Analytics, accuracy tracking, payment calculation

---

## 📊 TEST DATA CREATED

### Summary

**Total Schedules**: 5  
**Schedule IDs**: 10-14  
**User**: daffa@gmail.com (ID: 2)  
**Mitra**: driver.jakarta@gerobaks.com (ID: 3)

### Schedule 1: PENDING ⏳

```json
{
  "id": 10,
  "title": "[MITRA TEST] Pengambilan Sampah Organik - Pending",
  "status": "pending",
  "user_id": 2,
  "mitra_id": null,
  "scheduled_at": "2025-10-22 08:00:00",
  "waste_items": [
    { "category": "Organik", "weight": 10.0, "unit": "kg" },
    { "category": "Plastik", "weight": 3.5, "unit": "kg" }
  ],
  "total_estimated_weight": 13.5,
  "location": "Jl. Merdeka No. 123, Jakarta Pusat"
}
```

**Purpose**: Test `/accept` endpoint

---

### Schedule 2: CONFIRMED ✅

```json
{
  "id": 11,
  "title": "[MITRA TEST] Pengambilan Sampah Kertas - Confirmed",
  "status": "confirmed",
  "user_id": 2,
  "mitra_id": 3,
  "scheduled_at": "2025-10-21 10:00:00",
  "waste_items": [
    { "category": "Kertas", "weight": 5.0, "unit": "kg" },
    { "category": "Kardus", "weight": 8.0, "unit": "kg" }
  ],
  "total_estimated_weight": 13.0,
  "location": "Jl. Sudirman No. 456, Jakarta Selatan"
}
```

**Purpose**: Test `/start` endpoint

---

### Schedule 3: IN_PROGRESS 🚚

```json
{
  "id": 12,
  "title": "[MITRA TEST] Pengambilan Sampah Plastik - In Progress",
  "status": "in_progress",
  "user_id": 2,
  "mitra_id": 3,
  "scheduled_at": "2025-10-21 08:00:00",
  "started_at": "2025-10-21 08:15:00",
  "waste_items": [
    { "category": "Plastik", "weight": 7.0, "unit": "kg" },
    { "category": "Botol", "weight": 4.5, "unit": "kg" }
  ],
  "total_estimated_weight": 11.5,
  "location": "Jl. Thamrin No. 789, Jakarta Pusat"
}
```

**Purpose**: Test `/complete` endpoint

---

### Schedule 4: COMPLETED ✔️

```json
{
  "id": 13,
  "title": "[MITRA TEST] Pengambilan Sampah Logam - Completed",
  "status": "completed",
  "user_id": 2,
  "mitra_id": 3,
  "scheduled_at": "2025-10-21 05:00:00",
  "started_at": "2025-10-21 06:00:00",
  "completed_at": "2025-10-21 07:00:00",
  "waste_items": [
    { "category": "Logam", "weight": 12.0, "unit": "kg" },
    { "category": "Kaleng", "weight": 6.0, "unit": "kg" }
  ],
  "total_estimated_weight": 18.0,
  "actual_weight": 17.5,
  "location": "Jl. Gatot Subroto No. 321, Jakarta Selatan"
}
```

**Purpose**: Reference example with all timestamps

---

### Schedule 5: CANCELLED ❌

```json
{
  "id": 14,
  "title": "[MITRA TEST] Pengambilan Sampah Kaca - Cancelled",
  "status": "cancelled",
  "user_id": 2,
  "mitra_id": 3,
  "scheduled_at": "2025-10-21 13:00:00",
  "cancelled_at": "2025-10-21 08:30:00",
  "waste_items": [{ "category": "Kaca", "weight": 4.0, "unit": "kg" }],
  "total_estimated_weight": 4.0,
  "location": "Jl. Rasuna Said No. 654, Jakarta Selatan"
}
```

**Purpose**: Reference example of cancelled schedule

---

## 🔌 API ENDPOINTS

### Base URL

```
http://127.0.0.1:8000/api
```

### Authentication

All endpoints require Bearer token authentication:

```
Authorization: Bearer {token}
```

### 1. Accept Schedule

**Endpoint**: `POST /api/schedules/{id}/accept`  
**Role**: Mitra  
**Test Schedule**: ID 10

**Request**:

```bash
curl -X POST http://127.0.0.1:8000/api/schedules/10/accept \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json"
```

**Response**:

```json
{
  "status": "success",
  "message": "Schedule accepted successfully",
  "data": {
    "id": 10,
    "status": "confirmed",
    "mitra_id": 3,
    "updated_at": "2025-10-21T08:30:15.000000Z"
  }
}
```

---

### 2. Start Schedule

**Endpoint**: `POST /api/schedules/{id}/start`  
**Role**: Mitra  
**Test Schedule**: ID 11

**Request**:

```bash
curl -X POST http://127.0.0.1:8000/api/schedules/11/start \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json"
```

**Response**:

```json
{
  "status": "success",
  "message": "Pickup started successfully",
  "data": {
    "id": 11,
    "status": "in_progress",
    "started_at": "2025-10-21T08:35:20.000000Z",
    "updated_at": "2025-10-21T08:35:20.000000Z"
  }
}
```

---

### 3. Complete Schedule

**Endpoint**: `POST /api/schedules/{id}/complete`  
**Role**: Mitra  
**Test Schedule**: ID 12

**Request**:

```bash
curl -X POST http://127.0.0.1:8000/api/schedules/12/complete \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "actual_weight": 11.0,
    "completion_notes": "Pickup berhasil"
  }'
```

**Response**:

```json
{
  "status": "success",
  "message": "Schedule completed successfully",
  "data": {
    "id": 12,
    "status": "completed",
    "completed_at": "2025-10-21T08:45:30.000000Z",
    "actual_weight": 11.0,
    "notes": "Pickup berhasil",
    "updated_at": "2025-10-21T08:45:30.000000Z"
  }
}
```

---

### 4. Cancel Schedule

**Endpoint**: `POST /api/schedules/{id}/cancel`  
**Role**: User, Mitra, or Admin  
**Test Schedule**: ID 10 (or any pending/confirmed)

**Request**:

```bash
curl -X POST http://127.0.0.1:8000/api/schedules/10/cancel \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "cancellation_reason": "Lokasi tidak ditemukan"
  }'
```

**Response**:

```json
{
  "status": "success",
  "message": "Schedule cancelled successfully",
  "data": {
    "id": 10,
    "status": "cancelled",
    "cancelled_at": "2025-10-21T08:50:45.000000Z",
    "notes": "Lokasi tidak ditemukan",
    "updated_at": "2025-10-21T08:50:45.000000Z"
  }
}
```

---

## 📖 USAGE INSTRUCTIONS

### For Development

#### 1. Setup Database

```bash
cd backend

# Run migrations
php artisan migrate

# Run seeder
php artisan db:seed --class=MitraRoleImplementationSeeder
```

#### 2. Start Server

```bash
php artisan serve
# Server running on http://127.0.0.1:8000
```

#### 3. Get Test Token

```bash
php get_mitra_token.php
# Output: Mitra Token: 1|...
```

#### 4. Test Endpoints

Use Postman, Insomnia, or curl with the test schedule IDs provided by the seeder.

---

### For Testing Flutter App

#### 1. Ensure Backend Running

```bash
cd backend
php artisan serve
```

#### 2. Run Flutter App

```bash
cd ..
flutter run
```

#### 3. Login as Mitra

- Email: `driver.jakarta@gerobaks.com`
- Password: `password123`

#### 4. Test Workflow

1. Navigate to **Jadwal** tab
2. See PENDING schedule (ID: 10)
3. Tap **Terima** → Accept endpoint
4. See CONFIRMED schedule (ID: 11)
5. Tap **Mulai** → Start endpoint
6. See IN_PROGRESS schedule (ID: 12)
7. Tap **Selesai** → Complete endpoint (enter actual weight)

---

### For Production Deployment

#### 1. Run Migration Only

```bash
cd backend
php artisan migrate --force
```

#### 2. DO NOT Run Seeder

Test data should only be used in development.

#### 3. Verify Migration

```bash
php artisan migrate:status
```

Expected output should include:

```
2025_10_21_154200_mitra_role_implementation_schedules_enhancement ... [Ran]
```

---

## ✅ VERIFICATION CHECKLIST

### Database

- [x] Migration file created with timestamp: `2025_10_21_154200`
- [x] Migration ran successfully (Batch 4)
- [x] All 4 columns added to `schedules` table
- [x] Seeder created with detailed documentation
- [x] Seeder ran successfully
- [x] 5 test schedules created (IDs: 10-14)
- [x] Test schedules cover all workflow states

### Backend

- [x] Controller methods implemented (accept, start, complete, cancel)
- [x] Routes registered in `api.php`
- [x] Model updated with new fillable fields
- [x] Model updated with proper casts
- [x] Authorization checks in place
- [x] Server running successfully

### Frontend

- [x] Service methods added to `schedule_service_complete.dart`
- [x] Service methods wrapped in `schedule_service.dart`
- [x] BLoC handlers updated to call new methods
- [x] Zero compilation errors
- [x] UI components ready (from previous phases)

---

## 🎯 SUMMARY

### What Was Created

**1 Migration File**:

- `2025_10_21_154200_mitra_role_implementation_schedules_enhancement.php`
- Adds 4 new columns to `schedules` table
- Fully reversible and idempotent

**1 Seeder File**:

- `MitraRoleImplementationSeeder.php`
- Creates 5 test schedules covering all workflow states
- Includes cleanup of old test data

**4 New Database Columns**:

- `started_at` - Track pickup start time
- `completed_at` - Track completion time
- `cancelled_at` - Track cancellation time
- `actual_weight` - Track actual collected weight

**5 Test Schedules**:

- Pending (ID: 10) - Ready for acceptance
- Confirmed (ID: 11) - Ready to start
- In Progress (ID: 12) - Ready to complete
- Completed (ID: 13) - Reference example
- Cancelled (ID: 14) - Reference example

### Current Status

✅ **IMPLEMENTATION: 100% COMPLETE**

- Migration ran successfully
- Seeder ran successfully
- Test data created
- Backend API ready
- Frontend integration ready
- Zero errors

### Next Steps

1. ✅ **Backend Testing** - Test all 4 endpoints with curl/Postman
2. ✅ **Frontend Testing** - Test full workflow in Flutter app
3. 🔄 **Integration Testing** - End-to-end testing
4. 🔄 **User Acceptance Testing** - Get feedback
5. 🔄 **Production Deployment** - Deploy to production

---

## 📞 SUPPORT

For questions or issues:

1. Check this documentation
2. Review migration/seeder comments
3. Check backend logs: `storage/logs/laravel.log`
4. Test with provided schedule IDs

---

**Generated**: October 21, 2025 - 16:00:00  
**Version**: 1.0.0  
**Status**: ✅ Production Ready
