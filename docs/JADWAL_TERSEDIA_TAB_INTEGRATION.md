# 📋 Integrasi Tab "Tersedia" ke Halaman Jadwal Mitra

## 🎯 Ringkasan Perubahan

Halaman "Jadwal Tersedia" yang sebelumnya standalone sekarang diintegrasikan sebagai tab pertama di halaman Jadwal Mitra yang sudah ada.

---

## 📁 File yang Diubah/Dibuat

### 1. **File Baru: `available_schedules_tab_content.dart`**
**Path:** `lib/ui/pages/mitra/available_schedules_tab_content.dart`

**Deskripsi:**
Widget content untuk tab "Tersedia" tanpa AppBar, dirancang khusus untuk digunakan sebagai tab content di dalam `JadwalMitraPageNew`.

**Fitur:**
- ✅ Daftar jadwal tersedia (pending schedules)
- ✅ Pagination & infinite scroll
- ✅ Filter (jenis sampah, area, tanggal)
- ✅ Pull to refresh
- ✅ Accept schedule functionality
- ✅ Loading states & error handling

**Key Components:**
```dart
class AvailableSchedulesTabContent extends StatefulWidget
class _ScheduleCard extends StatelessWidget
```

---

### 2. **File Diupdate: `jadwal_mitra_page_new.dart`**
**Path:** `lib/ui/pages/mitra/jadwal/jadwal_mitra_page_new.dart`

**Perubahan:**

#### a. Import Statement
```dart
// ADDED:
import 'package:bank_sha/ui/pages/mitra/available_schedules_tab_content.dart';
```

#### b. Tab Controller Length
```dart
// CHANGED: length: 4 → length: 5
_tabController = TabController(length: 5, vsync: this);
```

#### c. Tab Index Mapping
```dart
// ADDED case 0 untuk "tersedia"
case 0:
  _selectedFilter = "tersedia";
  break;
case 1:  // Was case 0
  _selectedFilter = "semua";
  break;
// ... dst
```

#### d. Filter Tabs UI
```dart
// ADDED tab button "Tersedia" di awal
_buildFilterTab(
  "Tersedia",
  _selectedFilter == "tersedia",
  () {
    setState(() {
      _selectedFilter = "tersedia";
      _tabController.animateTo(0);
    });
  },
  isSmallScreen,
),
```

#### e. Body Content Switching
```dart
Widget _buildBody(BuildContext context, bool isSmallScreen) {
  // ADDED: Conditional rendering
  if (_selectedFilter == "tersedia") {
    return const AvailableSchedulesTabContent();
  }
  
  // Original content untuk tab lainnya
  return Column(...);
}
```

#### f. Section Title Update
```dart
// ADDED kondisi untuk "tersedia"
Text(
  _selectedFilter == "tersedia"
      ? 'Jadwal Tersedia untuk Diambil'
      : _selectedFilter == "semua"
      ? 'Prioritas Terdekat'
      : // ... dst
)
```

---

## 🎨 UI/UX Changes

### Before
```
┌──────────────────────────────┐
│  [Semua] [Menunggu]          │
│  [Diproses] [Selesai]        │
└──────────────────────────────┘
```

### After
```
┌──────────────────────────────┐
│  [Tersedia] [Semua]          │
│  [Menunggu] [Diproses]       │
│  [Selesai]                   │
└──────────────────────────────┘
```

**Catatan:**
- Tab "Tersedia" sekarang menjadi tab **pertama**
- UI menggunakan `SingleChildScrollView` horizontal untuk menampung 5 tab
- Filter button dan counter tetap ada di dalam tab content

---

## 🔄 Navigation Flow

```
Mitra Dashboard
       ↓
  Jadwal Tab (Bottom Nav)
       ↓
┌────────────────────────────┐
│ JadwalMitraPageNew         │
│                            │
│ ┌────────────────────────┐ │
│ │ Tab: TERSEDIA (NEW)    │ │
│ │ ► AvailableSchedules   │ │
│ │   TabContent           │ │
│ │   - List jadwal        │ │
│ │   - Pagination         │ │
│ │   - Filter modal       │ │
│ │   - Accept button      │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ Tab: Semua             │ │
│ │ ► Original content     │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ Tab: Menunggu          │ │
│ │ ► Original content     │ │
│ └────────────────────────┘ │
│                            │
│ ... (dst)                  │
└────────────────────────────┘
```

---

## ✨ Fitur Tab "Tersedia"

### 1. **Daftar Jadwal**
- Menampilkan semua jadwal dengan status `pending`
- Card design konsisten dengan UI yang sudah ada
- Info lengkap: user, lokasi, waktu, jenis sampah

### 2. **Filter**
```dart
Jenis Sampah: Dropdown (Semua, Organik, Anorganik, B3, dll)
Area:         TextInput (e.g., "Jakarta Selatan")
Tanggal:      DatePicker
```

