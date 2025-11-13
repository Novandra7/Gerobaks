# 📋 Dokumentasi: Detail Aktivitas User

**Dibuat:** 13 November 2025  
**Fitur:** Detail hasil inputan user pada aktivitas yang sudah selesai  
**Status:** ✅ **IMPLEMENTED**

---

## 📋 Overview

Fitur ini menampilkan detail lengkap hasil pengambilan sampah untuk aktivitas yang sudah selesai (completed), termasuk:
- Detail sampah per jenis (berat, poin)
- Total berat & total poin
- Foto bukti pengambilan
- Informasi petugas
- Catatan tambahan

---

## 🎯 User Flow

### **1. Lihat Daftar Aktivitas**
```
User → Tab "Riwayat" → Lihat list aktivitas yang sudah selesai
```

### **2. Klik Detail Aktivitas**
```
User → Klik card aktivitas → Modal detail muncul
```

### **3. Lihat Detail Lengkap (Jika Completed)**
```
User → Klik "Lihat Detail Lengkap" → Draggable bottom sheet muncul dengan:
- Ringkasan (total berat, jenis, poin, petugas)
- Detail sampah per jenis
- Foto bukti
- Catatan
```

---

## 🔧 Technical Implementation

### **A. Model Data**

**File:** `lib/models/activity_model_improved.dart`

```dart
class TrashDetail {
  final String type;        // Jenis sampah
  final int weight;         // Berat dalam kg
  final int points;         // Poin yang diberikan
  final String? icon;       // Icon untuk jenis sampah
}

class ActivityModel {
  final String id;
  final String title;
  final String address;
  final String dateTime;
  final String status;
  final bool isActive;
  final DateTime date;

  // Data tambahan untuk pengambilan selesai
  final List<TrashDetail>? trashDetails;
  final int? totalWeight;           // Total berat dalam kg
  final int? totalPoints;            // Total poin yang didapat
  final List<String>? photoProofs;   // URL foto bukti
  final String? completedBy;         // Nama petugas
  final String? notes;               // Catatan
}
```

---

### **B. Data Parsing dari API**

**File:** `lib/ui/pages/end_user/activity/activity_content_improved.dart`

**Method:** `getFilteredActivities()`

```dart
List<ActivityModel> getFilteredActivities() {
  List<ActivityModel> activities = _schedules.map((schedule) {
    // Parse actual_weights jika ada (untuk schedule yang completed)
    List<TrashDetail>? trashDetails;
    int? totalWeight;
    int? totalPoints;
    
    if (schedule['actual_weights'] != null && schedule['status'] == 'completed') {
      final weights = schedule['actual_weights'];
      trashDetails = [];
      int calculatedWeight = 0;
      int calculatedPoints = 0;
      
      if (weights is Map) {
        weights.forEach((type, weight) {
          final weightValue = (weight is String) 
              ? double.tryParse(weight)?.toInt() ?? 0
              : (weight is num) ? weight.toInt() : 0;
          
          // Kalkulasi poin (contoh: 10 poin per kg)
          final points = weightValue * 10;
          
          calculatedWeight += weightValue;
          calculatedPoints += points;
          
          trashDetails!.add(TrashDetail(
            type: type.toString(),
            weight: weightValue,
            points: points,
            icon: _getTrashIcon(type.toString()),
          ));
        });
      }
      
      totalWeight = calculatedWeight;
      totalPoints = calculatedPoints;
    }
    
    // Parse pickup_photos jika ada
    List<String>? photoProofs;
    if (schedule['pickup_photos'] != null) {
      photoProofs = (schedule['pickup_photos'] as List)
          .map((p) => p.toString())
          .toList();
    }
    
    // Get mitra name
    String? completedBy;
    if (schedule['mitra_name'] != null) {
      completedBy = schedule['mitra_name'].toString();
    }

    return ActivityModel(
      // ... standard fields
      trashDetails: trashDetails,
      totalWeight: totalWeight,
      totalPoints: totalPoints,
      photoProofs: photoProofs,
      completedBy: completedBy,
    );
  }).toList();
}
```

**Helper Method untuk Icon Mapping:**
```dart
String _getTrashIcon(String trashType) {
  final type = trashType.toLowerCase();
  
  if (type.contains('organik')) {
    return 'assets/ic_transaction_cat1.png';
  } else if (type.contains('plastik')) {
    return 'assets/ic_transaction_cat2.png';
  } else if (type.contains('kertas')) {
    return 'assets/ic_transaction_cat3.png';
  } else if (type.contains('kaca') || type.contains('logam')) {
    return 'assets/ic_transaction_cat4.png';
  } else if (type.contains('elektronik') || type.contains('b3')) {
    return 'assets/ic_transaction_cat5.png';
  }
  
  return 'assets/ic_trash.png'; // Default
}
```

