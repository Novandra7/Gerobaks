import 'package:bank_sha/services/api_client.dart';

class TrackingApiService {
  TrackingApiService._internal();
  static final TrackingApiService _instance = TrackingApiService._internal();
  factory TrackingApiService() => _instance;

  final ApiClient _api = ApiClient();

  Future<void> postLocation({
    required int scheduleId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    DateTime? recordedAt,
  }) async {
    final body = {
      'schedule_id': scheduleId,
      'latitude': latitude,
      'longitude': longitude,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      if (recordedAt != null) 'recorded_at': recordedAt.toIso8601String(),
    };
    await _api.postJson('/api/tracking', body);
  }

  Future<List<dynamic>> getHistory({
    required int scheduleId,
    int limit = 200,
    DateTime? since,
    DateTime? until,
  }) async {
    final query = <String, dynamic>{
      'schedule_id': scheduleId,
      'limit': limit,
      if (since != null) 'since': since.toIso8601String(),
      if (until != null) 'until': until.toIso8601String(),
    };
    final json = await _api.getJson('/api/tracking', query: query);
    if (json is List) return json;
    return [];
  }
}
