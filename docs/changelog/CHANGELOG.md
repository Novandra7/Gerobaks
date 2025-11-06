# Changelog

Semua perubahan penting pada proyek Gerobaks untuk periode September 2025 (1 Sept – 23 Sept).

## [1.0.0] - 2025-09-23

> Ringkasan Rilis: Rilis stabil awal untuk ekosistem Mitra mencakup Dashboard interaktif, Manajemen Jadwal terstruktur (ScheduleBloc), Profil Mitra baru, Chat multi-format (teks, gambar, audio, typing indicator), Laporan kinerja dengan chart donat, verifikasi nomor HP (OTP + badge), subscription management, integrasi caching HTTP, dan peningkatan desain & performa UI.

### ✨ Fitur Baru (Added)

- Dashboard Mitra: penambahan widget statistik & kartu pickup awal (`07da6b6`, `d146bfc`).
- Dock Navigation awal untuk struktur navigasi mitra (`d146bfc`).
- Halaman/komponen jadwal pengguna & mitra: create schedule form, filtering, status, ScheduleBloc (`30eaaba`, `f40df6a`, `ae6783c`, `255b866`).
- Fitur taxi call & tampilan saldo (`127df32`).
- Halaman & komponen Dashboard Mitra lanjutan (peningkatan layout) (`c011f86`, `b779026`, `be37d88`, `6da8770`, `b71f828`, `d47103b`, `eac7145`).
- Fitur verifikasi nomor HP (OTP) + badge verifikasi + alur update batch signup (`64f5cbc`, `fd33ab7`, `c56637c`).
- Manajemen subscription user (load, update, sinkronisasi model) (`3d61d22`, `47ca043`).
- Sign-up batch 2 & navigasi lanjutan (`5c678e4`).
- Halaman Profile Mitra + action + versi redesign (`2f8fe92`, `50ab847`, `e35d225`, `179d2f2`, `f9ab95f`).
- Chat Mitra: layanan dasar, kirim teks, gambar, audio/voice, indikasi mengetik (`7812b83`, `3c34fd6`, `9a15cc3`, `6d44790`, `fdf86d8`).
- Halaman Mitra Lokasi (`b2ac591`).
- Halaman Jadwal Mitra baru & perbaikan lanjutan (`4e76b81`, `8ce65e1`).
- Laporan Mitra Page dengan statistik chart (donut) + integrasi library chart (`30ce7f4`).
- Integrasi caching HTTP dengan `dio_cache_interceptor` + file store (`91a31d3`).
- Inisialisasi plugin Android untuk perekaman audio (`97db500`).

### ♻️ Refactor / Peningkatan Struktural

- Penataan ulang manajemen jadwal (model, state, filtering) (`ae6783c`, `255b866`).
- Cleanup & perbaikan kode sign-up batch pages (`fef3eca`, revert `1fdfbe3`).
- Penyesuaian layout dashboard agar responsif (`c011f86`, `be37d88`).
- Refactor audio services (error handling & kompatibilitas Linux) (`6d44790`).
- Penyesuaian style profil dan konsistensi warna hijau (`b4d536b`).
- Perapian tile provider service (minor) (`a05e943`).

### 🛠️ Perbaikan (Fixes)

- Perbaikan path build directory (hindari isu spasi) (`9f93163`).
- Perbaikan local storage & user service untuk mitra (`6ef8ca6`).
- Perbaikan tampilan dashboard (spacing / overflow) (`be37d88`).
- Perbaikan halaman jadwal mitra (kartu + layout) (`8ce65e1`).

### 🗺️ Peta & Tracking

- Alternatif provider map: CartoDB untuk fleksibilitas (eksperimen) (`b237028`, `8b40946`).
- Implementasi konfigurasi map (MapConfig) untuk integrasi API (`b237028`).

### 🧩 Integrasi & Merges

- Beberapa merge antar branch staging / update (sinkronisasi paralel fitur) (`847af9f`, `b24836f`, `385a083`, `8946931`, `55869a0`, `eac7145`, `12f0711`, `413d3cf`, `ef61c54`, `4466903`, `40aff3c`, `2ef7123`, `0a2bda7`).

### 📊 Laporan & Statistik

- Penambahan halaman laporan dengan visualisasi donut chart (jenis sampah) (`30ce7f4`).

### 🔐 Verifikasi & Keamanan Ringan

- OTP & badge verifikasi memperkuat kepercayaan pengguna (`64f5cbc`, `fd33ab7`, `c56637c`).

### 🔉 Komunikasi & Media

- Chat multi-format: teks, gambar, audio, indikasi mengetik (`7812b83`, `3c34fd6`, `9a15cc3`, `6d44790`, `fdf86d8`).

### 📦 Dependensi / Build

- Penambahan library chart (fl_chart) (`30ce7f4`).
- Commit perubahan `pubspec.lock` (sinkronisasi dependency) (`050ee2e`).

### 🧪 Catatan Minor

- Commit "non commit" (`bd7d6ce`) – bisa dihindari ke depan.

### 🔍 Highlight Dampak

- Mitra kini memiliki ekosistem lengkap: Dashboard, Profil matang, Jadwal dinamis, Laporan visual, Chat kaya fitur.
- Fondasi skalabilitas: caching, logging, modular jadwal, subscription lifecycle.
- UX meningkat dengan konsistensi visual & interaksi modern.

### 🚀 Rekomendasi Lanjutan

- Tambahkan test unit untuk jadwal, chat, subscription.
- Upgrade dependency besar secara bertahap (perhatikan kompatibilitas Flutter versi sekarang).
- Tambah analytics untuk pemakaian laporan & chat.
- Pertimbangkan state management terpusat (jika skalasi makin kompleks).

---

_Disusun otomatis dari log commit (1–23 Sept 2025)._
