import 'package:equatable/equatable.dart';

/// States untuk notification management
enum NotificationStatus {
  initial,
  loading,
  loaded,
  error,
  markingAsRead,
  markedAsRead,
}

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<dynamic>? notifications;
  final String? errorMessage;
  final int unreadCount;
  final bool hasMoreNotifications;
  final int currentPage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications,
    this.errorMessage,
    this.unreadCount = 0,
    this.hasMoreNotifications = true,
    this.currentPage = 1,
  });

  /// Initial state
  factory NotificationState.initial() {
    return const NotificationState(status: NotificationStatus.initial);
  }

  /// Loading state
  factory NotificationState.loading() {
    return const NotificationState(status: NotificationStatus.loading);
  }

  /// Loaded state
  factory NotificationState.loaded({
    required List<dynamic> notifications,
    int unreadCount = 0,
    bool hasMoreNotifications = true,
    int currentPage = 1,
  }) {
    return NotificationState(
      status: NotificationStatus.loaded,
      notifications: notifications,
      unreadCount: unreadCount,
      hasMoreNotifications: hasMoreNotifications,
      currentPage: currentPage,
    );
  }

  /// Error state
  factory NotificationState.error(String message) {
    return NotificationState(
      status: NotificationStatus.error,
      errorMessage: message,
    );
  }

  /// Marking as read state
  factory NotificationState.markingAsRead() {
    return const NotificationState(status: NotificationStatus.markingAsRead);
  }

  /// Marked as read state
  factory NotificationState.markedAsRead({
    required List<dynamic> notifications,
    required int unreadCount,
  }) {
    return NotificationState(
      status: NotificationStatus.markedAsRead,
      notifications: notifications,
      unreadCount: unreadCount,
    );
  }

  /// Copy with method
  NotificationState copyWith({
    NotificationStatus? status,
    List<dynamic>? notifications,
    String? errorMessage,
    int? unreadCount,
    bool? hasMoreNotifications,
    int? currentPage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMoreNotifications: hasMoreNotifications ?? this.hasMoreNotifications,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        errorMessage,
        unreadCount,
        hasMoreNotifications,
        currentPage,
      ];
}
