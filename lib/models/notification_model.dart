import 'dart:convert';

/// Model untuk notifikasi
class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String category;
  final String title;
  final String message;
  final String icon;
  final String priority;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.title,
    required this.message,
    required this.icon,
    required this.priority,
    required this.isRead,
    this.data,
    required this.createdAt,
    this.readAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse data field - backend returns JSON string, not object
    Map<String, dynamic>? parsedData;
    if (json['data'] != null) {
      try {
        if (json['data'] is String) {
          parsedData = jsonDecode(json['data']);
        } else if (json['data'] is Map) {
          parsedData = Map<String, dynamic>.from(json['data']);
        }
      } catch (e) {
        print('⚠️ Error parsing notification data: $e');
        parsedData = null;
      }
    }

    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      category: json['category'],
      title: json['title'],
      message: json['message'],
      icon: json['icon'],
      priority: json['priority'],
      // Backend uses integer (0/1) for is_read, convert to boolean
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      data: parsedData,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category': category,
      'title': title,
      'message': message,
      'icon': icon,
      'priority': priority,
      'is_read': isRead ? 1 : 0,
      'data': data != null ? jsonEncode(data) : null,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters untuk data field yang umum digunakan
  int? get scheduleId => data?['schedule_id'];
  String? get wasteType => data?['waste_type'];
  String? get pickupTimeStart => data?['pickup_time_start'];
  String? get pickupTimeEnd => data?['pickup_time_end'];
  String? get scheduleDay => data?['schedule_day'];
  String? get pickupTime => data?['pickup_time'];
  int? get pointsEarned => data?['points_earned'];
  int? get totalPoints => data?['total_points'];
  String? get reason => data?['reason'];
  String? get actionUrl => data?['action_url'];

  // Helper untuk check priority
  bool get isUrgent => priority == 'urgent';
  bool get isHigh => priority == 'high';
  bool get isNormal => priority == 'normal';
  bool get isLow => priority == 'low';

  // Helper untuk check type
  bool get isSchedule => type == 'schedule';
  bool get isReminder => type == 'reminder';
  bool get isInfo => type == 'info';
  bool get isSystem => type == 'system';
  bool get isPromo => type == 'promo';
}

/// Model untuk pagination
class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      perPage: json['per_page'],
      total: json['total'],
      lastPage: json['last_page'],
      from: json['from'],
      to: json['to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
      'from': from,
      'to': to,
    };
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}

/// Model untuk summary
class Summary {
  final int totalNotifications;
  final int unreadCount;
  final Map<String, int> byPriority;

  Summary({
    required this.totalNotifications,
    required this.unreadCount,
    required this.byPriority,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalNotifications: json['total_notifications'],
      unreadCount: json['unread_count'],
      byPriority: Map<String, int>.from(json['by_priority']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_notifications': totalNotifications,
      'unread_count': unreadCount,
      'by_priority': byPriority,
    };
  }

  int get urgentCount => byPriority['urgent'] ?? 0;
  int get highCount => byPriority['high'] ?? 0;
  int get normalCount => byPriority['normal'] ?? 0;
  int get lowCount => byPriority['low'] ?? 0;
}

/// Response model untuk list notifications
class NotificationResponse {
  final List<NotificationModel> notifications;
  final Pagination pagination;
  final Summary summary;

  NotificationResponse({
    required this.notifications,
    required this.pagination,
    required this.summary,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications: (json['data']['notifications'] as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList(),
      pagination: Pagination.fromJson(json['data']['pagination']),
      summary: Summary.fromJson(json['data']['summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'notifications': notifications.map((n) => n.toJson()).toList(),
        'pagination': pagination.toJson(),
        'summary': summary.toJson(),
      }
    };
  }
}

/// Response model untuk unread count
class UnreadCountResponse {
  final int unreadCount;
  final Map<String, int> byCategory;
  final Map<String, int> byPriority;
  final bool hasUrgent;

  UnreadCountResponse({
    required this.unreadCount,
    required this.byCategory,
    required this.byPriority,
    required this.hasUrgent,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      unreadCount: json['data']['unread_count'],
      byCategory: Map<String, int>.from(json['data']['by_category']),
      byPriority: Map<String, int>.from(json['data']['by_priority']),
      hasUrgent: json['data']['has_urgent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'unread_count': unreadCount,
        'by_category': byCategory,
        'by_priority': byPriority,
        'has_urgent': hasUrgent,
      }
    };
  }
}
