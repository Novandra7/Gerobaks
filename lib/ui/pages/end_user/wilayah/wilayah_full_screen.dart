import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WilayahFullScreen extends StatefulWidget {
  const WilayahFullScreen({super.key});

  @override
  State<WilayahFullScreen> createState() => _WilayahFullScreenState();
}

class _WilayahFullScreenState extends State<WilayahFullScreen> {
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    // Titik-titik polygon zona hijau
    final List<LatLng> greenZone = [
      LatLng(-0.502473, 117.148738), // Titik A
      LatLng(-0.503042, 117.148523), // Titik B
      LatLng(-0.503959, 117.151090), // Titik C
      LatLng(-0.503240, 117.151347), // Titik D
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Peta (Full Screen tanpa SafeArea)
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-0.5035, 117.1500),
              initialZoom: 17.6,
            ),
            children: [
              // Peta dasar
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
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
                  // Marker tempat sampah 1
                  Marker(
                    point: LatLng(-0.503106, 117.150248),
                    width: 30,
                    height: 60,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/ic_tempat_sampah.png',
                      width: 35,
                      height: 35,
                      color: greenColor,
                    ),
                  ),

                  // Marker tempat sampah 2
                  Marker(
                    point: LatLng(-0.503248, 117.150693),
                    width: 30,
                    height: 60,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/ic_tempat_sampah.png',
                      width: 35,
                      height: 35,
                      color: redcolor,
                    ),
                  ),

                  // Marker tempat sampah 3
                  Marker(
                    point: LatLng(-0.502784, 117.149304),
                    width: 30,
                    height: 60,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/ic_tempat_sampah.png',
                      width: 35,
                      height: 35,
                      color: redcolor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tombol Back Normal (sejajar dengan AppBar)
          if (!isFullScreen)
            Positioned(
              top:
                  MediaQuery.of(context).padding.top + 8, // Status bar + margin
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back,
                        color: greenColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Tombol Full Screen (sejajar dengan AppBar)
          if (!isFullScreen)
            Positioned(
              top:
                  MediaQuery.of(context).padding.top + 8, // Status bar + margin
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isFullScreen = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.fullscreen,
                        color: greenColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Tombol Back Full Screen (sejajar dengan AppBar)
          if (isFullScreen)
            Positioned(
              top:
                  MediaQuery.of(context).padding.top + 8, // Status bar + margin
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back,
                        color: greenColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Tombol Exit Full Screen (sejajar dengan AppBar)
          if (isFullScreen)
            Positioned(
              top:
                  MediaQuery.of(context).padding.top + 8, // Status bar + margin
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isFullScreen = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.fullscreen_exit,
                        color: greenColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Legend/Info Panel (dengan SafeArea untuk bottom)
          if (!isFullScreen)
            Positioned(
              bottom: 0,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(
                    12,
                  ), // Reduced padding from 16 to 12
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🗺️ Peta Wilayah Layanan',
                        style: blackTextStyle.copyWith(
                          fontSize: 14, // Reduced font size from 16 to 14
                          fontWeight: semiBold,
                        ),
                      ),
                      const SizedBox(height: 10), // Reduced from 12 to 10
                      Row(
                        children: [
                          Container(
                            width: 18, // Reduced from 20 to 18
                            height: 18, // Reduced from 20 to 18
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Area Layanan Aktif',
                              style: blackTextStyle.copyWith(
                                fontSize: 11, // Reduced font size from 12 to 11
                                fontWeight: medium,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            'assets/ic_tempat_sampah.png',
                            width: 18, // Reduced from 20 to 18
                            height: 18, // Reduced from 20 to 18
                            color: greenColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tempat Sampah Tersedia',
                              style: blackTextStyle.copyWith(
                                fontSize: 11, // Reduced font size from 12 to 11
                                fontWeight: medium,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            'assets/ic_tempat_sampah.png',
                            width: 18, // Reduced from 20 to 18
                            height: 18, // Reduced from 20 to 18
                            color: redcolor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tempat Sampah Penuh',
                              style: blackTextStyle.copyWith(
                                fontSize: 11, // Reduced font size from 12 to 11
                                fontWeight: medium,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
