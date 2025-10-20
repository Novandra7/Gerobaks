# ========================================
# GEROBAKS MOBILE API - 100% PASS RATE TEST
# All Endpoints with CORRECT Paths & Roles
# ========================================

$baseUrl = "http://localhost:8000/api"

# Colors
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Test { param($msg) Write-Host "[TEST] $msg" -ForegroundColor Yellow }

# Test tracking
$script:totalTests = 0
$script:passedTests = 0
$script:failedTests = 0
$script:testResults = @()

function Add-TestResult {
    param($service, $endpoint, $method, $status, $message)
    $script:totalTests++
    if ($status -eq "PASS") { $script:passedTests++ } else { $script:failedTests++ }
    $script:testResults += [PSCustomObject]@{
        Service = $service; Endpoint = $endpoint; Method = $method; Status = $status; Message = $message
    }
}

# HTTP Helper
function Invoke-Api {
    param([string]$Method, [string]$Endpoint, [string]$Token, [hashtable]$Body = $null)
    
    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    if ($Token) { $headers["Authorization"] = "Bearer $Token" }
    
    try {
        $params = @{ Uri = "$baseUrl$Endpoint"; Method = $Method; Headers = $headers; TimeoutSec = 30 }
        if ($Body) { $params["Body"] = ($Body | ConvertTo-Json -Depth 10) }
        
        $response = Invoke-RestMethod @params
        return @{ Success = $true; Data = $response }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message; StatusCode = $_.Exception.Response.StatusCode.value__ }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "MOBILE API - 100% PASS RATE TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ========================================
# 1. AUTHENTICATION - Login 3 users
# ========================================
Write-Host "`n1. AUTHENTICATION" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

# Login End User
Write-Test "Login as END USER"
$result = Invoke-Api -Method POST -Endpoint "/login" -Body @{ email = "daffa@gmail.com"; password = "password123" }
if ($result.Success) {
    $script:endUserToken = $result.Data.data.token
    Write-Success "End User logged in - Token: $($script:endUserToken.Substring(0,20))..."
    Add-TestResult "Auth" "/login" "POST" "PASS" "End user login"
} else {
    Write-Error "End user login failed: $($result.Error)"
    Add-TestResult "Auth" "/login" "POST" "FAIL" $result.Error
    exit 1
}

# Login Mitra
Write-Test "Login as MITRA"
$result = Invoke-Api -Method POST -Endpoint "/login" -Body @{ email = "mitra@test.com"; password = "password123" }
if ($result.Success) {
    $script:mitraToken = $result.Data.data.token
    Write-Success "Mitra logged in - Token: $($script:mitraToken.Substring(0,20))..."
    Add-TestResult "Auth" "/login" "POST" "PASS" "Mitra login"
} else {
    Write-Error "Mitra login failed: $($result.Error)"
    Add-TestResult "Auth" "/login" "POST" "FAIL" $result.Error
}

# Login Admin
Write-Test "Login as ADMIN"
$result = Invoke-Api -Method POST -Endpoint "/login" -Body @{ email = "admin@test.com"; password = "password123" }
if ($result.Success) {
    $script:adminToken = $result.Data.data.token
    Write-Success "Admin logged in - Token: $($script:adminToken.Substring(0,20))..."
    Add-TestResult "Auth" "/login" "POST" "PASS" "Admin login"
} else {
    Write-Error "Admin login failed: $($result.Error)"
    Add-TestResult "Auth" "/login" "POST" "FAIL" $result.Error
}

# ========================================
# 2. TRACKING SERVICE
# ========================================
Write-Host "`n2. TRACKING SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /tracking"
$result = Invoke-Api -Method GET -Endpoint "/tracking" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count tracking points"
    Add-TestResult "Tracking" "/tracking" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Tracking" "/tracking" "GET" "FAIL" $result.Error
}

Write-Test "POST /tracking (as MITRA)"
$result = Invoke-Api -Method POST -Endpoint "/tracking" -Token $script:mitraToken -Body @{
    schedule_id = 1
    latitude = -6.2
    longitude = 106.816666
    recorded_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}
if ($result.Success) {
    Write-Success "Tracking created"
    Add-TestResult "Tracking" "/tracking" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Tracking" "/tracking" "POST" "FAIL" $result.Error
}

# ========================================
# 3. RATING SERVICE
# ========================================
Write-Host "`n3. RATING SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /ratings"
$result = Invoke-Api -Method GET -Endpoint "/ratings" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count ratings"
    Add-TestResult "Rating" "/ratings" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Rating" "/ratings" "GET" "FAIL" $result.Error
}

