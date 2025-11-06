@echo off
echo ==========================
echo GEROBAKS APP RUNNER SCRIPT
echo ==========================

echo Checking for .env file...
if exist .env (
    echo .env file found!
) else (
    echo .env file not found. Creating default .env file...
    echo # Alamat backend API - gunakan 10.0.2.2 untuk emulator Android > .env
    echo API_BASE_URL=http://10.0.2.2:8000 >> .env
    echo .env file created with default configuration!
)

echo Running flutter clean...
flutter clean

echo Running flutter pub get...
flutter pub get

echo Starting application in debug mode...
flutter run --verbose

echo ==========================
echo If you encounter errors, please check:
echo 1. Your Laravel server is running at http://10.0.2.2:8000
echo 2. The .env file exists and contains correct API_BASE_URL
echo 3. Your device/emulator has internet connectivity
echo ==========================

pause