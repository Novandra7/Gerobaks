# 📄 Fitur Pagination - Jadwal Tersedia Mitra

**Dibuat:** 13 November 2025  
**Status:** ✅ Implemented  
**Priority:** HIGH

---

## 📋 Overview

Fitur pagination telah ditambahkan pada halaman **Jadwal Tersedia** untuk mitra, memungkinkan user melihat semua jadwal yang tersedia secara bertahap (infinite scroll).

### ⚡ Masalah yang Diselesaikan

**Issue Sebelumnya:**
- Flutter hanya menampilkan halaman 1 (20 jadwal pertama)
- User tidak bisa melihat jadwal dari user baru yang ada di halaman 2+
- User mengira ada bug karena jadwal baru tidak muncul

**Root Cause:**
- Backend pagination sudah bekerja dengan baik (20 jadwal per halaman)
- Flutter tidak mengimplementasikan pagination UI
- Tidak ada cara untuk load halaman berikutnya

**Solusi:**
- ✅ Infinite scroll (otomatis load saat scroll ke 80%)
- ✅ Manual "Load More" button sebagai fallback
- ✅ Indicator halaman dan total jadwal
- ✅ Loading indicator saat load halaman berikutnya
- ✅ Message "Semua jadwal telah ditampilkan" di akhir list

---

## 🔧 Technical Implementation

### 1. **Backend API (Sudah Ready)**

**Endpoint:** `GET /api/mitra/pickup-schedules/available?page={page}`

**Response Format:**
```json
{
  "success": true,
  "message": "Available schedules retrieved successfully",
  "data": {
    "schedules": [
      {
        "id": 8,
        "user_id": 2,
        "user_name": "User Daffa",
        "pickup_address": "Jl. Example",
        "schedule_day": "Senin",
        "pickup_time_start": "08:00",
        "pickup_time_end": "10:00",
        ...
      }
    ],
    "pagination": {
      "current_page": 1,
      "total": 38,
      "per_page": 20
    }
  }
}
```

**Pagination Behavior:**
- Default: 20 jadwal per halaman
- Ordering: `created_at DESC` (jadwal terlama dulu)
- Total schedules: 38 jadwal dari 6 users berbeda
- Total pages: 2 halaman (20 + 18 jadwal)

**Data Distribution:**
```
Page 1 (20 schedules): ID 8-24
  - Mostly User Daffa (ID 2)
  - Created: 2025-11-12 06:32:05 (oldest)

Page 2 (18 schedules): ID 35-52
  - Aji Ali (ID 13): 1 schedule
  - ali (ID 15): 12 schedules
  - Aceng (ID 10): 4 schedules
  - mbah (ID 17): 1 schedule (NEW USER)
  - Created: 2025-11-13 (newest)
```

---

### 2. **Flutter Service Updates**

**File:** `lib/services/mitra_api_service.dart`

**Changes:**

#### Before:
```dart
Future<List<MitraPickupSchedule>> getAvailableSchedules({
  String? wasteType,
  String? area,
  String? date,
}) async {
  // ... fetches only default page (page 1)
  return schedules;
}
```

#### After:
```dart
Future<Map<String, dynamic>> getAvailableSchedules({
  int page = 1,  // ✅ NEW: page parameter
  String? wasteType,
  String? area,
  String? date,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),  // ✅ NEW: include page in query
  };
  // ... other params ...
  
  return {
    'schedules': schedules,           // ✅ List<MitraPickupSchedule>
    'pagination': pagination ?? {},   // ✅ Pagination metadata
    'has_more': schedules.length >= 20,  // ✅ Flag for more pages
  };
}
```

**Key Changes:**
1. ✅ Added `int page = 1` parameter
2. ✅ Changed return type from `List` to `Map<String, dynamic>`
3. ✅ Returns schedules + pagination info + has_more flag
4. ✅ Logs include page number for debugging

---

### 3. **Flutter UI Updates**

**File:** `lib/ui/pages/mitra/available_schedules_page.dart`

