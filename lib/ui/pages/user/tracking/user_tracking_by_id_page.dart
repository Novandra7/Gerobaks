import 'dart:async';
import 'package:bank_sha/services/realtime_tracking_service.dart';
import 'package:bank_sha/services/mock_tracking_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🎭 MOCK TRACKING TOGGLE
/// Set true untuk gunakan data simulasi (tanpa backend)
/// Set false untuk gunakan data real dari backend
const bool USE_MOCK_TRACKING = true;

/// 📍 Halaman Tracking Real-Time untuk User dengan OpenStreetMap (By ID)
///
/// Menerima scheduleId langsung, tidak perlu ScheduleModel
/// Fetch semua data dari backend ATAU mock data (lihat USE_MOCK_TRACKING)
///
/// Menampilkan:
/// - Posisi user (marker biru)
/// - Posisi mitra (marker hijau) - UPDATE SETIAP 5 DETIK
/// - Polyline rute (garis)
/// - Jarak & ETA real-time
/// - Tombol call mitra
/// - Warning jika lokasi mitra basi (> 30 detik)
///
/// 🎭 MOCK MODE:
/// - User location: Fixed di Jakarta
/// - Mitra location: Bergerak mendekati user (30 km/h)
/// - Distance & ETA: Calculated automatically
/// - Updates every 5 seconds

class UserTrackingByIdPage extends StatefulWidget {
  final int scheduleId;

  const UserTrackingByIdPage({super.key, required this.scheduleId});

  @override
  State<UserTrackingByIdPage> createState() => _UserTrackingByIdPageState();
}

class _UserTrackingByIdPageState extends State<UserTrackingByIdPage> {
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

