# Fitur Sampah Tambahan - Mitra Complete Pickup

## 📋 Deskripsi

Fitur ini memungkinkan **mitra** untuk menambahkan **jenis sampah tambahan** selain yang dijadwalkan oleh end user. Misalnya jika user hanya jadwalkan "Organik", mitra bisa menambahkan "Plastik" atau "Kertas" jika ternyata ada sampah jenis tersebut saat pickup.

## ⚠️ Problem Statement

**Sebelum:**
- Form hanya menampilkan jenis sampah yang dijadwalkan (daily)
- Jika user jadwalkan "Organik" saja, mitra tidak bisa input jenis lain
- Padahal saat pickup, user mungkin punya sampah tambahan yang tidak dijadwalkan

**Sesudah:**
- Form menampilkan sampah daily yang dijadwalkan
- Mitra bisa **tambah jenis sampah lain** dengan tombol "Tambah Jenis Sampah Lain"
- Form dinamis: menampilkan daily + tambahan

## ✨ Features

### 1. **Visual Distinction**
- **Hijau**: Jenis sampah yang dijadwalkan (daily)
- **Orange**: Jenis sampah tambahan (added by mitra)

### 2. **Add Additional Waste**
- Tombol: "Tambah Jenis Sampah Lain"
- Dialog untuk pilih jenis yang belum ada
- Auto-create form field untuk jenis yang dipilih

### 3. **Remove Additional Waste**
- Icon "X" pada chip orange
- Tap untuk hapus jenis tambahan
- Form field otomatis hilang

### 4. **Smart Filtering**
- Hanya tampilkan jenis yang belum dipilih
- Disable tombol jika semua 6 jenis sudah ditambahkan

## 🎯 User Flow

### Scenario 1: User Jadwalkan "Campuran"

```
1. End User → Jadwalkan sampah "Campuran"
   ↓
2. Mitra → Accept & Open Complete Pickup
   ↓
3. Form shows:
   ┌─────────┐
   │ Campuran│ (Hijau - Daily)
   └─────────┘
   [Tambah Jenis Sampah Lain]
   
   [Campuran______] kg
   ↓
4. Mitra → Tap "Tambah Jenis Sampah Lain"
   ↓
5. Dialog shows:
   - Organik
   - Anorganik
   - Kertas
   - Plastik
   - Logam
   - Kaca
   ↓
6. Mitra → Pilih "Plastik"
   ↓
7. Form updates:
   ┌─────────┐ ┌─────────┐
   │ Campuran│ │Plastik X│ (Orange - Additional)
   └─────────┘ └─────────┘
   [Tambah Jenis Sampah Lain]
   
   [Campuran______] kg
   [Plastik_______] kg
   ↓
8. Mitra → Fill weights & Submit
   ↓
9. Backend receives:
   actual_weights: {
     "Campuran": 5.5,
     "Plastik": 2.3
   }
```

### Scenario 2: Remove Additional Waste

```
1. Mitra added "Plastik" (orange chip)
   ↓
2. Mitra → Tap "X" on "Plastik" chip
   ↓
3. Confirmation (optional)
   ↓
4. Chip removed
   ↓
5. Form field removed
   ↓
6. "Plastik" available again in dialog
```

## 🔧 Technical Implementation

### 1. State Variables

```dart
// Scheduled types dari daily schedule
late final List<String> _scheduledTypes;

// Additional types yang ditambahkan mitra
final List<String> _additionalTypes = [];

// All available waste types
final List<String> _allAvailableTypes = [
  'Organik', 'Anorganik', 'Kertas', 
  'Plastik', 'Logam', 'Kaca',
];

// Getter untuk types yang ditampilkan
List<String> get _displayedWasteTypes => [
  ..._scheduledTypes,
  ..._additionalTypes,
];
```

### 2. Add Additional Waste

