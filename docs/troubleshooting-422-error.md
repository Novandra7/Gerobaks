# Troubleshooting Guide: Error 422 - Invalid Data

## Error yang Terjadi
```
422 The given data was invalid
```

## Root Cause
Error 422 (Unprocessable Entity) terjadi ketika request body yang dikirim tidak sesuai dengan format/validasi yang diharapkan oleh backend API.

## Langkah Troubleshooting

### 1. Periksa Log Response
Setelah implementasi logging terbaru, cek console untuk melihat detail error:

```dart
_logger.e('❌ Validation error (422): ${response.body}');

if (errorData['errors'] != null) {
  final errors = errorData['errors'] as Map<String, dynamic>;
  errors.forEach((field, messages) {
    _logger.e('  - $field: $messages');
  });
}
```

**Output yang Diharapkan:**
```
❌ Validation error (422): {
  "message": "The given data was invalid",
  "errors": {
    "subscription_plan_id": ["Field ini wajib diisi"],
    "payment_method": ["Format tidak valid"]
  }
}
```

### 2. Format Request Body yang Dicoba

**Format 1 (Current):**
```json
{
  "subscription_plan_id": "premium_monthly",
  "payment_method": "gopay",
  "auto_renew": true
}
```

**Format 2 (Alternative - jika backend pakai field name pendek):**
```json
{
  "plan_id": "premium_monthly",
  "payment_method": "gopay",
  "auto_renew": true
}
```

**Format 3 (Alternative - tanpa auto_renew jika optional):**
```json
{
  "subscription_plan_id": "premium_monthly",
  "payment_method": "gopay"
}
```

### 3. Kemungkinan Masalah

#### a. Field Name Tidak Sesuai
Backend mungkin ekspektasi field name yang berbeda:
- `plan_id` instead of `subscription_plan_id`
- `method` instead of `payment_method`
- `payment_method_id` instead of `payment_method`

**Solusi:** Check API documentation atau tanya backend developer.

#### b. Data Type Tidak Sesuai
Backend mungkin ekspektasi:
- Integer untuk plan ID: `1` bukan `"premium_monthly"`
- Boolean dengan format tertentu
- Enum values yang specific

**Solusi:** Pastikan tipe data sesuai spesifikasi API.

#### c. Required Fields Missing
Backend mungkin membutuhkan field tambahan:
- `amount`: Total pembayaran
- `currency`: Mata uang (IDR)
- `user_id`: ID user (mungkin sudah dari token)

**Solusi:** Tambahkan field yang diperlukan.

#### d. Validation Rules
Backend mungkin punya aturan validasi:
- Plan ID harus ada di database
- Payment method harus valid
- Auto renew harus boolean

**Solusi:** Pastikan data yang dikirim valid.

### 4. Cara Debug

#### Step 1: Cek Response Error Detail
```dart
// Di baris 221-234, sudah ada logging detail
_logger.e('❌ Validation error (422): ${response.body}');

if (errorData['errors'] != null) {
  final errors = errorData['errors'] as Map<String, dynamic>;
  errors.forEach((field, messages) {
    _logger.e('  - $field: $messages');
  });
}
```

#### Step 2: Test dengan Postman/Curl
```bash
curl -X POST https://api.gerobaks.com/api/subscriptions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "subscription_plan_id": "premium_monthly",
    "payment_method": "gopay",
    "auto_renew": true
  }'
```

#### Step 3: Bandingkan dengan Dokumentasi API
- Cek Postman collection
- Cek Swagger/OpenAPI docs
- Tanya backend developer

### 5. Solusi Sementara: Gunakan Format Alternatif

Jika format 1 tidak work, coba modifikasi di `subscription_service.dart`:

**Ubah Request Body:**
```dart
// Format current (baris 161-166)
final requestBody = {
  'subscription_plan_id': planId,
  'payment_method': paymentMethodId,
  'auto_renew': true,
};

// Coba format alternatif:
// Option A: Field name pendek
final requestBody = {
  'plan_id': planId,
  'payment_method': paymentMethodId,
  'auto_renew': true,
};

// Option B: Tambahkan field additional
final requestBody = {
  'subscription_plan_id': planId,
  'payment_method': paymentMethodId,
  'auto_renew': true,
  'amount': plan.price, // Tambahkan amount
  'currency': 'IDR',     // Tambahkan currency
};

// Option C: Tanpa auto_renew
final requestBody = {
  'subscription_plan_id': planId,
  'payment_method': paymentMethodId,
};
```

### 6. Dokumentasi Backend yang Diperlukan

Minta backend developer untuk provide:

```yaml
# Expected Request Format
POST /api/subscriptions
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Body:
  subscription_plan_id: string (required) - e.g., "premium_monthly"
  payment_method: string (required) - e.g., "gopay", "dana", "qris"
  auto_renew: boolean (optional, default: true)
  amount: integer (optional) - e.g., 75000
  currency: string (optional, default: "IDR")

Validation Rules:
  - subscription_plan_id must exist in subscription_plans table
  - payment_method must be in: ["qris", "gopay", "dana", "ovo", "shopeepay", "bca", "mandiri", "bni", "ocbc"]
  - auto_renew must be boolean
  - amount must be positive integer if provided
```

### 7. Action Items

**Untuk Developer:**
1. ✅ Check log output untuk melihat detail validation errors
2. ⏳ Bandingkan dengan API documentation
3. ⏳ Test dengan Postman/Curl
4. ⏳ Koordinasi dengan backend developer
5. ⏳ Update request body format sesuai spesifikasi

**Untuk Backend Developer:**
1. Provide API documentation lengkap
2. Clarify required vs optional fields
3. Provide example request/response
4. Explain validation rules

---

## Quick Fix Options

### Option 1: Check Actual API Response (Recommended)
Run the app, trigger payment, dan lihat console log. Cari output:
```
❌ Validation error (422): {...}
  - field_name: [error messages]
```

### Option 2: Ask Backend Developer
Tanya format yang benar untuk request body.

### Option 3: Test Different Formats
Uncomment format alternatif di code dan test satu per satu.

---

## Update After Investigation

**Setelah mengetahui format yang benar, update di sini:**

✅ **Format yang Benar:**
```json
{
  // TODO: Fill after investigation
}
```

✅ **Field yang Required:**
- [ ] subscription_plan_id (atau plan_id?)
- [ ] payment_method (atau method?)
- [ ] auto_renew
- [ ] amount?
- [ ] lainnya?

✅ **Validation Rules:**
- Plan ID format: _____________
- Payment method values: _____________
- Additional constraints: _____________
