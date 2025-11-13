# 🚨 ISSUE: Jadwal User Tidak Muncul di Mitra

**Tanggal**: 13 November 2025  
**Reporter**: Frontend Team  
**Severity**: 🔴 CRITICAL - Feature tidak berfungsi

---

## 📋 Deskripsi Masalah

User **Aceng** (aceng@gmail.com) sudah membuat jadwal penjemputan, tetapi jadwal tersebut **TIDAK MUNCUL** di tampilan "Jadwal Tersedia" pada aplikasi Mitra.

---

## ✅ Data Yang Sudah Dikonfirmasi

### 1. **Jadwal User Aceng ADA di Database**

Query: `GET /api/pickup-schedules?status=pending&show_active=true`

**Total**: 3 jadwal pending

**Detail Jadwal**:

| ID | Schedule Day | Waste Type | Status | assigned_mitra_id | is_scheduled_active |
|----|-------------|------------|--------|-------------------|---------------------|
| 48 | kamis       | Campuran   | pending | `null` ✅ | `true` ✅ |
| 46 | rabu        | B3         | pending | `null` ✅ | `true` ✅ |
| 42 | rabu        | B3         | pending | `null` ✅ | `true` ✅ |

**Karakteristik Jadwal**:
- ✅ `status = 'pending'`
- ✅ `assigned_mitra_id IS NULL` (belum ada mitra)
- ✅ `is_scheduled_active = true`
- ✅ `deleted_at IS NULL`
- ✅ User aktif (status: active)
- ✅ Alamat: "1-99 Stockton St, Union Square, San Francisco"

### 2. **Backend Sudah Update**

Tim backend konfirmasi sudah fix endpoint:
```
GET /api/mitra/pickup-schedules/available
```

**Update yang sudah dilakukan**:
- ✅ Menampilkan semua jadwal pending
- ✅ Support pagination (`?per_page=20`)
- ✅ Support filter optional: `?waste_type=`, `?area=`, `?date=`
- ✅ Return total **33 schedules** yang siap diambil mitra

---

## 🔍 Testing Yang Sudah Dilakukan

### Test 1: User Endpoint ✅ BERHASIL

```bash
# Login sebagai user Aceng
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"aceng@gmail.com","password":"Password123"}' \
  | jq -r '.data.token')

# Cek jadwal user
curl -X GET "http://127.0.0.1:8000/api/pickup-schedules?status=pending" \
  -H "Authorization: Bearer $TOKEN" | jq '.data.total'

# Result: 3 jadwal ✅
```

### Test 2: Mitra Login ❌ GAGAL

```bash
# Login sebagai mitra
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}' \
  | jq '.'

# Result: 
{
  "error": "validation_error",
  "message": "The given data was invalid.",
  "details": {
    "email": ["The provided credentials are incorrect."]
  }
}
```

**❌ BLOCKER**: Tidak bisa login sebagai mitra untuk test endpoint available!

### Test 3: Endpoint Available dengan User Token ❌ FORBIDDEN

```bash
# Test dengan token end_user
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $USER_TOKEN" | jq '.'

# Result:
{
  "error": "Forbidden",
  "message": "Insufficient permissions"
}
```

**❌ BLOCKER**: Endpoint memerlukan role `mitra`, tidak bisa ditest dengan user token!

---

## 🚨 Root Cause Analysis

### Masalah Utama:

1. **❌ Password Mitra Tidak Berfungsi**
   - Password `mitra123` tidak bisa login
   - Kemungkinan password di database tidak di-hash dengan benar
   - Atau password berubah/berbeda dari yang didokumentasikan

2. **❓ Endpoint Mitra Tidak Bisa Diverifikasi**
   - Tidak ada cara untuk test endpoint `/api/mitra/pickup-schedules/available`
   - Tidak bisa verify apakah 3 jadwal Aceng muncul atau tidak
   - Tidak bisa test apakah fix backend (33 schedules) bekerja

3. **🔒 Authorization Middleware**
   - Endpoint mitra protected dengan role check
   - Hanya user dengan role `mitra` yang bisa akses
   - Testing dari Flutter app juga gagal karena login mitra gagal

---

## 💡 Kemungkinan Penyebab Jadwal Tidak Muncul

Meskipun backend claim sudah fix, ada beberapa kemungkinan:

### A. **Filter di Backend Masih Ada**

Mungkin masih ada filter yang tidak disadari:

```php
// Kemungkinan query backend
$schedules = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('work_area', $mitra->work_area)  // ❌ INI MASALAH!
    ->get();
```

**Masalah**: User Aceng alamatnya "San Francisco", sedangkan mitra work_area "Jakarta Pusat" → **tidak match!**

### B. **Scheduled Date Filter**

```php
// Kemungkinan ada filter tanggal
->where('scheduled_pickup_at', '>=', now())
->where('scheduled_pickup_at', '<=', now()->addDays(7))
```

**Check**: Apakah jadwal ID 46 (Rabu 13 Nov) sudah lewat?

### C. **Soft Delete Issue**

```php
// Pastikan tidak filter soft delete secara manual
->whereNull('deleted_at')  // ✅ Harus ada!
```

### D. **Response Structure Tidak Sesuai**

Backend return 33 schedules, tapi Flutter app expect struktur berbeda:

**Backend Return**:
```json
{
  "success": true,
  "data": {
    "schedules": [...],  // Array 33 items
    "total": 33
  }
}
```

**Flutter Expect**:
```dart
// Sudah di-fix untuk handle both
if (data['data'] is List) {
  schedules = data['data'];
} else {
  schedules = data['data']['schedules'];
}
```

