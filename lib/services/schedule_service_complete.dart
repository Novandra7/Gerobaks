import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Service helper khusus aksi jadwal untuk peran mitra/admin
/// Menggunakan endpoint backend produksi (Gerobaks API)
class ScheduleServiceComplete {
  ScheduleServiceComplete._();
  static final ScheduleServiceComplete _instance = ScheduleServiceComplete._();
  factory ScheduleServiceComplete() => _instance;

  final ApiClient _api = ApiClient();

  /// Mitra menerima jadwal (ubah status menjadi confirmed)
  Future<dynamic> acceptSchedule(int scheduleId) {
    return _api.patchJson(
      ApiRoutes.schedule(scheduleId),
      {
        'status': 'confirmed',
      },
    );
  }

  /// Mitra memulai penjemputan (ubah status menjadi in_progress)
  Future<dynamic> startSchedule(int scheduleId) {
    return _api.patchJson(
      ApiRoutes.schedule(scheduleId),
      {
        'status': 'in_progress',
      },
    );
  }

  /// Mitra menyelesaikan jadwal
  /// Backend menerima completion_notes dan actual_duration (menit)
  Future<dynamic> completeSchedulePickup({
    required int scheduleId,
    double? actualWeight,
    String? notes,
  }) {
    final segments = <String>[];
    if (actualWeight != null) {
      final weightText = actualWeight % 1 == 0
          ? actualWeight.toStringAsFixed(0)
          : actualWeight.toStringAsFixed(2);
      segments.add('Berat aktual: $weightText kg');
    }
    if (notes != null && notes.isNotEmpty) {
      segments.add(notes);
    }

    final body = <String, dynamic>{
      if (segments.isNotEmpty) 'completion_notes': segments.join(' - '),
    };

    return _api.postJson(
      ApiRoutes.scheduleComplete(scheduleId),
      body,
    );
  }

  /// Mitra membatalkan jadwal dengan alasan
  Future<dynamic> cancelScheduleWithReason({
    required int scheduleId,
    required String reason,
  }) {
    return _api.postJson(
      ApiRoutes.scheduleCancel(scheduleId),
      {
        'cancellation_reason': reason,
      },
    );
  }
}
