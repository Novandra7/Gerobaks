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
          
          // Pindahkan peta ke lokasi pengguna
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0,
          );
        });
        
        // Dapatkan alamat dari koordinat
        await _reverseGeocode(position.latitude, position.longitude);
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Dapatkan alamat dari koordinat menggunakan geocoding API
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final apiKey = dotenv.env['MAPS_API_KEY'];
      if (apiKey == null) {
        setState(() {
          _selectedAddress = 'Lat: $lat, Lng: $lng';
        });
        return;
      }
      
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey',
      ));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].length > 0) {
          setState(() {
            _selectedAddress = data['results'][0]['formatted_address'];
          });
        } else {
          setState(() {
            _selectedAddress = 'Lat: $lat, Lng: $lng';
          });
        }
      } else {
        setState(() {
          _selectedAddress = 'Lat: $lat, Lng: $lng';
        });
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
      setState(() {
        _selectedAddress = 'Lat: $lat, Lng: $lng';
      });
    }
  }

  // Pencarian alamat
  Future<void> _performSearch(String query) async {
    if (query.isEmpty || query.length < 3) {
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
      final apiKey = dotenv.env['MAPS_API_KEY'];
      if (apiKey == null) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }
      
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
      ));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> results = data['results'];
          
          setState(() {
            _searchResults = results.map((result) {
              return {
                'address': result['formatted_address'],
                'lat': result['geometry']['location']['lat'],
                'lng': result['geometry']['location']['lng'],
              };
            }).toList();
            
            _isSearching = false;
          });
        } else {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error in place search: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  // Handle tap pada peta
  Future<void> _handleMapTap(LatLng point) async {
    setState(() {
      _selectedLat = point.latitude;
      _selectedLng = point.longitude;
      _selectedAddress = 'Memuat alamat...';
      _searchResults = []; // Tutup hasil pencarian
      _searchController.clear(); // Clear search input
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
      _searchResults = []; // Tutup hasil pencarian
      _searchController.text = ''; // Clear search input
    });
    
    // Pindahkan peta ke lokasi yang dipilih
    _mapController.move(LatLng(lat, lng), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Pilih Lokasi',
          style: blackTextStyle.copyWith(
            fontWeight: semiBold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: blackColor),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari alamat...',
                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                prefixIcon: Icon(Icons.search, color: greyColor),
                suffixIcon: _isSearching
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: greenColor,
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: greenColor, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: _performSearch,
            ),
          ),

          // Search Results or Map
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        leading: Icon(Icons.location_on, color: greyColor),
                        title: Text(
                          result['address'],
                          style: blackTextStyle.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                  )
                : Stack(
                    children: [
                      // Map
                      _isMapReady
                          ? FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(_selectedLat, _selectedLng),
                                initialZoom: 15.0,
                                onTap: (tapPosition, point) => _handleMapTap(point),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(_selectedLat, _selectedLng),
                                      child: Icon(
                                        Icons.location_on,
                                        color: redcolor,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                              ),
                            ),

                      // Lokasi yang dipilih - info box
                      if (_selectedAddress.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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

                      // Loading indicator
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedAddress.isNotEmpty ? greenColor : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
      ),
    );
  }
}
