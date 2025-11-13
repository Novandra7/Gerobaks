# 🧪 Testing Guide: Detail Aktivitas User

**Fitur:** Detail hasil inputan user pada aktivitas yang sudah selesai  
**Status:** ✅ **IMPLEMENTED** - Ready for testing  
**Tanggal:** 13 November 2025

---

## 📋 Status Implementation

### ✅ Yang Sudah Selesai:

1. **Data Parsing Logic** ✅
   - Parse `actual_weights` dari API response
   - Handle tipe data String/Number dengan defensive parsing
   - Kalkulasi total weight dan total points
   - Extract foto bukti dan nama petugas
   - Icon mapping untuk 5+ jenis sampah

2. **UI Components** ✅
   - Modal detail untuk quick view
   - Draggable bottom sheet untuk full detail
   - Ringkasan section dengan highlights
   - List detail sampah per jenis dengan icon
   - Grid foto bukti dengan zoom functionality
   - Conditional rendering berdasarkan status

3. **Debug Logging** ✅
   - Print statements untuk tracking parsing
   - Memudahkan debugging saat testing

---

## 🎯 Testing Scenarios

### Scenario 1: Aktivitas Dijadwalkan (CURRENT STATE)

**Status:** "Dijadwalkan" (scheduled)

**Expected Behavior:**
- ✅ Modal menampilkan status badge "Dijadwalkan" (warna orange)
- ✅ Tombol "Atur Ulang Jadwal" muncul
- ✅ Tombol "Batalkan" muncul
- ❌ Tombol "Lihat Detail Lengkap" **TIDAK muncul** (karena belum selesai)

**Result:** ✅ **PASSED** (sesuai screenshot)

---

### Scenario 2: Aktivitas Selesai (PENDING - Need Completed Data)

**Status:** "Selesai" (completed)

**Required Data:**
- Schedule dengan `status = "completed"`
- `actual_weights` berisi Map jenis sampah dan berat
- `pickup_photos` berisi array URL foto
- `mitra_name` berisi nama petugas
- `notes` optional

**Expected Behavior:**

#### A. Quick Modal
- ✅ Modal menampilkan status badge "Selesai" (warna hijau)
- ✅ Tombol "Lihat Detail Lengkap" muncul (warna hijau)
- ❌ Tombol "Atur Ulang Jadwal" **TIDAK muncul**
- ❌ Tombol "Batalkan" **TIDAK muncul**

#### B. Detail Sheet (After Click "Lihat Detail Lengkap")
- ✅ Draggable bottom sheet muncul
- ✅ **Ringkasan Section:**
  - Total Berat: XX kg
  - Total Jenis: X jenis
  - Total Poin: XX poin (highlighted hijau)
  - Petugas: [Nama Mitra]

- ✅ **Detail Sampah Section:**
  - List card per jenis sampah
  - Icon sesuai jenis (organik, plastik, kertas, dll)
  - Berat dalam kg
  - Poin yang didapat (+XX poin)

- ✅ **Bukti Foto Section:**
  - Grid 2 kolom
  - Thumbnail foto
  - Tap foto → fullscreen zoom
  - Pinch to zoom (0.5x - 4x)

- ✅ **Catatan Section:**
  - Text notes dari pengambilan
  - Hanya muncul jika ada notes

**Result:** ⏳ **PENDING** - Menunggu data completed untuk testing

---

## 🔧 How to Create Test Data

### Option 1: Via Mitra App

1. **Login sebagai mitra** (driver.jakarta@gerobaks.com)
2. **Accept schedule** yang available
3. **Start pickup** (ubah status ke "on the way")
4. **Arrive at location** (ubah status ke "arrived")
5. **Complete pickup:**
   - Input berat sampah per jenis
   - Upload foto bukti
   - Tambah notes (optional)
   - Submit
6. **Verify** schedule jadi status "completed"

### Option 2: Via API Direct (Development Only)

```bash
# 1. Login sebagai mitra
TOKEN=$(curl -s -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"driver.jakarta@gerobaks.com","password":"password123"}' \
  | jq -r '.data.token')

# 2. Get available schedule ID
SCHEDULE_ID=$(curl -s -X GET "http://127.0.0.1:8000/api/mitra/pickup-schedules/available" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -r '.data.schedules[0].id')

# 3. Accept schedule
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/$SCHEDULE_ID/accept" \
  -H "Authorization: Bearer $TOKEN"

# 4. Start pickup
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/$SCHEDULE_ID/start" \
  -H "Authorization: Bearer $TOKEN"

# 5. Complete pickup dengan data
curl -X POST "http://127.0.0.1:8000/api/mitra/pickup-schedules/$SCHEDULE_ID/complete" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: multipart/form-data" \
  -F "actual_weights[Organik]=3" \
  -F "actual_weights[Plastik]=2" \
  -F "actual_weights[Kertas]=1" \
  -F "photos[]=@/path/to/photo1.jpg" \
  -F "photos[]=@/path/to/photo2.jpg" \
  -F "notes=Sampah sudah ditimbang dan dicatat"
```

