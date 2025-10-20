import 'package:bloc/bloc.dart';
import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC untuk mengelola notifications
/// Menggunakan ApiClient untuk komunikasi dengan backend
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiClient _api = ApiClient();

  NotificationBloc() : super(NotificationState.initial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  /// Handle fetch notifications
  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Don't show loading if we're paginating
    if (event.page == null || event.page == 1) {
      emit(NotificationState.loading());
    }

    try {
      print('🔔 NotificationBloc: Fetching notifications page ${event.page ?? 1}');

      // GET /api/notifications?page=1&per_page=20
      String endpoint = ApiRoutes.notifications;
      if (event.page != null || event.perPage != null) {
        endpoint += '?';
        if (event.page != null) endpoint += 'page=${event.page}&';
        if (event.perPage != null) endpoint += 'per_page=${event.perPage}';
      }

      final response = await _api.get(endpoint);

      print('✅ NotificationBloc: Notifications fetched');

      // Extract notification data from response
      final data = response['data'] as List<dynamic>?;
      final meta = response['meta'] as Map<String, dynamic>?;

      if (data != null) {
        // If paginating, append to existing notifications
        List<dynamic> updatedNotifications;
        if (event.page != null && event.page! > 1 && state.notifications != null) {
          updatedNotifications = [...state.notifications!, ...data];
        } else {
          updatedNotifications = data;
        }

        // Count unread notifications
        final unreadCount = updatedNotifications.where((n) => n['read_at'] == null).length;

        // Check if there are more pages
        bool hasMore = true;
        if (meta != null) {
          final currentPage = meta['current_page'] as int?;
          final lastPage = meta['last_page'] as int?;
          if (currentPage != null && lastPage != null) {
            hasMore = currentPage < lastPage;
          }
        }

        emit(NotificationState.loaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
          hasMoreNotifications: hasMore,
          currentPage: event.page ?? 1,
        ));
      } else {
        emit(NotificationState.error('Data notifikasi tidak ditemukan'));
      }
    } catch (e) {
      print('❌ NotificationBloc: Failed to fetch notifications - $e');
      emit(NotificationState.error(e.toString()));
    }
  }

  /// Handle mark notification as read
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationState.markingAsRead());

    try {
      print('🔔 NotificationBloc: Marking notification ${event.notificationId} as read');

      // POST /api/notifications/mark-read (marks specific notification)
      await _api.postJson('${ApiRoutes.notificationMarkRead}/${event.notificationId}', {});

      print('✅ NotificationBloc: Notification marked as read');

      // Update local state
      if (state.notifications != null) {
        final updatedNotifications = state.notifications!.map((n) {
          if (n['id'] == event.notificationId) {
            return {...n, 'read_at': DateTime.now().toIso8601String()};
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => n['read_at'] == null).length;

        emit(NotificationState.markedAsRead(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      } else {
        emit(state.copyWith(status: NotificationStatus.markedAsRead));
      }
    } catch (e) {
      print('❌ NotificationBloc: Failed to mark notification as read - $e');
      emit(NotificationState.error(e.toString()));
    }
  }

  /// Handle mark all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationState.markingAsRead());

    try {
      print('🔔 NotificationBloc: Marking all notifications as read');

      // POST /api/notifications/mark-read (marks all unread)
      await _api.postJson(ApiRoutes.notificationMarkRead, {});

      print('✅ NotificationBloc: All notifications marked as read');

      // Update local state
      if (state.notifications != null) {
        final updatedNotifications = state.notifications!.map((n) {
          return {...n, 'read_at': DateTime.now().toIso8601String()};
        }).toList();

        emit(NotificationState.markedAsRead(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      } else {
        emit(state.copyWith(status: NotificationStatus.markedAsRead, unreadCount: 0));
      }
    } catch (e) {
      print('❌ NotificationBloc: Failed to mark all notifications as read - $e');
      emit(NotificationState.error(e.toString()));
    }
  }

  /// Handle refresh notifications
  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    add(const FetchNotifications(page: 1));
  }
}
