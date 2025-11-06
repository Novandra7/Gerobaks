# Struktur Proyek Gerobaks

## 📁 Struktur Folder Utama

````
Gerobaks/
├── android/              # Konfigurasi platform Android
├── ios/                  # Konfigurasi platform iOS
├── web/                  # Konfigurasi platform Web
├── windows/              # Konfigurasi platform Windows
├── linux/                # Konfigurasi platform Linux
├── macos/                # Konfigurasi platform macOS
├── lib/                  # Source code Flutter
│   ├── blocs/           # Business Logic Components
│   ├── controllers/     # Controllers
│   ├── models/          # Data models
│   ├── services/        # API & services
│   ├── ui/              # User Interface
│   │   ├── pages/      # Halaman-halaman aplikasi
│   │   └── widgets/    # Komponen UI reusable
│   └── utils/          # Utility functions
├── assets/              # Asset statis (gambar, font, dll)
├── test/                # Unit & widget tests
├── backend/             # Backend Laravel API
├── database/            # File SQL database
├── scripts/             # Script automation
│   ├── batch/          # Script batch (.bat, .sh)
│   └── powershell/     # Script PowerShell (.ps1)
├── docs/                # Dokumentasi lengkap
│   ├── api/            # Dokumentasi API
│   ├── guides/         # Panduan fitur & implementasi
│   ├── implementation/ # Detail implementasi
│   ├── testing/        # Dokumentasi testing
│   ├── fixes/          # Dokumentasi bug fixes
│   └── archive/        # Dokumentasi lama/referensi
├── screenshots/         # Screenshot & log aplikasi
├── test-results/        # Hasil testing
└── temp/                # File temporary

## 📋 File Konfigurasi Penting

- `pubspec.yaml` - Dependency & asset configuration
- `.env` - Environment variables (tidak di-commit ke git)
- `.env.example` - Template environment variables
- `analysis_options.yaml` - Dart analyzer configuration

## 📚 Dokumentasi

Semua dokumentasi telah dipindahkan ke folder `docs/` dengan struktur yang terorganisir:

### API (`docs/api/`)
- API_DOCUMENTATION.md
- API_CREDENTIALS.md
- ENDPOINT_MAPPING_CORRECTIONS.md
- PANDUAN_KONEKSI_API.md

### Guides (`docs/guides/`)
- Panduan fitur-fitur aplikasi
- User flow
- Integrasi payment, maps, dll

### Implementation (`docs/implementation/`)
- Detail implementasi API
- Integrasi mobile dengan backend
- Dokumentasi service integration

### Testing (`docs/testing/`)
- Panduan testing
- Test results analysis
- Verification reports

### Fixes (`docs/fixes/`)
- Dokumentasi bug fixes
- Troubleshooting guides

### Archive (`docs/archive/`)
- Dokumentasi lama
- Changelog
- README backups
- Project completion summaries

## 🚀 Quick Start

1. Install dependencies:
```bash
flutter pub get
````

2. Setup environment:

```bash
cp .env.example .env
# Edit .env dengan konfigurasi Anda
```

3. Jalankan aplikasi:

```bash
flutter run
```

Atau gunakan task yang tersedia di VS Code:

- **Run Flutter App** - Menjalankan aplikasi
- **Backend: Serve** - Menjalankan Laravel backend

## 📝 Catatan

- File backup dan duplikat telah dihapus
- Semua script telah dipindah ke folder `scripts/`
- File SQL telah dipindah ke folder `database/`
- Dokumentasi telah diorganisir di folder `docs/`
- File demo yang tidak digunakan telah dihapus

Untuk informasi lebih lengkap, lihat README.md dan dokumentasi di folder `docs/`.
