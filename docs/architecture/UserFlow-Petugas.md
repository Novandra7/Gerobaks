# UserFlow Petugas

# Alur Pengguna (User Flow) Aplikasi Gerobaks – Petugas

## 1. Start dan Otentikasi

Pada saat aplikasi **Gerobaks** dibuka, pertama kali ditampilkan *Splash Screen* lalu sistem melakukan pemeriksaan autentikasi. Petugas dikonfirmasi apakah sudah login atau belum. Jika sudah terdapat sesi aktif, aplikasi langsung masuk ke **Beranda**. Jika belum, dilanjutkan ke proses **Login/Registrasi**.

- *Splash Screen*: logo Gerobaks dan inisialisasi aplikasi.
- *Cek Otentikasi*: periksa session login.
- [Decision] **Sudah punya akun?**
    - *Ya:* langsung lanjut ke proses **Login**.
    - *Tidak:* lanjut ke proses **Registrasi**.
- Setelah Login/Registrasi berhasil, masuk ke halaman **Beranda** utama.

## 2. Alur Autentikasi (Login & Registrasi)

Pada tahap ini petugas dapat **login** jika sudah terdaftar, atau **registrasi** jika akun baru. Proses ini mencakup validasi kredensial, verifikasi OTP, dan pengumpulan data pendukung.

- [Decision] **Apakah petugas sudah terdaftar?**
    - *Ya:* proses **Login**.
    - *Tidak:* proses **Registrasi**.
- **Login**:
    - Opsi masuk menggunakan *Google Login* atau manual (email/nomor HP + password).
    - Sistem memvalidasi kredensial.
    - Jika valid: lanjut ke **Beranda**. Jika gagal: tampilkan pesan error (misal: "Email/Password salah").
- **Registrasi**:
    - *Form Registrasi*:
        
        ### **Registrasi (Batch - Multi-Step Registration Flow)**
        
        **[Step 1: Data Diri]**
        
        - Input:
            - Nama Lengkap
            - NIK (Nomor Induk Kependudukan)
            - Tempat & Tanggal Lahir
            - Jenis Kelamin
            - Nomor HP aktif
            - Email
            - Pilih Lokasi Mitra (Dropdown wilayah: contoh: Samarinda, Balikpapan, Bontang, dst)
        - Tombol: [Next]
        
        **[Step 2: Verifikasi OTP]**
        
        - Ketika telah berhasil verifikasi OTP maka akan lanjut ke tahap berikutnya
        
        **[Step 3: Upload Dokumen]**
        
        - Upload:
            - SKCK Petugas (wajib)
            - KTP (wajib)
            - Sertifikat Tambahan (opsional)
        - Tombol: [Next]
        
        **[Step 4: Buat Akun Login]**
        
        - Input:
            - Buat Username
            - Buat Password
            - Konfirmasi Password
        - Tombol: [Submit Registrasi]
        
        **[Step 5: Redirect ke Login Page]**
        
        - Notifikasi: "Registrasi berhasil! Silakan login menggunakan akun Anda."
        - Redirect otomatis ke halaman login untuk melakukan login terhadap akun yang telah di regis
    - Penting setelah submit:
        - Jika terdapat kesalahan (OTP gagal, upload SKCK gagal): tampilkan notifikasi error dan minta ulang proses yang gagal.

## 3. Navigasi Utama (Bottom Tabs)

Setelah login, petugas diarahkan ke antarmuka utama dengan **navigasi tab** di bagian bawah layar. Terdapat lima tab utama:

- **Beranda**: ringkasan informasi tugas (penghasilan, jadwal), dan pemberitahuan penting.
- **Pick-Up**: daftar order pengambilan sampah dari pelanggan.
- **Aktivitas**: riwayat semua tugas pengambilan (history).
- **Chat**: komunikasi langsung dengan pelanggan dan dukungan (admin).
- **Profil**: informasi akun petugas dan pengaturan.

Petugas dapat berpindah antar-taberuta berdasarkan tugas yang ingin dilihat. Setiap tab memiliki fungsi spesifik sesuai namanya.

## 4. Beranda (Halaman Utama)

Halaman **Beranda** menampilkan ringkasan utama yang dibutuhkan petugas setiap hari. Informasi penting tersaji secara sekilas untuk membantu petugas melihat tujuan kerjanya.

- Menampilkan **Total Pendapatan** petugas minggu ini atau bulan ini.
- Jadwal pengambilan sampah mendatang (tanggal, waktu, alamat pelanggan).
- Notifikasi singkat jika ada **order baru masuk** dari pelanggan.
- Tombol cepat:
    - **"Lihat Jadwal"** – menuju halaman detail jadwal pengambilan.
    - **"Mulai Pengambilan"** – tombol aktif ketika sudah tiba waktu pengambilan sesuai jadwal. Jika ditekan, langsung menuju order terdepan.
