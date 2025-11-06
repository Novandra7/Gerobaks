# PRD (Product Requirement Document) - Aplikasi Gerobaks

## 📋 Informasi Dokumen
- **Nama Produk**: Gerobaks
- **Versi**: 1.0
- **Tanggal**: 22 Juli 2025
- **Tim Pengembang**: Gerobaks Development Team
- **Status**: Under Development
- **Lisensi**: 🔴 **"Closed Source"** - Project ini sepenuhnya dilisensikan kepada Gerobaks dan bukan open source

---

## 🎯 Executive Summary

**Gerobaks** adalah aplikasi mobile yang menghubungkan masyarakat dengan petugas pengambilan sampah untuk menciptakan sistem pengelolaan sampah yang efisien, terpercaya, dan ramah lingkungan. Aplikasi ini menggunakan teknologi real-time tracking, sistem poin reward, dan manajemen langganan untuk memberikan pengalaman yang seamless bagi semua pengguna.

---

## 🌟 Visi dan Misi

### Visi
Menjadi platform terdepan dalam pengelolaan sampah berkelanjutan yang menghubungkan masyarakat dengan petugas sampah secara efisien dan transparan.

### Misi
1. Menyediakan layanan pengambilan sampah yang mudah diakses dan terpercaya
2. Memberdayakan petugas sampah dengan teknologi modern
3. Mendorong partisipasi masyarakat dalam pengelolaan sampah berkelanjutan
4. Menciptakan ekosistem circular economy melalui sistem reward dan point

---

## 👥 Target Pengguna

### 1. End User (Masyarakat)
- **Demografi**: Usia 18-65 tahun, urban/suburban
- **Karakteristik**: Memiliki smartphone, peduli lingkungan, menginginkan kemudahan
- **Pain Points**: 
  - Kesulitan jadwal pengambilan sampah
  - Tidak ada tracking real-time
  - Tidak ada reward untuk partisipasi

### 2. Petugas (Mitra)
- **Demografi**: Usia 20-60 tahun, area perkotaan
- **Karakteristik**: Memiliki kendaraan, smartphone, pengalaman lapangan
- **Pain Points**:
  - Manajemen jadwal yang rumit
  - Komunikasi terbatas dengan pelanggan
  - Pendapatan tidak stabil

---

## 🎯 Tujuan Produk

### Tujuan Bisnis
1. **Revenue**: Mencapai 10,000 pengguna premium dalam 6 bulan pertama
2. **Market Share**: Menjadi aplikasi #1 pengelolaan sampah di 3 kota besar
3. **Sustainability**: Meningkatkan efisiensi pengambilan sampah hingga 40%

### Tujuan Pengguna
1. **End User**: Kemudahan akses layanan pengambilan sampah dengan reward system
2. **Petugas**: Peningkatan pendapatan dan efisiensi kerja melalui teknologi
3. **Lingkungan**: Pengurangan sampah yang tidak terkelola hingga 30%

---

## ⭐ Fitur Utama

### A. Fitur End User

#### 1. Autentikasi & Onboarding
- **Registrasi Multi-Step**
  - Data pribadi lengkap
  - Verifikasi OTP
  - Pilih alamat dengan GPS
  - Setup profile foto
- **Login Options**
  - Email/Password
  - Google Sign-In
  - Remember Me functionality

#### 2. Beranda (Dashboard)
- **Informasi Utama**
  - Greeting personal dengan nama
  - Status langganan aktif/tidak aktif
  - Saldo poin rewards
  - Quick access menu (8 fitur utama)
- **Features Quick Access**
  - Jadwal Baru
  - Tracking Truk
  - Keluhan/Complaint
  - Reward Center

#### 3. Sistem Langganan
- **Paket Berlangganan**
  - Basic Plan (bulanan)
  - Premium Plan (3 bulan)
  - Family Plan (tahunan)
- **Payment Gateway**
  - Multiple payment methods
  - QRIS integration
  - Bank transfer
  - Auto-renewal options

#### 4. Jadwal & Tracking
- **Buat Jadwal Pengambilan**
  - Pilih tanggal dan waktu
  - Multiple address support
  - Jenis sampah (Organik, Anorganik, B3)
  - Catatan khusus
