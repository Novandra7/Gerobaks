import 'dart:convert';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_api_service.dart';
import 'package:bank_sha/services/schedule_service_complete.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  final Uuid _uuid = const Uuid();
  late LocalStorageService _localStorage;
  final ScheduleApiService _remoteService = ScheduleApiService();
  final ScheduleServiceComplete _apiService = ScheduleServiceComplete();
  bool _isInitialized = false;

  // Key for storing schedules in local storage
  static const String _schedulesKey = 'schedules';

  // Initialize the service with localStorage
  Future<void> initialize() async {
    if (_isInitialized) return;
    _localStorage = await LocalStorageService.getInstance();

    // Create empty schedules list if it doesn't exist
    if (await _localStorage.getString(_schedulesKey) == null) {
      await _localStorage.saveString(_schedulesKey, jsonEncode([]));
    }
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Get all schedules
  Future<List<ScheduleModel>> getAllSchedules() async {
    return _syncRemoteSchedules();
  }

  Future<List<ScheduleModel>> _loadLocalSchedules() async {
    final schedulesJson = await _localStorage.getString(_schedulesKey);
    if (schedulesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(schedulesJson);
      return decoded.map((item) => ScheduleModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error decoding schedules: $e');
      return [];
    }
  }

  Future<void> _saveLocalSchedules(List<ScheduleModel> schedules) async {
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await _localStorage.saveString(_schedulesKey, jsonEncode(jsonList));
  }

  Future<void> _upsertLocalSchedule(ScheduleModel schedule) async {
    final schedules = await _loadLocalSchedules();
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      schedules[index] = schedule;
    } else {
      schedules.add(schedule);
    }
    await _saveLocalSchedules(schedules);
  }

  // Get schedules for a specific user
  Future<List<ScheduleModel>> getUserSchedules(String userId) async {
    if (userId.isEmpty) {
      return _syncRemoteSchedules();
    }

    final schedules = await _syncRemoteSchedules(fallbackUserId: userId);
    return schedules.where((schedule) => schedule.userId == userId).toList();
  }

  // Get driver schedules
  Future<List<ScheduleModel>> getDriverSchedules(String driverId) async {
    final assignedTo = int.tryParse(driverId);
    final schedules = await _syncRemoteSchedules(assignedTo: assignedTo);

    return schedules.where((schedule) {
      final currentDriverId = schedule.driverId;
      if (currentDriverId == null) return false;
      if (currentDriverId == driverId) return true;
      if (assignedTo != null && currentDriverId == assignedTo.toString()) {
        return true;
      }
      return false;
    }).toList();
  }

  // Get driver schedules for a specific date
  Future<List<ScheduleModel>> getDriverSchedulesByDate(
    String driverId,
    DateTime date,
  ) async {
    final driverSchedules = await getDriverSchedules(driverId);
    return driverSchedules.where((schedule) {
      return schedule.scheduledDate.year == date.year &&
          schedule.scheduledDate.month == date.month &&
          schedule.scheduledDate.day == date.day;
    }).toList();
  }

  // Get schedules for a specific date
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    final schedules = await _syncRemoteSchedules();
    return schedules.where((schedule) {
      return schedule.scheduledDate.year == date.year &&
          schedule.scheduledDate.month == date.month &&
          schedule.scheduledDate.day == date.day;
    }).toList();
  }

  // Get user schedules for a specific date
  Future<List<ScheduleModel>> getUserSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    final userSchedules = await getUserSchedules(userId);
    return userSchedules.where((schedule) {
      return schedule.scheduledDate.year == date.year &&
          schedule.scheduledDate.month == date.month &&
          schedule.scheduledDate.day == date.day;
    }).toList();
  }

  Future<List<ScheduleModel>> refreshSchedules({
    int page = 1,
    int perPage = 50,
    int? assignedTo,
    String? status,
    String? fallbackUserId,
    bool includeOffline = true,
  }) {
    return _syncRemoteSchedules(
      page: page,
      perPage: perPage,
      assignedTo: assignedTo,
      status: status,
      fallbackUserId: fallbackUserId,
      includeOffline: includeOffline,
    );
  }

  // Add a new schedule using a schedule model
  Future<ScheduleModel?> createSchedule(ScheduleModel schedule) async {
    await _ensureInitialized();
    final fallbackId = _uuid.v4();

    try {
      final scheduledAt = _combineDateAndTime(
        schedule.scheduledDate,
        schedule.timeSlot,
      );

      final apiModel = await _remoteService.createSchedule(
        title: _deriveTitle(schedule),
        description: schedule.address,
        latitude: schedule.location.latitude,
        longitude: schedule.location.longitude,
        status: _statusToApi(schedule.status),
        assignedTo: schedule.driverId != null
            ? int.tryParse(schedule.driverId!)
            : null,
        scheduledAt: scheduledAt,
      );

      final remoteSchedule = _mergeRemoteWithLocal(
        ScheduleModel.fromApi(apiModel),
        schedule.copyWith(id: apiModel.id.toString()),
      );

      await _upsertLocalSchedule(remoteSchedule);
      await _setupScheduleNotifications(remoteSchedule);
      return remoteSchedule;
    } catch (e) {
      debugPrint('Remote createSchedule failed: $e');
    }

    final fallbackSchedule = ScheduleModel(
      id: fallbackId,
      userId: schedule.userId,
      scheduledDate: schedule.scheduledDate,
      timeSlot: schedule.timeSlot,
      location: schedule.location,
      address: schedule.address,
      notes: schedule.notes,
      status: schedule.status,
      frequency: schedule.frequency,
      driverId: schedule.driverId,
      createdAt: DateTime.now(),
      wasteType: schedule.wasteType,
      estimatedWeight: schedule.estimatedWeight,
      isPaid: schedule.isPaid,
      amount: schedule.amount,
      contactName: schedule.contactName,
      contactPhone: schedule.contactPhone,
    );

    await _upsertLocalSchedule(fallbackSchedule);
    await _setupScheduleNotifications(fallbackSchedule);
    return fallbackSchedule;
  }

  // Add a new schedule with individual fields
  Future<ScheduleModel> addSchedule({
    required String userId,
    required DateTime scheduledDate,
    required TimeOfDay timeSlot,
    required LatLng location,
    required String address,
    String? notes,
    required ScheduleFrequency frequency,
    String? driverId,
    String? wasteType,
    double? estimatedWeight,
    required bool isPaid,
    double? amount,
    String? contactName,
    String? contactPhone,
  }) async {
    final schedule = ScheduleModel(
      id: null,
      userId: userId,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      location: location,
      address: address,
      notes: notes,
      status: ScheduleStatus.pending,
      frequency: frequency,
      driverId: driverId,
      createdAt: DateTime.now(),
      wasteType: wasteType,
      estimatedWeight: estimatedWeight,
      isPaid: isPaid,
      amount: amount,
      contactName: contactName,
      contactPhone: contactPhone,
    );

    final created = await createSchedule(schedule);
    if (created == null) {
      throw Exception('Gagal membuat jadwal baru');
    }
    return created;
  }

  // Update a schedule
  Future<ScheduleModel?> updateSchedule(ScheduleModel updatedSchedule) async {
    await _ensureInitialized();
    final schedules = await _loadLocalSchedules();
    final index = schedules.indexWhere((s) => s.id == updatedSchedule.id);
    ScheduleModel? localResult;

    if (index != -1) {
      schedules[index] = updatedSchedule;
      await _saveLocalSchedules(schedules);
      await _setupScheduleNotifications(updatedSchedule);
      localResult = updatedSchedule;
    }

    final remoteId = int.tryParse(updatedSchedule.id ?? '');
    if (remoteId != null) {
      try {
        final scheduledAt = _combineDateAndTime(
          updatedSchedule.scheduledDate,
          updatedSchedule.timeSlot,
        );
        final apiModel = await _remoteService.updateSchedule(
          remoteId,
          title: _deriveTitle(updatedSchedule),
          description: updatedSchedule.address,
          latitude: updatedSchedule.location.latitude,
          longitude: updatedSchedule.location.longitude,
          status: _statusToApi(updatedSchedule.status),
          assignedTo: updatedSchedule.driverId != null
              ? int.tryParse(updatedSchedule.driverId!)
              : null,
          scheduledAt: scheduledAt,
        );

        final remoteModel = _mergeRemoteWithLocal(
          ScheduleModel.fromApi(apiModel),
          updatedSchedule,
        );

        await _upsertLocalSchedule(remoteModel);
        await _setupScheduleNotifications(remoteModel);
        return remoteModel;
      } catch (e) {
        debugPrint('Remote updateSchedule failed: $e');
      }
    }

    return localResult;
  }

  // Update schedule status
  Future<ScheduleModel?> updateScheduleStatus(
    String scheduleId,
    ScheduleStatus newStatus,
  ) async {
    await _ensureInitialized();
    final schedules = await _loadLocalSchedules();
    final index = schedules.indexWhere((s) => s.id == scheduleId);
    ScheduleModel? localResult;

    if (index != -1) {
      final updatedSchedule = schedules[index].copyWith(
        status: newStatus,
        completedAt: newStatus == ScheduleStatus.completed
            ? DateTime.now()
            : null,
      );

      schedules[index] = updatedSchedule;
      await _saveLocalSchedules(schedules);
      await _setupScheduleNotifications(updatedSchedule);
      localResult = updatedSchedule;
    }

    final remoteId = int.tryParse(scheduleId);
    if (remoteId != null) {
      try {
        final apiModel = await _remoteService.updateScheduleStatus(
          remoteId,
          _statusToApi(newStatus),
        );

        final remoteModel = _mergeRemoteWithLocal(
          ScheduleModel.fromApi(apiModel),
          localResult,
        );

        await _upsertLocalSchedule(remoteModel);
        await _setupScheduleNotifications(remoteModel);
        return remoteModel;
      } catch (e) {
        debugPrint('Remote updateScheduleStatus failed: $e');
      }
    }

    return localResult;
  }

  // Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    await _ensureInitialized();
    final allSchedules = await _loadLocalSchedules();
    final initialLength = allSchedules.length;

    final filteredSchedules = allSchedules
        .where((s) => s.id != scheduleId)
        .toList();

    if (filteredSchedules.length == initialLength) {
      return false; // No schedule was removed
    }

    await _saveLocalSchedules(filteredSchedules);

    // TODO: Remove any notifications for this schedule

    return true;
  }

  // Assign driver to a schedule
  Future<ScheduleModel?> assignDriver(
    String scheduleId,
    String driverId,
  ) async {
    await _ensureInitialized();
    final allSchedules = await _loadLocalSchedules();
    final index = allSchedules.indexWhere((s) => s.id == scheduleId);

    if (index == -1) return null; // Schedule not found

    final updatedSchedule = allSchedules[index].copyWith(driverId: driverId);
    allSchedules[index] = updatedSchedule;
    await _saveLocalSchedules(allSchedules);
    await _setupScheduleNotifications(updatedSchedule);

    final remoteId = int.tryParse(scheduleId);
    if (remoteId != null) {
      try {
        final apiModel = await _remoteService.updateSchedule(
          remoteId,
          assignedTo: int.tryParse(driverId),
        );
        final remoteModel = _mergeRemoteWithLocal(
          ScheduleModel.fromApi(apiModel),
          updatedSchedule,
        );
        await _upsertLocalSchedule(remoteModel);
        await _setupScheduleNotifications(remoteModel);
        return remoteModel;
      } catch (e) {
        debugPrint('Remote assignDriver failed: $e');
      }
    }

    return updatedSchedule;
  }

  // Get available time slots for a specific date
  Future<List<TimeOfDay>> getAvailableTimeSlots(DateTime date) async {
    // Define all possible time slots (8:00 to 18:00 with 30 minute intervals)
    final List<TimeOfDay> allTimeSlots = [];
    for (int hour = 8; hour <= 17; hour++) {
      allTimeSlots.add(TimeOfDay(hour: hour, minute: 0));
      allTimeSlots.add(TimeOfDay(hour: hour, minute: 30));
    }
    allTimeSlots.add(const TimeOfDay(hour: 18, minute: 0));

    // Get schedules for the given date
    final schedulesForDate = await getSchedulesByDate(date);

    // Filter out time slots that are already booked
    final bookedTimeSlots = schedulesForDate.map((s) => s.timeSlot).toList();

    return allTimeSlots.where((timeSlot) {
      return !bookedTimeSlots.any(
        (bookedSlot) =>
            bookedSlot.hour == timeSlot.hour &&
            bookedSlot.minute == timeSlot.minute,
      );
    }).toList();
  }

  // Process recurring schedules
  Future<void> processRecurringSchedules() async {
    final allSchedules = await getAllSchedules();
    final now = DateTime.now();

    for (final schedule in allSchedules) {
      // Skip non-recurring schedules and non-completed schedules
      if (schedule.frequency == ScheduleFrequency.once ||
          schedule.status != ScheduleStatus.completed) {
        continue;
      }

      // Check if we need to create a new recurring schedule
      DateTime nextDate;
      switch (schedule.frequency) {
        case ScheduleFrequency.daily:
          nextDate = DateTime(now.year, now.month, now.day + 1);
          break;
        case ScheduleFrequency.weekly:
          nextDate = DateTime(now.year, now.month, now.day + 7);
          break;
        case ScheduleFrequency.biWeekly:
          nextDate = DateTime(now.year, now.month, now.day + 14);
          break;
        case ScheduleFrequency.monthly:
          nextDate = DateTime(now.year, now.month + 1, now.day);
          break;
        default:
          continue; // Skip if it's not recurring
      }

      // Create a new schedule for the next date
      await addSchedule(
        userId: schedule.userId,
        scheduledDate: nextDate,
        timeSlot: schedule.timeSlot,
        location: schedule.location,
        address: schedule.address,
        notes: schedule.notes,
        frequency: schedule.frequency,
        driverId: schedule.driverId,
        wasteType: schedule.wasteType,
        estimatedWeight: schedule.estimatedWeight,
        isPaid: schedule.isPaid,
        amount: schedule.amount,
      );
    }
  }

  Future<List<ScheduleModel>> _syncRemoteSchedules({
    int page = 1,
    int perPage = 50,
    int? assignedTo,
    String? status,
    String? fallbackUserId,
    bool includeOffline = true,
  }) async {
    await _ensureInitialized();

    try {
      final result = await _remoteService.listSchedules(
        page: page,
        perPage: perPage,
        assignedTo: assignedTo,
        status: status,
      );

      final remoteModels = result.items.map(ScheduleModel.fromApi).toList();
      final localSchedules = await _loadLocalSchedules();

      final mergedRemote = remoteModels.map((remote) {
        final localMatch = _findLocalScheduleById(localSchedules, remote.id);
        return _mergeRemoteWithLocal(
          remote,
          localMatch,
          fallbackUserId: fallbackUserId,
        );
      }).toList();

      final remoteIds = mergedRemote
          .map((schedule) => schedule.id)
          .whereType<String>()
          .toSet();

      List<ScheduleModel> offlineSchedules = const [];
      if (includeOffline) {
        offlineSchedules = localSchedules.where((local) {
          final id = local.id;
          if (id == null) return true;
          if (remoteIds.contains(id)) return false;
          return int.tryParse(id) == null;
        }).toList();
      }

      final combined = [...mergedRemote, ...offlineSchedules];
      await _saveLocalSchedules(combined);
      return combined;
    } catch (e) {
      debugPrint('Failed to sync schedules: $e');
      return await _loadLocalSchedules();
    }
  }

  Future<List<ScheduleModel>> fetchSchedulesFromApi({
    int page = 1,
    int perPage = 50,
    int? assignedTo,
    String? status,
  }) async {
    try {
      final result = await _remoteService.listSchedules(
        page: page,
        perPage: perPage,
        assignedTo: assignedTo,
        status: status,
      );
      return result.items.map(ScheduleModel.fromApi).toList();
    } catch (e) {
      debugPrint('Failed to fetch schedules from API: $e');
      return [];
    }
  }

  ScheduleModel? _findLocalScheduleById(
    List<ScheduleModel> schedules,
    String? id,
  ) {
    if (id == null) return null;
    for (final schedule in schedules) {
      if (schedule.id == id) {
        return schedule;
      }
    }
    return null;
  }

  ScheduleModel _mergeRemoteWithLocal(
    ScheduleModel remote,
    ScheduleModel? local, {
    String? fallbackUserId,
  }) {
    if (local == null) {
      return remote.copyWith(userId: fallbackUserId ?? remote.userId);
    }

    return remote.copyWith(
      userId: local.userId,
      notes: local.notes ?? remote.notes,
      frequency: local.frequency,
      wasteType: local.wasteType ?? remote.wasteType,
      estimatedWeight: local.estimatedWeight ?? remote.estimatedWeight,
      isPaid: local.isPaid,
      amount: local.amount ?? remote.amount,
      contactName: local.contactName ?? remote.contactName,
      contactPhone: local.contactPhone ?? remote.contactPhone,
      driverId: local.driverId ?? remote.driverId,
    );
  }

  String _deriveTitle(ScheduleModel schedule) {
    final contact = schedule.contactName?.trim();
    if (contact != null && contact.isNotEmpty) {
      return contact.length > 255 ? contact.substring(0, 255) : contact;
    }

    final address = schedule.address.trim();
    if (address.isNotEmpty) {
      final truncated = address.length > 255
          ? address.substring(0, 255)
          : address;
      return truncated;
    }

    final fallback = 'Jadwal ${schedule.userId}'.trim();
    return fallback.length > 255 ? fallback.substring(0, 255) : fallback;
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _statusToApi(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.pending:
        return 'pending';
      case ScheduleStatus.inProgress:
        return 'in_progress';
      case ScheduleStatus.completed:
        return 'completed';
      case ScheduleStatus.cancelled:
        return 'cancelled';
      case ScheduleStatus.missed:
        return 'missed';
    }
  }

  // Set up notifications for a schedule
  Future<void> _setupScheduleNotifications(ScheduleModel schedule) async {
    // TODO: Implement notifications for schedules
    // This will be implemented when integrating with notification_service.dart
  }

  // Generate test data (for development purposes)
  Future<void> generateTestData(String userId, String driverId) async {
    final now = DateTime.now();
    final location = LatLng(-0.5028797174108289, 117.15020096577763);

    // Create schedules for today and next 7 days
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      final timeSlot = TimeOfDay(hour: 9 + i % 8, minute: (i % 2) * 30);

      await addSchedule(
        userId: userId,
        scheduledDate: date,
        timeSlot: timeSlot,
        location: location,
        address: 'Jl. Test Alamat #$i, Samarinda',
        notes: 'Catatan untuk pengambilan #$i',
        frequency: i % 4 == 0
            ? ScheduleFrequency.weekly
            : ScheduleFrequency.once,
        driverId: i % 3 == 0 ? driverId : null,
        wasteType: i % 3 == 0 ? 'Organik' : (i % 3 == 1 ? 'Anorganik' : 'B3'),
        estimatedWeight: (i + 1) * 2.5,
        isPaid: i % 2 == 0,
        amount: (i + 1) * 10000.0,
      );
    }
  }

  // NEW METHOD: Create schedule with multiple waste items
  Future<ScheduleModel> createScheduleWithWasteItems({
    required String date,
    required String time,
    required String address,
    required double latitude,
    required double longitude,
    required List<dynamic> wasteItems, // WasteItem from event
    String? notes,
  }) async {
    await _ensureInitialized();

    // Convert date string (YYYY-MM-DD) to DateTime
    final dateParts = date.split('-');
    final scheduledDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    // Convert time string (HH:mm) to TimeOfDay
    final timeParts = time.split(':');
    final timeSlot = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // Create schedule model with new waste items
    final schedule = ScheduleModel(
      id: null,
      userId: '', // Will be set by API/context
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      location: LatLng(latitude, longitude),
      address: address,
      notes: notes,
      status: ScheduleStatus.pending,
      frequency: ScheduleFrequency.once,
      driverId: null,
      createdAt: DateTime.now(),
      wasteItems: wasteItems.cast<dynamic>(),
      isPaid: false,
    );

    final created = await createSchedule(schedule);
    if (created == null) {
      throw Exception('Gagal membuat jadwal baru');
    }
    return created;
  }

  // NEW METHOD: Update schedule with multiple waste items
  Future<ScheduleModel> updateScheduleWithWasteItems({
    required String scheduleId,
    String? date,
    String? time,
    String? address,
    double? latitude,
    double? longitude,
    List<dynamic>? wasteItems,
    String? status,
    String? notes,
  }) async {
    await _ensureInitialized();

    // Get existing schedule
    final schedules = await _loadLocalSchedules();
    final index = schedules.indexWhere((s) => s.id == scheduleId);

    if (index == -1) {
      throw Exception('Jadwal tidak ditemukan');
    }

    final existingSchedule = schedules[index];

    // Parse date if provided
    DateTime? scheduledDate;
    if (date != null) {
      final dateParts = date.split('-');
      scheduledDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
    }

    // Parse time if provided
    TimeOfDay? timeSlot;
    if (time != null) {
      final timeParts = time.split(':');
      timeSlot = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    // Parse status if provided
    ScheduleStatus? newStatus;
    if (status != null) {
      newStatus = ScheduleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () => existingSchedule.status,
      );
    }

    // Update schedule
    final updatedSchedule = existingSchedule.copyWith(
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      address: address,
      location: (latitude != null && longitude != null)
          ? LatLng(latitude, longitude)
          : null,
      wasteItems: wasteItems?.cast<dynamic>(),
      status: newStatus,
      notes: notes,
    );

    final updated = await updateSchedule(updatedSchedule);
    if (updated == null) {
      throw Exception('Gagal mengupdate jadwal');
    }
    return updated;
  }

  // ============================================================================
  // MITRA ACTIONS - Call backend API endpoints
  // ============================================================================

  /// Mitra accepts a schedule
  Future<dynamic> acceptSchedule(String scheduleId) async {
    try {
      final id = int.parse(scheduleId);
      return await _apiService.acceptSchedule(id);
    } catch (e) {
      debugPrint('Error accepting schedule: $e');
      rethrow;
    }
  }

  /// Mitra starts the pickup
  Future<dynamic> startSchedule(String scheduleId) async {
    try {
      final id = int.parse(scheduleId);
      return await _apiService.startSchedule(id);
    } catch (e) {
      debugPrint('Error starting schedule: $e');
      rethrow;
    }
  }

  /// Mitra completes the pickup
  Future<dynamic> completeSchedule({
    required String scheduleId,
    double? actualWeight,
    String? notes,
  }) async {
    try {
      final id = int.parse(scheduleId);
      return await _apiService.completeSchedulePickup(
        scheduleId: id,
        actualWeight: actualWeight,
        notes: notes,
      );
    } catch (e) {
      debugPrint('Error completing schedule: $e');
      rethrow;
    }
  }

  /// Cancel schedule with reason
  Future<dynamic> cancelScheduleWithReason({
    required String scheduleId,
    required String reason,
  }) async {
    try {
      final id = int.parse(scheduleId);
      return await _apiService.cancelScheduleWithReason(
        scheduleId: id,
        reason: reason,
      );
    } catch (e) {
      debugPrint('Error cancelling schedule: $e');
      rethrow;
    }
  }
}