- (Opsional) Indikator status akun (misal: aktif/tidak aktif) atau rating/performance petugas.

**Penggunaan:** Petugas membuka aplikasi dan langsung melihat berapa banyak yang telah dihasilkan serta tugas berikutnya. Beranda menjadi pusat navigasi cepat ke fungsi utama (jadwal atau memulai pickup).

## 5. Pick-Up (Daftar Order)

Tab **Pick-Up** menampilkan semua order pengambilan sampah dari pelanggan(pengguna yang telah berlangganan/Subs Aplikasi Gerobaks) yang menunggu tindakan. Fitur ini mirip daftar tugas harian petugas.

- Terdapat daftar order masuk pelanggan dengan status **Terjadwal**(pelanggan yang telah order menjadi partner petugas dan petugas dijadwalkan untuk mengambil sampah sesuai waktu yang diberikan), **Menunggu** (Berarti petugas akan segera datang ke lokasi pelanggan), dan **Selesai**(Jika petugas telah mengambil sampah harian sesuai jadwal yang di tetapkan).
- Namun juga terdapat daftar order masuk pengguna biasa yang tidak berlangganan dengan status **Order**(order masuk dari pengguna), **Diterima**(Order di terima oleh Petugas), **Menunggu** (Berarti petugas akan segera datang ke lokasi pengguna biasa), dan **Selesai**(Jika petugas telah mengambil sampah harian sesuai jadwal yang di tetapkan).
- Setiap order menampilkan ringkasan: nama pelanggan, alamat, jadwal pengambilan, dan status.
- [Decision] **Terima / Tolak Order Untuk Kasus Pengguna tidak berlangganan**:
    - Petugas dapat memilih untuk **Menerima** atau **Menolak** tiap order yang berstatus Masuk.
    - Jika *Menolak*: order dibatalkan, pengguna menerima notifikasi pembatalan, order hilang dari daftar petugas tersebut.
    - Jika *Menerima*: status order menjadi "Diterima", langkah selanjutnya diarahkan ke navigasi lokasi.
- Untuk Pelanggan akan sudah pasti orderannya tidak akan ditolak oleh petugas karena telah berabayar(Subs) dan sesuai dengan jadwal yang telah di tetapkan
- **Navigasi ke Lokasi**: setelah menerima order, aplikasi menampilkan peta (Google Maps) dengan rute ke rumah pelanggan atau pengguna biasa. Petugas bisa mengklik tombol **Mulai Pengambilan** untuk memulai navigasi dan saat itu juga status menjadi menunggu karena petugas aka datang ke lokasi.
- **Konfirmasi Pengambilan**: ketika petugas tiba di lokasi pelanggan atau pengguna :
    - Tampilkan opsi untuk mengambil foto sampah sebagai bukti (mengakses kamera).
    - Setelah foto diambil, petugas menekan tombol **"Sampah Sudah Diambil"** atau **Konfirmasi Pengambilan** untuk mengakhiri proses order.
    - Status order berubah menjadi **Selesai** dan catatan waktu pengambilan terekam.
- Notifikasi otomatiss: pelanggan mendapat pemberitahuan saat order diterima petugas dan saat pengambilan selesai.

**Penggunaan:** Petugas melihat daftar tugas yang harus diambil sampahnya. Dia dapat memilih order yang diambil, menavigasi ke sana, dan memproses order sesuai alur (foto dan konfirmasi).

## 6. Aktivitas (Riwayat Pengambilan)

Tab **Aktivitas** berisi riwayat semua order yang telah diproses oleh petugas, lengkap dengan detailnya. Ini seperti buku harian tugas pengambilan sampah.

- Daftar kronologis pengambilan (dari terbaru ke terlama).
- Setiap entri menampilkan: tanggal dan waktu pengambilan, alamat pelanggan, status akhir (Selesai atau Gagal).
- **Foto Bukti**: thumbnail foto sampah yang diambil disimpan dan ditampilkan pada tiap order sebagai bukti validasi.
- **Pendapatan Order**: tampilkan jumlah uang/komisi yang diperoleh dari order tersebut.
- Kemungkinan fitur lanjutan: filter berdasarkan tanggal/periode atau status (MVP Fokus: tampilan dasar).
- (Opsional) Detail order dapat diklik untuk melihat informasi lengkap (misal detail pelanggan, catatan khusus order).

**Penggunaan:** Petugas dapat mengecek historis pekerjaannya dan melihat berapa penghasilan yang didapat dari tiap order. Hal ini juga membantu transparansi dan audit tugas.

## 7. Chat

Tab **Chat** menyediakan sarana komunikasi langsung antara petugas dan pelanggan, serta dengan admin/pusat dukungan. Hal ini mirip fitur chat pada aplikasi pengemudi ride-sharing.

