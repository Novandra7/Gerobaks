@echo off
REM Change to the script directory
cd /d "%~dp0"

REM Run Flutter with verbose logging and debug flags
echo Starting Flutter in debug mode with special logging flags...
flutter run --verbose --debug-port=12345 --enable-software-rendering --dart-flags="--no-disable-service-port-fallback" --no-dds
pause