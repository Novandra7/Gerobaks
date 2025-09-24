import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_event.dart';
import 'package:bank_sha/blocs/tracking/tracking_state.dart';
import 'package:bank_sha/utils/navigation_helper.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
// import 'package:bank_sha/services/tile_provider_service.dart';

class NavigationPageRedesigned extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const NavigationPageRedesigned({super.key, required this.scheduleData});

  @override
  State<NavigationPageRedesigned> createState() =>
      _NavigationPageRedesignedState();
}

class _NavigationPageRedesignedState extends State<NavigationPageRedesigned>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  double _cardOffset = 0.0;
  final double _minCardHeight = 140;
  final double _maxCardHeight = 360;
  bool _isDragging = false;
  bool _isMapReady = false;
  bool _isSyncingLocation = false;
  Timer? _locationUpdateTimer;
  double _zoomLevel = 15.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    NavigationHelper.registerController(_mapController);

    _startLocationUpdates();

    // Initialize the map with routes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Set destination from scheduleData
      if (widget.scheduleData.containsKey('latitude') && 
          widget.scheduleData.containsKey('longitude')) {
        final double lat = double.tryParse(widget.scheduleData['latitude'].toString()) ?? -0.5028797174108289;
        final double lng = double.tryParse(widget.scheduleData['longitude'].toString()) ?? 117.15020096577763;
        
        // Update destination in the TrackingBloc
        context.read<TrackingBloc>().add(
          UpdateDestination(LatLng(lat, lng))
        );
      }
      
      context.read<TrackingBloc>().add(FetchRoute());
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan',
          ),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Pengaturan',
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    _syncCurrentLocation();
  }

  void _startLocationUpdates() {
    // Update location every 5 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _syncCurrentLocation();
    });

    NavigationHelper.registerTimer(_locationUpdateTimer!);
  }

  Future<void> _syncCurrentLocation() async {
    if (_isSyncingLocation) return;

    setState(() {
      _isSyncingLocation = true;
    });

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      // Update truck position in the bloc
      if (mounted) {
        context.read<TrackingBloc>().add(UpdateTruckLocation(currentLocation));

        // Center map on current position if map is ready
        if (_isMapReady) {
          _mapController.move(currentLocation, _zoomLevel);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingLocation = false;
        });
      }
    }
  }

  Future<void> _openExternalNavigation(String type) async {
    final TrackingState state = context.read<TrackingBloc>().state;
    final double destLat = state.destination.latitude;
    final double destLng = state.destination.longitude;

    String url;

    switch (type) {
      case 'google_maps':
        url =
            'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving';
        break;
      case 'waze':
        url = 'https://waze.com/ul?ll=$destLat,$destLng&navigate=yes';
        break;
      case 'apple_maps':
        url = 'http://maps.apple.com/?daddr=$destLat,$destLng&dirflg=d';
        break;
      default:
        url =
            'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka aplikasi navigasi')),
        );
      }
    }
  }

  void _showExternalNavSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buka Navigasi di',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavAppChip(
                    label: 'Google Maps',
                    icon: Icons.map,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(ctx);
                      _openExternalNavigation('google_maps');
                    },
                  ),
                  _NavAppChip(
                    label: 'Waze',
                    icon: Icons.navigation,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(ctx);
                      _openExternalNavigation('waze');
                    },
                  ),
                  _NavAppChip(
                    label: 'Apple Maps',
                    icon: Icons.map_outlined,
                    color: Colors.black87,
                    onTap: () {
                      Navigator.pop(ctx);
                      _openExternalNavigation('apple_maps');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double screenWidth = media.size.width;
    final double cardHeight = _minCardHeight + _cardOffset;
    final double maxDrag = _maxCardHeight - _minCardHeight;
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final double buttonSize = isSmallScreen ? 40.0 : 50.0;
    final double iconSize = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Gradient header with rounded bottom corners (Figma-inspired)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _HeaderBar(
                    plateNumber: (widget.scheduleData['plate'] ?? 'KT 777 WAN')
                        .toString(),
                    driverCode:
                        (widget.scheduleData['driverCode'] ?? 'DRV-KTM-214')
                            .toString(),
                    statusTitle:
                        (widget.scheduleData['statusTitle'] ??
                                'Menuju Pengambilan')
                            .toString(),
                    rtLabel: (widget.scheduleData['rt'] ?? 'RT 15').toString(),
                    onBack: () => Navigator.pop(context),
                    onOpenExternalNavigation: _openExternalNavigation,
                  ),
                ),
              ),
              // Map view with actual implementation
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: state.truckPosition,
                    initialZoom: _zoomLevel,
                    minZoom: 3,
                    maxZoom: 18,
                    onMapReady: () {
                      setState(() {
                        _isMapReady = true;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.gerobaks.app',
                    ),
                    // Only show polyline layer if we have route points
                    if (state.routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: state.routePoints,
                            color: greenColor,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // Destination marker
                        Marker(
                          point: state.destination,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // Truck marker with rotation
                        Marker(
                          point: state.truckPosition,
                          child: Transform.rotate(
                            angle: state.truckBearing * (3.14159265359 / 180),
                            child: Icon(
                              Icons.local_shipping,
                              color: greenColor,
                              size: 35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation controls (zoom & current location)
              Positioned(
                right: 16,
                bottom: cardHeight + 16,
                child: Column(
                  children: [
                    // Zoom controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: buttonSize,
                            width: buttonSize,
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                size: iconSize,
                                color: greenColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _zoomLevel = (_zoomLevel + 1).clamp(
                                    3.0,
                                    18.0,
                                  );
                                  if (_isMapReady) {
                                    _mapController.move(
                                      _mapController.camera.center,
                                      _zoomLevel,
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200],
                          ),
                          SizedBox(
                            height: buttonSize,
                            width: buttonSize,
                            child: IconButton(
                              icon: Icon(
                                Icons.remove,
                                size: iconSize,
                                color: greenColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _zoomLevel = (_zoomLevel - 1).clamp(
                                    3.0,
                                    18.0,
                                  );
                                  if (_isMapReady) {
                                    _mapController.move(
                                      _mapController.camera.center,
                                      _zoomLevel,
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Current location button
                    Container(
                      height: buttonSize,
                      width: buttonSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.my_location,
                          size: iconSize,
                          color: _isSyncingLocation ? Colors.blue : greenColor,
                        ),
                        onPressed: _syncCurrentLocation,
                      ),
                    ),
                  ],
                ),
              ),

              // Left-side prominent actions: Sinkron Lokasi Saya & Buka Navigasi
              Positioned(
                left: 16,
                bottom: cardHeight + 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: greenColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _requestLocationPermission,
                        icon: _isSyncingLocation
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: greenColor,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _isSyncingLocation
                              ? 'Menyinkronkan…'
                              : 'Sinkron Lokasi Saya',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showExternalNavSheet,
                        icon: const Icon(Icons.directions),
                        label: const Text(
                          'Buka Navigasi',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // (Optional) External navigation entry accessible via long-press on status
              // Kept minimal for MVP and to match the provided visual design

              // Draggable Card with customer info
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _isDragging = true;
                      _cardOffset = (_cardOffset - details.delta.dy).clamp(
                        0,
                        maxDrag,
                      );
                    });
                  },
                  onVerticalDragEnd: (details) {
                    setState(() {
                      _isDragging = false;
                      // Snap to min or max
                      if (_cardOffset > maxDrag / 2) {
                        _cardOffset = maxDrag;
                      } else {
                        _cardOffset = 0;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: _isDragging ? 0 : 250),
                    curve: Curves.easeOut,
                    height: cardHeight,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          const Color(0xFFB6F0C2).withOpacity(0.5),
                          const Color(0xFF6EDC8A).withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: _buildCustomerInfoCard(context),
                  ),
                ),
              ),

              // Loading indicator
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  // External navigation buttons removed from header to align with Figma layout.

  Widget _buildCustomerInfoCard(BuildContext context) {
    // Get customer data from schedule
    final customerName = widget.scheduleData['customerName'] ?? 'Wahyu Indra';
    final customerAddress =
        widget.scheduleData['address'] ??
        'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur';
    final wasteType = widget.scheduleData['wasteType'] ?? 'Organik';
    final wasteWeight = widget.scheduleData['wasteWeight'] ?? '2 Kg';
    final timeSlot = widget.scheduleData['timeSlot'] ?? '09:00 - 11:00';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Time and status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded, color: blackColor, size: 22),
                  SizedBox(width: 8),
                  Text(
                    timeSlot,
                    style: blackTextStyle.copyWith(
                      fontWeight: semiBold,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF9E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFECDC7F), width: 1),
                ),
                child: Text(
                  'Menuju Lokasi',
                  style: TextStyle(
                    fontWeight: semiBold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: Color(0xFF7A6F1A),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Customer info card (Figma-inspired bottom sheet)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // Three-stop gradient per Figma style
                gradient: LinearGradient(
                  begin: Alignment(0.13, 0.09),
                  end: Alignment(0.36, 1.79),
                  colors: const [
                    Color(0xFF5BC487),
                    Color(0xFF54C07F),
                    Color(0xFF45C375),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6EDC8A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.recycling,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer avatar
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Color(0xFF4CBC6C),
                                ),
                              ),
                              SizedBox(width: 16),

                            // Customer info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          customerName,
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveHelper.getResponsiveFontSize(
                                                  context,
                                                  20,
                                                ),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      IconButton(
                                        icon: Icon(
                                          Icons.content_copy,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          // Copy customer name to clipboard
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    customerAddress,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            14,
                                          ),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Single CTA chip (MVP) - Hubungi Pelanggan
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF6AC28E),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0.7,
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Hubungi Pelanggan',
                              style: TextStyle(
                                color: const Color(0xFFF9FFF8),
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      10,
                                    ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Waste info
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(wasteType),
                            _buildChip(wasteWeight),
                            _buildChip(
                              'Sampah Rumah Tangga',
                              icon: Icons.home_outlined,
                            ),
                          ],
                        ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed action buttons row to align with Figma MVP; single CTA provided instead.

  Widget _buildChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_locationUpdateTimer != null) {
      _locationUpdateTimer!.cancel();
      NavigationHelper.unregisterTimer(_locationUpdateTimer!);
      _locationUpdateTimer = null;
    }
    NavigationHelper.unregisterController(_mapController);
    _mapController.dispose();
    super.dispose();
  }
}

/// Figma-inspired header bar with gradient and rounded bottom corners
class _HeaderBar extends StatelessWidget {
  final String plateNumber;
  final String driverCode;
  final String statusTitle;
  final String rtLabel;
  final VoidCallback onBack;
  final void Function(String app) onOpenExternalNavigation;

  const _HeaderBar({
    required this.plateNumber,
    required this.driverCode,
    required this.statusTitle,
    required this.rtLabel,
    required this.onBack,
    required this.onOpenExternalNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final headerHeight = 144.0; // base from Figma; works responsively by width

    return Stack(
      children: [
        // Gradient background with round bottom corners
        Container(
          width: width,
          height: paddingTop + headerHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, -0.00),
              end: Alignment(0.50, 1.00),
              colors: [Color(0xFF12A448), Color(0xFF58BA89)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100),
              bottomRight: Radius.circular(100),
            ),
          ),
        ),

        // Content layer
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: paddingTop + 16, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Back button placeholder area from Figma (empty container replaced with button)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Plate number
                    Expanded(
                      child: Text(
                        plateNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          height: 1.57,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Driver code
                    Text(
                      driverCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.57,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status title
                Center(
                  child: Text(
                    statusTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF4F4F4),
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // RT Chip and external navigation menu trigger
                Center(
                  child: GestureDetector(
                    onLongPress: () => _showExternalNavSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0x99E4F9DF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            rtLabel,
                            style: const TextStyle(
                              color: Color(0xFFF4F4F4),
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              height: 1.83,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showExternalNavSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buka Navigasi di',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavAppChip(
                    label: 'Google Maps',
                    icon: Icons.map,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(ctx);
                      onOpenExternalNavigation('google_maps');
                    },
                  ),
                  _NavAppChip(
                    label: 'Waze',
                    icon: Icons.navigation,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(ctx);
                      onOpenExternalNavigation('waze');
                    },
                  ),
                  _NavAppChip(
                    label: 'Apple Maps',
                    icon: Icons.map_outlined,
                    color: Colors.black87,
                    onTap: () {
                      Navigator.pop(ctx);
                      onOpenExternalNavigation('apple_maps');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavAppChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _NavAppChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
