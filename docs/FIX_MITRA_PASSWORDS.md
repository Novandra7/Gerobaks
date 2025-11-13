# 🔧 Fix Mitra Passwords - Urgent

## ❌ Problem Identified

**Error:** `"This password does not use the Bcrypt algorithm."`

**Root Cause:** Password mitra users di database **TIDAK di-hash dengan bcrypt**. Kemungkinan password disimpan sebagai plain text atau menggunakan algoritma hash yang salah.

**Impact:** Mitra users **tidak bisa login** sama sekali!

---

## ✅ Solution: Hash Passwords dengan Bcrypt

### Option 1: Via Laravel Tinker (RECOMMENDED)

```bash
# 1. Masuk ke backend directory
cd /path/to/laravel/backend

# 2. Jalankan tinker
php artisan tinker

# 3. Update passwords (paste ke tinker)
use Illuminate\Support\Facades\Hash;

$mitras = [
    'driver.jakarta@gerobaks.com',
    'driver.bandung@gerobaks.com',
    'driver.surabaya@gerobaks.com'
];

foreach($mitras as $email) {
    DB::table('users')
        ->where('email', $email)
        ->update(['password' => Hash::make('mitra123')]);
    echo "✅ Updated password for: $email\n";
}

echo "\n✅ All mitra passwords updated successfully!\n";
```

### Option 2: Direct SQL Update

```sql
-- WARNING: Replace 'BCRYPT_HASH_HERE' with actual bcrypt hash
-- Generate hash first using: https://bcrypt-generator.com/
-- Input: mitra123
-- Rounds: 10

UPDATE users 
SET password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi' 
WHERE email IN (
    'driver.jakarta@gerobaks.com',
    'driver.bandung@gerobaks.com', 
    'driver.surabaya@gerobaks.com'
);
```

**Note:** Hash di atas adalah contoh, generate hash baru untuk `mitra123`!

### Option 3: Create New Seeder (BEST FOR PRODUCTION)

```bash
# 1. Create seeder
php artisan make:seeder FixMitraPasswordsSeeder

# 2. Edit file: database/seeders/FixMitraPasswordsSeeder.php
```

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class FixMitraPasswordsSeeder extends Seeder
{
    public function run()
    {
        $mitras = [
            'driver.jakarta@gerobaks.com',
            'driver.bandung@gerobaks.com',
            'driver.surabaya@gerobaks.com',
        ];

        foreach ($mitras as $email) {
            DB::table('users')
                ->where('email', $email)
                ->update([
                    'password' => Hash::make('mitra123'),
                    'updated_at' => now()
                ]);
            
            $this->command->info("✅ Updated password for: $email");
        }

        $this->command->info("\n✅ All mitra passwords updated successfully!");
    }
}
```

```bash
# 3. Run seeder
php artisan db:seed --class=FixMitraPasswordsSeeder
```

---

## 🧪 Testing After Fix

### Test Login via API:

```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "driver.jakarta@gerobaks.com",
    "password": "mitra123"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 5,
      "name": "Ahmad Kurniawan",
      "email": "driver.jakarta@gerobaks.com",
      "role": "mitra",
      ...
    },
    "token": "43|..."
  }
}
```

### Test di Flutter App:

1. Login dengan:
   - Email: `driver.jakarta@gerobaks.com`
   - Password: `mitra123`

2. **Expected Result:**
   - ✅ Login successful
   - ✅ Navigate to mitra dashboard
   - ✅ See "Sistem Penjemputan Mitra" card

---

## 🔍 Verify Password Hash in Database

```sql
-- Check current password hash
SELECT 
    id, 
    name, 
    email, 
    LEFT(password, 7) as hash_type,
    LENGTH(password) as hash_length,
    role
FROM users 
WHERE role = 'mitra';
```

**Expected Output:**
```
+----+------------------+------------------------------+------------+--------------+-------+
| id | name             | email                        | hash_type  | hash_length  | role  |
+----+------------------+------------------------------+------------+--------------+-------+
|  5 | Ahmad Kurniawan  | driver.jakarta@gerobaks.com  | $2y$10$    | 60           | mitra |
|  6 | Budi Santoso     | driver.bandung@gerobaks.com  | $2y$10$    | 60           | mitra |
|  7 | Candra Wijaya    | driver.surabaya@gerobaks.com | $2y$10$    | 60           | mitra |
+----+------------------+------------------------------+------------+--------------+-------+
```

**Key Indicators:**
- ✅ `hash_type` starts with `$2y$10$` (bcrypt)
- ✅ `hash_length` is 60 characters
- ❌ If length < 60 or doesn't start with `$2y$`, it's WRONG!

---

## 🚨 Prevention for Future

### Update User Factory/Seeder:

```php
// database/factories/UserFactory.php
public function definition()
{
    return [
        'name' => fake()->name(),
        'email' => fake()->unique()->safeEmail(),
        'password' => Hash::make('password123'), // ← ALWAYS use Hash::make()
        // ...
    ];
}
```

### Update Registration Controller:

```php
// app/Http/Controllers/Api/AuthController.php
public function register(Request $request)
{
    // ...
    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password), // ← ALWAYS use Hash::make()
        // ...
    ]);
    // ...
}
```

---

## 📊 Quick Diagnosis Commands

### Check if passwords are bcrypt:
```bash
php artisan tinker --execute="
    \$users = DB::table('users')->where('role', 'mitra')->get(['email', 'password']);
    foreach(\$users as \$user) {
        \$isBcrypt = str_starts_with(\$user->password, '\$2y\$');
        echo \$user->email . ': ' . (\$isBcrypt ? '✅ bcrypt' : '❌ NOT bcrypt') . PHP_EOL;
    }
"
```

### Test password verification:
```bash
php artisan tinker --execute="
    use Illuminate\Support\Facades\Hash;
    \$user = DB::table('users')->where('email', 'driver.jakarta@gerobaks.com')->first();
    if(\$user) {
        try {
            \$valid = Hash::check('mitra123', \$user->password);
            echo \$valid ? '✅ Password valid' : '❌ Password invalid';
        } catch (\Exception \$e) {
            echo '❌ Error: ' . \$e->getMessage();
        }
    }
"
```

---

## 📝 Summary

**Problem:** Mitra passwords not hashed with bcrypt  
**Solution:** Re-hash all mitra passwords using `Hash::make()`  
**Test:** Login via API or Flutter app  
**Prevention:** Always use `Hash::make()` when storing passwords  

**Status:** 🔴 **CRITICAL** - Must fix before testing mitra pickup system!

---

**Date:** November 13, 2025  
**Priority:** P0 (Critical)  
**Estimated Fix Time:** 5 minutes  