---

## 🎯 Action Items - PRIORITAS TINGGI

### 1. **FIX PASSWORD MITRA** (P0 - CRITICAL)

**Tim Backend - Urgent**:

```bash
# Masuk ke Laravel tinker
php artisan tinker

# Fix password mitra
use Illuminate\Support\Facades\Hash;
DB::table('users')
  ->where('email', 'driver.jakarta@gerobaks.com')
  ->update(['password' => Hash::make('mitra123')]);

echo "✅ Password fixed!\n";

# Test login
$user = DB::table('users')
  ->where('email', 'driver.jakarta@gerobaks.com')
  ->first();
  
echo "User: {$user->name}\n";
echo "Role: {$user->role}\n";
echo "Password hash: " . substr($user->password, 0, 10) . "...\n";
```

**Verifikasi**:
```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}' \
  | jq '.success'

# Expected: true
```

### 2. **VERIFY ENDPOINT AVAILABLE** (P0 - CRITICAL)

Setelah password fix, test endpoint:

```bash
# 1. Login sebagai mitra
MITRA_TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}' \
  | jq -r '.data.token')

# 2. Get available schedules
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?per_page=50" \
  -H "Authorization: Bearer $MITRA_TOKEN" \
  | jq '{
    success,
    total: .data.total,
    schedules_count: (.data.schedules | length),
    aceng_schedules: [.data.schedules[] | select(.user_id == 10) | {id, schedule_day, waste_type_scheduled}]
  }'
```

**Expected Output**:
```json
{
  "success": true,
  "total": 33,
  "schedules_count": 33,
  "aceng_schedules": [
    {"id": 48, "schedule_day": "kamis", "waste_type_scheduled": "Campuran"},
    {"id": 46, "schedule_day": "rabu", "waste_type_scheduled": "B3"},
    {"id": 42, "schedule_day": "rabu", "waste_type_scheduled": "B3"}
  ]
}
```

**❓ Pertanyaan untuk Backend**:
- Apakah 3 jadwal Aceng (ID: 42, 46, 48) muncul dalam 33 schedules?
- Apakah ada filter `work_area` atau location-based?
- Apakah response structure sudah sesuai?

### 3. **CHECK BACKEND QUERY** (P1 - HIGH)

**Tim Backend - Share Query**:

Tolong share actual query yang digunakan di `getAvailableSchedules()`:

```php
// File: app/Http/Controllers/Api/MitraPickupController.php
// Method: getAvailableSchedules()

public function getAvailableSchedules(Request $request)
{
    // ⚠️ TOLONG SHARE QUERY INI
    $schedules = PickupSchedule::/* ... query apa saja? */
    
    // ⚠️ Ada filter work_area?
    // ⚠️ Ada filter location/distance?
    // ⚠️ Ada filter tanggal?
}
```

### 4. **TEST VIA FLUTTER APP** (P1 - HIGH)

Setelah password fix, test di Flutter app:

**Steps**:
1. ✅ Stop Flutter app (Ctrl+C)
2. ✅ `flutter clean`
3. ✅ `flutter pub get`
4. ✅ `flutter run`
5. ✅ Login sebagai mitra (driver.jakarta@gerobaks.com / mitra123)
6. ✅ Navigasi ke "Sistem Penjemputan Mitra"
7. ✅ Buka tab "Tersedia"
8. ✅ **Cek apakah 33 jadwal muncul**
9. ✅ **Cek apakah jadwal Aceng (ID 42, 46, 48) ada**

---

## 📊 Expected vs Actual

| Item | Expected | Actual | Status |
|------|----------|--------|--------|
| User create schedule | ✅ Success | ✅ Success | ✅ PASS |
| Schedule in database | ✅ Yes | ✅ Yes (3 schedules) | ✅ PASS |
| Schedule status | pending | pending | ✅ PASS |
| assigned_mitra_id | null | null | ✅ PASS |
| is_scheduled_active | true | true | ✅ PASS |
| **Mitra login** | ✅ Success | ❌ Failed | ❌ FAIL |
| **Available endpoint** | 33 schedules | ❓ Cannot test | ⏳ BLOCKED |
| **Mitra app shows schedules** | Show 33 | Not showing | ❌ FAIL |

---

## 🔄 Workaround Sementara

Sampai password mitra di-fix, tidak ada workaround. Feature **completely blocked**.

**User Impact**:
- ❌ Mitra tidak bisa lihat jadwal tersedia
- ❌ Mitra tidak bisa accept jadwal
- ❌ User tidak bisa mendapat service penjemputan
- ❌ **Feature 100% tidak berfungsi**

---

## 📞 Contact

**Frontend Team**: Ready to test setelah backend fix password  
**Backend Team**: **URGENT** - Please fix mitra password ASAP

**Test Credentials Needed**:
```
Mitra Login:
Email: driver.jakarta@gerobaks.com
Password: mitra123 (currently NOT WORKING ❌)
```

---

## ✅ Definition of Done

Issue dianggap resolved jika:

1. ✅ Mitra bisa login dengan email/password yang benar
2. ✅ Endpoint `/api/mitra/pickup-schedules/available` return 33+ schedules
3. ✅ Jadwal user Aceng (ID: 42, 46, 48) muncul dalam list
4. ✅ Flutter app tab "Tersedia" menampilkan jadwal
5. ✅ Mitra bisa tap dan lihat detail jadwal
6. ✅ Mitra bisa accept jadwal

---

**Status**: 🔴 BLOCKED - Waiting for backend to fix mitra password  
**Last Updated**: November 13, 2025, 18:30 WIB
