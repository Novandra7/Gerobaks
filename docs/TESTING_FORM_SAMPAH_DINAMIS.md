# Testing Guide: Form Berat Sampah Dinamis

## 🎯 Quick Test Scenarios

### ✅ Test 1: Single Type (Campuran)

**Steps:**
1. Login sebagai end user
2. Buat jadwal dengan jenis sampah: **Campuran**
3. Login sebagai mitra
4. Accept schedule tersebut
5. Buka "Selesaikan Pengambilan"

**Expected Result:**
```
✅ Console log: "📦 Scheduled waste types: Campuran"
✅ Console log: "✅ Single type: Campuran"
✅ UI: 1 chip tampil → "Campuran"
✅ UI: 1 form field → "Campuran"
✅ UI: Text → "Isi berat untuk 1 jenis sampah yang dijadwalkan"
```

---

### ✅ Test 2: Single Type (Organik)

**Steps:**
1. Login sebagai end user
2. Buat jadwal dengan jenis sampah: **Organik**
3. Login sebagai mitra
4. Accept schedule tersebut
5. Buka "Selesaikan Pengambilan"

**Expected Result:**
```
✅ Console log: "📦 Scheduled waste types: Organik"
✅ Console log: "✅ Single type: Organik"
✅ UI: 1 chip tampil → "Organik"
✅ UI: 1 form field → "Organik"
✅ UI: Text → "Isi berat untuk 1 jenis sampah yang dijadwalkan"
```

---

### ✅ Test 3: Multiple Types (Manual Database)

**Setup:**
Manually update database untuk test multiple types:
```sql
UPDATE pickup_schedules 
SET waste_type_scheduled = 'Organik,Plastik,Kertas' 
WHERE id = 57;
```

**Steps:**
1. Login sebagai mitra
2. Accept schedule id 57
3. Buka "Selesaikan Pengambilan"

**Expected Result:**
```
✅ Console log: "📦 Scheduled waste types: Organik,Plastik,Kertas"
✅ Console log: "✅ Parsed 3 types: [Organik, Plastik, Kertas]"
✅ UI: 3 chips tampil → "Organik", "Plastik", "Kertas"
✅ UI: 3 form fields
✅ UI: Text → "Isi berat untuk 3 jenis sampah yang dijadwalkan"
```

---

### ✅ Test 4: With Spaces (Manual Database)

**Setup:**
```sql
UPDATE pickup_schedules 
SET waste_type_scheduled = ' Organik , Plastik , Logam ' 
WHERE id = 58;
```

**Steps:**
1. Login sebagai mitra
2. Accept schedule id 58
3. Buka "Selesaikan Pengambilan"

**Expected Result:**
```
✅ Console log: "📦 Scheduled waste types:  Organik , Plastik , Logam "
✅ Console log: "✅ Parsed 3 types: [Organik, Plastik, Logam]"
✅ UI: 3 chips tampil → "Organik", "Plastik", "Logam" (no spaces)
✅ UI: 3 form fields
✅ UI: Text → "Isi berat untuk 3 jenis sampah yang dijadwalkan"
```

---

### ✅ Test 5: Empty (Fallback)

**Setup:**
```sql
UPDATE pickup_schedules 
SET waste_type_scheduled = '' 
WHERE id = 59;
```

**Steps:**
1. Login sebagai mitra
2. Accept schedule id 59
3. Buka "Selesaikan Pengambilan"

**Expected Result:**
```
✅ Console log: "📦 Scheduled waste types: "
✅ Console log: "⚠️  Empty waste_type_scheduled, using fallback"
✅ UI: 6 chips tampil → All types
✅ UI: 6 form fields
✅ UI: Text → "Isi berat untuk 6 jenis sampah yang dijadwalkan"
```

---

### ✅ Test 6: Form Submission

**Steps:**
1. Open schedule dengan 2 types: "Organik,Plastik"
2. Fill form:
   - Organik: 5.5 kg
   - Plastik: 2.3 kg
3. Add 2 photos
4. Add notes
5. Submit

**Expected Result:**
```
✅ Form submits successfully
✅ actual_weights = {"Organik": 5.5, "Plastik": 2.3}
✅ total_weight = 7.8
✅ Status → "completed"
✅ End user can see detail with correct weights
```

---

### ✅ Test 7: Validation

**Steps:**
1. Open schedule dengan 1 type: "Organik"
2. Leave weight field empty
3. Try to submit

**Expected Result:**
```
✅ Validation error: "Masukkan berat Organik"
✅ Form does not submit
✅ Error message displayed in red
```

**Steps (continued):**
4. Enter invalid value: "abc"
5. Try to submit

**Expected Result:**
```
✅ Validation error: "Berat harus berupa angka"
✅ Form does not submit
```

**Steps (continued):**
6. Enter zero: "0"
7. Try to submit

**Expected Result:**
```
✅ Validation error: "Berat harus lebih dari 0"
✅ Form does not submit
```

---

## 🔧 Manual Database Testing

