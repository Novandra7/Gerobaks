# ========================================
# COMPREHENSIVE LOCAL API TEST SUITE
# Updated for 100% Pass Rate
# ========================================

$baseUrl = "http://localhost:8000/api"
$testResults = @()
$passCount = 0
$failCount = 0

# Test users credentials
$endUserCredentials = @{
    email    = "daffa@gmail.com"
    password = "password123"
}

$mitraCredentials = @{
    email    = "mitra@test.com"
    password = "password123"
}

$adminCredentials = @{
    email    = "admin@test.com"
    password = "password123"
}

# Tokens storage
$script:endUserToken = $null
$script:mitraToken = $null
$script:adminToken = $null

# Helper function to test endpoint
function Test-Endpoint {
    param(
        [string]$Service,
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null,
        [string]$Token = $null,
        [string]$ExpectedStatus = "PASS"
    )
    
    try {
        $url = "$baseUrl$Endpoint"
        $headers = @{
            "Accept"       = "application/json"
            "Content-Type" = "application/json"
        }
        
        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
            Write-Host "  [DEBUG] Using token: $($Token.Substring(0, 20))..." -ForegroundColor DarkGray
        }
        
        $params = @{
            Uri     = $url
            Method  = $Method
            Headers = $headers
        }
        
        if ($Body -and $Method -ne "GET") {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        
        $message = "Success"
        if ($response.data) {
            if ($response.data -is [Array]) {
                $message = "Retrieved $($response.data.Count) items"
            }
            elseif ($response.data.token) {
                $message = "Token received"
            }
            else {
                $message = "Data retrieved"
            }
        }
        elseif ($response.message) {
            $message = $response.message
        }
        
        Write-Host "[OK] $message" -ForegroundColor Green
        
        $script:testResults += @{
            Service  = $Service
            Endpoint = $Endpoint
            Method   = $Method
            Status   = "PASS"
            Message  = $message
        }
        $script:passCount++
        
        return $response
        
    }
    catch {
        $errorMsg = $_.Exception.Message
        $statusCode = $null
        
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        
        Write-Host "  [DEBUG] Status: $statusCode, Error: $errorMsg" -ForegroundColor DarkGray
        Write-Host "[ERROR] $errorMsg" -ForegroundColor Red
        
        $script:testResults += @{
            Service    = $Service
            Endpoint   = $Endpoint
            Method     = $Method
            Status     = "FAIL"
            Message    = $errorMsg
            StatusCode = $statusCode
        }
        $script:failCount++
        
        return $null
    }
}

# ========================================
# CHECK SERVER STATUS
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CHECKING LOCAL API SERVER..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    $healthCheck = Invoke-RestMethod -Uri "$baseUrl/ping" -Method GET
    Write-Host "[OK] Local API server is running!" -ForegroundColor Green
    Write-Host "[INFO] Server: $baseUrl`n" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Local API server is not running!" -ForegroundColor Red
    Write-Host "[INFO] Please start the server first with: php artisan serve`n" -ForegroundColor Yellow
    exit 1
}

# ========================================
# 1. AUTHENTICATION - LOGIN ALL USERS
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. AUTHENTICATION SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Login as end_user
Write-Host "[TEST] Login as END USER (POST /api/login)" -ForegroundColor Yellow
$loginResponse = Test-Endpoint -Service "Auth" -Endpoint "/login" -Method "POST" -Body $endUserCredentials
if ($loginResponse -and $loginResponse.data.token) {
    $script:endUserToken = $loginResponse.data.token
    Write-Host "[INFO] End User token: $($script:endUserToken.Substring(0, 30))...`n" -ForegroundColor Gray
}

# Login as mitra
Write-Host "[TEST] Login as MITRA (POST /api/login)" -ForegroundColor Yellow
$mitraLoginResponse = Test-Endpoint -Service "Auth" -Endpoint "/login" -Method "POST" -Body $mitraCredentials
if ($mitraLoginResponse -and $mitraLoginResponse.data.token) {
    $script:mitraToken = $mitraLoginResponse.data.token
    Write-Host "[INFO] Mitra token: $($script:mitraToken.Substring(0, 30))...`n" -ForegroundColor Gray
}

