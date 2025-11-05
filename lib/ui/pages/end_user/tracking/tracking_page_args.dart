import 'package:bank_sha/models/schedule_model.dart';
import 'package:latlong2/latlong.dart';

class TrackingPageArgs {
  TrackingPageArgs({required this.scheduleId, this.destination, this.address});

  final int scheduleId;
  final LatLng? destination;
  final String? address;

  static TrackingPageArgs? from(Object? raw) {
    if (raw == null) return null;

    if (raw is TrackingPageArgs) return raw;

    if (raw is ScheduleModel) {
      final id = _tryParseInt(raw.id);
      if (id == null) return null;
      return TrackingPageArgs(
        scheduleId: id,
        destination: raw.location,
        address: raw.address,
      );
    }

    if (raw is Map) {
      final scheduleId = _tryParseInt(
        raw['scheduleId'] ?? raw['id'] ?? raw['schedule_id'],
      );
      if (scheduleId == null) return null;

      final lat = _tryParseDouble(
        raw['destinationLat'] ?? raw['latitude'] ?? raw['lat'],
      );
      final lng = _tryParseDouble(
        raw['destinationLng'] ?? raw['longitude'] ?? raw['lng'],
      );

      final destination = lat != null && lng != null ? LatLng(lat, lng) : null;

      return TrackingPageArgs(
        scheduleId: scheduleId,
        destination: destination,
        address: raw['address'] as String?,
      );
    }

    return null;
  }
}

int? _tryParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _tryParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
