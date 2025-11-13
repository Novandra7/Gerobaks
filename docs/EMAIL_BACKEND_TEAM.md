# Email/Chat Template untuk Backend Team

---

**Subject**: 🚨 URGENT - Mitra Password Tidak Berfungsi & Jadwal Tidak Muncul

---

Halo Tim Backend,

Kami testing integrasi sistem penjemputan mitra dan menemukan **2 masalah critical**:

## 🔴 Masalah 1: Password Mitra Tidak Bisa Login (BLOCKER)

**Credentials yang ditest**:
```
Email: driver.jakarta@gerobaks.com
Password: mitra123
```

**Error**:
```json
{
  "error": "validation_error",
  "message": "The given data was invalid.",
  "details": {
    "email": ["The provided credentials are incorrect."]
  }
}
```

**Impact**: Tidak bisa test endpoint mitra sama sekali!

**Request**: Tolong fix password ini segera via tinker:
```php
use Illuminate\Support\Facades\Hash;
DB::table('users')
  ->where('email', 'driver.jakarta@gerobaks.com')
  ->update(['password' => Hash::make('mitra123')]);
```

---

## 🔴 Masalah 2: Jadwal User Tidak Muncul di Mitra

**Situasi**:
- User Aceng sudah buat 3 jadwal pending (ID: 42, 46, 48)
- Jadwal sudah confirmed ada di database dengan status correct
- Backend claim endpoint available sudah return 33 schedules
- **TAPI** kami tidak bisa verify karena blocked by password issue

**Data Jadwal** (confirmed via user endpoint):
```
ID 48: status=pending, assigned_mitra_id=null, is_scheduled_active=true
ID 46: status=pending, assigned_mitra_id=null, is_scheduled_active=true
ID 42: status=pending, assigned_mitra_id=null, is_scheduled_active=true
```

**Pertanyaan**:

1. **Apakah 3 jadwal Aceng ini muncul dalam 33 schedules yang kalian return?**

2. **Apakah masih ada filter `work_area` di query?**
   - User Aceng alamatnya: "San Francisco"
   - Mitra work_area: "Jakarta Pusat"
   - Kalau ada filter work_area → tidak akan match!

3. **Bisa share actual query yang dipakai di `getAvailableSchedules()`?**

---

## ✅ Query yang Benar (Reference)

```php
public function getAvailableSchedules(Request $request)
{
    $perPage = $request->get('per_page', 20);
    
    $schedules = PickupSchedule::with(['user'])
        ->where('status', 'pending')
        ->whereNull('assigned_mitra_id')
        ->whereNull('deleted_at')
        ->where('is_scheduled_active', true)
        // ❌ JANGAN ada filter work_area!
        // ❌ JANGAN ada filter location/distance!
        ->orderBy('scheduled_pickup_at', 'asc')
        ->paginate($perPage);
    
    return response()->json([
        'success' => true,
        'data' => [
            'schedules' => $schedules->items(),
            'total' => $schedules->total(),
        ]
    ]);
}
```

---

## 🎯 Action Items

**Untuk Backend Team** (URGENT):

1. ✅ Fix password mitra (via tinker)
2. ✅ Verify 3 jadwal Aceng ada dalam 33 schedules
3. ✅ Remove filter `work_area` kalau masih ada
4. ✅ Share response sample dari endpoint available
5. ✅ Confirm kalau sudah ready untuk testing ulang

**Untuk Frontend Team**:

1. ⏳ Waiting untuk password fix
2. ⏳ Ready untuk test ulang setelah fix
3. ⏳ Will verify jadwal muncul di Flutter app

---

## 📊 Test Command (Setelah Password Fix)

Kalian bisa test sendiri dengan command ini:

```bash
# 1. Login
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}' \
  | jq -r '.data.token')

echo "Token: $TOKEN"

# 2. Get available schedules
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available?per_page=50" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '{
    total: .data.total,
    count: (.data.schedules | length),
    aceng_schedules: [.data.schedules[] | select(.user_id == 10) | {id, schedule_day, waste_type_scheduled}]
  }'

# Expected:
# - total: 33
# - aceng_schedules: [id: 42, 46, 48]
```

---

## 📎 Dokumentasi Lengkap

Lihat file berikut untuk detail lengkap:
- `docs/ISSUE_JADWAL_TIDAK_MUNCUL.md` (full analysis)
- `docs/QUICK_ISSUE_SUMMARY.md` (ringkasan)
- `docs/BACKEND_FIX_QUICK_REFERENCE.md` (panduan fix)

---

**Timeline**: Mohon konfirmasi secepatnya agar kami bisa lanjut testing 🙏

**Contact**: Frontend team standby untuk verify setelah fix

Terima kasih!

---

Tim Frontend
