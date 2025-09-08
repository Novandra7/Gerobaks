import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_event.dart';
import 'package:bank_sha/blocs/tracking/tracking_state.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';

class WilayahContent extends StatefulWidget {
  final double horizontalPadding;
  
  const WilayahContent({
    super.key,
    this.horizontalPadding = 24.0,
  });

  @override
  State<WilayahContent> createState() => _WilayahContentState();
}

class _WilayahContentState extends State<WilayahContent> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(FetchRoute());
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _simulateLoading();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Method to show trash point details in a bottom modal
  void _showTrashPointDetails(
    BuildContext context, 
    String name, 
    LatLng location, 
    {
      required bool isAvailable,
      required int capacity,
      required int currentUsage,
      required String lastEmptied,
    }
  ) {
    // Calculate usage percentage
    final usagePercent = (currentUsage / capacity * 100).round();
    
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: isTablet ? screenWidth * 0.7 : screenWidth,
        margin: isTablet 
            ? EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: 20) 
            : null,
        padding: EdgeInsets.only(
          top: 20,
          left: isTablet ? 32 : 24,
          right: isTablet ? 32 : 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Title with status indicator
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAvailable ? greenColor : redcolor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: blackTextStyle.copyWith(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Status with improved visual
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 6
              ),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAvailable ? greenColor.withOpacity(0.5) : redcolor.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.error_outline,
                    size: isTablet ? 20 : 18,
                    color: isAvailable ? greenColor : redcolor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? "Tersedia" : "Penuh",
                    style: blackTextStyle.copyWith(
                      fontWeight: medium,
                      color: isAvailable ? greenColor : redcolor,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Location coordinates
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined, 
                  size: isTablet ? 20 : 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  "${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}",
                  style: greyTextStyle.copyWith(
                    fontSize: isTablet ? 15 : 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Usage bar with improved visual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kapasitas",
                        style: blackTextStyle.copyWith(
                          fontWeight: medium,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      Text(
                        "$usagePercent% terisi",
                        style: blackTextStyle.copyWith(
                          fontWeight: semiBold,
                          color: usagePercent > 80 ? redcolor : greenColor,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: currentUsage / capacity,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        usagePercent > 80 ? redcolor : greenColor,
                      ),
                      minHeight: isTablet ? 12 : 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$currentUsage / $capacity kg",
                    style: greyTextStyle.copyWith(
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Last emptied info
            Row(
              children: [
                Icon(
                  Icons.history, 
                  size: isTablet ? 20 : 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  "Terakhir dikosongkan: $lastEmptied",
                  style: greyTextStyle.copyWith(
                    fontSize: isTablet ? 15 : 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action button with improved style
            SizedBox(
              height: isTablet ? 52 : 48,
              child: ElevatedButton(
                onPressed: isAvailable 
                  ? () {
                      Navigator.pop(context);
                      // Navigate to schedule pickup page
                      Navigator.pushNamed(context, '/home');
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isAvailable ? "Jadwalkan Pengambilan" : "Tidak Tersedia",
                  style: whiteTextStyle.copyWith(
                    fontWeight: semiBold,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _simulateLoading() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate map data loading
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Start animation after loading is complete
      _animationController.forward();
    }
  }
  
  // Map skeleton loader with improved visual
  Widget _buildMapSkeletonLoader() {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = widget.horizontalPadding;
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? horizontalPadding : horizontalPadding / 2,
        vertical: isTablet ? 16 : 8,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SkeletonItems.card(
                height: isTablet ? 500 : 400,
                width: MediaQuery.of(context).size.width * (isTablet ? 0.9 : 0.85),
                borderRadius: 16,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),
            SkeletonItems.text(width: isTablet ? 220 : 180, height: isTablet ? 24 : 20),
            SizedBox(height: isTablet ? 12 : 8),
            SkeletonItems.text(width: isTablet ? 280 : 240, height: isTablet ? 18 : 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = widget.horizontalPadding;
    
    // Show skeleton loading
    if (_isLoading) {
      return _buildMapSkeletonLoader();
    }
    
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        // Titik-titik polygon zona hijau
        final List<LatLng> greenZone = [
          LatLng(-0.502473, 117.148738), // Titik A
          LatLng(-0.503042, 117.148523), // Titik B
          LatLng(-0.503959, 117.151090), // Titik C
          LatLng(-0.503240, 117.151347), // Titik D
        ];

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? horizontalPadding / 2 : horizontalPadding / 4,
                vertical: isTablet ? 16 : 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map title
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      "Peta Wilayah Layanan",
                      style: blackTextStyle.copyWith(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: semiBold,
                      ),
                    ),
                  ),
                  
                  // Map container
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Map
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(-0.5035, 117.1500),
                              initialZoom: 17.6,
                            ),
                            children: [
                              // Peta dasar
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.gerobaks.app',
                              ),

                              // Zona hijau sebagai polygon
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: greenZone,
                                    color: Colors.blue.withOpacity(0.3),
                                    borderColor: Colors.blue,
                                    borderStrokeWidth: 2,
                                  ),
                                ],
                              ),

                              // Marker tujuan dan tempat sampah
                              MarkerLayer(
                                markers: [
                                  // Marker tempat sampah 1 - Kosong (Hijau)
                                  Marker(
                                    point: LatLng(-0.503106, 117.150248),
                                    width: 30,
                                    height: 60,
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showTrashPointDetails(
                                          context, 
                                          "Tempat Sampah A", 
                                          LatLng(-0.503106, 117.150248),
                                          isAvailable: true,
                                          capacity: 30,
                                          currentUsage: 5,
                                          lastEmptied: "Hari ini, 08:30",
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/ic_tempat_sampah.png',
                                        width: 35,
                                        height: 35,
                                        color: greenColor,
                                      ),
                                    ),
                                  ),

                                  // Marker tempat sampah 2 - Penuh (Merah)
                                  Marker(
                                    point: LatLng(-0.503248, 117.150693),
                                    width: 30,
                                    height: 60,
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showTrashPointDetails(
                                          context, 
                                          "Tempat Sampah B", 
                                          LatLng(-0.503248, 117.150693),
                                          isAvailable: false,
                                          capacity: 50,
                                          currentUsage: 48,
                                          lastEmptied: "Kemarin, 15:45",
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/ic_tempat_sampah.png',
                                        width: 35,
                                        height: 35,
                                        color: redcolor,
                                      ),
                                    ),
                                  ),

                                  // Marker tempat sampah 3 - Penuh (Merah)
                                  Marker(
                                    point: LatLng(-0.502784, 117.149304),
                                    width: 30,
                                    height: 60,
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showTrashPointDetails(
                                          context, 
                                          "Tempat Sampah C", 
                                          LatLng(-0.502784, 117.149304),
                                          isAvailable: false,
                                          capacity: 40,
                                          currentUsage: 38,
                                          lastEmptied: "2 hari lalu, 10:20",
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/ic_tempat_sampah.png',
                                        width: 35,
                                        height: 35,
                                        color: redcolor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Map controls
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Tombol full screen
                                Container(
                                  width: isTablet ? 48 : 40,
                                  height: isTablet ? 48 : 40,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.fullscreen,
                                      size: isTablet ? 24 : 20,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/wilayah-full-screen');
                                    },
                                    tooltip: 'Layar Penuh',
                                  ),
                                ),
                                
                                // Tombol lokasi saya
                                Container(
                                  width: isTablet ? 48 : 40,
                                  height: isTablet ? 48 : 40,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.my_location,
                                      size: isTablet ? 24 : 20,
                                      color: greenColor,
                                    ),
                                    onPressed: () {
                                      // Simulate finding current location
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Mencari lokasi Anda...',
                                            style: whiteTextStyle,
                                          ),
                                          backgroundColor: greenColor,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    tooltip: 'Lokasi Saya',
                                  ),
                                ),
                                
                                // Tombol zoom in
                                Container(
                                  width: isTablet ? 48 : 40,
                                  height: isTablet ? 48 : 40,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: isTablet ? 24 : 20,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () {
                                      // Zoom in functionality would be implemented here
                                    },
                                    tooltip: 'Perbesar',
                                  ),
                                ),
                                
                                // Tombol zoom out
                                Container(
                                  width: isTablet ? 48 : 40,
                                  height: isTablet ? 48 : 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: isTablet ? 24 : 20,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () {
                                      // Zoom out functionality would be implemented here
                                    },
                                    tooltip: 'Perkecil',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Legend
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/ic_tempat_sampah.png',
                                        width: 18,
                                        height: 18,
                                        color: greenColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tersedia',
                                        style: blackTextStyle.copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/ic_tempat_sampah.png',
                                        width: 18,
                                        height: 18,
                                        color: redcolor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Penuh',
                                        style: blackTextStyle.copyWith(fontSize: 12),
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
                  
                  // Information text
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 12),
                    child: Text(
                      "Tap pada ikon tempat sampah untuk melihat detail",
                      style: greyTextStyle.copyWith(
                        fontSize: isTablet ? 14 : 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

