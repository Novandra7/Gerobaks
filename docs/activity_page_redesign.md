# Redesign Halaman Activity End User

> **Dokumen Analisis & Rencana Implementasi**  
> Tanggal: 31 Maret 2026

---

## 📋 Ringkasan

Dokumen ini berisi analisis dan rencana untuk memperbarui halaman `activity_page_improved.dart` agar sesuai dengan flow lengkap pickup schedule dari sisi **End User**, termasuk fitur **GPS Tracking** mitra.

---

## 🔄 Flow Lengkap Pickup Schedule

Berdasarkan API documentation (GEND-18), berikut adalah **lifecycle lengkap** sebuah jadwal pickup:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           USER JOURNEY                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [1. CREATE]          [2. WAITING]         [3. TRACKING]     [4. DONE]     │
│                                                                             │
│  ┌──────────┐        ┌──────────┐        ┌──────────┐      ┌──────────┐    │
│  │ PENDING  │───────►│ ASSIGNED │───────►│ON_THE_WAY│─────►│ ARRIVED  │    │
│  └──────────┘        └──────────┘        └──────────┘      └──────────┘    │
│       │                   │                   │                  │          │
│       │                   │                   │                  ▼          │
│       │                   │                   │            ┌──────────┐    │
│       │                   │                   │            │COMPLETED │    │
│       │                   │                   │            └──────────┘    │
│       │                   │                   │                  │          │
│       ▼                   ▼                   │                  ▼          │
│  ┌──────────┐        ┌──────────┐            │            ┌──────────┐    │
│  │CANCELLED │        │CANCELLED │            │            │  POINTS  │    │
│  │(by user) │        │(by mitra)│            │            │ EARNED!  │    │
│  └──────────┘        └──────────┘            │            └──────────┘    │
│                                               │                             │
│                                    🛰️ GPS TRACKING                         │
│                                    User dapat melihat                       │
│                                    lokasi mitra real-time                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Analisis Tab yang Diperlukan

### Kondisi Saat Ini (2 Tab)
| Tab | Status yang Ditampilkan |
|-----|------------------------|
| **Aktif** | pending, assigned, on_the_way, arrived |
| **Riwayat** | completed, cancelled |

### Rekomendasi Baru (4 Tab)

Berdasarkan user journey di atas, saya merekomendasikan **4 tab** untuk pengalaman yang lebih fokus:

| Tab | Nama | Status | Deskripsi | Fitur Utama |
|-----|------|--------|-----------|-------------|
| **1** | 📅 **Dijadwalkan** | `pending` | Jadwal yang dibuat user dan menunggu mitra | Edit/Cancel jadwal |
| **2** | 🚀 **Berlangsung** | `assigned`, `on_the_way`, `arrived` | Jadwal yang sedang diproses mitra | **GPS Tracking**, Info mitra, Chat |
| **3** | ✅ **Selesai** | `completed` | Pickup yang sukses | Detail poin, Foto bukti, Rating |
| **4** | ❌ **Dibatalkan** | `cancelled` | Jadwal yang dibatalkan | Alasan pembatalan, Buat ulang |

---

## 🛰️ Fitur GPS Tracking

### Kapan GPS Tracking Aktif?

GPS tracking **hanya aktif** pada status:
- `on_the_way` - Mitra sedang dalam perjalanan menuju lokasi user
- `arrived` - Mitra sudah tiba (opsional, untuk konfirmasi lokasi)

### Data yang Diperlukan dari Backend

```json
{
  "mitra_location": {
    "latitude": -6.2088,
    "longitude": 106.8456,
    "updated_at": "2026-03-31T10:15:30Z",
    "heading": 45.5,
    "speed": 25.3
  },
  "eta_minutes": 12,
  "distance_km": 3.5,
  "route_polyline": "encoded_polyline_string"
}
```

### Implementasi GPS Tracking

```dart
// Komponen yang dibutuhkan:
// 1. FlutterMap widget dengan OpenStreetMap tiles
// 2. MarkerLayer untuk lokasi user dan mitra
// 3. PolylineLayer untuk rute perjalanan
// 4. Stream/WebSocket untuk update real-time lokasi mitra
// 5. Bottom sheet info dengan ETA, jarak, info mitra
```

**Referensi Implementasi Existing:**
- `lib/ui/pages/end_user/tracking/tracking_content.dart` - Contoh FlutterMap basic
- `lib/ui/pages/user/tracking/user_mitra_tracking_osm_page.dart` - Tracking dengan OSM (BEST REFERENCE!)
- `lib/ui/pages/mitra/tracking/tracking_mitra_page.dart` - Tracking dari sisi mitra

