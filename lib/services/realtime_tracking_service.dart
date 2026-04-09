import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_sha/models/tracking/tracking_models.dart';
import 'package:bank_sha/utils/app_config.dart';
import 'package:logger/logger.dart';

/// Service untuk menangani real-time GPS tracking antara Mitra dan User.
///
/// Features:
/// - Mitra: Send location every 10 seconds saat foreground, 30 seconds saat background
/// - User: Poll location every 5 seconds
/// - App lifecycle aware tracking
/// - Persistent notification saat tracking di background
class RealTimeTrackingService with WidgetsBindingObserver {
  RealTimeTrackingService._internal();
  static final RealTimeTrackingService _instance =
      RealTimeTrackingService._internal();
  factory RealTimeTrackingService() => _instance;

  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _trackingNotificationId = 999;
  static const Duration _foregroundInterval = Duration(seconds: 10);
  static const Duration _backgroundInterval = Duration(seconds: 30);

  Timer? _trackingTimer;
  bool _isTracking = false;
  bool _isSendingLocation = false;
  int? _currentPickupScheduleId;
  Duration _currentTrackingInterval = _foregroundInterval;
  AppLifecycleState _currentLifecycleState = AppLifecycleState.resumed;
  bool _isLifecycleObserverRegistered = false;
  bool _notificationPluginInitialized = false;

  // Base URL from AppConfig
  String get _baseUrl => AppConfig.apiBaseUrl;

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==========================================
  // MITRA: SEND LOCATION UPDATES
  // ==========================================

