import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';

class ScheduleApiService {
  ScheduleApiService._internal();
  static final ScheduleApiService _instance = ScheduleApiService._internal();
  factory ScheduleApiService() => _instance;

  final ApiClient _api = ApiClient();

  // Fetch a schedule by ID from backend and return the raw JSON map
  Future<ScheduleApiModel> getScheduleById(int id) async {
    final json = await _api.getJson(ApiRoutes.schedule(id));
    if (json is Map<String, dynamic>) {
      return ScheduleApiModel.fromJson(json);
    }
    throw HttpException('Invalid schedule response for id=$id');
  }

  Future<SchedulePageResult> listSchedules({
    int page = 1,
    int perPage = 50,
    int? assignedTo,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (status != null && status.isNotEmpty && status != 'semua')
        'status': status,
    };

    final json = await _api.getJson(ApiRoutes.schedules, query: query);
    if (json is! Map<String, dynamic>) {
      throw HttpException('Invalid schedules response: ${json.runtimeType}');
    }

    final data = json['data'];
    final items = (data is List)
        ? data
              .whereType<Map<String, dynamic>>()
              .map(ScheduleApiModel.fromJson)
              .toList()
        : <ScheduleApiModel>[];

    return SchedulePageResult(
      items: items,
      currentPage: _asInt(json['current_page']) ?? page,
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']) ?? perPage,
      total: _asInt(json['total']),
    );
  }

  Future<ScheduleApiModel> createSchedule({
    required String title,
    String? description,
    required double latitude,
    required double longitude,
    String? status,
    int? assignedTo,
    DateTime? scheduledAt,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (status != null && status.isNotEmpty) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
    };

    final json = await _api.postJson(ApiRoutes.schedules, body);
    if (json is Map<String, dynamic>) {
      return ScheduleApiModel.fromJson(json);
    }
    throw HttpException(
      'Invalid schedule create response: ${json.runtimeType}',
    );
  }

  Future<ScheduleApiModel> updateSchedule(
    int id, {
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? status,
    int? assignedTo,
    DateTime? scheduledAt,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
    };

    if (body.isEmpty) {
      throw ArgumentError('updateSchedule requires at least one field');
    }

    final json = await _api.patchJson(ApiRoutes.schedule(id), body);
    if (json is Map<String, dynamic>) {
      return ScheduleApiModel.fromJson(json);
    }
    throw HttpException(
      'Invalid schedule update response: ${json.runtimeType}',
    );
  }

  Future<ScheduleApiModel> updateScheduleStatus(int id, String status) {
    return updateSchedule(id, status: status);
  }

  // Pickup Schedule Methods - New API endpoint
  Future<Map<String, dynamic>> createPickupSchedule({
    required String scheduleDay,
    required String wasteTypeScheduled,
    required bool isScheduledActive,
    required String pickupTimeStart,
    required String pickupTimeEnd,
    required bool hasAdditionalWaste,
    List<Map<String, dynamic>>? additionalWastes,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'schedule_day': scheduleDay,
      'waste_type_scheduled': wasteTypeScheduled,
      'is_scheduled_active': isScheduledActive,
      'pickup_time_start': pickupTimeStart,
      'pickup_time_end': pickupTimeEnd,
      'has_additional_waste': hasAdditionalWaste,
      if (additionalWastes != null && additionalWastes.isNotEmpty)
        'additional_wastes': additionalWastes,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final json = await _api.postJson(ApiRoutes.pickupSchedules, body);
    if (json is Map<String, dynamic>) {
      return json;
    }
    throw HttpException(
      'Invalid pickup schedule create response: ${json.runtimeType}',
    );
  }

  Future<Map<String, dynamic>> listPickupSchedules({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty && status != 'semua')
        'status': status,
    };

    final json = await _api.getJson(ApiRoutes.pickupSchedules, query: query);
    if (json is! Map<String, dynamic>) {
      throw HttpException(
        'Invalid pickup schedules response: ${json.runtimeType}',
      );
    }

    return json;
  }
}

class SchedulePageResult {
  SchedulePageResult({
    required this.items,
    required this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  final List<ScheduleApiModel> items;
  final int currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