**Contoh Kode GPS Tracking dengan OpenStreetMap:**

```dart
// Berdasarkan user_mitra_tracking_osm_page.dart

// 1. Setup FlutterMap dengan OpenStreetMap
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: LatLng(-6.200000, 106.816666),
    initialZoom: 15,
    minZoom: 5,
    maxZoom: 18,
  ),
  children: [
    // Tile Layer OSM
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.gerobaks',
      maxZoom: 19,
    ),
    
    // Polyline untuk rute
    PolylineLayer(
      polylines: [
        Polyline(
          points: [mitraLocation, userLocation],
          color: Colors.blue,
          strokeWidth: 4,
          borderColor: Colors.blue.shade200,
          borderStrokeWidth: 2,
        ),
      ],
    ),
    
    // Marker untuk user dan mitra
    MarkerLayer(
      markers: [
        // User marker
        Marker(
          point: userLocation,
          width: 80,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(...)],
                ),
                child: Icon(Icons.person_pin_circle),
              ),
              Container(child: Text('Anda')),
            ],
          ),
        ),
        
        // Mitra marker
        Marker(
          point: mitraLocation,
          width: 80,
          height: 80,
          child: Icon(Icons.local_shipping),
        ),
      ],
    ),
  ],
)

// 2. Real-time update dengan Timer
Timer.periodic(Duration(seconds: 5), (timer) {
  _loadTrackingData(); // Fetch dari backend
});

// 3. Auto-center map untuk show both markers
void animateCameraToShowBoth() {
  final bounds = LatLngBounds.fromPoints([userLocation, mitraLocation]);
  mapController.fitBounds(bounds, 
    options: FitBoundsOptions(padding: EdgeInsets.all(50)));
}
```

### Package yang Diperlukan

```yaml
dependencies:
  flutter_map: ^8.2.1                    # OpenStreetMap widget (sudah digunakan)
  latlong2: ^0.9.1                       # Koordinat lat/long (sudah digunakan)
  flutter_map_cache: ^2.0.0+1            # Map caching (sudah digunakan)
  geolocator: ^10.1.0                    # Location services
  location: ^5.0.3                       # Background location
  web_socket_channel: ^2.4.0             # Real-time tracking
  flutter_polyline_points: ^2.1.0        # Rute polyline (sudah digunakan)
```

**Catatan:** Package `flutter_map`, `latlong2`, `flutter_map_cache`, dan `flutter_polyline_points` sudah digunakan di aplikasi untuk fitur tracking dan wilayah.

---

## 📱 Desain UI per Tab

### Tab 1: Dijadwalkan (Pending)

```
┌─────────────────────────────────────────┐
│  📅 Jadwal Pickup                       │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🗑️ Pickup Organik              │    │
│  │ Senin, 1 April 2026 • 08:00    │    │
│  │ Jl. Sudirman No. 123           │    │
│  │                                 │    │
│  │ ⏳ Menunggu Mitra              │    │
│  │ [Edit] [Batalkan]              │    │
│  └─────────────────────────────────┘    │
│                                         │
│  💡 Mitra akan segera menerima         │
│     jadwal Anda                         │
└─────────────────────────────────────────┘
```

**Fitur:**
- Daftar jadwal pending
- Tombol edit jadwal
- Tombol batalkan
- Info estimasi waktu mitra tersedia

---

### Tab 2: Berlangsung (Assigned, On The Way, Arrived)

```
┌─────────────────────────────────────────┐
│  🚀 Pickup Sedang Berlangsung          │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🗺️ [PETA GPS TRACKING OSM]        │    │
│  │                                 │    │
│  │    📍 Mitra menuju lokasi Anda  │    │
│  │    ════════════════════════     │    │
│  │    🛵 Ahmad K.                  │    │
│  │    ETA: 12 menit • 3.5 km       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 👤 Ahmad Kurniawan             │    │
│  │ ⭐ 4.8 • 156 pickup             │    │
│  │ 📞 081234567890                │    │
│  │                                 │    │
│  │ [📞 Hubungi] [💬 Chat]         │    │
│  └─────────────────────────────────┘    │
│                                         │
│  📦 Detail Pickup                       │
│  • Organik: 5 kg                        │
│  • Plastik: 2 kg (tambahan)            │
└─────────────────────────────────────────┘
```

