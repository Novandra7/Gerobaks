import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bank_sha/services/location_service.dart';
import 'package:bank_sha/services/tracking_api_service.dart';
import 'package:bank_sha/shared/theme.dart';

/// Screen untuk Mitra tracking lokasi mereka sendiri
/// - Tampilkan lokasi di map
/// - Toggle Start/Stop tracking
/// - Update ke server setiap 15 detik
class MitraLocationTrackingPage extends StatefulWidget {
  const MitraLocationTrackingPage({super.key});

  @override
  State<MitraLocationTrackingPage> createState() =>
      _MitraLocationTrackingPageState();
}

class _MitraLocationTrackingPageState extends State<MitraLocationTrackingPage> {
  final LocationService _locationService = LocationService();
  final TrackingApiService _trackingApi = TrackingApiService();

  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isTracking = false;
  bool _isLoading = false;
  String? _lastUpdateTime;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    _mapController?.dispose();
    super.dispose();
  }

  /// Load lokasi mitra dari server
  Future<void> _loadMyLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get lokasi dari server
      final locationData = await _trackingApi.getMyLocation();

      if (locationData['current_location'] != null) {
        final loc = locationData['current_location'];
        final latitude = loc['latitude'];
        final longitude = loc['longitude'];

        if (latitude != null && longitude != null) {
          setState(() {
            _currentPosition = Position(
              latitude: latitude,
              longitude: longitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            _lastUpdateTime = loc['last_update'];
            _updateMarker();
          });

          // Move camera ke lokasi
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(latitude, longitude)),
          );
        }
      } else {
        // Belum ada lokasi, get dari GPS
        await _getCurrentLocation();
      }
    } catch (e) {
      print('❌ Error loading my location: $e');
      // Fallback ke GPS
      await _getCurrentLocation();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get current location dari GPS
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Position? position = await _locationService.getCurrentPosition();

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _updateMarker();
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      } else {
        setState(() {
          _errorMessage = 'Tidak dapat mengambil lokasi GPS';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Update marker di map
  void _updateMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('my_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: 'Lokasi Saya',
            snippet: 'Posisi saat ini',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      };
    });
  }

  /// Start tracking
  Future<void> _startTracking() async {
    setState(() {
      _errorMessage = null;
    });

    bool success = await _locationService.startTracking(
      intervalSeconds: 15, // Update setiap 15 detik
      onUpdate: (Position position) async {
        // Update UI
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _lastUpdateTime = DateTime.now().toIso8601String();
            _updateMarker();
          });

          // Move camera
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        }

        // Kirim ke server
        try {
          await _trackingApi.updateMitraLocation(position);
          print('✅ Location sent to server');
        } catch (e) {
          print('❌ Failed to send location: $e');
          // Queue untuk retry? (optional)
        }
      },
    );

    if (success) {
      setState(() {
        _isTracking = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Tracking dimulai'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Gagal memulai tracking. Periksa izin GPS.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal memulai tracking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Stop tracking
  void _stopTracking() {
    _locationService.stopTracking();
    setState(() {
      _isTracking = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🛑 Tracking dihentikan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Lokasi Saya'),
        backgroundColor: greenColor,
      ),
      body: Stack(
        children: [
          // Google Map
          _currentPosition == null
              ? Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text('Lokasi belum tersedia'),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.my_location),
                              label: const Text('Ambil Lokasi'),
                            ),
                          ],
                        ),
                )
              : GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                ),

          // Info overlay
          if (_currentPosition != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isTracking
                                ? Icons.location_on
                                : Icons.location_off,
                            color: _isTracking ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isTracking
                                  ? 'Tracking Aktif'
                                  : 'Tracking Tidak Aktif',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '📍 ${_locationService.formatCoordinates(_currentPosition!.latitude, _currentPosition!.longitude)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_lastUpdateTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Update: ${_formatTime(_lastUpdateTime!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Control buttons
          if (_currentPosition != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Refresh location button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Start/Stop tracking button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _isTracking ? 'Stop Tracking' : 'Start Tracking',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTracking
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Loading overlay
          if (_isLoading && _currentPosition != null)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      DateTime time = DateTime.parse(isoString);
      DateTime now = DateTime.now();
      Duration diff = now.difference(time);

      if (diff.inSeconds < 60) {
        return '${diff.inSeconds} detik lalu';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} menit lalu';
      } else {
        return '${diff.inHours} jam lalu';
      }
    } catch (e) {
      return isoString;
    }
  }
}