- **Real-time Tracking**
  - GPS tracking petugas
  - Status updates (Diterima → Ditugaskan → Dalam Perjalanan → Selesai)
  - Estimasi waktu tiba
  - Komunikasi dengan petugas

#### 5. Sistem Reward & Points
- **Earning Points**
  - 15 poin pendaftaran
  - 10-15 poin per pengambilan sampah
  - Bonus poin untuk konsistensi
- **Redeem Rewards**
  - Voucher belanja
  - Pulsa dan data
  - Voucher makanan
  - Merchandise eco-friendly

#### 6. Activity & History
- **Riwayat Lengkap**
  - History pengambilan sampah
  - Detail setiap transaksi
  - Status dan timestamp
  - Filter berdasarkan tanggal/kategori
- **Statistik Personal**
  - Total sampah dikumpulkan
  - Environmental impact
  - Achievement badges

#### 7. Chat & Support
- **Customer Support**
  - Live chat dengan admin
  - FAQ section
  - Ticket system untuk komplain
- **Communication**
  - Chat dengan petugas assigned
  - Notifikasi real-time
  - Voice/image message support

#### 8. Profile & Settings
- **Account Management**
  - Edit profile information
  - Manage saved addresses
  - Subscription management
  - Payment history
- **App Settings**
  - Notification preferences
  - Language settings
  - Privacy controls
  - About & help

### B. Fitur Petugas (Mitra)

#### 1. Autentikasi Petugas
- **Registrasi Khusus**
  - Data pribadi lengkap (NIK, KTP)
  - Upload dokumen SKCK
  - Verifikasi admin manual
  - Setup area operasi
- **Login Security**
  - Two-factor authentication
  - Session management
  - Role-based access

#### 2. Dashboard Petugas
- **Overview Harian**
  - Total pendapatan hari ini/minggu/bulan
  - Jadwal pengambilan
  - Order baru masuk
  - Performance stats (rating, completion rate)
- **Quick Actions**
  - Mulai shift kerja
  - Lihat jadwal hari ini
  - Update status ketersediaan

#### 3. Pick-Up Management
- **Order Queue**
  - Daftar order pelanggan berlangganan (auto-accept)
  - Order pengguna biasa (perlu approval)
  - Priority queue berdasarkan jarak/waktu
- **Order Processing**
  - Terima/Tolak order
  - Navigasi GPS ke lokasi
  - Update status real-time
  - Foto bukti pengambilan
  - Konfirmasi completion

#### 4. Navigasi & Maps
- **GPS Integration**
  - Route optimization
  - Real-time traffic updates
  - Multiple stops planning
  - Offline maps support

#### 5. Activity & Earnings
- **History Management**
  - Riwayat semua pengambilan
  - Detail earnings per order
  - Customer feedback/rating
  - Photo evidence archive
- **Performance Analytics**
  - Daily/weekly/monthly stats
  - Completion rate
  - Customer satisfaction score
  - Revenue tracking

#### 6. Communication
- **Customer Chat**
  - In-app messaging dengan pelanggan
  - Order-specific chat rooms
  - Quick reply templates
- **Admin Support**
  - Support ticket system
  - Emergency contact
  - Policy updates

#### 7. Profile & Settings
- **Account Info**
  - Personal information
  - Vehicle details
  - Work area settings
  - Document management
- **Work Management**
  - Online/offline status
  - Schedule preferences
  - Availability calendar

---

## 🚀 User Journey

### End User Journey

#### Journey 1: First Time User Registration
1. **Download & Open App** → Splash Screen
2. **Onboarding** → Intro slides tentang fitur
3. **Registration** → Multi-step form completion
4. **Verification** → OTP via SMS
5. **Profile Setup** → Upload foto, pilih alamat
6. **Subscription** → Pilih paket atau skip
7. **Success** → Welcome bonus 15 poin
8. **First Use** → Tutorial guided tour

#### Journey 2: Scheduled Pickup (Subscriber)
1. **Login** → Dashboard dengan jadwal otomatis
2. **View Schedule** → Cek jadwal pengambilan berikutnya
3. **Prepare Waste** → Notifikasi reminder
4. **Track Driver** → Real-time GPS tracking
5. **Pickup Complete** → Konfirmasi dan rating
6. **Earn Points** → Poin otomatis ditambahkan

