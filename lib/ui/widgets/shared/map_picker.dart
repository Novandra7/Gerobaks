import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

// Map Picker Page untuk digunakan di berbagai tempat
class MapPickerPage extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;
  final LatLng? initialLocation;

  const MapPickerPage({
    super.key, 
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final _searchController = TextEditingController();
  String _selectedAddress = '';
  double _selectedLat = -7.2575; // Default ke Surabaya
  double _selectedLng = 112.7521;
  bool _isSearching = false;
  bool _isMapReady = false;
  bool _isLoadingLocation = true;
  
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    
    // Gunakan lokasi awal jika disediakan
    if (widget.initialLocation != null) {
      _selectedLat = widget.initialLocation!.latitude;
      _selectedLng = widget.initialLocation!.longitude;
      _reverseGeocode(_selectedLat, _selectedLng); // Dapatkan alamat dari koordinat
    } else {
      // Dapatkan lokasi saat ini jika tidak ada lokasi awal
      _getCurrentLocation();
    }
    
    // Set map siap setelah delay singkat
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    });
  }

  // Dapatkan lokasi pengguna saat ini
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _isMapReady = true;
          });
        }
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _isMapReady = true;
            });
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _isMapReady = true;
          });
        }
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition();
      
      if (mounted) {
        setState(() {
          _selectedLat = position.latitude;
          _selectedLng = position.longitude;
          _isLoadingLocation = false;
          _isMapReady = true;
        });
      }
      
      // Dapatkan alamat dari lokasi
      _reverseGeocode(_selectedLat, _selectedLng);
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _isMapReady = true;
        });
      }
    }
  }

  // Cari alamat berdasarkan text
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });

    try {
      final apiKey = dotenv.env['NOMINATIM_API_KEY'] ?? '';
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5'),
        headers: {
          'User-Agent': 'GEROBAKS App',
          if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;
        final formattedResults = results.map((result) {
          return {
            'address': result['display_name'],
            'lat': double.parse(result['lat']),
            'lng': double.parse(result['lon']),
          };
        }).toList();

        if (mounted) {
          setState(() {
            _searchResults = formattedResults;
            _isSearching = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      print('Error searching: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  // Dapatkan alamat dari koordinat
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final apiKey = dotenv.env['NOMINATIM_API_KEY'] ?? '';
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json'),
        headers: {
          'User-Agent': 'GEROBAKS App',
          if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (mounted) {
          setState(() {
            _selectedAddress = result['display_name'];
          });
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
  }

  // Handler untuk tap pada map
  void _handleMapTap(LatLng point) async {
    setState(() {
      _selectedLat = point.latitude;
      _selectedLng = point.longitude;
      _selectedAddress = 'Memuat alamat...';
    });
    
    // Dapatkan alamat dari koordinat yang dipilih
    await _reverseGeocode(_selectedLat, _selectedLng);
  }

  // Pilih lokasi dari hasil pencarian
  void _selectLocation(String address, double lat, double lng) {
    setState(() {
      _selectedAddress = address;
      _selectedLat = lat;
      _selectedLng = lng;
      _searchResults = [];
      _searchController.text = '';
    });
    
    // Pindahkan peta ke lokasi yang dipilih
    _mapController.move(LatLng(lat, lng), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Lokasi',
          style: blackTextStyle.copyWith(
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: blackColor),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          color: whiteColor,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      foregroundColor: whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                    onPressed: _selectedAddress.isNotEmpty 
                      ? () {
                          widget.onLocationSelected(
                            _selectedAddress,
                            _selectedLat,
                            _selectedLng,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: whiteColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Konfirmasi Lokasi',
                          style: whiteTextStyle.copyWith(
                            fontWeight: semiBold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari alamat...',
                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                prefixIcon: Icon(Icons.search, color: greyColor),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: greenColor, width: 2),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),

          // Search Results
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: Icon(Icons.location_on, color: greyColor),
                    title: Text(
                      result['address'],
                      style: blackTextStyle.copyWith(fontSize: 14),
                    ),
                    onTap: () {
                      _selectLocation(
                        result['address'],
                        result['lat'],
                        result['lng'],
                      );
                    },
                  );
                },
              ),
            )
          else
            // Map
            Expanded(
              child: Stack(
                children: [
                  _isMapReady ? 
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(_selectedLat, _selectedLng),
                      initialZoom: 15.0,
                      onTap: (tapPosition, LatLng point) {
                        _handleMapTap(point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_selectedLat, _selectedLng),
                            child: Icon(
                              Icons.location_on,
                              color: redcolor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ) :
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                    ),
                  ),

                  // Lokasi yang dipilih
                  if (_selectedAddress.isNotEmpty && _searchResults.isEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokasi Terpilih',
                              style: blackTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedAddress,
                              style: greyTextStyle.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Koordinat: ${_selectedLat.toStringAsFixed(6)}, ${_selectedLng.toStringAsFixed(6)}',
                              style: greyTextStyle.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Loading indikator untuk lokasi
                  if (_isLoadingLocation)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Mendapatkan lokasi Anda...',
                              style: whiteTextStyle.copyWith(
                                fontWeight: medium,
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
      ),
    );
  }
}