---

### **C. UI Component**

**File:** `lib/ui/widgets/modals/activity_detail_modal.dart`

**Method:** `_showCompletedDetails()`

#### **1. Ringkasan Section**
```dart
Card(
  child: Padding(
    child: Column(
      children: [
        Text('Ringkasan'),
        _buildSummaryRow('Total Berat', '${activity.totalWeight} kg'),
        _buildSummaryRow('Total Jenis', '${activity.trashDetails!.length} jenis'),
        _buildSummaryRow('Total Poin', '${activity.totalPoints} poin', isHighlighted: true),
        _buildSummaryRow('Petugas', activity.completedBy!),
      ],
    ),
  ),
)
```

#### **2. Detail Sampah List**
```dart
ListView.builder(
  itemCount: activity.trashDetails!.length,
  itemBuilder: (context, index) {
    final trashDetail = activity.trashDetails![index];
    return Card(
      child: ListTile(
        leading: Container(
          child: Image.asset(trashDetail.icon ?? 'assets/ic_trash.png'),
        ),
        title: Text(trashDetail.type),
        subtitle: Text('${trashDetail.weight} kg'),
        trailing: Container(
          child: Text('+${trashDetail.points} poin'),
        ),
      ),
    );
  },
)
```

#### **3. Foto Bukti Grid**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: activity.photoProofs!.length,
  itemBuilder: (context, index) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, activity.photoProofs![index]),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(activity.photoProofs![index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  },
)
```

#### **4. Full Screen Image Viewer**
```dart
void _showFullScreenImage(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      );
    },
  );
}
```

---

## 📊 Data Structure

### **API Response Format (Completed Schedule)**

```json
{
  "id": 51,
  "user_id": 15,
  "pickup_address": "1-99 Stockton St, San Francisco",
  "user_name": "ali",
  "status": "completed",
  "scheduled_at": "2025-11-14T06:00:00.000000Z",
  "completed_at": "2025-11-13T07:35:30.000000Z",
  "mitra_name": "Ahmad Kurniawan",
  "actual_weights": {
    "Kaca": "1.0",
    "Logam": "1.0",
    "Kertas": "1.0",
    "Organik": "1.0",
    "Plastik": "1.0",
    "Anorganik": "1.0"
  },
  "total_weight": "6.00",
  "pickup_photos": [
    "/storage/pickups/51/9yqfOwvdTsV3Qz4HCHNFGOPFviQ2fXt9uS2Sx8ky.jpg"
  ],
  "notes": "Sampah sudah ditimbang"
}
```

### **Parsed to ActivityModel**

```dart
ActivityModel(
  id: "51",
  title: "Layanan Sampah",
  address: "1-99 Stockton St, San Francisco",
  status: "Selesai",
  isActive: false,
  trashDetails: [
    TrashDetail(type: "Kaca", weight: 1, points: 10, icon: "..."),
    TrashDetail(type: "Logam", weight: 1, points: 10, icon: "..."),
    TrashDetail(type: "Kertas", weight: 1, points: 10, icon: "..."),
    TrashDetail(type: "Organik", weight: 1, points: 10, icon: "..."),
    TrashDetail(type: "Plastik", weight: 1, points: 10, icon: "..."),
    TrashDetail(type: "Anorganik", weight: 1, points: 10, icon: "..."),
  ],
  totalWeight: 6,
  totalPoints: 60,
  photoProofs: ["/storage/pickups/51/...jpg"],
  completedBy: "Ahmad Kurniawan",
  notes: "Sampah sudah ditimbang",
)
```

---

## 🎨 UI/UX Features

### **1. Modal Bottom Sheet (First Layer)**
- Header dengan "Detail Aktivitas"
- Status badge dengan icon
- Info: Judul, Alamat, Waktu
- Action buttons:
  - **Jika Aktif:**
    - "Lacak Pengambilan" (jika menuju lokasi)
    - "Atur Ulang Jadwal" (jika dijadwalkan)
    - "Batalkan" (button merah)
  - **Jika Selesai:**
    - "Lihat Detail Lengkap" (button hijau)

### **2. Draggable Bottom Sheet (Detail Layer)**
- Draggable handle bar
- Header dengan "Detail Pengambilan Sampah"
- **Ringkasan Card:**
  - Total Berat
  - Total Jenis Sampah
  - Total Poin (highlighted hijau)
  - Nama Petugas
  
- **Detail Sampah Section:**
  - List card per jenis sampah
  - Icon jenis sampah
  - Nama jenis
  - Berat (kg)
  - Poin yang didapat
  
- **Bukti Foto Section:**
  - Grid 2 kolom
  - Thumbnail foto
  - Zoom icon overlay
  - Tap untuk fullscreen
  
- **Catatan Section:**
  - Text box dengan border
  - Background abu-abu muda

### **3. Full Screen Image Viewer**
- Tap foto → dialog fullscreen
- InteractiveViewer:
  - Pan/drag
  - Pinch to zoom (0.5x - 4x)
- Close button (top right)

---

## 🔄 User Interaction Flow

```
┌─────────────────────────────────────────────────┐
│         Activity List (Riwayat Tab)            │
│  ┌──────────────────────────────────────────┐  │
│  │ ✅ Pengambilan Sampah        +60 poin   │  │
│  │ 📍 1-99 Stockton St                      │  │
│  │ 🕐 14 Nov 2025, 06:00        [Detail >] │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                     ↓ Tap "Detail"
┌─────────────────────────────────────────────────┐
│        Detail Aktivitas Modal                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                  │
│     ✅ Selesai                                  │
│                                                  │
│  Judul: Pengambilan Sampah                      │
│  Alamat: 1-99 Stockton St, San Francisco        │
│  Waktu: 14 November 2025, 06:00                 │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │     [Lihat Detail Lengkap]                 │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                     ↓ Tap "Lihat Detail Lengkap"
┌─────────────────────────────────────────────────┐
│    Detail Pengambilan Sampah (Draggable)       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                                  │
│  📊 RINGKASAN                                   │
│  ┌────────────────────────────────────────────┐ │
│  │ Total Berat:          6 kg                 │ │
│  │ Total Jenis:          6 jenis              │ │
│  │ Total Poin:           60 poin (hijau)      │ │
│  │ Petugas:              Ahmad Kurniawan      │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  📦 DETAIL SAMPAH                               │
│  ┌────────────────────────────────────────────┐ │
│  │ 🗑️ Kaca          1 kg         +10 poin    │ │
│  │ 🗑️ Logam         1 kg         +10 poin    │ │
│  │ 🗑️ Kertas        1 kg         +10 poin    │ │
│  │ 🗑️ Organik       1 kg         +10 poin    │ │
│  │ 🗑️ Plastik       1 kg         +10 poin    │ │
│  │ 🗑️ Anorganik     1 kg         +10 poin    │ │
│  └────────────────────────────────────────────┘ │
│                                                  │
│  📸 BUKTI FOTO                                  │
│  ┌─────────────────┬─────────────────┐          │
│  │ [Foto 1] 🔍     │ [Foto 2] 🔍     │          │
│  └─────────────────┴─────────────────┘          │
│                                                  │
│  📝 CATATAN                                     │
│  ┌────────────────────────────────────────────┐ │
│  │ Sampah sudah ditimbang dan dicatat        │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                     ↓ Tap Foto
┌─────────────────────────────────────────────────┐
│         Full Screen Image Viewer                │
│                                                  │
│                                           ❌     │
│                                                  │
│                                                  │
│              [Zoomable Image]                   │
│           (Pinch to zoom 0.5x-4x)               │
│                                                  │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## ✅ Features Implemented

