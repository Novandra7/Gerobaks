# ========================================
# GEROBAKS API - COMPREHENSIVE ENDPOINT TESTING
# Test ALL Mobile Service Endpoints (GET, POST, PUT, DELETE)
# Using LOCAL API with ONLINE DATABASE
# ========================================

# CONFIGURATION
$baseUrl = "http://localhost:8000/api"  # Local API URL (HTTP not HTTPS)
$script:authToken = ""  # Will be filled after login

# Check if server is running
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CHECKING LOCAL API SERVER..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5
    Write-Host "[OK] Local API server is running!" -ForegroundColor Green
    Write-Host "[INFO] Server: http://localhost:8000" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Local API server is NOT running!" -ForegroundColor Red
    Write-Host "`nPlease start the server first:" -ForegroundColor Yellow
    Write-Host "  .\start-local-api.bat" -ForegroundColor Yellow
    Write-Host "`nOr manually:" -ForegroundColor Yellow
    Write-Host "  cd backend" -ForegroundColor Yellow
    Write-Host "  php artisan serve --host=0.0.0.0 --port=8000`n" -ForegroundColor Yellow
    exit 1
}

# Colors for output
function Write-Success { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Test { param($msg) Write-Host "[TEST] $msg" -ForegroundColor Yellow }
function Write-Section { param($msg) Write-Host "`n========================================" -ForegroundColor Magenta; Write-Host "$msg" -ForegroundColor Magenta; Write-Host "========================================`n" -ForegroundColor Magenta }

# Test Results Tracking
$script:totalTests = 0
$script:passedTests = 0
$script:failedTests = 0
$script:testResults = @()

function Add-TestResult {
    param($service, $endpoint, $method, $status, $message)
    $script:totalTests++
    if ($status -eq "PASS") {
        $script:passedTests++
    }
    else {
        $script:failedTests++
    }
    $script:testResults += [PSCustomObject]@{
        Service  = $service
        Endpoint = $endpoint
        Method   = $method
        Status   = $status
        Message  = $message
    }
}

# HTTP Request Helper
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [bool]$RequireAuth = $true
    )
    
    $headers = @{
        "Content-Type" = "application/json"
        "Accept"       = "application/json"
    }
    
    if ($RequireAuth -and $script:authToken) {
        $headers["Authorization"] = "Bearer $script:authToken"
        Write-Host "  [DEBUG] Using auth token: $($script:authToken.Substring(0,15))..." -ForegroundColor DarkGray
    }
    elseif ($RequireAuth -and -not $script:authToken) {
        Write-Host "  [WARNING] Auth required but no token available!" -ForegroundColor Yellow
    }
    
    $uri = "$baseUrl$Endpoint"
    
    try {
        $params = @{
            Uri        = $uri
            Method     = $Method
            Headers    = $headers
            TimeoutSec = 30
        }
        
        if ($Body) {
            $params["Body"] = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return @{ Success = $true; Data = $response }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMsg = if ($_.ErrorDetails.Message) { 
            $_.ErrorDetails.Message 
        }
        else { 
            $_.Exception.Message 
        }
        Write-Host "  [DEBUG] Status: $statusCode, Error: $errorMsg" -ForegroundColor DarkGray
        return @{ Success = $false; StatusCode = $statusCode; Error = $errorMsg }
    }
}

# ========================================
# 1. AUTHENTICATION TEST
# ========================================
Write-Section "1. AUTHENTICATION SERVICE"

Write-Test "Testing Login (POST /api/login)"
$loginResult = Invoke-ApiRequest -Method POST -Endpoint "/login" -RequireAuth $false -Body @{
    email    = "daffa@gmail.com"
    password = "password123"
}