### Option 3: Database Direct (Quick Testing)

```sql
-- Update existing schedule to completed
UPDATE pickup_schedules 
SET 
  status = 'completed',
  completed_at = NOW(),
  actual_weights = '{"Organik": 3, "Plastik": 2, "Kertas": 1, "Kaca": 1, "Logam": 1, "Anorganik": 2}',
  total_weight = 10,
  pickup_photos = '["/storage/pickups/test/photo1.jpg", "/storage/pickups/test/photo2.jpg"]',
  notes = 'Sampah sudah ditimbang dan dicatat dengan baik'
WHERE id = [SCHEDULE_ID];
```

---

## 📱 Testing Steps (When Data Available)

### Step 1: Launch App
```bash
cd /Users/ajiali/Development/projects/Gerobaks
flutter run
```

### Step 2: Login as End User
- Email: `ali@gmail.com`
- Password: `Password123`

### Step 3: Navigate to Activity Tab
- Tap **"Riwayat"** tab di bottom navigation
- Pastikan tab **"Riwayat"** aktif (bukan "Jadwal")

### Step 4: Find Completed Activity
- Scroll cari aktivitas dengan badge hijau **"Selesai"**
- Atau lihat di list yang menampilkan poin (+XX poin)

### Step 5: Test Quick Modal
- **Tap aktivitas card** atau **tap "Detail" button**
- ✅ Verify modal muncul
- ✅ Verify status badge "Selesai" (hijau)
- ✅ Verify tombol "Lihat Detail Lengkap" ada (hijau)
- ✅ Verify tombol lain tidak ada (Atur Ulang, Batalkan)

### Step 6: Test Detail Sheet
- **Tap "Lihat Detail Lengkap"**
- ✅ Verify bottom sheet muncul dengan drag handle
- ✅ Verify dapat di-drag up/down

### Step 7: Verify Ringkasan Section
- ✅ Total Berat menampilkan nilai correct (XX kg)
- ✅ Total Jenis menampilkan jumlah correct (X jenis)
- ✅ Total Poin dengan background hijau (+XX poin)
- ✅ Petugas menampilkan nama mitra

### Step 8: Verify Detail Sampah List
- ✅ List menampilkan semua jenis sampah
- ✅ Setiap item punya icon correct:
  - Organik → ic_transaction_cat1.png (hijau)
  - Plastik → ic_transaction_cat2.png (biru)
  - Kertas → ic_transaction_cat3.png (kuning)
  - Kaca/Logam → ic_transaction_cat4.png (abu)
  - Elektronik/B3 → ic_transaction_cat5.png (merah)
- ✅ Berat ditampilkan dalam kg
- ✅ Poin ditampilkan dengan benar (+XX poin)
- ✅ Kalkulasi: poin = berat × 10

### Step 9: Verify Foto Bukti Section
- ✅ Grid 2 kolom menampilkan semua foto
- ✅ Thumbnail foto terlihat jelas
- ✅ Tap salah satu foto
- ✅ Fullscreen image viewer muncul
- ✅ Pinch to zoom berfungsi
- ✅ Pan/drag foto berfungsi
- ✅ Tap X atau outside → kembali ke detail sheet

### Step 10: Verify Catatan Section
- ✅ Jika ada notes → section "Catatan" muncul
- ✅ Text notes ditampilkan dengan benar
- ✅ Jika tidak ada notes → section tidak muncul

### Step 11: Test Closing
- ✅ Swipe down detail sheet → modal menutup
- ✅ Tap X button → modal menutup
- ✅ Kembali ke activity list

---

## 🐛 Debug Console Output (Expected)

Saat ada schedule completed, console akan print:

```
🔍 Parsing completed schedule #51
   📦 Actual weights: {Organik: 3, Plastik: 2, Kertas: 1, Kaca: 1, Logam: 1, Anorganik: 2}
   ✅ Organik: 3kg = 30 poin
   ✅ Plastik: 2kg = 20 poin
   ✅ Kertas: 1kg = 10 poin
   ✅ Kaca: 1kg = 10 poin
   ✅ Logam: 1kg = 10 poin
   ✅ Anorganik: 2kg = 20 poin
   📊 Total: 10kg, 100 poin, 6 jenis
```

Jika tidak ada output ini, berarti:
- Tidak ada schedule dengan status "completed", ATAU
- `actual_weights` null/empty

---

## ✅ Test Checklist

### Data Parsing ✅
- [x] `_parseDouble()` handle String/Number
- [x] `_normalizeActualWeights()` handle Map/Array
- [x] Parse actual_weights ke List<TrashDetail>
- [x] Kalkulasi total weight correct
- [x] Kalkulasi total points correct (weight × 10)
- [x] Parse pickup_photos ke List<String>
- [x] Parse mitra_name ke completedBy
- [x] Parse notes jika ada
- [x] `_getTrashIcon()` map jenis ke icon correct