### **1. Data Parsing** ✅
- [x] Parse `actual_weights` dari Map ke List<TrashDetail>
- [x] Handle tipe data String/Number dengan defensive parsing
- [x] Kalkulasi total weight dari semua jenis sampah
- [x] Kalkulasi total points (10 poin per kg)
- [x] Parse `pickup_photos` dari array
- [x] Parse `mitra_name` sebagai completedBy
- [x] Parse `notes` jika ada

### **2. UI Components** ✅
- [x] Modal bottom sheet untuk quick detail
- [x] Draggable bottom sheet untuk full detail
- [x] Ringkasan card dengan highlight
- [x] List detail sampah per jenis
- [x] Grid foto bukti (2 kolom)
- [x] Full screen image viewer dengan zoom
- [x] Catatan section
- [x] Conditional rendering berdasarkan status

### **3. Icon Mapping** ✅
- [x] Organik → ic_transaction_cat1.png
- [x] Plastik → ic_transaction_cat2.png
- [x] Kertas → ic_transaction_cat3.png
- [x] Kaca/Logam → ic_transaction_cat4.png
- [x] Elektronik/B3 → ic_transaction_cat5.png
- [x] Default → ic_trash.png

### **4. User Experience** ✅
- [x] Smooth transitions between modals
- [x] Draggable bottom sheet (50%-95% height)
- [x] InteractiveViewer untuk zoom foto
- [x] Handle bar untuk drag gesture
- [x] Close buttons di setiap layer
- [x] Conditional buttons berdasarkan status

