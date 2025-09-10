# <img src="assets/img_logo.png" width="30"> Pembaruan Aplikasi Gerobaks

<div align="center">
  <img src="assets/img_gerobakss.png" alt="Logo Gerobaks" width="250">
  <h2>Pembaruan Fitur dan Peningkatan Sistem</h2>
  <p><i>"Solusi Cerdas untuk Pengelolaan Sampah Berkelanjutan"</i></p>
  
  <a href="#1-sistem-multi-role">🔄 Multi-Role</a> •
  <a href="#2-peningkatan-uiux">🎨 UI/UX</a> •
  <a href="#3-perbaikan-sistem-autentikasi">🔐 Autentikasi</a> •
  <a href="#4-sistem-langganan">💎 Langganan</a> •
  <a href="#5-pelacakan-dan-pemetaan">🗺️ Pemetaan</a> •
  <a href="#6-sistem-keluhan">📝 Keluhan</a> •
  <a href="#7-penyimpanan-lokal">💾 Storage</a> •
  <a href="#8-sistem-notifikasi">🔔 Notifikasi</a> •
  <a href="#9-optimasi-performa">⚡ Performa</a>
</div>

---

<details open>
<summary>
  <h2 id="1-sistem-multi-role">1. Sistem Multi-Role <img src="assets/ic_profile.png" width="25"></h2>
</summary>

Aplikasi Gerobaks kini mendukung dua peran pengguna yang berbeda dengan antarmuka dan fitur yang disesuaikan untuk masing-masing kebutuhan.

### 👨‍💼 Untuk End User (Pelanggan)

<table>
  <tr>
    <td width="50%" valign="top">
      <h4><img src="assets/ic_truck.png" width="20"> Sistem Berlangganan Pengambilan Sampah</h4>
      <ul>
        <li>Pilihan 3 tier berlangganan: Basic, Premium, dan Pro</li>
        <li>Perbandingan fitur antar paket yang detail</li>
        <li>Opsi pembayaran bulanan atau tahunan dengan diskon</li>
        <li>Sistem auto-renewal yang bisa dikustomisasi</li>
      </ul>
      <h4><img src="assets/ic_tracking.png" width="20"> Pelacakan Real-time</h4>
      <ul>
        <li>Pantau posisi petugas pengambil sampah secara real-time</li>
        <li>Estimasi waktu kedatangan yang akurat</li>
        <li>Riwayat lengkap pengambilan sampah</li>
        <li>Notifikasi 30 menit sebelum kedatangan petugas</li>
      </ul>
    </td>
    <td width="50%" valign="top">
      <h4><img src="assets/ic_tempat_sampah.png" width="20"> Sistem Keluhan</h4>
      <ul>
        <li>Form keluhan dengan kategori yang terperinci</li>
        <li>Upload hingga 5 foto bukti</li>
        <li>Tracking status keluhan secara real-time</li>
        <li>Fitur rating dan feedback untuk penanganan keluhan</li>
      </ul>
      <h4><img src="assets/ic_reward.png" width="20"> Sistem Reward</h4>
      <ul>
        <li>Poin reward untuk setiap pengambilan sampah</li>
        <li>Bonus poin untuk pemilahan sampah</li>
        <li>Leaderboard komunitas penghasil sampah terendah</li>
        <li>Tukar poin dengan voucher merchant partner</li>
      </ul>
    </td>
  </tr>
</table>

### 🚚 Untuk Mitra (Petugas/Driver)

<table>
  <tr>
    <td width="50%" valign="top">
      <h4><img src="assets/ic_overview.png" width="20"> Dashboard Monitoring</h4>
      <ul>
        <li>Tampilan harian, mingguan, dan bulanan</li>
        <li>Ringkasan pencapaian target pengambilan</li>
        <li>Metrik kinerja dengan visualisasi grafis</li>
        <li>Prediksi volume sampah berdasarkan data historis</li>
      </ul>
      <h4><img src="assets/ic_calender.png" width="20"> Jadwal Pengambilan</h4>
      <ul>
        <li>Jadwal harian dengan rute otomatis terbaik</li>
        <li>Fitur reschedule dengan notifikasi ke pelanggan</li>
        <li>Navigasi turn-by-turn ke lokasi pelanggan</li>
        <li>Estimasi waktu antar lokasi pengambilan</li>
      </ul>
    </td>
    <td width="50%" valign="top">
      <h4><img src="assets/ic_history.png" width="20"> Laporan Kinerja</h4>
      <ul>
        <li>Laporan pengambilan harian dan bulanan</li>
        <li>Metrik jumlah dan jenis sampah yang dikumpulkan</li>
        <li>Efisiensi rute dan waktu pengambilan</li>
        <li>Rating dan feedback dari pelanggan</li>
      </ul>
      <h4><img src="assets/ic_truck_tracking.png" width="20"> Sistem Navigasi</h4>
      <ul>
        <li>Rute optimal dengan mempertimbangkan volume sampah</li>
        <li>Pembaruan rute otomatis saat terjadi pembatalan</li>
        <li>Navigasi offline dengan map yang diunduh sebelumnya</li>
        <li>Fitur pelaporan hambatan jalan dan area sulit dijangkau</li>
      </ul>
    </td>
  </tr>
