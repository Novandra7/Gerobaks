import 'package:bank_sha/utils/trash_data_mock.dart';

class TrashDetail {
  final String type; // Jenis sampah (Organik, Plastik, Kertas, dll)
  final int weight; // Berat dalam kg
  final int points; // Poin yang diberikan
  final String? icon; // Icon untuk jenis sampah

  TrashDetail({
    required this.type,
    required this.weight,
    required this.points,
    this.icon,
  });
}

class ActivityModel {
  final String id;
  final String title;
  final String address;
  final String dateTime;
  final String status;
  final bool isActive;
  final DateTime date;

  // Data tambahan untuk pengambilan selesai
  final List<TrashDetail>? trashDetails;
  final int? totalWeight; // dalam kg
  final int? totalPoints;
  final List<String>? photoProofs;
  final String? completedBy;
  final String? notes;

  ActivityModel({
    required this.id,
    required this.title,
    required this.address,
    required this.dateTime,
    required this.status,
    required this.isActive,
    required this.date,
    this.trashDetails,
    this.totalWeight,
    this.totalPoints,
    this.photoProofs,
    this.completedBy,
    this.notes,
  });

  // Helper method untuk mendapatkan kategori dari status
  String getCategory() {
    switch (status.toLowerCase()) {
      case 'dijadwalkan':
        return 'Dijadwalkan';
      case 'diterima mitra':
        return 'Diterima Mitra';
      case 'menuju lokasi':
      case 'mitra menuju lokasi':
        return 'Menuju Lokasi';
      case 'mitra sudah tiba':
        return 'Mitra Sudah Tiba';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Lainnya';
    }
  }

  // Helper method untuk icon
  String getIcon() {
    switch (status.toLowerCase()) {
      case 'dijadwalkan':
        return 'assets/ic_calender_search.png';
      case 'diterima mitra':
        return 'assets/ic_check.png';
      case 'menuju lokasi':
      case 'mitra menuju lokasi':
        return 'assets/ic_truck_otw.png';
      case 'mitra sudah tiba':
        return 'assets/ic_pin.png';
      case 'selesai':
        return 'assets/ic_check.png';
      case 'dibatalkan':
        return 'assets/ic_trash.png';
      default:
        return 'assets/ic_trash.png';
    }
  }
}

// Data contoh aktivitas - menggunakan data mock generator
// Generate 10 aktivitas aktif dan 20 aktivitas riwayat
List<ActivityModel> sampleActivities = [
  ...generateCompletedActivities(10, isActive: true),
  ...generateCompletedActivities(20),
];
