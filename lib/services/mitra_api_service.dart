import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/mitra_pickup_schedule.dart';
import '../utils/api_routes.dart';
import '../services/local_storage_service.dart';

class MitraApiService {
  static final MitraApiService _instance = MitraApiService._internal();
  factory MitraApiService() => _instance;
  MitraApiService._internal();

  final Logger _logger = Logger();
  LocalStorageService? _localStorage;

  // Auto-initialize localStorage on first use
  Future<LocalStorageService> get _storage async {
    _localStorage ??= await LocalStorageService.getInstance();
    return _localStorage!;
  }

  // Helper method to get token with auto-initialization
  Future<String> _getToken() async {
    final localStorage = await _storage;
    final token = await localStorage.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  Future<void> initialize() async {
    _localStorage = await LocalStorageService.getInstance();
  }

  /// Get available schedules for mitra (pending schedules)
  Future<Map<String, dynamic>> getAvailableSchedules({
    int page = 1,
    String? wasteType,
    String? area,
    String? date,
  }) async {
    try {
      final token = await _getToken();

      // Build query parameters
      final queryParams = <String, String>{'page': page.toString()};
      if (wasteType != null) queryParams['waste_type'] = wasteType;
      if (area != null) queryParams['area'] = area;
      if (date != null) queryParams['date'] = date;

      final uri = Uri.parse(
        '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupAvailable}',
      ).replace(queryParameters: queryParams);

      _logger.i('🚛 Fetching available schedules (page $page): $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          // Handle both List and Map responses
          List<dynamic> schedulesList;
          Map<String, dynamic>? pagination;

          if (data['data'] is List) {
            // API returns schedules directly in data['data']
            schedulesList = data['data'] as List;
            pagination = null;
          } else if (data['data'] is Map<String, dynamic>) {
            // API returns nested structure with schedules key
            schedulesList = (data['data']['schedules'] as List?) ?? [];
            pagination = data['data']['pagination'] as Map<String, dynamic>?;
          } else {
            schedulesList = [];
            pagination = null;
          }

          final schedules = schedulesList
              .map((json) => MitraPickupSchedule.fromJson(json))
              .toList();

          _logger.i(
            '✅ Loaded ${schedules.length} available schedules (page $page)',
          );

          return {
            'schedules': schedules,
            'pagination': pagination ?? {},
            'has_more':
                schedules.length >=
                20, // If we got 20 items, likely more pages exist
          };
        }

        _logger.w('⚠️ No schedules data in response');
        return {
          'schedules': <MitraPickupSchedule>[],
          'pagination': {},
          'has_more': false,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal memuat jadwal');
      }
    } catch (e) {
      _logger.e('❌ Error fetching available schedules: $e');
      rethrow;
    }
  }

  /// Get schedule detail
  Future<MitraPickupSchedule> getScheduleDetail(int scheduleId) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupDetail(scheduleId)}';
      _logger.i('📋 Fetching schedule detail: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return MitraPickupSchedule.fromJson(data['data']['schedule']);
        }
        throw Exception('Data jadwal tidak ditemukan');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal memuat detail jadwal');
      }
    } catch (e) {
      _logger.e('❌ Error fetching schedule detail: $e');
      rethrow;
    }
  }

  /// Accept schedule (Mitra terima jadwal)
  Future<MitraPickupSchedule> acceptSchedule(int scheduleId) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupAccept(scheduleId)}';
      _logger.i('✅ Accepting schedule: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _logger.i('✅ Schedule accepted successfully');
          return MitraPickupSchedule.fromJson(data['data']['schedule']);
        }
        throw Exception('Gagal menerima jadwal');
      } else if (response.statusCode == 409) {
        throw Exception('Jadwal sudah diterima oleh mitra lain');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal menerima jadwal');
      }
    } catch (e) {
      _logger.e('❌ Error accepting schedule: $e');
      rethrow;
    }
  }

  /// Start journey to pickup location
  Future<void> startJourney(
    int scheduleId, {
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupStartJourney(scheduleId)}';
      _logger.i('🚗 Starting journey: $url');

      final body = <String, dynamic>{};
      if (currentLatitude != null) body['current_latitude'] = currentLatitude;
      if (currentLongitude != null)
        body['current_longitude'] = currentLongitude;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Journey started');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal memulai perjalanan');
      }
    } catch (e) {
      _logger.e('❌ Error starting journey: $e');
      rethrow;
    }
  }

  /// Confirm arrival at pickup location
  Future<void> confirmArrival(
    int scheduleId, {
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupArrive(scheduleId)}';
      _logger.i('📍 Confirming arrival: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Arrival confirmed');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal konfirmasi kedatangan');
      }
    } catch (e) {
      _logger.e('❌ Error confirming arrival: $e');
      rethrow;
    }
  }

  /// Complete pickup with photos and weights
  Future<Map<String, dynamic>> completePickup({
    required int scheduleId,
    required Map<String, double> actualWeights,
    required List<String> photosPaths,
    String? notes,
  }) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupComplete(scheduleId)}';
      _logger.i('📦 Completing pickup: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add actual weights
      actualWeights.forEach((wasteType, weight) {
        request.fields['actual_weights[$wasteType]'] = weight.toString();
      });

      // Add notes
      if (notes != null && notes.isNotEmpty) {
        request.fields['notes'] = notes;
      }

      // Add photos
      for (var i = 0; i < photosPaths.length; i++) {
        final file = await http.MultipartFile.fromPath(
          'photos[]',
          photosPaths[i],
        );
        request.files.add(file);
      }

      _logger.i('📤 Sending request with ${photosPaths.length} photos');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _logger.i('✅ Pickup completed successfully');
          return data['data'];
        }
        throw Exception('Gagal menyelesaikan pengambilan');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal menyelesaikan pengambilan');
      }
    } catch (e) {
      _logger.e('❌ Error completing pickup: $e');
      rethrow;
    }
  }

  /// Cancel schedule
  Future<void> cancelSchedule(int scheduleId, String reason) async {
    try {
      final token = await _getToken();

      final url =
          '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupCancel(scheduleId)}';
      _logger.i('❌ Cancelling schedule: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Schedule cancelled');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal membatalkan jadwal');
      }
    } catch (e) {
      _logger.e('❌ Error cancelling schedule: $e');
      rethrow;
    }
  }

  /// Get mitra's active schedules
  Future<List<MitraPickupSchedule>> getMyActiveSchedules() async {
    try {
      final token = await _getToken();

      final url = '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupMyActive}';
      _logger.i('📋 Fetching active schedules: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Handle both List and Map responses
          List<dynamic> schedulesList;

          if (data['data'] is List) {
            // API returns schedules directly in data['data']
            schedulesList = data['data'] as List;
          } else if (data['data'] is Map<String, dynamic>) {
            // API returns nested structure with schedules key
            schedulesList = (data['data']['schedules'] as List?) ?? [];
          } else {
            schedulesList = [];
          }

          final result = schedulesList
              .map((json) => MitraPickupSchedule.fromJson(json))
              .toList();

          _logger.i('✅ Loaded ${result.length} active schedules');
          return result;
        }
        return [];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal memuat jadwal aktif');
      }
    } catch (e) {
      _logger.e('❌ Error fetching active schedules: $e');
      rethrow;
    }
  }

  /// Get mitra's history (completed schedules)
  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int perPage = 20,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final token = await _getToken();

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;

      final uri = Uri.parse(
        '${ApiRoutes.baseUrl}${ApiRoutes.mitraPickupHistory}',
      ).replace(queryParameters: queryParams);

      _logger.i('📚 Fetching history: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Check if data['data'] is a List (direct schedules) or Map (with nested structure)
          List<dynamic> schedulesList;
          Map<String, dynamic>? pagination;
          Map<String, dynamic>? summary;

          if (data['data'] is List) {
            // API returns schedules directly in data['data']
            schedulesList = data['data'] as List;
            pagination = null;
            summary = null;
          } else if (data['data'] is Map<String, dynamic>) {
            // API returns nested structure with schedules, pagination, summary
            schedulesList = (data['data']['schedules'] as List?) ?? [];
            pagination = data['data']['pagination'] as Map<String, dynamic>?;
            summary = data['data']['summary'] as Map<String, dynamic>?;
          } else {
            schedulesList = [];
            pagination = null;
            summary = null;
          }

          final schedules = schedulesList
              .map((json) => MitraPickupSchedule.fromJson(json))
              .toList();

          _logger.i('✅ Loaded ${schedules.length} history items');

          return {
            'schedules': schedules,
            'pagination': pagination ?? {},
            'summary': summary ?? {},
          };
        }
        return {
          'schedules': <MitraPickupSchedule>[],
          'pagination': {},
          'summary': {},
        };
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal memuat riwayat');
      }
    } catch (e) {
      _logger.e('❌ Error fetching history: $e');
      rethrow;
    }
  }

  /// Get mitra dashboard statistics
  /// Returns real-time statistics from backend
  ///
  /// Backend returns: completed_today, available_schedules, active_hours, pending_pickups
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final localStorage = await _storage;
      final token = await localStorage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final url = '${ApiRoutes.baseUrl}${ApiRoutes.mitraStatistics}';
      _logger.i('📊 Fetching mitra statistics: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final stats = data['data'] as Map<String, dynamic>;
          _logger.i(
            '✅ Statistics loaded: completed=${stats['completed_today']}, '
            'available=${stats['available_schedules']}, active_hours=${stats['active_hours']}, '
            'pending=${stats['pending_pickups']}',
          );
          return stats;
        }
        throw Exception('Data statistik tidak ditemukan');
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal memuat statistik');
      }
    } catch (e) {
      _logger.e('❌ Error fetching statistics: $e');
      rethrow;
    }
  }
}
