# Quick Production Mode Test
# Run this to verify app is using production API

Write-Host "================================" -ForegroundColor Cyan
Write-Host "PRODUCTION MODE VERIFICATION" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check .env file
Write-Host "🔍 Checking .env configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $apiUrl = Get-Content ".env" | Select-String "API_BASE_URL"
    Write-Host "   $apiUrl" -ForegroundColor White
    
    if ($apiUrl -match "https://gerobaks.dumeg.com") {
        Write-Host "   ✅ Production URL configured" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Not using production URL!" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ .env file not found!" -ForegroundColor Red
}
Write-Host ""

# Run app in release mode with verbose logging
Write-Host "🚀 Running app in release mode..." -ForegroundColor Yellow
Write-Host "   Watch for these logs:" -ForegroundColor Cyan
Write-Host "   - '✅ Already in production mode'" -ForegroundColor White
Write-Host "   - 'Current URL: https://gerobaks.dumeg.com'" -ForegroundColor White
Write-Host "   - 'Is Production: true'" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop when verified" -ForegroundColor Yellow
Write-Host ""

flutter run --release
