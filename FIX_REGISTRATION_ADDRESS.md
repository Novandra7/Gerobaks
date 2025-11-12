# Fix: Registration Address & Name Not Saving to Database

## 🐛 Problems

### Problem 1: Address Not Saved
Saat registrasi user baru, **alamat tidak tersimpan di database** meskipun user sudah memasukkan alamat lengkap di form sign up batch 4.

### Problem 2: Name Shows as "New User"
User name yang diinput di form **tidak tersimpan dengan benar** di database. Database menunjukkan "New User" sebagai default value.

## 🔍 Root Cause Analysis

### Flow Registrasi:
1. **sign_up_page_batch_4.dart** → User input address
2. **user_service.dart** → Save user locally ✅ (address saved)
3. **sign_up_success_page.dart** → Call backend API ❌ (address NOT sent)
4. **auth_api_service.dart** → Register to backend ❌ (no address parameter)

### Masalah Ditemukan:

#### File 1: `lib/services/auth_api_service.dart`
```dart
// ❌ BEFORE - Missing address parameters
Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  String? role,
}) async {
  final resp = await _api.postJson(ApiRoutes.register, {
    'name': name,
    'email': email,
    'password': password,
    if (role != null) 'role': role,
    // Missing: phone, address, latitude, longitude
  });
}
```

#### File 2: `lib/ui/pages/sign_up/sign_up_success_page.dart`
```dart
// ❌ BEFORE - Not sending address data & wrong name key
await authApiService.register(
  name: args['name'] ?? 'New User',  // ❌ Wrong key! Form uses 'fullName'
  email: args['email'],
  password: args['password'],
  role: args['role'] ?? 'end_user',
  // Missing: phone, address, latitude, longitude from args
);
```

### Root Cause Summary:
1. **Address Issue**: Parameters tidak dikirim ke API backend
2. **Name Issue**: Form menggunakan key `'fullName'` tapi code membaca `'name'`
   - sign_up_page_batch_1.dart → sends `'fullName': _fullNameController.text`
   - sign_up_success_page.dart → reads `args['name']` ❌ (returns null)
   - Default fallback → `'New User'` ❌

## ✅ Solution

### Change 1: Update `auth_api_service.dart`

**Added parameters** untuk menerima data lokasi:

```dart
// ✅ AFTER - Complete with location data
Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  String? role,
  String? phone,           // ✅ NEW
  String? address,         // ✅ NEW
  double? latitude,        // ✅ NEW
  double? longitude,       // ✅ NEW
}) async {
  print('🔐 Registering user via API: $name ($email)');
  print('📍 Address: $address');
  print('📍 Coordinates: ($latitude, $longitude)');
  
  final resp = await _api.postJson(ApiRoutes.register, {
    'name': name,
    'email': email,
    'password': password,
    if (role != null) 'role': role,
    if (phone != null && phone.isNotEmpty) 'phone': phone,        // ✅ NEW
    if (address != null && address.isNotEmpty) 'address': address, // ✅ NEW
    if (latitude != null) 'latitude': latitude,                   // ✅ NEW
    if (longitude != null) 'longitude': longitude,                // ✅ NEW
  });
}
```

### Change 2: Update `sign_up_success_page.dart`

**Pass data lokasi** dari arguments ke API dan **fix name key mapping**:

```dart
// ✅ AFTER - Sending complete user data with correct name
// Extract name from either 'fullName' or 'name' key
final userName = args['fullName'] ?? args['name'] ?? 'New User';

await authApiService.register(
  name: userName,                 // ✅ FIXED - Now reads 'fullName' first
  email: args['email'],
  password: args['password'],
  role: args['role'] ?? 'end_user',
  phone: args['phone'],           // ✅ NEW
  address: args['address'],       // ✅ NEW
  latitude: args['latitude'],     // ✅ NEW
  longitude: args['longitude'],   // ✅ NEW
);
debugPrint('Backend API registration successful');
debugPrint('  Name: $userName');
debugPrint('  Email: ${args['email']}');
debugPrint('  Phone: ${args['phone']}');
debugPrint('  Address: ${args['address']}');
```

## 📊 Data Flow (After Fix)

```
┌─────────────────────────┐
│ sign_up_page_batch_4    │
│ User inputs:            │
│ - Address text          │
│ - Pin location on map   │
│ - Lat/Lng coordinates   │
└───────────┬─────────────┘
            │ userData = {
            │   'address': '...',
            │   'latitude': -6.xxx,
            │   'longitude': 106.xxx
            │ }
            ↓
┌─────────────────────────┐
│ user_service.dart       │
│ registerUser()          │
│ ✅ Saves locally        │
└───────────┬─────────────┘
            │ passes userData
            ↓
┌─────────────────────────┐
│ sign_up_success_page    │
│ Receives args with:     │
│ - address               │
│ - latitude              │
│ - longitude             │
└───────────┬─────────────┘
            │ ✅ Now passes all data
            ↓
┌─────────────────────────┐
│ auth_api_service.dart   │
│ register()              │
│ ✅ Sends to backend API │
└───────────┬─────────────┘
            │ POST /api/register
            ↓
┌─────────────────────────┐
│ Laravel Backend         │
│ ✅ Saves to database    │
│   users table:          │
│   - address             │
│   - phone               │
│   - (lat/lng if needed) │
└─────────────────────────┘
```

## 🧪 Testing Steps

### 1. Test New Registration

