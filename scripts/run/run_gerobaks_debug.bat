@echo off
REM ========================================
REM Advanced Flutter Debug Runner Script
REM Created: September 22, 2025
REM ========================================

echo.
echo === Gerobaks App Debug Runner ===
echo.

REM Change to the script directory
cd /d "%~dp0"

REM Check Flutter status
echo Checking Flutter status...
flutter doctor -v > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Flutter may not be properly installed or configured
    echo Running flutter doctor for diagnostics:
    flutter doctor -v
    echo.
    echo Press any key to continue anyway...
    pause > nul
)

REM Clean old build files if needed
echo Would you like to clean the project first? (y/n)
set /p clean_choice="> "
if /i "%clean_choice%"=="y" (
    echo Cleaning Flutter project...
    flutter clean
    echo Flutter dependencies will be retrieved...
    flutter pub get
    echo.
)

REM Set environment variables to improve logging
set FLUTTER_VERBOSE_LOGGING=true
set VERBOSE_ANALYTICS=true
set ENABLE_CONSOLE_LOGGING=true

echo.
echo Starting Flutter in debug mode with special settings...
echo Logs will appear in the debug console
echo.
echo If debug console is not visible:
echo 1. Check the "Output" panel in VS Code
echo 2. Make sure "Flutter" is selected in the dropdown
echo 3. Try restarting VS Code with admin privileges
echo.

REM Run with specific flags to ensure debug console works
flutter run --verbose --debug-port=12345 --enable-software-rendering --dart-flags="--no-disable-service-port-fallback" --no-dds --target-platform=android-arm64 --debug %*

echo.
echo Debug session ended
echo.
pause