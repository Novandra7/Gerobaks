import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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
  
  // Location tracking
  bool _isLoadingLocation = false;
  LatLng? _currentLocation;
  
  // Define mock data for subscription areas with more complex boundaries
  final List<Map<String, dynamic>> subscriptionAreas = [
    {
      'id': 'AREA001',
      'name': 'RT 13',
      'color': Colors.blue.withOpacity(0.1),
      'borderColor': Colors.blue.withOpacity(0.6),
      'boundaries': [
        LatLng(-0.502473, 117.148738),
        LatLng(-0.503042, 117.148523),
        LatLng(-0.503959, 117.151090),
        LatLng(-0.503240, 117.151347),
        LatLng(-0.502473, 117.148738), // Close polygon
      ],
    },
    {
      'id': 'AREA002',
      'name': 'RT 14',
      'color': Colors.green.withOpacity(0.1),
      'borderColor': Colors.green.withOpacity(0.6),
      'boundaries': [
        LatLng(-0.502150, 117.149200),
        LatLng(-0.502450, 117.149100),
        LatLng(-0.502750, 117.150000),
        LatLng(-0.502350, 117.150200),
        LatLng(-0.502150, 117.149200), // Close polygon
      ],
    },
    {
      'id': 'AREA003',
      'name': 'RT 15',
      'color': Colors.purple.withOpacity(0.1),
      'borderColor': Colors.purple.withOpacity(0.6),
      'boundaries': [
        LatLng(-0.503959, 117.151090),
        LatLng(-0.504200, 117.151300),
        LatLng(-0.504100, 117.151800),
        LatLng(-0.503800, 117.151600),
        LatLng(-0.503959, 117.151090), // Close polygon
      ],
    },
  ];
  
  // Define route paths between customers
  final List<List<LatLng>> routePaths = [
    [
      LatLng(-0.502784, 117.149304), // Start from customer 3
      LatLng(-0.502900, 117.149700),
      LatLng(-0.503020, 117.150000),
      LatLng(-0.503106, 117.150248), // To customer 1
      LatLng(-0.503180, 117.150400),
      LatLng(-0.503248, 117.150693), // To customer 2
    ],
    [
      LatLng(-0.502784, 117.149304), // Start from customer 3
      LatLng(-0.502700, 117.150000),
      LatLng(-0.503248, 117.150693), // To customer 2
    ],
  ];
  
  // Define mock data for customers with extended information
  final List<Map<String, dynamic>> customers = [
    {
      'id': 'CUST001',
      'name': 'Wahyu Indra',
      'address': 'Jl. Muso Salim 8',
      'location': LatLng(-0.503106, 117.150248),
      'organic': true,
      'nonOrganic': false,
      'weight': 3,
      'time': '14:00 - 16:00',
      'status': 'Active',
      'phone': '081234567890',
      'subscription': 'Premium',
      'nextPickup': '16 Sep 2025',
      'lastPickup': '13 Sep 2025',
      'area': 'RT 13',
      'notes': 'Tempatkan di depan pagar hitam'
    },
    {
      'id': 'CUST002',
      'name': 'Budi Santoso',
      'address': 'Jl. Muso Salim 12',
      'location': LatLng(-0.503248, 117.150693),
      'organic': false,
      'nonOrganic': true,
      'weight': 2,
      'time': '09:00 - 11:00',
      'status': 'Active',
      'phone': '082345678901',
      'subscription': 'Standard',
      'nextPickup': '16 Sep 2025',
      'lastPickup': '13 Sep 2025',
      'area': 'RT 13',
      'notes': 'Rumah dengan pagar putih'
    },
    {
      'id': 'CUST003',
      'name': 'Dewi Sartika',
      'address': 'Jl. Kapten Tendean 5',
      'location': LatLng(-0.502784, 117.149304),
      'organic': true,
      'nonOrganic': true,
      'weight': 4,
      'time': '13:00 - 15:00',
      'status': 'Active',
      'phone': '083456789012',
      'subscription': 'Premium',
      'nextPickup': '16 Sep 2025',
      'lastPickup': '13 Sep 2025',
      'area': 'RT 13',
      'notes': 'Rumah pojok dengan pohon mangga'
    },
    {
      'id': 'CUST004',
      'name': 'Siti Nurhaliza',
      'address': 'Jl. Ahmad Dahlan 23',
      'location': LatLng(-0.502250, 117.149400),
      'organic': true,
      'nonOrganic': true,
      'weight': 3,
      'time': '10:00 - 12:00',
      'status': 'Active',
      'phone': '084567890123',
      'subscription': 'Standard',
      'nextPickup': '16 Sep 2025',
      'lastPickup': '13 Sep 2025',
      'area': 'RT 14',
      'notes': 'Seberang toko kelontong'
    },
    {
      'id': 'CUST005',
      'name': 'Ahmad Syarif',
      'address': 'Jl. Diponegoro 45',
      'location': LatLng(-0.504050, 117.151500),
      'organic': false,
      'nonOrganic': true,
      'weight': 2,
      'time': '15:00 - 17:00',
      'status': 'Active',
      'phone': '085678901234',
      'subscription': 'Basic',
      'nextPickup': '16 Sep 2025',
      'lastPickup': '13 Sep 2025',
      'area': 'RT 15',
      'notes': 'Rumah cat hijau'
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
    
    // Get location and load data
    _initializeMap();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Initialize map with user location
  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _isLoadingLocation = true;
    });
    
    try {
      // Get current location
      await _getCurrentLocation();
      
      // Auto-focus on first customer after loading if location not found
      if (_currentLocation == null && customers.isNotEmpty) {
        _selectCustomer(0);
      }
      
      // Start animation after loading is complete
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingLocation = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingLocation = false;
        });
        
        // If error, still select first customer
        if (customers.isNotEmpty) {
          _selectCustomer(0);
        }
        _animationController.forward();
      }
    }
  }
  
  // Get user's current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Center map on current location
        _mapController.move(_currentLocation!, 17.0);
      }
    } catch (e) {
      print('Error getting location: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat mengakses lokasi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
  
  // Helper method to determine subscription color
  Color _getSubscriptionColor(String subscription) {
    switch (subscription) {
      case 'Premium':
        return Colors.purple;
      case 'Standard':
        return Colors.blue;
      case 'Basic':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  // Helper method to build waste type tag
  Widget _buildWasteTypeTag(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color, // Using color directly
          fontSize: 12,
          fontWeight: medium,
        ),
      ),
    );
  }
  
  // Method to call customer's phone number
  void _callCustomer(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat melakukan panggilan ke $phoneNumber'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Method to navigate to customer's location
  void _navigateToCustomer(int index) {
    if (index >= 0 && index < customers.length) {
      _selectCustomer(index);
      
      final customer = customers[index];
      final lat = customer['location'].latitude;
      final lng = customer['location'].longitude;
      
      // Show navigation options
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Navigasi ke ${customer['name']}',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: Text('Buka di Google Maps', style: blackTextStyle),
                onTap: () async {
                  final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.green),
                title: Text('Petunjuk Arah', style: blackTextStyle),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menuju lokasi ${customer['name']}'),
                      backgroundColor: greenColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  // Method to refresh map and get current location
  void _refreshMapAndLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    await _getCurrentLocation();
    
    setState(() {
      _isLoadingLocation = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lokasi diperbarui'),
        backgroundColor: greenColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Build customer card at bottom with enhanced details
  Widget _buildCustomerCard(Map<String, dynamic> customer, int index) {
    final bool isSelected = index == _selectedCustomerIndex;
    
    return GestureDetector(
      onTap: () => _selectCustomer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(
          left: index == 0 ? 16 : 8,
          right: index == customers.length - 1 ? 16 : 8,
        ),
        width: 320, // Slightly wider for more information
        height: 195, // Fixed height to avoid overflow
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00A643).withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? greenColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            // Time slot and action button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF00A643),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customer['time'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF00A643),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : greenColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Area ${customer['area']}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : greenColor,
                            fontSize: 10,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Call button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _callCustomer(customer['phone']),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.phone,
                              size: 18,
                              color: isSelected ? Colors.white : greenColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Navigate button
                      ElevatedButton(
                        onPressed: () => _navigateToCustomer(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.white : const Color(0xFF00A643),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                        ),
                        child: Text(
                          'Menuju',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? const Color(0xFF00A643) : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Customer info with enhanced details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Customer ID and subscription badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          customer['id'],
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getSubscriptionColor(customer['subscription']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            customer['subscription'],
                            style: TextStyle(
                              color: _getSubscriptionColor(customer['subscription']),
                              fontSize: 12,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Name
                    Text(
                      customer['name'],
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Address with icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                    // Phone with icon
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customer['phone'],
                            style: greyTextStyle.copyWith(
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Waste type indicators and next pickup date
                    Row(
                      children: [
                        if (customer['organic']) _buildWasteTypeTag('Organik', Colors.green),
                        if (customer['organic'] && customer['nonOrganic']) 
                          const SizedBox(width: 8),
                        if (customer['nonOrganic']) _buildWasteTypeTag('Non-Organik', Colors.blue),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pickup: ${customer['nextPickup']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[800],
                                fontWeight: medium,
                              ),
                            ),
                          ],
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
                      initialCenter: _currentLocation ?? LatLng(-0.5035, 117.1500),
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
                            color: area['color'],
                            borderColor: area['borderColor'],
                            borderStrokeWidth: 2,
                          );
                        }).toList(),
                      ),
                      
                      // Route paths
                      PolylineLayer(
                        polylines: routePaths.map((path) {
                          return Polyline(
                            points: path,
                            color: Colors.blue.withOpacity(0.7),
                            strokeWidth: 3.0,
                          );
                        }).toList(),
                      ),
                      
                      // Current location marker
                      if (_currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                  'assets/img_gerobakss.png',
                                  width: 100,
                                  height: 28,
                                  color: Colors.white,
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
                            
                            // Wilayah Pengambilan title with marker (changed from Jadwal Pengambilan)
                            Row(
                              children: [
                                Text(
                                  'Wilayah Pengambilan',
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
                  bottom: 220, // Position above customer list
                  child: Column(
                    children: [
                      // My Location button
                      Container(
                        width: 40,
                        height: 40,
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
                            Icons.my_location,
                            color: greenColor,
                            size: 20,
                          ),
                          onPressed: _refreshMapAndLocation,
                        ),
                      ),
                      
                      // Previous button
                      Container(
                        width: 40,
                        height: 40,
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
                        width: 40,
                        height: 40,
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
                        width: 40,
                        height: 40,
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
                  bottom: 16, // Add some padding at the bottom
                  child: Container(
                    height: 195, // Fixed height for customer cards
                    child: customers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              return _buildCustomerCard(customers[index], index);
                            },
                          ),
                  ),
                ),
                
                // Loading indicator for location
                if (_isLoadingLocation)
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: greenColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mendapatkan lokasi...',
                            style: blackTextStyle.copyWith(
                              fontSize: 12,
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
  
  // Empty state view
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            color: Colors.grey[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pelanggan di wilayah ini',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data pelanggan akan muncul di sini',
            textAlign: TextAlign.center,
            style: greyTextStyle.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