1. **Open App** dan navigate ke Sign Up
2. **Fill Form Batch 1-3**:
   - **Full Name**: "Test User" ✅
   - Email: "test@example.com"
   - Phone: "081234567890"
   - Password: "password123"

3. **Fill Form Batch 4** (Alamat):
   - **Manual Input**: Ketik alamat lengkap
   - **Or Map Selection**: Pin lokasi di map
   - Address Example: "Jl. Sudirman No. 123, Jakarta Pusat"
   - Coordinates will auto-fill

4. **Complete Registration**:
   - Continue to Success Page
   - Wait for API registration

5. **Check Console Logs**:
   ```
   🔐 Registering user via API: Test User (test@example.com)
   📍 Address: Jl. Sudirman No. 123, Jakarta Pusat
   📍 Coordinates: (-6.2088, 106.8456)
   ✅ API registration successful
   Backend API registration successful
     Name: Test User
     Email: test@example.com
     Phone: 081234567890
     Address: Jl. Sudirman No. 123, Jakarta Pusat
   ```

### 2. Verify Database

**Open phpMyAdmin**: http://localhost/phpmyadmin

**Query:**
```sql
SELECT 
  id,
  name,
  email,
  phone,
  address,
  role,
  created_at
FROM users
WHERE email = 'test@example.com'
ORDER BY created_at DESC
LIMIT 1;
```

**Expected Result:**
| id | name | email | phone | address | role |
|----|------|-------|-------|---------|------|
| X | **Test User** | test@example.com | 081234567890 | Jl. Sudirman No. 123, Jakarta Pusat | end_user |

✅ **Before Fix**: name = "New User" ❌  
✅ **After Fix**: name = "Test User" ✅

### 3. Test Existing Features

**Verify alamat digunakan di:**
- ✅ Add Schedule Page (auto-fill address)
- ✅ Profile Page (display address)
- ✅ Edit Profile (update address)

## 🔍 Debug Tips

### Check if Address is Passed

**In `sign_up_page_batch_4.dart`**, before navigation:
```dart
print('📍 userData address: ${userData['address']}');
print('📍 userData latitude: ${userData['latitude']}');
print('📍 userData longitude: ${userData['longitude']}');
```

**In `sign_up_success_page.dart`**, when receiving args:
```dart
print('📦 Received args: $args');
print('📍 Name from args (fullName): ${args['fullName']}');
print('📍 Name from args (name): ${args['name']}');
print('📍 Address from args: ${args['address']}');
```

### Check Backend API Request

**Using curl** (replace with actual values):
```bash
curl -X POST http://127.0.0.1:8000/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "phone": "081234567890",
    "address": "Jl. Sudirman No. 123, Jakarta Pusat",
    "role": "end_user"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "Test User",
      "email": "test@example.com",
      "phone": "081234567890",
      "address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "role": "end_user"
    },
    "token": "1|xxxxxxxxxxxxx"
  }
}
```

## 📝 Backend Requirements

### Laravel Migration

Pastikan tabel `users` memiliki kolom:

```php
// database/migrations/xxxx_create_users_table.php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email')->unique();
    $table->string('phone')->nullable();
    $table->text('address')->nullable();  // ✅ Required
    $table->string('password');
    $table->enum('role', ['end_user', 'mitra', 'admin'])->default('end_user');
    $table->timestamps();
});
```

### Laravel Controller

**app/Http/Controllers/Api/AuthController.php**:

```php
public function register(Request $request)
{
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:6',
        'phone' => 'nullable|string',
        'address' => 'nullable|string',  // ✅ Accept address
        'latitude' => 'nullable|numeric',
        'longitude' => 'nullable|numeric',
        'role' => 'nullable|in:end_user,mitra,admin',
    ]);

    $user = User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'password' => Hash::make($validated['password']),
        'phone' => $validated['phone'] ?? null,
        'address' => $validated['address'] ?? null,  // ✅ Save address
        'role' => $validated['role'] ?? 'end_user',
    ]);

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'success' => true,
        'data' => [
            'user' => $user,
            'token' => $token,
        ]
    ]);
}
```

## ⚠️ Important Notes

### 1. Backward Compatibility
- `phone`, `address`, `latitude`, `longitude` are **optional**
- Old registration flows without these fields will still work
- Uses conditional `if` checks: `if (address != null && address.isNotEmpty)`

### 2. Data Validation
- Address validated on backend (nullable)
- Frontend ensures data is passed if available
- Console logs help track data flow

### 3. Local vs Remote Storage
- **Local Storage** (UserService): Always has address ✅
- **Remote Database**: Now also has address ✅
- Both are in sync after this fix

## 🎯 Summary

### What Was Fixed:
1. ✅ `auth_api_service.dart` - Added address parameters
2. ✅ `sign_up_success_page.dart` - Passes address to API
3. ✅ `sign_up_success_page.dart` - **Fixed name key mapping (`fullName` → `name`)**
4. ✅ Added debug logging for tracking
5. ✅ Maintains backward compatibility

### What Works Now:
- ✅ **Name** correctly saved (not "New User")
- ✅ Address saved to local storage
- ✅ Address sent to backend API
- ✅ Address persisted in database
- ✅ Address available for pickup schedules
- ✅ Address shown in profile

### Impact:
- **Before**: 
  - Name = "New User" (wrong ❌)
  - Address only in app memory (lost after logout)
- **After**: 
  - Name = User's actual name ✅
  - Address persisted in database ✅

---

**Status:** ✅ FIXED
**Date:** November 12, 2025
**Files Changed:** 2
**Lines Added:** ~20
**Backward Compatible:** Yes
