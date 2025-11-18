# 🔧 Backend Fix Required: Schedule DateTime Display

## 📋 Ringkasan Masalah

Saat ini di aplikasi **Mitra**, data waktu penjemputan yang ditampilkan di card menunjukkan:
- ✅ **Hari dan tanggal** = BENAR (sudah dinamis)
- ❌ **Jam** = SALAH (masih hardcoded ke 06:00 - 08:00)

**Contoh Masalah:**
- User input jadwal: **Jumat, 14 Nov 2025, jam 10:28**
- Yang muncul di Mitra: **Jumat, 14 Nov 2025, 06:00 - 08:00** ❌
- Yang seharusnya: **Jumat, 14 Nov 2025, 10:28** ✅ (hanya jam mulai saja)

## 🎯 Contoh Kasus Detail

**Scenario 1:**
- User membuat jadwal: **Jumat, 14 November 2025, jam 10:28**
- Backend menyimpan dengan benar di field `scheduled_pickup_at`: `2025-11-14 10:28:00`
- Field `schedule_day` sudah benar: `"Jumat, 14 Nov 2025"` ✅
- Tetapi field `pickup_time_start` masih hardcoded: `"06:00"` ❌
- Field `pickup_time_end` **TIDAK DIGUNAKAN** (bisa dihapus atau diabaikan)

**Scenario 2:**
- User membuat jadwal: **Sabtu, 15 November 2025, jam 13:45**
- Backend menyimpan: `scheduled_pickup_at`: `2025-11-15 13:45:00`
- Field `schedule_day` sudah benar: `"Sabtu, 15 Nov 2025"` ✅
- Tetapi field `pickup_time_start` masih hardcoded: `"06:00"` ❌
- Field `pickup_time_end` **TIDAK DIGUNAKAN**

**Data Backend Saat Ini (❌ SEBAGIAN BENAR):**
```json
{
  "schedule_day": "Jumat, 14 Nov 2025",   // ✅ Sudah benar (dinamis)
  "pickup_time_start": "06:00",           // ❌ Hardcoded (HARUS DIUBAH!)
  "pickup_time_end": "08:00",             // ⚠️ TIDAK DIGUNAKAN (bisa dihapus)
  "scheduled_pickup_at": "2025-11-14 10:28:00"  // ✅ Benar (data user)
}
```

**Yang Seharusnya (✅ BENAR):**
```json
{
  "schedule_day": "Jumat, 14 Nov 2025",   // ✅ Tetap benar
  "pickup_time_start": "10:28",           // ✅ Dari scheduled_pickup_at (hanya jam mulai!)
  "pickup_time_end": "08:00",             // ⚠️ Boleh tetap ada atau dihapus (tidak dipakai)
  "scheduled_pickup_at": "2025-11-14 10:28:00"
}
```

**PENTING:** Frontend hanya akan menampilkan `pickup_time_start`, tidak menampilkan `pickup_time_end`!

---

## � URGENT: Status Masalah Saat Ini

### Yang Sudah Benar ✅
- `schedule_day` sudah dinamis dan menampilkan hari/tanggal yang benar
- Contoh: "Jumat, 14 Nov 2025", "Sabtu, 15 Nov 2025"
- **TIDAK PERLU DIUBAH**

### Yang Masih Salah ❌
- `pickup_time_start` **MASIH HARDCODED** ke `"06:00"` untuk semua jadwal
- **INI YANG HARUS DIPERBAIKI!**
- `pickup_time_end` **TIDAK PERLU DIUBAH** (tidak digunakan di frontend)

### Bukti dari Screenshot:
```
Card 1: Jumat, 14 Nov 2025
        06:00  ❌ Hardcoded! Seharusnya 10:28

Card 2: Sabtu, 15 Nov 2025  
        06:00  ❌ Hardcoded! Seharusnya sesuai jam user input
```

### Apa yang Harus Dilakukan:
Backend perlu mengubah HANYA 1 field ini:
1. `pickup_time_start` → Ambil jam dari `scheduled_pickup_at`
2. `pickup_time_end` → **TIDAK PERLU** (boleh tetap ada, tapi tidak dipakai frontend)

---

## �🛠️ Solusi yang Dibutuhkan

### **Endpoint yang Perlu Diperbaiki:**

1. **GET** `/api/mitra/pickup-schedules/available`
2. **GET** `/api/mitra/pickup-schedules/my-active`
3. **GET** `/api/mitra/pickup-schedules/history`