# Login as admin
Write-Host "[TEST] Login as ADMIN (POST /api/login)" -ForegroundColor Yellow
$adminLoginResponse = Test-Endpoint -Service "Auth" -Endpoint "/login" -Method "POST" -Body $adminCredentials
if ($adminLoginResponse -and $adminLoginResponse.data.token) {
    $script:adminToken = $adminLoginResponse.data.token
    Write-Host "[INFO] Admin token: $($script:adminToken.Substring(0, 30))...`n" -ForegroundColor Gray
}

# ========================================
# 2. TRACKING SERVICE
# ========================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "2. TRACKING SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/tracking - Get all tracking data" -ForegroundColor Yellow
Test-Endpoint -Service "Tracking" -Endpoint "/tracking" -Token $script:endUserToken

Write-Host "[TEST] POST /api/tracking - Create tracking point (as MITRA)" -ForegroundColor Yellow
$trackingData = @{
    schedule_id = 1
    latitude    = -6.200000
    longitude   = 106.816666
    status      = "in_progress"
}
Test-Endpoint -Service "Tracking" -Endpoint "/tracking" -Method "POST" -Body $trackingData -Token $script:mitraToken

# ========================================
# 3. RATING SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "3. RATING SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/ratings - Get all ratings" -ForegroundColor Yellow
Test-Endpoint -Service "Rating" -Endpoint "/ratings" -Token $script:endUserToken

Write-Host "[TEST] POST /api/ratings - Create rating (as END USER)" -ForegroundColor Yellow
$ratingData = @{
    order_id = 1
    rating   = 5
    comment  = "Excellent service!"
}
Test-Endpoint -Service "Rating" -Endpoint "/ratings" -Method "POST" -Body $ratingData -Token $script:endUserToken

# ========================================
# 4. CHAT SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "4. CHAT SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/chats - Get all messages" -ForegroundColor Yellow
Test-Endpoint -Service "Chat" -Endpoint "/chats" -Token $script:endUserToken

Write-Host "[TEST] POST /api/chats - Send message" -ForegroundColor Yellow
# Get mitra user ID dynamically (created user IDs may vary)
$chatData = @{
    receiver_id = 2  # Assuming mitra user ID is 2 (created second)
    message     = "Hello mitra!"
}
Test-Endpoint -Service "Chat" -Endpoint "/chats" -Method "POST" -Body $chatData -Token $script:endUserToken

# ========================================
# 5. PAYMENT SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "5. PAYMENT SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/payments - Get all payments" -ForegroundColor Yellow
Test-Endpoint -Service "Payment" -Endpoint "/payments" -Token $script:endUserToken

Write-Host "[TEST] POST /api/payments - Create payment" -ForegroundColor Yellow
$paymentData = @{
    order_id       = 1
    amount         = 50000
    payment_method = "cash"
}
Test-Endpoint -Service "Payment" -Endpoint "/payments" -Method "POST" -Body $paymentData -Token $script:endUserToken

# ========================================
# 6. BALANCE SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "6. BALANCE SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/balance/summary - Get balance summary" -ForegroundColor Yellow
Test-Endpoint -Service "Balance" -Endpoint "/balance/summary" -Token $script:endUserToken

Write-Host "[TEST] GET /api/balance/ledger - Get ledger history" -ForegroundColor Yellow
Test-Endpoint -Service "Balance" -Endpoint "/balance/ledger" -Token $script:endUserToken

Write-Host "[TEST] POST /api/balance/topup - Top-up balance" -ForegroundColor Yellow
$topupData = @{
    amount         = 100000
    payment_method = "transfer"
}
Test-Endpoint -Service "Balance" -Endpoint "/balance/topup" -Method "POST" -Body $topupData -Token $script:endUserToken

# ========================================
# 7. SCHEDULE SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "7. SCHEDULE SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/schedules - Get all schedules" -ForegroundColor Yellow
Test-Endpoint -Service "Schedule" -Endpoint "/schedules" -Token $script:endUserToken

Write-Host "[TEST] POST /api/schedules - Create schedule (as MITRA)" -ForegroundColor Yellow
$scheduleData = @{
    pickup_date = "2025-01-20"
    pickup_time = "09:00:00"
    area        = "Jakarta Selatan"
}
Test-Endpoint -Service "Schedule" -Endpoint "/schedules" -Method "POST" -Body $scheduleData -Token $script:mitraToken

