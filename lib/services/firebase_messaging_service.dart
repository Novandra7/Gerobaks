import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bank_sha/services/notification_api_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:dio/dio.dart';
import 'dart:io';

/// Firebase Cloud Messaging Service
/// Handles push notifications dari backend
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationApiService? _notificationApi;
  String? _fcmToken;
  bool _isInitialized = false;

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    if (_isInitialized) {
      print('🔔 Firebase Messaging already initialized');
      return;
    }

    try {
      print('🔔 Initializing Firebase Messaging...');

      // Initialize notification API service
      await _initializeNotificationApi();

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Register token with backend
      await _registerTokenWithBackend();

      // Setup message handlers
      _setupMessageHandlers();

      _isInitialized = true;
      print('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Initialize notification API service
  Future<void> _initializeNotificationApi() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token != null && token.isNotEmpty) {
        final dio = Dio();
        _notificationApi = NotificationApiService(dio: dio);
        _notificationApi!.setAuthToken(token);
        print('✅ Notification API service initialized');
      } else {
        print('⚠️ No auth token found, will initialize later');
      }
    } catch (e) {
      print('❌ Error initializing notification API: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print(
        '📱 Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Notification permission provisional');
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('✅ Local notifications initialized');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null) {
        print('✅ FCM Token obtained: ${_fcmToken!.substring(0, 20)}...');
      } else {
        print('⚠️ FCM Token is null');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed');
        _fcmToken = newToken;
        _registerTokenWithBackend();
      });
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend() async {
    if (_fcmToken == null || _notificationApi == null) {
      print('⚠️ Cannot register token: fcmToken or notificationApi is null');
      return;
    }

    try {
      print('📤 Registering FCM token with backend...');

      final deviceType = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'web';

      await _notificationApi!.registerFcmToken(
        fcmToken: _fcmToken!,
        deviceType: deviceType,
      );

      print('✅ FCM token registered with backend');
    } catch (e) {
      print('❌ Error registering FCM token: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        print('📱 App opened from terminated state via notification');
        _handleNotificationTap(message);
      }
    });

    print('✅ Message handlers setup complete');
  }

  /// Handle foreground message (app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Foreground message received');
    print('   - Title: ${message.notification?.title}');
    print('   - Body: ${message.notification?.body}');
    print('   - Data: ${message.data}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('👆 Notification tapped');
    print('   - Data: ${message.data}');

    // Navigate based on notification data
    if (message.data.containsKey('action_url')) {
      final actionUrl = message.data['action_url'];
      print('   - Action URL: $actionUrl');
      // TODO: Implement navigation
      // NavigationService.navigateTo(actionUrl);
    }

    // Mark as read if notification_id exists
    if (message.data.containsKey('notification_id')) {
      final notificationId = int.tryParse(
        message.data['notification_id'].toString(),
      );
      if (notificationId != null && _notificationApi != null) {
        try {
          await _notificationApi!.markAsRead(notificationId);
          print('✅ Notification marked as read: $notificationId');
        } catch (e) {
          print('❌ Error marking notification as read: $e');
        }
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'gerobaks_channel',
        'Gerobaks Notifications',
        channelDescription: 'Notifikasi untuk aplikasi Gerobaks',
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound('nf_gerobaks'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'nf_gerobaks.wav',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'Gerobaks',
        message.notification?.body ?? '',
        notificationDetails,
        payload: message.data.toString(),
      );

      print('✅ Local notification shown');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Handle notification tap from local notification
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped');
    print('   - Payload: ${response.payload}');
    // TODO: Implement navigation based on payload
  }

  /// Subscribe to topic (optional)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic (optional)
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Remove FCM token (logout)
  Future<void> removeFcmToken() async {
    if (_fcmToken == null || _notificationApi == null) return;

    try {
      print('🗑️ Removing FCM token...');

      await _notificationApi!.removeFcmToken(_fcmToken!);
      await _firebaseMessaging.deleteToken();

      _fcmToken = null;
      print('✅ FCM token removed');
    } catch (e) {
      print('❌ Error removing FCM token: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Background message received');
  print('   - Title: ${message.notification?.title}');
  print('   - Body: ${message.notification?.body}');
  print('   - Data: ${message.data}');

  // Handle background message
  // Note: Cannot update UI or navigate here
}
