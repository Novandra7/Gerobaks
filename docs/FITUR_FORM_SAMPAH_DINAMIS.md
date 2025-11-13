# Fitur Form Berat Sampah Dinamis - Mitra

## 📋 Deskripsi

Fitur ini mengubah form input berat sampah pada halaman **Selesaikan Pengambilan** menjadi **dinamis**. Form hanya menampilkan jenis-jenis sampah yang telah dipilih oleh **end user** saat membuat jadwal, bukan menampilkan semua 6 jenis sampah secara hardcode.

## ✅ Manfaat

### Sebelum (Static)
- Menampilkan **6 field** untuk semua jenis sampah
- Mitra harus scroll dan melihat field yang tidak relevan
- UX membingungkan karena menampilkan jenis yang tidak dijadwalkan

### Sesudah (Dynamic)
- Hanya menampilkan **jenis sampah yang dijadwalkan**
- Form lebih ringkas dan fokus
- Mengurangi kebingungan mitra
- Chips visual menunjukkan jenis yang dijadwalkan

## 🎯 Skenario Penggunaan

### Skenario 1: User Pilih 1 Jenis
```
End User → Jadwalkan "Organik"
↓
Mitra → Complete Pickup
↓
Form menampilkan: HANYA 1 field (Organik)
```

### Skenario 2: User Pilih 3 Jenis
```
End User → Jadwalkan "Organik,Plastik,Kertas"
↓
Mitra → Complete Pickup
↓
Form menampilkan: 3 fields (Organik, Plastik, Kertas)
```

### Skenario 3: User Pilih "Campuran"
```
End User → Jadwalkan "Campuran"
↓
Mitra → Complete Pickup
↓
Form menampilkan: HANYA 1 field (Campuran)
```

## 🔧 Implementasi Teknis

### 1. Parsing Waste Types

**File:** `lib/ui/pages/mitra/complete_pickup_page.dart`

```dart
/// Parse jenis sampah dari wasteTypeScheduled
/// Mendukung format:
/// - Single: "Campuran" atau "Organik"
/// - Multiple (comma-separated): "Organik,Plastik,Kertas"
List<String> _getScheduledWasteTypes() {
  final scheduled = widget.schedule.wasteTypeScheduled.trim();
  
  // Debug log
  print('📦 Scheduled waste types: $scheduled');
  
  // Jika kosong, gunakan fallback
  if (scheduled.isEmpty) {
    print('⚠️  Empty waste_type_scheduled, using fallback');
    return ['Organik', 'Anorganik', 'Kertas', 'Plastik', 'Logam', 'Kaca'];
  }
  
  // Jika berisi koma, split
  if (scheduled.contains(',')) {
    final types = scheduled
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    print('✅ Parsed ${types.length} types: $types');
    return types;
  }
  
  // Single type
  print('✅ Single type: $scheduled');
  return [scheduled];
}
```

### 2. Dynamic Initialization

**Sebelum:**
```dart
// Static list
final List<String> _wasteTypes = [
  'Organik', 'Anorganik', 'Kertas', 
  'Plastik', 'Logam', 'Kaca',
];

// Initialize ALL controllers
for (var type in _wasteTypes) {
  _weightControllers[type] = TextEditingController();
}
```

**Sesudah:**
```dart
// Dynamic list
late final List<String> _wasteTypes;

@override
void initState() {
  super.initState();
  _apiService.initialize();
  
  // Initialize dynamic waste types from schedule
  _wasteTypes = _getScheduledWasteTypes();
  
  // Initialize weight controllers only for scheduled types
  for (var type in _wasteTypes) {
    _weightControllers[type] = TextEditingController();
  }
}
```

### 3. Enhanced UI with Chips

```dart
// Weight Inputs Section
const Text(
  'Berat Sampah (kg) *',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
Text(
  'Isi berat untuk ${_wasteTypes.length} jenis sampah yang dijadwalkan',
  style: const TextStyle(color: Colors.grey, fontSize: 14),
),
const SizedBox(height: 8),

// Chips menampilkan jenis sampah yang dijadwalkan
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: _wasteTypes.map((type) => Chip(
    label: Text(type),
    backgroundColor: Colors.green[50],
    labelStyle: TextStyle(
      color: Colors.green[800],
      fontWeight: FontWeight.w500,
    ),
    side: BorderSide(color: Colors.green[200]!),
  )).toList(),
),
```

