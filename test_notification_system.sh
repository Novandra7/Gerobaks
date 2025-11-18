#!/bin/bash

# 🧪 Quick Test Script - Notification System
# This script helps test the notification banner by simulating status changes

echo "🧪 Gerobaks - Notification System Test Script"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration (UPDATE THESE!)
API_URL="http://localhost:8000"  # Your backend URL
USER_TOKEN=""                     # User JWT token
SCHEDULE_ID=""                    # Schedule ID to test

# Check if required vars are set
if [ -z "$USER_TOKEN" ]; then
    echo -e "${RED}❌ ERROR: USER_TOKEN not set${NC}"
    echo "Edit this script and set USER_TOKEN variable"
    exit 1
fi

if [ -z "$SCHEDULE_ID" ]; then
    echo -e "${YELLOW}⚠️  WARNING: SCHEDULE_ID not set${NC}"
    echo "Will try to fetch schedules first..."
    echo ""
fi

# Function to print step
print_step() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
}

# Function to wait
wait_for_polling() {
    echo -e "${YELLOW}⏳ Waiting 35 seconds for Flutter polling to detect change...${NC}"
    echo "   (Polling interval: 30 seconds)"
    echo ""
    for i in {35..1}; do
        echo -ne "   ⏱️  $i seconds remaining...\r"
        sleep 1
    done
    echo ""
    echo -e "${GREEN}✅ Polling should have detected the change!${NC}"
    echo ""
}

# Test 1: Get User Schedules
print_step "TEST 1: Get User Schedules"
echo "📡 Calling: GET $API_URL/api/user/pickup-schedules"
echo ""

RESPONSE=$(curl -s -X GET "$API_URL/api/user/pickup-schedules" \
    -H "Authorization: Bearer $USER_TOKEN" \
    -H "Accept: application/json")

echo "$RESPONSE" | jq '.'

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: jq not installed or invalid JSON response${NC}"
    echo "Raw response:"
    echo "$RESPONSE"
    exit 1
fi

# Check if success
SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
if [ "$SUCCESS" != "true" ]; then
    echo -e "${RED}❌ API Error: Backend returned success=false${NC}"
    exit 1
fi

# Get schedule count
SCHEDULE_COUNT=$(echo "$RESPONSE" | jq '.data | length')
echo ""
echo -e "${GREEN}✅ Found $SCHEDULE_COUNT schedule(s)${NC}"

if [ $SCHEDULE_COUNT -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No schedules found. Create a schedule first via app.${NC}"
    exit 0
fi

# Display first schedule
echo ""
echo "📋 First Schedule Details:"
echo "$RESPONSE" | jq '.data[0] | {
    id, 
    status, 
    schedule_day, 
    pickup_time_start,
    mitra_name,
    updated_at
}'

# If SCHEDULE_ID not set, use first schedule
if [ -z "$SCHEDULE_ID" ]; then
    SCHEDULE_ID=$(echo "$RESPONSE" | jq -r '.data[0].id')
    echo ""
    echo -e "${BLUE}ℹ️  Using Schedule ID: $SCHEDULE_ID${NC}"
fi

CURRENT_STATUS=$(echo "$RESPONSE" | jq -r '.data[0].status')
echo -e "${BLUE}ℹ️  Current Status: $CURRENT_STATUS${NC}"

# Ask user what to test
echo ""
echo "═══════════════════════════════════════════════"
echo "Which status change do you want to test?"
echo "═══════════════════════════════════════════════"
echo ""
echo "1) pending → on_progress      (Mitra Accept)"
echo "2) on_progress → on_the_way   (Mitra On The Way)"
echo "3) on_the_way → arrived       (Mitra Arrived)"
echo "4) arrived → completed        (Pickup Completed)"
echo "5) Cancel schedule"
echo "6) Show all transitions"
echo "0) Exit"
echo ""
read -p "Choose option [0-6]: " OPTION