```dart
void _addAdditionalWasteType() {
  // Filter types yang belum dipilih
  final availableTypes = _allAvailableTypes.where((type) {
    return !_scheduledTypes.contains(type) && 
           !_additionalTypes.contains(type);
  }).toList();
  
  if (availableTypes.isEmpty) {
    // Show message: semua sudah ditambahkan
    return;
  }
  
  // Show dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tambah Jenis Sampah'),
      content: ListView.builder(
        itemCount: availableTypes.length,
        itemBuilder: (context, index) {
          final type = availableTypes[index];
          return ListTile(
            leading: const Icon(Icons.delete, color: Colors.green),
            title: Text(type),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _additionalTypes.add(type);
                _weightControllers[type] = TextEditingController();
              });
            },
          );
        },
      ),
    ),
  );
}
```

### 3. Remove Additional Waste

```dart
void _removeAdditionalWasteType(String type) {
  setState(() {
    _additionalTypes.remove(type);
    _weightControllers[type]?.dispose();
    _weightControllers.remove(type);
  });
  print('➖ Removed additional type: $type');
}
```

### 4. UI - Chips with Color Coding

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: _displayedWasteTypes.map((type) {
    final isScheduled = _scheduledTypes.contains(type);
    final isAdditional = _additionalTypes.contains(type);
    
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type),
          if (isAdditional) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _removeAdditionalWasteType(type),
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ],
      ),
      backgroundColor: isScheduled 
        ? Colors.green[50]  // Daily
        : Colors.orange[50], // Additional
      labelStyle: TextStyle(
        color: isScheduled ? Colors.green[800] : Colors.orange[800],
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isScheduled ? Colors.green[200]! : Colors.orange[200]!,
      ),
    );
  }).toList(),
),
```

### 5. UI - Add Button

```dart
// Tombol tambah jenis sampah tambahan
if (_displayedWasteTypes.length < _allAvailableTypes.length)
  OutlinedButton.icon(
    onPressed: _addAdditionalWasteType,
    icon: const Icon(Icons.add_circle_outline, size: 20),
    label: const Text('Tambah Jenis Sampah Lain'),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.orange,
      side: BorderSide(color: Colors.orange[300]!),
    ),
  ),
```

## 🎨 UI Design

### Initial State (Daily Only)

```
┌────────────────────────────────────┐
│ Berat Sampah (kg) *                │
│ Isi berat untuk 1 jenis sampah     │
│                                    │
│ ┌─────────┐                        │
│ │ Campuran│ (Green)                │
│ └─────────┘                        │
│                                    │
│ [+] Tambah Jenis Sampah Lain       │ ← Orange button
│                                    │
│ ┌──────────────────────────────┐   │
│ │ Campuran               kg    │   │
│ │ [0.00__________________]     │   │
│ └──────────────────────────────┘   │
└────────────────────────────────────┘
```

### After Adding "Plastik"

```
┌────────────────────────────────────┐
│ Berat Sampah (kg) *                │
│ Isi berat untuk 2 jenis sampah     │
│                                    │
│ ┌─────────┐ ┌──────────┐          │
│ │ Campuran│ │Plastik X │ (Orange) │
│ └─────────┘ └──────────┘          │
│                                    │
│ [+] Tambah Jenis Sampah Lain       │
│                                    │
│ ┌──────────────────────────────┐   │
│ │ Campuran               kg    │   │
│ │ [0.00__________________]     │   │
│ └──────────────────────────────┘   │
│ ┌──────────────────────────────┐   │
│ │ Plastik                kg    │   │
│ │ [0.00__________________]     │   │
│ └──────────────────────────────┘   │
└────────────────────────────────────┘
```

### Dialog to Add Type

```
┌────────────────────────────┐
│ Tambah Jenis Sampah        │
│                            │
│ 🗑️ Organik                 │ ← Tap to add
│ 🗑️ Anorganik               │
│ 🗑️ Kertas                  │
│ 🗑️ Logam                   │
│ 🗑️ Kaca                    │
│                            │
│              [Batal]       │
└────────────────────────────┘
```

## 🧪 Testing

### Test Case 1: Add Single Additional Type

**Steps:**
1. Schedule with "Campuran"
2. Open Complete Pickup
3. Tap "Tambah Jenis Sampah Lain"
4. Select "Plastik"

**Expected:**
```
✅ Chips: [Campuran (green)] [Plastik X (orange)]
✅ Fields: 2 (Campuran, Plastik)
✅ Button still visible (not all 6 types)
✅ Console: "➕ Added additional type: Plastik"
```

### Test Case 2: Add Multiple Additional Types

**Steps:**
1. Schedule with "Organik"
2. Add "Plastik"
3. Add "Kertas"
4. Add "Logam"

**Expected:**
```
✅ Chips: 
   [Organik (green)]
   [Plastik X (orange)]
   [Kertas X (orange)]
   [Logam X (orange)]