---

## 🧪 Testing Checklist

### **Data Parsing**
- [ ] Test dengan `actual_weights` sebagai Map
- [ ] Test dengan weight value sebagai String
- [ ] Test dengan weight value sebagai Number
- [ ] Test dengan `pickup_photos` empty array
- [ ] Test dengan `pickup_photos` null
- [ ] Test dengan `mitra_name` null
- [ ] Test dengan `notes` null
- [ ] Test kalkulasi total weight correct
- [ ] Test kalkulasi total points correct (weight * 10)

### **UI Display**
- [ ] Modal muncul saat klik "Detail"
- [ ] Status badge warna sesuai status
- [ ] Tombol "Lihat Detail Lengkap" muncul jika status = selesai
- [ ] Draggable sheet muncul saat klik "Lihat Detail Lengkap"
- [ ] Ringkasan section tampil dengan data correct
- [ ] Detail sampah list tampil semua jenis
- [ ] Icon sampah sesuai dengan jenis
- [ ] Foto grid tampil jika ada foto
- [ ] Foto bisa di-tap dan fullscreen
- [ ] Zoom foto berfungsi (0.5x - 4x)
- [ ] Catatan tampil jika ada notes
- [ ] Close button berfungsi di setiap layer

### **Edge Cases**
- [ ] Handle schedule dengan 0 actual_weights
- [ ] Handle schedule tanpa foto
- [ ] Handle schedule tanpa catatan
- [ ] Handle schedule dengan mitra_name null
- [ ] Handle foto dengan URL invalid
- [ ] Handle jenis sampah yang tidak terdaftar (use default icon)

---

## 📱 Screenshots

### **Before (Simple Modal)**
```
┌─────────────────────────────┐
│  Detail Aktivitas           │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│                              │
│  ✅ Selesai                 │
│                              │
│  Judul: Pengambilan Sampah  │
│  Alamat: Jl. Merdeka No.1   │
│  Waktu: 14 Nov, 06:00       │
│                              │
│  [Tutup]                    │
└─────────────────────────────┘
```

### **After (With Details)**
```
┌─────────────────────────────┐
│  Detail Pengambilan Sampah  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│                              │
│  📊 RINGKASAN               │
│  Total Berat: 6 kg          │
│  Total Jenis: 6 jenis       │
│  Total Poin: 60 poin        │
│  Petugas: Ahmad Kurniawan   │
│                              │
│  📦 DETAIL SAMPAH           │
│  🗑️ Kaca    1kg  +10 poin  │
│  🗑️ Logam   1kg  +10 poin  │
│  🗑️ Kertas  1kg  +10 poin  │
│  ...                        │
│                              │
│  📸 BUKTI FOTO              │
│  [📷] [📷]                  │
│                              │
│  📝 CATATAN                 │
│  Sampah sudah ditimbang     │
└─────────────────────────────┘
```

---

## 🔮 Future Enhancements

### **Phase 2:**
- [ ] Download foto ke gallery
- [ ] Share hasil pengambilan ke social media
- [ ] Print receipt/invoice
- [ ] Export data ke PDF
- [ ] Timeline view of pickup process
- [ ] Rating system untuk mitra

### **Phase 3:**
- [ ] AR view untuk visualisasi sampah
- [ ] Chart statistik poin bulanan
- [ ] Comparison dengan bulan lalu
- [ ] Achievement badges
- [ ] Leaderboard antar user

---

## 📞 Contact & Support

**Jika ada bug atau improvement:**
1. Test dengan data real dari backend
2. Check console logs untuk error
3. Verify API response structure
4. Check image paths untuk foto

**Files Modified:**
- ✅ `lib/ui/pages/end_user/activity/activity_content_improved.dart`
- ✅ `lib/models/activity_model_improved.dart` (already has fields)
- ✅ `lib/ui/widgets/modals/activity_detail_modal.dart` (already has UI)

**Status:** ✅ **READY FOR TESTING**

---

*Dokumentasi dibuat: 13 November 2025*  
*Last Updated: 13 November 2025*
