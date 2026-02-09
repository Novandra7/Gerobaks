import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;
  final LatLng? initialLocation;

  const MapPickerPage({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late MapController _mapController;
  LatLng _selectedLocation = const LatLng(
    -6.2088,
    106.8456,
  ); // Default: Jakarta
  String _selectedAddress = '';
  bool _isLoading = true; // Start with loading true
  bool _locationObtained = false; // Track if we got user's location

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Always try to get current location first for better UX
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
      _locationObtained = true;
      setState(() => _isLoading = false);
      // Still get address even if we have initial location
      _getAddressFromLatLng(_selectedLocation);
    } else {
      // Get user's real location on start
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'GPS tidak aktif. Gunakan lokasi default atau tap pada peta.',
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
          // Use default location and stop loading
          setState(() => _isLoading = false);
          _getAddressFromLatLng(_selectedLocation);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Izin lokasi ditolak. Tap pada peta untuk memilih lokasi.',
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.orange,
              ),
            );
            // Use default location and stop loading
            setState(() => _isLoading = false);
            _getAddressFromLatLng(_selectedLocation);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin lokasi ditolak permanen. Tap pada peta untuk memilih.',
              ),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
          // Use default location and stop loading
          setState(() => _isLoading = false);
          _getAddressFromLatLng(_selectedLocation);
        }
        return;
      }

      // Get current position with high accuracy and timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Add timeout
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _locationObtained = true;
      });

      // Move map to user's location with animation
      _mapController.move(_selectedLocation, 15.0);

      // Get address for the location
      await _getAddressFromLatLng(_selectedLocation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Lokasi Anda berhasil ditemukan'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal mendapatkan lokasi. Tap pada peta untuk memilih lokasi.',
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        // Use default location on error
        setState(() => _isLoading = false);
        _getAddressFromLatLng(_selectedLocation);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build complete address like in tracking
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

        setState(() {
          if (addressParts.isNotEmpty) {
            _selectedAddress = addressParts.join(', ');
          } else {
            // Fallback to coordinates if no address found
            _selectedAddress =
                'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
          }
        });
      }
    } catch (e) {
      // Geocoding error - might be network or API limit
      if (mounted) {
        setState(() {
          _selectedAddress =
              'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
        });
        
        // Show user-friendly message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan alamat: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
      _locationObtained = false; // Mark as manually selected, not from GPS
    });
    _getAddressFromLatLng(location);

    // Optional: Animate map to center on new location
    _mapController.move(location, _mapController.camera.zoom);
  }

  void _confirmLocation() {
    widget.onLocationSelected(
      _selectedAddress,
      _selectedLocation.latitude,
      _selectedLocation.longitude,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Anda'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoading ? null : _getCurrentLocation,
            tooltip: 'Gunakan Lokasi Saat Ini',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              // Using OpenTopoMap - Free for production use, no API key needed
              // More alternatives: https://wiki.openstreetmap.org/wiki/Tile_servers
              TileLayer(
                urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gerobaks.app/1.0',
                maxNativeZoom: 17,
                maxZoom: 17,
                subdomains: const ['a', 'b', 'c'],
                // Attribution (required by OpenTopoMap)
                tileProvider: NetworkTileProvider(),
              ),
              // Circle around selected location for accuracy visualization
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
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mencari lokasi Anda...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _selectedAddress.isEmpty
                            ? Colors.grey
                            : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress.isEmpty
                              ? 'Tap pada peta untuk memilih lokasi'
                              : _selectedAddress,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedAddress.isEmpty
                                ? FontWeight.normal
                                : FontWeight.w600,
                            color: _selectedAddress.isEmpty
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _locationObtained
                                ? 'Lokasi GPS Anda'
                                : 'Lokasi dipilih',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _selectedAddress.isEmpty
                        ? null
                        : _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi Lokasi Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Attribution text (required by OpenTopoMap)
                  Text(
                    'Map data: © OpenStreetMap contributors, SRTM | Map style: © OpenTopoMap',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