  /// Load tracking data dari backend atau mock
  Future<void> _loadTrackingData() async {
    try {
      print('🔍 Loading tracking data for schedule: ${widget.scheduleId}');
      print('🎭 Mock mode: ${USE_MOCK_TRACKING ? "ENABLED" : "DISABLED"}');

      Map<String, dynamic>? trackingData;

      if (USE_MOCK_TRACKING) {
        // 🎭 Use mock data
        print('🎭 Generating mock tracking data...');
        final mockResponse = MockTrackingService.generateMockTrackingData(
          widget.scheduleId,
        );
        trackingData = parseMockTrackingData(mockResponse);
        print('✅ Mock data generated successfully');

        // Print simulation status
        final simStatus = MockTrackingService.getSimulationStatus();
        print('📊 Simulation elapsed: ${simStatus['elapsed_minutes']} minutes');
      } else {
        // 🌐 Use real backend
        print('🌐 Fetching real tracking data from backend...');
        final trackingInfo = await RealTimeTrackingService()
            .getUserTrackingInfo(widget.scheduleId);

        print(
          '📦 Tracking info received: ${trackingInfo != null ? "YES" : "NULL"}',
        );

        if (trackingInfo == null) {
          print('❌ Tracking info is NULL - check backend response above');
          throw Exception(
            'Tracking data not available - Backend returned null response',
          );
        }

        // Convert TrackingInfoModel to Map (manual mapping)
        trackingData = {
          'user_location': {
            'latitude': trackingInfo.userLocation.latitude,
            'longitude': trackingInfo.userLocation.longitude,
          },
          'mitra_location': {
            'latitude': trackingInfo.mitraLocation.latitude,
            'longitude': trackingInfo.mitraLocation.longitude,
            'last_update': trackingInfo.mitraLocation.lastUpdate
                ?.toIso8601String(),
            'is_stale': trackingInfo.mitraLocation.isStale,
          },
          'mitra_info': {
            'name': trackingInfo.mitraInfo.name,
            'phone': trackingInfo.mitraInfo.phone,
          },
          'tracking_info': {
            'distance_km': trackingInfo.trackingInfo.distanceKm,
            'eta_minutes': trackingInfo.trackingInfo.etaMinutes,
          },
        };
        print('✅ Real tracking data loaded successfully');
      }

      if (trackingData == null) {
        throw Exception('Failed to load tracking data');
      }

      if (!mounted) return;

      setState(() {
        // User location
        final userLoc = trackingData!['user_location'];
        _userLocation = LatLng(userLoc['latitude'], userLoc['longitude']);

        // Mitra location (real-time)
        final mitraLoc = trackingData['mitra_location'];
        if (mitraLoc['latitude'] != null && mitraLoc['longitude'] != null) {
          _mitraLocation = LatLng(mitraLoc['latitude'], mitraLoc['longitude']);

          // Check if location is stale
          if (mitraLoc['last_update'] != null) {
            _lastMitraUpdate = DateTime.parse(mitraLoc['last_update']);
          }
          _isMitraLocationStale = mitraLoc['is_stale'] ?? false;
        }

        // Mitra info
        final mitraInfo = trackingData['mitra_info'];
        _mitraName = mitraInfo['name'];
        _mitraPhone = mitraInfo['phone'];

        // Distance & ETA
        final trackingInfo = trackingData['tracking_info'];
        _distanceKm = trackingInfo['distance_km'];
        _etaMinutes = trackingInfo['eta_minutes'];

        _isLoading = false;
        _errorMessage = null;
      });

      // Schedule camera animation after widget is built
      if (_userLocation != null && _mitraLocation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _animateCameraToShowBoth();
          }
        });
      }
    } catch (e) {
      print('❌ Error loading tracking data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Animate camera to show both user and mitra markers
  void _animateCameraToShowBoth() {
    if (_userLocation == null || _mitraLocation == null) return;

    try {
      // Calculate bounds
      final latitudes = [_userLocation!.latitude, _mitraLocation!.latitude];
      final longitudes = [_userLocation!.longitude, _mitraLocation!.longitude];

      final minLat = latitudes.reduce((a, b) => a < b ? a : b);
      final maxLat = latitudes.reduce((a, b) => a > b ? a : b);
      final minLng = longitudes.reduce((a, b) => a < b ? a : b);
      final maxLng = longitudes.reduce((a, b) => a > b ? a : b);

      final southWest = LatLng(minLat, minLng);
      final northEast = LatLng(maxLat, maxLng);

      // Add padding
      final bounds = LatLngBounds(southWest, northEast);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    } catch (e) {
      print('⚠️ Cannot animate camera yet (map not ready): $e');
      // Map will use initialCenter instead
    }
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
        const SnackBar(content: Text('Tidak dapat membuka dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Lacak Mitra'),
            if (USE_MOCK_TRACKING) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🎭 MOCK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: greenColor,
        foregroundColor: whiteColor,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null
          ? _buildErrorView()
          : _buildMapView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: greenColor),
          const SizedBox(height: 16),
          Text(
            'Memuat data tracking...',
            style: greyTextStyle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat tracking',
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadTrackingData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_userLocation == null) {
      return const Center(child: Text('Lokasi user tidak tersedia'));
    }

    return Stack(
      children: [
        // OpenStreetMap
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _userLocation!,
            initialZoom: 15,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            // Tile layer - OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.bank_sha',
            ),

            // Polyline (route) - jika mitra location tersedia
            if (_mitraLocation != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_userLocation!, _mitraLocation!],
                    strokeWidth: 4,
                    color: Colors.blue.withOpacity(0.7),
                  ),
                ],
              ),

            // Markers layer
            MarkerLayer(
              markers: [
                // User marker (blue)
                Marker(
                  point: _userLocation!,
                  width: 80,
                  height: 80,
                  child: _buildUserMarker(),
                ),

                // Mitra marker (green) - jika tersedia
                if (_mitraLocation != null)
                  Marker(
                    point: _mitraLocation!,
                    width: 80,
                    height: 80,
                    child: _buildMitraMarker(),
                  ),
              ],
            ),
          ],
        ),

        // Info card at bottom
        Positioned(left: 16, right: 16, bottom: 16, child: _buildInfoCard()),

        // Stale warning at top
        if (_isMitraLocationStale)
          Positioned(top: 16, left: 16, right: 16, child: _buildStaleWarning()),
      ],
    );
  }

  Widget _buildUserMarker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Anda',
            style: whiteTextStyle.copyWith(fontSize: 10, fontWeight: semiBold),
          ),
        ),
        const SizedBox(height: 4),
        Icon(Icons.location_on, color: Colors.blue[700], size: 40),
      ],
    );
  }

  Widget _buildMitraMarker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _mitraName ?? 'Mitra',
            style: whiteTextStyle.copyWith(fontSize: 10, fontWeight: semiBold),
          ),
        ),
        const SizedBox(height: 4),
        Icon(Icons.local_shipping, color: greenColor, size: 40),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mitra name
          Row(
            children: [
              Icon(Icons.person, color: greenColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _mitraName ?? 'Mitra',
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              if (_mitraPhone != null)
                IconButton(
                  onPressed: _callMitra,
                  icon: Icon(Icons.phone, color: greenColor),
                  tooltip: 'Hubungi Mitra',
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Distance & ETA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Distance
              Column(
                children: [
                  Icon(Icons.straighten, color: Colors.grey[600], size: 20),
                  const SizedBox(height: 4),
                  Text(
                    _distanceKm != null
                        ? '${_distanceKm!.toStringAsFixed(1)} km'
                        : 'N/A',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  Text('Jarak', style: greyTextStyle.copyWith(fontSize: 12)),
                ],
              ),

              Container(width: 1, height: 40, color: Colors.grey[300]),

              // ETA
              Column(
                children: [
                  Icon(Icons.schedule, color: Colors.grey[600], size: 20),
                  const SizedBox(height: 4),
                  Text(
                    _etaMinutes != null ? '~$_etaMinutes min' : 'N/A',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                  Text('Estimasi', style: greyTextStyle.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaleWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[800], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lokasi mitra terakhir diupdate ${_getTimeAgo()}',
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo() {
    if (_lastMitraUpdate == null) return 'tidak diketahui';

    final difference = DateTime.now().difference(_lastMitraUpdate!);
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return '${difference.inSeconds} detik yang lalu';
    }
  }
}