### **Field yang Perlu Diperbaiki:**

| Field | Status Saat Ini | Yang Perlu Diubah | Contoh |
|-------|----------------|-------------------|---------|
| `schedule_day` | ✅ Sudah benar (dinamis) | Tidak perlu diubah | `"Jumat, 14 Nov 2025"` |
| `pickup_time_start` | ❌ **HARDCODED "06:00"** | **HARUS DINAMIS dari `scheduled_pickup_at`** | User input 10:28 → `"10:28"` |
| `pickup_time_end` | ❌ **HARDCODED "08:00"** | **HARUS DINAMIS dari `scheduled_pickup_at + 2 jam`** | User input 10:28 → `"12:28"` |

**CRITICAL:** Yang harus diperbaiki hanya `pickup_time_start` dan `pickup_time_end`!

---

## 💻 Implementasi Laravel

### **1. Update Model/Resource Transformer**

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Carbon\Carbon;

class PickupScheduleResource extends JsonResource
{
    public function toArray($request)
    {
        // Parse scheduled_pickup_at
        $scheduledAt = Carbon::parse($this->scheduled_pickup_at);
        
        // Generate schedule_day (format: "Jumat, 15 Nov 2025")
        Carbon::setLocale('id'); // Set locale Indonesia
        $scheduleDay = $scheduledAt->isoFormat('dddd, DD MMM YYYY');
        
        // Generate pickup_time_start (format: "HH:MM")
        $pickupTimeStart = $scheduledAt->format('H:i');
        
        // Generate pickup_time_end - OPTIONAL (tidak digunakan di frontend)
        // Frontend HANYA menampilkan pickup_time_start
        // Anda bisa pilih salah satu:
        // OPTION 1: Tetap hardcoded (tidak masalah karena tidak ditampilkan)
        $pickupTimeEnd = '08:00';
        
        // OPTION 2: Atau tetap dynamic (tapi tidak digunakan)
        // $duration = $this->pickup_duration ?? 2; // default 2 jam
        // $pickupTimeEnd = $scheduledAt->copy()->addHours($duration)->format('H:i');
        
        // OPTION 3: Atau hapus field ini dari response

        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'user_name' => $this->user?->name ?? '',
            'user_phone' => $this->user?->phone ?? '',
            'pickup_address' => $this->pickup_address,
            'latitude' => (float) $this->latitude,
            'longitude' => (float) $this->longitude,
            
            // ✅ FIXED: Generate dari scheduled_pickup_at
            'schedule_day' => $scheduleDay,
            'pickup_time_start' => $pickupTimeStart,
            'pickup_time_end' => $pickupTimeEnd,
            
            'waste_type_scheduled' => $this->waste_type_scheduled,
            'user_waste_types' => $this->user_waste_types,
            'estimated_weights' => $this->estimated_weights,
            'scheduled_pickup_at' => $this->scheduled_pickup_at,
            'waste_summary' => $this->waste_summary,
            'notes' => $this->notes,
            'status' => $this->status,
            'created_at' => $this->created_at,
            'assigned_mitra_id' => $this->assigned_mitra_id,
            'assigned_at' => $this->assigned_at,
            'completed_at' => $this->completed_at,
            'actual_weights' => $this->actual_weights,
            'total_weight' => $this->total_weight,
            'pickup_photos' => $this->pickup_photos,
        ];
    }
}
```

### **2. Alternative: Update di Controller**

Jika tidak menggunakan Resource, update langsung di Controller:

```php
<?php

namespace App\Http\Controllers\Api\Mitra;

use Carbon\Carbon;

