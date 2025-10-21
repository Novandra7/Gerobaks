# Gerobaks Multi-Role System

## Overview
Aplikasi Gerobaks sekarang mendukung dua role pengguna:
1. **End User** - Pelanggan yang berlangganan layanan pengambilan sampah
2. **Mitra** - Petugas/driver yang melakukan pengambilan sampah

## Struktur Role

### End User Features
- Berlangganan layanan
- Membuat keluhan
- Tracking pengambilan sampah
- Sistem reward dan poin
- Pembayaran

### Mitra Features
- Dashboard monitoring
- Jadwal pengambilan
- Daftar pengambilan sampah
- Laporan kinerja
- Profil mitra

## Struktur Folder

```
lib/
├── ui/pages/
│   ├── mitra/                    # Pages khusus untuk mitra
│   │   ├── dashboard/           # Dashboard utama mitra
│   │   ├── jadwal/              # Jadwal pengambilan
│   │   ├── pengambilan/         # Daftar dan detail pengambilan
│   │   ├── laporan/             # Laporan kinerja
│   │   └── profile/             # Profil mitra
│   ├── sign_in/                 # Login untuk semua role
│   └── [existing end_user pages]
├── utils/
│   ├── user_data_mock.dart      # Mock data untuk kedua role
│   ├── role_helper.dart         # Helper untuk manajemen role
│   └── navigation_guard.dart    # Guard untuk akses berdasarkan role
```

## Authentication Flow

### Login Process
1. User memasukkan email dan password
2. System validasi dengan `UserDataMock.validateLogin()`
3. Berdasarkan role, user diarahkan ke:
   - End User → `/home`
   - Mitra → `/mitra-dashboard`

### Registration Process
- **End User**: Dapat mendaftar melalui flow sign-up yang ada
- **Mitra**: Tidak ada registrasi (hanya admin yang menambahkan)

## Data Structure

### End User Data
```dart
{
  'id': 'user_001',
  'email': 'user@example.com',
  'password': 'password',
  'name': 'Nama User',
  'role': 'end_user',
  'profile_picture': 'assets/...',
  'phone': '081234567890',
  'address': 'Alamat lengkap',
  'points': 50,
  'subscription_status': 'active',
  'created_at': '2024-01-15',
}
```

### Mitra Data
```dart
{
  'id': 'mitra_001',
  'email': 'driver@gerobaks.com',
  'password': 'password',
  'name': 'Nama Mitra',
  'role': 'mitra',
  'profile_picture': 'assets/...',
  'phone': '081234567890',
  'employee_id': 'DRV-JKT-001',
  'vehicle_type': 'Truck Sampah',
  'vehicle_plate': 'B 1234 ABC',
  'work_area': 'Jakarta Pusat',
  'status': 'active',
  'rating': 4.8,
  'total_collections': 1250,
  'created_at': '2023-06-15',
}
```

## Navigation Routes

### End User Routes
- `/home` - Dashboard end user
- `/subscription-plans` - Paket berlangganan
- `/buatKeluhan` - Buat keluhan
- `/tracking` - Tracking pengambilan
- `/reward` - Halaman reward

### Mitra Routes
- `/mitra-dashboard` - Dashboard mitra
- Semua sub-pages mitra diakses melalui bottom navigation di dashboard

### Shared Routes
- `/sign-in` - Login untuk semua role
- `/sign-up-*` - Registrasi end user

## Security & Access Control

### NavigationGuard
- `checkAccess()` - Validasi akses berdasarkan role
- `getCurrentUser()` - Mendapatkan data user saat ini
- `logout()` - Logout dan redirect ke sign-in

### RoleHelper
- `getDefaultRouteForRole()` - Route default berdasarkan role
- `canPerformAction()` - Validasi action berdasarkan role
- Helper methods untuk manajemen role

## Usage Examples

### Check User Role
```dart
final user = await NavigationGuard.getCurrentUser();
if (user != null && user['role'] == 'mitra') {
  // Logic untuk mitra
}
```

### Protect Route
```dart
@override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: NavigationGuard.checkAccess(
      context: context,
      requiredRole: 'mitra',
    ),
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return MitraPage();
      }
      return Container(); // Will redirect automatically
    },
  );
}
```

### Role-based Navigation
```dart
final route = RoleHelper.getDefaultRouteForRole(userRole);
Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
```

## Testing Accounts

### End Users
- Email: daffa@gmail.com, Password: password123
- Email: sansan@gmail.com, Password: password456
- Email: wahyuh@gmail.com, Password: password789

### Mitra
- Email: driver.jakarta@gerobaks.com, Password: mitra123
- Email: driver.bandung@gerobaks.com, Password: mitra123
- Email: supervisor.surabaya@gerobaks.com, Password: mitra123