</table>

### 🔒 Peningkatan Sistem Role-Based

- **Pemisahan UI:** Antarmuka yang berbeda dan dioptimalkan untuk masing-masing peran
- **Navigasi Guard:** Pembatasan akses fitur berdasarkan peran untuk keamanan
- **Role-based Notification:** Notifikasi yang disesuaikan berdasarkan peran pengguna
- **Transisi Peran:** Kemampuan beralih peran (untuk pengguna dengan multi-role)

</details>

---

<details>
<summary>
  <h2 id="2-peningkatan-uiux">2. Peningkatan UI/UX <img src="assets/ic_help.png" width="25"></h2>
</summary>

Aplikasi Gerobaks menghadirkan antarmuka pengguna yang modern, intuitif, dan menyenangkan untuk digunakan dengan berbagai peningkatan komponen UI.

### 🎨 Komponen UI yang Ditingkatkan

<div align="center">
  <table>
    <tr>
      <td align="center"><img src="assets/ic_check.png" width="40"><br><b>Dialog Kustom</b></td>
      <td align="center"><img src="assets/ic_edit_profile.png" width="40"><br><b>Tombol Dinamis</b></td>
      <td align="center"><img src="assets/ic_full_screen.png" width="40"><br><b>AppBar Responsif</b></td>
      <td align="center"><img src="assets/ic_notification.png" width="40"><br><b>Kartu Interaktif</b></td>
    </tr>
    <tr>
      <td>Dialog dengan branding konsisten di seluruh aplikasi</td>
      <td>Tombol dengan icon dan teks yang dapat dikustomisasi</td>
      <td>AppBar dengan adaptasi konten berdasarkan halaman</td>
      <td>Kartu informasi dengan animasi dan interaksi</td>
    </tr>
  </table>
</div>

### 💫 Pengalaman Pengguna

<table>
  <tr>
    <td width="33%" valign="top">
      <h4>Animasi & Transisi</h4>
      <ul>
        <li>Transisi halaman yang halus dengan efek hero</li>
        <li>Animasi loading yang informatif dan menarik</li>
        <li>Efek ripple pada interaksi touch</li>
        <li>Animasi feedback untuk aksi pengguna</li>
      </ul>
    </td>
    <td width="33%" valign="top">
      <h4>Feedback Visual</h4>
      <ul>
        <li>Toast messages dengan ikon yang intuitif</li>
        <li>Pesan error yang jelas dan solusi</li>
        <li>Indikator sukses dengan animasi yang menyenangkan</li>
        <li>Progress indicator untuk proses yang panjang</li>
      </ul>
    </td>
    <td width="33%" valign="top">
      <h4>Aksesibilitas</h4>
      <ul>
        <li>Dukungan mode gelap/terang otomatis</li>
        <li>Kontras warna yang baik untuk keterbacaan</li>
        <li>Ukuran font yang dapat disesuaikan</li>
        <li>Kompatibilitas dengan screen reader</li>
      </ul>
    </td>
  </tr>
</table>

### 📱 Perbaikan Layout & Responsivitas

- **Adaptasi Multi-Layar:** UI yang konsisten dari smartphone kompak hingga tablet
- **Map Picker Ditingkatkan:** Interface pemilihan lokasi yang lebih intuitif tanpa tumpang tindih
- **Indikator Progress:** Visual yang lebih jelas menunjukkan posisi dalam alur multi-langkah
- **Keyboard Handling:** Penyesuaian otomatis layout saat keyboard muncul

<div align="center">
  <img src="assets/img_onboard1.png" height="150">
  <img src="assets/img_onboard2.png" height="150">
  <img src="assets/img_onboard3.png" height="150">
  <p><i>Tampilan onboarding baru dengan ilustrasi yang informatif</i></p>
</div>

</details>

---

<details>
<summary>
  <h2 id="3-perbaikan-sistem-autentikasi">3. Perbaikan Sistem Autentikasi <img src="assets/ic_profile.png" width="25"></h2>
</summary>

