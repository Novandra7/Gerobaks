# ========================================
# GEROBAKS API - START LOCAL SERVER
# Database: Online MySQL (202.10.35.161)
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "GEROBAKS API - LOCAL SERVER" -ForegroundColor Cyan
Write-Host "Database: Online MySQL (202.10.35.161)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if backend directory exists
if (-not (Test-Path "backend")) {
    Write-Host "[ERROR] Backend directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory.`n" -ForegroundColor Yellow
    exit 1
}

# Navigate to backend
Set-Location backend

# Step 1: Check PHP
Write-Host "[1/5] Checking PHP installation..." -ForegroundColor Yellow
try {
    $phpVersion = php --version
    Write-Host $phpVersion -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] PHP not found! Please install PHP first." -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Step 2: Check .env file
Write-Host "`n[2/5] Checking .env configuration..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "[ERROR] .env file not found!" -ForegroundColor Red
    Write-Host "Please copy .env.example to .env and configure it.`n" -ForegroundColor Yellow
    Set-Location ..
    exit 1
}

# Read and display database config
$envContent = Get-Content ".env"
$dbHost = ($envContent | Select-String "^DB_HOST=").ToString().Split("=")[1]
$dbDatabase = ($envContent | Select-String "^DB_DATABASE=").ToString().Split("=")[1]
$dbUsername = ($envContent | Select-String "^DB_USERNAME=").ToString().Split("=")[1]

Write-Host "  Database: $dbDatabase" -ForegroundColor Cyan
Write-Host "  Host: $dbHost" -ForegroundColor Cyan
Write-Host "  User: $dbUsername" -ForegroundColor Cyan

# Step 3: Install dependencies (if needed)
Write-Host "`n[3/5] Checking Composer dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "vendor")) {
    Write-Host "  Installing dependencies..." -ForegroundColor Yellow
    composer install
}
else {
    Write-Host "  Dependencies already installed." -ForegroundColor Green
}

# Step 4: Clear cache
Write-Host "`n[4/5] Clearing Laravel cache..." -ForegroundColor Yellow
php artisan config:clear
php artisan cache:clear
php artisan route:clear
Write-Host "  Cache cleared!" -ForegroundColor Green

# Step 5: Start server
Write-Host "`n[5/5] Starting Laravel development server..." -ForegroundColor Yellow
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "API URL: http://localhost:8000" -ForegroundColor Green
Write-Host "API Endpoints: http://localhost:8000/api" -ForegroundColor Green
Write-Host "Database: $dbDatabase @ $dbHost" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nPress Ctrl+C to stop the server...`n" -ForegroundColor Yellow

# Start the server
php artisan serve --host=0.0.0.0 --port=8000

# Cleanup on exit
Set-Location ..