**New State Variables:**
```dart
class _AvailableSchedulesPageState extends State<AvailableSchedulesPage> {
  final ScrollController _scrollController = ScrollController();  // ✅ NEW
  
  List<MitraPickupSchedule> _schedules = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;  // ✅ NEW: separate loading state
  String? _error;
  
  // ✅ NEW: Pagination state
  int _currentPage = 1;
  bool _hasMorePages = true;
  
  // Filters (existing)
  String? _selectedWasteType;
  String? _selectedArea;
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);  // ✅ NEW: scroll listener
    _initializeService();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();  // ✅ NEW: cleanup
    super.dispose();
  }
}
```

**Scroll Detection:**
```dart
void _onScroll() {
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent * 0.8) {
    // ✅ User scrolled to 80% of list
    _loadMoreSchedules();
  }
}
```

**Load Initial Data:**
```dart
Future<void> _loadSchedules() async {
  setState(() {
    _isLoading = true;
    _error = null;
    _currentPage = 1;           // ✅ Reset to page 1
    _hasMorePages = true;       // ✅ Reset pagination
    _schedules = [];            // ✅ Clear existing schedules
  });

  try {
    final result = await _apiService.getAvailableSchedules(
      page: 1,  // ✅ Always start from page 1
      wasteType: _selectedWasteType,
      area: _selectedArea,
      date: _selectedDate != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null,
    );

    final schedules = result['schedules'] as List<MitraPickupSchedule>;
    final hasMore = result['has_more'] as bool? ?? false;

    setState(() {
      _schedules = schedules;
      _hasMorePages = hasMore;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}
```

**Load More Pages:**
```dart
Future<void> _loadMoreSchedules() async {
  if (_isLoadingMore || !_hasMorePages || _isLoading) return;  // ✅ Guards

  setState(() {
    _isLoadingMore = true;
  });

  try {
    final result = await _apiService.getAvailableSchedules(
      page: _currentPage + 1,  // ✅ Next page
      wasteType: _selectedWasteType,
      area: _selectedArea,
      date: _selectedDate != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null,
    );

    final moreSchedules = result['schedules'] as List<MitraPickupSchedule>;
    final hasMore = result['has_more'] as bool? ?? false;

    setState(() {
      if (moreSchedules.isEmpty) {
        _hasMorePages = false;  // ✅ No more pages
      } else {
        _schedules.addAll(moreSchedules);  // ✅ Append new schedules
        _currentPage++;                     // ✅ Increment page
        _hasMorePages = hasMore;            // ✅ Update flag
      }
      _isLoadingMore = false;
    });
  } catch (e) {
    setState(() {
      _isLoadingMore = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal lainnya: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
```

---

### 4. **UI Components**

