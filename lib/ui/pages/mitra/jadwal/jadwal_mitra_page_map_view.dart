import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_api_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/detail_pickup.dart';
import 'package:bank_sha/utils/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/date_symbol_data_local.dart';

class JadwalMitraMapView extends StatefulWidget {
  final String? scheduleId;

  const JadwalMitraMapView({super.key, this.scheduleId});

  @override
  State<JadwalMitraMapView> createState() => _JadwalMitraMapViewState();
}

class _JadwalMitraMapViewState extends State<JadwalMitraMapView>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String? _driverId;
  bool _isLoading = false;
  final String _selectedFilter =
      "semua"; // Filter options: semua, pending, in_progress, completed
  final ScheduleApiService _scheduleApiService = ScheduleApiService();
  List<ScheduleApiModel> _schedules = [];
  String? _errorMessage;
  final MapController _mapController = MapController();
  int _selectedCardIndex = -1; // Index of the selected schedule card
  late PageController _pageController;
  final Set<int> _updatingScheduleIds = <int>{};

  // Service area polygon coordinates
  final List<LatLng> _serviceAreaPolygon = [
    LatLng(-0.502473, 117.148738),
    LatLng(-0.503042, 117.148523),
    LatLng(-0.503959, 117.151090),
    LatLng(-0.503240, 117.151347),
  ];

  // Initial map center position
  LatLng _mapCenter = LatLng(-0.5035, 117.1500);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);

    // Initialize
    _initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await initializeDateFormatting("id_ID", null);

      // Ambil ID driver dari local storage
      final LocalStorageService localStorageService =
          await LocalStorageService.getInstance();
      final userData = await localStorageService.getUserData();

      if (userData != null && userData["id"] != null) {
        _driverId = userData["id"].toString();
      } else {
        throw Exception("ID driver tidak ditemukan");
      }

      // Load schedules
      await _loadSchedules();

      // If we have a specific scheduleId, select the corresponding card
      if (widget.scheduleId != null) {
        final schedules = _getFilteredSchedules();
        for (int i = 0; i < schedules.length; i++) {
          if (schedules[i].id.toString() == widget.scheduleId) {
            setState(() {
              _selectedCardIndex = i;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              final lat = schedules[i].latitude;
              final lng = schedules[i].longitude;
              if (lat != null && lng != null) {
                _mapController.move(LatLng(lat, lng), 16.0);
              }
            });
            break;
          }
        }
      }
    } catch (e) {
      // Tampilkan error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat jadwal: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 80),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSchedules() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final driverId = int.tryParse(_driverId ?? '');
      final result = await _scheduleApiService.listSchedules(
        assignedTo: driverId,
        perPage: 100,
      );

      final schedules = List<ScheduleApiModel>.from(result.items)
        ..sort((a, b) {
          final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });

      if (widget.scheduleId == null) {
        _selectedCardIndex = -1;
      }

      if (mounted) {
        setState(() {
          _schedules = schedules;
        });
        _adjustMapBounds(schedules);
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat jadwal: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 80),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to adjust map bounds to include all pickup locations
  void _adjustMapBounds([List<ScheduleApiModel>? source]) {
    final schedules = List<ScheduleApiModel>.from(
      (source ?? _getFilteredSchedules()).where(
        (schedule) => schedule.latitude != null && schedule.longitude != null,
      ),
    );
    if (schedules.isEmpty) return;

    double minLat = schedules.first.latitude!;
    double maxLat = schedules.first.latitude!;
    double minLng = schedules.first.longitude!;
    double maxLng = schedules.first.longitude!;

    for (final schedule in schedules) {
      final lat = schedule.latitude!;
      final lng = schedule.longitude!;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final latPadding = ((maxLat - minLat).abs()).clamp(0.001, 0.01);
    final lngPadding = ((maxLng - minLng).abs()).clamp(0.001, 0.01);

    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    _mapCenter = LatLng(centerLat, centerLng);

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_mapCenter, 15.0);
      });
    }
  }

  void _navigateToLocation(LatLng location) {
    // Open maps navigation using MapUtils
    MapUtils.openMapsNavigation(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: Column(
        children: [
          // Custom Header matching the design
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF37DE7A), Color(0xFF00A643)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                transform: GradientRotation(0.2),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00A643).withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top bar with logo and notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Image.asset(
                          'assets/ic_truck.png',
                          width: 32,
                          height: 32,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'GEROBAKS',
                          style: whiteTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    // Notification and chat icons
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to chat
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            // Navigate to notifications
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Jadwal Pengambilan Text
                Text(
                  'Jadwal Pengambilan',
                  style: whiteTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                // Date indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Hari ini, ${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}",
                    style: whiteTextStyle.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Body content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: greenColor))
                : _buildBody(),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  Widget _buildBody() {
    final schedules = _getFilteredSchedules();

    return Column(
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Gagal memuat jadwal. Tarik ke bawah untuk mencoba lagi.',
                style: blackTextStyle.copyWith(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: medium,
                ),
              ),
            ),
          ),
        // Map View with Service Area - Full screen
        Expanded(
          child: Stack(
            children: [
              // Map with full screen
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _mapCenter,
                  initialZoom: 16.0,
                  onTap: (tapPosition, point) {
                    // Reset selected card when tapping on map
                    setState(() {
                      _selectedCardIndex = -1;
                    });
                  },
                ),
                children: [
                  // Base map layer
                  TileLayer(
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                    subdomains: const ["a", "b", "c", "d"],
                    userAgentPackageName: "com.gerobaks.app",
                  ),

                  // Service area polygon
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _serviceAreaPolygon,
                        color: greenColor.withOpacity(0.2),
                        borderColor: greenColor,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),

                  // Pickup location markers
                  MarkerLayer(markers: _buildMarkers(schedules)),
                ],
              ),

              // Map control buttons
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  children: [
                    _buildMapControlButton(
                      icon: Icons.refresh,
                      onTap: () => _loadSchedules(),
                    ),
                    SizedBox(height: 8),
                    // Full screen button
                    _buildMapControlButton(
                      icon: Icons.fullscreen,
                      onTap: () {
                        // Toggle full screen
                      },
                    ),
                    SizedBox(height: 8),
                    // Zoom in button
                    _buildMapControlButton(
                      icon: Icons.add,
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(_mapCenter, currentZoom + 1.0);
                      },
                    ),
                    SizedBox(height: 8),
                    // Zoom out button
                    _buildMapControlButton(
                      icon: Icons.remove,
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(_mapCenter, currentZoom - 1.0);
                      },
                    ),
                    SizedBox(height: 8),
                    // My location button
                    _buildMapControlButton(
                      icon: Icons.my_location,
                      onTap: () {
                        // Center on user location
                      },
                    ),
                  ],
                ),
              ),

              // Floating schedule card with navigation
              if (schedules.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 150, // Increased height to accommodate content
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Card PageView
                        PageView.builder(
                          controller: _pageController,
                          itemCount: schedules.length,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedCardIndex = index;
                            });

                            final lat = schedules[index].latitude;
                            final lng = schedules[index].longitude;
                            if (lat != null && lng != null) {
                              _mapController.move(LatLng(lat, lng), 16.0);
                            }
                          },
                          itemBuilder: (context, index) {
                            final schedule = schedules[index];
                            final lat = schedule.latitude;
                            final lng = schedule.longitude;
                            final petugas =
                                schedule.assignedUser?.name ??
                                'Petugas belum ditetapkan';
                            final trackingText =
                                'Tracking: ${schedule.trackingsCount ?? 0}';
                            final actionButton = _buildActionButton(schedule);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPickupPage(
                                      scheduleId: schedule.id.toString(),
                                    ),
                                  ),
                                ).then((_) {
                                  if (mounted) {
                                    _loadSchedules();
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF76DE8D),
                                      greenColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${schedule.formattedTime} • ${schedule.formattedDate}',
                                            style: whiteTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: whiteColor,
                                              foregroundColor: greenColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              minimumSize: const Size(0, 0),
                                            ),
                                            onPressed:
                                                lat != null && lng != null
                                                ? () => _navigateToLocation(
                                                    LatLng(lat, lng),
                                                  )
                                                : null,
                                            child: Text(
                                              "Menuju Lokasi",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: semiBold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            schedule.title,
                                            style: whiteTextStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  schedule.description ??
                                                      'Alamat belum tersedia',
                                                  style: whiteTextStyle
                                                      .copyWith(fontSize: 12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '$petugas • $trackingText',
                                              style: whiteTextStyle.copyWith(
                                                fontSize: 11,
                                                fontWeight: medium,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildStatusChip(schedule),
                                          if (actionButton != null) ...[
                                            const SizedBox(height: 8),
                                            actionButton,
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Left Arrow
                        Positioned(
                          left: 0,
                          child: GestureDetector(
                            onTap: _selectedCardIndex > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _selectedCardIndex > 0
                                    ? greenColor
                                    : Colors.grey.withOpacity(0.3),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // "Lihat Jadwal" button between arrows
                        Positioned(
                          bottom: -5,
                          child: GestureDetector(
                            onTap: () {
                              // Navigate back to the list view
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: greenColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.list_alt_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Lihat Jadwal",
                                    style: whiteTextStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Right Arrow
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: _selectedCardIndex < schedules.length - 1
                                ? () {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _selectedCardIndex < schedules.length - 1
                                    ? greenColor
                                    : Colors.grey.withOpacity(0.3),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build map control buttons
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: greenColor, size: 20),
      ),
    );
  }

  // Fungsi untuk membuat marker pada peta
  List<Marker> _buildMarkers(List<ScheduleApiModel> schedules) {
    final markers = <Marker>[];

    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];
      final lat = schedule.latitude;
      final lng = schedule.longitude;
      if (lat == null || lng == null) continue;

      final markerColor = _statusColor(schedule.status);

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCardIndex = i;
              });

              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );

              _mapController.move(LatLng(lat, lng), 17.0);
            },
            child: Container(
              decoration: BoxDecoration(
                border: _selectedCardIndex == i
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                "assets/ic_tempat_sampah.png",
                width: 30,
                height: 30,
                color: markerColor,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<ScheduleApiModel> _getFilteredSchedules() {
    if (_selectedFilter == "semua") {
      return List<ScheduleApiModel>.from(_schedules);
    }

    final filtered = _schedules
        .where(
          (schedule) => _normalizeStatus(schedule.status) == _selectedFilter,
        )
        .toList();
    filtered.sort((a, b) {
      final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return filtered;
  }

  Color _statusColor(String? status) {
    switch (_normalizeStatus(status)) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return greenColor;
    }
  }

  String _normalizeStatus(String? status) => status?.toLowerCase() ?? 'unknown';

  Widget _buildStatusChip(ScheduleApiModel schedule) {
    final normalizedStatus = _normalizeStatus(schedule.status);
    late Color chipColor;
    late String label;

    switch (normalizedStatus) {
      case 'pending':
        chipColor = Colors.orange;
        label = 'Menunggu';
        break;
      case 'in_progress':
        chipColor = Colors.blue;
        label = 'Diproses';
        break;
      case 'completed':
        chipColor = Colors.green;
        label = 'Selesai';
        break;
      case 'cancelled':
        chipColor = Colors.grey;
        label = 'Dibatalkan';
        break;
      default:
        chipColor = Colors.grey;
        label = normalizedStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: chipColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: whiteTextStyle.copyWith(fontSize: 11, fontWeight: semiBold),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButton(ScheduleApiModel schedule) {
    final normalizedStatus = _normalizeStatus(schedule.status);
    String? label;

    switch (normalizedStatus) {
      case 'pending':
        label = 'Mulai Pengambilan';
        break;
      case 'in_progress':
        label = 'Tandai Selesai';
        break;
      default:
        label = null;
    }

    if (label == null) return null;

    final isProcessing = _updatingScheduleIds.contains(schedule.id);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: greenColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isProcessing ? null : () => _handleScheduleAction(schedule),
        child: isProcessing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                ),
              )
            : Text(
                label,
                style: blackTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: semiBold,
                  color: greenColor,
                ),
              ),
      ),
    );
  }

  Future<void> _handleScheduleAction(ScheduleApiModel schedule) async {
    final normalizedStatus = _normalizeStatus(schedule.status);

    if (normalizedStatus == 'pending') {
      final confirmed = await _showStatusConfirmation(
        title: 'Mulai Pengambilan',
        message:
            'Status jadwal akan diubah menjadi Diproses dan tampil di daftar tugas aktif.',
        confirmLabel: 'Mulai',
      );

      if (confirmed) {
        await _updateScheduleStatus(
          schedule,
          'in_progress',
          successMessage: 'Pengambilan ditandai sedang diproses.',
        );
      }
      return;
    }

    if (normalizedStatus == 'in_progress') {
      final confirmed = await _showStatusConfirmation(
        title: 'Selesaikan Pengambilan',
        message:
            'Pastikan sampah sudah diambil. Status akan ditandai sebagai selesai.',
        confirmLabel: 'Selesai',
      );

      if (confirmed) {
        await _updateScheduleStatus(
          schedule,
          'completed',
          successMessage: 'Pengambilan selesai dicatat.',
        );
      }
      return;
    }

    if (normalizedStatus == 'cancelled') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jadwal ini telah dibatalkan oleh sistem.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    }
  }

  Future<void> _updateScheduleStatus(
    ScheduleApiModel schedule,
    String newStatus, {
    String? successMessage,
  }) async {
    if (_updatingScheduleIds.contains(schedule.id)) return;

    setState(() {
      _updatingScheduleIds.add(schedule.id);
    });

    try {
      final updated = await _scheduleApiService.updateScheduleStatus(
        schedule.id,
        newStatus,
      );

      if (!mounted) return;

      setState(() {
        final index = _schedules.indexWhere(
          (element) => element.id == schedule.id,
        );
        if (index != -1) {
          _schedules[index] = updated;
        }
        _updatingScheduleIds.remove(schedule.id);
        final filtered = _getFilteredSchedules();
        _selectedCardIndex = filtered.indexWhere(
          (element) => element.id == updated.id,
        );
        if (_selectedCardIndex >= 0 && _pageController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                _selectedCardIndex,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      });

      _adjustMapBounds();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage ?? 'Status jadwal diperbarui.'),
          backgroundColor: greenColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _updatingScheduleIds.remove(schedule.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        ),
      );
    }
  }

  Future<bool> _showStatusConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: blackTextStyle.copyWith(fontWeight: bold)),
          content: Text(message, style: blackTextStyle.copyWith(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: blackTextStyle.copyWith(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
