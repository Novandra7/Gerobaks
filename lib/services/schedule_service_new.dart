import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Schedule Model untuk API response
class Schedule {
  final int id;
  final String? title;
  final String? description;
  final String area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime scheduledDate;
  final String timeSlot;
  final String status;
  final int? assignedUserId;
  final String? assignedUserName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    this.title,
    this.description,
    required this.area,
    this.address,
    this.latitude,
    this.longitude,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    this.assignedUserId,
    this.assignedUserName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id']?.toInt() ?? 0,
      title: map['title'],
      description: map['description'],
      area: map['area'] ?? '',
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      scheduledDate: DateTime.parse(map['scheduled_date'] ?? DateTime.now().toIso8601String()),
      timeSlot: map['time_slot'] ?? '',
      status: map['status'] ?? 'pending',
      assignedUserId: map['assigned_user_id']?.toInt(),
      assignedUserName: map['assigned_user_name'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'area': area,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduled_date': scheduledDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': status,
      'assigned_user_id': assignedUserId,
      'assigned_user_name': assignedUserName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

/// Service untuk mengelola jadwal penjemputan sampah
class ScheduleService {
  ScheduleService._internal();
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get list of schedules with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 10)
  /// [area] - filter berdasarkan area
  /// [status] - filter berdasarkan status
  Future<Map<String, dynamic>> getSchedules({
    int page = 1,
    int limit = 10,
    String? area,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (area != null) 'area': area,
        if (status != null) 'status': status,
      };

      final response = await _api.getJson(ApiRoutes.schedules, query: query);
      
      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'schedules': (data['data'] as List).map((item) => Schedule.fromMap(item)).toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          }
        };
      }

      throw Exception('Failed to load schedules');
    } catch (e) {
      print('❌ Failed to get schedules: $e');
      rethrow;
    }
  }

  /// Get single schedule by ID
  Future<Schedule> getSchedule(int id) async {
    try {
      final response = await _api.get(ApiRoutes.schedule(id));
      
      if (response != null && response['success'] == true) {
        return Schedule.fromMap(response['data']);
      }

      throw Exception('Schedule not found');
    } catch (e) {
      print('❌ Failed to get schedule $id: $e');
      rethrow;
    }
  }

  /// Create new schedule (requires mitra or admin role)
  Future<Schedule> createSchedule({
    String? title,
    String? description,
    required String area,
    String? address,
    double? latitude,
    double? longitude,
    required DateTime scheduledDate,
    required String timeSlot,
    String? notes,
  }) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra/admin can create

      final requestData = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        'area': area,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'scheduled_date': scheduledDate.toIso8601String(),
        'time_slot': timeSlot,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.postJson(ApiRoutes.schedules, requestData);
      
      if (response != null && response['success'] == true) {
        return Schedule.fromMap(response['data']);
      }

      throw Exception('Failed to create schedule');
    } catch (e) {
      print('❌ Failed to create schedule: $e');
      rethrow;
    }
  }

  /// Create schedule for mobile (end_user format)
  Future<Schedule> createMobileSchedule({
    required String area,
    String? address,
    double? latitude,
    double? longitude,
    required DateTime scheduledDate,
    required String timeSlot,
    String? notes,
  }) async {
    try {
      _authManager.requireRole('end_user'); // Only end_user can create mobile format

      final requestData = {
        'area': area,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'scheduled_date': scheduledDate.toIso8601String(),
        'time_slot': timeSlot,
        if (notes != null) 'notes': notes,
      };

      final response = await _api.postJson(ApiRoutes.schedulesMobile, requestData);
      
      if (response != null && response['success'] == true) {
        return Schedule.fromMap(response['data']);
      }

      throw Exception('Failed to create mobile schedule');
    } catch (e) {
      print('❌ Failed to create mobile schedule: $e');
      rethrow;
    }
  }

  /// Update schedule (requires mitra or admin role)
  Future<Schedule> updateSchedule(int id, {
    String? title,
    String? description,
    String? area,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledDate,
    String? timeSlot,
    String? status,
    String? notes,
  }) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra/admin can update

      final requestData = <String, dynamic>{};
      if (title != null) requestData['title'] = title;
      if (description != null) requestData['description'] = description;
      if (area != null) requestData['area'] = area;
      if (address != null) requestData['address'] = address;
      if (latitude != null) requestData['latitude'] = latitude;
      if (longitude != null) requestData['longitude'] = longitude;
      if (scheduledDate != null) requestData['scheduled_date'] = scheduledDate.toIso8601String();
      if (timeSlot != null) requestData['time_slot'] = timeSlot;
      if (status != null) requestData['status'] = status;
      if (notes != null) requestData['notes'] = notes;

      final response = await _api.patchJson(ApiRoutes.schedule(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Schedule.fromMap(response['data']);
      }

      throw Exception('Failed to update schedule');
    } catch (e) {
      print('❌ Failed to update schedule $id: $e');
      rethrow;
    }
  }

  /// Complete schedule (requires mitra role)
  Future<Schedule> completeSchedule(int id, {String? notes}) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can complete

      final requestData = <String, dynamic>{};
      if (notes != null) requestData['notes'] = notes;

      final response = await _api.postJson(ApiRoutes.scheduleComplete(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Schedule.fromMap(response['data']);
      }

      throw Exception('Failed to complete schedule');
    } catch (e) {
      print('❌ Failed to complete schedule $id: $e');
      rethrow;
    }
  }

  /// Cancel schedule (requires mitra role)
  Future<Schedule> cancelSchedule(int id, {String? reason}) async {
    try {
      _authManager.requireRole('mitra'); // Only mitra can cancel

      final requestData = <String, dynamic>{};
      if (reason != null) requestData['reason'] = reason;

      final response = await _api.postJson(ApiRoutes.scheduleCancel(id), requestData);
      
      if (response != null && response['success'] == true) {
        return Schedule.fromMap(response['data']);
      }

      throw Exception('Failed to cancel schedule');
    } catch (e) {
      print('❌ Failed to cancel schedule $id: $e');
      rethrow;
    }
  }

  /// Get available time slots for scheduling
  List<String> getAvailableTimeSlots() {
    return [
      '06:00-08:00',
      '08:00-10:00',
      '10:00-12:00',
      '12:00-14:00',
      '14:00-16:00',
      '16:00-18:00',
    ];
  }

  /// Get schedule status options
  List<String> getStatusOptions() {
    return ['pending', 'assigned', 'in_progress', 'completed', 'cancelled'];
  }

  /// Check if user can create schedule
  bool canCreateSchedule() {
    return _authManager.isAuthenticated && 
           (_authManager.isMitra || _authManager.isAdmin || _authManager.isEndUser);
  }

  /// Check if user can update schedule
  bool canUpdateSchedule() {
    return _authManager.isAuthenticated && 
           (_authManager.isMitra || _authManager.isAdmin);
  }
}