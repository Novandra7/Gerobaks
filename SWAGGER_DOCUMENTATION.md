# 📚 Gerobaks API - Swagger Documentation

Documentation yang lengkap dan interaktif untuk Gerobaks API menggunakan OpenAPI 3.0 & Swagger UI.

## 🌐 Akses Dokumentasi

### Production

```
https://gerobaks.dumeg.com
https://gerobaks.dumeg.com/docs
https://gerobaks.dumeg.com/api-docs
```

### Local Development

```
http://127.0.0.1:8000
http://127.0.0.1:8000/docs
http://127.0.0.1:8000/api-docs
```

### OpenAPI Specification

```
http://127.0.0.1:8000/openapi.yaml
https://gerobaks.dumeg.com/openapi.yaml
```

## 🚀 Quick Start

### 1. Start Laravel Server

```bash
cd backend
php artisan serve
```

### 2. Buka Browser

Akses salah satu URL berikut:

- http://127.0.0.1:8000
- http://127.0.0.1:8000/docs
- http://127.0.0.1:8000/api-docs

### 3. Test API

1. **Pilih Environment**: Local / Staging / Production
2. **Login untuk mendapatkan token**:

   - Scroll ke section "Authentication"
   - Expand endpoint `POST /api/login`
   - Klik "Try it out"
   - Masukkan credentials:
     ```json
     {
       "email": "daffa@gmail.com",
       "password": "password123"
     }
     ```
   - Klik "Execute"
   - Copy token dari response

3. **Authorize dengan Token**:

   - Klik tombol "Authorize" di kanan atas
   - Paste token (tanpa kata "Bearer")
   - Klik "Authorize"
   - Klik "Close"

4. **Test Endpoint**:
   - Pilih endpoint yang ingin dicoba
   - Klik "Try it out"
   - Isi parameter yang diperlukan
   - Klik "Execute"

## 📖 Fitur Dokumentasi

### ✅ Interactive API Explorer

- **Try It Out**: Test semua endpoint langsung dari browser
- **Request/Response Examples**: Lihat contoh request & response
- **Schema Validation**: Validasi otomatis untuk request body
- **Authorization**: Bearer token authentication terintegrasi

### 🔐 Authentication System

- **Token Storage**: Token tersimpan di localStorage
- **Auto Authorization**: Token otomatis digunakan untuk semua request
- **Test Login**: Fitur test login langsung dari UI

### 🌍 Multi-Environment Support

