# 🧪 Testing Guide: Activity & Schedule API

> **Quick testing guide untuk backend dan frontend developer**

---

## 📋 Prerequisites

1. Backend sudah implement API dari `BACKEND_API_ACTIVITY_SCHEDULES.md`
2. User sudah login dan punya token
3. Database sudah ada tabel `waste_schedules`

---

## 🎯 Test Scenarios

### Scenario 1: Create Test Data (via Tinker)

```bash
cd /path/to/laravel/project
php artisan tinker
```

**Paste code ini:**

```php
// Ambil user pertama yang aktif
$user = \App\Models\User::where('role', 'end_user')->where('status', 'active')->first();

if (!$user) {
    echo "⚠️ No end_user found! Please create a user first.\n";
    exit;
}

echo "Creating schedules for user: {$user->name} (ID: {$user->id})\n\n";

// 1. Pending schedule (Aktif)
\App\Models\WasteSchedule::create([
    'user_id' => $user->id,
    'service_type' => 'Pengambilan Sampah Organik',
    'waste_type' => 'Organik',
    'pickup_address' => 'Jl. Sudirman No. 123, Jakarta Pusat',
    'pickup_latitude' => -6.208763,
    'pickup_longitude' => 106.845599,
    'scheduled_at' => now()->addDays(2)->setTime(8, 0, 0),
    'status' => 'pending',
    'notes' => 'Sampah sudah dipilah. Mohon diambil tepat waktu.',
    'estimated_weight' => 5.5,
]);

// 2. In Progress schedule (Aktif - Mitra sedang OTW)
\App\Models\WasteSchedule::create([
    'user_id' => $user->id,
    'service_type' => 'Pengambilan Sampah Anorganik',
    'waste_type' => 'Anorganik',
    'pickup_address' => 'Jl. Thamrin No. 45, Jakarta Pusat',
    'pickup_latitude' => -6.195500,
    'pickup_longitude' => 106.822800,
    'scheduled_at' => now()->setTime(9, 0, 0),
    'status' => 'in_progress',
    'notes' => 'Botol plastik dan kertas karton',
    'estimated_weight' => 3.2,
    'accepted_at' => now()->subMinutes(30),
    'started_at' => now()->subMinutes(15),
]);

// 3. Completed schedule (Riwayat - Selesai)
\App\Models\WasteSchedule::create([
    'user_id' => $user->id,
    'service_type' => 'Pengambilan Sampah Organik',
    'waste_type' => 'Organik',
    'pickup_address' => 'Jl. Gatot Subroto No. 78, Jakarta Selatan',
    'pickup_latitude' => -6.225014,
    'pickup_longitude' => 106.808331,
    'scheduled_at' => now()->subDays(3)->setTime(8, 0, 0),
    'status' => 'completed',
    'notes' => 'Terima kasih sudah membantu!',
    'estimated_weight' => 4.0,
    'actual_weight' => 4.3,
    'accepted_at' => now()->subDays(3)->setTime(7, 45, 0),
    'started_at' => now()->subDays(3)->setTime(8, 0, 0),
    'completed_at' => now()->subDays(3)->setTime(8, 45, 0),
]);

// 4. Completed schedule (Riwayat - Kemarin)
\App\Models\WasteSchedule::create([
    'user_id' => $user->id,
    'service_type' => 'Pengambilan Sampah Anorganik',
    'waste_type' => 'Anorganik',
    'pickup_address' => 'Jl. MH Thamrin No. 10, Jakarta Pusat',
    'pickup_latitude' => -6.192600,
    'pickup_longitude' => 106.823000,
    'scheduled_at' => now()->subDay()->setTime(10, 0, 0),
    'status' => 'completed',
    'notes' => 'Plastik dan kardus',
    'estimated_weight' => 2.5,
    'actual_weight' => 2.8,
    'accepted_at' => now()->subDay()->setTime(9, 50, 0),
    'started_at' => now()->subDay()->setTime(10, 0, 0),
    'completed_at' => now()->subDay()->setTime(10, 30, 0),
]);

// 5. Cancelled schedule (Riwayat - Dibatalkan)
\App\Models\WasteSchedule::create([
    'user_id' => $user->id,
    'service_type' => 'Pengambilan Sampah B3',
    'waste_type' => 'B3',
    'pickup_address' => 'Jl. HR Rasuna Said, Jakarta Selatan',
    'pickup_latitude' => -6.224300,
    'pickup_longitude' => 106.831000,
    'scheduled_at' => now()->subDays(5)->setTime(7, 30, 0),
    'status' => 'cancelled',
    'notes' => 'Baterai dan limbah elektronik',
    'estimated_weight' => 1.0,
    'cancelled_at' => now()->subDays(5)->setTime(6, 0, 0),
    'cancellation_reason' => 'Ada perubahan rencana mendadak',
]);

// 6. Pending schedule (Aktif - Besok)
\App\Models\WasteSchedule::create([
    'user_id' => $user->id,
    'service_type' => 'Pengambilan Sampah Elektronik',
    'waste_type' => 'Elektronik',
    'pickup_address' => 'Jl. Kuningan, Jakarta Selatan',
    'pickup_latitude' => -6.238900,
    'pickup_longitude' => 106.830700,
    'scheduled_at' => now()->addDay()->setTime(14, 0, 0),
    'status' => 'pending',
    'notes' => 'Barang elektronik rusak',
    'estimated_weight' => 8.0,
]);

// Verify
$total = \App\Models\WasteSchedule::where('user_id', $user->id)->count();
$active = \App\Models\WasteSchedule::where('user_id', $user->id)
    ->whereIn('status', ['pending', 'in_progress'])->count();
$history = \App\Models\WasteSchedule::where('user_id', $user->id)
    ->whereIn('status', ['completed', 'cancelled'])->count();

echo "\n✅ Created 6 test schedules!\n";
echo "Total: $total\n";
echo "Active: $active\n";
echo "History: $history\n";
echo "\nUser ID: {$user->id}\n";
echo "Email: {$user->email}\n";
```

