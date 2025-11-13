# 🚀 Quick Reference: Mitra Pickup API

> **TL;DR:** User buat jadwal → Mitra accept → Status auto-update ke User → Mitra complete → User dapat poin

---

## 📌 API Endpoints Summary

| Method | Endpoint | Fungsi | Priority |
|--------|----------|--------|----------|
| **GET** | `/api/mitra/pickup-schedules/available` | List jadwal PENDING | 🔴 HIGH |
| **GET** | `/api/mitra/pickup-schedules/{id}` | Detail jadwal (nama, telpon, alamat) | 🔴 HIGH |
| **POST** | `/api/mitra/pickup-schedules/{id}/accept` | Mitra terima jadwal | 🔴 HIGH |
| **POST** | `/api/mitra/pickup-schedules/{id}/complete` | Upload foto + berat sampah | 🔴 HIGH |
| **POST** | `/api/mitra/pickup-schedules/{id}/cancel` | Batalkan jadwal | 🟡 MEDIUM |
| **GET** | `/api/mitra/pickup-schedules/my-active` | Jadwal aktif mitra | 🟡 MEDIUM |
| **GET** | `/api/mitra/pickup-schedules/history` | Riwayat completed | 🟢 LOW |

---

## 🗄️ Database Changes Needed

```sql
-- ALTER TABLE pickup_schedules
ALTER TABLE pickup_schedules 
ADD COLUMN assigned_mitra_id BIGINT UNSIGNED NULL,
ADD COLUMN assigned_at DATETIME NULL,
ADD COLUMN on_the_way_at DATETIME NULL,
ADD COLUMN picked_up_at DATETIME NULL,
ADD COLUMN completed_at DATETIME NULL,
ADD COLUMN actual_weights JSON NULL,
ADD COLUMN total_weight DECIMAL(8,2) NULL,
ADD COLUMN pickup_photos JSON NULL,
ADD COLUMN cancelled_at DATETIME NULL,
ADD COLUMN cancellation_reason TEXT NULL,
ADD FOREIGN KEY (assigned_mitra_id) REFERENCES users(id) ON DELETE SET NULL,
ADD INDEX idx_assigned_mitra (assigned_mitra_id),
ADD INDEX idx_status_mitra (status, assigned_mitra_id);
```

---

## 📋 Status Flow

```
[USER creates schedule]
       ↓
   PENDING ← (visible to all mitra)
       ↓
[MITRA accepts]
       ↓
 ON_PROGRESS ← (auto-update ke user, notifikasi terkirim)
       ↓
[MITRA completes with photo + weight]
       ↓
  COMPLETED ← (user dapat poin, notifikasi)
```

---

## 🔥 Critical Implementation Points

### 1. Accept Schedule - `POST /api/mitra/pickup-schedules/{id}/accept`

**What happens:**
```php
DB::transaction(function() {
    // 1. Update schedule
    $schedule->update([
        'assigned_mitra_id' => $mitra->id,
        'status' => 'on_progress',
        'assigned_at' => now()
    ]);
    
    // 2. Send notification to USER
    $schedule->user->notify(new MitraAssigned($schedule, $mitra));
    
    // 3. Broadcast realtime (optional)
    broadcast(new PickupStatusUpdated($schedule));
});
```

**Validasi:**
- Status harus `pending`
- `assigned_mitra_id` harus NULL
- Prevent double-accept (race condition)

---

### 2. Complete Pickup - `POST /api/mitra/pickup-schedules/{id}/complete`

**Request (multipart/form-data):**
```
actual_weights[Organik]    = 3.5
actual_weights[Anorganik]  = 2.0
actual_weights[B3]         = 1.2
photos[]                   = file1.jpg
photos[]                   = file2.jpg
notes                      = "Selesai tepat waktu"
```

**What happens:**
```php
DB::transaction(function() {
    // 1. Calculate total weight
    $totalWeight = array_sum($request->actual_weights);
    
    // 2. Upload photos
    $photoUrls = [];
    foreach ($request->file('photos') as $photo) {
        $path = $photo->store("pickups/{$schedule->id}", 'public');
        $photoUrls[] = Storage::url($path);
    }
    
    // 3. Update schedule
    $schedule->update([
        'status' => 'completed',
        'completed_at' => now(),
        'actual_weights' => $request->actual_weights,
        'total_weight' => $totalWeight,
        'pickup_photos' => $photoUrls
    ]);
    
    // 4. Add points to user (1 kg = 10 points)
    $points = (int)($totalWeight * 10);
    $schedule->user->increment('points', $points);
    
    // 5. Notify user
    $schedule->user->notify(new PickupCompleted($schedule, $points));
    
    // 6. Update mitra stats
    $mitra->increment('total_collections');
});
```

