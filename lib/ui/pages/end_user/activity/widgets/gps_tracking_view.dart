import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bank_sha/services/realtime_tracking_service.dart';
import 'package:bank_sha/services/osrm_routing_service.dart';
import 'package:bank_sha/shared/theme.dart';

/// Widget untuk menampilkan GPS tracking real-time
/// Menggunakan OpenStreetMap dengan flutter_map
///
/// Features:
/// - Auto-update setiap 5 detik
/// - Rute yang mengikuti jalan (OSRM routing)
/// - Distance & ETA dari OSRM routing (bukan dari API tracking)
/// - Loading/error states dengan retry mechanism
/// - Map controls (zoom, re-center)
/// - Live update indicator
class GpsTrackingView extends StatefulWidget {
  final String scheduleId;
  final bool autoUpdate;

  const GpsTrackingView({
    super.key,
    required this.scheduleId,
    this.autoUpdate = true,
  });

  @override
  State<GpsTrackingView> createState() => _GpsTrackingViewState();
}

class _GpsTrackingViewState extends State<GpsTrackingView> {
  final MapController _mapController = MapController();
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isInitialLoad = true;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Tracking data
  LatLng? _userLocation;
  LatLng? _mitraLocation;
  double? _distanceKm;
  int? _etaMinutes;
  bool _isMitraLocationStale = false;

