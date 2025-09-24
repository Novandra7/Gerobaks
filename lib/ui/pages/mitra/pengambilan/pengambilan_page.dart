import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/action_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/detail_pickup.dart';

class PengambilanPage extends StatefulWidget {
  const PengambilanPage({super.key});

  @override
  State<PengambilanPage> createState() => _PengambilanPageState();
}

class _PengambilanPageState extends State<PengambilanPage> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(-0.5, 117.15); // Default to Samarinda
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Add customer marker
    _markers.add(
      Marker(
        markerId: const MarkerId('customer_location'),
        position: const LatLng(-0.51, 117.16),
        infoWindow: const InfoWindow(
          title: 'Wahyu Indra',
          snippet: 'JL. Muso Salim B, Kota Samarinda',
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // Header with gradient
          Column(
            children: [
              _buildHeader(context),
              const Spacer(),
              _buildCustomerCard(context),
            ],
          ),

          // Zoom controls
          Positioned(right: 16, top: 230, child: _buildZoomControls(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF12A448), const Color(0xFF58BA89)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getResponsiveWidth(context, 16),
        ResponsiveHelper.getResponsiveHeight(context, 50),
        ResponsiveHelper.getResponsiveWidth(context, 16),
        ResponsiveHelper.getResponsiveHeight(context, 16),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/logo_light.png',
                  height: 27,
                  width: 148,
                  fit: BoxFit.contain,
                ),
                Row(
                  children: [
                    _buildIconButton(
                      Icons.notifications_outlined,
                      hasBadge: true,
                      onTap: () {
                        // Handle notification tap
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildIconButton(
                      Icons.more_vert,
                      onTap: () {
                        // Handle menu tap
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KT 777 WAN',
                    style: whiteTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DRV-KTM-214',
                    style: whiteTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Menuju Pengambilan',
                style: whiteTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'RT 15',
                      style: whiteTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4E4E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Column(
      children: [
        _buildZoomButton(
          '+',
          onTap: () {
            mapController?.animateCamera(CameraUpdate.zoomIn());
          },
        ),
        const SizedBox(height: 12),
        _buildZoomButton(
          '−',
          onTap: () {
            mapController?.animateCamera(CameraUpdate.zoomOut());
          },
        ),
      ],
    );
  }

  Widget _buildZoomButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: blackTextStyle.copyWith(fontSize: 20, fontWeight: medium),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Pull handle
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Time slot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF4B4003),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '09:00 - 11:00',
                      style: blackTextStyle.copyWith(
                        color: const Color(0xFF4B4003),
                        fontSize: 15,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Menuju Lokasi',
                  style: blackTextStyle.copyWith(
                    color: const Color(0xFF4B4003),
                    fontSize: 15,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),

          // Customer card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.13, 0.09),
                end: Alignment(0.36, 1.79),
                colors: [
                  Color(0xFF5BC487),
                  Color(0xFF54C07F),
                  Color(0xFF45C375),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF93DA97),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Wahyu Indra',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.verified_user,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur',
                              style: whiteTextStyle.copyWith(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      12,
                                    ),
                                fontWeight: regular,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildTag('Organik'),
                                const SizedBox(width: 8),
                                _buildTag('2 Kg'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage('https://placehold.co/90x90'),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactButton(),
                ],
              ),
            ),
          ),

          // Navigation bar at the bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 8),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.call,
                    label: 'Telepon',
                    onTap: () {
                      // Handle call action
                    },
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 16),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.navigation,
                    label: 'Navigasi',
                    onTap: () {
                      // Navigate to DetailPickupPage so user can start navigation flow
                      // Assumption: using a demo schedule id here; replace with real id from data source when available
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const DetailPickupPage(scheduleId: '1'),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 16),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.message,
                    label: 'Pesan',
                    onTap: () {
                      // Handle message action
                    },
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 16),
                  ),
                  buildActionButton(
                    context,
                    icon: Icons.check_circle,
                    label: 'Selesai',
                    onTap: () {
                      // Handle complete action
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF69C28E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 0.7),
      ),
      child: Text(
        label,
        style: whiteTextStyle.copyWith(fontSize: 10, fontWeight: semiBold),
      ),
    );
  }

  Widget _buildContactButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6AC28E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Hubungi Pelanggan',
              style: whiteTextStyle.copyWith(
                fontSize: 12,
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
