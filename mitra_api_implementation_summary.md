# Implementasi API untuk Role Mitra

## Ringkasan

Dokumen ini merangkum implementasi integrasi API untuk role Mitra (driver/petugas) dalam aplikasi Gerobaks.

## Files yang Diimplementasikan

### Models

1. **Models/order_model.dart** - Model untuk data pesanan
2. **Models/tracking_model.dart** - Model untuk data pelacakan lokasi
3. **Models/activity_model_extension.dart** - Extension untuk model aktivitas
4. **Models/schedule_model_extension.dart** - Extension untuk model jadwal

### Services

1. **Services/mitra_service.dart** - Layanan khusus untuk operasi mitra
2. **Services/api_client_extension.dart** - Extension untuk API client (upload file)
3. **Services/api_service_manager_extension.dart** - Extension untuk API service manager

### UI Pages

1. **UI/Pages/Mitra/Dashboard/mitra_dashboard_content.dart** - Halaman dashboard mitra
2. **UI/Pages/Mitra/Jadwal/jadwal_mitra_api_page.dart** - Halaman jadwal pengambilan
3. **UI/Pages/Mitra/Jadwal/jadwal_detail_page.dart** - Halaman detail jadwal
4. **UI/Pages/Mitra/Tracking/tracking_mitra_page.dart** - Halaman pelacakan lokasi
5. **UI/Pages/Mitra/Aktivitas/aktivitas_mitra_page.dart** - Halaman aktivitas mitra
6. **UI/Pages/Mitra/mitra_navigation_page.dart** - Navigasi utama mitra

### UI Widgets

1. **UI/Widgets/Mitra/schedule_card.dart** - Kartu untuk menampilkan jadwal

### Utils

1. **Utils/api_routes.dart** (update) - Penambahan rute API untuk mitra

## Features yang Diimplementasikan

1. **Dashboard Mitra**

   - Ringkasan data mitra (jumlah pesanan aktif, jumlah pesanan selesai, dll)
   - Status online/offline mitra

2. **Manajemen Jadwal**

   - Daftar jadwal pengambilan
   - Filter jadwal berdasarkan status
   - Detail jadwal
   - Aksi perubahan status jadwal

3. **Pelacakan Lokasi**

   - Submit lokasi saat ini
   - Riwayat lokasi
   - Navigasi ke lokasi pengambilan

4. **Aktivitas & Riwayat**

   - Daftar aktivitas mitra
   - Pengelompokan berdasarkan tanggal
   - Detail aktivitas dengan metadata

5. **Profil Mitra**
   - Informasi profil
   - Update data profil
   - Upload foto profil
   - Manajemen status online/offline

## API Endpoints yang Digunakan

1. `/api/dashboard/mitra/{id}` - Data dashboard mitra
2. `/api/schedules` - Daftar jadwal
3. `/api/schedules/{id}` - Detail jadwal
4. `/api/schedules/{id}/status` - Update status jadwal
5. `/api/trackings` - Riwayat pelacakan dan submit lokasi
6. `/api/activities` - Aktivitas mitra
7. `/api/mitra/{id}/status` - Update status online/offline
8. `/api/user/update-profile` - Update profil
9. `/api/user/upload-profile-image` - Upload foto profil

## Flow Kerja Mitra

1. Login ke aplikasi
2. Set status "Online" untuk menerima penugasan
3. Melihat jadwal pengambilan yang diberikan
4. Mengunjungi lokasi pengambilan
5. Memperbarui status jadwal menjadi "Dalam Proses"
6. Menyelesaikan pengambilan dan memperbarui status menjadi "Selesai"
7. Mengakses riwayat aktivitas untuk melihat catatan pengambilan

## Catatan Tambahan

1. Implementasi mendukung operasi offline, menyimpan data di SharedPreferences
2. Extension methods digunakan untuk memperluas fungsionalitas tanpa memodifikasi kelas asli
3. UI komponen mengikuti desain sistem yang konsisten
4. Penanganan error diimplementasikan di semua level