**Page Info Card (Top):**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.blue[50],
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.blue[200]!),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Menampilkan ${_schedules.length} jadwal${_hasMorePages ? ' (Scroll ke bawah untuk lebih banyak)' : ''}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      if (_currentPage > 1)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Hal $_currentPage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  ),
)
```

**Loading Indicator (While Loading More):**
```dart
if (_isLoadingMore) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            'Memuat jadwal lainnya...',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
```

**End of List Message:**
```dart
if (!_hasMorePages && _schedules.isNotEmpty) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 40),
          const SizedBox(height: 8),
          Text(
            '✅ Semua jadwal telah ditampilkan',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Total: ${_schedules.length} jadwal',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Load More Button (Fallback):**
```dart
if (_hasMorePages) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: ElevatedButton.icon(
        onPressed: _loadMoreSchedules,
        icon: const Icon(Icons.expand_more),
        label: const Text('Muat Lebih Banyak'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    ),
  );
}
```

---

## 🎯 Features

### ✅ Implemented

1. **Infinite Scroll**
   - Automatically loads next page when user scrolls to 80% of list
   - Smooth loading without blocking UI
   - Separate loading indicator for "load more" state

2. **Page Indicator**
   - Shows current page number (if page > 1)
   - Shows total number of schedules loaded
   - Hint message: "Scroll ke bawah untuk lebih banyak"

3. **Manual Load More Button**
   - Fallback if auto-scroll doesn't trigger
   - User can manually tap to load next page
   - Only shown if there are more pages

4. **Loading States**
   - Initial loading (full screen loader)
   - Loading more (small indicator at bottom)
   - Separate state management to prevent conflicts

5. **End of List Message**
   - Clear message when all schedules loaded
   - Shows total count
   - Green checkmark icon for visual feedback

6. **Error Handling**
   - Toast notification if loading more fails
   - Doesn't break existing schedules
   - User can retry

7. **Pull to Refresh**
   - Existing feature still works
   - Resets pagination back to page 1
   - Clears all loaded schedules

8. **Filter Compatibility**
   - Pagination works with all filters
   - Filter changes reset to page 1
   - Each filtered result has its own pagination

---

## 📊 User Experience Flow

### Scenario 1: Fresh Load

```
User opens "Jadwal Tersedia" page
  ↓
[Loading spinner]
  ↓
✅ Shows 20 schedules (page 1)
  ↓
Info card: "Menampilkan 20 jadwal (Scroll ke bawah untuk lebih banyak)"
  ↓
User scrolls down...
```

### Scenario 2: Loading More

```
User scrolls to 80% of list
  ↓
[Small loading indicator appears at bottom]
"Memuat jadwal lainnya..."
  ↓
✅ 18 more schedules loaded (page 2)
  ↓
Total now: 38 schedules
Info card updated: "Menampilkan 38 jadwal | Hal 2"
  ↓
[End of list message]
"✅ Semua jadwal telah ditampilkan"
"Total: 38 jadwal"
```

### Scenario 3: With Filters

```
User applies filter (e.g., Waste Type = "Plastik")
  ↓
Pagination resets to page 1
  ↓
Shows filtered results (maybe 5 schedules)
  ↓
If results > 20, pagination continues
If results < 20, shows "Semua jadwal telah ditampilkan"
```

### Scenario 4: Manual Load

```
User sees "Muat Lebih Banyak" button
  ↓
Taps button
  ↓
[Loading indicator]
  ↓
Next page loads
```

---

## 🧪 Testing Checklist

### ✅ Functional Testing

- [ ] **Load Page 1**
  - Opens page successfully
  - Shows 20 schedules
  - Info card shows "Menampilkan 20 jadwal"
  - No page number shown (still page 1)

- [ ] **Scroll to Load More**
  - Scroll to 80% triggers loading
  - Loading indicator appears
  - Page 2 loads (18 schedules)
  - Total becomes 38 schedules
  - Page indicator shows "Hal 2"

- [ ] **End of List**
  - After page 2, shows end message
  - "✅ Semua jadwal telah ditampilkan"
  - "Total: 38 jadwal"
  - No more loading attempts

- [ ] **Manual Load Button**
  - Button appears if auto-scroll doesn't trigger
  - Tap button loads next page
  - Button disappears at end of list

- [ ] **Pull to Refresh**
  - Pull down refreshes list
  - Resets to page 1
  - All 38 schedules cleared and reloaded

- [ ] **Filters**
  - Apply waste type filter → resets to page 1
  - Apply area filter → resets to page 1
  - Apply date filter → resets to page 1
  - Clear filters → reloads all pages

- [ ] **Error Handling**
  - Network error shows toast
  - Existing schedules remain visible
  - Can retry loading more

---

### 🔍 Edge Cases

- [ ] **Empty Result**
  - No schedules available
  - Shows empty state message
  - No pagination controls

- [ ] **Exactly 20 Schedules**
  - Shows all 20
  - Tries to load page 2
  - Page 2 returns empty
  - Shows end message

- [ ] **Less than 20 Schedules**
  - Shows all available
  - No "load more" indicator
  - Shows end message immediately

- [ ] **Network Interruption**
  - Loading more fails mid-scroll
  - Shows error toast
  - Existing schedules still visible
  - Can scroll again to retry

- [ ] **Rapid Scrolling**
  - Multiple scroll events don't trigger duplicate loads
  - Guards prevent concurrent requests
  - Only one "load more" at a time

---

## 📈 Performance

### Optimizations

1. **Scroll Threshold: 80%**
   - Triggers early enough for smooth UX
   - Not too early to waste API calls
   - User doesn't notice loading

2. **Guards Against Duplicate Requests**
   ```dart
   if (_isLoadingMore || !_hasMorePages || _isLoading) return;
   ```
   - Prevents multiple simultaneous loads
   - Checks state before making request
   - Efficient API usage

3. **Separate Loading States**
   - `_isLoading`: Initial page load (blocks UI)
   - `_isLoadingMore`: Pagination load (small indicator)
   - Better UX, less disruptive

4. **Append vs Replace**
   ```dart
   _schedules.addAll(moreSchedules);  // Append to existing list
   ```
   - Keeps existing schedules in memory
   - No unnecessary re-renders
   - Smooth scroll experience

---

## 🐛 Known Limitations

### Backend Pagination Metadata Incomplete

**Issue:**
Backend currently returns:
```json
"pagination": {
  "current_page": null,
  "total": null
}
```

**Should return:**
```json
"pagination": {
  "current_page": 1,
  "last_page": 2,
  "total": 38,
  "per_page": 20,
  "has_more": true
}
```

**Workaround:**
Flutter uses `schedules.length >= 20` as heuristic for "has_more"

**Recommendation for Backend:**
Update `MitraPickupScheduleController.php`:
```php
return response()->json([
    'success' => true,
    'data' => [
        'schedules' => $schedules->items(),
        'pagination' => [
            'current_page' => $schedules->currentPage(),
            'last_page' => $schedules->lastPage(),
            'total' => $schedules->total(),
            'per_page' => $schedules->perPage(),
            'has_more' => $schedules->hasMorePages(),
        ]
    ]
]);
```

---

## 📝 Future Enhancements

### Potential Improvements

1. **Smart Preloading**
   - Load page 2 in background while user views page 1
   - Instant display when user scrolls

2. **Cached Pages**
   - Cache loaded pages in memory
   - Quick back navigation without re-fetch

3. **Skeleton Loading**
   - Show skeleton cards while loading
   - Better perceived performance

4. **Virtual Scrolling**
   - Render only visible items
   - Better performance with 100+ schedules

5. **Pagination Metadata Display**
   - Show "Page X of Y" when backend provides total
   - Progress bar for total schedules

---

## 🚀 Deployment Checklist

- [x] **Code Implementation**
  - [x] Update `MitraApiService.getAvailableSchedules()`
  - [x] Update `AvailableSchedulesPage` state management
  - [x] Add scroll controller
  - [x] Add loading states
  - [x] Add UI indicators

- [x] **Documentation**
  - [x] This document
  - [x] Code comments
  - [x] User-facing messages

- [ ] **Testing**
  - [ ] Manual testing on iOS
  - [ ] Manual testing on Android
  - [ ] Network error scenarios
  - [ ] Edge cases

- [ ] **Backend Communication**
  - [ ] Request pagination metadata improvement
  - [ ] Verify backend pagination working
  - [ ] Test with large datasets (100+ schedules)

---

## 📚 Related Documentation

- **Backend Docs:** `README_BACKEND_DOCS.md`
- **API Routes:** `lib/utils/api_routes.dart`
- **Model:** `lib/models/mitra_pickup_schedule.dart`

---

## ✅ Summary

**Problem:** User tidak bisa melihat jadwal dari user baru (ternyata ada di page 2)

**Solution:** Infinite scroll + manual load more + page indicators

**Result:** 
- ✅ User bisa lihat semua 38 jadwal
- ✅ Smooth UX dengan auto-scroll
- ✅ Clear feedback dengan indicators
- ✅ No breaking changes ke fitur existing

**Status:** ✅ **READY FOR TESTING**

---

*Dokumentasi dibuat: 13 November 2025*
