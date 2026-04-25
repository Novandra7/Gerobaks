import 'dart:async';
import 'dart:convert';

import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/ui/pages/end_user/chat/chat_detail_page.dart';
import 'package:bank_sha/ui/pages/mitra/chat/mitra_chat_detail_page.dart';
import 'package:bank_sha/ui/widgets/shared/notification_icon_with_badge.dart';
import 'package:bank_sha/utils/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bank_sha/services/notification_api_service.dart';
import '../firebase_options.dart';
import 'package:dio/dio.dart';
import 'dart:io';

// ✅ Instance global — dipakai bersama antara class dan background isolate
final FlutterLocalNotificationsPlugin globalLocalNotifications =
    FlutterLocalNotificationsPlugin();

// ✅ Harus top-level function, dipanggil saat notifikasi diklik di background isolate
@pragma('vm:entry-point')
void onBackgroundNotificationTapped(NotificationResponse response) {
  // Tidak bisa navigasi di sini karena tidak ada UI context
  // Payload sudah tersimpan, akan dibaca saat app buka via getNotificationAppLaunchDetails
  print('🔔 [BACKGROUND ISOLATE] notif tapped: ${response.payload}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  // ✅ Gunakan instance global, bukan buat baru
  FlutterLocalNotificationsPlugin get _localNotifications =>
      globalLocalNotifications;

  NotificationApiService? _notificationApi;
  String? _fcmToken;
  bool _isInitialized = false;
  bool _isTokenRefreshListenerAttached = false;

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
        'chat_messages',
        'Chat Messages',
        description: 'Notifikasi pesan chat baru',
        importance: Importance.high,
      );

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await ensureFirebaseInitialized();
      await _initializeNotificationApi();
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _getFCMToken();
      await _registerTokenWithBackend();

      // ✅ _setupMessageHandlers dipanggil SETELAH navigator siap
      // Jangan panggil di sini — pindah ke setupHandlersAfterNavigatorReady()
      // yang dipanggil dari initState MyApp

      _isInitialized = true;
      print('✅ FirebaseMessagingService initialized');
    } catch (e) {
      print('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// ✅ Dipanggil dari initState MyApp setelah navigatorKey di-set
  Future<void> setupHandlersAfterNavigatorReady() async {
    try {
      _setupMessageHandlers();

      // ✅ Cek apakah app dibuka dari notifikasi (terminated state)
      await _checkInitialLocalNotification();

      print('✅ Message handlers setup complete');
    } catch (e) {
      print('❌ Error setting up message handlers: $e');
    }
  }

  /// ✅ Cek local notification yang membuka app saat terminated
  Future<void> _checkInitialLocalNotification() async {
    try {
      final details = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        final payload = details!.notificationResponse?.payload;
        print('🔔 [TERMINATED] App dibuka dari local notif, payload: $payload');
        if (payload != null && payload.isNotEmpty) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          await _handleLocalNotificationPayload(payload);
        }
      }
    } catch (e) {
      print('❌ Error checking initial local notification: $e');
    }
  }

  Future<void> _initializeNotificationApi() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      final token = await localStorage.getToken();

      if (token != null && token.isNotEmpty) {
        final dio = Dio();
        _notificationApi = NotificationApiService(
          dio: dio,
          baseUrl: (dotenv.env['API_BASE_URL'] ?? '') + '/api',
        );
        _notificationApi!.setAuthToken(token);
      }
    } catch (e) {
      print('❌ Error initializing notification API: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

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

      // ✅ Daftarkan KEDUA handler sekaligus
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          print('🔔 [FOREGROUND/BACKGROUND] notif tapped: ${response.payload}');
          _onNotificationTapped(response);
        },
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundNotificationTapped,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_chatChannel);

      print('✅ Local notifications initialized');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('✅ FCM Token: $_fcmToken');

      if (!_isTokenRefreshListenerAttached) {
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _registerTokenWithBackend();
        });
        _isTokenRefreshListenerAttached = true;
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _registerTokenWithBackend() async {
    if (_fcmToken == null || _notificationApi == null) return;

    try {
      final deviceType = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'web';
      final deviceName = _getDeviceName(deviceType);

      await _notificationApi!.registerFcmToken(
        fcmToken: _fcmToken!,
        deviceType: deviceType,
        deviceName: deviceName,
      );
      print('✅ FCM token registered to backend');
    } catch (e) {
      print('❌ Error registering FCM token: $e');
    }
  }

  String _getDeviceName(String deviceType) {
    if (Platform.localHostname.isNotEmpty) return Platform.localHostname;
    switch (deviceType) {
      case 'android':
        return 'Android Device';
      case 'ios':
        return 'iOS Device';
      default:
        return 'Unknown Device';
    }
  }

  void _setupMessageHandlers() {
    // Foreground — tampilkan sebagai local notification
    FirebaseMessaging.onMessage.listen((message) {
      print('🔔 [FOREGROUND] FCM message received: ${message.data}');
      _handleForegroundMessage(message);
    });

    // Background — app ada tapi di background, user klik notifikasi FCM
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('🔔 [BACKGROUND] onMessageOpenedApp: ${message.data}');
      unawaited(_handleNotificationTap(message));
    });

    // Terminated — app mati, user klik notifikasi FCM
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        print('🔔 [TERMINATED] getInitialMessage: ${message.data}');
        unawaited(_handleNotificationTap(message));
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(message);
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final Map<String, String> rawData = {};
    message.data.forEach((key, value) {
      rawData[key.toString()] = value?.toString() ?? '';
    });
    final data = _normalizeNotificationData(rawData);
    await _processNotificationData(data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    unawaited(_handleLocalNotificationPayload(payload));
  }

  Future<void> _handleLocalNotificationPayload(String payload) async {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final Map<String, String> rawData = {};
        decoded.forEach((key, value) {
          rawData[key.toString()] = value?.toString() ?? '';
        });
        final data = _normalizeNotificationData(rawData);
        await _processNotificationData(data);
      }
    } catch (e) {
      print('❌ Error parsing local notification payload: $e');
    }
  }

  Future<void> _processNotificationData(Map<String, String> data) async {
    // 1. Handle navigasi
    await _handleChatNavigationFromData(data);

    // 2. Mark as read — hanya jika ada notification_id
    final notificationIdRaw = data['notification_id'] ?? data['id'];
    if (notificationIdRaw != null) {
      final notificationId = int.tryParse(notificationIdRaw.toString());
      if (notificationId != null) {
        if (_notificationApi == null) await _initializeNotificationApi();
        if (_notificationApi != null) {
          try {
            await _notificationApi!.markAsRead(notificationId);
            print('✅ Notification marked as read: $notificationId');
          } catch (e) {
            print('❌ Error marking notification as read: $e');
          }
        }
      }
    }

    // ✅ Selalu refresh badge — meski tidak ada notification_id
    // Karena payload kamu hanya punya room_id, message_id, dll
    NotificationIconWithBadge.refreshNotifier.value++;
    print('✅ Badge refresh triggered');
  }

  Future<void> _handleChatNavigationFromData(Map<String, String> data) async {
    if (!_isChatNotificationData(data)) {
      print('⚠️ Bukan chat notification, skip navigasi');
      return;
    }

    print('🔔 Chat notification detected, navigating...');

    final chatService = ChatService();
    await chatService.initializeData();

    final roomIdRaw = _getDataValue(data, const [
      'room_id',
      'chat_room_id',
      'roomId',
      'chatRoomId',
    ]);
    final roomId = int.tryParse(roomIdRaw);

    final payloadConversationId = _getDataValue(data, const [
      'conversation_id',
      'chat_conversation_id',
      'conversationId',
      'chatConversationId',
    ]);
    final pickupScheduleIdRaw = _getDataValue(data, const [
      'pickup_schedule_id',
      'schedule_id',
      'pickupScheduleId',
      'scheduleId',
    ]);
    final pickupScheduleId = int.tryParse(pickupScheduleIdRaw);

    String? conversationId;
    if (payloadConversationId.isNotEmpty) {
      conversationId = payloadConversationId;
    } else if (pickupScheduleId != null) {
      final counterpartName = _getDataValue(data, const [
        'sender_name',
        'sender',
        'senderName',
      ]);
      conversationId = await chatService.getOrCreatePickupConversationFast(
        pickupScheduleId: pickupScheduleId,
        counterpartName: counterpartName,
      );
    } else if (roomId != null) {
      final counterpartName = _getDataValue(data, const [
        'sender_name',
        'sender',
        'senderName',
      ]);
      conversationId = await chatService.getOrCreateConversationByRoomId(
        roomId: roomId,
        counterpartName: counterpartName,
      );
    }

    if (conversationId == null || conversationId.trim().isEmpty) {
      print('⚠️ conversationId null atau kosong, skip navigasi');
      return;
    }

    final targetConversationId = conversationId;
    final localStorage = await LocalStorageService.getInstance();
    final userRole = (await localStorage.getUserRole() ?? '')
        .trim()
        .toLowerCase();
    final isMitra =
        userRole == LocalStorageService.roleMitra || userRole == 'admin';

    print('🔔 Navigating to chat: $targetConversationId, isMitra: $isMitra');

    final navigator = await _waitForNavigatorReady();
    if (navigator == null) {
      print('❌ Navigator tidak siap setelah retry, navigasi dibatalkan');
      return;
    }

    final route = MaterialPageRoute<void>(
      builder: (context) => isMitra
          ? MitraChatDetailPage(conversationId: targetConversationId)
          : ChatDetailPage(conversationId: targetConversationId),
    );
    navigator.push(route);
  }

  Map<String, String> _normalizeNotificationData(Map<String, String> rawData) {
    final normalized = <String, String>{...rawData};

    void mergeNested(Map<String, dynamic> nested) {
      nested.forEach((key, value) {
        final normalizedKey = key.toString().trim();
        final normalizedValue = value?.toString() ?? '';
        if (normalizedKey.isEmpty) return;
        if (!normalized.containsKey(normalizedKey) ||
            normalized[normalizedKey]!.trim().isEmpty) {
          normalized[normalizedKey] = normalizedValue;
        }
      });
    }

    final dataNode = rawData['data'];
    if (dataNode != null && dataNode.trim().isNotEmpty) {
      try {
        final decodedData = jsonDecode(dataNode);
        if (decodedData is Map<String, dynamic>) {
          mergeNested(decodedData);
        } else if (decodedData is Map) {
          mergeNested(Map<String, dynamic>.from(decodedData));
        }
      } catch (_) {}
    }

    return normalized;
  }

  String _getDataValue(Map<String, String> data, List<String> keys) {
    for (final key in keys) {
      final direct = data[key];
      if (direct != null && direct.trim().isNotEmpty) return direct.trim();
    }
    final loweredCandidates = keys.map((key) => key.toLowerCase()).toSet();
    for (final entry in data.entries) {
      if (!loweredCandidates.contains(entry.key.toLowerCase())) continue;
      if (entry.value.trim().isNotEmpty) return entry.value.trim();
    }
    return '';
  }

  bool _isChatNotificationData(Map<String, String> data) {
    final type = _getDataValue(data, const ['type', 'notification_type']);
    final category = _getDataValue(data, const ['category']);
    final actionUrl = _getDataValue(data, const ['action_url', 'actionUrl']);
    final title = _getDataValue(data, const ['title']);
    final body = _getDataValue(data, const ['body', 'message']);

    final chatTypes = <String>{
      'chat_message',
      'chat',
      'message',
      'new_message',
      'new_chat_message',
    };

    if (chatTypes.contains(type.toLowerCase()) ||
        chatTypes.contains(category.toLowerCase()))
      return true;
    if (actionUrl.toLowerCase().contains('chat')) return true;

    final hasRoomOrConversation =
        _getDataValue(data, const [
          'room_id',
          'chat_room_id',
          'roomId',
        ]).isNotEmpty ||
        _getDataValue(data, const [
          'conversation_id',
          'chat_conversation_id',
          'conversationId',
        ]).isNotEmpty;
    if (hasRoomOrConversation) return true;

    final hasScheduleId = _getDataValue(data, const [
      'pickup_schedule_id',
      'schedule_id',
      'pickupScheduleId',
    ]).isNotEmpty;
    final hasChatWord =
        title.toLowerCase().contains('chat') ||
        body.toLowerCase().contains('chat') ||
        title.toLowerCase().contains('pesan') ||
        body.toLowerCase().contains('pesan');

    return hasScheduleId && hasChatWord;
  }

  Future<NavigatorState?> _waitForNavigatorReady({
    int attempts = 20,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    for (var i = 0; i < attempts; i++) {
      final navigator = NavigationService.navigatorKey?.currentState;
      if (navigator != null) {
        print('✅ Navigator siap pada attempt ke-${i + 1}');
        return navigator;
      }
      print('⏳ Menunggu navigator... attempt ${i + 1}/$attempts');
      await Future<void>.delayed(delay);
    }
    return null;
  }

  // ✅ Gunakan _localNotifications (instance global, sudah ter-init dengan handler)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'chat_messages',
        'Chat Messages',
        channelDescription: 'Notifikasi untuk pesan chat',
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
        _resolveNotificationTitle(message),
        _resolveNotificationBody(message),
        notificationDetails,
        payload: jsonEncode(message.data),
      );

      print('✅ Local notification shown');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  String _resolveNotificationTitle(RemoteMessage message) {
    final dataTitle = message.data['title']?.toString();
    if (dataTitle != null && dataTitle.isNotEmpty) return dataTitle;
    return message.notification?.title ?? 'Gerobaks';
  }

  String _resolveNotificationBody(RemoteMessage message) {
    final dataBody = message.data['body']?.toString();
    if (dataBody != null && dataBody.isNotEmpty) return dataBody;
    final dataMessage = message.data['message']?.toString();
    if (dataMessage != null && dataMessage.isNotEmpty) return dataMessage;
    return message.notification?.body ?? '';
  }

  Future<void> syncTokenWithBackend() async {
    try {
      await ensureFirebaseInitialized();
      if (_notificationApi == null) await _initializeNotificationApi();
      if (_fcmToken == null || _fcmToken!.isEmpty) await _getFCMToken();
      await _registerTokenWithBackend();
    } catch (e) {
      print('❌ Error syncing FCM token with backend: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  Future<void> removeFcmToken() async {
    if (_fcmToken == null || _notificationApi == null) return;
    try {
      await _notificationApi!.removeFcmToken(_fcmToken!);
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
    } catch (e) {
      print('❌ Error removing FCM token: $e');
    }
  }
}

Future<void> ensureFirebaseInitialized() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }
}