- **Local**: Development environment (http://127.0.0.1:8000)
- **Staging**: QA environment (https://staging-gerobaks.dumeg.com)
- **Production**: Live environment (https://gerobaks.dumeg.com)
- **Quick Switch**: Ganti environment dengan 1 klik

### 🎨 Modern UI/UX

- **Dark Mode**: Toggle dark/light mode
- **Responsive**: Mobile-friendly design
- **Syntax Highlighting**: Colored JSON/YAML
- **AOS Animation**: Smooth scrolling animations

## 📋 API Endpoints Coverage

Dokumentasi mencakup **semua** endpoint API:

### 🏥 Health & Monitoring

- `GET /api/health` - Health check
- `GET /api/ping` - Server ping

### 🔐 Authentication

- `POST /api/register` - Register user baru
- `POST /api/login` - Login & get token
- `GET /api/auth/me` - Get user info
- `POST /api/auth/logout` - Logout & revoke token

### 👤 User Management

- `POST /api/user/update-profile` - Update profile
- `POST /api/user/change-password` - Ubah password

### 📅 Schedules

- `GET /api/schedules` - List schedules (with filters)
- `POST /api/schedules` - Create schedule (standard format)
- `POST /api/schedules/mobile` - Create schedule (mobile format) 🆕
- `GET /api/schedules/{id}` - Get schedule detail
- `PATCH /api/schedules/{id}` - Update schedule
- `POST /api/schedules/{id}/complete` - Mark as completed
- `POST /api/schedules/{id}/cancel` - Cancel schedule

### 📍 Tracking

- `GET /api/tracking` - Get GPS tracking data
- `POST /api/tracking` - Record tracking point

### 💰 Balance & Payments

- `GET /api/balance/summary` - Get balance summary
- `POST /api/balance/topup` - Top up balance

### ⭐ Ratings & Reviews

- `GET /api/ratings` - Get ratings
- `POST /api/ratings` - Submit rating

### 👨‍💼 Admin

- `GET /api/admin/stats` - Get statistics

## 🔧 File Structure

```
backend/
├── app/Http/Controllers/
│   └── DocsController.php          # Documentation controller
├── routes/
│   └── web.php                     # Routes untuk dokumentasi
├── resources/views/docs/
│   └── index.blade.php             # Swagger UI view
├── public/
│   └── openapi.yaml                # OpenAPI specification
└── CHANGELOG.md                    # Changelog (shown in docs)
```

## 📝 OpenAPI Specification

File `openapi.yaml` menggunakan **OpenAPI 3.0.3** specification:

### Structure

```yaml
openapi: 3.0.3
info:
  title: Gerobaks API
  version: 1.0.0
  description: API Documentation

servers:
  - url: https://gerobaks.dumeg.com/api
  - url: http://127.0.0.1:8000/api

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer

  schemas:
    User: { ... }
    Schedule: { ... }
    Error: { ... }

paths:
  /login: { ... }
  /schedules: { ... }
  # ... all endpoints
```

## 🎯 Special Features

### Mobile Format Schedule Creation

Endpoint khusus untuk mobile app dengan field dalam bahasa Indonesia:

```json
POST /api/schedules/mobile
{
  "alamat": "Jl. Merdeka No. 123",
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

### Error Handling

Semua endpoint mendokumentasikan error responses:

- **422 Validation Error**: Missing required fields
- **401 Unauthorized**: Invalid/missing token
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found

### Request Examples

Setiap endpoint memiliki contoh request yang bisa langsung dicoba.

## 🔐 Security Documentation

Dokumentasi mencakup security features:

- **AES-256-CBC Encryption**: Data at rest
- **HTTPS**: Data in transit
- **Bearer Token**: API authentication
- **Role-Based Access**: end_user, mitra, admin

## 🛠️ Customization

### Update OpenAPI Spec

Edit file `backend/public/openapi.yaml`:

```yaml
paths:
  /api/new-endpoint:
    post:
      tags:
        - New Feature
      summary: Description
      # ... endpoint definition
```

### Update UI

Edit file `backend/resources/views/docs/index.blade.php`:

- Ubah styling
- Tambahkan sections
- Modify Swagger UI config

### Add Environment

Edit `backend/app/Http/Controllers/DocsController.php`:

```php
$servers = [
    // ... existing servers
    [
        'key' => 'dev',
        'label' => 'Development',
        'url' => 'http://dev.gerobaks.com',
    ],
];
```

## 📊 Changelog Integration

Dokumentasi otomatis menampilkan `CHANGELOG.md` di halaman docs.

Update changelog:

```bash
cd backend
echo "## [1.1.0] - 2025-11-30
### Added
- New endpoint for X
- Feature Y" >> CHANGELOG.md
```

## 🌟 Benefits

### For Developers

✅ **No Postman needed** - Test API langsung dari browser  
✅ **Auto-generated examples** - Copy-paste ready code  
✅ **Schema validation** - Tahu persis field apa yang required  
✅ **Multi-environment** - Switch antara local/staging/production

### For QA Team

✅ **Interactive testing** - Test semua endpoint tanpa coding  
✅ **Clear documentation** - Tahu endpoint mana untuk apa  
✅ **Error examples** - Paham error handling

### For Frontend Team

✅ **API Contract** - Tahu struktur request/response  
✅ **Field types** - Tahu data type untuk setiap field  
✅ **Enum values** - Tahu nilai yang valid untuk enum fields

## 🚨 Troubleshooting

### Dokumentasi tidak muncul

```bash
# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Restart server
php artisan serve
```

### OpenAPI file tidak ditemukan

```bash
# Cek apakah file ada
ls backend/public/openapi.yaml

# Jika tidak ada, pastikan file ada di folder yang benar
```

### Token expired

1. Login ulang di section "Authentication"
2. Copy token baru
3. Click "Authorize" dan paste token
4. Test endpoint lagi

### CORS error

Pastikan backend sudah enable CORS di `config/cors.php`:

```php
'paths' => ['api/*', 'openapi.yaml', 'docs', '/'],
'allowed_origins' => ['*'],
```

## 📦 Export & Share

### Export Collection

Download OpenAPI spec:

```bash
curl http://127.0.0.1:8000/openapi.yaml -o gerobaks-api-spec.yaml
```

### Import ke Postman

1. Buka Postman
2. File → Import
3. Pilih file `openapi.yaml`
4. Collection otomatis ter-generate

### Share Documentation

Share URL dokumentasi:

- **Live**: https://gerobaks.dumeg.com/docs
- **Local**: Share via ngrok/localtunnel

## 🔗 Links

- **GitHub**: https://github.com/fk0u/gerobackend
- **Developer**: [@fk0u](https://github.com/fk0u)
- **Production API**: https://gerobaks.dumeg.com/api
- **Swagger UI**: https://swagger.io/tools/swagger-ui/

## 📄 License

MIT License - See LICENSE file for details

---

**Made with ❤️ by [@fk0u](https://github.com/fk0u)**

🚛 **Gerobaks** - Waste Management System
