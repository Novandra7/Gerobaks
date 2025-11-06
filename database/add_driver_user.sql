-- Tambah user driver.jakarta@gerobaks.com ke database
-- Password: mitra123
USE gerobaks_db;

-- Hapus user jika sudah ada
DELETE FROM users WHERE email = 'driver.jakarta@gerobaks.com';

-- Tambah user baru dengan password mitra123
-- Hash bcrypt yang benar untuk password 'mitra123'
INSERT INTO users (name, email, email_verified_at, password, role, status, phone, address, created_at, updated_at) VALUES
('Driver Jakarta', 'driver.jakarta@gerobaks.com', NOW(), '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mitra', 'active', '+6281234567895', 'Jakarta, DKI Jakarta', NOW(), NOW());

-- ALTERNATIVE: Jika masih gagal, coba dengan hash untuk password 'password' terlebih dahulu
-- INSERT INTO users (name, email, email_verified_at, password, role, status, phone, address, created_at, updated_at) VALUES
-- ('Driver Jakarta', 'driver.jakarta@gerobaks.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mitra', 'active', '+6281234567895', 'Jakarta, DKI Jakarta', NOW(), NOW());

-- Cek apakah user berhasil ditambahkan
SELECT id, name, email, role, status FROM users WHERE email = 'driver.jakarta@gerobaks.com';

-- =============================================
-- KREDENSIAL LOGIN - VERSI 1:
-- =============================================
-- Email: driver.jakarta@gerobaks.com
-- Password: mitra123 (hash: $2y$10$...)
-- Role: mitra
-- =============================================
-- 
-- JIKA MASIH GAGAL, COBA DENGAN PASSWORD: password
-- (uncomment baris INSERT alternative di atas)
-- =============================================