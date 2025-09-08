import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles the notification sounds for the Gerobaks app.
/// This class provides methods to get AndroidNotificationDetails with proper sound configuration.
class NotificationSoundHelper {
  // Private constructor to prevent instantiation
  NotificationSoundHelper._();
  
  /// Get default notification sound for general notifications
  static AndroidNotificationDetails getDefaultSoundDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      sound: const RawResourceAndroidNotificationSound('nf_gerobaks'),
    );
  }
  
  /// Get pickup notification sound details
  static AndroidNotificationDetails getPickupSoundDetails({
    String channelId = 'pickup_notifications',
    String channelName = 'Pickup Notifications',
    String channelDescription = 'Notifications for waste pickup schedules',
    Importance importance = Importance.max,
    Priority priority = Priority.high,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      sound: const RawResourceAndroidNotificationSound('nf_gerobaks'),
    );
  }
  
  /// Get chat notification sound details
  static AndroidNotificationDetails getChatSoundDetails({
    String channelId = 'chat_notifications',
    String channelName = 'Chat Notifications',
    String channelDescription = 'Notifications for new chat messages',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      sound: const RawResourceAndroidNotificationSound('nf_gerobaks'),
    );
  }
  
  /// Get Darwin (iOS) notification details with sound
  static const iosDetailsWithSound = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  /// Create full notification details with Android and iOS settings
  static NotificationDetails getFullDetails({
    required AndroidNotificationDetails androidDetails,
    DarwinNotificationDetails? iosDetails,
  }) {
    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails ?? iosDetailsWithSound,
    );
  }
}
