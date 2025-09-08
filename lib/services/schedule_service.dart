import 'dart:convert';
import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class ScheduleService {
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();
  
  final Uuid _uuid = const Uuid();
  late LocalStorageService _localStorage;
  
  // Key for storing schedules in local storage
  static const String _schedulesKey = 'schedules';
  
  // Initialize the service with localStorage
  Future<void> initialize() async {
    _localStorage = await LocalStorageService.getInstance();
    
    // Create empty schedules list if it doesn't exist
    if (await _localStorage.getString(_schedulesKey) == null) {
      await _localStorage.saveString(_schedulesKey, jsonEncode([]));
    }
  }
  
  // Get all schedules
  Future<List<ScheduleModel>> getAllSchedules() async {
    final schedulesJson = await _localStorage.getString(_schedulesKey);
    if (schedulesJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(schedulesJson);
      return decoded.map((item) => ScheduleModel.fromJson(item)).toList();
    } catch (e) {
      print('Error decoding schedules: $e');
      return [];
    }
  }
  
  // Get schedules for a specific user
  Future<List<ScheduleModel>> getUserSchedules(String userId) async {
    final allSchedules = await getAllSchedules();
    return allSchedules.where((schedule) => schedule.userId == userId).toList();
  }
  
  // Get driver schedules
  Future<List<ScheduleModel>> getDriverSchedules(String driverId) async {
    final allSchedules = await getAllSchedules();
    return allSchedules.where((schedule) => schedule.driverId == driverId).toList();
  }
  
  // Get driver schedules for a specific date
  Future<List<ScheduleModel>> getDriverSchedulesByDate(String driverId, DateTime date) async {
    final driverSchedules = await getDriverSchedules(driverId);
    return driverSchedules.where((schedule) {
      return schedule.scheduledDate.year == date.year &&
             schedule.scheduledDate.month == date.month &&
             schedule.scheduledDate.day == date.day;
    }).toList();
  }
  
  // Get schedules for a specific date
  Future<List<ScheduleModel>> getSchedulesByDate(DateTime date) async {
    final allSchedules = await getAllSchedules();
    return allSchedules.where((schedule) {
      return schedule.scheduledDate.year == date.year &&
             schedule.scheduledDate.month == date.month &&
             schedule.scheduledDate.day == date.day;
    }).toList();
  }
  
  // Get user schedules for a specific date
  Future<List<ScheduleModel>> getUserSchedulesByDate(String userId, DateTime date) async {
    final userSchedules = await getUserSchedules(userId);
    return userSchedules.where((schedule) {
      return schedule.scheduledDate.year == date.year &&
             schedule.scheduledDate.month == date.month &&
             schedule.scheduledDate.day == date.day;
    }).toList();
  }
  
  // Add a new schedule using a schedule model
  Future<ScheduleModel?> createSchedule(ScheduleModel schedule) async {
    final newSchedule = ScheduleModel(
      id: _uuid.v4(),
      userId: schedule.userId,
      scheduledDate: schedule.scheduledDate,
      timeSlot: schedule.timeSlot,
      location: schedule.location,
      address: schedule.address,
      notes: schedule.notes,
      status: ScheduleStatus.pending,
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
    
    final allSchedules = await getAllSchedules();
    allSchedules.add(newSchedule);
    
    // Save updated schedules list
    await _localStorage.saveString(_schedulesKey, jsonEncode(allSchedules.map((s) => s.toJson()).toList()));
    
    // Set up notifications for the new schedule
    await _setupScheduleNotifications(newSchedule);
    
    return newSchedule;
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
    final newSchedule = ScheduleModel(
      id: _uuid.v4(),
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
    
    final allSchedules = await getAllSchedules();
    allSchedules.add(newSchedule);
    
    // Save updated schedules list
    await _localStorage.saveString(_schedulesKey, jsonEncode(allSchedules.map((s) => s.toJson()).toList()));
    
    // Set up notifications for the new schedule
    await _setupScheduleNotifications(newSchedule);
    
    return newSchedule;
  }
  
  // Update a schedule
  Future<ScheduleModel?> updateSchedule(ScheduleModel updatedSchedule) async {
    final allSchedules = await getAllSchedules();
    final index = allSchedules.indexWhere((s) => s.id == updatedSchedule.id);
    
    if (index == -1) return null; // Schedule not found
    
    allSchedules[index] = updatedSchedule;
    await _localStorage.saveString(_schedulesKey, jsonEncode(allSchedules.map((s) => s.toJson()).toList()));
    
    // Update notifications for the schedule
    await _setupScheduleNotifications(updatedSchedule);
    
    return updatedSchedule;
  }
  
  // Update schedule status
  Future<ScheduleModel?> updateScheduleStatus(String scheduleId, ScheduleStatus newStatus) async {
    final allSchedules = await getAllSchedules();
    final index = allSchedules.indexWhere((s) => s.id == scheduleId);
    
    if (index == -1) return null; // Schedule not found
    
    // Create updated schedule with new status
    final updatedSchedule = allSchedules[index].copyWith(
      status: newStatus,
      completedAt: newStatus == ScheduleStatus.completed ? DateTime.now() : null,
    );
    
    allSchedules[index] = updatedSchedule;
    await _localStorage.saveString(_schedulesKey, jsonEncode(allSchedules.map((s) => s.toJson()).toList()));
    
    return updatedSchedule;
  }
  
  // Delete a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    final allSchedules = await getAllSchedules();
    final initialLength = allSchedules.length;
    
    final filteredSchedules = allSchedules.where((s) => s.id != scheduleId).toList();
    
    if (filteredSchedules.length == initialLength) {
      return false; // No schedule was removed
    }
    
    await _localStorage.saveString(_schedulesKey, jsonEncode(filteredSchedules.map((s) => s.toJson()).toList()));
    
    // TODO: Remove any notifications for this schedule
    
    return true;
  }
  
  // Assign driver to a schedule
  Future<ScheduleModel?> assignDriver(String scheduleId, String driverId) async {
    final allSchedules = await getAllSchedules();
    final index = allSchedules.indexWhere((s) => s.id == scheduleId);
    
    if (index == -1) return null; // Schedule not found
    
    final updatedSchedule = allSchedules[index].copyWith(driverId: driverId);
    allSchedules[index] = updatedSchedule;
    await _localStorage.saveString(_schedulesKey, jsonEncode(allSchedules.map((s) => s.toJson()).toList()));
    
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
      return !bookedTimeSlots.any((bookedSlot) => 
        bookedSlot.hour == timeSlot.hour && bookedSlot.minute == timeSlot.minute);
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
        frequency: i % 4 == 0 ? ScheduleFrequency.weekly : ScheduleFrequency.once,
        driverId: i % 3 == 0 ? driverId : null,
        wasteType: i % 3 == 0 ? 'Organik' : (i % 3 == 1 ? 'Anorganik' : 'B3'),
        estimatedWeight: (i + 1) * 2.5,
        isPaid: i % 2 == 0,
        amount: (i + 1) * 10000.0,
      );
    }
  }
}
