/// Model untuk item sampah individual dalam jadwal
/// Mendukung multiple waste types dengan estimasi berat masing-masing
class WasteItem {
  final String wasteType;
  final double estimatedWeight;
  final String unit;
  final String? notes;

  WasteItem({
    required this.wasteType,
    required this.estimatedWeight,
    this.unit = 'kg',
    this.notes,
  });

  /// Create WasteItem from JSON
  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      wasteType: json['waste_type'] ?? json['wasteType'] ?? '',
      estimatedWeight: _parseDouble(
        json['estimated_weight'] ?? json['estimatedWeight'],
      ),
      unit: json['unit'] ?? 'kg',
      notes: json['notes'],
    );
  }

  /// Convert WasteItem to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'waste_type': wasteType,
      'estimated_weight': estimatedWeight,
      'unit': unit,
      if (notes != null) 'notes': notes,
    };
  }

  /// Parse double safely from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Copy with method for immutability
  WasteItem copyWith({
    String? wasteType,
    double? estimatedWeight,
    String? unit,
    String? notes,
  }) {
    return WasteItem(
      wasteType: wasteType ?? this.wasteType,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'WasteItem(type: $wasteType, weight: $estimatedWeight $unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WasteItem &&
        other.wasteType == wasteType &&
        other.estimatedWeight == estimatedWeight &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return wasteType.hashCode ^ estimatedWeight.hashCode ^ unit.hashCode;
  }
}

/// Predefined waste types with emoji icons
class WasteType {
  static const String organik = 'organik';
  static const String plastik = 'plastik';
  static const String kertas = 'kertas';
  static const String kaleng = 'kaleng';
  static const String botolKaca = 'botol_kaca';
  static const String elektronik = 'elektronik';
  static const String lainnya = 'lainnya';

  /// Get all available waste types
  static List<Map<String, String>> getAllTypes() {
    return [
      {'id': organik, 'name': 'Organik', 'emoji': '🍃'},
      {'id': plastik, 'name': 'Plastik', 'emoji': '♻️'},
      {'id': kertas, 'name': 'Kertas', 'emoji': '📄'},
      {'id': kaleng, 'name': 'Kaleng', 'emoji': '🥫'},
      {'id': botolKaca, 'name': 'Botol Kaca', 'emoji': '🍾'},
      {'id': elektronik, 'name': 'Elektronik', 'emoji': '📱'},
      {'id': lainnya, 'name': 'Lainnya', 'emoji': '📦'},
    ];
  }

  /// Get emoji for waste type
  static String getEmoji(String wasteType) {
    final type = getAllTypes().firstWhere(
      (t) => t['id'] == wasteType,
      orElse: () => {'emoji': '📦'},
    );
    return type['emoji'] ?? '📦';
  }

  /// Get display name for waste type
  static String getDisplayName(String wasteType) {
    final type = getAllTypes().firstWhere(
      (t) => t['id'] == wasteType,
      orElse: () => {'name': 'Lainnya'},
    );
    return type['name'] ?? 'Lainnya';
  }
}
