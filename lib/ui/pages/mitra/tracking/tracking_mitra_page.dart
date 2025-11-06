import 'dart:async';
import 'package:bank_sha/models/tracking_model.dart';
import 'package:bank_sha/services/mitra_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class TrackingMitraPage extends StatefulWidget {
  final int scheduleId;
  final String customerName;
  final String customerAddress;

  const TrackingMitraPage({
    super.key,
    required this.scheduleId,
    required this.customerName,
    required this.customerAddress,
  });

  @override
  State<TrackingMitraPage> createState() => _TrackingMitraPageState();
}

class _TrackingMitraPageState extends State<TrackingMitraPage> {
  final MitraService _mitraService = MitraService();
  final Location _location = Location();
  final MapController _mapController = MapController();

  bool _isLoading = false;
  bool _isTracking = false;
  String? _errorMessage;
  LatLng _currentLocation = LatLng(0, 0);
  List<TrackingModel> _trackingHistory = [];
  Timer? _trackingTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocationService();
    _loadTrackingHistory();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Layanan lokasi tidak tersedia';
        });
        return;
      }
    }

    // Check if permission is granted
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _errorMessage = 'Izin lokasi tidak diberikan';
        });
        return;
      }
    }

    // Get current location
    try {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        if (mounted &&
            currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            _currentLocation = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
          });

          // Center map on current location if tracking is active
          if (_isTracking) {
            final currentZoom = _mapController.camera.zoom;
            _mapController.move(_currentLocation, currentZoom);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadTrackingHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trackingHistory = await _mitraService.getTrackingHistory(
        widget.scheduleId,
      );

      if (mounted) {
        setState(() {
          _trackingHistory = trackingHistory;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      // Stop tracking
      _trackingTimer?.cancel();
      setState(() {
        _isTracking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pelacakan dihentikan'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Start tracking
      await _submitTracking();

      // Set timer to submit tracking every 30 seconds
      _trackingTimer = Timer.periodic(const Duration(seconds: 30), (
        timer,
      ) async {
        await _submitTracking(showMessage: false);
      });

      setState(() {
        _isTracking = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pelacakan dimulai'),
          backgroundColor: greenColor,
        ),
      );
    }
  }

  Future<void> _submitTracking({bool showMessage = true}) async {
    if (_currentLocation.latitude == 0 && _currentLocation.longitude == 0) {
      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi belum tersedia'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      await _mitraService.submitTracking(
        scheduleId: widget.scheduleId,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        status: 'in_progress',
        notes: 'Update lokasi otomatis',
      );

      await _loadTrackingHistory();

      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi berhasil diperbarui'),
            backgroundColor: greenColor,
          ),
        );
      }
    } catch (e) {
      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui lokasi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Pelacakan'),
        backgroundColor: greenColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadTrackingHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTrackingHistory,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Map section
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation.latitude != 0
                          ? _currentLocation
                          : const LatLng(
                              -6.2088,
                              106.8456,
                            ), // Default to Jakarta
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          // Current location marker
                          if (_currentLocation.latitude != 0 &&
                              _currentLocation.longitude != 0)
                            Marker(
                              width: 40,
                              height: 40,
                              point: _currentLocation,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),

                          // Tracking history markers
                          ..._trackingHistory.map(
                            (tracking) => Marker(
                              width: 30,
                              height: 30,
                              point: tracking.location,
                              child: Icon(
                                Icons.location_history,
                                color: Colors.red.withOpacity(0.7),
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Customer info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: whiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pelanggan',
                        style: blackTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.customerName,
                              style: blackTextStyle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.customerAddress,
                              style: blackTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tracking history section
                Expanded(
                  flex: 2,
                  child: Container(
                    color: lightBackgroundColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Riwayat Lokasi',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: semiBold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _toggleTracking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isTracking
                                      ? Colors.orange
                                      : greenColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  _isTracking ? 'Berhenti' : 'Mulai Pelacakan',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _trackingHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    'Belum ada data pelacakan',
                                    style: greyTextStyle,
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _trackingHistory.length,
                                  itemBuilder: (context, index) {
                                    final tracking = _trackingHistory[index];
                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        leading: const Icon(
                                          Icons.location_history,
                                          color: Colors.blue,
                                        ),
                                        title: Text(
                                          'Lat: ${tracking.location.latitude.toStringAsFixed(4)}, Long: ${tracking.location.longitude.toStringAsFixed(4)}',
                                          style: blackTextStyle.copyWith(
                                            fontWeight: medium,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                'dd MMM yyyy, HH:mm:ss',
                                              ).format(tracking.timestamp),
                                              style: greyTextStyle.copyWith(
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (tracking.notes != null &&
                                                tracking.notes!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                tracking.notes!,
                                                style: greyTextStyle.copyWith(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        onTap: () {
                                          _mapController.move(
                                            tracking.location,
                                            16,
                                          );
                                        },
                                      ),
                                    );
                                  },
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
}
