import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MitraLokasiPage extends StatefulWidget {
  const MitraLokasiPage({super.key});

  @override
  State<MitraLokasiPage> createState() => _MitraLokasiPageState();
}

class _MitraLokasiPageState extends State<MitraLokasiPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  int _selectedCustomerIndex = -1;
  
  // Define mock data for subscription areas
  final List<Map<String, dynamic>> subscriptionAreas = [
    {
      'id': 'AREA001',
      'name': 'RT 13',
      'boundaries': [
        LatLng(-0.502473, 117.148738),
        LatLng(-0.503042, 117.148523),
        LatLng(-0.503959, 117.151090),
        LatLng(-0.503240, 117.151347),
      ],
    },
  ];
  
  // Define mock data for customers
  final List<Map<String, dynamic>> customers = [
    {
      'id': 'CUST001',
      'name': 'Wahyu Indra',
      'address': 'Jl. Muso Salim 8',
      'location': LatLng(-0.503106, 117.150248),
      'organic': true,
      'weight': 3,
      'time': '14:00 - 16:00',
    },
    {
      'id': 'CUST002',
      'name': 'Budi Santoso',
      'address': 'Jl. Muso Salim 12',
      'location': LatLng(-0.503248, 117.150693),
      'organic': false,
      'weight': 2,
      'time': '09:00 - 11:00',
    },
    {
      'id': 'CUST003',
      'name': 'Dewi Sartika',
      'address': 'Jl. Kapten Tendean 5',
      'location': LatLng(-0.502784, 117.149304),
      'organic': true,
      'weight': 4,
      'time': '13:00 - 15:00',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
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
    
    _simulateLoading();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
  
  // Method to select a customer and show details
  void _selectCustomer(int index) {
    setState(() {
      _selectedCustomerIndex = index;
      
      // Center map on selected customer
      if (index >= 0 && index < customers.length) {
        _mapController.move(customers[index]['location'], 17.0);
      }
    });
  }
  
  // Build customer card at bottom
  Widget _buildCustomerCard(Map<String, dynamic> customer, int index) {
    final bool isSelected = index == _selectedCustomerIndex;
    
    return GestureDetector(
      onTap: () => _selectCustomer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
          left: index == 0 ? 16 : 8,
          right: index == customers.length - 1 ? 16 : 8,
          bottom: 16,
        ),
        width: 280,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00A643).withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? greenColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time slot
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A643) : const Color(0xFFE4F9E8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    customer['time'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF00A643),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Menuju Lokasi',
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF00A643),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Customer info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    customer['name'],
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Address with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer['address'],
                          style: greyTextStyle.copyWith(
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Type and weight
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          customer['organic'] ? 'Organik' : 'Non-Organik',
                          style: greenTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${customer['weight']} kg',
                          style: blackTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: greenColor),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat Peta Wilayah...',
                    style: blackTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Full screen map
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(-0.5035, 117.1500),
                      initialZoom: 17.0,
                      minZoom: 12.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      // Base map layer with a pinkish tint to match screenshot
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.gerobaks.app',
                        tileBuilder: (context, child, tile) {
                          return ColorFiltered(
                            colorFilter: ColorFilter.matrix([
                              1.05, 0, 0, 0, 0,
                              0, 1, 0, 0, 10, // Slight pink tint
                              0, 0, 1, 0, 10,
                              0, 0, 0, 1, 0,
                            ]),
                            child: child,
                          );
                        },
                      ),
                      
                      // Subscription area polygon
                      PolygonLayer(
                        polygons: subscriptionAreas.map((area) {
                          return Polygon(
                            points: area['boundaries'],
                            color: Colors.blue.withOpacity(0.1),
                            borderColor: Colors.blue.withOpacity(0.5),
                            borderStrokeWidth: 2,
                          );
                        }).toList(),
                      ),
                      
                      // Customer markers
                      MarkerLayer(
                        markers: customers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final customer = entry.value;
                          final isSelected = index == _selectedCustomerIndex;
                          
                          return Marker(
                            point: customer['location'],
                            width: 35,
                            height: 35,
                            child: GestureDetector(
                              onTap: () => _selectCustomer(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected 
                                    ? greenColor 
                                    : Colors.white,
                                  border: Border.all(
                                    color: greenColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: isSelected ? Colors.white : greenColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Top header with gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00A643),
                          const Color(0xFF00A643).withOpacity(0),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button and title
                            Row(
                              children: [
                                Image.asset(
                                  'assets/ic_gerobaks.png',
                                  width: 28,
                                  height: 28,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'GEROBAKS',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    // Show message screen
                                    Navigator.pushNamed(context, '/mitra-chat-list');
                                  },
                                  child: Image.asset(
                                    'assets/ic_send.png', 
                                    width: 24,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    // Show notifications
                                  },
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Vehicle info
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'KT 777 WAN',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.badge,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'DRV-KTM-214',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Jadwal Pengambilan title with marker
                            Row(
                              children: [
                                Text(
                                  'Jadwal Pengambilan',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'RT 13',
                                        style: whiteTextStyle.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Search and filter area
                            Row(
                              children: [
                                // Search input (disabled)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ketikkan alamat',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Filter button
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.filter_list,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Navigation controls
                Positioned(
                  right: 16,
                  bottom: 120, // Position above customer list
                  child: Column(
                    children: [
                      // Previous button
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.blue,
                            size: 16,
                          ),
                          onPressed: () {
                            // Go to previous customer if possible
                            if (_selectedCustomerIndex > 0) {
                              _selectCustomer(_selectedCustomerIndex - 1);
                            }
                          },
                        ),
                      ),
                      
                      // Live view button
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: greenColor,
                            size: 16,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tampilan live map diaktifkan'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Next button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue,
                            size: 16,
                          ),
                          onPressed: () {
                            // Go to next customer if possible
                            if (_selectedCustomerIndex < customers.length - 1) {
                              _selectCustomer(_selectedCustomerIndex + 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Horizontal scrolling customer cards at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 155, // Height for the customer card
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        return _buildCustomerCard(customers[index], index);
                      },
                    ),
                  ),
                ),
                
                // Center text when there's no data
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      'KATAKAN PETA',
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}