### 4. Form Fields (Automatic)

Form fields dibuat secara otomatis berdasarkan `_wasteTypes`:

```dart
..._wasteTypes.map((type) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: _weightControllers[type],
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: type,
        suffixText: 'kg',
        border: const OutlineInputBorder(),
        hintText: '0.00',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Masukkan berat $type';
        }
        final weight = double.tryParse(value);
        if (weight == null) {
          return 'Berat harus berupa angka';
        }
        if (weight <= 0) {
          return 'Berat harus lebih dari 0';
        }
        return null;
      },
    ),
  );
})
```

## 📊 Data Flow

```
1. End User creates schedule → Selects waste types
   ↓
2. Backend saves: waste_type_scheduled = "Organik" atau "Organik,Plastik,Kertas"
   ↓
3. Mitra accepts schedule → Opens CompletePickupPage
   ↓
4. initState() → _getScheduledWasteTypes()
   ↓
5. Parse waste_type_scheduled:
   - Single: "Organik" → ["Organik"]
   - Multiple: "Organik,Plastik,Kertas" → ["Organik", "Plastik", "Kertas"]
   - Empty: "" → Fallback all types
   ↓
6. Initialize controllers dynamically for parsed types
   ↓
7. Render form fields only for those types
   ↓
8. Mitra fills weights → Submit → Backend receives actual_weights
```

## 🎨 UI Components

### 1. Section Header
```
┌─────────────────────────────────────┐
│ Berat Sampah (kg) *                 │
│ Isi berat untuk 2 jenis sampah...  │
└─────────────────────────────────────┘
```

### 2. Visual Chips
```
┌─────────┐ ┌─────────┐
│ Organik │ │ Plastik │
└─────────┘ └─────────┘
```
- Background: Light green
- Border: Green
- Text: Dark green

### 3. Input Fields
```
┌─────────────────────────────────────┐
│ Organik                         kg  │
│ [0.00___________________________]   │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ Plastik                         kg  │
│ [0.00___________________________]   │
└─────────────────────────────────────┘
```

## 🧪 Testing Guide

### Test Case 1: Single Type
**Setup:**
1. Create schedule dengan `waste_type_scheduled = "Organik"`

**Expected:**
- Form shows 1 chip: "Organik"
- Form shows 1 field: Organik
- Console log: `✅ Single type: Organik`

### Test Case 2: Multiple Types (Comma-Separated)
**Setup:**
1. Create schedule dengan `waste_type_scheduled = "Organik,Plastik,Kertas"`

**Expected:**
- Form shows 3 chips: "Organik", "Plastik", "Kertas"
- Form shows 3 fields
- Console log: `✅ Parsed 3 types: [Organik, Plastik, Kertas]`

### Test Case 3: Campuran
**Setup:**
1. Create schedule dengan `waste_type_scheduled = "Campuran"`

**Expected:**
- Form shows 1 chip: "Campuran"
- Form shows 1 field: Campuran
- Console log: `✅ Single type: Campuran`

### Test Case 4: Empty/Null (Fallback)
**Setup:**
1. Create schedule dengan `waste_type_scheduled = ""`

**Expected:**
- Form shows 6 chips (all types)
- Form shows 6 fields
- Console log: `⚠️ Empty waste_type_scheduled, using fallback`

### Test Case 5: With Spaces
**Setup:**
1. Create schedule dengan `waste_type_scheduled = " Organik , Plastik , Kertas "`

**Expected:**
- Form shows 3 chips (trimmed): "Organik", "Plastik", "Kertas"
- Form shows 3 fields
- Console log: `✅ Parsed 3 types: [Organik, Plastik, Kertas]`

### Test Case 6: Form Submission
**Steps:**
1. Open complete pickup page
2. Fill weights for displayed types
3. Add photos
4. Submit

**Expected:**
- `actual_weights` contains only the types shown in form
- Example: `{"Organik": 5.5, "Plastik": 2.3}`

## 🔍 Debug Logs

