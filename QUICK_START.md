# 🚀 QUICK START - LOCAL API + ONLINE DATABASE

## ⚡ CARA CEPAT (ONE-COMMAND)

### Option 1: Auto Start & Test

```powershell
.\run-local-api-test.ps1
```

Script ini akan:

- ✅ Check jika server sudah running
- ✅ Start server jika belum running (window baru)
- ✅ Wait sampai server ready
- ✅ Run comprehensive test (54 endpoints)

---

### Option 2: Manual (Step by Step)

#### Terminal 1: Start Server

```powershell
# Batch File (Windows)
.\start-local-api.bat

# OR PowerShell (Recommended)
.\start-local-api.ps1
```

#### Terminal 2: Run Tests

```powershell
.\test-all-mobile-services.ps1
```

---

## 📋 PREREQUISITES

### 1. PHP Installed

```powershell
php --version
# Should show PHP 8.1 or higher
```

### 2. Composer Installed

```powershell
composer --version
```

### 3. Database Configured

File: `backend/.env`

```env
DB_CONNECTION=mysql
DB_HOST=202.10.35.161
DB_PORT=3306
DB_DATABASE=dumeg_gerobaks
DB_USERNAME=dumeg_ghani
DB_PASSWORD=)W&tJ3Nyh~b5;*~z
```

**✅ Already configured!** No need to edit.

---

## 🔧 AVAILABLE SCRIPTS

### 1. `start-local-api.bat` (Windows Batch)

Simple batch file untuk start server

- Clear cache otomatis
- Start server di port 8000
- Show database info

### 2. `start-local-api.ps1` (PowerShell - Better)

PowerShell version dengan lebih banyak features:

- ✅ Check PHP installation
- ✅ Check .env configuration
- ✅ Install dependencies jika belum ada
- ✅ Clear all caches (config, route, cache)
- ✅ Show database connection info
- ✅ Start server dengan clear output

### 3. `test-all-mobile-services.ps1` (Comprehensive Test)

Test semua 54 endpoints dari 12 services:

- ✅ Check server running sebelum test
- ✅ Auto login & get token
- ✅ Test GET, POST, PUT, DELETE
- ✅ Show detailed results dengan colors
- ✅ Generate summary report

### 4. `run-local-api-test.ps1` (One Command Solution)

Kombinasi start server + run tests:

- ✅ Check jika server sudah running
- ✅ Start server jika belum (window baru)
- ✅ Wait server ready (max 30 seconds)
- ✅ Auto run comprehensive tests
- ✅ Show complete results

### 5. `test-local-api.ps1` (Quick Connection Test)

Quick test untuk verify koneksi:

- ✅ Health check
- ✅ Database ping
- ✅ Login test
- ✅ Public endpoint test
- ✅ Authenticated endpoint test

---

## 🎯 USAGE EXAMPLES

### Scenario 1: First Time Setup

```powershell
# 1. Check PHP & Composer
php --version
composer --version

# 2. Navigate to project
cd C:\Users\HP VICTUS\Documents\GitHub\Gerobaks

# 3. Start server (PowerShell recommended)
.\start-local-api.ps1

# Server akan running di: http://localhost:8000
# Keep terminal ini tetap terbuka!
```

### Scenario 2: Quick Test (Server Already Running)

```powershell
# Just run tests
.\test-all-mobile-services.ps1
```

### Scenario 3: Auto Everything

```powershell
# One command untuk start & test
.\run-local-api-test.ps1
```

### Scenario 4: Quick Connection Check

```powershell
# Verify connection tanpa comprehensive test
.\test-local-api.ps1
```

---

## 🐛 TROUBLESHOOTING

### Problem: "Server is NOT running"

```powershell
# Solution 1: Start server manual
.\start-local-api.ps1

# Solution 2: Check port 8000
netstat -ano | findstr :8000

# Solution 3: Kill process jika stuck
# Get PID from netstat, then:
taskkill /PID <process_id> /F
```

### Problem: "Database connection error"

```powershell
# Check .env configuration
cd backend
type .env | findstr "DB_"

# Should show:
# DB_CONNECTION=mysql
# DB_HOST=202.10.35.161
# DB_PORT=3306
# DB_DATABASE=dumeg_gerobaks
# DB_USERNAME=dumeg_ghani
```

### Problem: "Composer dependencies not installed"

```powershell
cd backend
composer install
cd ..
```

### Problem: "PHP not found"

```powershell
# Install PHP 8.1+ from:
# https://windows.php.net/download/

# Add to PATH environment variable
```

---

## 📊 SERVER INFO

### Local API

- **URL**: http://localhost:8000
- **API Base**: http://localhost:8000/api
- **Swagger Docs**: http://localhost:8000/api/documentation

### Database (Online)

- **Host**: 202.10.35.161:3306
- **Database**: dumeg_gerobaks
- **User**: dumeg_ghani
- **Type**: MySQL (Production Data)

### Available Endpoints

Total: **54 endpoints** across **12 services**

Services:

1. ✅ Authentication (login, register, logout, me)
2. ✅ Tracking (GET, POST, by schedule)
3. ✅ Users (admin endpoints)
4. ✅ Schedules (GET, POST, PUT, DELETE)
5. ✅ Orders (GET, POST, PUT, DELETE)
6. ✅ Ratings (GET, POST)
7. ✅ Payments (GET, POST, PATCH)
8. ✅ Balance (summary, ledger, topup)
9. ✅ Subscription (plans, current, subscribe)
10. ✅ Chats (GET, POST)
11. ✅ Notifications (GET, POST, mark-read)
12. ✅ Feedback (GET, POST)

---

## ✅ READY TO GO!

### Method 1: All-in-One (Recommended for First Time)

```powershell
.\run-local-api-test.ps1
```

### Method 2: Manual Control (Recommended for Development)

```powershell
# Terminal 1
.\start-local-api.ps1

# Terminal 2 (after server ready)
.\test-all-mobile-services.ps1
```

### Method 3: Quick Check Only

```powershell
# Start server first
.\start-local-api.ps1

# In another terminal, quick test
.\test-local-api.ps1
```

---

**Last Updated**: October 15, 2025  
**Configuration**: Local Laravel API + Online MySQL Database  
**Status**: ✅ Ready to Use

---

## 🎓 TIPS

1. **Always keep server terminal open** - Jangan close window server
2. **Use PowerShell scripts** - Lebih banyak features & better error handling
3. **Check server first** - Before running tests, verify server is running
4. **Read test results** - Script akan show detailed results dengan colors
5. **Use Ctrl+C to stop** - Untuk stop server dengan graceful

Happy Testing! 🚀