✅ Fields: 4
✅ Button still visible (2 more available)
```

### Test Case 3: Add All 6 Types

**Steps:**
1. Schedule with "Organik"
2. Add remaining 5 types one by one

**Expected:**
```
✅ All 6 chips displayed
✅ Button "Tambah Jenis Sampah Lain" HIDDEN
✅ Message if try to add more: "Semua jenis sampah sudah ditambahkan"
```

### Test Case 4: Remove Additional Type

**Steps:**
1. Schedule with "Organik"
2. Add "Plastik"
3. Tap "X" on "Plastik" chip

**Expected:**
```
✅ "Plastik" chip removed
✅ "Plastik" field removed
✅ "Plastik" available again in dialog
✅ Console: "➖ Removed additional type: Plastik"
```

### Test Case 5: Submit with Additional Types

**Steps:**
1. Schedule with "Organik"
2. Add "Plastik"
3. Fill weights:
   - Organik: 5.5 kg
   - Plastik: 2.3 kg
4. Add photos
5. Submit

**Expected:**
```
✅ Form submits successfully
✅ actual_weights = {"Organik": 5.5, "Plastik": 2.3}
✅ total_weight = 7.8
✅ Backend saves correctly
✅ End user sees both types in detail
```

### Test Case 6: Validation with Additional Types

**Steps:**
1. Schedule with "Organik"
2. Add "Plastik"
3. Fill only Organik weight
4. Leave Plastik empty
5. Try to submit

**Expected:**
```
❌ Validation error: "Minimal 1 jenis sampah harus diisi beratnya"
   (Should pass because Organik is filled)
✅ Form submits with only Organik weight
```

### Test Case 7: Empty Daily Schedule (Fallback)

**Steps:**
1. Schedule with empty `waste_type_scheduled`
2. Open Complete Pickup

**Expected:**
```
✅ All 6 types shown as scheduled (green)
✅ Button "Tambah Jenis Sampah Lain" HIDDEN
✅ Can't add more (all already displayed)
```

## 🐛 Edge Cases

### 1. Add Same Type Twice
**Prevention:** Filter already selected types
```dart
!_scheduledTypes.contains(type) && !_additionalTypes.contains(type)
```

### 2. Remove Scheduled Type
**Prevention:** Remove button only on additional types
```dart
if (isAdditional) ...[
  GestureDetector(
    onTap: () => _removeAdditionalWasteType(type),
    child: const Icon(Icons.close, size: 16),
  ),
]
```

### 3. All Types Already Added
**Handling:** Hide button and show message
```dart
if (_displayedWasteTypes.length < _allAvailableTypes.length)
  OutlinedButton.icon(...)
```

### 4. Dialog with No Available Types
**Handling:** Show snackbar before dialog
```dart
if (availableTypes.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Semua jenis sampah sudah ditambahkan'),
    ),
  );
  return;
}
```

## 📊 Data Flow

```
User Creates Schedule
  ↓
waste_type_scheduled = "Organik"
  ↓
Mitra Accepts & Opens Complete Pickup
  ↓