### UI Components ✅
- [x] Quick modal dengan conditional buttons
- [x] Status badge dengan warna correct per status
- [x] Draggable bottom sheet
- [x] Ringkasan card dengan highlight
- [x] Detail sampah list dengan icon
- [x] Foto grid 2 kolom
- [x] Fullscreen image viewer
- [x] Pinch to zoom functionality
- [x] Catatan section (conditional)
- [x] Close buttons berfungsi

### Edge Cases (TODO - After Data Available)
- [ ] Handle schedule tanpa actual_weights
- [ ] Handle schedule tanpa pickup_photos
- [ ] Handle schedule tanpa mitra_name
- [ ] Handle schedule tanpa notes
- [ ] Handle jenis sampah tidak terdaftar (default icon)
- [ ] Handle foto URL invalid
- [ ] Handle actual_weights dengan value 0
- [ ] Handle actual_weights dengan tipe data unexpected

---

## 📊 Current Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Data Parsing Logic | ✅ Complete | Dengan defensive parsing & debug logs |
| UI Components | ✅ Complete | Modal + Detail Sheet fully implemented |
| Icon Mapping | ✅ Complete | 5 kategori + default |
| Debug Logging | ✅ Complete | Print statements untuk tracking |
| Test Data | ⏳ Pending | Need completed schedule dari backend |
| Full Testing | ⏳ Pending | Menunggu test data |

---

## 🚀 Next Steps

### Immediate (For Testing):

1. **Create Completed Schedule:**
   ```bash
   # Via mitra app atau API
   # Buat 1-2 schedule completed dengan berbagai jenis sampah
   ```

2. **Test Full Flow:**
   - Login end user
   - Lihat aktivitas selesai
   - Klik detail lengkap
   - Verify semua data tampil correct
   - Test zoom foto
   - Test close modal

3. **Verify Debug Logs:**
   ```
   # Check console output untuk:
   🔍 Parsing completed schedule #XX
   📦 Actual weights: {...}
   ✅ [Jenis]: XXkg = XX poin
   📊 Total: XXkg, XX poin, X jenis
   ```

4. **Edge Case Testing:**
   - Schedule tanpa foto
   - Schedule tanpa notes
   - Schedule dengan 1 jenis sampah only
   - Schedule dengan banyak foto (5+)

### Future Enhancements:

- [ ] Download foto ke gallery
- [ ] Share hasil pengambilan
- [ ] Export ke PDF/print receipt
- [ ] Chart statistik poin
- [ ] Comparison dengan period sebelumnya
- [ ] Achievement badges

---

## 📞 Troubleshooting

### Issue: Tombol "Lihat Detail Lengkap" tidak muncul

**Kemungkinan Penyebab:**
1. Status bukan "selesai" (completed)
2. `isActive = true` (masih aktif)

**Solution:**
```dart
// Check kondisi di activity_detail_modal.dart line 193-209:
if (!activity.isActive && activity.status.toLowerCase() == 'selesai')
```

---

### Issue: Detail sheet kosong/tidak ada data

**Kemungkinan Penyebab:**
1. `actual_weights` null dari API
2. `trashDetails` tidak ter-parse

**Solution:**
```bash
# Check console logs:
grep "🔍 Parsing completed" logs.txt
grep "📦 Actual weights" logs.txt

# Jika tidak ada output → actual_weights null
# Check API response:
curl ... | jq '.data.schedules[] | select(.status == "completed") | .actual_weights'
```

---

### Issue: Icon tidak sesuai jenis sampah

**Kemungkinan Penyebab:**
1. Nama jenis sampah beda dengan expected
2. Icon file tidak ada di assets

**Solution:**
```dart
// Check _getTrashIcon() di activity_content_improved.dart line 400-418
// Tambah logging:
print('Icon for $trashType: ${_getTrashIcon(trashType)}');

// Verify assets exist:
ls -la assets/ic_transaction_cat*.png
```

---

### Issue: Foto tidak bisa di-zoom

**Kemungkinan Penyebab:**
1. InteractiveViewer tidak berfungsi
2. Image path invalid

**Solution:**
```dart
// Check activity_detail_modal.dart _showFullScreenImage()
// Verify:
- InteractiveViewer wraps image ✅
- minScale = 0.5, maxScale = 4 ✅
- panEnabled = true ✅
```

---

## 📚 Related Documentation

- **Implementation Details:** `docs/FITUR_DETAIL_AKTIVITAS.md`
- **Backend Bug Documentation:** `docs/BACKEND_BUG_HISTORY_ENDPOINT.md`
- **API Endpoints:** Check backend routes for `/api/schedules`
- **Model Definitions:** `lib/models/activity_model_improved.dart`

---

*Testing Guide created: 13 November 2025*  
*Last Updated: 13 November 2025*  
*Status: Ready for testing with completed data*
