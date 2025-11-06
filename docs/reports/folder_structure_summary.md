# Struktur Folder Gerobaks - Multi Role System

## Overview
Aplikasi Gerobaks sekarang sudah diorganisir dengan sistem multi-role yang lebih tertata dengan pemisahan folder yang jelas antara **end_user** dan **mitra**.

## Struktur Folder UI Pages

```
lib/ui/pages/
├── end_user/                    # Semua halaman untuk pengguna akhir
│   ├── activity/                # Halaman aktivitas sampah
│   ├── address/                 # Manajemen alamat
│   ├── buat_keluhan/           # Buat keluhan
│   ├── chat/                   # Chat dengan admin/support
│   ├── examples/               # Contoh-contoh
│   ├── home/                   # Dashboard utama end user
│   ├── kordinat_wilayah/       # Koordinat wilayah
│   ├── payment/                # Sistem pembayaran
│   ├── profile/                # Profil pengguna
│   ├── reward/                 # Sistem reward/poin
│   ├── subscription/           # Manajemen langganan
│   ├── tracking/              # Tracking sampah
│   ├── wilayah/               # Data wilayah
│   ├── noftification_page.dart # Halaman notifikasi
│   ├── popupiklan.dart        # Popup iklan
│   ├── tambah_example.dart    # Tambah contoh
│   └── tambah_jadwal_page.dart # Tambah jadwal
│
├── mitra/                      # Semua halaman untuk mitra
│   ├── dashboard/              # Dashboard mitra
│   ├── jadwal/                 # Manajemen jadwal pengambilan
│   ├── laporan/                # Laporan mitra
│   ├── pengambilan/            # Pengambilan sampah
│   └── profile/                # Profil mitra
│
├── sign_in/                    # Halaman login (dipakai bersama)
├── sign_up/                    # Halaman registrasi (hanya end_user)
└── splash_onboard/             # Onboarding & splash
```

## Role System

### End User
- **Akses**: Semua fitur dalam folder `end_user/`
- **Login**: Menggunakan email/username dan password
- **Registrasi**: Bisa mendaftar akun baru
- **Dashboard**: `/home` - HomePage dengan navigasi ke berbagai fitur
- **Fitur Utama**: 
  - Tracking sampah
  - Subscription/langganan
  - Reward system
  - Chat support
  - Payment
  - Profile management

### Mitra
- **Akses**: Semua fitur dalam folder `mitra/`
- **Login**: Menggunakan email/username dan password (data sudah ada di sistem)
- **Registrasi**: Tidak ada - account dibuat oleh admin
- **Dashboard**: `/mitra-dashboard` - MitraDashboardPage dengan bottom navigation
- **Fitur Utama**:
  - Dashboard overview
  - Jadwal pengambilan
  - Kelola pengambilan sampah
  - Laporan
  - Profile management

## Import Statements Update

Semua import statements sudah diupdate untuk mengikuti struktur folder baru:

**Sebelum:**
```dart
import 'package:bank_sha/ui/pages/home/home_page.dart';
import 'package:bank_sha/ui/pages/profile/profile_page.dart';
```

**Sesudah:**
```dart
import 'package:bank_sha/ui/pages/end_user/home/home_page.dart';
import 'package:bank_sha/ui/pages/end_user/profile/profile_page.dart';
```

## Keuntungan Struktur Baru

1. **Pemisahan yang Jelas**: End user dan mitra terpisah secara logical
2. **Maintainability**: Lebih mudah maintain kode untuk masing-masing role
3. **Scalability**: Mudah menambah fitur baru untuk role tertentu
4. **Organization**: Struktur folder yang lebih rapi dan intuitif
5. **Team Development**: Tim bisa fokus pada role tertentu tanpa conflict

## Authentication Flow

```
Login Page → Validasi Role → Redirect berdasarkan role
                        ├── end_user → /home (HomePage)
                        └── mitra → /mitra-dashboard (MitraDashboardPage)
```

## Files yang Diupdate

- `main.dart` - Update semua import paths dan routing
- Semua file dalam `end_user/` - Update internal imports
- `user_data_mock.dart` - Sistem data terpisah untuk kedua role
- Various utility files - Update import paths

Struktur ini memberikan foundation yang solid untuk pengembangan berkelanjutan dengan sistem multi-role yang scalable.
