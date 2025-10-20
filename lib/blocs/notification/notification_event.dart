import 'package:equatable/equatable.dart';

/// Events untuk notification management
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk fetch notifications
class FetchNotifications extends NotificationEvent {
  final int? page;
  final int? perPage;

  const FetchNotifications({
    this.page,
    this.perPage,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Event untuk mark notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event untuk mark all notifications as read
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Event untuk refresh notifications
class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}