/// ✅ Background FCM handler — top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await ensureFirebaseInitialized();

  print('🔔 [BACKGROUND HANDLER] message received: ${message.data}');

  // Hanya tampilkan notifikasi jika tidak ada notification payload dari FCM
  // (artinya data-only message)
  if (message.notification == null) {
    await _showBackgroundLocalNotification(message);
  }
}

/// ✅ Dipakai di background isolate — gunakan globalLocalNotifications
Future<void> _showBackgroundLocalNotification(RemoteMessage message) async {
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

    // ✅ Init dengan background handler terdaftar
    await globalLocalNotifications.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationTapped,
    );

    const channel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifikasi pesan chat baru',
      importance: Importance.high,
    );

    await globalLocalNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifikasi untuk pesan chat',
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

    await globalLocalNotifications.show(
      message.hashCode,
      _resolveNotificationTitleBg(message),
      _resolveNotificationBodyBg(message),
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );

    print('✅ Background local notification shown');
  } catch (e) {
    print('❌ Error showing background local notification: $e');
  }
}

String _resolveNotificationTitleBg(RemoteMessage message) {
  final dataTitle = message.data['title']?.toString();
  if (dataTitle != null && dataTitle.isNotEmpty) return dataTitle;
  return message.notification?.title ?? 'Gerobaks';
}

String _resolveNotificationBodyBg(RemoteMessage message) {
  final dataBody = message.data['body']?.toString();
  if (dataBody != null && dataBody.isNotEmpty) return dataBody;
  final dataMessage = message.data['message']?.toString();
  if (dataMessage != null && dataMessage.isNotEmpty) return dataMessage;
  return message.notification?.body ?? '';
}