### 3. **Pagination**
- Infinite scroll (auto load saat scroll 80%)
- Manual "Muat Lebih Banyak" button sebagai fallback
- Loading indicator saat fetch data

### 4. **Actions**
- **Terima Jadwal**: Confirm dialog → Accept schedule → Refresh list
- **Tap Card**: Navigate to detail page
- **Pull to Refresh**: Reload dari page 1

### 5. **States**
- Loading: CircularProgressIndicator
- Empty: "Tidak ada jadwal tersedia" + Refresh button
- Error: Error message + Retry button
- End of List: "✅ Semua jadwal telah ditampilkan"

---

## 📊 Data Flow

```
Tab "Tersedia" Selected
       ↓
AvailableSchedulesTabContent
       ↓
MitraApiService.getAvailableSchedules()
       ↓
API: GET /api/mitra/pickup-schedules/available
       ↓
Response: {schedules: [...], pagination: {...}}
       ↓
Parse to List<MitraPickupSchedule>
       ↓
Display in ListView with Cards
       ↓
User taps "Terima Jadwal"
       ↓
Confirm Dialog
       ↓
MitraApiService.acceptSchedule(id)
       ↓
API: POST /api/mitra/pickup-schedules/{id}/accept
       ↓
Success → Refresh list
       ↓
Schedule removed from "Tersedia" tab
```

---

## 🧪 Testing Checklist

### Functional Tests
- [ ] Tab "Tersedia" tampil sebagai tab pertama
- [ ] Klik tab "Tersedia" → load jadwal pending
- [ ] Pagination bekerja (scroll ke bawah → load more)
- [ ] Filter modal bisa dibuka & filter diterapkan
- [ ] Accept schedule → konfirmasi → berhasil
- [ ] Pull to refresh → reload data
- [ ] Empty state tampil jika tidak ada jadwal
- [ ] Error handling bekerja (network error)

### UI Tests
- [ ] Tab bar horizontal scrollable (5 tabs)
- [ ] Filter badge (red dot) tampil saat ada filter aktif
- [ ] Card design konsisten dengan tab lain
- [ ] Loading indicator tampil saat fetch data
- [ ] End of list message tampil saat semua data loaded

### Integration Tests
- [ ] Switch antar tab smooth (tidak lag)
- [ ] Accept schedule dari tab "Tersedia" → muncul di tab "Diproses"
- [ ] Header stats (locationCount, pendingCount) ter-update
- [ ] Map view tetap bisa dibuka dari tab lain

---

## 🐛 Known Issues & Workarounds

### Issue 1: Tab Animation Delay
**Problem:** Slight delay saat switch ke tab "Tersedia" karena load data

**Workaround:** 
- Loading indicator ditampilkan dengan cepat
- Data di-cache untuk akses berikutnya (future improvement)

### Issue 2: Filter State Persist
**Problem:** Filter tidak persist saat switch tab

**Status:** By design - filter reset saat switch tab untuk menghindari confusion

---

## 🚀 Next Steps

### Short Term
1. ✅ Testing manual di simulator
2. ⏳ Testing di real device
3. ⏳ Backend verification (available schedules API)

### Future Enhancements
1. Add cache untuk mengurangi API calls
2. Add real-time updates (WebSocket/Polling)
3. Add nearby filter (sort by distance)
4. Add quick filters (preset filters)
5. Add schedule preview before accept
6. Add schedule history tracking

---

## 📝 Code Quality

### Metrics
- **Lines Added:** ~700 lines (new file)
- **Lines Modified:** ~50 lines (jadwal_mitra_page_new.dart)
- **Files Created:** 1
- **Files Modified:** 1
- **Breaking Changes:** ❌ None
- **Backward Compatible:** ✅ Yes

### Best Practices
- ✅ Separation of concerns (tab content as separate widget)
- ✅ Reusable components (_ScheduleCard)
- ✅ Proper state management
- ✅ Error handling
- ✅ Loading states
- ✅ Null safety
- ✅ Responsive design (isSmallScreen)

---

## 🎓 Developer Notes

### Why Separate Widget?
1. **Reusability:** Bisa digunakan di tempat lain jika diperlukan
2. **Maintainability:** Easier to maintain & test
3. **Clean Code:** Tidak membuat jadwal_mitra_page_new.dart terlalu besar
4. **Performance:** Widget tree lebih optimal

### Design Decisions
1. **Tab Position:** "Tersedia" di awal karena priority tinggi (mitra cari jadwal baru)
2. **No AppBar:** Content only, AppBar handled by parent page
3. **Inline Filter:** Filter modal dari dalam widget, bukan global
4. **Auto Scroll:** Pagination otomatis untuk better UX

---

**Status:** ✅ Implemented & Ready for Testing  
**Date:** November 13, 2025  
**Version:** 1.0.0
