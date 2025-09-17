import 'package:bank_sha/services/local_storage_service.dart';
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

class _JadwalMitraMapViewState extends State<JadwalMitraMapView> with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String? _driverId;
  bool _isLoading = false;
  String _selectedFilter = "semua"; // Filter options: semua, pending, in_progress, completed
  final MapController _mapController = MapController();
  int _selectedCardIndex = -1; // Index of the selected schedule card
  late PageController _pageController;
  
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
      final LocalStorageService localStorageService = await LocalStorageService.getInstance();
      final userData = await localStorageService.getUserData();
      
      if (userData != null && userData["id"] != null) {
        _driverId = userData["id"] as String;
      } else {
        throw Exception("ID driver tidak ditemukan");
      }
      
      // Load schedules
      await _loadSchedules();
      
      // If we have a specific scheduleId, select the corresponding card
      if (widget.scheduleId != null) {
        final schedules = _getFilteredSchedules();
        for (int i = 0; i < schedules.length; i++) {
          if (schedules[i]["id"] == widget.scheduleId) {
            setState(() {
              _selectedCardIndex = i;
            });
            
            // Scroll to the selected card
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pageController.animateToPage(
                i,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
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
            margin: EdgeInsets.only(
              left: 16, 
              right: 16, 
              bottom: 80
            ),
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
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_driverId != null) {
        // Di sini akan implementasi untuk mendapatkan jadwal berdasarkan ID driver dan tanggal
        // dari API atau sumber data lain
        // Untuk sementara, kita gunakan data dummy dan simulasi loading
        await Future.delayed(const Duration(seconds: 1));
        
        // Dalam implementasi sebenarnya akan seperti:
        // final schedules = await _scheduleService.getSchedules(driverId: _driverId!, date: selectedDate);
        // setState(() {
        //   _schedules = schedules;
        // });
        
        // Reset selected card when reloading schedules
        if (widget.scheduleId == null) {
          setState(() {
            _selectedCardIndex = -1;
          });
        }
        
        // Adjust map bounds to include all markers
        _adjustMapBounds();
      } else {
        throw Exception("ID driver tidak ditemukan");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat jadwal: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              left: 16, 
              right: 16, 
              bottom: 80
            ),
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
  void _adjustMapBounds() {
    final schedules = _getFilteredSchedules();
    if (schedules.isEmpty) return;
    
    // Calculate bounds
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;
    
    for (int i = 0; i < schedules.length; i++) {
      final lat = -0.502784 + ((i * 0.0002) % 0.003);
      final lng = 117.149304 + ((i * 0.0003) % 0.004);
      
      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }
    
    // Add padding to bounds
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;
    
    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;
    
    // Calculate center and zoom for bounds
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    
    // Update map center
    _mapCenter = LatLng(centerLat, centerLng);
    
    // In a real app, you would use bounds to calculate the appropriate zoom level
    // Here we just update the center
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
      case 1: return 'Januari';
      case 2: return 'Februari';
      case 3: return 'Maret';
      case 4: return 'April';
      case 5: return 'Mei';
      case 6: return 'Juni';
      case 7: return 'Juli';
      case 8: return 'Agustus';
      case 9: return 'September';
      case 10: return 'Oktober';
      case 11: return 'November';
      case 12: return 'Desember';
      default: return '';
    }
  }
  
  Widget _buildBody() {
    final schedules = _getFilteredSchedules();
    
    return Column(
      children: [
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
                    urlTemplate: "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
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
                  MarkerLayer(
                    markers: _buildMarkers(schedules),
                  ),
                ],
              ),
              
              // Map control buttons
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  children: [
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
                    height: 150,  // Increased height to accommodate content
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
                              
                              // Update map focus to selected marker
                              final lat = -0.502784 + ((index * 0.0002) % 0.003);
                              final lng = 117.149304 + ((index * 0.0003) % 0.004);
                              _mapController.move(LatLng(lat, lng), 16.0);
                            });
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to detail page when card is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPickupPage(
                                      scheduleId: schedules[index]["id"],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF76DE8D), greenColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Time and action button row
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            schedules[index]["time"],
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
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              minimumSize: Size(0, 0),
                                            ),
                                            onPressed: () {
                                              // Navigate to location
                                              final lat = -0.502784 + ((index * 0.0002) % 0.003);
                                              final lng = 117.149304 + ((index * 0.0003) % 0.004);
                                              _navigateToLocation(LatLng(lat, lng));
                                            },
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
                                    
                                    // Customer info
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            schedules[index]["customer_name"],
                                            style: whiteTextStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  schedules[index]["address"],
                                                  style: whiteTextStyle.copyWith(
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "${schedules[index]["waste_type"]} - ${schedules[index]["waste_weight"]}",
                                              style: whiteTextStyle.copyWith(
                                                fontSize: 11,
                                                fontWeight: medium,
                                              ),
                                            ),
                                          ),
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
                            onTap: _selectedCardIndex > 0 ? () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _selectedCardIndex > 0 ? greenColor : Colors.grey.withOpacity(0.3),
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
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            onTap: _selectedCardIndex < schedules.length - 1 ? () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _selectedCardIndex < schedules.length - 1 ? greenColor : Colors.grey.withOpacity(0.3),
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
  Widget _buildMapControlButton({required IconData icon, required VoidCallback onTap}) {
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
        child: Icon(
          icon,
          color: greenColor,
          size: 20,
        ),
      ),
    );
  }
  
  // Fungsi untuk membuat marker pada peta
  List<Marker> _buildMarkers(List<Map<String, dynamic>> schedules) {
    List<Marker> markers = [];
    
    for (int i = 0; i < schedules.length; i++) {
      final schedule = schedules[i];
      
      // In a real app, you would get lat/lng from your API
      // For demo purposes, we'll generate locations around the center point
      final lat = -0.502784 + ((i * 0.0002) % 0.003);
      final lng = 117.149304 + ((i * 0.0003) % 0.004);
      
      // Set icon color based on waste type
      Color markerColor;
      if (schedule["waste_type"] == "Organik") {
        markerColor = greenColor;
      } else {
        markerColor = Colors.red;
      }
      
      // Create marker
      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCardIndex = i;
                
                // Scroll to selected card
                _pageController.animateToPage(
                  i,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
              
              // Center map on this location
              _mapController.move(LatLng(lat, lng), 17.0);
            },
            child: Container(
              decoration: BoxDecoration(
                // Highlight selected marker
                border: _selectedCardIndex == i 
                  ? Border.all(color: Colors.white, width: 2) 
                  : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
  
  List<Map<String, dynamic>> _getFilteredSchedules() {
    // Data dummy untuk pengujian
    final List<Map<String, dynamic>> schedules = [
      {
        "id": "001",
        "customer_name": "Wahyu Indra",
        "address": "Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur",
        "time": "08:00 - 09:00",
        "waste_type": "Organik",
        "waste_weight": "3 kg",
        "status": "pending",
        "estimatedDistance": "500m • 10 menit",
      },
      {
        "id": "002",
        "customer_name": "Siti Rahayu",
        "address": "Perumahan Indah Blok B, Kota Samarinda, Kalimantan Timur",
        "time": "09:30 - 10:30",
        "waste_type": "Anorganik",
        "waste_weight": "1.5 kg",
        "status": "completed",
        "estimatedDistance": "800m • 15 menit",
      },
      {
        "id": "003",
        "customer_name": "Ahmad Rizal",
        "address": "Jl. Juanda No. 45, Kota Samarinda, Kalimantan Timur",
        "time": "11:00 - 12:00",
        "waste_type": "Organik",
        "waste_weight": "3 kg",
        "status": "in_progress",
        "estimatedDistance": "1.2km • 20 menit",
      },
      {
        "id": "004",
        "customer_name": "Wahyu Indra",
        "address": "Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur",
        "time": "14:00 - 16:00",
        "waste_type": "Anorganik",
        "waste_weight": "2 kg",
        "status": "pending",
        "estimatedDistance": "1.5km • 25 menit",
      },
    ];
    
    // Filter jadwal sesuai dengan tab yang dipilih
    if (_selectedFilter == "semua") {
      return schedules;
    } else {
      return schedules.where((s) => s["status"] == _selectedFilter).toList();
    }
  }
}