Write-Test "POST /ratings"
$result = Invoke-Api -Method POST -Endpoint "/ratings" -Token $script:endUserToken -Body @{
    order_id = 1
    rating = 5
    comment = "Great service!"
}
if ($result.Success) {
    Write-Success "Rating created"
    Add-TestResult "Rating" "/ratings" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Rating" "/ratings" "POST" "FAIL" $result.Error
}

# ========================================
# 4. CHAT SERVICE
# ========================================
Write-Host "`n4. CHAT SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /chats"
$result = Invoke-Api -Method GET -Endpoint "/chats" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count chats"
    Add-TestResult "Chat" "/chats" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Chat" "/chats" "GET" "FAIL" $result.Error
}

Write-Test "POST /chats"
$result = Invoke-Api -Method POST -Endpoint "/chats" -Token $script:endUserToken -Body @{
    receiver_id = 2
    message = "Hello from PowerShell test!"
}
if ($result.Success) {
    Write-Success "Chat sent"
    Add-TestResult "Chat" "/chats" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Chat" "/chats" "POST" "FAIL" $result.Error
}

# ========================================
# 5. PAYMENT SERVICE
# ========================================
Write-Host "`n5. PAYMENT SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /payments"
$result = Invoke-Api -Method GET -Endpoint "/payments" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count payments"
    Add-TestResult "Payment" "/payments" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Payment" "/payments" "GET" "FAIL" $result.Error
}

Write-Test "POST /payments"
$result = Invoke-Api -Method POST -Endpoint "/payments" -Token $script:endUserToken -Body @{
    order_id = 1
    amount = 50000
    payment_method = "cash"
}
if ($result.Success) {
    Write-Success "Payment created"
    Add-TestResult "Payment" "/payments" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Payment" "/payments" "POST" "FAIL" $result.Error
}

# ========================================
# 6. BALANCE SERVICE (FIXED PATHS)
# ========================================
Write-Host "`n6. BALANCE SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /balance/summary (FIXED: was /balance)"
$result = Invoke-Api -Method GET -Endpoint "/balance/summary" -Token $script:endUserToken
if ($result.Success) {
    Write-Success "Balance summary retrieved"
    Add-TestResult "Balance" "/balance/summary" "GET" "PASS" "Retrieved successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Balance" "/balance/summary" "GET" "FAIL" $result.Error
}

Write-Test "GET /balance/ledger"
$result = Invoke-Api -Method GET -Endpoint "/balance/ledger" -Token $script:endUserToken
if ($result.Success) {
    Write-Success "Balance ledger retrieved"
    Add-TestResult "Balance" "/balance/ledger" "GET" "PASS" "Retrieved successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Balance" "/balance/ledger" "GET" "FAIL" $result.Error
}

Write-Test "POST /balance/topup"
$result = Invoke-Api -Method POST -Endpoint "/balance/topup" -Token $script:endUserToken -Body @{
    amount = 100000
    payment_method = "transfer"
}
if ($result.Success) {
    Write-Success "Topup created"
    Add-TestResult "Balance" "/balance/topup" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Balance" "/balance/topup" "POST" "FAIL" $result.Error
}

# ========================================
# 7. SCHEDULE SERVICE
# ========================================
Write-Host "`n7. SCHEDULE SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /schedules"
$result = Invoke-Api -Method GET -Endpoint "/schedules" -Token $script:endUserToken
if ($result.Success) {
    Write-Success "Schedules retrieved"
    Add-TestResult "Schedule" "/schedules" "GET" "PASS" "Retrieved successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Schedule" "/schedules" "GET" "FAIL" $result.Error
}

Write-Test "POST /schedules (as MITRA)"
$result = Invoke-Api -Method POST -Endpoint "/schedules" -Token $script:mitraToken -Body @{
    pickup_date = "2025-01-20"
    pickup_time = "09:00:00"
    area = "Jakarta Selatan"
}
if ($result.Success) {
    Write-Success "Schedule created"
    Add-TestResult "Schedule" "/schedules" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Schedule" "/schedules" "POST" "FAIL" $result.Error
}

# ========================================
# 8. ORDER SERVICE
# ========================================
Write-Host "`n8. ORDER SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /orders"
$result = Invoke-Api -Method GET -Endpoint "/orders" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count orders"
    Add-TestResult "Order" "/orders" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Order" "/orders" "GET" "FAIL" $result.Error
}

Write-Test "POST /orders"
$result = Invoke-Api -Method POST -Endpoint "/orders" -Token $script:endUserToken -Body @{
    service_id = 1
    schedule_id = 3
    address_text = "Test Address PowerShell"
    latitude = -6.2
    longitude = 106.8
}
if ($result.Success) {
    Write-Success "Order created"
    Add-TestResult "Order" "/orders" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Order" "/orders" "POST" "FAIL" $result.Error
}

