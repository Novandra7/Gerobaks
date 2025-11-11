import 'package:bank_sha/services/tracking_service.dart';
import 'package:latlong2/latlong.dart';

abstract class TrackingEvent {}

class FetchRoute extends TrackingEvent {
  FetchRoute({this.scheduleId, this.destination});

  final int? scheduleId;
  final LatLng? destination;
}

class UpdateTruckLocation extends TrackingEvent {
  final LatLng position;
  UpdateTruckLocation(this.position);
}

class UpdateDestination extends TrackingEvent {
  final LatLng destination;
  UpdateDestination(this.destination);
}

class TrackingHistoryUpdated extends TrackingEvent {
  TrackingHistoryUpdated({
    required this.scheduleId,
    required this.items,
    this.destination,
  });

  final int scheduleId;
  final List<Tracking> items;
  final LatLng? destination;
}

class TrackingHistoryFailed extends TrackingEvent {
  TrackingHistoryFailed({required this.scheduleId, required this.message});

  final int scheduleId;
  final String message;
}