Sistem autentikasi yang diperbarui menawarkan pengalaman pendaftaran dan masuk yang lebih cepat, aman, dan nyaman bagi pengguna.

### 📝 Pendaftaran (Sign Up)

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Sebelumnya</b></td>
      <td align="center"><b>Sekarang</b></td>
    </tr>
    <tr>
      <td>
        <ol>
          <li>Input data diri</li>
          <li>Verifikasi OTP</li>
          <li>Create password</li>
          <li>Upload profile picture</li>
        </ol>
      </td>
      <td>
        <ol>
          <li>Input data diri & password</li>
          <li>Upload profile picture (opsional)</li>
          <li>Pilihan subscription</li>
        </ol>
      </td>
    </tr>
  </table>
</div>

#### Peningkatan Proses Pendaftaran:
- ✅ **Alur yang Disederhanakan:** Pengurangan dari 4 langkah menjadi 3 langkah
- ✅ **Tanpa OTP:** Penghapusan verifikasi OTP untuk mempercepat proses
- ✅ **Validasi Real-time:** Umpan balik instan untuk format email, kekuatan password
- ✅ **Profile Picture Opsional:** Kemampuan untuk menambahkan foto profil nanti
- ✅ **Informasi Status:** Progress bar yang jelas menunjukkan tahap pendaftaran

### 🔑 Masuk (Sign In)

<table>
  <tr>
    <td width="60%">
      <h4>Fitur Login yang Ditingkatkan</h4>
      <ul>
        <li><b>Auto-Login:</b> Penyimpanan kredensial yang aman untuk login otomatis</li>
        <li><b>Biometric Login:</b> Dukungan untuk login dengan sidik jari atau Face ID</li>
        <li><b>Multi-Device Login:</b> Kemampuan login di beberapa perangkat</li>
        <li><b>Login Cepat:</b> Opsi "tetap login" untuk akses instan</li>
        <li><b>Reset Password:</b> Proses pemulihan password yang disederhanakan</li>
      </ul>
    </td>
    <td width="40%">
      <div align="center">
        <img src="assets/img_logo_google.png" height="40">
        <p><i>Social Login</i></p>
        <img src="assets/ic_check.png" height="40">
        <p><i>Biometric Authentication</i></p>
      </div>
    </td>
  </tr>
</table>

### 👤 Manajemen Data Pengguna

- **Profile Controller:** Sistem terpusat untuk pengelolaan data pengguna
- **Data Persistence:** Perbaikan penyimpanan dan pengambilan data profil
- **Profile Enrichment:** Kemampuan untuk menambahkan informasi profil tambahan
- **User Preferences:** Penyimpanan preferensi pengguna (notifikasi, bahasa, tema)
- **Sync Mechanism:** Sinkronisasi data profil antar perangkat

<div align="center">
  <img src="assets/ic_profile.png" height="40"> &nbsp;&nbsp;
  <img src="assets/ic_edit_profile.png" height="40"> &nbsp;&nbsp;
  <img src="assets/ic_settings.png" height="40"> &nbsp;&nbsp;
  <img src="assets/ic_notification.png" height="40">
  <p><i>Manajemen profil dan preferensi yang terintegrasi</i></p>
</div>

</details>

---

<details>
<summary>
  <h2 id="4-sistem-langganan">4. Sistem Langganan (Subscription) <img src="assets/ic_wallet.png" width="25"></h2>
</summary>

Sistem langganan yang komprehensif dengan berbagai pilihan paket dan metode pembayaran untuk memenuhi kebutuhan pengguna.

### 💎 Paket Langganan

<div align="center">
  <table>
    <tr>
      <th align="center" width="30%">Basic<br><small>Rp 50.000/bulan</small></th>
      <th align="center" width="30%">Premium<br><small>Rp 100.000/bulan</small></th>
      <th align="center" width="30%">Pro<br><small>Rp 200.000/bulan</small></th>
    </tr>
    <tr>
      <td>
        <ul>
          <li>Pengambilan sampah 2x seminggu</li>
          <li>Pelacakan pengambilan dasar</li>
          <li>Kapasitas sampah 10kg per pengambilan</li>
          <li>Dukungan email</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Pengambilan sampah 3x seminggu</li>
          <li>Pelacakan real-time</li>
          <li>Kapasitas sampah 25kg per pengambilan</li>
          <li>Dukungan 24/7</li>
          <li>Analisis sampah bulanan</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>Pengambilan sampah setiap hari</li>
          <li>Pelacakan real-time + notifikasi</li>
          <li>Kapasitas sampah unlimited</li>
          <li>Dukungan prioritas 24/7</li>
          <li>Analisis sampah real-time</li>
          <li>Pemilahan sampah oleh petugas</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

