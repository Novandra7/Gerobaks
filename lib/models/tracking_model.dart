import 'package:latlong2/latlong.dart';

class TrackingModel {
  final int id;
  final int scheduleId;
  final LatLng location;
  final String status;
  final String? notes;
  final DateTime timestamp;

  TrackingModel({
    required this.id,
    required this.scheduleId,
    required this.location,
    required this.status,
    this.notes,
    required this.timestamp,
  });

  factory TrackingModel.fromMap(Map<String, dynamic> map) {
    return TrackingModel(
      id: map['id'],
      scheduleId: map['schedule_id'],
      location: LatLng(
        double.parse(map['latitude'].toString()),
        double.parse(map['longitude'].toString()),
      ),
      status: map['status'],
      notes: map['notes'],
      timestamp: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'status': status,
      'notes': notes,
      'created_at': timestamp.toIso8601String(),
    };
  }
}