class PickupScheduleController extends Controller
{
    public function getAvailableSchedules(Request $request)
    {
        // ... existing query code ...
        
        $schedules = PickupSchedule::where('status', 'pending')
            ->whereNull('assigned_mitra_id')
            ->paginate(20);
        
        // Transform data
        $transformedSchedules = $schedules->map(function ($schedule) {
            $scheduledAt = Carbon::parse($schedule->scheduled_pickup_at);
            Carbon::setLocale('id'); // Set Indonesia locale
            
            // CATATAN: pickup_time_end tidak digunakan di frontend
            // Frontend hanya menampilkan pickup_time_start
            
            return [
                'id' => $schedule->id,
                'user_id' => $schedule->user_id,
                'user_name' => $schedule->user?->name ?? '',
                'user_phone' => $schedule->user?->phone ?? '',
                'pickup_address' => $schedule->pickup_address,
                'latitude' => (float) $schedule->latitude,
                'longitude' => (float) $schedule->longitude,
                
                // ✅ Generate dari scheduled_pickup_at
                'schedule_day' => $scheduledAt->isoFormat('dddd, DD MMM YYYY'),
                'pickup_time_start' => $scheduledAt->format('H:i'),
                'pickup_time_end' => '08:00',  // Optional: tidak digunakan di frontend
                
                'waste_type_scheduled' => $schedule->waste_type_scheduled,
                'user_waste_types' => $schedule->user_waste_types,
                'estimated_weights' => $schedule->estimated_weights,
                'scheduled_pickup_at' => $schedule->scheduled_pickup_at,
                'waste_summary' => $schedule->waste_summary,
                'notes' => $schedule->notes,
                'status' => $schedule->status,
                'created_at' => $schedule->created_at,
                // ... other fields
            ];
        });
        
        return response()->json([
            'success' => true,
            'message' => 'Available schedules retrieved successfully',
            'data' => [
                'schedules' => $transformedSchedules,
                'total' => $schedules->total(),
                'current_page' => $schedules->currentPage(),
                'last_page' => $schedules->lastPage(),
                'per_page' => $schedules->perPage(),
            ],
        ]);
    }
}
```

---

## 📝 Catatan Penting

### **1. Format Hari (schedule_day)**
- ✅ **SUDAH BENAR** - Tidak perlu diubah!
- Format saat ini sudah: `dddd, DD MMM YYYY` (Indonesia)
- Contoh yang sudah benar: `"Jumat, 14 Nov 2025"`, `"Sabtu, 15 Nov 2025"`

### **2. Format Waktu (pickup_time_start & pickup_time_end)**
- ❌ **MASALAH:** Saat ini `pickup_time_start` hardcoded ke `"06:00"`
- ✅ **SOLUSI:** Harus ambil dari `scheduled_pickup_at`
- Format: `H:i` (24-hour format tanpa detik)
- ⚠️ **CATATAN:** `pickup_time_end` **TIDAK DIGUNAKAN** di frontend, hanya `pickup_time_start` yang ditampilkan
- Contoh:
  - User input: `2025-11-14 10:28:00`
  - `pickup_time_start`: `"10:28"` ✅ (bukan `"06:00"`)
  - `pickup_time_end`: `"08:00"` ⚠️ (tidak digunakan, boleh tetap atau dihapus)
- **JANGAN** gunakan format `H:i:s` (dengan detik)
- **Frontend hanya menampilkan `pickup_time_start`**, tidak perlu `pickup_time_end`

### **3. Durasi Penjemputan (OPTIONAL)**
Field `pickup_time_end` tidak digunakan di frontend, jadi:
- **Bisa tetap hardcoded** (tidak masalah)
- **Bisa dihapus** dari response
- **Atau tetap dynamic** tapi tidak akan ditampilkan

Jika ingin tetap dynamic, gunakan default 2 jam atau tambahkan field di database:

```sql
-- OPTIONAL: Jika ingin dynamic pickup_time_end
ALTER TABLE pickup_schedules ADD COLUMN pickup_duration INT DEFAULT 2 COMMENT 'Durasi penjemputan dalam jam';
```

### **4. Timezone**
Pastikan menggunakan timezone yang konsisten (Indonesia):

```php
// Di config/app.php
'timezone' => 'Asia/Jakarta',

// Atau set di code
Carbon::setTimezone('Asia/Jakarta');
```

---

## ✅ Expected Output Setelah Fix

### **Scenario Real dari Screenshot:**

**User membuat jadwal:**
- Tanggal: Jumat, 14 Nov 2025
- Waktu: 10:28 pagi
- Backend save: `scheduled_pickup_at = 2025-11-14 10:28:00`

### **Request:**
```bash
GET /api/mitra/pickup-schedules/available?page=1
Authorization: Bearer {token}
```

### **Response yang Benar:**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 75,
        "user_id": 15,
        "user_name": "ali",
        "user_phone": "1234567890",
        "pickup_address": "1-99 Stockton St, Union Square, San Francisco",
        "latitude": 0,
        "longitude": 0,
        "schedule_day": "Jumat, 14 Nov 2025",  // ✅ Sudah benar
        "pickup_time_start": "10:28",          // ✅ HARUS DIPERBAIKI (saat ini "06:00")
        "pickup_time_end": "08:00",            // ⚠️ Tidak digunakan (boleh tetap/dihapus)
        "waste_type_scheduled": "Campuran",
        "scheduled_pickup_at": "2025-11-14 10:28:00",
        "waste_summary": "Campuran",
        "status": "pending",
        "created_at": "2025-11-13 17:49:37"
      }
    ],
    "total": 1,
    "current_page": 1,
    "last_page": 1,
    "per_page": 20
  }
}
```

