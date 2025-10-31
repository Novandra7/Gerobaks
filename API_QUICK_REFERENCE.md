# 📋 Gerobaks API - Quick Reference Card

Quick reference untuk endpoint yang paling sering digunakan.

## 🔗 URLs

| Environment    | Base URL                               | Docs                                    |
| -------------- | -------------------------------------- | --------------------------------------- |
| **Local**      | http://127.0.0.1:8000/api              | http://127.0.0.1:8000                   |
| **Staging**    | https://staging-gerobaks.dumeg.com/api | https://staging-gerobaks.dumeg.com/docs |
| **Production** | https://gerobaks.dumeg.com/api         | https://gerobaks.dumeg.com/docs         |

## 🔐 Authentication

### Register

```http
POST /api/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "08123456789",
  "role": "end_user"
}
```

### Login

```http
POST /api/login
Content-Type: application/json

{
  "email": "daffa@gmail.com",
  "password": "password123"
}

Response:
{
  "token": "33|vPTYQr0DF4ESykfUGg1aly2PKc50273Ex6HH0UC50e894e5d"
}
```

### Get Current User

```http
GET /api/auth/me
Authorization: Bearer {token}
```

### Logout

```http
POST /api/auth/logout
Authorization: Bearer {token}
```

## 📅 Schedules

### Create Schedule (Mobile Format) 🆕

```http
POST /api/schedules/mobile
Authorization: Bearer {token}
Content-Type: application/json

{
  "alamat": "Jl. Merdeka No. 123, Jakarta Pusat",
  "tanggal": "2025-11-01",
  "waktu": "08:00",
  "koordinat": {
    "lat": -6.200000,
    "lng": 106.816667
  },
  "jenis_layanan": "pickup_sampah_organik",
  "catatan": "Tolong ambil di depan rumah",
  "metode_pembayaran": "cash"
}
```

**Jenis Layanan:**

- `pickup_sampah_organik` - Sampah Organik
- `pickup_sampah_anorganik` - Sampah Anorganik
- `pickup_sampah_daur_ulang` - Sampah Daur Ulang
- `pickup_sampah_b3` - Sampah B3
- `pickup_sampah_campuran` - Sampah Campuran

### Get Schedules

```http
GET /api/schedules?status=pending&per_page=20
Authorization: Bearer {token}
```

**Query Parameters:**

- `status`: pending, confirmed, in_progress, completed, cancelled
- `mitra_id`: Filter by mitra
- `user_id`: Filter by user
- `date_from`: YYYY-MM-DD
- `date_to`: YYYY-MM-DD
- `service_type`: Filter by service
- `per_page`: Items per page (default: 20)
- `page`: Page number

### Get Schedule Detail

```http
GET /api/schedules/{id}
Authorization: Bearer {token}
```

### Update Schedule (Mitra/Admin)

```http
PATCH /api/schedules/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "confirmed",
  "mitra_id": 5,
  "price": 15000
}
```

### Complete Schedule

```http
POST /api/schedules/{id}/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "completion_notes": "Berhasil diambil",
  "actual_duration": 25
}
```

### Cancel Schedule

```http
POST /api/schedules/{id}/cancel
Authorization: Bearer {token}
Content-Type: application/json

{
  "cancellation_reason": "Customer request"
}
```

## 📍 Tracking

### Record GPS Point

```http
POST /api/tracking
Authorization: Bearer {token}
Content-Type: application/json

{
  "schedule_id": 45,
  "latitude": -6.200000,
  "longitude": 106.816667,
  "speed": 25.5,
  "bearing": 90.0,
  "accuracy": 10.5
}
```

### Get Tracking Data

```http
GET /api/tracking?schedule_id=45
Authorization: Bearer {token}
```

## 💰 Balance & Payments

### Get Balance

```http
GET /api/balance/summary
Authorization: Bearer {token}

Response:
{
  "current_balance": 50000,
  "total_topup": 100000,
  "total_spent": 50000
}
```

### Top Up

```http
POST /api/balance/topup
Authorization: Bearer {token}
Content-Type: application/json

{
  "amount": 50000,
  "method": "transfer",
  "reference": "TRF123456"
}
```

