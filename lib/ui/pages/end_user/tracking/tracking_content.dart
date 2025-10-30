import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';

import '../../../../blocs/tracking/tracking_bloc.dart';
import '../../../../blocs/tracking/tracking_event.dart';
import '../../../../blocs/tracking/tracking_state.dart';
import 'tracking_page_args.dart';

class TrackingContent extends StatefulWidget {
  const TrackingContent({super.key, this.args});

  final TrackingPageArgs? args;

  @override
  State<TrackingContent> createState() => _TrackingContentState();
}

class _TrackingContentState extends State<TrackingContent> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(
      FetchRoute(
        scheduleId: widget.args?.scheduleId,
        destination: widget.args?.destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final routePoints = state.routePoints;
        final hasRoute = routePoints.length >= 2;
        final hasTruckPosition = routePoints.isNotEmpty;
        final center = hasTruckPosition
            ? state.truckPosition
            : state.destination;

        final markers = <Marker>[
          Marker(
            point: state.destination,
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: const Icon(Icons.location_pin, size: 34, color: Colors.red),
          ),
        ];

        if (hasTruckPosition) {
          markers.add(
            Marker(
              point: state.truckPosition,
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: state.truckBearing * (math.pi / 180),
                child: Image.asset(
                  'assets/ic_truck_otw.png',
                  width: 38,
                  height: 38,
                ),
              ),
            ),
          );
        }

        final map = FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: hasTruckPosition ? 17.5 : 16.8,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.gerobaks.app',
            ),
            if (hasRoute)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.green,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        );

        final overlays = <Widget>[map];

        final lastUpdated = state.lastUpdated;
        if (lastUpdated != null) {
          final formatted = DateFormat(
            'HH:mm:ss',
          ).format(lastUpdated.toLocal());
          overlays.add(
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      'Terakhir diperbarui $formatted',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final address = widget.args?.address;
        if (address != null && address.isNotEmpty) {
          overlays.add(
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.error != null && !state.isLoading) {
          overlays.add(
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15),
                alignment: Alignment.center,
                child: _StatusBadge(
                  icon: Icons.error_outline,
                  message: state.error!,
                  iconColor: Colors.redAccent,
                ),
              ),
            ),
          );
        } else if (!state.isLoading && routePoints.isEmpty) {
          overlays.add(
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _StatusBadge(
                      icon: Icons.info_outline,
                      message: state.error ?? 'Belum ada data pelacakan',
                      iconColor: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (state.isLoading) {
          overlays.add(
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        }

        return Stack(children: overlays);
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.message,
    required this.iconColor,
  });

  final IconData icon;
  final String message;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