### **Yang Ditampilkan di Mitra App:**
```
Card:
┌─────────────────────────────┐
│ Jumat, 14 Nov 2025          │  ← schedule_day (sudah benar)
│ 10:28                       │  ← pickup_time_start (HARUS DIPERBAIKI)
│                             │  ← pickup_time_end TIDAK DITAMPILKAN
│ ali - 1234567890            │
│ Stockton St, San Francisco  │
└─────────────────────────────┘
```
```

### **Tampilan di Mitra App Setelah Fix:**
```
Before ❌:
┌─────────────────────────────────┐
│  📅 Jumat, 14 Nov 2025          │ ✅ Sudah benar
│  🕐 06:00                       │ ❌ SALAH! Hardcoded
└─────────────────────────────────┘

After ✅:
┌─────────────────────────────────┐
│  📅 Jumat, 14 Nov 2025          │ ✅ Tetap benar
│  🕐 10:28                       │ ✅ BENAR! Sesuai input user
└─────────────────────────────────┘
```

---

## 🧪 Testing

### **Test Cases:**

1. **User Input Pagi (10:28)**
   - User membuat jadwal: Jumat, 14 Nov 2025, **jam 10:28**
   - `scheduled_pickup_at`: `2025-11-14 10:28:00`
   - Expected Output:
     - `schedule_day`: `"Jumat, 14 Nov 2025"` ✅ (sudah benar)
     - `pickup_time_start`: `"10:28"` ✅ (harus diperbaiki dari "06:00")
     - `pickup_time_end`: `"08:00"` ⚠️ (tidak digunakan, boleh tetap/dihapus)
   - **Yang ditampilkan di app:** "Jumat, 14 Nov 2025" dan "10:28"

2. **User Input Siang (13:45)**
   - User membuat jadwal: Sabtu, 15 Nov 2025, **jam 13:45**
   - `scheduled_pickup_at`: `2025-11-15 13:45:00`
   - Expected Output:
     - `schedule_day`: `"Sabtu, 15 Nov 2025"`
     - `pickup_time_start`: `"13:45"` (bukan "06:00")
     - `pickup_time_end`: (tidak digunakan)
   - **Yang ditampilkan di app:** "Sabtu, 15 Nov 2025" dan "13:45"

3. **User Input Sore (16:30)**
   - User membuat jadwal: Minggu, 16 Nov 2025, **jam 16:30**
   - `scheduled_pickup_at`: `2025-11-16 16:30:00`
   - Expected Output:
     - `schedule_day`: `"Minggu, 16 Nov 2025"`
     - `pickup_time_start`: `"16:30"` (bukan "06:00")
     - `pickup_time_end`: (tidak digunakan)
   - **Yang ditampilkan di app:** "Minggu, 16 Nov 2025" dan "16:30"

### **SQL Query untuk Testing:**
```sql
-- Cek data scheduled_pickup_at yang ada
SELECT 
    id, 
    user_id, 
    scheduled_pickup_at,
    DATE_FORMAT(scheduled_pickup_at, '%W, %d %b %Y') as formatted_day,
    DATE_FORMAT(scheduled_pickup_at, '%H:%i') as start_time
FROM pickup_schedules
WHERE status = 'pending'
LIMIT 10;
```

**CATATAN:** Query di atas hanya menampilkan `start_time` karena `pickup_time_end` tidak digunakan.

---

## 🚀 Priority

**HIGH PRIORITY** - Mempengaruhi user experience di aplikasi Mitra

---

## 📞 Contact

Jika ada pertanyaan atau butuh klarifikasi, silakan hubungi:
- Frontend Developer (Flutter)
- Backend Developer (Laravel)

---

**Dokumentasi ini dibuat:** 14 November 2025  
**Untuk:** Tim Backend Laravel  
**Status:** Menunggu Implementasi
