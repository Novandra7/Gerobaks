# Backend API Endpoint - Check Email

## Endpoint Baru yang Perlu Ditambahkan

### GET `/api/check-email`

**Deskripsi:** Check apakah email sudah terdaftar di database

**Query Parameters:**
- `email` (required, string) - Email address yang akan dicek

**Response Success (200):**
```json
{
  "exists": false,
  "message": "Email available"
}
```

**Response Email Sudah Ada (200):**
```json
{
  "exists": true,
  "message": "Email already registered"
}
```

**Response Validation Error (422):**
```json
{
  "exists": false,
  "message": "Invalid email format"
}
```

## Implementasi Laravel

### 1. Route (routes/api.php)
```php
// Add this to your api.php routes file
Route::get('/check-email', [AuthController::class, 'checkEmail']);
```

### 2. Controller Method (app/Http/Controllers/AuthController.php)
```php
public function checkEmail(Request $request)
{
    $request->validate([
        'email' => 'required|email',
    ]);

    $exists = \App\Models\User::where('email', $request->email)->exists();

    return response()->json([
        'exists' => $exists,
        'message' => $exists 
            ? 'Email already registered' 
            : 'Email available',
    ]);
}
```

### 3. Alternative: Jika ingin lebih detail
```php
public function checkEmail(Request $request)
{
    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'exists' => false,
            'message' => 'Invalid email format',
        ], 422);
    }

    $user = \App\Models\User::where('email', $request->email)->first();

    if ($user) {
        return response()->json([
            'exists' => true,
            'message' => 'Email already registered',
            'registered_at' => $user->created_at->format('Y-m-d H:i:s'),
        ]);
    }

    return response()->json([
        'exists' => false,
        'message' => 'Email available',
    ]);
}
```

## Testing

### cURL Test
```bash
# Test with existing email
curl -X GET "http://127.0.0.1:8000/api/check-email?email=ajialii@gmail.com"

# Test with new email
curl -X GET "http://127.0.0.1:8000/api/check-email?email=newemail@example.com"

# Test with invalid email
curl -X GET "http://127.0.0.1:8000/api/check-email?email=invalid-email"
```

### Expected Results

**Existing Email:**
```json
{
  "exists": true,
  "message": "Email already registered"
}
```

**New Email:**
```json
{
  "exists": false,
  "message": "Email available"
}
```

## Security Considerations

1. **Rate Limiting:** Add rate limiting to prevent email enumeration attacks
```php
// In RouteServiceProvider or routes/api.php
Route::middleware(['throttle:10,1'])->group(function () {
    Route::get('/check-email', [AuthController::class, 'checkEmail']);
});
```

2. **Optional: Add delay untuk mencegah timing attacks**
```php
public function checkEmail(Request $request)
{
    $request->validate(['email' => 'required|email']);
    
    // Add small random delay to prevent timing attacks
    usleep(mt_rand(100000, 300000)); // 100-300ms
    
    $exists = \App\Models\User::where('email', $request->email)->exists();
    
    return response()->json([
        'exists' => $exists,
        'message' => $exists ? 'Email already registered' : 'Email available',
    ]);
}
```

## Integration with Flutter App

Setelah endpoint ini ditambahkan, Flutter app akan:

1. User mengisi form di **Batch 1** (Nama, Email, Phone)
2. User klik button **"Lanjutkan"**
3. App call API `GET /api/check-email?email={email}`
4. Jika `exists: true` → Show error dialog "Email Sudah Terdaftar"
5. Jika `exists: false` → Lanjut ke Batch 2 (Password)

## Benefits

✅ Validasi email di awal proses registrasi
✅ User tidak perlu mengisi semua form baru tahu email sudah terdaftar  
✅ Better UX - error muncul lebih cepat
✅ Mengurangi beban server (tidak perlu proses full registration untuk email yang sudah ada)