**Validasi:**
- Status harus `on_progress`
- Mitra harus yang assigned
- Minimal 1 foto wajib
- Berat harus > 0

---

## 📱 Response Format Examples

### Available Schedules
```json
{
  "success": true,
  "data": {
    "schedules": [
      {
        "id": 36,
        "user_name": "Ali",
        "user_phone": "081234567890",
        "pickup_address": "Jl. Sudirman No. 123, Jakarta",
        "latitude": -6.208763,
        "longitude": 106.845599,
        "waste_type_scheduled": "B3",
        "scheduled_pickup_at": "2025-11-13 06:00:00",
        "status": "pending"
      }
    ]
  }
}
```

### Schedule Detail
```json
{
  "success": true,
  "data": {
    "schedule": {
      "id": 36,
      "user": {
        "id": 15,
        "name": "Ali",
        "phone": "081234567890",
        "address": "Jl. Sudirman No. 123, Jakarta Pusat"
      },
      "pickup_address": "Jl. Sudirman No. 123",
      "latitude": -6.208763,
      "longitude": 106.845599,
      "waste_type_scheduled": "B3",
      "notes": "Sampah sudah dipilah"
    }
  }
}
```

---

## 🔔 Notification Events

### Send to User:

```php
// When mitra accepts
$user->notify(new MitraAssigned($schedule, $mitra));
// Message: "Mitra John Doe menerima jadwal Anda!"

// When completed
$user->notify(new PickupCompleted($schedule, $points));
// Message: "Pengambilan selesai! Anda mendapat +67 poin"

// When cancelled by mitra
$user->notify(new PickupCancelled($schedule, $reason));
// Message: "Jadwal dibatalkan: {reason}"
```

### Send to Mitra:

```php
// When user creates new schedule (optional)
$mitras->each->notify(new NewScheduleAvailable($schedule));
// Message: "Jadwal baru tersedia di area Anda"
```

---

## 🧪 Testing Commands

```bash
# 1. Get available schedules (as Mitra)
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Accept: application/json"

# 2. Get schedule detail
curl -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/36" \
  -H "Authorization: Bearer {mitra_token}"

# 3. Accept schedule
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/accept" \
  -H "Authorization: Bearer {mitra_token}" \
  -H "Content-Type: application/json" \
  -d '{}'

# 4. Complete pickup (with photos)
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/36/complete" \
  -H "Authorization: Bearer {mitra_token}" \
  -F "actual_weights[Organik]=3.5" \
  -F "actual_weights[Anorganik]=2.0" \
  -F "actual_weights[B3]=1.2" \
  -F "photos[]=@photo1.jpg" \
  -F "photos[]=@photo2.jpg" \
  -F "notes=Selesai"

# 5. Check user's points after completion (as User)
curl -X GET "http://127.0.0.1:8000/api/user/profile" \
  -H "Authorization: Bearer {user_token}"
```

---

## ✅ Quick Checklist

**Backend Team:**
- [ ] Run migration untuk tambah kolom di `pickup_schedules`
- [ ] Buat `MitraPickupController.php`
- [ ] Add routes di `routes/api.php`
- [ ] Implement notification classes
- [ ] Test accept schedule
- [ ] Test complete pickup (dengan foto upload)
- [ ] Verify user points bertambah otomatis
- [ ] Test cancel schedule

**Flutter Team (Mitra App):**
- [ ] Screen: Jadwal Tersedia (list pending)
- [ ] Screen: Detail Jadwal (map, user info)
- [ ] Screen: Jadwal Aktif (my on_progress)
- [ ] Form: Complete Pickup (input berat, upload foto)
- [ ] Screen: Riwayat (history completed)

**Flutter Team (User App):**
- [ ] Auto-refresh status saat mitra accept
- [ ] Notifikasi saat status berubah
- [ ] Display mitra info (nama, telpon, kendaraan)
- [ ] Display points yang bertambah

---

## 🎯 Priority Order

**Week 1 (URGENT):**
1. Database migration
2. API available schedules
3. API accept schedule
4. API complete pickup
5. Auto-update points

**Week 2:**
6. Notification system integration
7. Cancel feature
8. History API

**Week 3 (Optional):**
9. Realtime location tracking
10. ETA calculation
11. Rating system

---

**Dokumentasi lengkap:** `docs/MITRA_PICKUP_SYSTEM.md`  
**Status:** 🔴 URGENT - Core Feature  
**Contact:** Flutter Team ready to integrate
