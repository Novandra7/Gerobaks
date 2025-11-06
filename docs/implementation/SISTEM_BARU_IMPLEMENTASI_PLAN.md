# 🚀 Rencana Implementasi Sistem Baru Gerobaks

**Tanggal**: 20 Oktober 2025  
**Status**: DRAFT - Ready for Implementation  
**Tujuan**: Menghapus Google Maps, Refactor Schedule System dengan Multi-Waste Selection

---

## 📋 Ringkasan Perubahan

### 1. **Hapus Google Maps Integration** ❌

- Hapus `google_maps_flutter` dependency
- Hapus semua file yang menggunakan GoogleMap widget
- Ganti dengan sistem address string + external navigation

### 2. **Refactor Schedule System** 🔄

- Tambah multiple waste selection (sampah tambahan)
- Tambah estimasi berat per jenis sampah
- Implementasi BLoC pattern lengkap
- Update database schema

### 3. **Backend Migration** 🗄️

- Buat migration file untuk field database baru
- Update API endpoints untuk multiple waste items
- Adjust response format

---

## 🎯 Phase 1: Hapus Google Maps (Priority: HIGH)

### Files to Delete/Modify:

#### Files to DELETE:

```
lib/ui/pages/mitra/pengambilan/pengambilan_page.dart
lib/ui/pages/mitra/pengambilan/pengambilan_page_improved.dart
lib/ui/pages/mitra/jadwal/jadwal_mitra_page_map_view.dart
lib/ui/widgets/shared/map_picker_fixed.dart
```

#### Files to MODIFY (Remove Google Maps):

```
lib/ui/pages/mitra/pengambilan/navigation_page_redesigned.dart
  - Remove google_maps_flutter import
  - Keep only external navigation (url_launcher)

lib/ui/pages/mitra/pengambilan/detail_pickup.dart
  - Keep _openGoogleMaps() but make it external only

lib/ui/pages/mitra/jadwal/jadwal_mitra_page.dart
  - Remove _openMapView() method

lib/ui/pages/mitra/jadwal/jadwal_mitra_page_new.dart
  - Remove _openMapView() method

lib/ui/pages/mitra/jadwal/jadwal_detail_page.dart
  - Keep external navigation only

lib/utils/map_utils.dart
  - Remove openMapView() method
  - Keep launchMapsUrl() for external navigation
```

#### pubspec.yaml:

```yaml
# REMOVE:
google_maps_flutter: ^2.2.0

# KEEP:
url_launcher: ^6.1.10 # For external navigation
geolocator: ^9.0.2 # For GPS location
```

---

## 🎯 Phase 2: Database Schema Update

### New Database Fields (schedules table):

```sql
-- Migration file: database/migrations/2025_10_20_add_multiple_waste_to_schedules.php

ALTER TABLE schedules ADD COLUMN waste_items JSON NULL AFTER address;
ALTER TABLE schedules ADD COLUMN total_estimated_weight DECIMAL(8,2) DEFAULT 0.00 AFTER waste_items;

-- waste_items format:
-- [
--   {
--     "waste_type": "organik",
--     "estimated_weight": 5.5,
--     "unit": "kg"
--   },
--   {
--     "waste_type": "plastik",
--     "estimated_weight": 2.0,
--     "unit": "kg"
--   }
-- ]
```

### Backend API Update:

#### Endpoint: POST /api/schedules

```json
{
  "user_id": 1,
  "date": "2025-10-25",
  "time": "10:00",
  "address": "Jl. Contoh No. 123",
  "latitude": -6.2,
  "longitude": 106.816666,
  "waste_items": [
    {
      "waste_type": "organik",
      "estimated_weight": 5.5,
      "unit": "kg"
    },
    {
      "waste_type": "plastik",
      "estimated_weight": 2.0,
      "unit": "kg"
    },
    {
      "waste_type": "kertas",
      "estimated_weight": 1.5,
      "unit": "kg"
    }
  ],
  "notes": "Sampah di depan rumah"
}
```

---

## 🎯 Phase 3: Frontend Model Update

### New Schedule Model:

```dart
// lib/models/waste_item.dart
class WasteItem {
  final String wasteType;
  final double estimatedWeight;
  final String unit;

  WasteItem({
    required this.wasteType,
    required this.estimatedWeight,
    this.unit = 'kg',
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      wasteType: json['waste_type'],
      estimatedWeight: (json['estimated_weight'] as num).toDouble(),
      unit: json['unit'] ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waste_type': wasteType,
      'estimated_weight': estimatedWeight,
      'unit': unit,
    };
  }
}

// lib/models/schedule_model.dart - ADD:
final List<WasteItem> wasteItems;
final double totalEstimatedWeight;
```

---

## 🎯 Phase 4: BLoC Implementation

### New Events:

```dart
// lib/blocs/schedule/schedule_event.dart

class ScheduleCreate extends ScheduleEvent {
  final String date;
  final String time;
  final String address;
  final double latitude;
  final double longitude;
  final List<WasteItem> wasteItems;
  final String? notes;

  ScheduleCreate({
    required this.date,
    required this.time,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.wasteItems,
    this.notes,
  });
}

class ScheduleAddWasteItem extends ScheduleEvent {
  final WasteItem wasteItem;
  ScheduleAddWasteItem(this.wasteItem);
}

class ScheduleRemoveWasteItem extends ScheduleEvent {
  final int index;
  ScheduleRemoveWasteItem(this.index);
}

class ScheduleUpdateWasteItem extends ScheduleEvent {
  final int index;
  final WasteItem wasteItem;
  ScheduleUpdateWasteItem(this.index, this.wasteItem);
}
```

