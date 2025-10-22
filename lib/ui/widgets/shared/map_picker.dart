import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bank_sha/shared/theme.dart';

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
  late MapController _mapController;
  LatLng _selectedLocation = const LatLng(
    -6.2088,
    106.8456,
  ); // Default: Jakarta
  String _selectedAddress = '';
  bool _isLoading = false;
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
      _getAddressFromLatLng(_selectedLocation);
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Layanan lokasi tidak aktif. Silakan aktifkan GPS.',
              ),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.',
              ),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_selectedLocation, 15.0);
      await _getAddressFromLatLng(_selectedLocation);
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    if (!mounted) return;
    setState(() => _isGettingAddress = true);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final addressParts = <String>[];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        setState(() {
          _selectedAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
        });
      } else {
        setState(() {
          _selectedAddress =
              'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() {
          _selectedAddress =
              'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingAddress = false);
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLatLng(location);
  }

  void _confirmLocation() {
    widget.onLocationSelected(
      _selectedAddress,
      _selectedLocation.latitude,
      _selectedLocation.longitude,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Pilih Lokasi',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        backgroundColor: whiteColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: blackColor),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: blueColor),
            onPressed: _isLoading ? null : _getCurrentLocation,
            tooltip: 'Lokasi Saya',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: _onMapTap,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.gerobaks.app',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.location_on,
                      size: 50,
                      color: redcolor,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Mendapatkan lokasi...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Address Display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: blueColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isGettingAddress
                                ? Row(
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Mendapatkan alamat...',
                                        style: greyTextStyle.copyWith(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    _selectedAddress.isEmpty
                                        ? 'Ketuk peta untuk memilih lokasi'
                                        : _selectedAddress,
                                    style: blackTextStyle.copyWith(
                                      fontSize: 13,
                                      fontWeight: _selectedAddress.isEmpty
                                          ? regular
                                          : medium,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Confirm Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            (_selectedAddress.isEmpty || _isGettingAddress)
                            ? null
                            : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          disabledBackgroundColor: greyColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Konfirmasi Lokasi',
                          style: whiteTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Hint overlay
          if (!_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: whiteColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, size: 16, color: blueColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ketuk peta atau gunakan tombol lokasi',
                        style: greyTextStyle.copyWith(fontSize: 12),
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
