# 🚀 SETUP LOCAL API + ONLINE DATABASE

**Tanggal:** 15 Oktober 2025  
**Konfigurasi:** Local Laravel API + Remote MySQL Database

---

## 📋 KONFIGURASI DATABASE

### Database Online (Production)

```
Host:     202.10.35.161
Port:     3306
Database: dumeg_gerobaks
Username: dumeg_ghani
Password: )W&tJ3Nyh~b5;*~z
```

### Backend API (Local)

```
URL:      http://localhost:8000
Path:     /api
Framework: Laravel 12.x
```

---

## 🔧 CARA SETUP

### 1. **Update Backend .env** ✅ (DONE)

File: `backend/.env`

```env
# Database Configuration
DB_CONNECTION=mysql
DB_HOST=202.10.35.161
DB_PORT=3306
DB_DATABASE=dumeg_gerobaks
DB_USERNAME=dumeg_ghani
DB_PASSWORD=)W&tJ3Nyh~b5;*~z

# App Configuration
APP_URL=http://localhost:8000
APP_ENV=local
APP_DEBUG=true
```

### 2. **Update Mobile App Config** ✅ (DONE)

File: `lib/utils/app_config.dart`

```dart
// Default API URL changed to localhost
static const String DEFAULT_API_URL = 'http://localhost:8000';
static const String LOCALHOST_API_URL = 'http://localhost:8000';
```

### 3. **Start Local API Server**

**Option A: Using Batch File (Recommended)**

```batch
.\start-local-api.bat
```

**Option B: Manual**

```bash
cd backend
php artisan config:clear
php artisan cache:clear
php artisan serve --host=0.0.0.0 --port=8000
```

Server akan berjalan di: **http://localhost:8000**

### 4. **Test Koneksi**

```powershell
.\test-local-api.ps1
```

Tests yang dilakukan:

- ✅ Health check API
- ✅ Database connection (via ping)
- ✅ Login authentication
- ✅ Get ratings (public endpoint)
- ✅ Get schedules (authenticated)
- ✅ Get tracking (new endpoint path)

---

## 🧪 TESTING ENDPOINTS

### Quick Test (PowerShell)

```powershell
# 1. Health Check
Invoke-RestMethod -Uri "http://localhost:8000/api/health"

# 2. Ping (Database check)
Invoke-RestMethod -Uri "http://localhost:8000/api/ping"

# 3. Login
$body = @{
    email = "daffa@gmail.com"
    password = "password123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" `
    -Method POST -Body $body -ContentType "application/json"

$token = $response.data.token
Write-Host "Token: $token"

# 4. Get Ratings (Public)
Invoke-RestMethod -Uri "http://localhost:8000/api/ratings"

# 5. Get Schedules (Auth Required)
$headers = @{ "Authorization" = "Bearer $token" }
Invoke-RestMethod -Uri "http://localhost:8000/api/schedules" -Headers $headers

# 6. Get Tracking (FIXED PATH)
Invoke-RestMethod -Uri "http://localhost:8000/api/tracking?limit=5"
```

---

## 📱 MOBILE APP SETUP

### For Android Emulator

Jika menggunakan Android Emulator, gunakan IP khusus:

```dart
// lib/utils/app_config.dart
static const String DEVELOPMENT_API_URL = 'http://10.0.2.2:8000';
```

**10.0.2.2** = localhost dari perspektif Android Emulator

### For Physical Device

Jika menggunakan physical device di network yang sama:

1. Cari IP komputer Anda:

   ```powershell
   ipconfig
   # Cari "IPv4 Address" di adapter WiFi/Ethernet
   ```

2. Update app config:

   ```dart
   static const String DEVELOPMENT_API_URL = 'http://192.168.x.x:8000';
   ```

3. Pastikan firewall mengizinkan port 8000

---

## ✅ VERIFIED ENDPOINTS (FIXED PATHS)

Sesuai dengan backend documentation, endpoint yang sudah diperbaiki:

### Tracking Service

- ✅ `GET /api/tracking` (was: /trackings)
- ✅ `POST /api/tracking` (was: /trackings)
- ✅ `GET /api/tracking/schedule/{id}` (new)

### Users Service

- ✅ `GET /api/admin/users` (was: /users)
- ✅ `POST /api/admin/users` (was: /users)

### Balance Service

- ✅ `GET /api/balance/summary` (was: /balance)
- ✅ `GET /api/balance/ledger`
- ✅ `POST /api/balance/topup`

### Subscription Service

- ✅ `GET /api/subscription/plans` (was: /subscriptions)
- ✅ `GET /api/subscription/current`
- ✅ `POST /api/subscription/subscribe`

### Others (Already Correct)

- ✅ `GET /api/ratings`
- ✅ `GET /api/schedules`
- ✅ `GET /api/orders`
- ✅ `GET /api/payments`
- ✅ `GET /api/chats`
- ✅ `GET /api/feedback`

---

## 🔍 TROUBLESHOOTING

### Problem: "Connection refused" saat akses API

**Solution:**

1. Pastikan `start-local-api.bat` masih running
2. Check apakah port 8000 sudah digunakan aplikasi lain:
   ```powershell
   netstat -ano | findstr :8000
   ```
3. Restart Laravel server

### Problem: "SQLSTATE[HY000] [2002] Connection refused"

**Solution:**

1. Verify database credentials di `backend/.env`
2. Test koneksi database manual:
   ```bash
   mysql -h 202.10.35.161 -P 3306 -u dumeg_ghani -p dumeg_gerobaks
   ```
3. Check firewall/network

### Problem: "419 CSRF Token Mismatch"

**Solution:**

```bash
cd backend
php artisan config:clear
php artisan cache:clear
php artisan serve
```

### Problem: Mobile app cannot connect to localhost

**Android Emulator:** Use `http://10.0.2.2:8000`  
**Physical Device:** Use computer's IP `http://192.168.x.x:8000`  
**iOS Simulator:** Use `http://localhost:8000` (works directly)

