@echo off
echo ========================================
echo GEROBAKS API - LOCAL SERVER
echo Database: Online MySQL (202.10.35.161)
echo ========================================
echo.

cd backend

echo [1/3] Checking PHP installation...
php --version
if %errorlevel% neq 0 (
    echo ERROR: PHP not found! Please install PHP first.
    pause
    exit /b 1
)
echo.

echo [2/3] Checking database connection...
php artisan config:clear
php artisan cache:clear
echo.

echo [3/3] Starting Laravel development server...
echo.
echo API will be available at: http://localhost:8000
echo Database: dumeg_gerobaks @ 202.10.35.161
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

php artisan serve --host=0.0.0.0 --port=8000

pause
