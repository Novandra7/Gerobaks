import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bank_sha/services/tracking_api_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen untuk User tracking lokasi Mitra real-time (New GPS API)
/// - Polling setiap 10 detik ke GET /api/user/tracking/{schedule_id}
/// - Tampilkan 2 markers: user & mitra
/// - Info distance & ETA dari backend
/// - Call/WA button
class UserGpsTrackingPage extends StatefulWidget {
  final int scheduleId;

  const UserGpsTrackingPage({super.key, required this.scheduleId});

  @override
  State<UserGpsTrackingPage> createState() => _UserGpsTrackingPageState();
}

class _UserGpsTrackingPageState extends State<UserGpsTrackingPage> {
  final TrackingApiService _trackingApi = TrackingApiService();

  GoogleMapController? _mapController;
  Timer? _pollingTimer;
  Map<String, dynamic>? _trackingData;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Start polling setiap 10 detik
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchTrackingData(showLoading: false);
      }
    });
  }

  /// Fetch tracking data dari API
  Future<void> _fetchTrackingData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final data = await _trackingApi.getTrackingData(widget.scheduleId);

      if (mounted) {
        setState(() {
          _trackingData = data;
          _isLoading = false;
          _hasError = false;
          _updateMarkers();
        });

        // Update camera untuk fit both markers
        _fitMapToMarkers();
      }
    } catch (e) {
      print('❌ Error fetching tracking data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Update markers di map
  void _updateMarkers() {
    if (_trackingData == null) return;

    _markers.clear();

    // Marker untuk user location
    final userLoc = _trackingData!['user_location'];
    if (userLoc != null &&
        userLoc['latitude'] != null &&
        userLoc['longitude'] != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(userLoc['latitude'], userLoc['longitude']),
          infoWindow: InfoWindow(
            title: 'Lokasi Anda',
            snippet: userLoc['address'] ?? '',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Marker untuk mitra location (jika ada)
    final mitraLoc = _trackingData!['mitra_location'];
    if (mitraLoc != null &&
        mitraLoc['latitude'] != null &&
        mitraLoc['longitude'] != null) {
      final mitraInfo = _trackingData!['mitra'];
      _markers.add(
        Marker(
          markerId: const MarkerId('mitra'),
          position: LatLng(mitraLoc['latitude'], mitraLoc['longitude']),
          infoWindow: InfoWindow(
            title: mitraInfo?['name'] ?? 'Mitra',
            snippet:
                'ETA: ${_trackingData!['estimated_arrival_minutes']} menit',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    setState(() {});
  }

  /// Fit map camera untuk show both markers
  void _fitMapToMarkers() {
    if (_markers.length < 2 || _mapController == null) return;

    final userLoc = _trackingData!['user_location'];
    final mitraLoc = _trackingData!['mitra_location'];

    if (userLoc == null || mitraLoc == null) return;

    final userLat = userLoc['latitude'];
    final userLng = userLoc['longitude'];
    final mitraLat = mitraLoc['latitude'];
    final mitraLng = mitraLoc['longitude'];

    if (userLat == null ||
        userLng == null ||
        mitraLat == null ||
        mitraLng == null)
      return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        userLat < mitraLat ? userLat : mitraLat,
        userLng < mitraLng ? userLng : mitraLng,
      ),
      northeast: LatLng(
        userLat > mitraLat ? userLat : mitraLat,
        userLng > mitraLng ? userLng : mitraLng,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  /// Launch phone call
  Future<void> _callMitra() async {
    final mitra = _trackingData?['mitra'];
    if (mitra == null || mitra['phone'] == null) return;

    final phone = mitra['phone'].toString();
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat melakukan panggilan')),
        );
      }
    }
  }

  /// Launch WhatsApp
  Future<void> _whatsappMitra() async {
    final mitra = _trackingData?['mitra'];
    if (mitra == null || mitra['phone'] == null) return;

    String phone = mitra['phone'].toString().replaceAll(RegExp(r'[^0-9]'), '');

    // Add country code jika belum ada (Indonesia: 62)
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (!phone.startsWith('62')) {
      phone = '62$phone';
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Mitra'),
        backgroundColor: greenColor,
        actions: [
          if (_trackingData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _fetchTrackingData(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _trackingData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _trackingData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Gagal memuat tracking data'),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTrackingData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_trackingData == null) {
      return const Center(child: Text('Tidak ada data tracking'));
    }

    final userLoc = _trackingData!['user_location'];

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
            _fitMapToMarkers();
          },
          initialCameraPosition: CameraPosition(
            target: userLoc != null
                ? LatLng(
                    userLoc['latitude'] ?? -6.2088,
                    userLoc['longitude'] ?? 106.8456,
                  )
                : const LatLng(-6.2088, 106.8456), // Default Jakarta
            zoom: 14,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
        ),

        // Info card
        Positioned(top: 16, left: 16, right: 16, child: _buildInfoCard()),

        // Bottom actions
        if (_trackingData!['mitra'] != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildActionButtons(),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final mitra = _trackingData!['mitra'];
    final mitraLoc = _trackingData!['mitra_location'];
    final status = _trackingData!['status'];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mitra info
            if (mitra != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: greenColor,
                    child: Text(
                      mitra['name']?[0] ?? 'M',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mitra['name'] ?? 'Mitra',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mitra['vehicle_plate'] != null)
                          Text(
                            'Plat: ${mitra['vehicle_plate']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
            ],

            // Location status
            if (mitraLoc != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _trackingApi.formatDistance(
                          _trackingData!['distance_km'] ?? 0.0,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _trackingApi.formatETA(
                          _trackingData!['estimated_arrival_minutes'] ?? 0,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    mitraLoc['is_active'] == true
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 12,
                    color: mitraLoc['is_active'] == true
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      mitraLoc['is_active'] == true
                          ? 'Mitra aktif'
                          : 'Lokasi terakhir: ${mitraLoc['last_update']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.location_off, size: 18, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menunggu lokasi GPS mitra...',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],

            // Status badge
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Call button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _callMitra,
            icon: const Icon(Icons.phone),
            label: const Text('Telepon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // WhatsApp button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _whatsappMitra,
            icon: const Icon(Icons.chat),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'on_the_way':
        return Colors.blue;
      case 'arrived':
        return Colors.green;
      case 'completed':
        return const Color(0xFF00A643);
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'on_the_way':
        return '🚚 Dalam Perjalanan';
      case 'arrived':
        return '📍 Sudah Tiba';
      case 'completed':
        return '✅ Selesai';
      case 'accepted':
        return '⏳ Menunggu';
      default:
        return status ?? 'Unknown';
    }
  }
}
