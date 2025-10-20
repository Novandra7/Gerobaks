import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/action_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
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
              padding: EdgeInsets.only(
                // Add padding at the bottom to accommodate the customer card
                bottom: MediaQuery.of(context).size.height * 0.27,
              ),
            ),
          ),

          // Main content layout
          Column(
            children: [
              _buildHeader(context),
              const Spacer(),
              _buildCustomerCard(context),
            ],
          ),

          // Zoom controls - positioned absolutely
          Positioned(
            right: ResponsiveHelper.getResponsiveWidth(context, 16),
            top: ResponsiveHelper.getResponsiveHeight(context, 230),
            child: _buildZoomControls(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12A448), Color(0xFF58BA89)],
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
        MediaQuery.of(context).padding.top +
            ResponsiveHelper.getResponsiveHeight(context, 16),
        ResponsiveHelper.getResponsiveWidth(context, 16),
        ResponsiveHelper.getResponsiveHeight(context, 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo_light.png',
                height: ResponsiveHelper.getResponsiveHeight(context, 27),
                width:
                    screenWidth * 0.35, // Limit width to a percentage of screen
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback widget if image fails to load
                  return Container(
                    height: ResponsiveHelper.getResponsiveHeight(context, 27),
                    width: screenWidth * 0.35,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gerobaks',
                      style: whiteTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          18,
                        ),
                        fontWeight: semiBold,
                      ),
                    ),
                  );
                },
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
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 12),
                  ),
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
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),

          // Wrap in SingleChildScrollView to handle overflow on small screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(context, 8),
                ),
                Text(
                  'KT 777 WAN',
                  style: whiteTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    fontWeight: medium,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(context, 16),
                ),
                const Icon(Icons.person_outline, color: Colors.white, size: 20),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(context, 8),
                ),
                Text(
                  'DRV-KTM-214',
                  style: whiteTextStyle.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    fontWeight: medium,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 16)),
          Center(
            child: Text(
              'Menuju Pengambilan',
              style: whiteTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                fontWeight: semiBold,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 4),
                  ),
                  Text(
                    'RT 15',
                    style: whiteTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        12,
                      ),
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 8)),
        ],
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
        width: ResponsiveHelper.getResponsiveWidth(context, 40),
        height: ResponsiveHelper.getResponsiveHeight(context, 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
            ),
            if (hasBadge)
              Positioned(
                top: ResponsiveHelper.getResponsiveHeight(context, 8),
                right: ResponsiveHelper.getResponsiveWidth(context, 8),
                child: Container(
                  width: ResponsiveHelper.getResponsiveWidth(context, 8),
                  height: ResponsiveHelper.getResponsiveHeight(context, 8),
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
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 12)),
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
        width: ResponsiveHelper.getResponsiveWidth(context, 36),
        height: ResponsiveHelper.getResponsiveHeight(context, 36),
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
            style: blackTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
              fontWeight: medium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsiveHeight(context, 16),
      ),
      child: Column(
        children: [
          // Pull handle
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 60),
            height: ResponsiveHelper.getResponsiveHeight(context, 5),
            margin: EdgeInsets.only(
              bottom: ResponsiveHelper.getResponsiveHeight(context, 8),
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Time slot
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
              vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
            ),
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
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(context, 8),
                    ),
                    Text(
                      '09:00 - 11:00',
                      style: blackTextStyle.copyWith(
                        color: const Color(0xFF4B4003),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          15,
                        ),
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Menuju Lokasi',
                  style: blackTextStyle.copyWith(
                    color: const Color(0xFF4B4003),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      15,
                    ),
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),

          // Customer card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsiveWidth(context, 16),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Wahyu Indra',
                                  style: whiteTextStyle.copyWith(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          20,
                                        ),
                                    fontWeight: semiBold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveHelper.getResponsiveWidth(
                                  context,
                                  8,
                                ),
                              ),
                              const Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveHeight(
                              context,
                              4,
                            ),
                          ),
                          Text(
                            'JL. Muso Salim B, Kota Samarinda, Kalimantan Timur',
                            style: whiteTextStyle.copyWith(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                12,
                              ),
                              fontWeight: regular,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveHeight(
                              context,
                              16,
                            ),
                          ),
                          Wrap(
                            spacing: ResponsiveHelper.getResponsiveWidth(
                              context,
                              8,
                            ),
                            runSpacing: ResponsiveHelper.getResponsiveHeight(
                              context,
                              8,
                            ),
                            children: [_buildTag('Organik'), _buildTag('2 Kg')],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(context, 12),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.2,
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
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(context, 16),
                ),
                _buildContactButton(),
              ],
            ),
          ),

          // Navigation bar at the bottom
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
              vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
            ),
            margin: EdgeInsets.only(
              top: ResponsiveHelper.getResponsiveHeight(context, 16),
            ),
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
                      // Handle navigation action
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
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(context, 8),
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
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF69C28E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 0.7),
      ),
      child: Text(
        label,
        style: whiteTextStyle.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
          fontWeight: semiBold,
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
          vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF6AC28E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, color: Colors.white, size: 16),
            SizedBox(width: ResponsiveHelper.getResponsiveWidth(context, 8)),
            Text(
              'Hubungi Pelanggan',
              style: whiteTextStyle.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
