import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatNotificationMethod {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Initialize notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        final String? payload = notificationResponse.payload;
        if (payload != null) {
          print('Notification payload: $payload');
          // Handle notification tap
        }
      },
    );
    
    _isInitialized = true;
  }

  // Show chat notification
  Future<void> showChatNotification({
    required String title,
    required String body,
    required String sender,
    String? imageUrl,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Create style information for the notification
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_notifications',
      'Chat Notifications',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      sound: const RawResourceAndroidNotificationSound('nf_gerobaks'),
      styleInformation: MessagingStyleInformation(
        Person(name: 'Anda', key: 'user'),
        conversationTitle: sender,
        messages: [
          Message(
            body,
            DateTime.now(),
            Person(
              name: sender,
              key: sender.toLowerCase().replaceAll(' ', '_'),
              icon: imageUrl != null ? ByteArrayAndroidIcon.fromBase64String(imageUrl) : null,
            ),
          ),
        ],
      ),
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
        threadIdentifier: 'chat',
      ),
    );

    final int notificationId = Random().nextInt(1000000);
    await _notifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload != null ? Uri.encodeComponent(payload.toString()) : null,
    );
  }
}
