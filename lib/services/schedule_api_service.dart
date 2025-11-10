import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:intl/intl.dart';

class ScheduleApiService {
  ScheduleApiService._internal();
  static final ScheduleApiService _instance = ScheduleApiService._internal();
  factory ScheduleApiService() => _instance;

  final ApiClient _api = ApiClient();

  Map<String, dynamic> _ensureMap(dynamic value, String context) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    throw FormatException(
      '$context expected Map but received ${value.runtimeType}',
    );
  }

  List<Map<String, dynamic>> _ensureListOfMap(dynamic value, String context) {
    if (value == null) {
      return const [];
    }
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) =>
                item.map((key, dynamic val) => MapEntry(key.toString(), val)),
          )
          .toList(growable: false);
    }
    throw FormatException(
      '$context expected List but received ${value.runtimeType}',
    );
  }

  Map<String, dynamic> _extractDataMap(dynamic payload, String context) {
    final root = _ensureMap(payload, context);
    if (root.containsKey('data')) {
      final data = root['data'];
      if (data == null) {
        return <String, dynamic>{};
      }
      return _ensureMap(data, '$context.data');
    }
    return root;
  }

  Map<String, dynamic> _cleanPayload(Map<String, dynamic> payload) {
    final cleaned = <String, dynamic>{};
    payload.forEach((key, value) {
      if (value != null) {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }

  // Fetch a schedule by ID from backend and return the raw JSON map
  Future<ScheduleApiModel> getScheduleById(int id) async {
    final json = await _api.getJson(ApiRoutes.schedule(id));
    final data = _extractDataMap(json, 'schedule detail');
    return ScheduleApiModel.fromJson(data);
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
      if (assignedTo != null) 'mitra_id': assignedTo,
      if (status != null && status.isNotEmpty && status != 'semua')
        'status': status,
    };

    final json = await _api.getJson(ApiRoutes.schedules, query: query);
    final root = _ensureMap(json, 'schedule list response');
    final data = _extractDataMap(root, 'schedule list');

    final itemsRaw = _ensureListOfMap(data['items'], 'schedule list items');
    final items = itemsRaw
        .map(ScheduleApiModel.fromJson)
        .toList(growable: false);

    final meta = data['meta'] is Map
        ? data['meta'].map((key, dynamic val) => MapEntry(key.toString(), val))
        : <String, dynamic>{};

    return SchedulePageResult(
      items: items,
      currentPage: _asInt(meta['current_page']) ?? page,
      lastPage: _asInt(meta['last_page']),
      perPage: _asInt(meta['per_page']) ?? perPage,
      total: _asInt(meta['total']),
      hasMore: meta['has_more'] == true,
      meta: meta,
      message: root['message']?.toString(),
    );
  }

  Future<ScheduleApiModel> createSchedule(Map<String, dynamic> payload) async {
    final json = await _api.postJson(
      ApiRoutes.schedules,
      _cleanPayload(payload),
    );
    final data = _extractDataMap(json, 'create schedule');
    return ScheduleApiModel.fromJson(data);
  }

  Future<ScheduleApiModel> updateSchedule(
    int id,
    Map<String, dynamic> payload,
  ) async {
    if (payload.isEmpty) {
      throw ArgumentError('updateSchedule requires at least one field');
    }

    final json = await _api.patchJson(
      ApiRoutes.schedule(id),
      _cleanPayload(payload),
    );
    final data = _extractDataMap(json, 'update schedule');
    return ScheduleApiModel.fromJson(data);
  }

  Future<ScheduleApiModel> updateScheduleStatus(int id, String status) {
    return updateSchedule(id, {'status': status});
  }

  /// Create schedule using mobile-specific endpoint (/api/schedules/mobile)
  /// Expected fields: pickup_location (string), scheduled_at (DateTime or String),
  /// optional: dropoff_location, latitude, longitude, notes, waste_items (list)
  Future<ScheduleApiModel> createScheduleMobile({
    required String address,
    required DateTime scheduledAt,
    required double latitude,
    required double longitude,
    required String serviceType,
    String? notes,
    String? paymentMethod,
    List<Map<String, dynamic>>? wasteItems,
  }) async {
    final body = <String, dynamic>{
      'alamat': address,
      'tanggal': DateFormat('yyyy-MM-dd').format(scheduledAt),
      'waktu': DateFormat('HH:mm').format(scheduledAt),
      'koordinat': {'lat': latitude, 'lng': longitude},
      'jenis_layanan': serviceType,
      'metode_pembayaran': paymentMethod ?? 'cash',
      if (notes != null && notes.isNotEmpty) 'catatan': notes,
    };

    if (wasteItems != null && wasteItems.isNotEmpty) {
      body['detail_sampah'] = wasteItems
          .map(
            (item) => {
              'jenis': (item['type'] ?? item['jenis'] ?? 'campuran')
                  .toString()
                  .toLowerCase(),
              if (item['estimated_weight'] != null)
                'perkiraan_berat': item['estimated_weight'],
            },
          )
          .toList();
    }

    final json = await _api.postJson(ApiRoutes.schedulesMobile, body);
    final data = _extractDataMap(json, 'create schedule (mobile)');
    return ScheduleApiModel.fromJson(data);
  }

  /// Convenience method to fetch schedules for a given user id via query
  Future<List<ScheduleApiModel>> getUserSchedules(String userId) async {
    final result = await listSchedules(
      page: 1,
      perPage: 200,
      status: null,
      assignedTo: null,
    );

    return result.items
        .where((schedule) => schedule.userId?.toString() == userId)
        .toList(growable: false);
  }
}

class SchedulePageResult {
  SchedulePageResult({
    required this.items,
    required this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasMore,
    this.meta = const {},
    this.message,
  });

  final List<ScheduleApiModel> items;
  final int currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final bool? hasMore;
  final Map<String, dynamic> meta;
  final String? message;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
