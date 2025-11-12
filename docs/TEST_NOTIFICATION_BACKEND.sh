#!/bin/bash

# 🧪 Test Script untuk Backend Notification API
# Usage: bash docs/TEST_NOTIFICATION_BACKEND.sh

echo "🧪 Testing Backend Notification API"
echo "===================================="
echo ""

# ⚠️  IMPORTANT: Edit credentials di bawah sebelum run script!
# Configuration
BASE_URL="http://127.0.0.1:8000/api"
EMAIL="user@example.com"  # ⚠️  GANTI dengan email user yang ada di database
PASSWORD="password"       # ⚠️  GANTI dengan password yang benar

echo "⚙️  Configuration:"
echo "   - Base URL: $BASE_URL"
echo "   - Email: $EMAIL"
echo "   - Password: ${PASSWORD:0:3}*** (hidden)"
echo ""
echo "❗ Jika login gagal, edit credentials di file ini (docs/TEST_NOTIFICATION_BACKEND.sh)"
echo ""

echo "1️⃣  Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}")

echo "$LOGIN_RESPONSE" | jq .

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.access_token // .token // empty')

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed! No token received."
  echo "Response: $LOGIN_RESPONSE"
  exit 1
fi

echo "✅ Login successful!"
echo "Token: ${TOKEN:0:50}..."
echo ""

echo "2️⃣  Testing GET /notifications/unread-count..."
UNREAD_RESPONSE=$(curl -s -X GET "$BASE_URL/notifications/unread-count" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$UNREAD_RESPONSE" | jq .
echo ""

echo "3️⃣  Testing GET /notifications..."
NOTIFICATIONS_RESPONSE=$(curl -s -X GET "$BASE_URL/notifications?page=1&per_page=10" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$NOTIFICATIONS_RESPONSE" | jq .
echo ""

echo "4️⃣  Testing GET /notifications with filter is_read=0..."
UNREAD_NOTIFICATIONS=$(curl -s -X GET "$BASE_URL/notifications?is_read=0" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json")

echo "$UNREAD_NOTIFICATIONS" | jq .
echo ""

echo "✅ All tests completed!"
echo ""
echo "📊 Summary:"
echo "==========="
UNREAD_COUNT=$(echo "$UNREAD_RESPONSE" | jq -r '.data.unread_count // 0')
TOTAL_NOTIF=$(echo "$NOTIFICATIONS_RESPONSE" | jq -r '.data.pagination.total // 0')
echo "   - Total notifications: $TOTAL_NOTIF"
echo "   - Unread count: $UNREAD_COUNT"
echo ""

if [ "$TOTAL_NOTIF" -eq 0 ]; then
  echo "⚠️  No notifications found!"
  echo ""
  echo "💡 Create test notification dengan:"
  echo "   php artisan tinker"
  echo ""
  echo "   \App\Models\Notification::create(["
  echo "     'user_id' => 1,"
  echo "     'type' => 'schedule',"
  echo "     'category' => 'waste_pickup',"
  echo "     'title' => 'Test Notification',"
  echo "     'message' => 'This is a test notification',"
  echo "     'priority' => 'high',"
  echo "     'is_read' => 0,"
  echo "     'data' => json_encode(['test' => true]),"
  echo "   ]);"
fi
