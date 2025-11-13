# 🚨 QUICK ISSUE: Jadwal Tidak Muncul di Mitra

**Status**: 🔴 BLOCKED  
**Updated**: 13 Nov 2025, 18:30 WIB

---

## ❌ Masalah

Jadwal yang dibuat user **TIDAK MUNCUL** di tampilan mitra "Jadwal Tersedia"

---

## ✅ Sudah Dikonfirmasi

### Data User Aceng:
- ✅ 3 jadwal pending di database
- ✅ Status: `pending`
- ✅ `assigned_mitra_id`: `null`
- ✅ `is_scheduled_active`: `true`

**Detail**:
```
ID 48: Kamis, Campuran
ID 46: Rabu, B3  
ID 42: Rabu, B3
```

### Backend Claim:
- ✅ Endpoint sudah di-fix
- ✅ Return 33 schedules
- ✅ Support pagination & filter

---

## 🚫 BLOCKER

**❌ Password Mitra Tidak Berfungsi!**

```bash
# Login gagal
curl -X POST http://127.0.0.1:8000/api/login \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}'

# Result: "The provided credentials are incorrect."
```

**Impact**:
- ❌ Tidak bisa test endpoint mitra
- ❌ Tidak bisa verify jadwal muncul
- ❌ Feature 100% tidak berfungsi

---

## 🎯 Action Needed - URGENT

### 1. **Backend: Fix Password Mitra** (P0)

```bash
php artisan tinker

use Illuminate\Support\Facades\Hash;
DB::table('users')
  ->where('email', 'driver.jakarta@gerobaks.com')
  ->update(['password' => Hash::make('mitra123')]);
```

### 2. **Backend: Verify Query**

Pastikan endpoint `/api/mitra/pickup-schedules/available` tidak filter:
- ❌ JANGAN filter `work_area`
- ❌ JANGAN filter location/distance
- ✅ HANYA filter: `status='pending'` AND `assigned_mitra_id IS NULL`

### 3. **Test Setelah Fix**

```bash
# Login
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}' \
  | jq -r '.data.token')

# Get available
curl "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data.total'

# Expected: 33 (minimal 3 dari Aceng)
```

---

## ❓ Pertanyaan untuk Backend

1. Apakah jadwal Aceng (ID: 42, 46, 48) muncul dalam 33 schedules?
2. Apakah ada filter `work_area` di query?
3. Kenapa password mitra tidak bisa login?

---

## 📋 Test Credentials

```
User (WORKS ✅):
Email: aceng@gmail.com
Password: Password123

Mitra (BROKEN ❌):
Email: driver.jakarta@gerobaks.com
Password: mitra123
```

---

**Next Step**: Tunggu backend fix password, lalu test ulang

**Contact**: Frontend team ready to verify setelah fix
