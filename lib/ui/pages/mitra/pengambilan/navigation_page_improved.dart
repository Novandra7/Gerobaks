import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_event.dart';
import 'package:bank_sha/blocs/tracking/tracking_state.dart';
import 'package:bank_sha/utils/navigation_helper.dart';
import 'package:bank_sha/utils/responsive_helper.dart';
import 'package:bank_sha/services/tile_provider_service.dart';

class InAppNavigationPage extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const InAppNavigationPage({super.key, required this.scheduleData});

  @override
  State<InAppNavigationPage> createState() => _InAppNavigationPageState();
}

class _InAppNavigationPageState extends State<InAppNavigationPage>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  double _cardOffset = 0.0;
  final double _minCardHeight = 140;
  final double _maxCardHeight = 360;
  bool _isDragging = false;
  bool _showFullNavigation = false;

  // Define missing variables
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    NavigationHelper.registerController(_mapController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TrackingBloc>().add(FetchRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double screenWidth = media.size.width;
    final double cardHeight = _minCardHeight + _cardOffset;
    final double maxDrag = _maxCardHeight - _minCardHeight;
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final bool isLargeScreen = ResponsiveHelper.isLargeScreen(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Navigasi ke Pelanggan',
          style: blackTextStyle.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: greenColor),
            onPressed: () {
              // Show information dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Informasi Navigasi',
                    style: blackTextStyle.copyWith(fontWeight: semiBold),
                  ),
                  content: Text(
                    'Anda dapat menarik kartu ke atas untuk melihat lebih banyak informasi pelanggan. Gunakan peta untuk menavigasi ke lokasi pelanggan.',
                    style: greyTextStyle,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Mengerti', style: greenTextStyle),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map view
          Positioned.fill(
            child: BlocBuilder<TrackingBloc, TrackingState>(
              builder: (context, state) {
                // Real implementation would use the map here
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      'TAMPILAN PETA',
                      style: blackTextStyle.copyWith(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          20,
                        ),
                        fontWeight: medium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation controls
          Positioned(
            right: 16,
            bottom: cardHeight + 16,
            child: Column(
              children: [
                // Zoom controls
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, color: greenColor),
                        onPressed: () {
                          // Zoom in
                        },
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                      IconButton(
                        icon: Icon(Icons.remove, color: greenColor),
                        onPressed: () {
                          // Zoom out
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // Current location button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.my_location, color: greenColor),
                    onPressed: () {
                      // Center on current location
                    },
                  ),
                ),
              ],
            ),
          ),

          // Draggable bottom card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _isDragging = true;
                  _cardOffset = (_cardOffset - details.delta.dy).clamp(
                    0,
                    maxDrag,
                  );
                });
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  _isDragging = false;
                  // Snap to min or max
                  if (_cardOffset > maxDrag / 2) {
                    _cardOffset = maxDrag;
                    _showFullNavigation = true;
                  } else {
                    _cardOffset = 0;
                    _showFullNavigation = false;
                  }
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: _isDragging ? 0 : 250),
                curve: Curves.easeOut,
                height: cardHeight,
                width: screenWidth,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pull indicator
                    Container(
                      width: 48,
                      height: 6,
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Card content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: _isDragging
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              20,
                            ),
                            vertical: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with time and status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: blackColor,
                                        size:
                                            ResponsiveHelper.getResponsiveIconSize(
                                              context,
                                              22,
                                            ),
                                      ),
                                      SizedBox(
                                        width:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              8,
                                            ),
                                      ),
                                      Text(
                                        widget.scheduleData['time_slot'] ??
                                            '09:00 - 11:00',
                                        style: blackTextStyle.copyWith(
                                          fontWeight: semiBold,
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(
                                                context,
                                                16,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          ResponsiveHelper.getResponsiveSpacing(
                                            context,
                                            12,
                                          ),
                                      vertical:
                                          ResponsiveHelper.getResponsiveSpacing(
                                            context,
                                            6,
                                          ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9E6),
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveHelper.getResponsiveRadius(
                                          context,
                                          20,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Menuju Lokasi',
                                      style: TextStyle(
                                        fontWeight: medium,
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              context,
                                              14,
                                            ),
                                        color: const Color(0xFF7A6F1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: ResponsiveHelper.getResponsiveSpacing(
                                  context,
                                  16,
                                ),
                              ),

                              // Customer info card
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveRadius(
                                      context,
                                      24,
                                    ),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6EDC8A),
                                      Color(0xFF00A643),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: greenColor.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Decorative elements
                                    Positioned(
                                      right: -20,
                                      top: -20,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -15,
                                      bottom: -15,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),

                                    // Content
                                    Padding(
                                      padding: EdgeInsets.all(
                                        ResponsiveHelper.getResponsiveSpacing(
                                          context,
                                          20,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Customer info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.scheduleData['customer_name'] ??
                                                          'Wahyu Indra',
                                                      style: whiteTextStyle
                                                          .copyWith(
                                                            fontWeight: bold,
                                                            fontSize:
                                                                ResponsiveHelper.getResponsiveFontSize(
                                                                  context,
                                                                  20,
                                                                ),
                                                            shadows: [
                                                              Shadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 4,
                                                              ),
                                                            ],
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          ResponsiveHelper.getResponsiveSpacing(
                                                            context,
                                                            8,
                                                          ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        // Copy customer name to clipboard
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Nama pelanggan disalin',
                                                            ),
                                                            backgroundColor:
                                                                greenColor,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.copy,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                        size:
                                                            ResponsiveHelper.getResponsiveIconSize(
                                                              context,
                                                              18,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      ResponsiveHelper.getResponsiveSpacing(
                                                        context,
                                                        8,
                                                      ),
                                                ),
                                                Text(
                                                  widget.scheduleData['customer_address'] ??
                                                      'JL. Muso Salim B, Kota Samarinda,\nKalimantan Timur',
                                                  style: whiteTextStyle.copyWith(
                                                    fontSize:
                                                        ResponsiveHelper.getResponsiveFontSize(
                                                          context,
                                                          14,
                                                        ),
                                                    height: 1.4,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      ResponsiveHelper.getResponsiveSpacing(
                                                        context,
                                                        16,
                                                      ),
                                                ),
                                                Wrap(
                                                  spacing:
                                                      ResponsiveHelper.getResponsiveSpacing(
                                                        context,
                                                        8,
                                                      ),
                                                  runSpacing:
                                                      ResponsiveHelper.getResponsiveSpacing(
                                                        context,
                                                        8,
                                                      ),
                                                  children: [
                                                    _buildChip(
                                                      context,
                                                      widget.scheduleData['waste_type'] ??
                                                          'Organik',
                                                    ),
                                                    _buildChip(
                                                      context,
                                                      widget.scheduleData['waste_weight'] ??
                                                          '2 Kg',
                                                    ),
                                                    _buildChip(
                                                      context,
                                                      'Hubungi',
                                                      icon: Icons.phone,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Profile picture
                                          Container(
                                            width:
                                                ResponsiveHelper.getResponsiveWidth(
                                                  context,
                                                  76,
                                                ),
                                            height:
                                                ResponsiveHelper.getResponsiveWidth(
                                                  context,
                                                  76,
                                                ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.person,
                                                size:
                                                    ResponsiveHelper.getResponsiveIconSize(
                                                      context,
                                                      48,
                                                    ),
                                                color: greenColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Extended content (visible when card is expanded)
                              if (_showFullNavigation ||
                                  _cardOffset > maxDrag / 2)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height:
                                          ResponsiveHelper.getResponsiveSpacing(
                                            context,
                                            20,
                                          ),
                                    ),

                                    // Navigation information
                                    Text(
                                      'Informasi Navigasi',
                                      style: blackTextStyle.copyWith(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              context,
                                              18,
                                            ),
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          ResponsiveHelper.getResponsiveSpacing(
                                            context,
                                            12,
                                          ),
                                    ),

                                    // Navigation info card
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                        ResponsiveHelper.getResponsiveSpacing(
                                          context,
                                          16,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getResponsiveRadius(
                                            context,
                                            16,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          _buildInfoRow(
                                            context,
                                            icon: Icons.route,
                                            title: 'Jarak',
                                            value:
                                                '${widget.scheduleData['distance'] ?? '3.2'} km',
                                            iconColor: const Color(0xFF5677FC),
                                          ),
                                          Divider(
                                            height:
                                                ResponsiveHelper.getResponsiveSpacing(
                                                  context,
                                                  24,
                                                ),
                                          ),
                                          _buildInfoRow(
                                            context,
                                            icon: Icons.timer,
                                            title: 'Waktu Tempuh',
                                            value:
                                                '${widget.scheduleData['duration'] ?? '15'} menit',
                                            iconColor: const Color(0xFFFF5722),
                                          ),
                                          Divider(
                                            height:
                                                ResponsiveHelper.getResponsiveSpacing(
                                                  context,
                                                  24,
                                                ),
                                          ),
                                          _buildInfoRow(
                                            context,
                                            icon: Icons.trending_up,
                                            title: 'Ketinggian',
                                            value:
                                                '+${widget.scheduleData['elevation'] ?? '10'} m',
                                            iconColor: const Color(0xFF4CAF50),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      height:
                                          ResponsiveHelper.getResponsiveSpacing(
                                            context,
                                            20,
                                          ),
                                    ),

                                    // Action buttons
                                    Container(
                                      margin: EdgeInsets.only(
                                        top:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              24,
                                            ),
                                        bottom:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              16,
                                            ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              16,
                                            ),
                                        vertical:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              20,
                                            ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.getResponsiveRadius(
                                            context,
                                            16,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildActionButton(
                                            context,
                                            icon: Icons.call,
                                            label: 'Hubungi',
                                            onTap: () {
                                              // Show calling dialog
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text(
                                                    'Hubungi Pelanggan',
                                                    style: blackTextStyle.copyWith(
                                                      fontWeight: semiBold,
                                                      fontSize:
                                                          ResponsiveHelper.getResponsiveFontSize(
                                                            context,
                                                            18,
                                                          ),
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Apakah Anda ingin menghubungi:',
                                                        style: greyTextStyle,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            ResponsiveHelper.getResponsiveSpacing(
                                                              context,
                                                              8,
                                                            ),
                                                      ),
                                                      Text(
                                                        widget.scheduleData['customer_name'] ??
                                                            'Wahyu Indra',
                                                        style: blackTextStyle
                                                            .copyWith(
                                                              fontWeight:
                                                                  semiBold,
                                                            ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            ResponsiveHelper.getResponsiveSpacing(
                                                              context,
                                                              8,
                                                            ),
                                                      ),
                                                      Text(
                                                        widget.scheduleData['phone'] ??
                                                            '+6281234567890',
                                                        style: blackTextStyle
                                                            .copyWith(
                                                              fontWeight:
                                                                  medium,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Text(
                                                        'Batal',
                                                        style: greyTextStyle,
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        // In real app, would use url_launcher to make a phone call
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Menghubungi ${widget.scheduleData['customer_name'] ?? 'Wahyu Indra'}',
                                                            ),
                                                            backgroundColor:
                                                                greenColor,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                      },
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                greenColor,
                                                          ),
                                                      child: Text(
                                                        'Hubungi',
                                                        style: whiteTextStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          _buildActionButton(
                                            context,
                                            icon: Icons.message,
                                            label: 'Pesan',
                                            color: Colors.blue,
                                            onTap: () {
                                              // Show messaging dialog
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Mengirim pesan ke ${widget.scheduleData['customer_name'] ?? 'Wahyu Indra'}',
                                                  ),
                                                  backgroundColor: Colors.blue,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                          _buildActionButton(
                                            context,
                                            icon: Icons.directions,
                                            label: 'Petunjuk',
                                            color: Colors.orange,
                                            onTap: () {
                                              // Show directions
                                              setState(() {
                                                _showFullNavigation =
                                                    !_showFullNavigation;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Add some bottom padding for better spacing
                                    SizedBox(
                                      height:
                                          ResponsiveHelper.getResponsiveSpacing(
                                            context,
                                            16,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 20),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: ResponsiveHelper.getResponsiveIconSize(context, 16),
              color: Colors.white,
            ),
            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 4)),
          ],
          Text(
            label,
            style: whiteTextStyle.copyWith(
              fontWeight: medium,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.getResponsiveWidth(context, 40),
          height: ResponsiveHelper.getResponsiveWidth(context, 40),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveRadius(context, 10),
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: ResponsiveHelper.getResponsiveIconSize(context, 20),
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: greyTextStyle.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveSpacing(context, 2),
              ),
              Text(
                value,
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (_locationUpdateTimer != null) {
      _locationUpdateTimer!.cancel();
      NavigationHelper.unregisterTimer(_locationUpdateTimer!);
      _locationUpdateTimer = null;
    }
    NavigationHelper.unregisterController(_mapController);
    _mapController.dispose();
    super.dispose();
  }

  // New utility method for action buttons
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF4CAF50),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 52),
            height: ResponsiveHelper.getResponsiveHeight(context, 52),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: ResponsiveHelper.getResponsiveIconSize(context, 24),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
          Text(
            label,
            style: blackTextStyle.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for drawing a grid pattern on the map placeholder
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw some random road-like paths
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Main road
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.3);

    // Secondary road
    path.moveTo(size.width * 0.1, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.7);

    canvas.drawPath(path, roadPaint);

    // Draw route path
    final routePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final routePath = Path();
    routePath.moveTo(size.width * 0.5, size.height * 0.9);
    routePath.lineTo(size.width * 0.5, size.height * 0.7);
    routePath.lineTo(size.width * 0.6, size.height * 0.5);
    routePath.lineTo(size.width * 0.8, size.height * 0.3);

    canvas.drawPath(routePath, routePaint);

    // Draw starting point
    final startPoint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.9),
      8,
      startPoint,
    );

    // Draw destination point
    final endPoint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 8, endPoint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
