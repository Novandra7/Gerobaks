import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bank_sha/config/map_config.dart';

class CartoDBMapWidget extends StatelessWidget {
  final MapController? mapController;
  final LatLng center;
  final double zoom;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final List<Polygon>? polygons;
  final Function(LatLng)? onTap;
  final Widget? attributionWidget;
  final bool showAttributionAlways;
  final bool enableInteraction;
  final EdgeInsets padding;

  const CartoDBMapWidget({
    Key? key,
    this.mapController,
    required this.center,
    this.zoom = 14.0,
    this.markers,
    this.polylines,
    this.polygons,
    this.onTap,
    this.attributionWidget,
    this.showAttributionAlways = true,
    this.enableInteraction = true,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            onTap: onTap != null 
                ? (_, point) => onTap!(point)
                : null,
            interactionOptions: enableInteraction 
                ? const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  )
                : const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
            // Padding managed through the Stack
          ),
          children: [
            // Tile layer using CartoDB
            TileLayer(
              urlTemplate: MapConfig.tileUrl,
              userAgentPackageName: 'com.gerobaks.app',
              subdomains: const ['a', 'b', 'c', 'd'],
              additionalOptions: {
                'useragent': 'Gerobaks App/1.0 (https://gerobaks.com)',
              },
            ),

            // Polygons layer (if provided)
            if (polygons != null && polygons!.isNotEmpty)
              PolygonLayer(polygons: polygons!),

            // Polylines layer (if provided)
            if (polylines != null && polylines!.isNotEmpty)
              PolylineLayer(polylines: polylines!),

            // Markers layer (if provided)
            if (markers != null && markers!.isNotEmpty)
              MarkerLayer(markers: markers!),
          ],
        ),

        // Custom Attribution
        if (attributionWidget != null)
          Positioned(
            bottom: 5,
            right: 5,
            child: attributionWidget!,
          )
        else
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(2),
              color: Colors.white.withOpacity(0.7),
              child: Text(
                MapConfig.attribution,
                style: const TextStyle(color: Colors.black54, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