**Status Badge:**
- `assigned` → 🟡 "Mitra Diterima"
- `on_the_way` → 🔵 "Menuju Lokasi" + GPS aktif
- `arrived` → 🟢 "Mitra Sudah Tiba"

**Fitur:**
- **GPS Tracking Map dengan OpenStreetMap** (saat `on_the_way`)
  - Real-time marker posisi mitra
  - Polyline rute perjalanan
  - Auto-center pada posisi mitra
- Info mitra (nama, foto, rating)
- Tombol hubungi/chat mitra
- ETA dan jarak real-time
- Detail sampah yang akan dijemput

---

### Tab 3: Selesai (Completed)

```
┌─────────────────────────────────────────┐
│  ✅ Pickup Selesai                      │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🎉 +150 Poin                    │    │
│  │                                 │    │
│  │ Senin, 1 April 2026            │    │
│  │ Oleh: Ahmad Kurniawan          │    │
│  │                                 │    │
│  │ ─────────────────────────────   │    │
│  │ 🥬 Organik     5 kg    +50 pts │    │
│  │ ♻️ Plastik     3 kg    +30 pts │    │
│  │ 📄 Kertas      2 kg    +20 pts │    │
│  │ ─────────────────────────────   │    │
│  │ Total: 10 kg          +100 pts │    │
│  │                                 │    │
│  │ 📸 [Lihat Foto Bukti]          │    │
│  │ ⭐ [Beri Rating Mitra]         │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

**Fitur:**
- Highlight poin yang didapat
- Breakdown per jenis sampah
- Foto bukti pickup
- Rating mitra (opsional)
- Riwayat lengkap

---

### Tab 4: Dibatalkan (Cancelled)

```
┌─────────────────────────────────────────┐
│  ❌ Jadwal Dibatalkan                   │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🗑️ Pickup Elektronik           │    │
│  │ Sabtu, 30 Mar 2026             │    │
│  │                                 │    │
│  │ ❌ Dibatalkan oleh: User       │    │
│  │ Alasan: Tidak jadi membuang    │    │
│  │                                 │    │
│  │ [🔄 Jadwalkan Ulang]           │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

**Fitur:**
- Alasan pembatalan
- Siapa yang membatalkan (user/mitra/sistem)
- Tombol jadwalkan ulang

---

## 🗂️ Struktur File yang Dibutuhkan

```
lib/ui/pages/end_user/activity/
├── activity_page_improved.dart          # Main page dengan 4 tabs
├── tabs/
│   ├── scheduled_tab.dart               # Tab 1: Dijadwalkan (pending)
│   ├── ongoing_tab.dart                 # Tab 2: Berlangsung (assigned, on_the_way, arrived)
│   ├── completed_tab.dart               # Tab 3: Selesai (completed)
│   └── cancelled_tab.dart               # Tab 4: Dibatalkan (cancelled)
├── widgets/
│   ├── activity_card.dart               # Card komponen untuk setiap item
│   ├── gps_tracking_map.dart            # Widget peta GPS tracking
│   ├── mitra_info_card.dart             # Card info mitra
│   ├── pickup_detail_card.dart          # Card detail pickup/sampah
│   └── points_summary_card.dart         # Card ringkasan poin
└── activity_content_improved.dart       # (existing, perlu update)
```

---

## 📦 Dependencies & Packages

**Packages yang sudah tersedia (sudah di pubspec.yaml):**
```yaml
dependencies:
  # Map & Location (OpenStreetMap) - SUDAH ADA
  flutter_map: ^8.2.1           # Flutter map widget untuk OSM
  latlong2: ^0.9.1               # Latitude/Longitude handling
  flutter_map_cache: ^2.0.0+1    # Offline tile caching
  flutter_polyline_points: ^2.1.0 # Polyline decoding untuk rute
  
  # Komunikasi real-time - SUDAH ADA
  web_socket_channel: ^2.4.0     # WebSocket connection
  
  # HTTP & State Management - SUDAH ADA
  http: ^1.1.0
  provider: ^6.0.5
  
  # URL Launcher (untuk telp/chat) - SUDAH ADA
  url_launcher: ^6.2.1
```

**Tile Server OpenStreetMap:**
- URL Template: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- User Agent: `com.example.gerobaks` (sesuaikan dengan package name)
- Max Zoom: 19

---

## 🔧 Perubahan Backend yang Diperlukan

### 1. Endpoint Lokasi Mitra Real-time

```
GET /api/pickup-schedules/{id}/mitra-location
```

