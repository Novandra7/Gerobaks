-- =====================================================
-- FIX MITRA PASSWORDS - URGENT
-- =====================================================
-- Problem: Passwords not hashed with bcrypt
-- Solution: Update with properly hashed passwords
-- Date: November 13, 2025
-- =====================================================

-- STEP 1: Check current password state
SELECT 
    id,
    name,
    email,
    LEFT(password, 7) as hash_start,
    LENGTH(password) as hash_length,
    role,
    created_at
FROM users 
WHERE role = 'mitra';

-- Expected bcrypt hash:
-- - Starts with: $2y$10$
-- - Length: 60 characters
-- If NOT, passwords need fixing!

-- =====================================================

-- STEP 2: Update passwords with bcrypt hashes
-- Password: mitra123
-- Generated via: php -r "echo password_hash('mitra123', PASSWORD_BCRYPT);"

-- IMPORTANT: Run this in Laravel Tinker instead for better compatibility!
-- php artisan tinker
-- Then paste:
-- use Illuminate\Support\Facades\Hash;
-- DB::table('users')->where('email', 'driver.jakarta@gerobaks.com')->update(['password' => Hash::make('mitra123')]);
-- DB::table('users')->where('email', 'driver.bandung@gerobaks.com')->update(['password' => Hash::make('mitra123')]);
-- DB::table('users')->where('email', 'driver.surabaya@gerobaks.com')->update(['password' => Hash::make('mitra123')]);

-- =====================================================

-- Alternative: Direct SQL (NOT RECOMMENDED, use Tinker above!)
-- Generate fresh bcrypt hashes at: https://bcrypt-generator.com/
-- Input: mitra123, Rounds: 10

-- UPDATE users 
-- SET 
--     password = '$2y$10$GENERATED_HASH_HERE',
--     updated_at = NOW()
-- WHERE email = 'driver.jakarta@gerobaks.com';

-- UPDATE users 
-- SET 
--     password = '$2y$10$GENERATED_HASH_HERE',
--     updated_at = NOW()
-- WHERE email = 'driver.bandung@gerobaks.com';

-- UPDATE users 
-- SET 
--     password = '$2y$10$GENERATED_HASH_HERE',
--     updated_at = NOW()
-- WHERE email = 'driver.surabaya@gerobaks.com';

-- =====================================================

-- STEP 3: Verify fix
SELECT 
    id,
    name,
    email,
    LEFT(password, 7) as hash_start,
    LENGTH(password) as hash_length,
    CASE 
        WHEN LEFT(password, 7) = '$2y$10$' AND LENGTH(password) = 60 THEN '✅ Valid bcrypt'
        ELSE '❌ Invalid hash'
    END as status
FROM users 
WHERE role = 'mitra';

-- Expected result: All users show '✅ Valid bcrypt'

-- =====================================================

-- STEP 4: Test login via SQL (for debugging)
-- Note: This won't actually verify the hash, use API test instead

SELECT 
    id,
    name,
    email,
    role,
    status,
    'Ready to test login' as next_step
FROM users 
WHERE email = 'driver.jakarta@gerobaks.com'
  AND role = 'mitra'
  AND status = 'active';

-- If user found, test login via:
-- curl -X POST http://127.0.0.1:8000/api/login \
--   -H "Content-Type: application/json" \
--   -d '{"email":"driver.jakarta@gerobaks.com","password":"mitra123"}'

-- =====================================================
-- RECOMMENDED APPROACH: Use Laravel Tinker
-- =====================================================
/*

# 1. Navigate to Laravel backend
cd /path/to/backend

# 2. Run tinker
php artisan tinker

# 3. Execute this code:
use Illuminate\Support\Facades\Hash;

$mitras = [
    'driver.jakarta@gerobaks.com',
    'driver.bandung@gerobaks.com',
    'driver.surabaya@gerobaks.com'
];

foreach($mitras as $email) {
    DB::table('users')
        ->where('email', $email)
        ->update([
            'password' => Hash::make('mitra123'),
            'updated_at' => now()
        ]);
    echo "✅ Fixed: $email\n";
}

echo "\n✅ All mitra passwords fixed!\n";

# 4. Test login
$user = DB::table('users')->where('email', 'driver.jakarta@gerobaks.com')->first();
$test = Hash::check('mitra123', $user->password);
echo $test ? "✅ Password verification works!" : "❌ Still broken!";

*/

-- =====================================================
-- End of file
-- =====================================================
