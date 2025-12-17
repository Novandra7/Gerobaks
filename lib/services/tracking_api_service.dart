import 'dart:convert';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// API Service untuk GPS Tracking
/// - Mitra: Update location, Get my location
/// - User: Get tracking data
class TrackingApiService {
  TrackingApiService._internal();
  static final TrackingApiService _instance = TrackingApiService._internal();
  factory TrackingApiService() => _instance;

  final ApiClient _api = ApiClient();
  final String baseUrl = 'http://127.0.0.1:8000';

  // ==================== OLD ENDPOINTS (Keep for compatibility) ====================

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
    await _api.postJson(ApiRoutes.trackings, body);
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
    final json = await _api.getJson(ApiRoutes.trackings, query: query);
    if (json is List) return json;
    return [];
  }

  // ==================== NEW GPS TRACKING ENDPOINTS ====================

  /// Get headers dengan Bearer token
  Future<Map<String, String>> _getHeaders() async {
    final localStorage = await LocalStorageService.getInstance();
    final token = await localStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// POST /api/mitra/update-location
  /// Update lokasi GPS mitra secara real-time
  Future<Map<String, dynamic>> updateMitraLocation(Position position) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/mitra/update-location');

      final body = jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      print(
        '🚀 Updating mitra location: ${position.latitude}, ${position.longitude}',
      );

      final response = await http.post(url, headers: headers, body: body);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Location updated successfully');
        return data['data'];
      } else if (response.statusCode == 403) {
        throw Exception('You are not authorized as mitra');
      } else if (response.statusCode == 422) {
        throw Exception('Validation error: ${data['errors']}');
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating mitra location: $e');
      rethrow;
    }
  }

  /// GET /api/mitra/my-location
  /// Get lokasi GPS mitra sendiri
  Future<Map<String, dynamic>> getMyLocation() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/mitra/my-location');

      print('🚀 Fetching my location...');

      final response = await http.get(url, headers: headers);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ My location fetched successfully');
        return data['data'];
      } else if (response.statusCode == 403) {
        throw Exception('You are not authorized as mitra');
      } else {
        throw Exception('Failed to get my location: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching my location: $e');
      rethrow;
    }
  }

  /// GET /api/user/tracking/{schedule_id}
  /// Get tracking data untuk user (lokasi mitra, distance, ETA)
  Future<Map<String, dynamic>> getTrackingData(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/user/tracking/$scheduleId');

      print('🚀 Fetching tracking data for schedule $scheduleId...');

      final response = await http.get(url, headers: headers);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Tracking data fetched successfully');
        return responseData['data'];
      } else if (response.statusCode == 404) {
        throw Exception(responseData['message'] ?? 'Pickup schedule not found');
      } else if (response.statusCode == 403) {
        throw Exception(
          'You do not have permission to view this tracking data',
        );
      } else {
        throw Exception('Failed to get tracking data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching tracking data: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Parse location dari API response
  Map<String, dynamic>? parseLocation(Map<String, dynamic>? locationData) {
    if (locationData == null) return null;

    return {
      'latitude': locationData['latitude'],
      'longitude': locationData['longitude'],
      'last_update': locationData['last_update'],
      'is_active': locationData['is_active'] ?? false,
      'formatted_address':
          locationData['address'] ?? locationData['formatted_address'],
    };
  }

  /// Parse mitra info dari API response
  Map<String, dynamic>? parseMitraInfo(Map<String, dynamic>? mitraData) {
    if (mitraData == null) return null;

    return {
      'id': mitraData['id'],
      'name': mitraData['name'],
      'phone': mitraData['phone'],
      'vehicle_plate': mitraData['vehicle_plate'],
      'photo': mitraData['photo'],
    };
  }

  /// Format distance untuk display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      int meters = (distanceKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceKm.toStringAsFixed(2)} km';
    }
  }

  /// Format ETA untuk display
  String formatETA(int minutes) {
    if (minutes < 1) {
      return 'Kurang dari 1 menit';
    } else if (minutes < 60) {
      return '$minutes menit';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $remainingMinutes menit';
      }
    }
  }

  /// Check jika mitra location aktif (updated dalam 5 menit terakhir)
  bool isLocationActive(String? lastUpdate) {
    if (lastUpdate == null) return false;

    try {
      DateTime lastUpdateTime = DateTime.parse(lastUpdate);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastUpdateTime);

      // Aktif jika update dalam 5 menit terakhir
      return difference.inMinutes <= 5;
    } catch (e) {
      print('❌ Error parsing last update time: $e');
      return false;
    }
  }
}
