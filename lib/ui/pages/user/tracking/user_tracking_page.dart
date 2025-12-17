import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bank_sha/models/tracking/tracking_models.dart';
import 'package:bank_sha/services/realtime_tracking_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

/// Halaman tracking real-time untuk User melihat posisi Mitra
///
/// Features:
/// - Google Maps dengan 2 markers (User & Mitra)
/// - Real-time update setiap 5 detik
/// - Tampilan jarak dan ETA
/// - Polyline route antara User dan Mitra
/// - Tombol telepon ke Mitra
class UserTrackingPage extends StatefulWidget {
  final int pickupScheduleId;
  final String mitraName;
  final String mitraPhone;

  const UserTrackingPage({
    super.key,
    required this.pickupScheduleId,
    required this.mitraName,
    required this.mitraPhone,
  });

  @override
  State<UserTrackingPage> createState() => _UserTrackingPageState();
}

class _UserTrackingPageState extends State<UserTrackingPage> {
  final RealTimeTrackingService _trackingService = RealTimeTrackingService();
  final Logger _logger = Logger();

  GoogleMapController? _mapController;
  Timer? _pollingTimer;

  TrackingInfoModel? _trackingInfo;
  bool _isLoading = true;
  String? _errorMessage;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Start polling tracking info setiap 5 detik
  void _startPolling() {
    // Fetch immediately
    _fetchTrackingInfo();

    // Then poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchTrackingInfo();
    });
  }

  /// Fetch tracking info from backend
  Future<void> _fetchTrackingInfo() async {
    try {
      final trackingInfo = await _trackingService.getUserTrackingInfo(
        widget.pickupScheduleId,
      );

      if (trackingInfo != null) {
        setState(() {
          _trackingInfo = trackingInfo;
          _isLoading = false;
          _errorMessage = null;
          _updateMap();
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal mendapatkan informasi tracking';
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error fetching tracking info: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  /// Update map markers and polyline
  void _updateMap() {
    if (_trackingInfo == null) return;

    _markers.clear();
    _polylines.clear();

    // User marker (blue)
    final userLatLng = LatLng(
      _trackingInfo!.userLocation.latitude,
      _trackingInfo!.userLocation.longitude,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Lokasi Anda',
          snippet: _trackingInfo!.userLocation.address,
        ),
      ),
    );

    // Mitra marker (green) - only if location available
    if (_trackingInfo!.hasValidMitraLocation) {
      final mitraLatLng = LatLng(
        _trackingInfo!.mitraLocation.latitude!,
        _trackingInfo!.mitraLocation.longitude!,
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('mitra'),
          position: mitraLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: widget.mitraName,
            snippet: 'Mitra sedang menuju lokasi Anda',
          ),
        ),
      );

      // Draw polyline between user and mitra
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [userLatLng, mitraLatLng],
          color: purpleColor,
          width: 4,
          geodesic: true,
        ),
      );

      // Adjust camera to show both markers
      _fitBounds(userLatLng, mitraLatLng);
    } else {
      // Only show user location
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15));
    }
  }

  /// Fit bounds to show both markers
  void _fitBounds(LatLng point1, LatLng point2) {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        point1.latitude < point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude < point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
      northeast: LatLng(
        point1.latitude > point2.latitude ? point1.latitude : point2.latitude,
        point1.longitude > point2.longitude
            ? point1.longitude
            : point2.longitude,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  /// Call mitra
  Future<void> _callMitra() async {
    final phoneUrl = Uri.parse('tel:${widget.mitraPhone}');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracking ${widget.mitraName}',
          style: whiteTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: purpleColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTrackingInfo,
            tooltip: 'Refresh',
          ),
          // Call button
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _callMitra,
            tooltip: 'Telepon Mitra',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildTrackingView(),
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
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: blackTextStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchTrackingInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingView() {
    return Stack(
      children: [
        // Google Maps
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              _trackingInfo!.userLocation.latitude,
              _trackingInfo!.userLocation.longitude,
            ),
            zoom: 15,
          ),
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            _updateMap();
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
        ),

        // Info card at bottom
        Positioned(bottom: 0, left: 0, right: 0, child: _buildInfoCard()),
      ],
    );
  }

  Widget _buildInfoCard() {
    if (_trackingInfo == null) return const SizedBox.shrink();

    final trackingInfo = _trackingInfo!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mitra info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: purpleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.person, color: purpleColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mitraName,
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(trackingInfo.status),
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Phone icon button
              IconButton(
                onPressed: _callMitra,
                icon: Icon(Icons.phone, color: purpleColor),
                style: IconButton.styleFrom(
                  backgroundColor: purpleColor.withOpacity(0.1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Distance and ETA
          if (trackingInfo.hasValidMitraLocation) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.straighten,
                    label: 'Jarak',
                    value: trackingInfo.trackingInfo.formattedDistance,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: greyColor.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.schedule,
                    label: 'Estimasi Tiba',
                    value: trackingInfo.trackingInfo.formattedEta,
                  ),
                ),
              ],
            ),

            // Location stale warning
            if (trackingInfo.mitraLocation.isStale) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lokasi mitra terakhir diupdate lebih dari 30 detik yang lalu',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // No mitra location
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: greyColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menunggu lokasi mitra...',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: purpleColor, size: 24),
        const SizedBox(height: 8),
        Text(label, style: greyTextStyle.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'on_the_way':
        return '🚛 Dalam perjalanan';
      case 'arrived':
        return '📍 Sudah tiba';
      default:
        return status;
    }
  }
}