### 💸 Proses Pembayaran

<table>
  <tr>
    <td width="50%">
      <h4>Metode Pembayaran</h4>
      <div align="center">
        <img src="assets/img_bank_bca.png" height="30">&nbsp;
        <img src="assets/img_bank_mandiri.png" height="30">&nbsp;
        <img src="assets/img_bank_bni.png" height="30">&nbsp;
        <img src="assets/img_bank_ocbc.png" height="30">
      </div>
      <ul>
        <li><b>Kartu Kredit/Debit:</b> Visa, Mastercard, JCB</li>
        <li><b>E-Wallet:</b> GoPay, OVO, DANA, LinkAja</li>
        <li><b>Transfer Bank:</b> Virtual Account semua bank</li>
        <li><b>QRIS:</b> Pembayaran dengan scan kode QR</li>
      </ul>
    </td>
    <td width="50%">
      <h4>Fitur Pembayaran</h4>
      <ul>
        <li><b>Auto-Renew:</b> Perpanjangan otomatis dengan persetujuan</li>
        <li><b>Recurring Billing:</b> Tagihan rutin dengan notifikasi</li>
        <li><b>Invoice Digital:</b> Faktur pembayaran yang dapat diunduh</li>
        <li><b>Diskon:</b> Potongan harga untuk pembayaran tahunan</li>
        <li><b>Promo Code:</b> Dukungan untuk kode voucher/promosi</li>
        <li><b>Refund Policy:</b> Kebijakan pengembalian dana yang jelas</li>
      </ul>
    </td>
  </tr>
</table>

### ⏱️ Manajemen Langganan

<div align="center">
  <img src="assets/img_card3.png" height="180">
  <p><i>Tampilan detail langganan dengan informasi komprehensif</i></p>
</div>

- **Masa Aktif:** Informasi durasi langganan dengan visualisasi timeline
- **Reminder:** Notifikasi H-7, H-3, dan H-1 sebelum berakhir langganan
- **Renewal Options:** Pilihan perpanjangan otomatis atau manual
- **Upgrade/Downgrade:** Perubahan paket dengan perhitungan pro-rata
- **Subscription History:** Riwayat lengkap langganan dan pembayaran
- **Cancellation:** Proses pembatalan langganan yang mudah dengan survei alasan

</details>

---

<details>
<summary>
  <h2 id="5-pelacakan-dan-pemetaan">5. Pelacakan dan Pemetaan <img src="assets/ic_tracking.png" width="25"></h2>
</summary>

Sistem pelacakan dan pemetaan canggih yang memberikan visibilitas penuh terhadap proses pengambilan sampah.

### 🚚 Pelacakan Real-time

<div align="center">
  <table>
    <tr>
      <td width="60%">
        <h4>Fitur Pelacakan</h4>
        <ul>
          <li><b>Live Tracking:</b> Posisi petugas pengambil sampah secara real-time</li>
          <li><b>ETA Akurat:</b> Estimasi waktu kedatangan dengan perhitungan traffic</li>
          <li><b>Status Updates:</b> Pembaruan status pengambilan (dijadwalkan, dalam perjalanan, selesai)</li>
          <li><b>Push Notifications:</b> Notifikasi otomatis saat petugas 10 menit dari lokasi</li>
          <li><b>Riwayat Tracking:</b> Histori lengkap pengambilan dengan detail waktu dan petugas</li>
        </ul>
      </td>
      <td width="40%">
        <div align="center">
          <img src="assets/ic_truck_tracking.png" height="100"><br>
          <img src="assets/ic_tracking_truck.png" height="100">
          <p><i>Visualisasi rute petugas pada peta</i></p>
        </div>
      </td>
    </tr>
  </table>
</div>

### 📍 Pemilihan Lokasi

<table>
  <tr>
    <td width="50%">
      <h4>Map Picker yang Ditingkatkan</h4>
      <ul>
        <li><b>UI Responsif:</b> Tampilan peta yang tidak tumpang tindih dengan kontrol</li>
        <li><b>Pencarian Alamat:</b> Fitur search dengan auto-complete</li>
        <li><b>Custom Pin:</b> Penanda lokasi yang dapat digeser dengan presisi</li>
        <li><b>Zoom Controls:</b> Kontrol zoom intuitif untuk penyesuaian detail peta</li>
        <li><b>Save Favorites:</b> Menyimpan lokasi favorit/sering digunakan</li>
      </ul>
    </td>
    <td width="50%">
      <h4>Fitur Geocoding</h4>
      <ul>
        <li><b>Reverse Geocoding:</b> Konversi koordinat ke alamat yang readable</li>
        <li><b>Address Validation:</b> Validasi dan standardisasi format alamat</li>
        <li><b>Multiple Addresses:</b> Kemampuan menyimpan beberapa alamat per akun</li>
        <li><b>Address Labels:</b> Pemberian label alamat (rumah, kantor, dll)</li>
        <li><b>Location History:</b> Riwayat alamat yang pernah digunakan</li>
      </ul>
    </td>
  </tr>
