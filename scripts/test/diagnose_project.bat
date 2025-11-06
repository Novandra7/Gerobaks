@echo off
REM ========================================
REM Flutter Project Diagnostic Tool
REM Created: September 22, 2025
REM ========================================

echo.
echo === Gerobaks Project Diagnostics ===
echo.

REM Change to the script directory
cd /d "%~dp0"

echo === SYSTEM INFORMATION ===
echo Operating System:
ver
echo.
echo === FLUTTER INFORMATION ===
flutter --version
echo.

echo === ANALYZING PROJECT ===
echo Running Flutter doctor...
flutter doctor -v
echo.

echo === CHECKING DEPENDENCIES ===
echo Running pub get...
flutter pub get
echo.

echo === ANALYZING CODE ===
echo Running Flutter analyze...
flutter analyze
echo.

echo === CHECKING FOR OUTDATED PACKAGES ===
echo Running pub outdated...
flutter pub outdated
echo.

echo === BUILD VALIDATION ===
echo Checking if app can be built...
echo.
echo Would you like to validate the build? (y/n)
set /p build_choice="> "
if /i "%build_choice%"=="y" (
    echo.
    echo Building APK (this might take a while)...
    flutter build apk --debug --dart-define=FLUTTER_NO_TESTS=true
    
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo Build failed. Would you like to see detailed Gradle build logs? (y/n)
        set /p gradle_choice="> "
        if /i "%gradle_choice%"=="y" (
            echo.
            echo Running with --verbose to see detailed Gradle logs...
            flutter build apk --debug --verbose --dart-define=FLUTTER_NO_TESTS=true
        )
    ) else (
        echo.
        echo Build completed successfully!
    )
) else (
    echo Build validation skipped.
)

echo.
echo === DIAGNOSTIC SUMMARY ===
echo.
echo If you encountered audioplayers_android Gradle issues:
echo Please refer to android_build_fix.md for solutions
echo.
echo If debug console is not visible:
echo 1. Try using run_gerobaks_debug.bat
echo 2. Check VS Code settings.json for "dart.debugExternalLibraries": true
echo 3. Make sure launch.json uses "console": "debugConsole"
echo.
echo Diagnostics completed.
echo.
pause