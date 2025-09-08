import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
<<<<<<< HEAD
import 'package:bank_sha/ui/widgets/shared/layout.dart';
<<<<<<< HEAD
import 'package:bank_sha/utils/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
=======
import 'package:flutter/material.dart';
>>>>>>> 02b957d (feat: adding & improve sign up)
=======
import 'package:bank_sha/services/user_service.dart';
import 'package:bank_sha/services/sign_up_service.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/mixins/app_dialog_mixin.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34

class SignUpBatch4Page extends StatefulWidget {
  const SignUpBatch4Page({super.key});

  @override
  State<SignUpBatch4Page> createState() => _SignUpBatch4PageState();
}

class _SignUpBatch4PageState extends State<SignUpBatch4Page> with AppDialogMixin {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedLocation;
  double? _selectedLat;
  double? _selectedLng;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _selectedLocation = address;
              _selectedLat = lat;
              _selectedLng = lng;
            });
          },
        ),
        fullscreenDialog: true, // Tampilkan sebagai dialog fullscreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo Section
                    const SizedBox(height: 60),

                    // Logo GEROBAKS
                    Container(
                      width: 250,
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset(
                        'assets/img_gerobakss.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: greenColor,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GEROBAKS',
                                style: greeTextStyle.copyWith(
                                  fontSize: 28,
                                  fontWeight: bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Alamat & Lokasi',
                      style: blackTextStyle.copyWith(
                        fontSize: 24,
                        fontWeight: bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Langkah 4 dari 5 - Informasi Alamat',
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Masukkan alamat dan tandai lokasi tempat tinggal Anda',
                      textAlign: TextAlign.center,
                      style: greyTextStyle.copyWith(fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    // Progress Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: greyColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Address Field
                    CustomFormField(
                      title: 'Alamat Lengkap',
                      keyboardType: TextInputType.streetAddress,
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        if (value.length < 10) {
                          return 'Alamat terlalu pendek, minimal 10 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Location Picker - Enhanced UI
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxHeight: 200, // Batasi tinggi maksimal
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedLocation != null
                              ? greenColor
                              : greyColor.withOpacity(0.5),
                          width: _selectedLocation != null ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _selectedLocation != null 
                          ? [
                              BoxShadow(
                                color: greenColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ] 
                          : null,
                      ),
                      child: InkWell(
                        onTap: _openMapPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Agar tidak terlalu besar
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
<<<<<<< HEAD
                                  Icon(
                                    Icons.location_on,
                                    color: _selectedLocation != null
                                        ? greenColor
                                        : greyColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pilih Lokasi di Peta',
                                    style:
                                        (_selectedLocation != null
                                                ? greeTextStyle
                                                : greyTextStyle)
                                            .copyWith(
                                              fontSize: 14,
                                              fontWeight: semiBold,
                                            ),
=======
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _selectedLocation != null 
                                        ? greenColor.withOpacity(0.1) 
                                        : greyColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: _selectedLocation != null ? greenColor : greyColor,
                                      size: 24,
                                    ),
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pilih Lokasi di Peta',
                                          style: (_selectedLocation != null ? greeTextStyle : blackTextStyle).copyWith(
                                            fontSize: 16,
                                            fontWeight: semiBold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedLocation != null 
                                          ? 'Lokasi sudah dipilih' 
                                          : 'Klik untuk memilih lokasi',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _selectedLocation != null 
                                        ? greenColor.withOpacity(0.1) 
                                        : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      _selectedLocation != null 
                                        ? Icons.check_circle 
                                        : Icons.arrow_forward_ios,
                                      color: _selectedLocation != null ? greenColor : greyColor,
                                      size: _selectedLocation != null ? 22 : 16,
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedLocation != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: greenColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: greenColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.pin_drop,
                                            color: greenColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Lokasi Terpilih',
                                            style: greeTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _selectedLocation!,
                                        style: blackTextStyle.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Koordinat: ${_selectedLat?.toStringAsFixed(6)}, ${_selectedLng?.toStringAsFixed(6)}',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
<<<<<<< HEAD
                                const SizedBox(height: 8),
                                Text(
                                  'Tap untuk membuka peta dan pilih lokasi tempat tinggal Anda',
                                  style: greyTextStyle.copyWith(fontSize: 12),
=======
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Klik untuk memilih lokasi tempat tinggal Anda pada peta',
                                          style: greyTextStyle.copyWith(
                                            fontSize: 12,
                                            color: Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (_selectedLocation == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '* Lokasi pada peta wajib dipilih',
                        style: TextStyle(color: redcolor, fontSize: 12),
                      ),
                    ],

                    const Spacer(),

                    const SizedBox(height: 30),

                    // Next Button
                    CustomFilledButton(
                      title: 'Lanjutkan',
                      showIcon: true,
                      icon: Icons.arrow_forward,
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && _selectedLocation != null) {
<<<<<<< HEAD
<<<<<<< HEAD
                          // Pass all data to subscription page
                          Navigator.pushNamed(
                            context,
                            '/sign-up-subscription',
=======
                          // Pass all data to next page
                          Navigator.pushNamed(
                            context,
                            '/sign-up-batch-5',
>>>>>>> 02b957d (feat: adding & improve sign up)
                            arguments: {
=======
                          // Show loading dialog
                          showAppLoadingDialog(
                            message: 'Mendaftarkan akun Anda...',
                          );
                          
                          try {
                            // Create user data object with all information
                            final userData = {
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34
                              ...?arguments,
                              'address': _selectedLocation ?? _addressController.text,
                              'selectedLocation': _selectedLocation,
                              'latitude': _selectedLat,
                              'longitude': _selectedLng,
                            };
                            
                            // Register the user first using UserService
                            final userService = await UserService.getInstance();
                            await userService.init();
                            
                            // Register user with basic info
                            final user = await userService.registerUser(
                              name: userData['fullName'] ?? userData['name'] ?? 'User',
                              email: userData['email'],
                              password: userData['password'],
                              phone: userData['phone'],
                              address: _selectedLocation ?? _addressController.text,
                              latitude: _selectedLat,
                              longitude: _selectedLng,
                            );
                            
                            // Save location coordinates in user data
                            if (_selectedLat != null && _selectedLng != null) {
                              // Save as a saved address if we have a pinpointed location
                              if (_selectedLocation != null) {
                                List<String> savedAddresses = user.savedAddresses ?? [];
                                if (!savedAddresses.contains(_selectedLocation)) {
                                  savedAddresses.add(_selectedLocation!);
                                  await userService.updateSavedAddresses(savedAddresses);
                                }
                              }
                            }
                            
                            // Mark onboarding complete
                            final signUpService = await SignUpService.getInstance();
                            await signUpService.markOnboardingComplete();
                            
                            // Close loading dialog
                            if (mounted) Navigator.of(context).pop();
                            
                            // Navigate to subscription page with user data
                            if (mounted) {
                              Navigator.pushNamed(
                                context,
                                '/sign-up-subscription',
                                arguments: userData,
                              );
                            }
                          } catch (e) {
                            // Close loading dialog
                            if (mounted) Navigator.of(context).pop();
                            
                            // Show error dialog
                            showAppErrorDialog(
                              title: 'Gagal Mendaftar',
                              message: 'Terjadi kesalahan saat mendaftarkan akun: ${e.toString()}',
                              buttonText: 'Coba Lagi',
                            );
                          }
                        } else if (_selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Silakan pilih lokasi pada peta',
                                style: whiteTextStyle.copyWith(fontSize: 14),
                              ),
                              backgroundColor: redcolor,
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: greyTextStyle.copyWith(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/sign-in');
                          },
                          child: Text(
                            'Sign In',
                            style: greeTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Map Picker Page
<<<<<<< HEAD
class MapPickerPage extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;

  const MapPickerPage({super.key, required this.onLocationSelected});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final _searchController = TextEditingController();
  String _selectedAddress = '';
  double _selectedLat = -7.2575; // Default Surabaya coordinates
  double _selectedLng = 112.7521;
  
<<<<<<< HEAD
  // Map controller
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  
  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  
  // ORS API
  String? _orsApiKey;

  @override
  void initState() {
    super.initState();
    _orsApiKey = dotenv.env['ORS_API_KEY'];
    _getCurrentLocation();
  }
=======
  // Dummy search results
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
>>>>>>> 02b957d (feat: adding & improve sign up)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
<<<<<<< HEAD
  
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, show error
          ToastHelper.showToast(
            context: context,
            message: 'Izin lokasi ditolak. Gunakan pin manual untuk menandai lokasi.',
            isSuccess: false,
          );
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever
        ToastHelper.showToast(
          context: context,
          message: 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengubahnya.',
          isSuccess: false,
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      
      // Get address from coordinates
      final address = await _getAddressFromCoordinates(position.latitude, position.longitude);
      
      setState(() {
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
        _selectedAddress = address;
        _isLoadingLocation = false;
        _isMapReady = true;
      });
      
      // Update map center
      _mapController.move(LatLng(_selectedLat, _selectedLng), 15);
      
    } catch (e) {
      print('Error getting location: $e');
      ToastHelper.showToast(
        context: context,
        message: 'Gagal mendapatkan lokasi. Gunakan pin manual.',
        isSuccess: false,
      );
      setState(() {
        _isLoadingLocation = false;
        _isMapReady = true;
      });
    }
  }
  
  Future<void> _performSearch(String query) async {
=======

  void _performSearch(String query) {
>>>>>>> 02b957d (feat: adding & improve sign up)
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

<<<<<<< HEAD
    if (_orsApiKey == null || _orsApiKey!.isEmpty) {
      ToastHelper.showToast(
        context: context,
        message: 'API key tidak ditemukan. Gunakan pin manual.',
        isSuccess: false,
      );
      return;
    }

=======
>>>>>>> 02b957d (feat: adding & improve sign up)
    setState(() {
      _isSearching = true;
    });

<<<<<<< HEAD
    try {
      // Perform geocoding search using ORS API
      final response = await http.get(
        Uri.parse('https://api.openrouteservice.org/geocode/search?api_key=$_orsApiKey&text=$query&boundary.country=ID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Process results
        List<Map<String, dynamic>> results = [];
        if (data['features'] != null) {
          for (var feature in data['features']) {
            final props = feature['properties'];
            final geometry = feature['geometry'];
            final coordinates = geometry['coordinates'];
            
            if (props['label'] != null && coordinates != null) {
              results.add({
                'address': props['label'],
                'lng': coordinates[0],
                'lat': coordinates[1],
              });
            }
          }
        }
        
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print('Error searching locations: $e');
      ToastHelper.showToast(
        context: context,
        message: 'Gagal mencari lokasi. Coba lagi nanti.',
        isSuccess: false,
      );
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    if (_orsApiKey == null || _orsApiKey!.isEmpty) {
      return 'Lokasi terpilih';
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://api.openrouteservice.org/geocode/reverse?api_key=$_orsApiKey&point.lon=$lng&point.lat=$lat'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null && data['features'].isNotEmpty) {
          return data['features'][0]['properties']['label'] ?? 'Lokasi terpilih';
        }
      }
      
      return 'Lokasi terpilih';
    } catch (e) {
      print('Error getting address: $e');
      return 'Lokasi terpilih';
    }
=======
    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _searchResults = [
          {
            'address': 'Jl. Raya Darmo No. 123, Surabaya, Jawa Timur',
            'lat': -7.2654,
            'lng': 112.7359,
          },
          {
            'address': 'Jl. Tunjungan Plaza, Surabaya, Jawa Timur',
            'lat': -7.2639,
            'lng': 112.7380,
          },
          {
            'address': 'Universitas Airlangga, Surabaya, Jawa Timur',
            'lat': -7.2709,
            'lng': 112.7801,
          },
        ];
        _isSearching = false;
      });
    });
>>>>>>> 02b957d (feat: adding & improve sign up)
  }

  void _selectLocation(String address, double lat, double lng) {
    setState(() {
      _selectedAddress = address;
      _selectedLat = lat;
      _selectedLng = lng;
      _searchResults = [];
      _searchController.clear();
<<<<<<< HEAD
      
      if (_isMapReady) {
        _mapController.move(LatLng(lat, lng), 15);
      }
    });
  }
  
  Future<void> _handleMapTap(LatLng tappedPoint) async {
    setState(() {
      _selectedLat = tappedPoint.latitude;
      _selectedLng = tappedPoint.longitude;
      _isSearching = true;
    });
    
    // Get address from coordinates
    final address = await _getAddressFromCoordinates(_selectedLat, _selectedLng);
    
    setState(() {
      _selectedAddress = address;
      _isSearching = false;
=======
>>>>>>> 02b957d (feat: adding & improve sign up)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: blackColor),
        ),
        title: Text(
          'Pilih Lokasi',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        actions: [
          if (_selectedAddress.isNotEmpty)
            TextButton(
              onPressed: () {
                widget.onLocationSelected(
                  _selectedAddress,
                  _selectedLat,
                  _selectedLng,
                );
                Navigator.pop(context);
              },
              child: Text(
                'Pilih',
                style: greeTextStyle.copyWith(fontWeight: semiBold),
              ),
            ),
        ],
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
<<<<<<< HEAD
            // Real Map
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
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ) :
                  // Loading state
=======
            // Map Placeholder
            Expanded(
              child: Stack(
                children: [
>>>>>>> 02b957d (feat: adding & improve sign up)
                  Container(
                    width: double.infinity,
                    color: greyColor.withOpacity(0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
<<<<<<< HEAD
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat peta...',
                          style: greyTextStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  // Map overlay instructions
                  if (_isMapReady)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tap pada peta untuk menandai lokasi Anda',
                        style: blackTextStyle.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
=======
                        Icon(
                          Icons.map,
                          size: 64,
                          color: greyColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Peta akan ditampilkan di sini',
                          style: greyTextStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap untuk menandai lokasi Anda',
                          style: greyTextStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Crosshair/Pin in center
                  Center(
                    child: Icon(
                      Icons.add,
                      size: 32,
                      color: redcolor,
                    ),
                  ),
>>>>>>> 02b957d (feat: adding & improve sign up)
                  // Current location button
                  Positioned(
                    bottom: 100,
                    right: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: whiteColor,
<<<<<<< HEAD
                      onPressed: _getCurrentLocation,
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.my_location, color: greenColor),
=======
                      onPressed: () {
                        _selectLocation(
                          'Lokasi Saat Ini, Surabaya, Jawa Timur',
                          -7.2575,
                          112.7521,
                        );
                      },
                      child: Icon(Icons.my_location, color: greenColor),
>>>>>>> 02b957d (feat: adding & improve sign up)
                    ),
                  ),
                ],
              ),
            ),

          // Selected Location Display
          if (_selectedAddress.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: greenColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: greenColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Lokasi Terpilih',
                        style: greeTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress,
                    style: blackTextStyle.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
=======
>>>>>>> fef3eca6e643bc33c01547823ba332b867597d34
