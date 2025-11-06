# Production Build Script
# Clean, rebuild, and verify production configuration

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GEROBAKS PRODUCTION BUILD" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous builds
Write-Host "🧹 Step 1: Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter clean failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Clean complete!" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "📦 Step 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Pub get failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies installed!" -ForegroundColor Green
Write-Host ""

# Step 3: Verify .env file
Write-Host "🔍 Step 3: Verifying .env configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "API_BASE_URL=https://gerobaks.dumeg.com") {
        Write-Host "✅ Production API URL configured correctly!" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  WARNING: .env may not be configured for production!" -ForegroundColor Yellow
        Write-Host "Current .env content:" -ForegroundColor Yellow
        Get-Content ".env" | Select-String "API_BASE_URL"
    }
}
else {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Build release APK
Write-Host "🔨 Step 4: Building release APK..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host ""

# Step 5: Show APK location
Write-Host "================================" -ForegroundColor Cyan
Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 APK Location:" -ForegroundColor Yellow
Write-Host "   build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Test APK on device" -ForegroundColor White
Write-Host "   2. Verify production API is used" -ForegroundColor White
Write-Host "   3. Check startup logs for: '✅ Already in production mode'" -ForegroundColor White
Write-Host "   4. Test all features" -ForegroundColor White
Write-Host "   5. Deploy to production" -ForegroundColor White
Write-Host ""

# Optional: Show APK details
if (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
    $apkSize = (Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length / 1MB
    Write-Host "📊 APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
}
Write-Host ""