---

## 🔧 Test API Endpoints

### 1. Get All Schedules

```bash
# Save token to variable
TOKEN="YOUR_TOKEN_HERE"

# Get all schedules
curl -X GET "http://127.0.0.1:8000/api/schedules" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq
```

**Expected Result:**
```json
{
  "success": true,
  "message": "Schedules retrieved successfully",
  "data": {
    "schedules": [...],  // Array of 6 schedules
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 6,
      ...
    },
    "summary": {
      "total_schedules": 6,
      "active_count": 3,
      "completed_count": 2,
      "cancelled_count": 1
    }
  }
}
```

### 2. Filter by Status (Active Only)

```bash
curl -X GET "http://127.0.0.1:8000/api/schedules?status=pending" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq
```

**Expected:** Hanya schedule dengan status `pending` (2 items)

### 3. Filter by Date

```bash
# Get today's schedules
TODAY=$(date +%Y-%m-%d)
curl -X GET "http://127.0.0.1:8000/api/schedules?date=$TODAY" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq
```

**Expected:** Hanya schedule hari ini (1 item dengan status in_progress)

### 4. Create New Schedule

```bash
# Schedule untuk 3 hari dari sekarang
FUTURE_DATE=$(date -v+3d +"%Y-%m-%d 08:00:00" 2>/dev/null || date -d "+3 days" +"%Y-%m-%d 08:00:00")

curl -X POST "http://127.0.0.1:8000/api/schedules" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{
    \"service_type\": \"Pengambilan Sampah Organik\",
    \"waste_type\": \"Organik\",
    \"pickup_address\": \"Jl. Test No. 999, Jakarta\",
    \"pickup_latitude\": -6.200000,
    \"pickup_longitude\": 106.800000,
    \"scheduled_at\": \"$FUTURE_DATE\",
    \"notes\": \"Test dari API\",
    \"estimated_weight\": 3.5
  }" | jq
```

**Expected:** Response 201 Created dengan data schedule baru

### 5. Get Schedule Detail

```bash
# Get detail schedule ID 1
curl -X GET "http://127.0.0.1:8000/api/schedules/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" | jq
```

**Expected:** Detail lengkap schedule dengan ID 1

### 6. Cancel Schedule

```bash
# Cancel schedule ID 1 (harus status pending/in_progress)
curl -X POST "http://127.0.0.1:8000/api/schedules/1/cancel" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "reason": "Test pembatalan dari API"
  }' | jq
```

**Expected:** Response 200 OK, status berubah menjadi `cancelled`

---

## 📱 Test di Flutter App

