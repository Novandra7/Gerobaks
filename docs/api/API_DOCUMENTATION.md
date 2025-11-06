# Gerobaks API Documentation

Backend Laravel untuk aplikasi Gerobaks dengan API RESTful.

## Kredensial Demo

### End User (Pelanggan)

1. **User Daffa**

   - Email: `daffa@gmail.com`
   - Password: `password123`
   - Role: `end_user`

2. **Jane San**

   - Email: `sansan@gmail.com`
   - Password: `password456`
   - Role: `end_user`

3. **Lionel Wahyu**
   - Email: `wahyuh@gmail.com`
   - Password: `password789`
   - Role: `end_user`

### Mitra (Driver/Petugas)

1. **Ahmad Kurniawan**

   - Email: `driver.jakarta@gerobaks.com`
   - Password: `mitra123`
   - Role: `mitra`

2. **Budi Santoso**

   - Email: `driver.bandung@gerobaks.com`
   - Password: `mitra123`
   - Role: `mitra`

3. **Siti Nurhaliza**
   - Email: `supervisor.surabaya@gerobaks.com`
   - Password: `mitra123`
   - Role: `mitra`

## API Endpoints

### Authentication

- **Register**: `POST /api/register`

  - Body: `name`, `email`, `password`, `role` (opsional, default: `end_user`)
  - Response: User data dan token autentikasi

- **Login**: `POST /api/login`

  - Body: `email`, `password`
  - Response: User data dan token autentikasi

- **User Info**: `GET /api/auth/me`

  - Header: `Authorization: Bearer {token}`
  - Response: Data user yang sedang login

- **Logout**: `POST /api/auth/logout`
  - Header: `Authorization: Bearer {token}`
  - Response: Konfirmasi logout

### Dashboard

- **Dashboard Data**: `GET /api/dashboard`
  - Header: `Authorization: Bearer {token}`
  - Response: Statistik dashboard berdasarkan role pengguna

### Schedule

- **Daftar Jadwal**: `GET /api/schedules`

  - Header: `Authorization: Bearer {token}`
  - Response: Daftar jadwal pengambilan sampah

- **Detail Jadwal**: `GET /api/schedules/{id}`

  - Header: `Authorization: Bearer {token}`
  - Response: Detail jadwal spesifik

- **Buat Jadwal**: `POST /api/schedules`

  - Header: `Authorization: Bearer {token}`
  - Body: Data jadwal baru
  - Response: Jadwal yang berhasil dibuat

- **Update Jadwal**: `PUT /api/schedules/{id}`
  - Header: `Authorization: Bearer {token}`
  - Body: Data jadwal yang diperbarui
  - Response: Jadwal yang berhasil diperbarui

### Tracking

- **Daftar Tracking**: `GET /api/trackings`

  - Header: `Authorization: Bearer {token}`
  - Response: Daftar tracking pengambilan sampah

- **Detail Tracking**: `GET /api/trackings/{id}`

  - Header: `Authorization: Bearer {token}`
  - Response: Detail tracking spesifik

- **Update Tracking**: `PUT /api/trackings/{id}`
  - Header: `Authorization: Bearer {token}`
  - Body: Data tracking yang diperbarui
  - Response: Tracking yang berhasil diperbarui

### Orders

- **Daftar Order**: `GET /api/orders`

  - Header: `Authorization: Bearer {token}`
  - Response: Daftar order pengguna

- **Detail Order**: `GET /api/orders/{id}`

  - Header: `Authorization: Bearer {token}`
  - Response: Detail order spesifik

- **Buat Order**: `POST /api/orders`
  - Header: `Authorization: Bearer {token}`
  - Body: Data order baru
  - Response: Order yang berhasil dibuat

### Payments

- **Daftar Pembayaran**: `GET /api/payments`

  - Header: `Authorization: Bearer {token}`
  - Response: Riwayat pembayaran pengguna

- **Detail Pembayaran**: `GET /api/payments/{id}`

  - Header: `Authorization: Bearer {token}`
  - Response: Detail pembayaran spesifik

- **Buat Pembayaran**: `POST /api/payments`
  - Header: `Authorization: Bearer {token}`
  - Body: Data pembayaran baru
  - Response: Pembayaran yang berhasil dibuat

### Services

- **Daftar Layanan**: `GET /api/services`

  - Response: Daftar layanan yang tersedia

- **Detail Layanan**: `GET /api/services/{id}`
  - Response: Detail layanan spesifik

### Ratings

- **Daftar Rating**: `GET /api/ratings`

  - Header: `Authorization: Bearer {token}`
  - Response: Daftar rating pengguna

- **Buat Rating**: `POST /api/ratings`
  - Header: `Authorization: Bearer {token}`
  - Body: Data rating baru
  - Response: Rating yang berhasil dibuat

### Notifications

- **Daftar Notifikasi**: `GET /api/notifications`

  - Header: `Authorization: Bearer {token}`
  - Response: Daftar notifikasi pengguna

- **Tandai Dibaca**: `PUT /api/notifications/{id}`
  - Header: `Authorization: Bearer {token}`
  - Response: Notifikasi yang berhasil diperbarui

### Chats

- **Daftar Chat**: `GET /api/chats`

  - Header: `Authorization: Bearer {token}`
  - Response: Riwayat chat pengguna

- **Kirim Chat**: `POST /api/chats`
  - Header: `Authorization: Bearer {token}`
  - Body: Pesan chat baru
  - Response: Chat yang berhasil dikirim

### Balance

- **Info Saldo**: `GET /api/balance`

  - Header: `Authorization: Bearer {token}`
  - Response: Info saldo pengguna

- **Riwayat Transaksi**: `GET /api/balance/transactions`
  - Header: `Authorization: Bearer {token}`
  - Response: Riwayat transaksi saldo

## Penggunaan di Aplikasi Flutter

Pada aplikasi Flutter, gunakan `AuthApiService` untuk koneksi ke API. Pastikan URL API dikonfigurasi dengan benar di file `.env`.

Contoh konfigurasi yang benar:

```
API_BASE_URL=http://10.0.2.2:8000
```

Untuk emulator Android, gunakan alamat `10.0.2.2:8000` untuk mengakses localhost server.
