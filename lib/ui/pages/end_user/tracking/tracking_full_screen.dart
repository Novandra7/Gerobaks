import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:bank_sha/shared/theme.dart'; // pastikan path ini sesuai

class TrackingFullScreen extends StatefulWidget {
  const TrackingFullScreen({super.key});

  @override
  State<TrackingFullScreen> createState() => _TrackingFullScreenState();
}

class _TrackingFullScreenState extends State<TrackingFullScreen> {
  final LatLng _truckPosition = LatLng(-0.5043299181420043, 117.14985864364043);
  final LatLng _destination = LatLng(-0.5028797174108289, 117.15020096577763);

  List<LatLng> _routePoints = [];
  double _truckBearing = 0.0;
  bool _isPanelExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchRoute();
  }

  // Fungsi untuk menghitung arah (bearing) antara dua titik

  double calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (Math.pi / 180);
    final lon1 = start.longitude * (Math.pi / 180);
    final lat2 = end.latitude * (Math.pi / 180);
    final lon2 = end.longitude * (Math.pi / 180);

    final dLon = lon2 - lon1;

    final y = Math.sin(dLon) * Math.cos(lat2);
    final x =
        Math.cos(lat1) * Math.sin(lat2) -
        Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

    final bearing = Math.atan2(y, x);
    return (bearing * (180 / Math.pi) + 360) % 360;
  }

  Future<void> fetchRoute() async {
    if (!dotenv.isInitialized) {
      print('[ERROR] dotenv belum di-load');
      return;
    }

    final String? apiKey = dotenv.env['ORS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('[ERROR] ORS_API_KEY tidak ditemukan di .env');
      return;
    }

    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${_truckPosition.longitude},${_truckPosition.latitude}&end=${_destination.longitude},${_destination.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates =
            data['features'][0]['geometry']['coordinates'] as List;

        final route = coordinates
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

        double bearing = 0.0;
        if (route.length >= 2) {
          bearing = calculateBearing(route[0], route[1]);
        }

        setState(() {
          _routePoints = route;
          _truckBearing = bearing;
        });
      } else {
        print('Gagal mendapatkan rute: ${response.statusCode}');
      }
    } catch (e) {
      print('Error mengambil rute: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-0.5035, 117.1500),
              initialZoom: 17.2,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.gerobaks.app',
              ),

              // Garis jalur
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.green,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),

              // Marker Tujuan
              MarkerLayer(
                markers: [
                  Marker(
                    point: _destination,
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_pin,
                      size: 35,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              // Marker Truk dengan rotasi
              MarkerLayer(
                markers: [
                  Marker(
                    point: _truckPosition,
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: _truckBearing * (Math.pi / 1000),
                      child: Image.asset(
                        'assets/ic_truck_otw.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tombol Back
          Positioned(
            top: 60,
            left: 20,
            child: Container(
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
          ),

          // Panel Estimasi Bottom Sheet
          _buildBottomEstimationPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomEstimationPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isPanelExpanded
            ? MediaQuery.of(context).size.height * 0.65
            : 130,
        child: Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle dan Quick Info
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isPanelExpanded = !_isPanelExpanded;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Handle drag
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status cepat
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: greenColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping,
                              color: greenColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Truk dalam perjalanan',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                Text(
                                  'Estimasi tiba dalam 15-20 menit',
                                  style: greyTextStyle.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'AKTIF',
                              style: whiteTextStyle.copyWith(
                                fontSize: 10,
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isPanelExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Konten detail (hanya tampil saat expanded)
              if (_isPanelExpanded)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Estimasi Detail
                        _buildDetailedEstimation(),
                        const SizedBox(height: 24),

                        // Timeline Progress
                        _buildProgressTimeline(),
                        const SizedBox(height: 24),

                        // Info Driver
                        _buildDriverInfo(),
                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedEstimation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 Informasi Perjalanan',
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
        ),
        const SizedBox(height: 12),

        // Grid estimasi
        Row(
          children: [
            Expanded(
              child: _buildEstimationCard(
                icon: Icons.access_time,
                label: 'Estimasi Tiba',
                value: '15-20 menit',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEstimationCard(
                icon: Icons.route,
                label: 'Jarak Tersisa',
                value: '2.5 km',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildEstimationCard(
                icon: Icons.speed,
                label: 'Kecepatan',
                value: '35 km/j',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEstimationCard(
                icon: Icons.traffic,
                label: 'Lalu Lintas',
                value: 'Lancar',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstimationCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: greyTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    final steps = [
      {
        'title': 'Pesanan Diterima',
        'time': '14:00',
        'completed': true,
        'description': 'Pesanan sampah telah diterima sistem',
      },
      {
        'title': 'Driver Ditugaskan',
        'time': '14:05',
        'completed': true,
        'description': 'Driver Ahmad telah ditugaskan',
      },
      {
        'title': 'Truk Berangkat',
        'time': '14:15',
        'completed': true,
        'description': 'Truk berangkat dari depot',
      },
      {
        'title': 'Dalam Perjalanan',
        'time': '14:30',
        'completed': true,
        'description': 'Truk sedang menuju lokasi Anda',
      },
      {
        'title': 'Tiba di Lokasi',
        'time': '14:50',
        'completed': false,
        'description': 'Estimasi tiba di lokasi penjemputan',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚛 Timeline Penjemputan',
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
        ),
        const SizedBox(height: 16),

        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;
          final isCompleted = step['completed'] as bool;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? greenColor : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? greenColor
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, color: whiteColor, size: 14)
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: isCompleted ? greenColor : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            step['title'] as String,
                            style: blackTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: isCompleted ? semiBold : medium,
                              color: isCompleted
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            step['time'] as String,
                            style: greyTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: greyTextStyle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: greenColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👨‍💼 Informasi Driver',
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: greenColor,
                child: Text(
                  'A',
                  style: whiteTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmad Rizki',
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: semiBold,
                      ),
                    ),
                    Text(
                      'Truk No. B 5678 DEF',
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: blackTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(152 trips)',
                          style: greyTextStyle.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Aksi hubungi driver
                },
                icon: Icon(Icons.phone, size: 16, color: greenColor),
                label: Text(
                  'Hubungi Driver',
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: greenColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aksi bagikan lokasi
                },
                icon: const Icon(Icons.share_location, size: 16),
                label: Text(
                  'Bagikan Lokasi',
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: medium,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Aksi batal penjemputan
              _showCancelDialog();
            },
            icon: Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
            label: Text(
              'Batalkan Penjemputan',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    DialogHelper.showDeleteConfirmDialog(
      context: context,
      title: 'Batalkan Penjemputan?',
      message: 'Apakah Anda yakin ingin membatalkan penjemputan sampah ini?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
    ).then((confirmed) {
      if (confirmed) {
        // Implementasi logika pembatalan jika pengguna mengkonfirmasi
      }
    });
  }
}
