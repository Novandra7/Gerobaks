#!/bin/bash

echo "Testing /api/register endpoint with all parameters..."
echo "=================================================="
echo ""

curl -X POST http://127.0.0.1:8000/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Test User Full",
    "email": "testfull@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "end_user",
    "phone": "081234567890",
    "address": "Jl. Test Lengkap No. 123, Jakarta Selatan",
    "latitude": -6.2088,
    "longitude": 106.8456
  }' | jq .

echo ""
echo "=================================================="
echo "Check database with:"
echo "SELECT id, name, email, phone, address FROM users WHERE email = 'testfull@example.com';"