  // Route data (untuk garis yang mengikuti jalan)
  List<LatLng>? _routePoints;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _stopTracking();
    _mapController.dispose();
    super.dispose();
  }

  void _startTracking() {
    _loadTrackingData();

    // Polling setiap 5 detik jika autoUpdate enabled
    if (widget.autoUpdate) {
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _loadTrackingData();
      });
    }
  }

  void _stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _loadTrackingData() async {
    try {
      final scheduleIdInt = int.tryParse(widget.scheduleId);
      if (scheduleIdInt == null) {
        throw Exception('ID jadwal tidak valid');
      }

      final trackingInfo = await RealTimeTrackingService().getUserTrackingInfo(
        scheduleIdInt,
      );

      if (trackingInfo == null) {
        throw Exception('Data tracking tidak tersedia');
      }

      if (!mounted) return;

      // Validasi lokasi user - FIXED: cek null sebelum akses
      final hasValidUserLocation =
          trackingInfo.userLocation.latitude != null &&
          trackingInfo.userLocation.longitude != null;

      if (!hasValidUserLocation) {
        throw Exception('Lokasi tujuan tidak tersedia');
      }

      final wasInitialLoad = _isInitialLoad;
      var mitraLocationChanged = false;

      setState(() {

        _userLocation = LatLng(
          trackingInfo.userLocation.latitude!,
          trackingInfo.userLocation.longitude!,
        );

        // Update lokasi mitra jika tersedia
        if (trackingInfo.mitraLocation.latitude != null &&
            trackingInfo.mitraLocation.longitude != null) {
          final newMitraLocation = LatLng(
            trackingInfo.mitraLocation.latitude!,
            trackingInfo.mitraLocation.longitude!,
          );

          // Cek apakah lokasi mitra berubah
          mitraLocationChanged =
              _mitraLocation == null ||
              _mitraLocation!.latitude != newMitraLocation.latitude ||
              _mitraLocation!.longitude != newMitraLocation.longitude;

          _mitraLocation = newMitraLocation;
          _isMitraLocationStale = trackingInfo.mitraLocation.isStale;
          print('isstale: ${_isMitraLocationStale}');

        }

        // TIDAK lagi gunakan distance & ETA dari API tracking
        // Akan diupdate oleh _loadRoute() dari OSRM

        _isLoading = false;
        _isInitialLoad = false;
        _errorMessage = null;
        _retryCount = 0;
      });

      // Hanya animate camera saat initial load, tidak setiap update
      if (wasInitialLoad) {
        _animateCameraToShowBoth();
      }

      // Load route baru jika lokasi mitra berubah
      // Route service akan update distance & ETA dari OSRM
      if (mitraLocationChanged &&
          _mitraLocation != null &&
          _userLocation != null &&
          !_isLoadingRoute) {
        _loadRoute(_mitraLocation!, _userLocation!);
      }

      // Load route jika belum pernah di-load (initial load dengan kedua lokasi tersedia)
      if (_mitraLocation != null &&
          _userLocation != null &&
          _routePoints == null &&
          !_isLoadingRoute) {
        _loadRoute(_mitraLocation!, _userLocation!);
      }
    } catch (e) {
      if (!mounted) return;

      _retryCount++;

      String errorMsg;
      if (e.toString().contains('ID jadwal')) {
        errorMsg = 'ID jadwal tidak valid';
      } else if (e.toString().contains('Lokasi tujuan')) {
        errorMsg = e.toString();
      } else if (e.toString().contains('tidak tersedia')) {
        errorMsg = 'Data tracking belum tersedia';
      } else if (_retryCount >= _maxRetries) {
        errorMsg = 'Tidak dapat memuat data tracking.\nCoba lagi nanti.';
      } else {
        errorMsg = 'Sedang mencoba ulang... ($_retryCount/$_maxRetries)';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });

      // Auto retry jika belum mencapai max retries
      if (_retryCount < _maxRetries) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _loadTrackingData();
        });
      }
    }
  }

  /// Load rute jalan yang sebenarnya dari mitra ke user
  /// menggunakan OSRM routing service
  /// Juga update distance & ETA dari OSRM (bukan dari API tracking)
  Future<void> _loadRoute(LatLng start, LatLng end) async {
    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final routingService = OsrmRoutingService();

      // Fetch route points dan route details secara paralel
      final results = await Future.wait([
        routingService.getRoute(start: start, end: end),
        routingService.getRouteDetails(start: start, end: end),
      ]);

      if (!mounted) return;

      final routePoints = results[0] as List<LatLng>?;
      final routeDetails = results[1] as Map<String, dynamic>?;
      
      print('[GPS Tracking] Route points received: ${routePoints?.length ?? 0}');
      
      final effectiveRoutePoints =
          routePoints != null && routePoints.length >= 2
          ? routePoints
          : <LatLng>[start, end];
      
      print('[GPS Tracking] Using ${effectiveRoutePoints.length} points (OSRM success: ${routePoints != null})');

      setState(() {
        // Update route points
        _routePoints = effectiveRoutePoints;

        // Update distance & ETA dari OSRM
        if (routeDetails != null) {
          // Distance dari OSRM dalam meters, convert ke km
          // OSRM bisa return int atau double, jadi convert ke num dulu
          final distanceMeters = (routeDetails['distance'] as num).toDouble();
          _distanceKm = distanceMeters / 1000;

          // Duration dari OSRM dalam seconds, convert ke minutes
          final durationSeconds = (routeDetails['duration'] as num).toDouble();
          _etaMinutes = (durationSeconds / 60).ceil();
        }

        _isLoadingRoute = false;
      });
    } catch (e) {
      if (!mounted) return;

      print('[GPS Tracking] Route load failed: $e');

      setState(() {
        // Tetap tampilkan garis lurus agar route selalu terlihat saat OSRM gagal
        _routePoints = <LatLng>[start, end];
        _isLoadingRoute = false;
      });
    }
  }

  void _animateCameraToShowBoth() {
    if (_userLocation == null) return;

    // Jika hanya ada lokasi user, center ke user
    if (_mitraLocation == null) {
      _mapController.move(_userLocation!, 15);
      return;
    }

    // Calculate bounds untuk kedua lokasi
    final south = _userLocation!.latitude < _mitraLocation!.latitude
        ? _userLocation!.latitude
        : _mitraLocation!.latitude;
    final north = _userLocation!.latitude > _mitraLocation!.latitude
        ? _userLocation!.latitude
        : _mitraLocation!.latitude;
    final west = _userLocation!.longitude < _mitraLocation!.longitude
        ? _userLocation!.longitude
        : _mitraLocation!.longitude;
    final east = _userLocation!.longitude > _mitraLocation!.longitude
        ? _userLocation!.longitude
        : _mitraLocation!.longitude;

    final centerLat = (north + south) / 2;
    final centerLng = (east + west) / 2;
    final center = LatLng(centerLat, centerLng);

    final latDiff = north - south;
    final lngDiff = east - west;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Calculate zoom berdasarkan jarak - FIXED: tambah brackets
    double zoom = 15;
    if (maxDiff > 0.1) {
      zoom = 11;
    } else if (maxDiff > 0.05) {
      zoom = 12;
    } else if (maxDiff > 0.02) {
      zoom = 13;
    } else if (maxDiff > 0.01) {
      zoom = 14;
    }

    _mapController.move(center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isInitialLoad) {
      return _buildLoadingView();
    }

    if (_errorMessage != null && _userLocation == null) {
      return _buildErrorView();
    }

    return Column(
      children: [
        // Map Container
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              _buildMap(),
              if (_isMitraLocationStale) _buildStaleWarning(),

              // Loading hanya muncul sekali di awal saat rute belum ada
              if (_isLoadingRoute && _routePoints == null) _buildRouteLoadingIndicator(),
              _buildMapControls(),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Distance & ETA
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.route,
                label: 'Jarak',
                value: _distanceKm != null
                    ? _distanceKm! < 1
                          ? '${(_distanceKm! * 1000).toStringAsFixed(0)} m'
                          : '${_distanceKm!.toStringAsFixed(1)} km'
                    : '-',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.access_time,
                label: 'Estimasi',
                value: _etaMinutes != null ? _formatEta(_etaMinutes!) : '-',
                color: greenColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMap() {
    final initialCenter = _userLocation ?? const LatLng(-6.200000, 106.816666);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 15,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gerobaks',
          maxZoom: 19,
        ),

        // Hanya tampilkan polyline jika route sudah berhasil di-load dari OSRM
        // Tidak tampilkan garis lurus saat loading
        if (_routePoints != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints!,
                color: Colors.blue.shade600,
                strokeWidth: 4,
                // Smooth line untuk route yang berkelok
                borderColor: Colors.blue.shade900,
                borderStrokeWidth: 1,
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                width: 60,
                height: 60,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'Anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_mitraLocation != null)
              Marker(
                point: _mitraLocation!,
                width: 60,
                height: 60,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: _isMitraLocationStale
                            ? Colors.orange
                            : greenColor,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _isMitraLocationStale
                            ? Colors.orange
                            : greenColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'Mitra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: greyTextStyle.copyWith(fontSize: 10)),
                Text(
                  value,
                  style: blackTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: semiBold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEta(int minutes) {
    if (minutes < 60) {
      return '~$minutes menit';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '~$hours jam';
    }
    return '~$hours jam $remainingMinutes menit';
  }



  Widget _buildRouteLoadingIndicator() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade700.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Memuat rute...',
              style: whiteTextStyle.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Column(
        children: [
          // Zoom In
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () {
                final currentZoom = _mapController.camera.zoom;
                _mapController.move(
                  _mapController.camera.center,
                  currentZoom + 1,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Zoom Out
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: () {
                final currentZoom = _mapController.camera.zoom;
                _mapController.move(
                  _mapController.camera.center,
                  currentZoom - 1,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.remove, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Re-center
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: _animateCameraToShowBoth,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.my_location, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaleWarning() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Lokasi mitra mungkin tidak akurat',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: greenColor),
          const SizedBox(height: 16),
          Text(
            'Memuat peta tracking...',
            style: greyTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final canRetry = _retryCount < _maxRetries;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 40),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Gagal memuat peta',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (canRetry)
            SizedBox(
              width: 120,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _retryCount = 0;
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadTrackingData();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          if (!canRetry) ...[
            const SizedBox(height: 8),
            Text(
              'Silakan periksa koneksi internet Anda',
              style: greyTextStyle.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