Response:
```json
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "updated_at": "2026-03-31T10:15:30Z",
  "heading": 45.5,
  "speed": 25.3,
  "eta_minutes": 12,
  "distance_km": 3.5
}
```

### 2. WebSocket untuk Real-time Update

```
ws://api.gerobaks.com/ws/tracking/{schedule_id}
```

Events:
- `location_update` - Update lokasi mitra
- `status_change` - Perubahan status jadwal
- `eta_update` - Update estimasi waktu tiba

### 3. Endpoint Rating Mitra

```
POST /api/pickup-schedules/{id}/rate
```

Body:
```json
{
  "rating": 5,
  "comment": "Mitra ramah dan tepat waktu"
}
```

---

## 📅 Timeline Implementasi

| Fase | Durasi | Deliverable |
|------|--------|-------------|
| **1. Setup** | - | Struktur file, dependencies |
| **2. Tab Dijadwalkan** | - | List pending, edit, cancel |
| **3. Tab Berlangsung** | - | List ongoing, GPS tracking dasar |
| **4. Tab Selesai** | - | List completed, detail poin |
| **5. Tab Dibatalkan** | - | List cancelled, reschedule |
| **6. GPS Tracking** | - | Real-time map, polyline, ETA |
| **7. Polish & Test** | - | UI/UX refinement, testing |

---

## ✅ Checklist Implementasi

### Frontend (Flutter)

- [ ] Refactor `activity_page_improved.dart` ke 4 tabs
- [ ] Buat `scheduled_tab.dart` untuk pending schedules
- [ ] Buat `ongoing_tab.dart` dengan GPS tracking
- [ ] Buat `completed_tab.dart` dengan detail poin
- [ ] Buat `cancelled_tab.dart` dengan reschedule
- [ ] Implementasi `gps_tracking_map.dart`
- [ ] Implementasi real-time location updates
- [ ] Implementasi `mitra_info_card.dart`
- [ ] Testing di berbagai kondisi network

### Backend (Laravel)

- [ ] Endpoint GET mitra-location
- [ ] WebSocket server untuk real-time tracking
- [ ] Endpoint POST rate mitra
- [ ] Mitra location broadcasting

---

## 📚 Referensi

### API & Backend
- [GEND-18: Pickup Schedule API Documentation](https://gerobaks.youtrack.cloud/issue/Gend-18)
- [Flutter WebSocket](https://docs.flutter.dev/cookbook/networking/web-sockets)

### Mapping & Location
- [flutter_map Package](https://pub.dev/packages/flutter_map) - OpenStreetMap widget
- [latlong2 Package](https://pub.dev/packages/latlong2) - Koordinat geografis
- [Geolocator Package](https://pub.dev/packages/geolocator) - Location services
- [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Tile_servers) - Tile servers
- [OpenStreetMap Directions](https://www.openstreetmap.org/directions) - Routing reference

### Implementasi Existing di Codebase
- `lib/ui/pages/end_user/tracking/tracking_content.dart` - FlutterMap basic
- `lib/ui/pages/user/tracking/user_mitra_tracking_osm_page.dart` - User tracking OSM
- `lib/ui/pages/mitra/tracking/tracking_mitra_page.dart` - Mitra tracking
- `lib/ui/pages/mitra/pengambilan/navigation_page_redesigned.dart` - Navigation dengan OSM

---

## 💬 Catatan

1. **GPS Tracking Priority**: Fitur GPS tracking adalah prioritas utama untuk Tab 2 (Berlangsung) karena memberikan value paling besar ke user.

2. **OpenStreetMap Implementation**: Aplikasi sudah menggunakan `flutter_map` dengan OpenStreetMap tiles. Gunakan implementasi yang sama dengan halaman tracking existing untuk konsistensi.

3. **Tile Server**: Gunakan `https://tile.openstreetmap.org/{z}/{x}/{y}.png` sebagai tile URL (sudah digunakan di tracking pages existing).

4. **Battery Consideration**: Implementasi GPS tracking harus mempertimbangkan konsumsi baterai. Gunakan interval update yang reasonable (setiap 5-10 detik).

5. **Offline Handling**: Perlu handling untuk kondisi offline/koneksi buruk saat tracking. Flutter_map_cache sudah tersedia untuk offline map tiles.

6. **Privacy**: Lokasi mitra hanya di-track saat status `on_the_way` dan hanya visible ke user yang jadwalnya sedang diproses.

---

*Dokumen ini akan diupdate seiring progres implementasi.*
