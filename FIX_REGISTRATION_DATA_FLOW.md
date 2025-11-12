# Fix Registrasi - Root Cause Analysis

## Masalah yang Ditemukan

### 1. Data Address & Phone Tidak Masuk Database

**Symptoms:**
- Saat registrasi, field `name`, `phone`, dan `address` bernilai NULL atau "New User" di database
- Console log menunjukkan: `📍 Address: null`, `📍 Coordinates: (null, null)`

**Root Cause:**
File `sign_up_subscription_page.dart` tidak meneruskan data lengkap ke `sign_up_success_page.dart`. Hanya mengirim:
```dart
arguments: {
  'email': user.email,
  'password': userData['password'],
  'hasSubscription': hasSubscription,
}
```

### 2. Name Menampilkan "New User"

**Root Cause:**
- Form sign-up mengirim key `'fullName'` 
- Success page membaca key `'name'`
- Ketika tidak ketemu, default ke `'New User'`

## Solusi yang Diterapkan

### Fix 1: Update sign_up_subscription_page.dart

**File:** `/lib/ui/pages/sign_up/sign_up_subscription_page.dart`

**Sebelum:**
```dart
Navigator.pushNamed(
  context,
  '/sign-up-success',
  arguments: {
    'email': user.email,
    'password': userData['password'],
    'hasSubscription': hasSubscription,
  },
);
```

**Sesudah:**
```dart
Navigator.pushNamed(
  context,
  '/sign-up-success',
  arguments: {
    'fullName': userData['fullName'] ?? userData['name'] ?? 'New User',
    'email': user.email,
    'password': userData['password'],
    'role': userData['role'] ?? 'end_user',
    'phone': userData['phone'],
    'address': userData['address'],
    'latitude': userData['latitude'],
    'longitude': userData['longitude'],
    'hasSubscription': hasSubscription,
  },
);
```

### Fix 2: Update sign_up_success_page.dart (Sudah dikerjakan sebelumnya)

**File:** `/lib/ui/pages/sign_up/sign_up_success_page.dart`

Membaca name dengan fallback:
```dart
final userName = args['fullName'] ?? args['name'] ?? 'New User';
```

Mengirim semua data ke API:
```dart
await authApiService.register(
  name: userName,
  email: args['email'],
  password: args['password'],
  role: args['role'] ?? 'end_user',
  phone: args['phone'],
  address: args['address'],
  latitude: args['latitude'],
  longitude: args['longitude'],
);
```

### Fix 3: Update auth_api_service.dart (Sudah dikerjakan sebelumnya)

**File:** `/lib/services/auth_api_service.dart`

Menambahkan parameter opsional:
```dart
Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  String? role,
  String? phone,      // ADDED
  String? address,    // ADDED
  double? latitude,   // ADDED
  double? longitude,  // ADDED
})
```

## Testing

### Backend API Test (SUKSES ✅)

```bash
curl -X POST http://127.0.0.1:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User Full",
    "email": "testfull@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "081234567890",
    "address": "Jl. Test Lengkap No. 123, Jakarta Selatan"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 9,
      "name": "Test User Full",
      "phone": "081234567890",
      "address": "Jl. Test Lengkap No. 123, Jakarta Selatan"
    }
  }
}
```

### Flutter App Test (Perlu dilakukan)

1. **Hot restart aplikasi Flutter** untuk memuat perubahan:
   ```
   Tekan 'R' di terminal Flutter
   ```

2. **Lakukan registrasi baru:**
   - Batch 1: Isi nama lengkap "Test User Baru"
   - Batch 2: Isi email "testbaru@example.com"
   - Batch 3: Isi password
   - Batch 4: Pilih lokasi dan isi alamat lengkap
   - Complete registration

3. **Cek console logs:**
   Harusnya muncul:
   ```
   flutter: 📍 Address: Jl. Test Lengkap...
   flutter: 📍 Coordinates: (-6.2088, 106.8456)
   flutter:   Name: Test User Baru
   flutter:   Email: testbaru@example.com
   flutter:   Phone: 081234567890
   flutter:   Address: Jl. Test...
   ```

4. **Verify database:**
   ```sql
   SELECT id, name, email, phone, address 
   FROM users 
   WHERE email = 'testbaru@example.com';
   ```
   
   Expected result:
   ```
   id: 10
   name: Test User Baru      (NOT "New User")
   email: testbaru@example.com
   phone: 081234567890
   address: Jl. Test Lengkap No...  (NOT NULL)
   ```

## File Yang Diubah

1. ✅ `/lib/services/auth_api_service.dart` - Added optional parameters
2. ✅ `/lib/ui/pages/sign_up/sign_up_success_page.dart` - Read fullName key & pass all data to API
3. ✅ `/lib/ui/pages/sign_up/sign_up_subscription_page.dart` - **BARU DIPERBAIKI** - Pass all user data to success page

## Impact

**Before Fix:**
- Name: "New User" (default value)
- Phone: NULL
- Address: NULL
- Latitude: NULL
- Longitude: NULL

**After Fix:**
- Name: Actual user input from form ✅
- Phone: Actual phone number ✅
- Address: Complete address from form ✅
- Latitude: Location coordinates ✅
- Longitude: Location coordinates ✅

## Catatan Penting

- Backend Laravel **SUDAH BERFUNGSI SEMPURNA** - tidak perlu perubahan
- Masalah ada di **data flow Flutter**: batch_4 → subscription → success → API
- Perubahan hanya di `sign_up_subscription_page.dart` (1 file)
- Backward compatible - jika field tidak ada, fallback ke nilai default