</table>

### 🗺️ Fitur Peta Lanjutan

- **Rute Optimal:** Visualisasi rute terbaik untuk pengambilan sampah
- **Custom Markers:** Penanda kustom untuk status pengambilan yang berbeda
- **Cluster View:** Pengelompokan marker saat zoom-out untuk tampilan yang lebih bersih
- **Heatmap:** Visualisasi densitas pengambilan sampah di area tertentu
- **Traffic Layer:** Informasi lalu lintas real-time untuk estimasi kedatangan akurat
- **Offline Maps:** Dukungan peta offline untuk area dengan koneksi terbatas

<div align="center">
  <img src="assets/img_truk_otw.png" height="120">
  <p><i>Notifikasi dan status pengambilan yang informatif</i></p>
</div>

</details>

---

<details>
<summary>
  <h2 id="6-sistem-keluhan">6. Sistem Keluhan <img src="assets/ic_trash.png" width="25"></h2>
</summary>

Sistem keluhan komprehensif yang memungkinkan pengguna melaporkan masalah dan menerima solusi dengan cepat.

### 📝 Pembuatan Keluhan

<div align="center">
  <table>
    <tr>
      <th align="center">Kategori Keluhan</th>
      <th align="center">Form Keluhan</th>
      <th align="center">Evidence Upload</th>
    </tr>
    <tr>
      <td valign="top">
        <ul>
          <li>Sampah tidak diambil</li>
          <li>Petugas terlambat</li>
          <li>Petugas tidak ramah</li>
          <li>Sampah berserakan</li>
          <li>Masalah pembayaran</li>
          <li>Bug aplikasi</li>
          <li>Lainnya</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>Dropdown kategori</li>
          <li>Judul keluhan</li>
          <li>Deskripsi detail</li>
          <li>Tingkat urgensi</li>
          <li>Lokasi kejadian</li>
          <li>Tanggal & waktu</li>
          <li>ID Transaksi (optional)</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>Upload hingga 5 foto</li>
          <li>Kamera langsung</li>
          <li>Dari gallery</li>
          <li>Upload video (max 30s)</li>
          <li>Perekaman audio</li>
          <li>Screenshot aplikasi</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

### 📊 Manajemen Keluhan

<table>
  <tr>
    <td width="60%">
      <h4>Status Tracking</h4>
      <ol>
        <li><b>Submitted:</b> Keluhan diterima sistem</li>
        <li><b>Under Review:</b> Tim sedang mempelajari keluhan</li>
        <li><b>In Progress:</b> Solusi sedang dikerjakan</li>
        <li><b>Awaiting Feedback:</b> Menunggu tanggapan pengguna</li>
        <li><b>Resolved:</b> Keluhan telah diselesaikan</li>
        <li><b>Closed:</b> Kasus ditutup dengan feedback pengguna</li>
      </ol>
      <h4>Fitur Komunikasi</h4>
      <ul>
        <li>Chat langsung dengan customer service</li>
        <li>Timeline update dengan timestamp</li>
        <li>Notifikasi perubahan status</li>
        <li>Rating kepuasan penyelesaian</li>
      </ul>
    </td>
    <td width="40%">
      <h4>Tampilan Riwayat Keluhan</h4>
      <div align="center">
        <img src="assets/ic_history.png" height="50"><br>
      </div>
      <ul>
        <li><b>Filter Status:</b> Filter berdasarkan status keluhan</li>
        <li><b>Filter Waktu:</b> Filter berdasarkan rentang waktu</li>
        <li><b>Filter Kategori:</b> Filter berdasarkan jenis keluhan</li>
        <li><b>Sorting:</b> Urutkan berdasarkan waktu, status, urgensi</li>
        <li><b>Search:</b> Pencarian berdasarkan keyword</li>
        <li><b>Export:</b> Unduh laporan keluhan dalam format PDF</li>
      </ul>
    </td>
  </tr>
</table>

### 📈 Dashboard Analisis Keluhan