### Setup Multiple Types
```sql
-- Test dengan 2 types
UPDATE pickup_schedules 
SET waste_type_scheduled = 'Organik,Plastik' 
WHERE id IN (56, 57);

-- Test dengan 3 types
UPDATE pickup_schedules 
SET waste_type_scheduled = 'Organik,Plastik,Kertas' 
WHERE id IN (58, 59);

-- Test dengan 5 types
UPDATE pickup_schedules 
SET waste_type_scheduled = 'Organik,Anorganik,Plastik,Kertas,Logam' 
WHERE id = 60;

-- Verify
SELECT id, waste_type_scheduled FROM pickup_schedules 
WHERE id BETWEEN 56 AND 60;
```

### Restore to Single Type
```sql
UPDATE pickup_schedules 
SET waste_type_scheduled = 'Campuran' 
WHERE id BETWEEN 56 AND 60;
```

---

## 📊 Console Log Monitoring

### Enable Debug Logs
Debug logs automatically appear in VS Code Debug Console or Terminal:

```
flutter: 📦 Scheduled waste types: Organik,Plastik,Kertas
flutter: ✅ Parsed 3 types: [Organik, Plastik, Kertas]
```

### Filter Logs
In terminal:
```bash
flutter run | grep "📦\|✅\|⚠️"
```

---

## ✅ Acceptance Criteria

### Functionality
- [ ] Single type: Shows 1 field
- [ ] Multiple types (comma-separated): Shows N fields
- [ ] Empty type: Shows all 6 fields (fallback)
- [ ] Whitespace trimmed correctly
- [ ] Chips display all scheduled types
- [ ] Form text shows correct count
- [ ] Controllers created only for scheduled types
- [ ] Validation works for all types
- [ ] Submission includes only scheduled types

### UI/UX
- [ ] Chips have green background
- [ ] Chips have green border
- [ ] Text shows: "Isi berat untuk N jenis sampah..."
- [ ] Form fields match chip order
- [ ] No scrolling needed for 1-3 types
- [ ] Clean layout with proper spacing

### Edge Cases
- [ ] Empty waste_type_scheduled → Fallback
- [ ] Whitespace in types → Trimmed
- [ ] Trailing comma: "Organik," → ["Organik"]
- [ ] Multiple commas: "Organik,,,Plastik" → ["Organik", "Plastik"]
- [ ] Case preserved: "organik" stays "organik"

### Backend Integration
- [ ] actual_weights contains only scheduled types
- [ ] total_weight calculated correctly
- [ ] Status updated to "completed"
- [ ] Photos uploaded successfully
- [ ] Notes saved correctly

---

## 🐛 Common Issues

### Issue 1: Still Shows All 6 Types
**Cause:** Hot reload not applied
**Fix:**
```bash
# Press 'r' in terminal for hot reload
# Or press 'R' for full restart
```

### Issue 2: Console Logs Not Showing
**Cause:** Debug console not active
**Fix:**
1. Open VS Code Debug Console (Cmd+Shift+Y)
2. Or check Terminal running flutter

### Issue 3: Chips Not Displayed
**Cause:** Empty waste_type_scheduled
**Check:**
```dart
print('DEBUG: ${widget.schedule.wasteTypeScheduled}');
```

### Issue 4: Form Validation Fails
**Cause:** Controller not initialized
**Check:**
```dart
print('Controllers: ${_weightControllers.keys}');
print('Waste types: $_wasteTypes');
```

---

## 📱 Visual Regression Testing

### Before (Static)
```
Berat Sampah (kg) *
Isi berat untuk setiap jenis sampah yang diambil

┌─────────────────┐
│ Organik     kg  │
│ [___________]   │
└─────────────────┘
┌─────────────────┐
│ Anorganik   kg  │
│ [___________]   │
└─────────────────┘
... (4 more fields)
```

### After (Dynamic - 2 types)
```
Berat Sampah (kg) *
Isi berat untuk 2 jenis sampah yang dijadwalkan

┌─────────┐ ┌─────────┐
│ Organik │ │ Plastik │
└─────────┘ └─────────┘

┌─────────────────┐
│ Organik     kg  │
│ [___________]   │
└─────────────────┘
┌─────────────────┐
│ Plastik     kg  │
│ [___________]   │
└─────────────────┘
```

---

## 🚀 Performance Testing

### Metrics to Check
- [ ] Page load time < 1s
- [ ] Smooth scrolling
- [ ] No frame drops during input
- [ ] Photo upload responsive

### Test with Different Counts
```
1 type:  Page loads in ~500ms
2 types: Page loads in ~550ms
3 types: Page loads in ~600ms
6 types: Page loads in ~800ms (fallback)
```

---

## ✅ Final Checklist

Before marking feature as complete:

### Code
- [x] Code compiles without errors
- [x] No warnings in console
- [x] Debug logs working
- [x] Comments added

### Testing
- [ ] Tested single type
- [ ] Tested multiple types (via DB)
- [ ] Tested empty (fallback)
- [ ] Tested with spaces
- [ ] Tested form submission
- [ ] Tested validation
- [ ] Tested on Android/iOS

### Documentation
- [x] Feature documentation created
- [x] Testing guide created
- [x] Code comments added
- [x] README updated (if needed)

### Integration
- [ ] Works with existing backend
- [ ] No breaking changes
- [ ] Backward compatible
- [ ] End user can see results

---

## 📞 Support

If you encounter issues:
1. Check console logs for debug messages
2. Verify database `waste_type_scheduled` value
3. Try full app restart (press 'R')
4. Check documentation: `FITUR_FORM_SAMPAH_DINAMIS.md`

---

**Happy Testing! 🎉**
