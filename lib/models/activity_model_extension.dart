import 'package:bank_sha/models/activity_model_improved.dart';
import 'dart:convert';

extension ActivityModelFromMap on ActivityModel {
  static ActivityModel fromMap(Map<String, dynamic> map) {
    // Parse trashDetails if available
    List<TrashDetail>? trashDetails;
    if (map['trash_details'] != null) {
      trashDetails = (map['trash_details'] as List)
          .map((item) => TrashDetail(
                type: item['type'] ?? 'Umum',
                weight: item['weight']?.toInt() ?? 0,
                points: item['points']?.toInt() ?? 0,
                icon: item['icon'],
              ))
          .toList();
    }

    // Parse photos if available
    List<String>? photoProofs;
    if (map['photo_proofs'] != null) {
      photoProofs = List<String>.from(map['photo_proofs']);
    }

    // Convert status from API format to app format
    String statusText;
    switch (map['status']) {
      case 'pending':
        statusText = 'Dijadwalkan';
        break;
      case 'assigned':
        statusText = 'Dijadwalkan';
        break;
      case 'in_progress':
        statusText = 'Menuju Lokasi';
        break;
      case 'completed':
        statusText = 'Selesai';
        break;
      case 'cancelled':
        statusText = 'Dibatalkan';
        break;
      default:
        statusText = 'Lainnya';
    }

    // Parse date time
    DateTime scheduledDate = DateTime.parse(map['scheduled_at'] ?? DateTime.now().toIso8601String());
    
    return ActivityModel(
      id: map['id'].toString(),
      title: map['title'] ?? 'Pengambilan Sampah',
      address: map['address'] ?? '',
      dateTime: '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year} ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}',
      status: statusText,
      isActive: map['is_active'] ?? true,
      date: scheduledDate,
      trashDetails: trashDetails,
      totalWeight: map['total_weight']?.toInt(),
      totalPoints: map['total_points']?.toInt(),
      photoProofs: photoProofs,
      completedBy: map['completed_by'],
      notes: map['notes'],
    );
  }

  static ActivityModel fromJson(String source) {
    return fromMap(json.decode(source));
  }
}