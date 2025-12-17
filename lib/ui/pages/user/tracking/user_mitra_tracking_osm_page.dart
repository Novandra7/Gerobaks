import 'dart:async';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/realtime_tracking_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// 📍 Halaman Tracking Real-Time untuk User dengan OpenStreetMap
///
/// Menampilkan:
/// - Posisi user (marker biru)
/// - Posisi mitra (marker hijau) - UPDATE SETIAP 5 DETIK
/// - Polyline rute (garis)
/// - Jarak & ETA real-time
/// - Tombol call mitra
/// - Warning jika lokasi mitra basi (> 30 detik)

class UserMitraTrackingPage extends StatefulWidget {
  final ScheduleModel schedule;

  const UserMitraTrackingPage({super.key, required this.schedule});

  @override
  State<UserMitraTrackingPage> createState() => _UserMitraTrackingPageState();
}

class _UserMitraTrackingPageState extends State<UserMitraTrackingPage> {
  final MapController _mapController = MapController();
  Timer? _pollingTimer;
  bool _isLoading = true;
  String? _errorMessage;

  // Tracking data
  LatLng? _userLocation;
  LatLng? _mitraLocation;
  String? _mitraName;
  String? _mitraPhone;
  double? _distanceKm;
  int? _etaMinutes;
  bool _isMitraLocationStale = false;
  DateTime? _lastMitraUpdate;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }

  /// Start tracking - polling setiap 5 detik
  void _startTracking() {
    _loadTrackingData(); // Load pertama kali

    // Polling setiap 5 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadTrackingData();
    });
  }

  /// Stop tracking
  void _stopTracking() {
    _pollingTimer?.cancel();
  }

  /// Load tracking data dari backend
  Future<void> _loadTrackingData() async {
    try {
      // Convert String ID to int
      final scheduleIdInt = int.tryParse(widget.schedule.id!);
      if (scheduleIdInt == null) {
        throw Exception('Invalid schedule ID');
      }

      final trackingInfo = await RealTimeTrackingService().getUserTrackingInfo(
        scheduleIdInt,
      );

      if (trackingInfo == null) {
        throw Exception('Tracking data not available');
      }

      if (!mounted) return;

      setState(() {
        // User location (dari schedule)
        _userLocation = LatLng(
          trackingInfo.userLocation.latitude,
          trackingInfo.userLocation.longitude,
        );

        // Mitra location (real-time dari backend)
        if (trackingInfo.mitraLocation.latitude != null &&
            trackingInfo.mitraLocation.longitude != null) {
          _mitraLocation = LatLng(
            trackingInfo.mitraLocation.latitude!,
            trackingInfo.mitraLocation.longitude!,
          );

          // Check if stale (> 30 seconds)
          _lastMitraUpdate = trackingInfo.mitraLocation.lastUpdate;
          _isMitraLocationStale = trackingInfo.mitraLocation.isStale;
        }

        // Mitra info
        _mitraName = trackingInfo.mitraInfo.name;
        _mitraPhone = trackingInfo.mitraInfo.phone;

        // Metrics
        _distanceKm = trackingInfo.trackingInfo.distanceKm;
        _etaMinutes = trackingInfo.trackingInfo.etaMinutes;

        _isLoading = false;
        _errorMessage = null;
      });

      // Animate camera to show both markers
      _animateCameraToShowBoth();
    } catch (e) {
      print('❌ Error loading tracking data: $e');
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat data tracking';
        _isLoading = false;
      });
    }
  }

  /// Animate camera to show both markers
  void _animateCameraToShowBoth() {
    if (_userLocation == null || _mitraLocation == null) return;

    // Calculate bounds
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

    // Calculate center and zoom
    final centerLat = (north + south) / 2;
    final centerLng = (east + west) / 2;
    final center = LatLng(centerLat, centerLng);

    // Calculate appropriate zoom level
    final latDiff = north - south;
    final lngDiff = east - west;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Simple zoom calculation (can be improved)
    double zoom = 15;
    if (maxDiff > 0.1)
      zoom = 11;
    else if (maxDiff > 0.05)
      zoom = 12;
    else if (maxDiff > 0.02)
      zoom = 13;
    else if (maxDiff > 0.01)
      zoom = 14;

    _mapController.move(center, zoom);
  }

  /// Get last update text
  String _getLastUpdateText() {
    if (_lastMitraUpdate == null) return 'Tidak diketahui';

    final age = DateTime.now().difference(_lastMitraUpdate!);
    if (age.inSeconds < 60) return '${age.inSeconds} detik lalu';
    if (age.inMinutes < 60) return '${age.inMinutes} menit lalu';
    return '${age.inHours} jam lalu';
  }

  /// Call mitra
  Future<void> _callMitra() async {
    if (_mitraPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon mitra tidak tersedia')),
      );
      return;
    }

    final uri = Uri.parse('tel:$_mitraPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Mitra'),
        backgroundColor: greenColor,
        foregroundColor: whiteColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : Stack(
              children: [
                // OpenStreetMap
                _buildMap(),

                // Info Card (bottom)
                _buildInfoCard(),

                // Stale warning (top)
                if (_isMitraLocationStale) _buildStaleWarning(),
              ],
            ),
    );
  }

  /// Build OpenStreetMap
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
        // OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.bank_sha',
          maxZoom: 19,
        ),

        // Polyline Layer (garis antara user dan mitra)
        if (_userLocation != null && _mitraLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_mitraLocation!, _userLocation!],
                color: Colors.blue,
                strokeWidth: 4,
                borderColor: Colors.blue.shade200,
                borderStrokeWidth: 2,
              ),
            ],
          ),

        // Marker Layer
        MarkerLayer(
          markers: [
            // User marker (blue)
            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue.shade700,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Mitra marker (green)
            if (_mitraLocation != null)
              Marker(
                point: _mitraLocation!,
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: _isMitraLocationStale
                            ? Colors.orange
                            : greenColor,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _isMitraLocationStale
                            ? Colors.orange
                            : greenColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _mitraName ?? 'Mitra',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  /// Build info card at bottom
  Widget _buildInfoCard() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mitra info
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: greenColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mitraName ?? 'Mitra',
                          style: blackTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sedang dalam perjalanan',
                          style: greyTextStyle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _callMitra,
                    icon: Icon(Icons.phone, color: greenColor),
                    style: IconButton.styleFrom(
                      backgroundColor: greenColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Distance & ETA
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.route,
                      label: 'Jarak',
                      value: _distanceKm != null
                          ? '${_distanceKm!.toStringAsFixed(1)} km'
                          : 'Menghitung...',
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.access_time,
                      label: 'Estimasi Tiba',
                      value: _etaMinutes != null
                          ? '~$_etaMinutes menit'
                          : 'Menghitung...',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build metric item
  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: greenColor, size: 24),
        const SizedBox(height: 4),
        Text(label, style: greyTextStyle.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
        ),
      ],
    );
  }

  /// Build stale location warning
  Widget _buildStaleWarning() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: Colors.orange.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lokasi mitra terakhir diperbarui ${_getLastUpdateText()}',
                  style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: blackTextStyle.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTrackingData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
