# ========================================
# GEROBAKS - START SERVER & RUN TESTS
# Automatically start local API and run tests
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GEROBAKS - AUTO START & TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if server is already running
Write-Host "[1/3] Checking if server is already running..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -TimeoutSec 3
    Write-Host "  Server is already running!" -ForegroundColor Green
    $serverRunning = $true
}
catch {
    Write-Host "  Server is not running. Will start it..." -ForegroundColor Yellow
    $serverRunning = $false
}

# Start server if not running
if (-not $serverRunning) {
    Write-Host "`n[2/3] Starting local API server..." -ForegroundColor Yellow
    
    # Start server in new window
    $serverProcess = Start-Process powershell -ArgumentList "-NoExit", "-Command", ".\start-local-api.ps1" -PassThru
    
    Write-Host "  Waiting for server to start (15 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    # Verify server started
    $attempts = 0
    $maxAttempts = 5
    $serverReady = $false
    
    while ($attempts -lt $maxAttempts -and -not $serverReady) {
        try {
            $health = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -TimeoutSec 3
            $serverReady = $true
            Write-Host "  Server is ready!" -ForegroundColor Green
        }
        catch {
            $attempts++
            Write-Host "  Attempt $attempts/$maxAttempts - Server not ready yet..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
    }
    
    if (-not $serverReady) {
        Write-Host "`n[ERROR] Server failed to start!" -ForegroundColor Red
        Write-Host "Please check the server window for errors.`n" -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "`n[2/3] Using existing server..." -ForegroundColor Green
}

# Run tests
Write-Host "`n[3/3] Running API tests..." -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

.\test-all-mobile-services.ps1

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
