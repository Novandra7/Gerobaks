import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:intl/intl.dart';

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

  /// Create schedule using mobile-specific endpoint (/api/schedules/mobile)
  ///
  /// **PRODUCTION API SPEC** (from OpenAPI 3.0.3 at gerobaks.dumeg.com):
  ///
  /// **REQUIRED FIELDS:**
  /// - alamat: Alamat lengkap pickup (string)
  /// - tanggal: Format YYYY-MM-DD (string, date)
  /// - waktu: Format HH:mm (string)
  /// - koordinat: {lat: float, lng: float} (object)
  /// - jenis_layanan: Service type enum (string)
  ///   * pickup_sampah_organik
  ///   * pickup_sampah_anorganik
  ///   * pickup_sampah_daur_ulang
  ///   * pickup_sampah_b3
  ///   * pickup_sampah_campuran
  ///
  /// **OPTIONAL FIELDS:**
  /// - catatan: Catatan tambahan (string)
  /// - metode_pembayaran: cash | transfer | wallet (string, enum)
  ///
  /// **AUTHORIZATION**: Bearer token, role: end_user
  /// **ENDPOINT**: POST /api/schedules/mobile
  Future<ScheduleApiModel> createScheduleMobile({
    required String address,
    required DateTime scheduledAt,
    required double latitude,
    required double longitude,
    required String serviceType,
    String? notes,
    String? paymentMethod,
    String? wasteType,
    double? estimatedWeight,
    String? contactName,
    String? contactPhone,
    String? frequency,
    List<Map<String, dynamic>>? wasteItems,
  }) async {
    // Build request body according to OpenAPI spec
    final body = <String, dynamic>{
      // REQUIRED fields per API spec
      'alamat': address,
      'tanggal': DateFormat('yyyy-MM-dd').format(scheduledAt),
      'waktu': DateFormat('HH:mm').format(scheduledAt),
      'koordinat': {'lat': latitude, 'lng': longitude},
      'jenis_layanan': serviceType,

      // OPTIONAL fields per API spec
      if (notes != null && notes.isNotEmpty) 'catatan': notes,
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'metode_pembayaran': paymentMethod,

      // WORKAROUND: Backend database requires 'title' field (not in OpenAPI spec)
      // This should be removed once backend migration is fixed
      'title': contactName?.isNotEmpty == true
          ? contactName!
          : 'Permintaan Pengambilan Sampah',
    };

    // NOTE: Additional fields below are NOT in OpenAPI spec but may be accepted by backend
    // If backend rejects them, remove these lines
    if (wasteType != null && wasteType.isNotEmpty) {
      body['jenis_sampah'] = wasteType;
    }
    if (estimatedWeight != null) {
      body['perkiraan_berat'] = estimatedWeight;
    }
    if (contactName != null && contactName.isNotEmpty) {
      body['nama_kontak'] = contactName;
    }
    if (contactPhone != null && contactPhone.isNotEmpty) {
      body['telepon_kontak'] = contactPhone;
    }
    if (frequency != null && frequency.isNotEmpty) {
      body['frekuensi'] = frequency;
    }

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
    if (json is Map<String, dynamic>) {
      return ScheduleApiModel.fromJson(json);
    }
    throw HttpException(
      'Invalid schedule create (mobile) response: ${json.runtimeType}',
    );
  }

  /// Convenience method to fetch schedules for a given user id via query
  Future<List<ScheduleApiModel>> getUserSchedules(String userId) async {
    final json = await _api.getJson(
      ApiRoutes.schedules,
      query: {'user_id': userId},
    );
    if (json is! Map<String, dynamic>) {
      throw HttpException(
        'Invalid schedules response for user: ${json.runtimeType}',
      );
    }

    final data = json['data'];
    final items = (data is List)
        ? data
              .whereType<Map<String, dynamic>>()
              .map(ScheduleApiModel.fromJson)
              .toList()
        : <ScheduleApiModel>[];
    return items;
  }

  /// Mitra accepts a schedule
  Future<dynamic> acceptSchedule(int scheduleId) async {
    final json = await _api.postJson(
      '${ApiRoutes.schedule(scheduleId)}/accept',
      {},
    );
    return json;
  }

  /// Mitra starts the pickup
  Future<dynamic> startSchedule(int scheduleId) async {
    final json = await _api.postJson(
      '${ApiRoutes.schedule(scheduleId)}/start',
      {},
    );
    return json;
  }

  /// Mitra completes the pickup
  Future<dynamic> completeSchedulePickup({
    required int scheduleId,
    double? actualWeight,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      if (actualWeight != null) 'actual_weight': actualWeight,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final json = await _api.postJson(
      '${ApiRoutes.schedule(scheduleId)}/complete',
      body,
    );
    return json;
  }

  /// Cancel schedule with reason
  Future<dynamic> cancelScheduleWithReason({
    required int scheduleId,
    required String reason,
  }) async {
    final body = {'reason': reason};
    final json = await _api.postJson(
      '${ApiRoutes.schedule(scheduleId)}/cancel',
      body,
    );
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