<div align="center">
  <table>
    <tr>
      <th align="center" width="30%">Untuk End User</th>
      <th align="center" width="30%">Untuk Mitra</th>
      <th align="center" width="30%">Untuk Admin</th>
    </tr>
    <tr>
      <td valign="top">
        <ul>
          <li>Ringkasan keluhan aktif</li>
          <li>Rata-rata waktu penyelesaian</li>
          <li>Status keluhan saat ini</li>
          <li>Rekomendasi tindakan</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>Keluhan terkait layanan</li>
          <li>Performance metrics</li>
          <li>Area peningkatan</li>
          <li>Feedback pelanggan</li>
          <li>Response time stats</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>Heat map area masalah</li>
          <li>Analisis tren keluhan</li>
          <li>Metrik resolusi</li>
          <li>Driver performance</li>
          <li>Customer satisfaction</li>
          <li>Insight AI untuk peningkatan</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

</details>

---

<details>
<summary>
  <h2 id="7-penyimpanan-lokal">7. Penyimpanan Lokal <img src="assets/ic_upload.png" width="25"></h2>
</summary>

Sistem penyimpanan lokal yang ditingkatkan untuk manajemen data yang lebih efisien dan aman.

### 🔍 Peningkatan Sistem Logging

<table>
  <tr>
    <td width="50%">
      <h4>Sebelumnya</h4>
      <pre><code>print("DEBUG: LocalStorage subscription data = $subscriptionData");</code></pre>
      <pre><code>print("📱 [STORAGE] User saved: ${user.name}");</code></pre>
      <pre><code>print("Error parsing user data: $e");</code></pre>
      <pre><code>print("📱 [STORAGE] User logged out but data preserved");</code></pre>
    </td>
    <td width="50%">
      <h4>Sekarang</h4>
      <pre><code>_logger.d("LocalStorage subscription data = $subscriptionData");</code></pre>
      <pre><code>_logger.i("User saved: ${user.name}");</code></pre>
      <pre><code>_logger.e("Error parsing user data: $e");</code></pre>
      <pre><code>_logger.i("User logged out but data preserved");</code></pre>
    </td>
  </tr>
</table>

#### Manfaat Logger:
- ✅ **Level Log yang Berbeda:** debug, info, warning, error, wtf
- ✅ **Formatting Konsisten:** Format output yang seragam dan mudah dibaca
- ✅ **Performance Impact Minimal:** Dampak kinerja yang lebih rendah dibanding print
- ✅ **Production Filtering:** Kemampuan mematikan log tertentu di production
- ✅ **Crash Reporting:** Integrasi dengan sistem pelaporan crash

### 🔐 Manajemen Data Pengguna

<div align="center">
  <table>
    <tr>
      <th align="center">Kategori Data</th>
      <th align="center">Metode Penyimpanan</th>
      <th align="center">Fitur Keamanan</th>
    </tr>
    <tr>
      <td valign="top">
        <ul>
          <li>User Profile</li>
          <li>Authentication Tokens</li>
          <li>Subscription Details</li>
          <li>Payment Information</li>
          <li>Saved Addresses</li>
          <li>App Preferences</li>
          <li>Notification Settings</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>SharedPreferences</li>
          <li>Secure Storage</li>
          <li>SQLite Database</li>
          <li>File Storage</li>
          <li>In-Memory Cache</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>AES-256 Encryption</li>
          <li>Biometric Protection</li>
          <li>Auto Session Timeout</li>
          <li>Data Masking</li>
          <li>Secure Deletion</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

### 📱 Pengelolaan Data Offline-Online

- **Sinkronisasi Otomatis:** Pembaruan data lokal dengan server saat online
- **Conflict Resolution:** Penanganan konflik data saat sinkronisasi
- **Bandwidth Optimization:** Sinkronisasi data dengan penggunaan bandwidth minimal
- **Background Sync:** Pembaruan data di background tanpa mengganggu pengguna
- **Selective Sync:** Kontrol pengguna terhadap jenis data yang disinkronkan

<table>
  <tr>
    <td width="50%">
      <h4>Cache Management</h4>
      <ul>
        <li><b>Smart Caching:</b> Penyimpanan data yang sering diakses</li>
        <li><b>TTL (Time To Live):</b> Masa berlaku data cache</li>
        <li><b>Cache Invalidation:</b> Pembersihan cache yang tidak valid</li>
        <li><b>Size Management:</b> Pembatasan ukuran cache untuk optimasi storage</li>
        <li><b>Prioritized Caching:</b> Prioritas cache berdasarkan kebutuhan user</li>
      </ul>
    </td>
    <td width="50%">
      <h4>Data Cleanup</h4>
      <ul>
        <li><b>Auto Cleanup:</b> Pembersihan otomatis data temporary</li>
        <li><b>Versioning:</b> Penanganan migrasi data antar versi app</li>
        <li><b>Storage Analyzer:</b> Analisis penggunaan penyimpanan</li>
        <li><b>Manual Cleanup:</b> Opsi pengguna untuk membersihkan cache</li>
        <li><b>Orphaned Data:</b> Deteksi dan pembersihan data yang tidak terpakai</li>
      </ul>
    </td>
  </tr>
