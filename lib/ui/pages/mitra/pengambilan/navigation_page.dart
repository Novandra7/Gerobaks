import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_event.dart';
import 'package:bank_sha/blocs/tracking/tracking_state.dart';
import 'package:bank_sha/utils/navigation_helper.dart';
import 'package:bank_sha/services/tile_provider_service.dart';

class InAppNavigationPage extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const InAppNavigationPage({super.key, required this.scheduleData});

  @override
  State<InAppNavigationPage> createState() => _InAppNavigationPageState();
}

class _InAppNavigationPageState extends State<InAppNavigationPage>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  Timer? _locationUpdateTimer;
  bool _isNavigating = false;

  // Add memory optimization flags
  bool _isMapDisposed = false;
  final int _simulationStep = 3; // Skip points to reduce memory usage

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Register controller with helper
    NavigationHelper.registerController(_mapController);

    // Initialize the destination from schedule data
    // No need to extract lat/lng here as it's handled by TrackingBloc

    // Update the destination in the Tracking Bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TrackingBloc>().add(FetchRoute());

      // Start simulating location updates (in a real app, you'd use actual GPS)
      _startNavigationSimulation();
    });
  }

  @override
  void dispose() {
    if (_locationUpdateTimer != null) {
      _locationUpdateTimer!.cancel();
      NavigationHelper.unregisterTimer(_locationUpdateTimer!);
      _locationUpdateTimer = null;
    }
    _isMapDisposed = true;
    NavigationHelper.unregisterController(_mapController);
    _mapController.dispose();
    super.dispose();
  }

  void _startNavigationSimulation() {
    // Check if already navigating to prevent duplicate timers
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    // Use a longer interval to reduce processing frequency
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      // Check if widget is still mounted before proceeding
      if (!mounted || _isMapDisposed) {
        timer.cancel();
        NavigationHelper.unregisterTimer(timer);
        return;
      }

      try {
        final bloc = context.read<TrackingBloc>();
        final state = bloc.state;

        if (state.routePoints.isEmpty) return;

        // Optimize movement calculation - use binary search or predefined steps
        // instead of indexOf which is inefficient for large lists
        int currentIndex = _findClosestPointIndex(
          state.routePoints,
          state.truckPosition,
        );
        if (currentIndex < 0) currentIndex = 0;

        // Skip points to reduce update frequency (move faster along route)
        int nextIndex = currentIndex + _simulationStep; // Skip points each time
        if (nextIndex >= state.routePoints.length) {
          nextIndex = state.routePoints.length - 1;
        }

        if (currentIndex < state.routePoints.length - 1) {
          final nextPosition = state.routePoints[nextIndex];
          bloc.add(UpdateTruckLocation(nextPosition));

          // Only move map if necessary and not disposed
          if (!_isMapDisposed) {
            try {
              _mapController.move(nextPosition, _mapController.camera.zoom);
            } catch (e) {
              print('Error moving map: $e');
            }
          }
        } else if (currentIndex == state.routePoints.length - 1) {
          // Reached destination
          _locationUpdateTimer?.cancel();
          if (_locationUpdateTimer != null) {
            NavigationHelper.unregisterTimer(_locationUpdateTimer!);
          }
          _locationUpdateTimer = null;
          setState(() {
            _isNavigating = false;
          });

          // Show arrival notification
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Anda telah tiba di tujuan'),
                backgroundColor: greenColor,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Handle any exceptions to prevent crashes
        print('Error in navigation simulation: $e');
      }
    });

    // Register timer with helper
    if (_locationUpdateTimer != null) {
      NavigationHelper.registerTimer(_locationUpdateTimer!);
    }
  }

  Future<void> _openExternalMaps() async {
    final latitude = widget.scheduleData['latitude'];
    final longitude = widget.scheduleData['longitude'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Aplikasi Navigasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.map, color: greenColor),
              title: const Text('Google Maps'),
              onTap: () async {
                Navigator.pop(context);
                final Uri googleMapsUri = Uri.parse(
                  'google.navigation:q=$latitude,$longitude',
                );

                if (await canLaunchUrl(googleMapsUri)) {
                  await launchUrl(
                    googleMapsUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  final fallbackUri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
                  );
                  await launchUrl(
                    fallbackUri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car, color: greenColor),
              title: const Text('Waze'),
              onTap: () async {
                Navigator.pop(context);
                final Uri wazeUri = Uri.parse(
                  'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes',
                );

                if (await canLaunchUrl(wazeUri)) {
                  await launchUrl(
                    wazeUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Aplikasi Waze tidak ditemukan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: greenColor),
              title: const Text('Maps Lainnya'),
              onTap: () async {
                Navigator.pop(context);
                final Uri fallbackUri = Uri.parse(
                  'https://www.openstreetmap.org/directions?from=&to=$latitude%2C$longitude',
                );

                if (await canLaunchUrl(fallbackUri)) {
                  await launchUrl(
                    fallbackUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tidak dapat membuka aplikasi peta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  // Helper method to find closest point in route without using indexOf
  int _findClosestPointIndex(List<LatLng> points, LatLng position) {
    if (points.isEmpty) return -1;

    // Optimize by checking fewer points
    double minDistance = double.infinity;
    int closestIndex = 0;

    // Only check every 10th point to improve performance significantly
    for (int i = 0; i < points.length; i += 10) {
      final distance = _calculateDistance(points[i], position);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  // Calculate distance between two points
  double _calculateDistance(LatLng p1, LatLng p2) {
    return (p1.latitude - p2.latitude) * (p1.latitude - p2.latitude) +
        (p1.longitude - p2.longitude) * (p1.longitude - p2.longitude);
  }

  // Reduce the number of points in the route to improve performance
  List<LatLng> _reduceRoutePoints(List<LatLng> points) {
    if (points.length <= 100)
      return points; // Don't reduce if already small enough

    // Take every nth point to reduce total count
    final int step = (points.length / 100).ceil(); // Aim for ~100 points
    return [for (int i = 0; i < points.length; i += step) points[i]];
  }

  // Helper method to handle customer calls (used in Frame181 widget via callback)
  void _callCustomerFromUI() async {
    final phone = widget.scheduleData['phone'];
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nomor telepon tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri telUri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat melakukan panggilan ke $phone'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Navigasi ke Pelanggan',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: blackColor),
        actions: [
          IconButton(
            icon: Icon(Icons.navigation_rounded, color: greenColor),
            onPressed: _openExternalMaps,
            tooltip: 'Buka di aplikasi maps lain',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TrackingBloc, TrackingState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: greenColor),
                  );
                }

                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: redcolor, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat rute: ${state.error}',
                          style: blackTextStyle.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TrackingBloc>().add(FetchRoute());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Coba Lagi',
                            style: whiteTextStyle.copyWith(fontWeight: medium),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: state.truckPosition,
                    initialZoom: 16.0,
                    minZoom: 12.0,
                    maxZoom: 18.0,
                    // Optimize for performance
                    keepAlive: true,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.gerobaks.app',
                      // Add caching to reduce network requests
                      tileProvider:
                          TileProviderService().cachedTileProvider ??
                          NetworkTileProvider(), // Fallback to network provider if cache isn't initialized
                      evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                      maxZoom: 18,
                      minZoom: 12,
                      // Optimize further with anti-aliasing turned off
                      tileBuilder: (context, widget, tile) {
                        return widget;
                      },
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          // Use reduced set of points for better performance
                          points: _reduceRoutePoints(state.routePoints),
                          strokeWidth: 5.0,
                          color: greenColor.withOpacity(0.7),
                          // Add rounded corners for better appearance
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                      ],
                    ),

                    MarkerLayer(
                      markers: [
                        // Use just two markers to reduce memory usage
                        // Truck marker (current location)
                        Marker(
                          point: state.truckPosition,
                          width: 40,
                          height: 40,
                          child: Transform.rotate(
                            angle: (state.truckBearing * (3.14159 / 180)),
                            child: Icon(
                              Icons.navigation,
                              color: greenColor,
                              size: 28,
                            ),
                          ),
                        ),
                        // Destination marker
                        Marker(
                          point: state.destination,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: redcolor,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          _buildCustomerInfoCard(),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _isNavigating && !_isMapDisposed
            ? FloatingActionButton(
                key: const ValueKey('nav_fab'),
                onPressed: () {
                  // Re-center map on truck
                  try {
                    if (!mounted || _isMapDisposed) return;

                    final truckPosition = context
                        .read<TrackingBloc>()
                        .state
                        .truckPosition;

                    _mapController.move(truckPosition, 16.0);
                  } catch (e) {
                    print('Error centering map: $e');
                  }
                },
                backgroundColor: greenColor,
                child: const Icon(Icons.my_location),
              )
            : const SizedBox.shrink(),
      ),
      resizeToAvoidBottomInset: false, // Prevent keyboard from causing reflows
    );
  }

  Widget _buildCustomerInfoCard() {
    final data = widget.scheduleData;
    final customerName = data['customer_name'] ?? 'Pelanggan';
    final address = data['address'] ?? 'Alamat tidak tersedia';
    final time = data['time'] ?? '00:00 - 00:00';
    final wasteType = data['waste_type'] ?? 'Organik';
    final wasteWeight = data['waste_weight'] ?? '0 kg';

    // Use simpler widget structure to reduce memory usage
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and status - simplified
          Row(
            children: [
              Icon(Icons.access_time, color: const Color(0xFF4B4003), size: 18),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  color: const Color(0xFF4B4003),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Menuju Lokasi',
                style: TextStyle(
                  color: const Color(0xFF4B4003),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Customer info - simplified
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5BC487),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Tags and call button row - simplified
                Row(
                  children: [
                    // Waste type tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF69C28E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        wasteType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Weight tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6AC28E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        wasteWeight,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Call button
                    GestureDetector(
                      onTap: _callCustomerFromUI,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6AC28E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              'Hubungi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