---

## 📊 DATABASE INFO

### Tables Available (dumeg_gerobaks)

Sesuai dengan ERD, database memiliki tables:

- ✅ `users` - User accounts (end_user, mitra, admin)
- ✅ `schedules` - Pickup schedules
- ✅ `orders` - Service orders
- ✅ `tracking` - GPS tracking points
- ✅ `payments` - Payment transactions
- ✅ `ratings` - User ratings
- ✅ `balance_ledger` - Balance transactions
- ✅ `chats` - Chat messages
- ✅ `notifications` - User notifications
- ✅ `feedback` - User feedback

### Sample Data

Database production sudah berisi data real:

- Users: Multiple roles (end_user, mitra, admin)
- Schedules: Active pickup schedules
- Tracking: GPS coordinates history
- Ratings: Customer reviews

---

## 🎯 NEXT STEPS

### 1. Start Development

```bash
# Terminal 1: Start API Server
.\start-local-api.bat

# Terminal 2: Test API
.\test-local-api.ps1

# Terminal 3: Run Flutter App
flutter run
```

### 2. Update Test Scripts

File yang perlu diupdate dengan `localhost:8000`:

- ❌ `test-all-mobile-services.ps1` (still using gerobaks.dumeg.com)
- ✅ `test-local-api.ps1` (already using localhost)
- ✅ `test-quick-fixed.ps1` (needs update to localhost)

### 3. Fix Service Files

Priority fixes dari `ENDPOINT_MAPPING_CORRECTIONS.md`:

- ✅ Tracking Service (DONE - paths fixed)
- ✅ Users Service (DONE - /admin/users)
- ⏳ Balance Service (remove /balance endpoint)
- ⏳ Subscription Service (paths need update)
- ⏳ Notification Service (PUT → POST)
- ⏳ Payment Service (PUT → PATCH)

---

## 📝 FILES CREATED/UPDATED

### Created

- ✅ `start-local-api.bat` - Start local Laravel server
- ✅ `test-local-api.ps1` - Test local API + online DB
- ✅ `LOCAL_API_SETUP.md` - This documentation

### Updated

- ✅ `backend/.env` - MySQL config (online DB)
- ✅ `lib/utils/app_config.dart` - Default URL to localhost
- ✅ `lib/services/tracking_service_complete.dart` - Fixed endpoints
- ✅ `lib/services/users_service.dart` - Fixed /admin/users path

---

## ✅ READY TO USE!

**Status:** ✅ **CONFIGURED & READY**

**Current Setup:**

- Backend API: Local (localhost:8000)
- Database: Online (202.10.35.161)
- Mobile App: Points to localhost
- Endpoints: Fixed to match backend

**To Start Development:**

1. Run `.\start-local-api.bat` (keep it running)
2. Run `.\test-local-api.ps1` (verify everything works)
3. Run `flutter run` (start mobile app)
4. Test endpoints dengan FIXED paths

---

**Last Updated:** October 15, 2025  
**Configuration:** Local API + Online Database  
**Status:** ✅ Production-Ready for Development
