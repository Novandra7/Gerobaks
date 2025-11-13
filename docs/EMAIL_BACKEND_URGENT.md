# 📧 Email ke Backend Team

---

**Subject:** 🚨 URGENT: Bug Critical di Endpoint Available Schedules

---

Hi Backend Team,

Saya menemukan **bug critical** di endpoint `/api/mitra/pickup-schedules/available` yang membuat sistem penjemputan mitra **tidak bisa digunakan**.

## ❌ Masalah

Endpoint **HANYA mengembalikan jadwal dari 1 user** (User Daffa, ID: 2), padahal di database ada **33 jadwal pending dari berbagai user**.

**Contoh:** User Aceng (ID: 10) punya 4 jadwal pending tapi **TIDAK MUNCUL** di hasil API.

## 🔍 Cara Reproduce

```bash
# Login mitra
curl -X POST http://127.0.0.1:8000/api/login \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}'

# Cek available - HANYA USER DAFFA YANG MUNCUL
curl -X GET http://127.0.0.1:8000/api/mitra/pickup-schedules/available \
  -H "Authorization: Bearer [TOKEN]"
```

## 💡 Kemungkinan Penyebab

Sepertinya ada **filter by work_area** di controller:

```php
->where('work_area', $mitra->work_area) // Jakarta Pusat
// Problem: User di San Francisco tidak muncul!
```

## ✅ Yang Perlu Dilakukan

**1. Cek dengan tinker (5 menit):**
```bash
php artisan tinker
```

```php
// Cek tanpa filter work_area
$all = PickupSchedule::where('status', 'pending')
    ->whereNull('assigned_mitra_id')
    ->where('is_scheduled_active', true)
    ->get();

echo "Total: " . $all->count() . "\n";
echo "User IDs: " . $all->pluck('user_id')->unique()->implode(', ') . "\n";
```

**2. Fix di controller (10 menit):**

File: `app/Http/Controllers/Api/MitraPickupScheduleController.php`

```php
public function getAvailableSchedules(Request $request)
{
    // HAPUS filter work_area!
    $schedules = PickupSchedule::with(['user', 'wasteType'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->where('is_scheduled_active', true)
        ->whereNull('deleted_at')
        ->orderBy('created_at', 'desc')
        ->paginate(20);
    
    return response()->json([...]);
}
```

**3. Test (5 menit):**
```bash
# Harusnya return berbagai user_id, bukan cuma [2]
curl -X GET http://127.0.0.1:8000/api/mitra/pickup-schedules/available \
  -H "Authorization: Bearer [TOKEN]" | jq '[.data.schedules[].user_id] | unique'
```

## 📊 Expected Result

**Sebelum fix:**
```json
{"schedules": [
  {"user_id": 2}, {"user_id": 2}, {"user_id": 2}
  // Semua user yang sama
]}
```

**Setelah fix:**
```json
{"schedules": [
  {"user_id": 10}, {"user_id": 10}, {"user_id": 2}, {"user_id": 2}
  // Berbagai user
]}
```

## ⏰ Timeline

**Priority:** 🔴 CRITICAL BLOCKER  
**Impact:** Sistem tidak bisa production  
**Expected fix:** 1-2 jam

## 📎 Dokumentasi Lengkap

Detail teknis ada di:
- `docs/CRITICAL_BACKEND_ISSUE.md` (lengkap + bahasa Inggris)
- `docs/LAPORAN_BACKEND_URGENT.md` (ringkas + bahasa Indonesia)

## 🙋 Questions?

Saya siap bantu test setelah fix! 

Thanks,  
Frontend Team

---

**Test Credentials:**
```
Mitra:
Email: driver.jakarta@gerobaks.com
Password: password123

User:
Email: aceng@gmail.com
Password: Password123
```