#### Journey 3: On-Demand Pickup (Non-Subscriber)
1. **Create Order** → Pilih tanggal, waktu, alamat
2. **Wait Approval** → Petugas terima/tolak order
3. **Payment** → Bayar per transaksi
4. **Track & Pickup** → Same as subscriber flow
5. **Complete & Rate** → Feedback dan rating

### Petugas Journey

#### Journey 1: Registration & Onboarding
1. **Application** → Form lengkap + dokumen
2. **Document Review** → Admin verifikasi SKCK/KTP
3. **Approval** → Notifikasi persetujuan
4. **Training** → Tutorial dan guideline
5. **First Assignment** → Supervised first pickup
6. **Full Access** → Independent operation

#### Journey 2: Daily Operations
1. **Clock In** → Start shift dengan status online
2. **Review Orders** → Cek jadwal dan order baru
3. **Navigate & Pickup** → GPS ke lokasi pelanggan
4. **Process Orders** → Foto, konfirmasi, update status
5. **Customer Service** → Handle chat dan komplain
6. **Clock Out** → Review earnings dan performance

---

## 💼 Business Model

### Revenue Streams
1. **Subscription Revenue** (Primary)
   - Basic: Rp 50,000/bulan
   - Premium: Rp 130,000/3 bulan
   - Family: Rp 450,000/tahun

2. **Transaction Fee** (Secondary)
   - 15% dari setiap on-demand pickup
   - Service fee untuk non-subscriber

3. **Partnership Revenue** (Future)
   - Commission dari reward partners
   - Sponsored content dalam app
   - Data analytics untuk B2B clients

### Cost Structure
1. **Operational Costs**
   - Petugas commission (70% dari revenue)
   - Server dan cloud infrastructure
   - Customer support team

2. **Technology Costs**
   - Development dan maintenance
   - Third-party API (maps, payment)
   - Security dan compliance

---

## 📊 Success Metrics

### User Acquisition
- **MAU (Monthly Active Users)**: Target 50,000 dalam 12 bulan
- **Retention Rate**: 70% untuk bulan pertama, 40% untuk bulan ketiga
- **Subscription Rate**: 30% dari total users berlangganan

### Operational Metrics
- **Order Completion Rate**: >95%
- **Average Response Time**: <30 menit untuk pickup
- **Customer Satisfaction**: Rating rata-rata >4.5/5

### Business Metrics
- **Monthly Recurring Revenue (MRR)**: Target Rp 1.5 miliar/bulan
- **Customer Acquisition Cost (CAC)**: <Rp 100,000
- **Lifetime Value (LTV)**: >Rp 500,000

---

## 🔒 Technical Requirements

### Security & Privacy
- **Data Encryption**: End-to-end encryption untuk data sensitif
- **GDPR Compliance**: Sesuai regulasi perlindungan data
- **Payment Security**: PCI DSS compliance
- **Access Control**: Role-based permissions

### Performance
- **App Performance**: Load time <3 detik
- **Offline Capability**: Core features available offline
- **Real-time Updates**: <5 detik latency untuk tracking
- **Scalability**: Support hingga 100,000 concurrent users

### Integration
- **Payment Gateways**: Midtrans, Xendit, QRIS
- **Maps & Navigation**: Google Maps API
- **Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics, Mixpanel

---

## 🎯 Go-to-Market Strategy

### Phase 1: MVP Launch (Bulan 1-3)
- **Target**: Soft launch di 1 kota (Samarinda)
- **Users**: 1,000 beta users
- **Features**: Core functionality untuk pickup dan tracking

### Phase 2: Scale Up (Bulan 4-6)
- **Target**: Ekspansi ke 2 kota tambahan
- **Users**: 10,000 active users
- **Features**: Advanced features (rewards, analytics)

### Phase 3: Market Leader (Bulan 7-12)
- **Target**: Dominasi di 5 kota besar
- **Users**: 50,000+ active users
- **Features**: AI optimization, advanced analytics

