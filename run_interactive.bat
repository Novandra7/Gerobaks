@echo off
echo Menjalankan Flutter dengan debug console yang berfungsi penuh...
cd /d "%~dp0"

echo Membersihkan cache...
call flutter clean

echo Memperbarui dependencies...
call flutter pub get

echo.
echo Menjalankan aplikasi dengan debug interactive console...
echo Gunakan "r" untuk hot reload, "R" untuk hot restart
echo.
call flutter run --verbose --no-enable-impeller --debug --device-vmservice-port=8080

echo.
echo Jika masih ada masalah, coba jalankan aplikasi secara manual dengan:
echo flutter run --no-enable-impeller --verbose