import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_event.dart';
import 'package:bank_sha/blocs/tracking/tracking_state.dart';
import 'package:bank_sha/utils/navigation_helper.dart';
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
  final double _maxCardHeight = 340;
  bool _isDragging = false;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Navigasi ke Pelanggan',
          style: blackTextStyle.copyWith(fontSize: 18, fontWeight: semiBold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map placeholder (replace with your map widget)
          Positioned.fill(
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text('INI PETA', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          // Draggable Card
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
                  } else {
                    _cardOffset = 0;
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
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      const Color(0xFFB6F0C2).withOpacity(0.5),
                      const Color(0xFF6EDC8A).withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _buildCardContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    // Placeholder data, replace with your dynamic data as needed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.black87,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '09:00 - 11:00',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              Text(
                'Menuju Lokasi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF7A6F1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Color(0xFF6EDC8A), Color(0xFFB6F0C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Wahyu Indra',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.copy,
                                color: Colors.white.withOpacity(0.8),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'JL. Muso Salim B, Kota Samarinda,\nKalimantan Timur, OHIO',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChip('Organik'),
                              _buildChip('2 Kg'),
                              _buildChip(
                                'Hubungi Pelanggan',
                                icon: Icons.phone,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF6EDC8A),
                      ),
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

  Widget _buildChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
}
