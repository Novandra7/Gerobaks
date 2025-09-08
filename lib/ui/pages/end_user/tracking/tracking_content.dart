import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../blocs/tracking/tracking_bloc.dart';
import '../../../../blocs/tracking/tracking_event.dart';
import '../../../../blocs/tracking/tracking_state.dart';

class TrackingContent extends StatefulWidget {
  const TrackingContent({super.key});

  @override
  State<TrackingContent> createState() => _TrackingContentState();
}

class _TrackingContentState extends State<TrackingContent> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(FetchRoute());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(-0.5035, 117.1500),
            initialZoom: 17.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.gerobaks.app',
            ),

            // Garis rute
            // if (state.routePoints.isNotEmpty)
            //   PolylineLayer(
            //     polylines: [
            //       Polyline(
            //         points: state.routePoints,
            //         color: Colors.green,
            //         strokeWidth: 4.0,
            //       ),
            //     ],
            //   ),

            // Marker Tujuan
            MarkerLayer(
              markers: [
                Marker(
                  point: state.destination,
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

            // Marker Truk
            // MarkerLayer(
            //   markers: [
            //     Marker(
            //       point: state.truckPosition,
            //       width: 60,
            //       height: 60,
            //       alignment: Alignment.center,
            //       child: Transform.rotate(
            //         angle: state.truckBearing * (math.pi / 1000),
            //         child: Image.asset(
            //           'assets/ic_truck_otw.png',
            //           width: 40,
            //           height: 40,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        );
      },
    );
  }
}