---

## 🎯 Phase 5: UI Implementation - Add Schedule Page

### Features:

1. **Date & Time Picker** ✅
2. **Address Input** (String only, no map)
3. **Multiple Waste Selection** (Pill Buttons)
4. **Weight Input per Waste Type**
5. **Dynamic List Management**

### Waste Types (Pill Buttons):

```
- Organik (🍃)
- Plastik (♻️)
- Kertas (📄)
- Kaleng (🥫)
- Botol Kaca (🍾)
- Elektronik (📱)
- Lainnya (📦)
```

### UI Flow:

```
1. Pilih Tanggal & Waktu
2. Input Alamat (Text Field)
3. Pilih Jenis Sampah (Pill Buttons - Multiple)
4. Input Estimasi Berat (TextField per sampah)
5. Review Selected Waste Items (List Cards)
6. Notes (Optional)
7. Submit Button
```

---

## 📁 File Structure Plan

```
lib/
├── blocs/
│   └── schedule/
│       ├── schedule_bloc.dart         # UPDATED
│       ├── schedule_event.dart        # NEW EVENTS
│       └── schedule_state.dart        # NEW STATES
├── models/
│   ├── waste_item.dart                # NEW MODEL
│   └── schedule_model.dart            # UPDATED
├── services/
│   └── schedule_service.dart          # UPDATED API
└── ui/
    └── pages/
        └── user/
            └── schedule/
                ├── add_schedule_page.dart          # NEW - Main form
                ├── widgets/
                │   ├── waste_type_selector.dart    # NEW - Pill buttons
                │   ├── waste_item_card.dart        # NEW - Selected item
                │   └── weight_input_dialog.dart    # NEW - Weight input
                └── schedule_list_page.dart         # UPDATED - Show waste items
```

---

## 🔧 Implementation Steps

### Step 1: Backend (Laravel Migration)

```bash
cd backend
php artisan make:migration add_multiple_waste_to_schedules_table
php artisan migrate
```

### Step 2: Update Backend API Controller

```php
// ScheduleController.php
public function store(Request $request) {
    $validated = $request->validate([
        'date' => 'required|date',
        'time' => 'required',
        'address' => 'required|string',
        'latitude' => 'required|numeric',
        'longitude' => 'required|numeric',
        'waste_items' => 'required|array|min:1',
        'waste_items.*.waste_type' => 'required|string',
        'waste_items.*.estimated_weight' => 'required|numeric|min:0',
        'waste_items.*.unit' => 'required|string',
        'notes' => 'nullable|string',
    ]);

    $totalWeight = collect($validated['waste_items'])
        ->sum('estimated_weight');

    $schedule = Schedule::create([
        'user_id' => auth()->id(),
        'date' => $validated['date'],
        'time' => $validated['time'],
        'address' => $validated['address'],
        'latitude' => $validated['latitude'],
        'longitude' => $validated['longitude'],
        'waste_items' => json_encode($validated['waste_items']),
        'total_estimated_weight' => $totalWeight,
        'notes' => $validated['notes'],
        'status' => 'pending',
    ]);

    return response()->json([
        'success' => true,
        'data' => $schedule->load('user'),
    ]);
}
```

### Step 3: Frontend - Remove Google Maps

1. Delete files listed above
2. Remove dependency from pubspec.yaml
3. Run `flutter pub get`

### Step 4: Frontend - Update Models

1. Create `waste_item.dart`
2. Update `schedule_model.dart`

### Step 5: Frontend - Update BLoC

1. Add new events
2. Add new states
3. Update bloc handlers

### Step 6: Frontend - Create UI

1. Create `add_schedule_page.dart`
2. Create waste type selector widget
3. Create weight input dialog
4. Implement dynamic list

---

## ✅ Testing Checklist

### Backend Testing:

- [ ] Migration runs successfully
- [ ] API accepts multiple waste items
- [ ] Validation works correctly
- [ ] Total weight calculated properly
- [ ] JSON storage works

### Frontend Testing:

- [ ] Google Maps removed completely
- [ ] App compiles without errors
- [ ] Can select multiple waste types
- [ ] Can input weight for each type
- [ ] Can add/remove waste items
- [ ] Form validation works
- [ ] Submit creates schedule successfully
- [ ] List page shows waste items

---

## 📊 Expected Results

### Before:

```
Schedule Form:
- Date & Time ✅
- Address with Map Picker ❌
- Single waste type
- No weight estimate
```

### After:

```
Schedule Form:
- Date & Time ✅
- Address (Text Input) ✅
- Multiple waste types (Pill Buttons) ✅
- Weight estimate per type ✅
- Dynamic waste item list ✅
- Total weight auto-calculated ✅
```

---

## 🚨 Breaking Changes

1. **Google Maps Dependency Removed**

   - Impact: All map-related features disabled
   - Solution: Use external navigation only

2. **Schedule Model Changed**

   - Impact: Existing schedules need migration
   - Solution: Backend migration + data transformation

3. **API Request Format Changed**
   - Impact: Frontend needs update
   - Solution: Update ScheduleService

---

## 📝 Notes

- Prioritas implementasi: Schedule Form dulu, baru hapus Google Maps
- Waste types bisa di-customize via API (future enhancement)
- Weight unit default: kg (bisa ditambah satuan lain)
- Total weight auto-calculated from waste items

---

**Status**: Ready to implement  
**Next Action**: Create backend migration file
