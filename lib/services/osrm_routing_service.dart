import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Service untuk mendapatkan rute jalan yang sebenarnya
/// menggunakan OSRM (Open Source Routing Machine) API
class OsrmRoutingService {
  // Public OSRM instance (gratis)
  static const String _baseUrl = 'https://router.project-osrm.org';

  /// Mendapatkan koordinat rute dari titik A ke titik B
  /// yang mengikuti jalan yang sebenarnya
  /// 
  /// Returns list of LatLng points untuk Polyline, atau null jika gagal
  Future<List<LatLng>?> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('[OSRM DEBUG] 🚀 Starting route request');
      print('[OSRM DEBUG] 📍 Start: lat=${start.latitude}, lon=${start.longitude}');
      print('[OSRM DEBUG] 📍 End: lat=${end.latitude}, lon=${end.longitude}');
      
      // Format: /route/v1/{profile}/{coordinates}
      // profile: driving (untuk mobil/kendaraan bermotor)
      // coordinates: longitude,latitude;longitude,latitude
      // 
      // Parameters:
      // - overview=full: get full geometry
      // - geometries=geojson: format koordinat
      // - alternatives=true: get alternative routes (pilih yang terpendek)
      // - steps=true: detail turn-by-turn instructions
      // - annotations=true: metadata tambahan (speed, duration per segment)
      final url = Uri.parse(
        '$_baseUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson&alternatives=true&steps=true&annotations=true',
      );

      print('[OSRM DEBUG] 🌐 URL: $url');
      print('[OSRM DEBUG] ⏳ Sending HTTP GET request (timeout: 10s)...');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[OSRM DEBUG] ❌ TIMEOUT after 10 seconds!');
          throw TimeoutException('OSRM request timed out');
        },
      );

      print('[OSRM DEBUG] ✅ Response received!');
      print('[OSRM DEBUG] 📊 Status code: ${response.statusCode}');
      print('[OSRM DEBUG] 📦 Response length: ${response.body.length} bytes');

      if (response.statusCode != 200) {
        print('[OSRM DEBUG] ❌ HTTP Error: ${response.statusCode}');
        print('[OSRM DEBUG] Response body: ${response.body}');
        return null;
      }

      print('[OSRM DEBUG] 🔍 Parsing JSON response...');
      final data = json.decode(response.body);

      print('[OSRM DEBUG] 📝 OSRM Response code: ${data['code']}');
      print('[OSRM DEBUG] 🛣️ Routes available: ${data['routes']?.length ?? 0}');

      if (data['code'] != 'Ok') {
        print('[OSRM DEBUG] ❌ OSRM Error code: ${data['code']}');
        print('[OSRM DEBUG] Message: ${data['message'] ?? 'No message'}');
        print('[OSRM DEBUG] Full response: ${response.body}');
        return null;
      }

      if (data['routes'] == null || data['routes'].isEmpty) {
        print('[OSRM DEBUG] ❌ No routes found in response');
        print('[OSRM DEBUG] Full response: ${response.body}');
        return null;
      }

      // Pilih rute terpendek dari alternatives (index 0 biasanya sudah optimal)
      // OSRM mengurutkan routes by duration (tercepat dulu)
      final bestRoute = data['routes'][0];
      print('[OSRM DEBUG] ⏱️ Duration: ${bestRoute['duration']}s, Distance: ${bestRoute['distance']}m');
      
      // Extract coordinates dari GeoJSON
      final geometry = bestRoute['geometry'];
      
      if (geometry == null) {
        print('[OSRM DEBUG] ❌ No geometry in route');
        return null;
      }

      if (geometry['coordinates'] == null) {
        print('[OSRM DEBUG] ❌ No coordinates in geometry');
        return null;
      }

      final coordinates = geometry['coordinates'] as List;
      print('[OSRM DEBUG] 📊 Raw coordinates count: ${coordinates.length}');

      // Convert ke List<LatLng>
      // OSRM returns [longitude, latitude], kita perlu flip
      print('[OSRM DEBUG] 🔄 Converting coordinates to LatLng...');
      
      final routePoints = coordinates.map((coord) {
        // OSRM bisa return int atau double, jadi kita convert ke num dulu baru toDouble()
        final lon = (coord[0] as num).toDouble();
        final lat = (coord[1] as num).toDouble();
        return LatLng(
          lat, // latitude
          lon, // longitude
        );
      }).toList();

      print('[OSRM DEBUG] ✅ Successfully converted ${routePoints.length} route points');
      print('[OSRM DEBUG] First point: lat=${routePoints.first.latitude}, lon=${routePoints.first.longitude}');
      print('[OSRM DEBUG] Last point: lat=${routePoints.last.latitude}, lon=${routePoints.last.longitude}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      return routePoints;
    } catch (e, stackTrace) {
      // Return null jika ada error, caller akan handle
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('[OSRM DEBUG] ❌ EXCEPTION CAUGHT!');
      print('[OSRM DEBUG] Error type: ${e.runtimeType}');
      print('[OSRM DEBUG] Error message: $e');
      print('[OSRM DEBUG] Stack trace:');
      print(stackTrace);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return null;
    }
  }

  /// Mendapatkan estimasi durasi dan jarak dari route
  /// Returns map dengan keys: 'duration' (seconds), 'distance' (meters)
  Future<Map<String, dynamic>?> getRouteDetails({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      // Request dengan alternatives untuk mendapat rute optimal
      final url = Uri.parse(
        '$_baseUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&alternatives=true&continue_straight=false',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);

      print('[OSRM] Response code: ${data['code']}');

      if (data['code'] != 'Ok' || data['routes'] == null || data['routes'].isEmpty) {
        print('[OSRM] ERROR: Invalid response or no routes found');
        return null;
      }

      // Pilih rute tercepat (index 0)
      final bestRoute = data['routes'][0];

      print('Best route duration: ${bestRoute['duration']} seconds, distance: ${bestRoute['distance']} meters');

      return {
        'duration': bestRoute['duration'], // in seconds
        'distance': bestRoute['distance'], // in meters
      };
    } catch (e) {
      return null;
    }
  }
}