# ========================================
# 9. NOTIFICATION SERVICE (FIXED PATH)
# ========================================
Write-Host "`n9. NOTIFICATION SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /notifications"
$result = Invoke-Api -Method GET -Endpoint "/notifications" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count notifications"
    Add-TestResult "Notification" "/notifications" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Notification" "/notifications" "GET" "FAIL" $result.Error
}

Write-Test "POST /notifications/mark-read (FIXED: was PUT /mark-all-read)"
$result = Invoke-Api -Method POST -Endpoint "/notifications/mark-read" -Token $script:endUserToken
if ($result.Success) {
    Write-Success "Notifications marked as read"
    Add-TestResult "Notification" "/notifications/mark-read" "POST" "PASS" "Marked successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Notification" "/notifications/mark-read" "POST" "FAIL" $result.Error
}

# ========================================
# 10. SUBSCRIPTION SERVICE (FIXED PATHS)
# ========================================
Write-Host "`n10. SUBSCRIPTION SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /subscription/plans (FIXED: was /subscriptions)"
$result = Invoke-Api -Method GET -Endpoint "/subscription/plans" -Token $script:endUserToken
if ($result.Success) {
    $count = if ($result.Data.data) { $result.Data.data.Count } else { 0 }
    Write-Success "Retrieved $count subscription plans"
    Add-TestResult "Subscription" "/subscription/plans" "GET" "PASS" "Retrieved $count items"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Subscription" "/subscription/plans" "GET" "FAIL" $result.Error
}

Write-Test "POST /subscription/subscribe (FIXED: was POST /subscriptions)"
$result = Invoke-Api -Method POST -Endpoint "/subscription/subscribe" -Token $script:endUserToken -Body @{
    plan_id = 1
    payment_method = "credit_card"
}
if ($result.Success) {
    Write-Success "Subscription created"
    Add-TestResult "Subscription" "/subscription/subscribe" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Subscription" "/subscription/subscribe" "POST" "FAIL" $result.Error
}

# ========================================
# 11. FEEDBACK SERVICE
# ========================================
Write-Host "`n11. FEEDBACK SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /feedback"
$result = Invoke-Api -Method GET -Endpoint "/feedback" -Token $script:endUserToken
if ($result.Success) {
    Write-Success "Feedback retrieved"
    Add-TestResult "Feedback" "/feedback" "GET" "PASS" "Retrieved successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Feedback" "/feedback" "GET" "FAIL" $result.Error
}

Write-Test "POST /feedback"
$result = Invoke-Api -Method POST -Endpoint "/feedback" -Token $script:endUserToken -Body @{
    subject = "PowerShell Test Feedback"
    message = "Testing from PowerShell 100% script"
}
if ($result.Success) {
    Write-Success "Feedback submitted"
    Add-TestResult "Feedback" "/feedback" "POST" "PASS" "Created successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Feedback" "/feedback" "POST" "FAIL" $result.Error
}

# ========================================
# 12. ADMIN SERVICE (FIXED PATH)
# ========================================
Write-Host "`n12. ADMIN SERVICE" -ForegroundColor Magenta
Write-Host "==================`n" -ForegroundColor Magenta

Write-Test "GET /admin/users (FIXED: was /users)"
$result = Invoke-Api -Method GET -Endpoint "/admin/users" -Token $script:adminToken
if ($result.Success) {
    Write-Success "Admin users retrieved"
    Add-TestResult "Admin" "/admin/users" "GET" "PASS" "Retrieved successfully"
} else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Admin" "/admin/users" "GET" "FAIL" $result.Error
}

# ========================================
# FINAL SUMMARY
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "FINAL SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Total Tests: $script:totalTests" -ForegroundColor White
Write-Host "Passed: $script:passedTests" -ForegroundColor Green
Write-Host "Failed: $script:failedTests" -ForegroundColor Red

$passRate = [math]::Round(($script:passedTests / $script:totalTests) * 100, 2)
Write-Host "Pass Rate: $passRate%`n" -ForegroundColor $(if ($passRate -eq 100) { "Green" } else { "Yellow" })

if ($script:failedTests -eq 0) {
    Write-Host "🎉🎉🎉 100% PASS RATE ACHIEVED! 🎉🎉🎉`n" -ForegroundColor Green
} else {
    Write-Host "`nFailed Tests:" -ForegroundColor Red
    $script:testResults | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object {
        Write-Host "  ❌ $($_.Method) $($_.Endpoint) - $($_.Message)" -ForegroundColor Red
    }
}

# Save detailed report
$reportFile = "test-results-powershell-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$script:testResults | ConvertTo-Json -Depth 10 | Out-File $reportFile
Write-Host "`nDetailed report saved to: $reportFile`n" -ForegroundColor Cyan
