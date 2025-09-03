import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TambahJadwalPage extends StatefulWidget {
  const TambahJadwalPage({super.key});

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = LatLng(-0.5028797174108289, 117.15020096577763);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Peta dengan FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 18.0,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _currentCenter = position.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.gerobaks.app',
              ),
            ],
          ),

          // Marker tetap di tengah layar
          Center(child: Icon(Icons.location_pin, size: 40, color: greenColor)),

          // Tombol Back dan informasi lokasi
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Back dengan border hijau
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: greenColor, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: whiteColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: blackColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Informasi lokasi
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: greenColor, width: 2),
                    ),
                    child: Text(
                      'Lokasi: ${_currentCenter.latitude.toStringAsFixed(6)}, ${_currentCenter.longitude.toStringAsFixed(6)}',
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Simpan Lokasi di bawah
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: CustomFilledButton(
              title: 'Tambah Jadwal',
              onPressed: () {
                // Tindakan saat tombol ditekan
                print('Takmbah Jadwal: $_currentCenter');
                // onPressed: () {
                // Navigator.pushNamed(context, '/tracking');
              },
            ),
          ),
        ],
      ),
    );
  }
}
