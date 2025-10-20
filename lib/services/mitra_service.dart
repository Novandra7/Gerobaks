import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/models/order_model.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:bank_sha/models/activity_model_extension.dart';
import 'package:bank_sha/models/schedule_model_extension.dart';
import 'package:bank_sha/services/api_service_manager_extension.dart';
import 'package:bank_sha/models/tracking_model.dart';
import 'dart:convert';

/// Service untuk mengelola data khusus Mitra (petugas/driver)
class MitraService {
  MitraService._internal();
  static final MitraService _instance = MitraService._internal();
  factory MitraService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get dashboard summary data for mitra
  /// 
  /// Returns active orders, completed orders today, total points, and unread notifications
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      _authManager.requireRole('mitra');
      
      final userData = await _authManager.getCurrentUserData();
      final mitraId = userData['id'];
      
      final response = await _api.getJson(ApiRoutes.mitraDashboard(mitraId));
      
      if (response != null && response['success'] == true) {
        return response['data'];
      }

      throw Exception('Gagal memuat data dashboard');
    } catch (e) {
      print('❌ Failed to get mitra dashboard summary: $e');
      rethrow;
    }
  }

  /// Get assignments for mitra
  /// 
  /// Returns list of scheduled pickups assigned to the mitra
  Future<List<ScheduleModel>> getAssignments({
    String? status,
    DateTime? date,
  }) async {
    try {
      _authManager.requireRole('mitra');
      
      final userData = await _authManager.getCurrentUserData();
      final mitraId = userData['id'];
      
      final query = <String, dynamic>{
        'mitra_id': mitraId,
        if (status != null) 'status': status,
        if (date != null) 'date': date.toIso8601String().split('T').first,
      };

      final response = await _api.getJson(ApiRoutes.schedules, query: query);
      
      if (response != null && response['success'] == true) {
        final List<dynamic> items = response['data']['data'];
        return items.map((item) => ScheduleModelFromMap.fromMap(item)).toList();
      }

      throw Exception('Gagal memuat data penugasan');
    } catch (e) {
      print('❌ Failed to get mitra assignments: $e');
      rethrow;
    }
  }

  /// Get mitra's orders
  /// 
  /// Returns list of orders assigned to the mitra
  Future<List<OrderModel>> getOrders({
    String? status,
  }) async {
    try {
      _authManager.requireRole('mitra');
      
      final userData = await _authManager.getCurrentUserData();
      final mitraId = userData['id'];
      
      final query = <String, dynamic>{
        'mitra_id': mitraId,
        if (status != null) 'status': status,
      };

      final response = await _api.getJson(ApiRoutes.orders, query: query);
      
      if (response != null && response['success'] == true) {
        final List<dynamic> items = response['data']['data'];
        return items.map((item) => OrderModel.fromMap(item)).toList();
      }

      throw Exception('Gagal memuat data order');
    } catch (e) {
      print('❌ Failed to get mitra orders: $e');
      rethrow;
    }
  }

  /// Update order status
  /// 
  /// Changes status of an order to assigned, in_progress, completed, or cancelled
  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    try {
      _authManager.requireRole('mitra');
      
      final response = await _api.patchJson(
        ApiRoutes.orderStatus(orderId), 
        {'status': status}
      );
      
      if (response != null && response['success'] == true) {
        return OrderModel.fromMap(response['data']);
      }

      throw Exception('Gagal memperbarui status order');
    } catch (e) {
      print('❌ Failed to update order status: $e');
      rethrow;
    }
  }

  /// Submit tracking location
  /// 
  /// Records mitra's current location during pickup/delivery
  Future<Map<String, dynamic>> submitTracking({
    required int scheduleId,
    required double latitude,
    required double longitude,
    String? status,
    String? notes,
  }) async {
    try {
      _authManager.requireRole('mitra');
      
      final requestData = {
        'schedule_id': scheduleId,
        'latitude': latitude,
        'longitude': longitude,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.postJson(ApiRoutes.trackings, requestData);
      
      if (response != null && response['success'] == true) {
        return response['data'];
      }

      throw Exception('Gagal mengirim data lokasi');
    } catch (e) {
      print('❌ Failed to submit tracking: $e');
      rethrow;
    }
  }

  /// Get activities for mitra
  /// 
  /// Returns list of activities assigned to the mitra
  Future<List<ActivityModel>> getActivities() async {
    try {
      _authManager.requireRole('mitra');
      
      final userData = await _authManager.getCurrentUserData();
      final mitraId = userData['id'];
      
      final query = <String, dynamic>{
        'mitra_id': mitraId,
      };

      final response = await _api.getJson(ApiRoutes.activities, query: query);
      
      if (response != null && response['success'] == true) {
        final List<dynamic> items = response['data']['data'];
        return items.map((item) => ActivityModelFromMap.fromMap(item)).toList();
      }

      throw Exception('Gagal memuat data aktivitas');
    } catch (e) {
      print('❌ Failed to get mitra activities: $e');
      rethrow;
    }
  }

  /// Get tracking history
  /// 
  /// Returns list of tracking locations for a schedule
  Future<List<TrackingModel>> getTrackingHistory(int scheduleId) async {
    try {
      _authManager.requireRole('mitra');
      
      final query = <String, dynamic>{
        'schedule_id': scheduleId,
      };

      final response = await _api.getJson(ApiRoutes.trackings, query: query);
      
      if (response != null && response['success'] == true) {
        final List<dynamic> items = response['data']['data'];
        return items.map((item) => TrackingModel.fromMap(item)).toList();
      }

      throw Exception('Gagal memuat data riwayat pelacakan');
    } catch (e) {
      print('❌ Failed to get tracking history: $e');
      rethrow;
    }
  }

  /// Update schedule status
  /// 
  /// Changes status of a schedule (pending, assigned, in_progress, completed, cancelled)
  Future<ScheduleModel> updateScheduleStatus(int scheduleId, String status) async {
    try {
      _authManager.requireRole('mitra');
      
      final response = await _api.patchJson(
        ApiRoutes.schedule(scheduleId), 
        {'status': status}
      );
      
      if (response != null && response['success'] == true) {
        return ScheduleModelFromMap.fromMap(response['data']);
      }

      throw Exception('Gagal memperbarui status jadwal');
    } catch (e) {
      print('❌ Failed to update schedule status: $e');
      rethrow;
    }
  }
}