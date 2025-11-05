import 'package:latlong2/latlong.dart';

class TrackingState {
  final int? scheduleId;
  final List<LatLng> routePoints;
  final LatLng truckPosition;
  final LatLng destination;
  final double truckBearing;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  TrackingState({
    this.scheduleId,
    required this.routePoints,
    required this.truckPosition,
    required this.destination,
    required this.truckBearing,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  factory TrackingState.initial({
    int? scheduleId,
    LatLng? truckPosition,
    LatLng? destination,
  }) => TrackingState(
    scheduleId: scheduleId,
    routePoints: const [],
    truckPosition:
        truckPosition ?? LatLng(-0.5043299181420043, 117.14985864364043),
    destination: destination ?? LatLng(-0.5028797174108289, 117.15020096577763),
    truckBearing: 0,
  );

  TrackingState copyWith({
    int? scheduleId,
    List<LatLng>? routePoints,
    LatLng? truckPosition,
    LatLng? destination,
    double? truckBearing,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool resetLastUpdated = false,
  }) {
    return TrackingState(
      scheduleId: scheduleId ?? this.scheduleId,
      routePoints: routePoints ?? this.routePoints,
      truckPosition: truckPosition ?? this.truckPosition,
      destination: destination ?? this.destination,
      truckBearing: truckBearing ?? this.truckBearing,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: resetLastUpdated ? null : (lastUpdated ?? this.lastUpdated),
    );
  }
}