case $OPTION in
    1)
        print_step "TEST 2: Simulate Mitra Accept"
        echo "📝 Note: This test requires direct database access"
        echo "Run this SQL command in your database:"
        echo ""
        echo -e "${YELLOW}UPDATE pickup_schedules"
        echo "SET status = 'on_progress',"
        echo "    mitra_id = 8,"
        echo "    updated_at = NOW()"
        echo -e "WHERE id = $SCHEDULE_ID AND status = 'pending';${NC}"
        echo ""
        read -p "Press Enter after running the SQL command..."
        
        wait_for_polling
        
        echo -e "${GREEN}Expected Banner:${NC}"
        echo "   🎉 Title: Jadwal Diterima! 🎉"
        echo "   📝 Message: Mitra [name] telah menerima jadwal..."
        echo "   🟢 Color: Green"
        ;;
        
    2)
        print_step "TEST 3: Simulate Mitra On The Way"
        echo "Run this SQL:"
        echo ""
        echo -e "${YELLOW}UPDATE pickup_schedules"
        echo "SET status = 'on_the_way',"
        echo "    updated_at = NOW()"
        echo -e "WHERE id = $SCHEDULE_ID AND status = 'on_progress';${NC}"
        echo ""
        read -p "Press Enter after running the SQL command..."
        
        wait_for_polling
        
        echo -e "${GREEN}Expected Banner:${NC}"
        echo "   🚛 Title: Mitra Dalam Perjalanan 🚛"
        echo "   📝 Message: Mitra sedang menuju ke [address]"
        echo "   🔵 Color: Blue"
        ;;
        
    3)
        print_step "TEST 4: Simulate Mitra Arrived"
        echo "Run this SQL:"
        echo ""
        echo -e "${YELLOW}UPDATE pickup_schedules"
        echo "SET status = 'arrived',"
        echo "    updated_at = NOW()"
        echo -e "WHERE id = $SCHEDULE_ID AND status = 'on_the_way';${NC}"
        echo ""
        read -p "Press Enter after running the SQL command..."
        
        wait_for_polling
        
        echo -e "${GREEN}Expected Banner:${NC}"
        echo "   📍 Title: Mitra Sudah Tiba! 📍"
        echo "   📝 Message: Mitra sudah sampai di lokasi..."
        echo "   🟠 Color: Orange"
        ;;
        
    4)
        print_step "TEST 5: Simulate Pickup Completed"
        echo "Run this SQL:"
        echo ""
        echo -e "${YELLOW}UPDATE pickup_schedules"
        echo "SET status = 'completed',"
        echo "    total_weight_kg = 5.5,"
        echo "    total_points = 55,"
        echo "    updated_at = NOW()"
        echo -e "WHERE id = $SCHEDULE_ID AND status = 'arrived';${NC}"
        echo ""
        read -p "Press Enter after running the SQL command..."
        
        wait_for_polling
        
        echo -e "${GREEN}Expected Banner:${NC}"
        echo "   ✅ Title: Penjemputan Selesai! ✅"
        echo "   📝 Message: Terima kasih telah menggunakan..."
        echo "   📊 Subtitle: 5.5 kg • +55 poin"
        echo "   🟢 Color: Dark Green"
        ;;
        
    5)
        print_step "TEST 6: Simulate Cancel"
        echo "Run this SQL:"
        echo ""
        echo -e "${YELLOW}UPDATE pickup_schedules"
        echo "SET status = 'cancelled',"
        echo "    updated_at = NOW()"
        echo -e "WHERE id = $SCHEDULE_ID;${NC}"
        echo ""
        read -p "Press Enter after running the SQL command..."
        
        wait_for_polling
        
        echo -e "${GREEN}Expected Banner:${NC}"
        echo "   ❌ Title: Jadwal Dibatalkan ❌"
        echo "   📝 Message: Jadwal penjemputan telah dibatalkan"
        echo "   🟠 Color: Orange"
        ;;
        
    6)
        print_step "FULL TEST: All Status Transitions"
        echo "This will simulate the complete lifecycle:"
        echo ""
        echo "pending → on_progress → on_the_way → arrived → completed"
        echo ""
        echo "Make sure Flutter app is running and logged in!"
        echo ""
        read -p "Continue? (y/n): " CONFIRM
        
        if [ "$CONFIRM" != "y" ]; then
            echo "Cancelled."
            exit 0
        fi
        
        # Step 1: on_progress
        echo ""
        echo -e "${BLUE}Step 1/4: pending → on_progress${NC}"
        echo "Run SQL:"
        echo -e "${YELLOW}UPDATE pickup_schedules SET status='on_progress', mitra_id=8, updated_at=NOW() WHERE id=$SCHEDULE_ID;${NC}"
        read -p "Press Enter after SQL..."
        wait_for_polling
        echo -e "${GREEN}Expected: 🎉 Jadwal Diterima banner${NC}"
        
        # Step 2: on_the_way
        echo ""
        echo -e "${BLUE}Step 2/4: on_progress → on_the_way${NC}"
        echo "Run SQL:"
        echo -e "${YELLOW}UPDATE pickup_schedules SET status='on_the_way', updated_at=NOW() WHERE id=$SCHEDULE_ID;${NC}"
        read -p "Press Enter after SQL..."
        wait_for_polling
        echo -e "${GREEN}Expected: 🚛 Mitra Dalam Perjalanan banner${NC}"
        
        # Step 3: arrived
        echo ""
        echo -e "${BLUE}Step 3/4: on_the_way → arrived${NC}"
        echo "Run SQL:"
        echo -e "${YELLOW}UPDATE pickup_schedules SET status='arrived', updated_at=NOW() WHERE id=$SCHEDULE_ID;${NC}"
        read -p "Press Enter after SQL..."
        wait_for_polling
        echo -e "${GREEN}Expected: 📍 Mitra Sudah Tiba banner${NC}"
        
        # Step 4: completed
        echo ""
        echo -e "${BLUE}Step 4/4: arrived → completed${NC}"
        echo "Run SQL:"
        echo -e "${YELLOW}UPDATE pickup_schedules SET status='completed', total_weight_kg=5.5, total_points=55, updated_at=NOW() WHERE id=$SCHEDULE_ID;${NC}"
        read -p "Press Enter after SQL..."
        wait_for_polling
        echo -e "${GREEN}Expected: ✅ Penjemputan Selesai banner${NC}"
        
        echo ""
        echo -e "${GREEN}🎉 Full test completed!${NC}"
        ;;
        
    0)
        echo "Exiting..."
        exit 0
        ;;
        
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════"
echo "📱 Check Flutter App"
echo "═══════════════════════════════════════════════"
echo ""
echo "Check Flutter console for:"
echo "  1. 🔔 [GlobalNotification] Status Change Detected!"
echo "  2. ✅ Showing \"...\" banner..."
echo ""
echo "Check Flutter app UI for:"
echo "  1. Banner animation from top"
echo "  2. Correct title and message"
echo "  3. Auto-dismiss after 5 seconds"
echo ""
echo -e "${GREEN}✅ Test script completed!${NC}"
echo ""