## ⭐ Ratings

### Submit Rating

```http
POST /api/ratings
Authorization: Bearer {token}
Content-Type: application/json

{
  "schedule_id": 45,
  "mitra_id": 5,
  "rating": 5,
  "comment": "Excellent service!"
}
```

### Get Ratings

```http
GET /api/ratings?mitra_id=5&per_page=10
Authorization: Bearer {token}
```

## 👤 User Management

### Update Profile

```http
POST /api/user/update-profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Doe Updated",
  "phone": "08123456789",
  "address": "Jl. Merdeka No. 123"
}
```

### Change Password

```http
POST /api/user/change-password
Authorization: Bearer {token}
Content-Type: application/json

{
  "current_password": "oldpassword",
  "new_password": "newpassword123",
  "new_password_confirmation": "newpassword123"
}
```

## 🏥 Health Check

### Health

```http
GET /api/health

Response:
{ "status": "ok" }
```

### Ping

```http
GET /api/ping

Response:
{
  "status": "ok",
  "message": "Gerobaks API is running",
  "timestamp": "2025-01-15T12:00:00.000000Z",
  "environment": "production"
}
```

## 👨‍💼 Admin

### Get Statistics

```http
GET /api/admin/stats
Authorization: Bearer {token}

Response:
{
  "total_users": 150,
  "total_mitra": 25,
  "total_schedules": 500,
  "total_revenue": 5000000,
  "active_schedules": 12,
  "pending_payments": 3
}
```

## 🔒 Authorization Header

Semua protected endpoint memerlukan header:

```
Authorization: Bearer 33|vPTYQr0DF4ESykfUGg1aly2PKc50273Ex6HH0UC50e894e5d
```

## 📊 HTTP Status Codes

| Code | Meaning          | Description              |
| ---- | ---------------- | ------------------------ |
| 200  | OK               | Request successful       |
| 201  | Created          | Resource created         |
| 401  | Unauthorized     | Invalid/missing token    |
| 403  | Forbidden        | Insufficient permissions |
| 404  | Not Found        | Resource not found       |
| 422  | Validation Error | Invalid input data       |
| 500  | Server Error     | Internal server error    |

## 🎯 Role-Based Access

| Role         | Can Access                                                                                                                                   |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **end_user** | - POST /api/schedules/mobile<br>- GET /api/schedules (own)<br>- POST /api/ratings<br>- GET /api/balance/summary<br>- POST /api/balance/topup |
| **mitra**    | - GET /api/schedules<br>- POST /api/schedules<br>- PATCH /api/schedules/{id}<br>- POST /api/schedules/{id}/complete<br>- POST /api/tracking  |
| **admin**    | - All endpoints<br>- GET /api/admin/stats                                                                                                    |

## 📝 Test Credentials

### Local Development

```
End User:
  Email: daffa@gmail.com
  Password: password123

Mitra:
  Email: mitra@gerobaks.com
  Password: password123

Admin:
  Email: admin@gerobaks.com
  Password: password123
```

## 🛠️ cURL Examples

### Login

```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "daffa@gmail.com",
    "password": "password123"
  }'
```

### Create Schedule

```bash
curl -X POST http://127.0.0.1:8000/api/schedules/mobile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "alamat": "Jl. Merdeka No. 123",
    "tanggal": "2025-11-01",
    "waktu": "08:00",
    "koordinat": {
      "lat": -6.200000,
      "lng": 106.816667
    },
    "jenis_layanan": "pickup_sampah_organik",
    "metode_pembayaran": "cash"
  }'
```

### Get Schedules

```bash
curl -X GET "http://127.0.0.1:8000/api/schedules?status=pending" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🔗 Documentation Links

- **Swagger UI**: http://127.0.0.1:8000
- **OpenAPI Spec**: http://127.0.0.1:8000/openapi.yaml
- **GitHub**: https://github.com/fk0u/gerobackend

## 📞 Support

**Developer**: [@fk0u](https://github.com/fk0u)  
**Repository**: https://github.com/fk0u/gerobackend

---

**Last Updated**: 2025-01-15  
**API Version**: 1.0.0
