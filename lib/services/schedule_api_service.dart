import 'package:bank_sha/services/api_client.dart';

class ScheduleApiService {
  ScheduleApiService._internal();
  static final ScheduleApiService _instance = ScheduleApiService._internal();
  factory ScheduleApiService() => _instance;

  final ApiClient _api = ApiClient();

  // Fetch a schedule by ID from backend and return the raw JSON map
  Future<Map<String, dynamic>> getScheduleById(int id) async {
    final json = await _api.getJson('/api/schedules/$id');
    if (json is Map<String, dynamic>) return json;
    throw HttpException('Invalid schedule response for id=$id');
  }
}
