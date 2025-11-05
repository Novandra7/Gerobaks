import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';

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
    final response = await _api.postJson(ApiRoutes.trackings, body);

    if (response is Map<String, dynamic>) {
      final success = response['success'];
      if (success is bool && !success) {
        final message = response['message'] ?? 'Gagal mengirim data tracking';
        throw HttpException(message.toString());
      }
    }
  }

  Future<List<Map<String, dynamic>>> getHistory({
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
    final json = await _api.getJson(ApiRoutes.trackings, query: query);
    return _normalizeList(json);
  }

  List<Map<String, dynamic>> _normalizeList(dynamic json) {
    if (json is List) {
      return json.whereType<Map<String, dynamic>>().toList();
    }

    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is List) {
          return inner.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const <Map<String, dynamic>>[];
  }
}