</table>

</details>

---

<details>
<summary>
  <h2 id="8-sistem-notifikasi">8. Sistem Notifikasi <img src="assets/ic_notification.png" width="25"></h2>
</summary>

Sistem notifikasi yang komprehensif untuk menjaga pengguna selalu terinformasi tentang aktivitas dan status penting.

### 🔔 Notifikasi Push

<div align="center">
  <table>
    <tr>
      <th align="center">Jenis Notifikasi</th>
      <th align="center">Untuk End User</th>
      <th align="center">Untuk Mitra</th>
    </tr>
    <tr>
      <td valign="top">
        <ul>
          <li>Pengingat Pengambilan</li>
          <li>Status Pembayaran</li>
          <li>Update Subscription</li>
          <li>Status Keluhan</li>
          <li>Promosi & Reward</li>
          <li>System Alerts</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>30 menit sebelum pengambilan</li>
          <li>Konfirmasi pembayaran</li>
          <li>7 hari sebelum subscription berakhir</li>
          <li>Update keluhan dari CS</li>
          <li>Promo dan poin reward baru</li>
          <li>Pembaruan aplikasi penting</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li>Jadwal pengambilan baru</li>
          <li>Perubahan jadwal</li>
          <li>Keluhan pelanggan baru</li>
          <li>Target & achievements</li>
          <li>Evaluasi kinerja</li>
          <li>Rute optimal baru</li>
        </ul>
      </td>
    </tr>
  </table>
</div>

### 🎛️ Konfigurasi Notifikasi

<table>
  <tr>
    <td width="50%">
      <h4>Pengaturan Dasar</h4>
      <ul>
        <li><b>Notifikasi On/Off:</b> Toggle utama untuk semua notifikasi</li>
        <li><b>Kategori Toggle:</b> Aktifkan/nonaktifkan per kategori</li>
        <li><b>Quiet Hours:</b> Atur waktu tanpa notifikasi</li>
        <li><b>Priority Settings:</b> Tingkat urgensi notifikasi</li>
        <li><b>Channel Settings:</b> Pemilihan channel (push, email, SMS)</li>
      </ul>
    </td>
    <td width="50%">
      <h4>Pengaturan Lanjutan</h4>
      <ul>
        <li><b>Custom Sounds:</b> Pilihan suara untuk notifikasi berbeda</li>
        <li><b>Grouping:</b> Pengelompokan notifikasi sejenis</li>
        <li><b>Rich Media:</b> Support untuk gambar dan action buttons</li>
        <li><b>Schedule Delivery:</b> Jadwalkan pengiriman notifikasi</li>
        <li><b>Read Status:</b> Pelacakan status dibaca/tidak dibaca</li>
      </ul>
    </td>
  </tr>
</table>

### 🔊 Suara & Haptic Feedback

<div align="center">
  <img src="assets/nf_gerobaks.wav" height="40" style="visibility:hidden"><br>
  <i>File suara notifikasi kustom "nf_gerobaks.wav"</i>
</div>

- **Suara Notifikasi Kustom:** Nada notifikasi branded Gerobaks
- **Volume Control:** Pengaturan volume terpisah dari sistem
- **Custom Sounds per Type:** Suara berbeda berdasarkan jenis notifikasi
- **Vibration Patterns:** Pola getar berbeda untuk tipe notifikasi berbeda
- **Silent Mode:** Opsi mode hanya getar atau tanpa suara sama sekali

### 📬 Notification Center

- **Inbox Unified:** Semua notifikasi dalam satu tampilan terpusat
- **Filtering & Sorting:** Filter berdasarkan jenis, waktu, status
- **Batch Actions:** Mark as read, delete untuk beberapa notifikasi sekaligus
- **Deep Linking:** Navigasi langsung ke halaman terkait dari notifikasi
- **History Retention:** Penyimpanan riwayat notifikasi selama 30 hari

<div align="center">
  <img src="assets/ic_notification.png" height="50">
  <p><i>Antarmuka notification center yang intuitif dan informatif</i></p>
</div>

</details>

---

<details>
<summary>
  <h2 id="9-optimasi-performa">9. Optimasi Performa <img src="assets/ic_settings.png" width="25"></h2>
</summary>

