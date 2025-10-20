# ========================================
# TEST LOCAL API + ONLINE DATABASE
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GEROBAKS - Local API + Online Database" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$localApi = "http://localhost:8000/api"

# Test 1: Health Check
Write-Host "[TEST 1] Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$localApi/health" -TimeoutSec 5
    Write-Host "[OK] API is running!" -ForegroundColor Green
    Write-Host "    Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] API not responding!" -ForegroundColor Red
    Write-Host "    Make sure you run: .\start-local-api.bat" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test 2: Database Connection (via ping)
Write-Host "[TEST 2] API Ping (Database Check)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$localApi/ping" -TimeoutSec 5
    Write-Host "[OK] Database connected!" -ForegroundColor Green
    Write-Host "    Message: $($response.message)" -ForegroundColor Gray
    Write-Host "    Database: $($response.database)" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Database connection failed!" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Login Test
Write-Host "[TEST 3] Login Test..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email    = "daffa@gmail.com"
        password = "password123"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$localApi/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -TimeoutSec 10

    $token = $response.data.token
    Write-Host "[OK] Login successful!" -ForegroundColor Green
    Write-Host "    User: $($response.data.user.name)" -ForegroundColor Gray
    Write-Host "    Role: $($response.data.user.role)" -ForegroundColor Gray
    Write-Host "    Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Login failed!" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 4: Get Ratings (with auth)
Write-Host "[TEST 4] Get Ratings (Public Endpoint)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$localApi/ratings" -TimeoutSec 5
    $count = if ($response.data) { $response.data.Count } else { 0 }
    Write-Host "[OK] Ratings retrieved!" -ForegroundColor Green
    Write-Host "    Count: $count ratings" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Failed to get ratings!" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Get Schedules
Write-Host "[TEST 5] Get Schedules..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept"        = "application/json"
    }
    $response = Invoke-RestMethod -Uri "$localApi/schedules" -Headers $headers -TimeoutSec 5
    $count = if ($response.data) { $response.data.Count } else { 0 }
    Write-Host "[OK] Schedules retrieved!" -ForegroundColor Green
    Write-Host "    Count: $count schedules" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Failed to get schedules!" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Get Tracking (FIXED endpoint)
Write-Host "[TEST 6] Get Tracking..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$localApi/tracking?limit=5" -TimeoutSec 5
    $count = if ($response.data) { $response.data.Count } else { 0 }
    Write-Host "[OK] Tracking retrieved!" -ForegroundColor Green
    Write-Host "    Count: $count tracking points" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Failed to get tracking!" -ForegroundColor Red
    Write-Host "    Error: $_" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local API:   http://localhost:8000" -ForegroundColor White
Write-Host "Database:    202.10.35.161:3306" -ForegroundColor White
Write-Host "DB Name:     dumeg_gerobaks" -ForegroundColor White
Write-Host "Status:      [OK] Ready for development!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Keep .\start-local-api.bat running" -ForegroundColor Gray
Write-Host "2. Update mobile app to use localhost:8000" -ForegroundColor Gray
Write-Host "3. Run Flutter app for testing" -ForegroundColor Gray
Write-Host ""
