import 'package:bank_sha/models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

extension ScheduleModelFromMap on ScheduleModel {
  static ScheduleModel fromMap(Map<String, dynamic> map) {
    // Parse scheduled datetime
    DateTime scheduledDate = DateTime.parse(map['scheduled_date'] ?? DateTime.now().toIso8601String());
    
    // Parse time slot to TimeOfDay
    String timeSlotStr = map['time_slot'] ?? '08:00';
    List<String> timeParts = timeSlotStr.split(':');
    TimeOfDay timeSlot = TimeOfDay(
      hour: int.parse(timeParts[0]), 
      minute: int.parse(timeParts[1].split(' ')[0])
    );
    
    // Parse location
    double latitude = map['latitude']?.toDouble() ?? 0.0;
    double longitude = map['longitude']?.toDouble() ?? 0.0;
    LatLng location = LatLng(latitude, longitude);
    
    // Map status from API format to enum
    ScheduleStatus status;
    switch (map['status']) {
      case 'pending':
        status = ScheduleStatus.pending;
        break;
      case 'in_progress':
        status = ScheduleStatus.inProgress;
        break;
      case 'completed':
        status = ScheduleStatus.completed;
        break;
      case 'cancelled':
        status = ScheduleStatus.cancelled;
        break;
      default:
        status = ScheduleStatus.pending;
    }
    
    // Map frequency from API to enum
    ScheduleFrequency frequency;
    switch (map['frequency']) {
      case 'once':
        frequency = ScheduleFrequency.once;
        break;
      case 'daily':
        frequency = ScheduleFrequency.daily;
        break;
      case 'weekly':
        frequency = ScheduleFrequency.weekly;
        break;
      case 'bi_weekly':
        frequency = ScheduleFrequency.biWeekly;
        break;
      case 'monthly':
        frequency = ScheduleFrequency.monthly;
        break;
      default:
        frequency = ScheduleFrequency.once;
    }
    
    return ScheduleModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      location: location,
      address: map['address'] ?? '',
      notes: map['notes'],
      status: status,
      frequency: frequency,
      driverId: map['mitra_id']?.toString(),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      wasteType: map['waste_type'],
      estimatedWeight: map['estimated_weight']?.toDouble(),
      isPaid: map['is_paid'] ?? false,
      amount: map['amount']?.toDouble(),
      contactName: map['contact_name'],
      contactPhone: map['contact_phone'],
    );
  }

  static ScheduleModel fromJson(String source) {
    return fromMap(json.decode(source));
  }
}