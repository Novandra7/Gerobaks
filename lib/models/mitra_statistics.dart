/// Model for Mitra Dashboard Statistics
///
/// Represents real-time statistics for mitra dashboard
class MitraStatistics {
  final int completedToday;
  final double rating;
  final int activeHours;
  final int pendingPickups;

  MitraStatistics({
    required this.completedToday,
    required this.rating,
    required this.activeHours,
    required this.pendingPickups,
  });

  factory MitraStatistics.fromJson(Map<String, dynamic> json) {
    return MitraStatistics(
      completedToday: json['completed_today'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      activeHours: json['active_hours'] ?? 0,
      pendingPickups: json['pending_pickups'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_today': completedToday,
      'rating': rating,
      'active_hours': activeHours,
      'pending_pickups': pendingPickups,
    };
  }

  /// Check if rating is available
  /// Backend currently always returns 0.0 (not implemented yet)
  bool get hasRating => rating > 0;

  /// Get formatted rating display
  String get ratingDisplay => hasRating ? rating.toStringAsFixed(1) : 'N/A';

  /// Get formatted active hours display
  String get activeHoursDisplay => '${activeHours}j';

  @override
  String toString() {
    return 'MitraStatistics(completed: $completedToday, rating: $rating, activeHours: $activeHours, pending: $pendingPickups)';
  }
}