Saat membuka CompletePickupPage, console akan menampilkan:

```
📦 Scheduled waste types: Organik,Plastik,Kertas
✅ Parsed 3 types: [Organik, Plastik, Kertas]
```

atau

```
📦 Scheduled waste types: Campuran
✅ Single type: Campuran
```

atau (fallback)

```
📦 Scheduled waste types: 
⚠️  Empty waste_type_scheduled, using fallback
```

## 🛡️ Error Handling

### 1. Empty waste_type_scheduled
```dart
if (scheduled.isEmpty) {
  print('⚠️  Empty waste_type_scheduled, using fallback');
  return ['Organik', 'Anorganik', 'Kertas', 'Plastik', 'Logam', 'Kaca'];
}
```
**Fallback:** Show all 6 types

### 2. Trim Whitespace
```dart
.map((e) => e.trim())
.where((e) => e.isNotEmpty)
```
**Handles:** `" Organik , Plastik "` → `["Organik", "Plastik"]`

### 3. Validation Unchanged
Form validation tetap sama:
- Required field
- Must be numeric
- Must be > 0

## 📱 Screenshots

### Sebelum (Static - 6 Fields)
```
┌───────────────────────────────┐
│ Berat Sampah (kg) *           │
│                               │
│ [Organik________] kg          │
│ [Anorganik______] kg          │
│ [Kertas_________] kg          │
│ [Plastik________] kg          │
│ [Logam__________] kg          │
│ [Kaca___________] kg          │
└───────────────────────────────┘
```

### Sesudah (Dynamic - 2 Fields)
```
┌───────────────────────────────┐
│ Berat Sampah (kg) *           │
│ Isi berat untuk 2 jenis...    │
│                               │
│ [Organik] [Plastik]           │  ← Chips
│                               │
│ [Organik________] kg          │
│ [Plastik________] kg          │
└───────────────────────────────┘
```

## 🔄 Backward Compatibility

### API Format Support
✅ Single: `"Organik"`
✅ Multiple: `"Organik,Plastik,Kertas"`
✅ Empty: `""` → Fallback
✅ With spaces: `" Organik , Plastik "` → Auto trim

### Model Field
Menggunakan field yang sudah ada:
```dart
final String wasteTypeScheduled;
```

Tidak ada perubahan pada model atau API contract.

## 🚀 Future Enhancements

### 1. Backend: Return Structured Array
```json
{
  "waste_types_scheduled": ["Organik", "Plastik", "Kertas"]
}
```

### 2. Icons per Type
```dart
Chip(
  avatar: CircleAvatar(
    backgroundImage: AssetImage(_getIconForType(type)),
  ),
  label: Text(type),
)
```

### 3. Estimated Weights Display
```dart
Text('Estimasi: ${schedule.estimatedWeights[type]} kg')
```

### 4. Color Coding
```dart
backgroundColor: _getColorForType(type),
```

## 📚 Related Files

### Modified
- ✅ `lib/ui/pages/mitra/complete_pickup_page.dart`
  - Lines 21-61: Dynamic initialization
  - Lines 392-412: Enhanced UI with chips

### Read Only
- `lib/models/mitra_pickup_schedule.dart`
  - Line 13: `wasteTypeScheduled` field

### Documentation
- ✅ `docs/FITUR_FORM_SAMPAH_DINAMIS.md` (this file)

## ✅ Completion Checklist

- [x] Parse waste_type_scheduled (single/multiple)
- [x] Dynamic _wasteTypes initialization
- [x] Dynamic controller creation
- [x] Add visual chips for scheduled types
- [x] Update UI text to show count
- [x] Add debug logging
- [x] Handle empty/null case (fallback)
- [x] Handle whitespace trimming
- [x] Compile without errors
- [x] Documentation created

## 🎉 Summary

Form berat sampah sekarang **dinamis** dan hanya menampilkan jenis sampah yang dijadwalkan oleh end user. Ini meningkatkan UX mitra dengan:
1. Form lebih ringkas
2. Fokus pada jenis yang relevan
3. Visual chips yang jelas
4. Support multiple format data
5. Fallback untuk edge cases

Mitra tidak perlu scroll melalui field yang tidak relevan lagi! 🚀