if ($loginResult.Success) {
    $script:authToken = $loginResult.Data.data.token
    Write-Success "Login successful! Token received: $($script:authToken.Substring(0,20))..."
    Write-Info "Full token stored in `$script:authToken for subsequent requests"
    Add-TestResult "Auth" "/login" "POST" "PASS" "Login successful"
}
else {
    Write-Error "Login failed: $($loginResult.Error)"
    Add-TestResult "Auth" "/login" "POST" "FAIL" $loginResult.Error
    Write-Error "Cannot continue without authentication. Exiting..."
    exit 1
}

# ========================================
# 2. TRACKING SERVICE TESTS
# ========================================
Write-Section "2. TRACKING SERVICE"

# GET /api/tracking (FIXED: singular not plural)
Write-Test "GET /api/tracking - Get all tracking data"
$result = Invoke-ApiRequest -Method GET -Endpoint "/tracking"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count tracking points"
    Add-TestResult "Tracking" "/tracking" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Tracking" "/tracking" "GET" "FAIL" $result.Error
}

# POST /api/tracking - Create tracking (FIXED: singular)
Write-Test "POST /api/tracking - Create tracking point"
$newTracking = @{
    schedule_id = 1
    latitude    = -6.2088
    longitude   = 106.8456
    status      = "on_the_way"
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/tracking" -Body $newTracking
if ($result.Success) {
    $trackingId = $result.Data.data.id
    Write-Success "Tracking created with ID: $trackingId"
    Add-TestResult "Tracking" "/trackings" "POST" "PASS" "Created ID: $trackingId"
    
    # PUT /api/trackings/{id} - Update tracking
    Write-Test "PUT /api/trackings/$trackingId - Update tracking"
    $updateTracking = @{
        latitude  = -6.2100
        longitude = 106.8470
        status    = "arrived"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/trackings/$trackingId" -Body $updateTracking
    if ($result.Success) {
        Write-Success "Tracking updated successfully"
        Add-TestResult "Tracking" "/trackings/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Tracking" "/trackings/{id}" "PUT" "FAIL" $result.Error
    }
    
    # GET /api/trackings/{id} - Get by ID
    Write-Test "GET /api/trackings/$trackingId - Get tracking by ID"
    $result = Invoke-ApiRequest -Method GET -Endpoint "/trackings/$trackingId"
    if ($result.Success) {
        Write-Success "Retrieved tracking details"
        Add-TestResult "Tracking" "/trackings/{id}" "GET" "PASS" "Retrieved successfully"
    }
    else {
        Write-Error "Failed: $($result.Error)"
        Add-TestResult "Tracking" "/trackings/{id}" "GET" "FAIL" $result.Error
    }
    
    # DELETE /api/trackings/{id}
    Write-Test "DELETE /api/trackings/$trackingId - Delete tracking"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/trackings/$trackingId"
    if ($result.Success) {
        Write-Success "Tracking deleted successfully"
        Add-TestResult "Tracking" "/trackings/{id}" "DELETE" "PASS" "Deleted successfully"
    }
    else {
        Write-Error "Delete failed: $($result.Error)"
        Add-TestResult "Tracking" "/trackings/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Tracking" "/trackings" "POST" "FAIL" $result.Error
}

# ========================================
# 3. RATING SERVICE TESTS
# ========================================
Write-Section "3. RATING SERVICE"

# GET /api/ratings
Write-Test "GET /api/ratings - Get all ratings"
$result = Invoke-ApiRequest -Method GET -Endpoint "/ratings"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count ratings"
    Add-TestResult "Rating" "/ratings" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Rating" "/ratings" "GET" "FAIL" $result.Error
}

# POST /api/ratings - Create rating (mitra_id auto-populated)
Write-Test "POST /api/ratings - Create rating"
$newRating = @{
    order_id = 1
    score    = 5
    review   = "Excellent service from API test!"
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/ratings" -Body $newRating
if ($result.Success) {
    $ratingId = $result.Data.data.id
    Write-Success "Rating created with ID: $ratingId (mitra_id auto-filled)"
    Add-TestResult "Rating" "/ratings" "POST" "PASS" "Created ID: $ratingId"
    
    # PUT /api/ratings/{id} - Update rating
    Write-Test "PUT /api/ratings/$ratingId - Update rating"
    $updateRating = @{
        score  = 4
        review = "Updated: Very good service"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/ratings/$ratingId" -Body $updateRating
    if ($result.Success) {
        Write-Success "Rating updated successfully"
        Add-TestResult "Rating" "/ratings/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Rating" "/ratings/{id}" "PUT" "FAIL" $result.Error
    }
    
    # DELETE /api/ratings/{id}
    Write-Test "DELETE /api/ratings/$ratingId - Delete rating"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/ratings/$ratingId"
    if ($result.Success) {
        Write-Success "Rating deleted successfully"
        Add-TestResult "Rating" "/ratings/{id}" "DELETE" "PASS" "Deleted successfully"
    }
    else {
        Write-Error "Delete failed: $($result.Error)"
        Add-TestResult "Rating" "/ratings/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Rating" "/ratings" "POST" "FAIL" $result.Error
}

# ========================================
# 4. CHAT SERVICE TESTS
# ========================================
Write-Section "4. CHAT SERVICE"

# GET /api/chats
Write-Test "GET /api/chats - Get all messages"
$result = Invoke-ApiRequest -Method GET -Endpoint "/chats"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count messages"
    Add-TestResult "Chat" "/chats" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Chat" "/chats" "GET" "FAIL" $result.Error
}

# POST /api/chats - Send message
Write-Test "POST /api/chats - Send message"
$newMessage = @{
    receiver_id = 2
    message     = "Hello from API test!"
    type        = "text"
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/chats" -Body $newMessage
if ($result.Success) {
    $chatId = $result.Data.data.id
    Write-Success "Message sent with ID: $chatId"
    Add-TestResult "Chat" "/chats" "POST" "PASS" "Created ID: $chatId"
    
    # PUT /api/chats/{id} - Update message
    Write-Test "PUT /api/chats/$chatId - Update message"
    $updateMessage = @{
        message = "Updated message from API test!"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/chats/$chatId" -Body $updateMessage
    if ($result.Success) {
        Write-Success "Message updated successfully"
        Add-TestResult "Chat" "/chats/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Chat" "/chats/{id}" "PUT" "FAIL" $result.Error
    }
    
    # DELETE /api/chats/{id}
    Write-Test "DELETE /api/chats/$chatId - Delete message"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/chats/$chatId"
    if ($result.Success) {
        Write-Success "Message deleted successfully"
        Add-TestResult "Chat" "/chats/{id}" "DELETE" "PASS" "Deleted successfully"
    }
    else {
        Write-Error "Delete failed: $($result.Error)"
        Add-TestResult "Chat" "/chats/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Chat" "/chats" "POST" "FAIL" $result.Error
}

# ========================================
# 5. PAYMENT SERVICE TESTS
# ========================================
Write-Section "5. PAYMENT SERVICE"

# GET /api/payments
Write-Test "GET /api/payments - Get all payments"
$result = Invoke-ApiRequest -Method GET -Endpoint "/payments"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count payments"
    Add-TestResult "Payment" "/payments" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Payment" "/payments" "GET" "FAIL" $result.Error
}

# POST /api/payments - Create payment
Write-Test "POST /api/payments - Create payment"
$newPayment = @{
    order_id = 1
    amount   = 50000
    method   = "cash"
    status   = "pending"
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/payments" -Body $newPayment
if ($result.Success) {
    $paymentId = $result.Data.data.id
    Write-Success "Payment created with ID: $paymentId"
    Add-TestResult "Payment" "/payments" "POST" "PASS" "Created ID: $paymentId"
    
    # PUT /api/payments/{id} - Update payment
    Write-Test "PUT /api/payments/$paymentId - Update payment"
    $updatePayment = @{
        status = "completed"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/payments/$paymentId" -Body $updatePayment
    if ($result.Success) {
        Write-Success "Payment updated successfully"
        Add-TestResult "Payment" "/payments/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Payment" "/payments/{id}" "PUT" "FAIL" $result.Error
    }
    
    # PUT /api/payments/{id}/mark-paid - Mark as paid
    Write-Test "PUT /api/payments/$paymentId/mark-paid - Mark as paid"
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/payments/$paymentId/mark-paid" -Body @{}
    if ($result.Success) {
        Write-Success "Payment marked as paid"
        Add-TestResult "Payment" "/payments/{id}/mark-paid" "PUT" "PASS" "Marked as paid"
    }
    else {
        Write-Error "Mark paid failed: $($result.Error)"
        Add-TestResult "Payment" "/payments/{id}/mark-paid" "PUT" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Payment" "/payments" "POST" "FAIL" $result.Error
}

# ========================================
# 6. BALANCE SERVICE TESTS
# ========================================
Write-Section "6. BALANCE SERVICE"

# GET /api/balance
Write-Test "GET /api/balance - Get current balance"
$result = Invoke-ApiRequest -Method GET -Endpoint "/balance"
if ($result.Success) {
    $balance = $result.Data.data.amount
    Write-Success "Current balance: Rp $balance"
    Add-TestResult "Balance" "/balance" "GET" "PASS" "Balance: Rp $balance"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Balance" "/balance" "GET" "FAIL" $result.Error
}

# POST /api/balance/topup - Top-up balance
Write-Test "POST /api/balance/topup - Top-up balance"
$topup = @{
    amount = 100000
    method = "va"
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/balance/topup" -Body $topup
if ($result.Success) {
    Write-Success "Top-up request submitted"
    Add-TestResult "Balance" "/balance/topup" "POST" "PASS" "Top-up Rp 100,000"
}
else {
    Write-Error "Top-up failed: $($result.Error)"
    Add-TestResult "Balance" "/balance/topup" "POST" "FAIL" $result.Error
}

# GET /api/balance/ledger - Get transaction history
Write-Test "GET /api/balance/ledger - Get ledger history"
$result = Invoke-ApiRequest -Method GET -Endpoint "/balance/ledger"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count ledger entries"
    Add-TestResult "Balance" "/balance/ledger" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Balance" "/balance/ledger" "GET" "FAIL" $result.Error
}

# GET /api/balance/summary - Get balance summary
Write-Test "GET /api/balance/summary - Get balance summary"
$result = Invoke-ApiRequest -Method GET -Endpoint "/balance/summary"
if ($result.Success) {
    Write-Success "Balance summary retrieved"
    Add-TestResult "Balance" "/balance/summary" "GET" "PASS" "Summary retrieved"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Balance" "/balance/summary" "GET" "FAIL" $result.Error
}

# ========================================
# 7. SCHEDULE SERVICE TESTS
# ========================================
Write-Section "7. SCHEDULE SERVICE"

# GET /api/schedules
Write-Test "GET /api/schedules - Get all schedules"
$result = Invoke-ApiRequest -Method GET -Endpoint "/schedules"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count schedules"
    Add-TestResult "Schedule" "/schedules" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Schedule" "/schedules" "GET" "FAIL" $result.Error
}

# POST /api/schedules - Create schedule
Write-Test "POST /api/schedules - Create schedule"
$newSchedule = @{
    pickup_date = "2025-01-20"
    pickup_time = "14:00"
    address     = "Jl. Testing API No. 123"
    latitude    = -6.2088
    longitude   = 106.8456
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/schedules" -Body $newSchedule
if ($result.Success) {
    $scheduleId = $result.Data.data.id
    Write-Success "Schedule created with ID: $scheduleId"
    Add-TestResult "Schedule" "/schedules" "POST" "PASS" "Created ID: $scheduleId"
    
    # PUT /api/schedules/{id} - Update schedule
    Write-Test "PUT /api/schedules/$scheduleId - Update schedule"
    $updateSchedule = @{
        pickup_time = "15:00"
        notes       = "Updated time via API test"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/schedules/$scheduleId" -Body $updateSchedule
    if ($result.Success) {
        Write-Success "Schedule updated successfully"
        Add-TestResult "Schedule" "/schedules/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Schedule" "/schedules/{id}" "PUT" "FAIL" $result.Error
    }
    
    # DELETE /api/schedules/{id}
    Write-Test "DELETE /api/schedules/$scheduleId - Delete schedule"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/schedules/$scheduleId"
    if ($result.Success) {
        Write-Success "Schedule deleted successfully"
        Add-TestResult "Schedule" "/schedules/{id}" "DELETE" "PASS" "Deleted successfully"
    }
    else {
        Write-Error "Delete failed: $($result.Error)"
        Add-TestResult "Schedule" "/schedules/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Schedule" "/schedules" "POST" "FAIL" $result.Error
}

# ========================================
# 8. ORDER SERVICE TESTS
# ========================================
Write-Section "8. ORDER SERVICE"

# GET /api/orders
Write-Test "GET /api/orders - Get all orders"
$result = Invoke-ApiRequest -Method GET -Endpoint "/orders"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count orders"
    Add-TestResult "Order" "/orders" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Order" "/orders" "GET" "FAIL" $result.Error
}

# POST /api/orders - Create order
Write-Test "POST /api/orders - Create order"
$newOrder = @{
    schedule_id      = 1
    waste_type       = "plastic"
    estimated_weight = 5.5
    pickup_address   = "Jl. Test Order No. 456"
    latitude         = -6.2088
    longitude        = 106.8456
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/orders" -Body $newOrder
if ($result.Success) {
    $orderId = $result.Data.data.id
    Write-Success "Order created with ID: $orderId"
    Add-TestResult "Order" "/orders" "POST" "PASS" "Created ID: $orderId"
    
    # PUT /api/orders/{id} - Update order
    Write-Test "PUT /api/orders/$orderId - Update order"
    $updateOrder = @{
        estimated_weight = 6.0
        notes            = "Updated weight via API test"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/orders/$orderId" -Body $updateOrder
    if ($result.Success) {
        Write-Success "Order updated successfully"
        Add-TestResult "Order" "/orders/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Order" "/orders/{id}" "PUT" "FAIL" $result.Error
    }
    
    # DELETE /api/orders/{id}
    Write-Test "DELETE /api/orders/$orderId - Delete order"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/orders/$orderId"
    if ($result.Success) {
        Write-Success "Order deleted successfully"
        Add-TestResult "Order" "/orders/{id}" "DELETE" "PASS" "Deleted successfully"
    }
    else {
        Write-Error "Delete failed: $($result.Error)"
        Add-TestResult "Order" "/orders/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Order" "/orders" "POST" "FAIL" $result.Error
}

# ========================================
# 9. NOTIFICATION SERVICE TESTS
# ========================================
Write-Section "9. NOTIFICATION SERVICE"

# GET /api/notifications
Write-Test "GET /api/notifications - Get all notifications"
$result = Invoke-ApiRequest -Method GET -Endpoint "/notifications"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count notifications"
    Add-TestResult "Notification" "/notifications" "GET" "PASS" "Retrieved $count items"
    
    if ($count -gt 0) {
        $notifId = $result.Data.data[0].id
        
        # PUT /api/notifications/{id}/mark-read - Mark single as read
        Write-Test "PUT /api/notifications/$notifId/mark-read - Mark as read"
        $result2 = Invoke-ApiRequest -Method PUT -Endpoint "/notifications/$notifId/mark-read" -Body @{}
        if ($result2.Success) {
            Write-Success "Notification marked as read"
            Add-TestResult "Notification" "/notifications/{id}/mark-read" "PUT" "PASS" "Marked as read"
        }
        else {
            Write-Error "Mark read failed: $($result2.Error)"
            Add-TestResult "Notification" "/notifications/{id}/mark-read" "PUT" "FAIL" $result2.Error
        }
    }
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Notification" "/notifications" "GET" "FAIL" $result.Error
}

# PUT /api/notifications/mark-all-read - Mark all as read
Write-Test "PUT /api/notifications/mark-all-read - Mark all as read"
$result = Invoke-ApiRequest -Method PUT -Endpoint "/notifications/mark-all-read" -Body @{}
if ($result.Success) {
    Write-Success "All notifications marked as read"
    Add-TestResult "Notification" "/notifications/mark-all-read" "PUT" "PASS" "Marked all as read"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Notification" "/notifications/mark-all-read" "PUT" "FAIL" $result.Error
}

# ========================================
# 10. SUBSCRIPTION SERVICE TESTS
# ========================================
Write-Section "10. SUBSCRIPTION SERVICE"

# GET /api/subscriptions
Write-Test "GET /api/subscriptions - Get all subscriptions"
$result = Invoke-ApiRequest -Method GET -Endpoint "/subscriptions"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count subscriptions"
    Add-TestResult "Subscription" "/subscriptions" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Subscription" "/subscriptions" "GET" "FAIL" $result.Error
}

# POST /api/subscriptions - Subscribe
Write-Test "POST /api/subscriptions - Subscribe to plan"
$newSub = @{
    plan          = "premium"
    billing_cycle = "monthly"
    auto_renew    = $true
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/subscriptions" -Body $newSub
if ($result.Success) {
    $subId = $result.Data.data.id
    Write-Success "Subscription created with ID: $subId"
    Add-TestResult "Subscription" "/subscriptions" "POST" "PASS" "Created ID: $subId"
    
    # PUT /api/subscriptions/{id} - Update subscription
    Write-Test "PUT /api/subscriptions/$subId - Update subscription"
    $updateSub = @{
        auto_renew = $false
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/subscriptions/$subId" -Body $updateSub
    if ($result.Success) {
        Write-Success "Subscription updated successfully"
        Add-TestResult "Subscription" "/subscriptions/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Subscription" "/subscriptions/{id}" "PUT" "FAIL" $result.Error
    }
    
    # DELETE /api/subscriptions/{id} - Cancel subscription
    Write-Test "DELETE /api/subscriptions/$subId - Cancel subscription"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/subscriptions/$subId"
    if ($result.Success) {
        Write-Success "Subscription cancelled successfully"
        Add-TestResult "Subscription" "/subscriptions/{id}" "DELETE" "PASS" "Cancelled successfully"
    }
    else {
        Write-Error "Cancel failed: $($result.Error)"
        Add-TestResult "Subscription" "/subscriptions/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Subscription" "/subscriptions" "POST" "FAIL" $result.Error
}

# ========================================
# 11. FEEDBACK SERVICE TESTS
# ========================================
Write-Section "11. FEEDBACK SERVICE"

# GET /api/feedback
Write-Test "GET /api/feedback - Get all feedback"
$result = Invoke-ApiRequest -Method GET -Endpoint "/feedback"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count feedback entries"
    Add-TestResult "Feedback" "/feedback" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Feedback" "/feedback" "GET" "FAIL" $result.Error
}

# POST /api/feedback - Submit feedback
Write-Test "POST /api/feedback - Submit feedback"
$newFeedback = @{
    type     = "suggestion"
    subject  = "API Test Feedback"
    message  = "This is a test feedback from PowerShell API test"
    priority = "medium"
}
$result = Invoke-ApiRequest -Method POST -Endpoint "/feedback" -Body $newFeedback
if ($result.Success) {
    $feedbackId = $result.Data.data.id
    Write-Success "Feedback submitted with ID: $feedbackId"
    Add-TestResult "Feedback" "/feedback" "POST" "PASS" "Created ID: $feedbackId"
    
    # PUT /api/feedback/{id} - Update feedback
    Write-Test "PUT /api/feedback/$feedbackId - Update feedback"
    $updateFeedback = @{
        message = "Updated feedback message from API test"
    }
    $result = Invoke-ApiRequest -Method PUT -Endpoint "/feedback/$feedbackId" -Body $updateFeedback
    if ($result.Success) {
        Write-Success "Feedback updated successfully"
        Add-TestResult "Feedback" "/feedback/{id}" "PUT" "PASS" "Updated successfully"
    }
    else {
        Write-Error "Update failed: $($result.Error)"
        Add-TestResult "Feedback" "/feedback/{id}" "PUT" "FAIL" $result.Error
    }
    
    # DELETE /api/feedback/{id}
    Write-Test "DELETE /api/feedback/$feedbackId - Delete feedback"
    $result = Invoke-ApiRequest -Method DELETE -Endpoint "/feedback/$feedbackId"
    if ($result.Success) {
        Write-Success "Feedback deleted successfully"
        Add-TestResult "Feedback" "/feedback/{id}" "DELETE" "PASS" "Deleted successfully"
    }
    else {
        Write-Error "Delete failed: $($result.Error)"
        Add-TestResult "Feedback" "/feedback/{id}" "DELETE" "FAIL" $result.Error
    }
}
else {
    Write-Error "Create failed: $($result.Error)"
    Add-TestResult "Feedback" "/feedback" "POST" "FAIL" $result.Error
}

# ========================================
# 12. USERS SERVICE TESTS (Admin)
# ========================================
Write-Section "12. USERS SERVICE (Admin)"

# GET /api/users
Write-Test "GET /api/users - Get all users"
$result = Invoke-ApiRequest -Method GET -Endpoint "/users"
if ($result.Success) {
    $count = $result.Data.data.Count
    Write-Success "Retrieved $count users"
    Add-TestResult "Users" "/users" "GET" "PASS" "Retrieved $count items"
}
else {
    Write-Error "Failed: $($result.Error)"
    Add-TestResult "Users" "/users" "GET" "FAIL" $result.Error
}

# ========================================
# FINAL REPORT
# ========================================
Write-Section "TEST SUMMARY REPORT"

Write-Host "`nTest Results by Service:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

$groupedResults = $script:testResults | Group-Object -Property Service
foreach ($group in $groupedResults) {
    $serviceName = $group.Name
    $passed = ($group.Group | Where-Object { $_.Status -eq "PASS" }).Count
    $failed = ($group.Group | Where-Object { $_.Status -eq "FAIL" }).Count
    $total = $group.Count
    
    $color = if ($failed -eq 0) { "Green" } else { "Yellow" }
    Write-Host "`n$serviceName Service: $passed/$total passed" -ForegroundColor $color
    
    foreach ($test in $group.Group) {
        $icon = if ($test.Status -eq "PASS") { "✅" } else { "❌" }
        $color = if ($test.Status -eq "PASS") { "Green" } else { "Red" }
        Write-Host "  $icon $($test.Method) $($test.Endpoint) - $($test.Message)" -ForegroundColor $color
    }
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "OVERALL SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Total Tests: $script:totalTests" -ForegroundColor White
Write-Host "Passed: $script:passedTests" -ForegroundColor Green
Write-Host "Failed: $script:failedTests" -ForegroundColor Red
$passRate = [math]::Round(($script:passedTests / $script:totalTests) * 100, 2)
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } else { "Yellow" })

# Export to JSON
$reportFile = "test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$script:testResults | ConvertTo-Json -Depth 10 | Out-File $reportFile
Write-Host "`nDetailed report saved to: $reportFile" -ForegroundColor Cyan

Write-Host "`n[COMPLETE] Testing Complete!" -ForegroundColor Green