### Marketing Channels
1. **Digital Marketing**
   - Social media campaigns (Instagram, TikTok)
   - Google Ads dan Facebook Ads
   - Influencer partnerships

2. **Ground Marketing**
   - Partnership dengan komplek perumahan
   - Campus activation programs
   - Community events

3. **Referral Program**
   - User referral bonus (poin + diskon)
   - Petugas recruitment incentive

---

## 🚧 Risks & Mitigation

### Technical Risks
- **Server Downtime**: Multi-region backup servers
- **GPS Accuracy**: Fallback to manual confirmation
- **Payment Failures**: Multiple payment gateway options

### Business Risks
- **Competition**: Strong product differentiation dengan reward system
- **Regulation**: Proactive compliance dengan pemerintah daerah
- **Market Adoption**: Extensive user education dan trial programs

### Operational Risks
- **Petugas Shortage**: Competitive compensation dan benefit package
- **Quality Control**: Regular training dan performance monitoring
- **Customer Complaints**: Responsive customer service dan escalation process

---

## 📅 Timeline & Milestones

### Q3 2025 (Agustus - Oktober)
- ✅ MVP Development completion
- ✅ Beta testing dengan 100 users
- 🎯 Soft launch di Samarinda

### Q4 2025 (November - Desember)
- 🎯 1,000 registered users
- 🎯 50 active petugas
- 🎯 Ekspansi ke Balikpapan

### Q1 2026 (Januari - Maret)
- 🎯 5,000 active users
- 🎯 Launch reward marketplace
- 🎯 Ekspansi ke Bontang

### Q2 2026 (April - Juni)
- 🎯 10,000 active users
- 🎯 Partnership dengan 50+ reward vendors
- 🎯 Advanced analytics dashboard

---

## ✅ Acceptance Criteria

### End User Criteria
1. User dapat registrasi dan verifikasi dalam <5 menit
2. User dapat membuat jadwal pickup dalam <3 langkah
3. User dapat tracking real-time dengan akurasi >90%
4. User dapat redeem reward tanpa masalah
5. Customer support response <2 jam

### Petugas Criteria
1. Petugas dapat menerima order dan navigate dalam <2 menit
2. Order completion flow dapat diselesaikan dalam <5 menit
3. Earnings calculation 100% akurat
4. Communication dengan customer seamless
5. Performance analytics tersedia real-time

### System Criteria
1. App stability >99.5% uptime
2. Data security memenuhi standar industri
3. Payment processing success rate >98%
4. Notification delivery rate >95%
5. Load time <3 detik untuk semua major features

---

## 📞 Stakeholder Contacts

### Product Team
- **Product Manager**: [Product Manager Name]
- **Lead Developer**: [Lead Developer Name]  
- **UI/UX Designer**: [Designer Name]

### Business Team
- **Business Development**: [BD Name]
- **Marketing Lead**: [Marketing Name]
- **Operations Manager**: [Operations Name]

---

## 🔒 Lisensi dan Hak Kekayaan Intelektual

### Status Lisensi
🔴 **"CLOSED SOURCE"** - Aplikasi Gerobaks adalah produk proprietary yang sepenuhnya dimiliki dan dilisensikan kepada Gerobaks.

### Hak Kekayaan Intelektual
- **Copyright**: © 2025 Gerobaks. All rights reserved.
- **Status**: Private dan Confidential
- **Distribusi**: Tidak diperbolehkan mendistribusikan, memodifikasi, atau menggunakan source code tanpa izin tertulis dari Gerobaks
- **Kerahasiaan**: Semua informasi dalam dokumen ini bersifat rahasia dan hanya untuk internal Gerobaks

### Perlindungan Aset
- Source code aplikasi dilindungi hak cipta
- Algoritma dan business logic adalah trade secret Gerobaks  
- Desain UI/UX dan brand identity dilindungi trademark
- Database schema dan API specification bersifat confidential

### Ketentuan Penggunaan
- Akses hanya diberikan kepada authorized personnel
- Tidak diperbolehkan reverse engineering
- Tidak diperbolehkan membuat derivative works
- Semua contribution menjadi property Gerobaks

---

*Dokumen ini akan terus diperbarui seiring dengan perkembangan produk dan feedback dari stakeholders.*
