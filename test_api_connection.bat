@echo off
echo ==========================
echo GEROBAKS API TESTER
echo ==========================
echo.
echo Memeriksa koneksi API Laravel...
echo.

REM Tentukan URL API untuk diuji
set API_URL=http://10.0.2.2:8000

echo Mencoba akses ke %API_URL%/api/ping...
curl -s -o nul -w "Status Code: %%{http_code}\n" %API_URL%/api/ping
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Tidak dapat terhubung ke server Laravel
    echo.
    echo Kemungkinan masalah:
    echo 1. Server Laravel belum berjalan
    echo 2. URL salah (untuk emulator Android gunakan 10.0.2.2:8000, perangkat fisik gunakan IP LAN)
    echo 3. Firewall memblokir koneksi
    echo.
    echo Solusi:
    echo - Jalankan server Laravel dengan: php artisan serve --host=0.0.0.0
    echo - Edit file .env di project Flutter dan set API_BASE_URL=http://[IP_Komputer]:8000
    echo - Matikan sementara firewall Windows
) else (
    echo [OK] Server Laravel dapat diakses!
)

echo.
echo Mencoba API login (gunakan user test)...
curl -s -X POST -H "Content-Type: application/json" -d "{\"email\":\"test@example.com\",\"password\":\"password\"}" %API_URL%/api/login
echo.
echo.

echo ==========================
echo Informasi Jaringan
echo ==========================
ipconfig | findstr "IPv4"
echo.
echo Gunakan IP Address komputer di atas untuk setting API_BASE_URL di file .env
echo jika menggunakan perangkat fisik untuk debugging.
echo.

echo ==========================
echo Cek Laravel Server
echo ==========================
netstat -ano | findstr ":8000" 
echo.
echo Jika ada output di atas, berarti Laravel server sedang berjalan di port 8000
echo.

echo Selesai! Tekan tombol apa saja untuk keluar...
pause > nul