# ========================================
# 8. ORDER SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "8. ORDER SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/orders - Get all orders" -ForegroundColor Yellow
Test-Endpoint -Service "Order" -Endpoint "/orders" -Token $script:endUserToken

Write-Host "[TEST] POST /api/orders - Create order (as END USER)" -ForegroundColor Yellow
$orderData = @{
    service_id   = 1
    schedule_id  = 3
    address_text = "Test Address"
    latitude     = -6.2
    longitude    = 106.8
}
Test-Endpoint -Service "Order" -Endpoint "/orders" -Method "POST" -Body $orderData -Token $script:endUserToken

# ========================================
# 9. NOTIFICATION SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "9. NOTIFICATION SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/notifications - Get all notifications" -ForegroundColor Yellow
Test-Endpoint -Service "Notification" -Endpoint "/notifications" -Token $script:endUserToken

Write-Host "[TEST] POST /api/notifications/mark-read - Mark notification as read" -ForegroundColor Yellow
$markReadData = @{
    notification_id = 1
}
Test-Endpoint -Service "Notification" -Endpoint "/notifications/mark-read" -Method "POST" -Body $markReadData -Token $script:endUserToken

# ========================================
# 10. SUBSCRIPTION SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "10. SUBSCRIPTION SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/subscription/plans - Get subscription plans" -ForegroundColor Yellow
Test-Endpoint -Service "Subscription" -Endpoint "/subscription/plans" -Token $script:endUserToken

Write-Host "[TEST] POST /api/subscription/subscribe - Subscribe to plan" -ForegroundColor Yellow
$subscribeData = @{
    plan_id        = 1
    payment_method = "credit_card"
}
Test-Endpoint -Service "Subscription" -Endpoint "/subscription/subscribe" -Method "POST" -Body $subscribeData -Token $script:endUserToken

# ========================================
# 11. FEEDBACK SERVICE
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "11. FEEDBACK SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/feedback - Get all feedback" -ForegroundColor Yellow
Test-Endpoint -Service "Feedback" -Endpoint "/feedback" -Token $script:endUserToken

Write-Host "[TEST] POST /api/feedback - Submit feedback" -ForegroundColor Yellow
$feedbackData = @{
    subject = "Test Feedback"
    message = "This is a test feedback message"
}
Test-Endpoint -Service "Feedback" -Endpoint "/feedback" -Method "POST" -Body $feedbackData -Token $script:endUserToken

# ========================================
# 12. USERS SERVICE (Admin)
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "12. ADMIN/USERS SERVICE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[TEST] GET /api/admin/users - Get all users (as ADMIN)" -ForegroundColor Yellow
Test-Endpoint -Service "Admin" -Endpoint "/admin/users" -Token $script:adminToken

# ========================================
# SUMMARY REPORT
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Group by service
$serviceGroups = $testResults | Group-Object -Property Service

Write-Host "`nTest Results by Service:" -ForegroundColor White
Write-Host "========================`n" -ForegroundColor White

foreach ($group in $serviceGroups) {
    $servicePassed = ($group.Group | Where-Object { $_.Status -eq "PASS" }).Count
    $serviceTotal = $group.Group.Count
    
    Write-Host "$($group.Name) Service: $servicePassed/$serviceTotal passed" -ForegroundColor Cyan
    
    foreach ($test in $group.Group) {
        $icon = if ($test.Status -eq "PASS") { "✅" } else { "❌" }
        $color = if ($test.Status -eq "PASS") { "Green" } else { "Red" }
        Write-Host "  $icon $($test.Method) $($test.Endpoint) - $($test.Message)" -ForegroundColor $color
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OVERALL SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$totalTests = $passCount + $failCount
$passRate = if ($totalTests -gt 0) { [math]::Round(($passCount / $totalTests) * 100, 2) } else { 0 }

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 50) { "Yellow" } else { "Red" })

# Save results to JSON
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportFile = "test-results-$timestamp.json"
$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "`nDetailed report saved to: $reportFile" -ForegroundColor Gray

Write-Host "`n[COMPLETE] Testing Complete!" -ForegroundColor Green