_scheduledTypes = ["Organik"]
_additionalTypes = []
  ↓
Mitra taps "Tambah Jenis Sampah Lain"
  ↓
Dialog shows: [Anorganik, Kertas, Plastik, Logam, Kaca]
  ↓
Mitra selects "Plastik"
  ↓
setState:
  _additionalTypes = ["Plastik"]
  _weightControllers["Plastik"] = TextEditingController()
  ↓
UI rebuilds:
  _displayedWasteTypes = ["Organik", "Plastik"]
  Form shows 2 fields
  ↓
Mitra fills weights & submits
  ↓
actual_weights = {
  "Organik": 5.5,
  "Plastik": 2.3
}
  ↓
Backend saves & updates schedule
```

## 🎯 Benefits

### For Mitra
✅ Fleksibilitas input sampah tambahan
✅ Tidak terbatas pada jadwal daily
✅ Lebih akurat dalam pencatatan

### For End User
✅ Mendapat poin dari semua jenis sampah
✅ Tidak perlu jadwalkan semua jenis di awal
✅ Data lebih detail di riwayat

### For Business
✅ Data sampah lebih lengkap
✅ Meningkatkan akurasi reporting
✅ Better user experience

## 🔄 Backward Compatibility

✅ **No breaking changes**
- Jika tidak ada sampah tambahan, berfungsi seperti sebelumnya
- Backward compatible dengan data lama
- Optional feature (mitra bisa skip tombol tambah)

## 📝 Notes

### Color Scheme
- **Green** (#4CAF50): Scheduled/Daily waste
- **Orange** (#FF9800): Additional waste
- **Red**: Remove action

### Icon Usage
- ✅ `add_circle_outline`: Tambah jenis
- ✅ `close`: Hapus jenis
- ✅ `delete`: Jenis sampah in dialog

### Console Logs
```
📦 Scheduled waste types: Organik
✅ Single type: Organik
🎯 Initialized 1 scheduled types
➕ Added additional type: Plastik
➖ Removed additional type: Plastik
```

## 🚀 Future Enhancements

### 1. Custom Waste Type
Allow mitra to add custom type (not in predefined list)
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Jenis Sampah Lainnya',
  ),
)
```

### 2. Quick Add Buttons
Instead of dialog, show as buttons
```dart
Wrap(
  children: availableTypes.map((type) => 
    ActionChip(
      label: Text(type),
      onPressed: () => _addType(type),
    )
  ).toList(),
)
```

### 3. Estimated Weights for Additional
Show estimated weights if available
```dart
Text('Est: ${schedule.estimatedWeights[type]} kg')
```

### 4. Undo Remove
Show snackbar with undo action
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('$type dihapus'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () => _undoRemove(type),
    ),
  ),
);
```

## ✅ Completion Checklist

- [x] Add `_scheduledTypes` and `_additionalTypes`
- [x] Create `_displayedWasteTypes` getter
- [x] Implement `_addAdditionalWasteType()`
- [x] Implement `_removeAdditionalWasteType()`
- [x] Update UI with color-coded chips
- [x] Add "Tambah Jenis Sampah Lain" button
- [x] Add remove "X" button on additional chips
- [x] Dialog for selecting additional type
- [x] Dynamic form field generation
- [x] Controller management
- [x] Debug logging
- [x] Hide button when all types added
- [x] Compile without errors
- [x] Documentation created

## 📞 Support

**Tested with:**
- Flutter SDK: Latest stable
- Dart SDK: Latest stable
- Target: Android/iOS

**Related Docs:**
- `FITUR_FORM_SAMPAH_DINAMIS.md` - Dynamic daily waste form
- `TESTING_FORM_SAMPAH_DINAMIS.md` - Testing guide

---

**Happy Coding! 🎉**

Form sekarang support:
- ✅ Dynamic daily waste (hijau)
- ✅ Additional waste (orange)
- ✅ Add/Remove functionality
- ✅ Smart filtering
- ✅ Color-coded UI