### Step 1: Login ke App

1. Buka Flutter app
2. Login dengan email user yang dibuat di tinker
3. Pastikan dapat token dan tersimpan

### Step 2: Buka Activity Page

1. Tap menu "Aktivitas" di bottom navigation
2. App akan otomatis fetch schedules dari API

### Step 3: Verify Data

**Tab "Aktif" harus menampilkan:**
- ✅ 3 schedules (2 pending + 1 in_progress)
- ✅ Card dengan status "Dijadwalkan" (hijau)
- ✅ Card dengan status "Menuju Lokasi" (biru)
- ✅ Alamat lengkap
- ✅ Tanggal & waktu yang benar
- ✅ Notes jika ada

**Tab "Riwayat" harus menampilkan:**
- ✅ 3 schedules (2 completed + 1 cancelled)
- ✅ Card dengan status "Selesai" (hijau gelap)
- ✅ Card dengan status "Dibatalkan" (merah)
- ✅ Timestamp completed_at atau cancelled_at

### Step 4: Test Filters

**Filter by Date:**
1. Tap icon calendar di AppBar
2. Pilih tanggal hari ini
3. Hanya 1 schedule yang muncul (in_progress)

**Filter by Category:**
1. Tap icon filter di AppBar
2. Pilih "Menuju Lokasi"
3. Hanya schedule dengan status in_progress yang muncul

**Reset Filters:**
1. Tap chip filter atau button "Reset"
2. Semua schedule muncul kembali

### Step 5: Test Pull to Refresh

1. Swipe down di list
2. Loading indicator muncul
3. Data refresh dari API

---

## 🐛 Troubleshooting

### Problem 1: "No schedules found"

**Cause:** User ID tidak cocok atau data belum dibuat

**Solution:**
```bash
# Check user ID di app (lihat log Flutter)
# Check schedules di database
php artisan tinker
>>> \App\Models\WasteSchedule::where('user_id', 14)->count();
```

### Problem 2: "401 Unauthorized"

**Cause:** Token expired atau invalid

**Solution:**
1. Logout dari app
2. Login ulang untuk dapat token baru
3. Test API dengan token baru

### Problem 3: "Empty response"

**Cause:** Backend endpoint belum dibuat

**Solution:**
1. Verify route terdaftar: `php artisan route:list | grep schedules`
2. Check controller sudah dibuat
3. Test endpoint manual dengan curl

### Problem 4: "Status not filtering"

**Cause:** Query parameter tidak ter-handle di backend

**Solution:**
```php
// Di ScheduleController.php, pastikan ada:
if ($request->has('status')) {
    $query->where('status', $request->status);
}
```

---

## ✅ Expected Results Summary

### API Responses:

| Endpoint | Status | Active | History |
|----------|--------|--------|---------|
| `GET /api/schedules` | 200 | 3 items | 3 items |
| `GET /api/schedules?status=pending` | 200 | 2 items | - |
| `GET /api/schedules?status=in_progress` | 200 | 1 item | - |
| `GET /api/schedules?status=completed` | 200 | - | 2 items |
| `GET /api/schedules?status=cancelled` | 200 | - | 1 item |
| `POST /api/schedules` | 201 | New schedule created | - |
| `POST /api/schedules/1/cancel` | 200 | Status → cancelled | Moved to history |

### Flutter App:

| Feature | Expected Behavior |
|---------|------------------|
| Tab "Aktif" | Shows 3 active schedules (pending + in_progress) |
| Tab "Riwayat" | Shows 3 history schedules (completed + cancelled) |
| Date Filter | Filters by selected date |
| Category Filter | Filters by status category |
| Pull to Refresh | Reloads data from API |
| Empty State | Shows when no data matches filter |
| Loading State | Shows skeleton while fetching |

---

## 🎉 Success Criteria

- [x] Backend API returns schedules correctly
- [x] Flutter app displays active schedules in "Aktif" tab
- [x] Flutter app displays history schedules in "Riwayat" tab
- [x] Date filter works (calendar icon)
- [x] Category filter works (filter icon)
- [x] Pull to refresh works
- [x] Empty states display correctly
- [x] Status badges show correct colors
- [x] Can create new schedule via API
- [x] Can cancel schedule via API

---

**Jika semua test passed, Activity Page sudah 100% terintegrasi dengan backend!** ✨