Peningkatan performa aplikasi untuk pengalaman pengguna yang lebih baik dan proses pengembangan yang lebih efisien.

### ⚡ Peningkatan Build System

<table>
  <tr>
    <td width="50%">
      <h4>Perbaikan Konfigurasi Build</h4>
      <pre><code>// Sebelumnya: Path relatif yang bermasalah
val newBuildDir: Directory = rootProject.layout
  .buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)</code></pre>
      <pre><code>// Sekarang: Path absolut yang konsisten
val newBuildDir: Directory = layout.buildDirectory
  .dir("C:/FlutterBuild/Gerobaks_Build/android").get()
rootProject.layout.buildDirectory.value(newBuildDir)</code></pre>
    </td>
    <td width="50%">
      <h4>Manfaat Perubahan</h4>
      <ul>
        <li>Menghindari error path dengan spasi</li>
        <li>Build time lebih konsisten</li>
        <li>Mengurangi error Gradle</li>
        <li>Cache build yang lebih efisien</li>
        <li>Migrasi multi-platform yang lebih mudah</li>
      </ul>
    </td>
  </tr>
</table>

### 🚀 Optimasi Android

- **Gradle Optimization:** Konfigurasi build yang lebih efisien
- **ProGuard Rules:** Minimalisasi dan obfuscation kode
- **Asset Compression:** Kompresi aset gambar dan suara
- **Split APKs:** APK terpisah berdasarkan arsitektur CPU
- **App Bundle:** Penggunaan Android App Bundle untuk distribusi yang lebih efisien

### 📱 Optimasi iOS

- **Size Reduction:** Pengurangan ukuran aplikasi
- **Asset Catalogs:** Optimasi aset untuk berbagai perangkat
- **Bitcode Support:** Kompilasi lebih efisien di App Store
- **Startup Time:** Pengurangan waktu startup aplikasi
- **Memory Management:** Pengelolaan memori yang lebih efisien

### 🧹 Perbaikan Kode

<div align="center">
  <table>
    <tr>
      <th align="center">Aspek</th>
      <th align="center">Sebelum</th>
      <th align="center">Sesudah</th>
    </tr>
    <tr>
      <td align="center">Imports</td>
      <td>Unused imports</td>
      <td>Hanya import yang digunakan</td>
    </tr>
    <tr>
      <td align="center">Logging</td>
      <td>print() statements</td>
      <td>Structured logging dengan Logger</td>
    </tr>
    <tr>
      <td align="center">Penamaan Konstanta</td>
      <td>UPPERCASE_WITH_UNDERSCORES</td>
      <td>lowerCamelCase sesuai Dart style</td>
    </tr>
    <tr>
      <td align="center">Struktur Widget</td>
      <td>Widget besar monolitik</td>
      <td>Extracted widgets yang reusable</td>
    </tr>
    <tr>
      <td align="center">Null Safety</td>
      <td>Null checks manual</td>
      <td>Penggunaan fitur null safety Dart</td>
    </tr>
  </table>
</div>

### 🧪 Pengujian Komprehensif

<table>
  <tr>
    <td width="33%" valign="top">
      <h4>Unit Testing</h4>
      <ul>
        <li>Test untuk business logic</li>
        <li>Service layer testing</li>
        <li>Model testing</li>
        <li>Mocking dependencies</li>
        <li>Coverage reports</li>
      </ul>
    </td>
    <td width="33%" valign="top">
      <h4>UI Testing</h4>
      <ul>
        <li>Widget testing</li>
        <li>Screen navigation testing</li>
        <li>Responsiveness testing</li>
        <li>Accessibility testing</li>
        <li>Integration tests</li>
      </ul>
    </td>
    <td width="33%" valign="top">
      <h4>Performance Testing</h4>
      <ul>
        <li>Startup time measurement</li>
        <li>Frame rate monitoring</li>
        <li>Memory leaks detection</li>
        <li>Battery consumption</li>
        <li>Network performance</li>
      </ul>
    </td>
  </tr>
</table>

</details>

---

<div align="center">
  <h3>🔄 Continuous Improvement</h3>
  <p>Aplikasi Gerobaks terus berkembang dengan fitur baru dan peningkatan berdasarkan feedback pengguna dan mitra.</p>
  <p>Kami berkomitmen untuk menyediakan pengalaman pengguna terbaik dalam mengelola sampah secara berkelanjutan.</p>
  
  <img src="assets/img_gerobaks_trust.png" width="200"><br>
  <p>© 2025 Gerobaks. All Rights Reserved.</p>
  <p><i>"Solusi Cerdas untuk Pengelolaan Sampah Berkelanjutan"</i></p>
</div>