  /// Start tracking - Mitra mengirim lokasi berdasarkan mode app.
  Future<void> startMitraTracking(int pickupScheduleId) async {
    if (_isTracking) {
      _logger.i(
        'Tracking sudah berjalan untuk pickup schedule: $_currentPickupScheduleId',
      );
      return;
    }

    _currentPickupScheduleId = pickupScheduleId;
    _isTracking = true;

    _logger.i('🚀 Start Mitra tracking for pickup schedule: $pickupScheduleId');

    _ensureLifecycleObserver();
    await _ensureNotificationPluginInitialized();
    _applyIntervalByLifecycle();
    await _updateTrackingNotificationVisibility();

    // Kirim lokasi pertama kali langsung.
    await _sendMitraLocation(pickupScheduleId);

    // Kemudian kirim berkala sesuai mode foreground/background.
    _restartTrackingTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentLifecycleState = state;

    if (!_isTracking) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _switchToForegroundMode();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _switchToBackgroundMode();
        break;
      case AppLifecycleState.detached:
        _cleanupTrackingResources();
        break;
    }
  }

  void _switchToForegroundMode() {
    _setTrackingInterval(_foregroundInterval);
    unawaited(_clearPersistentNotification());
    _logger.d('[Tracking] Switched to foreground mode: 10s interval');
  }

  void _switchToBackgroundMode() {
    _setTrackingInterval(_backgroundInterval);
    unawaited(_showPersistentNotification());
    _logger.d('[Tracking] Switched to background mode: 30s interval');
  }

  void _applyIntervalByLifecycle() {
    final isForeground = _currentLifecycleState == AppLifecycleState.resumed;
    _currentTrackingInterval = isForeground
        ? _foregroundInterval
        : _backgroundInterval;
  }

  void _setTrackingInterval(Duration interval) {
    if (_currentTrackingInterval == interval) return;
    _currentTrackingInterval = interval;
    _restartTrackingTimer();
  }

  void _restartTrackingTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(_currentTrackingInterval, (_) {
      if (!_isTracking || _currentPickupScheduleId == null) return;
      unawaited(_sendMitraLocation(_currentPickupScheduleId!));
    });
  }

  void _ensureLifecycleObserver() {
    if (_isLifecycleObserverRegistered) return;
    WidgetsBinding.instance.addObserver(this);
    _isLifecycleObserverRegistered = true;
  }

  void _removeLifecycleObserver() {
    if (!_isLifecycleObserverRegistered) return;
    WidgetsBinding.instance.removeObserver(this);
    _isLifecycleObserverRegistered = false;
  }

  Future<void> _ensureNotificationPluginInitialized() async {
    if (_notificationPluginInitialized) return;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationPlugin.initialize(initializationSettings);

    final androidImplementation = _notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'tracking_channel',
        'Delivery Tracking',
        description: 'Tracking lokasi mitra saat delivery',
        importance: Importance.high,
      ),
    );

    _notificationPluginInitialized = true;
  }

  Future<void> _updateTrackingNotificationVisibility() async {
    if (!_isTracking) return;

    if (_currentLifecycleState == AppLifecycleState.resumed) {
      await _clearPersistentNotification();
      return;
    }

    await _showPersistentNotification();
  }

  Future<void> _showPersistentNotification() async {
    if (!_isTracking) return;

    const androidDetails = AndroidNotificationDetails(
      'tracking_channel',
      'Delivery Tracking',
      channelDescription: 'Tracking lokasi mitra saat delivery',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationPlugin.show(
      _trackingNotificationId,
      '📍 Tracking Aktif',
      'Jangan tutup aplikasi sampai delivery selesai',
      details,
    );
  }

  Future<void> _clearPersistentNotification() async {
    await _notificationPlugin.cancel(_trackingNotificationId);
  }

  void _cleanupTrackingResources() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  /// Send current location to backend
  Future<MitraLocationUpdateResponse?> _sendMitraLocation(
    int pickupScheduleId,
  ) async {
    if (_isSendingLocation) {
      _logger.w('⏳ Skip location update: previous request still running');
      return null;
    }

    _isSendingLocation = true;
    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _logger.e('❌ Location permission denied');
        return null;
      }

      // Get current position (background mode biasanya butuh waktu lebih lama).
      final isForeground = _currentLifecycleState == AppLifecycleState.resumed;
      final desiredAccuracy = isForeground
          ? LocationAccuracy.high
          : LocationAccuracy.medium;
      final positionTimeout = isForeground
          ? const Duration(seconds: 8)
          : const Duration(seconds: 20);

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: desiredAccuracy,
          timeLimit: positionTimeout,
        );
      } on TimeoutException {
        _logger.w(
          '⏱️ GetCurrentPosition timeout in ${isForeground ? 'foreground' : 'background'} mode, trying last known position',
        );

        final lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition == null) {
          _logger.e('❌ Last known position not available after timeout');
          return null;
        }

        position = lastKnownPosition;
      }

      // Convert speed from m/s to km/h
      final speedKmh = position.speed > 0 ? position.speed * 3.6 : null;

      // Prepare request
      final request = MitraLocationUpdateRequest(
        pickupScheduleId: pickupScheduleId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: speedKmh,
        heading: position.heading,
      );

      // Send to backend
      final url = Uri.parse('$_baseUrl/api/mitra/tracking/update-location');
      final headers = await _getHeaders();

      _logger.d(
        '📍 Sending location: ${position.latitude}, ${position.longitude} (interval: ${_currentTrackingInterval.inSeconds}s)',
      );

      final response = await http
          .post(url, headers: headers, body: jsonEncode(request.toJson()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = MitraLocationUpdateResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.i(
          '✅ Location updated: Distance ${result.data?.trackingInfo.distanceKm} km, ETA ${result.data?.trackingInfo.etaMinutes} min',
        );

        return result;
      } else {
        _logger.e(
          '❌ Failed to update location: ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Error sending location', error: e, stackTrace: stackTrace);
      return null;
    } finally {
      _isSendingLocation = false;
    }
  }

  /// Stop tracking
  Future<void> stopMitraTracking(int pickupScheduleId) async {
    if (!_isTracking) {
      _logger.w('⚠️ Tracking sudah tidak aktif');
      return;
    }

    _logger.i('🛑 Stop Mitra tracking for pickup schedule: $pickupScheduleId');

    // Cancel local tracking resources terlebih dahulu.
    _cleanupTrackingResources();
    _isTracking = false;
    _currentPickupScheduleId = null;
    _currentTrackingInterval = _foregroundInterval;
    _removeLifecycleObserver();
    await _clearPersistentNotification();

    // Notify backend
    try {
      final url = Uri.parse('$_baseUrl/api/mitra/tracking/stop');
      final headers = await _getHeaders();

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({'pickup_schedule_id': pickupScheduleId}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        _logger.i('✅ Tracking stopped successfully');
      } else {
        _logger.e('❌ Failed to stop tracking: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error stopping tracking: $e');
    }
  }

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Get current pickup schedule ID being tracked
  int? get currentPickupScheduleId => _currentPickupScheduleId;

  // ==========================================
  // USER: GET TRACKING INFO
  // ==========================================

  /// Get real-time tracking info (untuk User)
  /// Polling every 5 seconds recommended
  Future<TrackingInfoModel?> getUserTrackingInfo(int pickupScheduleId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/user/tracking/$pickupScheduleId');
      final headers = await _getHeaders();

      _logger.d('📡 Fetching tracking info for pickup: $pickupScheduleId');
      _logger.d('   URL: $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      _logger.d('📥 Response status: ${response.statusCode}');
      _logger.d('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final trackingInfo = TrackingInfoModel.fromJson(json);

          _logger.i('✅ Tracking info retrieved successfully');
          _logger.d(
            '   📍 Distance: ${trackingInfo.trackingInfo.formattedDistance}',
          );
          _logger.d('   ⏱️  ETA: ${trackingInfo.trackingInfo.formattedEta}');
          _logger.d(
            '   🔄 Location stale: ${trackingInfo.mitraLocation.isStale}',
          );
          _logger.d('   👤 Mitra: ${trackingInfo.mitraInfo.name}');

          return trackingInfo;
        } else {
          _logger.w('⚠️ Tracking info failed: ${json['message']}');
          return null;
        }
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.w('⚠️ Tracking not available: ${json['message']}');
        _logger.d('   Error code: ${json['error_code']}');
        return null;
      } else if (response.statusCode == 403) {
        _logger.e('❌ Unauthorized: This schedule does not belong to you');
        return null;
      } else if (response.statusCode == 404) {
        _logger.w('⚠️ Schedule not found');
        return null;
      } else {
        _logger.e('❌ Failed to get tracking info: ${response.statusCode}');
        _logger.e('   Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error getting tracking info',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get tracking history (for completed pickups)
  Future<TrackingHistoryModel?> getTrackingHistory(int pickupScheduleId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/user/tracking/$pickupScheduleId/history',
      );
      final headers = await _getHeaders();

      _logger.d('📜 Fetching tracking history for pickup: $pickupScheduleId');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final history = TrackingHistoryModel.fromJson(json);

          _logger.i(
            '✅ Tracking history: ${history.totalPoints} points, '
            'Duration: ${history.formattedDuration}',
          );

          return history;
        } else {
          _logger.w('⚠️ Tracking history failed: ${json['message']}');
          return null;
        }
      } else {
        _logger.e('❌ Failed to get tracking history: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error getting tracking history',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position (one-time)
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkLocationPermission();

      if (permission == LocationPermission.denied) {
        final newPermission = await requestLocationPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          _logger.e('❌ Location permission denied');
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _logger.e('❌ Error getting current position: $e');
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _cleanupTrackingResources();
    _isTracking = false;
    _currentPickupScheduleId = null;
    _currentTrackingInterval = _foregroundInterval;
    _removeLifecycleObserver();
    unawaited(_clearPersistentNotification());
  }
}
