# 🚛 Gerobaks

<div align="center">

![Gerobaks Logo](assets/img_gerobakss.png)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.13.9-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.3.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Closed%20Source-red.svg)](#-lisensi)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-orange.svg)](https://flutter.dev/)
[![Status](https://img.shields.io/badge/Status-Beta-green.svg)]()

**Solusi Cerdas untuk Pengelolaan Sampah Berkelanjutan**

</div>

---

## 🔴 LISENSI CLOSED SOURCE

> **⚠️ PENTING**: Project ini sepenuhnya dilisensikan kepada **Gerobaks** dan **BUKAN open source**. 
> Semua source code, dokumentasi, dan aset intellectual property adalah milik Gerobaks.

---

## 📚 Dokumentasi Produk

<div align="center">

### 📋 Product Requirements & Specifications

| Dokumen | Deskripsi | Link |
|---------|-----------|------|
| **PRD** | Product Requirement Document - Kebutuhan dan spesifikasi produk lengkap | [📖 Baca PRD](PRD-Gerobaks.md) |
| **PSD** | Product Specification Document - Spesifikasi teknis dan arsitektur sistem | [⚙️ Baca PSD](PSD-Gerobaks.md) |
| **User Flow** | Alur pengguna untuk petugas mitra | [👥 User Flow Petugas](UserFlow-Petugas.md) |

</div>

---

## 📱 Tentang Gerobaks

Gerobaks adalah aplikasi mobile berbasis Flutter yang bertujuan untuk menciptakan lingkungan yang bersih dan berkelanjutan melalui pengelolaan sampah yang efisien. Aplikasi ini dilengkapi dengan teknologi AI terdepan dan sistem subscription yang fleksibel untuk memberikan pengalaman terbaik bagi pengguna.

**Fitur Unggulan:**
- 🤖 **AI-Powered Chat**: Integrasi Google Gemini AI untuk assistant cerdas
- 🔔 **Smart Notifications**: Sistem notifikasi yang disesuaikan dengan preferensi pengguna
- 💎 **Flexible Subscription**: 3 tier membership dengan benefits berbeda
- 🗑️ **Smart Waste Management**: Penjadwalan dan tracking pengambilan sampah
- 📊 **Real-time Analytics**: Dashboard dengan data pengelolaan sampah real-time
- 💰 **Rewards System**: Poin dan hadiah untuk aktivitas ramah lingkungan
- 📝 **Digital History**: Riwayat lengkap aktivitas pengelolaan sampah
- 🗺️ **Area Coverage**: Monitoring wilayah layanan yang komprehensif
- 🔔 **Contextual Alerts**: Notifikasi real-time yang relevan dan personal
- 💳 **Payment Gateway**: Mendukung pembayaran melalui QRIS, e-Wallet (ShopeePay, GoPay, DANA), dan Transfer Bank

## ✨ Fitur Utama

### 🏠 Halaman Utama
- Dashboard informatif dengan data pengelolaan sampah
- Carousel informasi interaktif dengan animasi slide up
- Tampilan saldo poin dan status level pengguna
- Real-time clock dan sistem greeting berdasarkan waktu

### 🤖 AI-Powered Chat Assistant
- **Google Gemini AI Integration**: Chat cerdas dengan AI terbaru (Gemini 2.5-Flash)
- **Contextual Responses**: AI memahami konteks pengelolaan sampah dan daur ulang
- **Multi-language Support**: Dukungan percakapan dalam Bahasa Indonesia dan Inggris
- **Smart Badge System**: Indikator visual status langganan dengan tooltip informatif
- **Subscription-Aware**: Chat experience yang disesuaikan dengan tier langganan pengguna

### 🔔 Enhanced Notification System
- **Smart Notifications**: Notifikasi yang disesuaikan dengan status langganan
- **Daily Pantun**: Pantun harian motivational tentang pengelolaan sampah
- **AI-Generated Content**: Pantun dan konten dibuat menggunakan Gemini AI
- **Multi-Channel Notifications**: Chat, pickup reminders, dan subscription alerts
- **Subscription Reminders**: Notifikasi pintar untuk mendorong upgrade langganan

### 💎 Subscription & Membership System
- **3-Tier Subscription**: Basic (🏠), Premium (⭐), Pro (🏢)
- **Flexible Payment**: Multiple payment methods dengan gateway terintegrasi
- **Optional Signup Flow**: Pengguna dapat skip subscription saat registrasi
- **Visual Status Indicators**: Badge dan warna berbeda untuk setiap tier
- **Non-Subscriber Support**: Pengalaman lengkap dengan reminder upgrade yang friendly

### 🗺️ Tracking
- Pelacakan real-time petugas pengambilan sampah
- Estimasi waktu kedatangan
- Rute pengambilan sampah dengan visualisasi peta
- Fitur full screen untuk tampilan peta yang lebih jelas

### 💰 Sistem Rewards
- Penukaran poin dengan berbagai hadiah menarik
- Peringkat dan level berdasarkan kontribusi pengelolaan sampah
- Riwayat aktivitas dengan tracking poin
- Gamifikasi untuk mendorong partisipasi aktif

### 🔔 Notification Center
- Notifikasi real-time untuk update pickup
- Pengingat jadwal pengambilan sampah
- Notifikasi promosi dan reward baru
- Custom settings untuk preferensi notifikasi

### 📱 User Experience
- **Responsive Design**: Optimized untuk berbagai ukuran layar
- **Dark/Light Mode**: Tema yang dapat disesuaikan
- **Offline Support**: Fitur dasar tetap berfungsi tanpa koneksi internet
- **Fast Performance**: Load time optimized untuk pengalaman yang smooth

## 🛠️ Teknologi

### Frontend
- **Flutter**: Cross-platform development framework
- **Dart**: Programming language
- **Provider/Bloc**: State management
- **Google Maps**: Integrasi peta dan lokasi

### Backend & Cloud
- **Firebase**: Authentication, Firestore, Cloud Functions
- **Google Gemini AI**: AI chat assistant
- **Local Storage**: SQLite untuk data offline
- **Push Notifications**: Firebase Cloud Messaging

### Payment Integration
- **QRIS**: Quick Response Code Indonesian Standard
- **E-Wallet**: ShopeePay, GoPay, DANA
- **Bank Transfer**: Multi-bank support
- **Gateway**: Midtrans payment gateway

## 📱 Screenshots

*(Tambahkan screenshots aplikasi di sini)*

## 🚀 Instalasi dan Setup

### Prerequisites
- Flutter SDK (3.13.9+)
- Dart SDK (3.1.0+)
- Android Studio / VS Code
- Firebase account
- Google Maps API key

### Environment Setup
1. Clone repository (untuk authorized users only)
2. Copy `.env.example` ke `.env`
3. Isi semua environment variables yang diperlukan
4. Run `flutter pub get`
5. Setup Firebase configuration
6. Run aplikasi dengan `flutter run`

### Environment Variables
```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
MIDTRANS_SERVER_KEY=your_midtrans_server_key
```

## 📄 Dokumentasi Development

### Architecture
- **Clean Architecture**: Separation of concerns dengan layer-based structure
- **MVVM Pattern**: Model-View-ViewModel untuk UI logic
- **Repository Pattern**: Data abstraction layer
- **Dependency Injection**: Service locator pattern

### Folder Structure
```
lib/
├── core/                 # Core functionality
├── data/                 # Data layer (repositories, datasources)
├── domain/              # Business logic layer
├── presentation/        # UI layer (pages, widgets)
├── shared/              # Shared resources (themes, constants)
└── main.dart           # App entry point
```

## 🧪 Testing

### Test Coverage
- Unit Tests: Business logic dan utility functions
- Widget Tests: UI components dan interactions
- Integration Tests: End-to-end user flows
- Performance Tests: Load time dan memory usage

### Run Tests
```bash
flutter test                    # Unit dan widget tests
flutter test integration_test/  # Integration tests
flutter test --coverage        # Test dengan coverage report
```

## 📊 Analytics & Monitoring

### Metrics Tracking
- **User Engagement**: DAU, MAU, session duration
- **Feature Usage**: Click-through rates, conversion funnel
- **Performance**: App crashes, load times, error rates
- **Business**: Subscription conversions, revenue tracking

### Monitoring Tools
- Firebase Analytics
- Crashlytics untuk crash reporting
- Performance monitoring
- Custom metrics dashboard

## 🔒 Security & Privacy

### Data Protection
- **Encryption**: Data sensitif dienkripsi end-to-end
- **Privacy Compliance**: Sesuai dengan GDPR dan regulasi lokal
- **Secure Storage**: Biometric authentication untuk data penting
- **API Security**: Rate limiting dan authentication tokens

### User Privacy
- Minimal data collection
- Transparent privacy policy
- User control atas data personal
- Right to delete account dan data

## 🤝 Contributing

> **⚠️ CLOSED SOURCE**: Repository ini bersifat private dan hanya untuk authorized contributors.

### Development Workflow
1. Create feature branch dari `development`
2. Implement feature dengan test coverage
3. Submit pull request dengan detailed description
4. Code review dari senior developers
5. Merge setelah approval dan testing

### Code Standards
- Follow Dart/Flutter style guide
- Minimum 80% test coverage
- Document public APIs
- Use meaningful commit messages

## 📞 Support & Contact

### Development Team
- **Lead Developer**: [Developer Name]
- **UI/UX Designer**: [Designer Name]
- **Product Manager**: [PM Name]

### Business Inquiries
- **Email**: business@gerobaks.com
- **Phone**: +62 XXX XXXX XXXX
- **Website**: https://gerobaks.com

## 📄 Lisensi

**🔴 CLOSED SOURCE LICENSE**

Copyright © 2025 Gerobaks. All rights reserved.

Aplikasi ini dan semua kode sumber, dokumentasi, dan aset terkait adalah properti eksklusif Gerobaks. Dilarang keras untuk:
- Mendistribusikan atau memperbanyak kode sumber
- Melakukan reverse engineering
- Membuat karya turunan
- Menggunakan untuk tujuan komersial tanpa izin tertulis

Untuk pertanyaan lisensi dan kerjasama, hubungi: legal@gerobaks.com

---

<div align="center">

**🌱 Bersama Gerobaks, Mari Ciptakan Lingkungan yang Lebih Bersih dan Berkelanjutan! 🌱**

</div>