- **Chat dengan Pelanggan**: untuk setiap order ada ruang chat khusus. Petugas dan pelanggan dapat berkomunikasi tentang detail pengambilan (konfirmasi lokasi, perubahan jadwal, kendala, dsb.).
- **Chat Support/Admin**: petugas dapat menghubungi admin atau dukungan teknis jika membutuhkan bantuan (misal masalah aplikasi, kesulitan lokasi, dll).
- **Notifikasi Pesan**: jika ada pesan baru baik dari pelanggan ataupun admin, muncul notifikasi/pop-up di aplikasi.
- Tampilkan daftar percakapan diurutkan berdasarkan waktu terakhir, dengan indikator pesan baru.
- Opsi fitur: lampirkan foto atau voice message jika diperlukan (opcional).

**Penggunaan:** Petugas menggunakan fitur chat untuk klarifikasi cepat, pertanyaan, dan koordinasi. Notifikasi pesan memastikan pesan penting tidak terlewat.

## 8. Profil

Tab **Profil** berisi informasi akun petugas dan pengaturan pribadi. Di sinilah petugas dapat mengelola data akunnya.

- **Info Akun**: tampilkan data profil petugas – Nama Lengkap, Nomor HP, Status (aktif/non-aktif), dan wilayah operasi.
- **Statistik Ringkas**: total penghasilan kumulatif (sejak bergabung atau per periode tertentu) dan jumlah pelanggan berlangganan jika ada.
- **Pengaturan Akun**:
    - Ubah **Password** akun.
    - *(Opsional)* Update data pribadi atau foto profil.
    - **Status Akun**: misal tombol untuk offline/online jika fitur ini tersedia.
    - **Logout**: tombol untuk keluar dari aplikasi.
- **Informasi Tambahan**:
    - Tampilkan tipe langganan aktif (jika pelanggan berlangganan layanan, misal tarif prioritas).
    - Bantuan/FAQ: link ke dokumen bantuan atau kontak admin.
- (Opsional) Verifikasi SKCK: status verifikasi dokumen SKCK, jika ada proses validasi manual.

**Penggunaan:** Petugas dapat memastikan profilnya lengkap, mengganti pengaturan keamanan, dan melihat ringkasan karir di satu tempat.

## 9. Notifikasi

Aplikasi menggunakan **notifikasi real-time** untuk memastikan petugas tidak melewatkan informasi penting. Notifikasi dapat berupa push notification dan pop-up di dalam aplikasi.

- **Order Masuk Baru**: notifikasi ketika pelanggan membuat order baru yang sesuai wilayah petugas.
- **Pengingat Jadwal**: alarm atau notifikasi beberapa menit/jam sebelum jadwal pengambilan tiba.
- **Pesan Baru**: notifikasi saat ada chat/komunikasi masuk dari pelanggan atau admin.
- **Perubahan Status Order**: notifikasi jika ada perubahan (misal order dibatalkan oleh pelanggan).
- **Pengumuman Sistem**: (opsional) notifikasi update aplikasi atau info penting dari admin.
- Notifikasi bersifat **terjadwal lokal** untuk reminder (misal reminder 1 jam sebelum jadwal) dan *push* untuk pesan/order real-time.

**Penggunaan:** Notifikasi memastikan petugas selalu update dengan tugas dan komunikasi tanpa harus terus-menerus memeriksa aplikasi secara manual.

## 10. Logout dan Penanganan Error

Selain fungsi utama, alur juga mencakup mekanisme keluar akun dan penanganan kendala teknis untuk UX yang baik.

- **Logout**: petugas dapat logout di halaman Profil. Proses logout menghapus session sehingga saat berikutnya aplikasi kembali ke **Splash** dan minta login.
- **Penanganan Error**:
    - *Koneksi Internet*: jika koneksi internet terputus atau lambat, tampilkan pesan kesalahan dan opsi coba ulang.
    - *Login/OTP Gagal*: jika verifikasi gagal, berikan instruksi yang jelas (misal SMS OTP tidak diterima, opsi kirim ulang OTP).
    - *Upload SKCK/Gagal Input*: error upload dokumen atau simpan data saat registrasi, tampilkan pesan dan minta verifikasi ulang.
    - *Navigasi ke Lokasi*: jika Google Maps tidak dapat diakses, minta kembali koneksi GPS atau internet.
- **Pengelolaan Tugas Gagal**: jika terjadi kegagalan pengambilan (misal tidak menemukan alamat pelanggan), catat status **Gagal** di aktivitas dan notif ke pelanggan.

**Penggunaan:** Sistem memberikan umpan balik saat terjadi kegagalan sehingga petugas dapat mengatasi masalah tersebut (retry, cek jaringan). Logout mudah diakses untuk keamanan akun.
