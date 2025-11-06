@echo off
echo ========================================
echo GEROBAKS - JALANKAN SERVER LARAVEL
echo ========================================
echo.
echo Menjalankan server Laravel dengan konfigurasi
echo yang dapat diakses oleh perangkat mobile...
echo.

cd "c:\Users\HP VICTUS\Documents\GitHub\Gerobaks\backend"

echo Membersihkan cache...
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo.
echo Menjalankan server di semua interface (0.0.0.0)...
echo Server akan dapat diakses dari perangkat fisik di jaringan
echo.

php artisan serve --host=0.0.0.0 --port=8000

pause