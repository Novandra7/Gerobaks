# ========================================
# GEROBAKS API - QUICK ENDPOINT TEST (FIXED PATHS)
# Test dengan endpoint paths yang CORRECT sesuai backend
# ========================================

$baseUrl = "https://gerobaks.dumeg.com/api"
$authToken = ""

function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Test { param($msg) Write-Host "[TEST] $msg" -ForegroundColor Yellow }
function Write-Section { param($msg) Write-Host "`n========== $msg ==========" -ForegroundColor Cyan }

$script:passed = 0
$script:failed = 0

function Test-Endpoint {
    param($Method, $Path, $Body = $null)
    
    $script:total++
    $headers = @{
        "Content-Type" = "application/json"
        "Accept"       = "application/json"
    }
    
    if ($authToken) {
        $headers["Authorization"] = "Bearer $authToken"
    }
    
    try {
        $params = @{
            Uri        = "$baseUrl$Path"
            Method     = $Method
            Headers    = $headers
            TimeoutSec = 15
        }
        
        if ($Body) {
            $params["Body"] = ($Body | ConvertTo-Json -Depth 5)
        }
        
        $response = Invoke-RestMethod @params
        Write-Success "$Method $Path - SUCCESS"
        $script:passed++
        return $true
    }
    catch {
        $status = $_.Exception.Response.StatusCode.value__
        Write-Error "$Method $Path - FAILED ($status)"
        $script:failed++
        return $false
    }
}

# ========================================
# 1. LOGIN
# ========================================
Write-Section "1. AUTHENTICATION"
Write-Test "POST /login"
try {
    $loginBody = @{
        email    = "daffa@gmail.com"
        password = "password123"
    }
    $response = Invoke-RestMethod -Uri "$baseUrl/login" -Method POST -Body ($loginBody | ConvertTo-Json) -ContentType "application/json"
    $authToken = $response.data.token
    Write-Success "Login successful! Token: $($authToken.Substring(0,20))..."
    $script:passed++
}
catch {
    Write-Error "Login failed!"
    $script:failed++
    exit 1
}

# ========================================
# 2. TRACKING (FIXED PATHS)
# ========================================
Write-Section "2. TRACKING SERVICE"
Test-Endpoint "GET" "/tracking"  # FIXED: was /trackings
Test-Endpoint "GET" "/tracking?limit=5"
Test-Endpoint "POST" "/tracking" @{
    schedule_id = 1
    latitude    = "-6.2088"
    longitude   = "106.8456"
    speed       = "45.50"
}

# ========================================
# 3. RATINGS
# ========================================
Write-Section "3. RATING SERVICE"
Test-Endpoint "GET" "/ratings"  # Public endpoint
Test-Endpoint "POST" "/ratings" @{
    order_id = 1
    rating   = 5
    comment  = "Test from API"
}

# ========================================
# 4. SCHEDULES
# ========================================
Write-Section "4. SCHEDULE SERVICE"
Test-Endpoint "GET" "/schedules"
Test-Endpoint "POST" "/schedules" @{
    pickup_date = "2025-10-20"
    pickup_time = "14:00"
    address     = "Test Address"
}

# ========================================
# 5. ORDERS
# ========================================
Write-Section "5. ORDER SERVICE"
Test-Endpoint "GET" "/orders"
Test-Endpoint "POST" "/orders" @{
    service_id       = 1
    pickup_location  = "Jakarta"
    dropoff_location = "Bekasi"
}

# ========================================
# 6. PAYMENTS
# ========================================
Write-Section "6. PAYMENT SERVICE"
Test-Endpoint "GET" "/payments"
Test-Endpoint "POST" "/payments" @{
    order_id = 1
    amount   = "50000"
    method   = "cash"
}

# ========================================
# 7. BALANCE (FIXED PATHS)
# ========================================
Write-Section "7. BALANCE SERVICE"
Test-Endpoint "GET" "/balance/summary"  # FIXED: /balance doesn't exist
Test-Endpoint "GET" "/balance/ledger"
Test-Endpoint "POST" "/balance/topup" @{
    amount = "100000"
    method = "bank_transfer"
}

# ========================================
# 8. NOTIFICATIONS
# ========================================
Write-Section "8. NOTIFICATION SERVICE"
Test-Endpoint "GET" "/notifications"
Test-Endpoint "POST" "/notifications/mark-read" @{
    notification_ids = @(1, 2, 3)
}

# ========================================
# 9. CHAT
# ========================================
Write-Section "9. CHAT SERVICE"
Test-Endpoint "GET" "/chats"
Test-Endpoint "POST" "/chats" @{
    receiver_id = 2
    message     = "Hello from API test"
}

# ========================================
# 10. FEEDBACK
# ========================================
Write-Section "10. FEEDBACK SERVICE"
Test-Endpoint "GET" "/feedback"
Test-Endpoint "POST" "/feedback" @{
    subject  = "Test"
    message  = "Test feedback"
    category = "bug"
}

# ========================================
# 11. SUBSCRIPTION (FIXED PATHS)
# ========================================
Write-Section "11. SUBSCRIPTION SERVICE"
Test-Endpoint "GET" "/subscription/plans"  # FIXED: was /subscriptions
Test-Endpoint "GET" "/subscription/current"
Test-Endpoint "POST" "/subscription/subscribe" @{
    plan_id = 1
}

# ========================================
# 12. ADMIN/USERS (FIXED PATHS)
# ========================================
Write-Section "12. ADMIN/USERS SERVICE"
Test-Endpoint "GET" "/admin/users"  # FIXED: was /users (requires admin role)
Test-Endpoint "GET" "/admin/stats"

# ========================================
# SUMMARY
# ========================================
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "TEST SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Passed: $script:passed" -ForegroundColor Green
Write-Host "Failed: $script:failed" -ForegroundColor Red
$total = $script:passed + $script:failed
$passRate = [math]::Round(($script:passed / $total) * 100, 1)
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 70) { "Green" } else { "Yellow" })

Write-Host "`nDone!" -ForegroundColor Cyan
