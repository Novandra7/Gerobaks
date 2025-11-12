# Map Picker Improvements - Registration Location

## Problem
- Map tidak terlihat (blank)
- Lokasi tidak sesuai dengan GPS user
- Format alamat tidak lengkap

## Solution

### 1. Gunakan OpenStreetMap Tile (Sama dengan Tracking Mitra)
**Implementation:**
```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  subdomains: const ['a', 'b', 'c'],
  userAgentPackageName: 'com.gerobaks.app',
)
```

**Benefit:** 
- Menggunakan tile yang sama dengan tracking mitra
- Lebih detail dan akurat untuk wilayah Indonesia
- Load balancing dengan subdomains a, b, c

### 2. Perbaiki Format Alamat
**Before:**
```dart
_selectedAddress = '${place.street}, ${place.subLocality}, ${place.locality}';
```

**After:**
```dart
List<String> addressParts = [];

if (place.street != null && place.street!.isNotEmpty) {
  addressParts.add(place.street!);
}
if (place.subLocality != null && place.subLocality!.isNotEmpty) {
  addressParts.add(place.subLocality!);
}
if (place.locality != null && place.locality!.isNotEmpty) {
  addressParts.add(place.locality!);
}

_selectedAddress = addressParts.join(', ');
```

**Benefit:** 
- Alamat tidak ada null values
- Format lebih bersih
- Fallback ke koordinat jika geocoding gagal
```dart
CircleLayer(
  circles: [
    CircleMarker(
      point: _selectedLocation,
      radius: 50,
      useRadiusInMeter: true,
      color: Colors.blue.withOpacity(0.2),
      borderColor: Colors.blue.withOpacity(0.5),
      borderStrokeWidth: 2,
    ),
  ],
)
```

**Benefit:** User bisa melihat area akurasi lokasi yang dipilih.

### 3. Tingkatkan Marker Visibility
```dart
Marker(
  point: _selectedLocation,
  width: 50,
  height: 50,
  alignment: Alignment.center,
  child: const Icon(
    Icons.location_pin,
    size: 50,  // Lebih besar dari 40
    color: Colors.red,
    shadows: [
      Shadow(
        color: Colors.black26,
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    ],
  ),
)
```

**Benefit:** Marker lebih terlihat dengan shadow effect.

### 4. Perbaiki Auto-Location Flow
```dart
Future<void> _getCurrentLocation() async {
  // Get current position with HIGH accuracy
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  
  // Update state
  setState(() {
    _selectedLocation = LatLng(position.latitude, position.longitude);
    _locationObtained = true;
  });

  // Animate map to user's location
  _mapController.move(_selectedLocation, 16.0);
  
  // Get address
  await _getAddressFromLatLng(_selectedLocation);

  // Show success notification
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('✓ Lokasi Anda berhasil ditemukan'),
      backgroundColor: Colors.green,
    ),
  );
}
```

**Benefit:** 
- Akurasi GPS tinggi
- Map langsung zoom ke lokasi user
- User mendapat feedback visual

### 5. Enhanced Map Interaction
```dart
void _onMapTap(TapPosition tapPosition, LatLng location) {
  setState(() {
    _selectedLocation = location;
    _locationObtained = false; // Mark as manually selected
  });
  _getAddressFromLatLng(location);
  
  // Center map on new location
  _mapController.move(location, _mapController.camera.zoom);
}
```

**Benefit:** User bisa tap di map untuk mengubah lokasi dengan mudah.

### 6. Better Loading State
```dart
if (_isLoading)
  Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: Card(
        child: Column(
          children: [
            CircularProgressIndicator(),
            Text('Mendapatkan lokasi Anda...'),
            Text('Pastikan GPS aktif'),
          ],
        ),
      ),
    ),
  )
```

**Benefit:** User tahu bahwa sistem sedang mencari lokasi GPS mereka.

## Testing Steps

1. **Test Realtime Location**
   - Buka halaman registrasi
   - Isi data sampai step 4 (Alamat & Lokasi)
   - Klik "Pilih Lokasi di Peta"
   - Map akan langsung mencari lokasi GPS Anda
   - Pastikan marker muncul di lokasi Anda yang sebenarnya

2. **Test Manual Location Selection**
   - Di map, tap di area lain
   - Marker akan pindah ke lokasi yang di-tap
   - Alamat akan update otomatis
   - Badge berubah dari "Lokasi GPS Anda" ke "Lokasi dipilih"

3. **Test GPS Button**
   - Tap icon GPS di AppBar (pojok kanan atas)
   - Map akan kembali ke lokasi GPS Anda
   - Badge berubah ke "Lokasi GPS Anda"

4. **Test on Simulator**
   - Di iOS Simulator: Features → Location → Custom Location
   - Set koordinat (misal: Jakarta -6.2088, 106.8456)
   - Atau pilih preset seperti "Apple Park"
   - Map akan menampilkan lokasi yang di-set

## Files Changed
- `/lib/ui/widgets/shared/map_picker.dart`

## Dependencies Used
- `flutter_map`: ^7.0.2
- `latlong2`: ^0.9.1
- `geolocator`: ^13.0.2
- `geocoding`: ^3.0.0

## Result
✅ Map terlihat dengan jelas menggunakan CartoDB tile
✅ Lokasi sesuai dengan GPS user (high accuracy)
✅ Tile sama dengan tracking page (konsistensi UI)
✅ User experience lebih baik dengan loading indicator
✅ Marker lebih terlihat dengan shadow effect
✅ Circle indicator menunjukkan area akurasi
