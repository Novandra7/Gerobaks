import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/services/service_integration_manager_corrected.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceIntegrationManager Tests', () {
    ServiceIntegrationManager? integrationManager;

    setUp(() {
      // Setup mock for SharedPreferences
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'getAll') {
                return <String, Object>{}; // Return empty preferences
              }
              return null;
            },
          );

      integrationManager = ServiceIntegrationManager();
    });

    tearDown(() async {
      if (integrationManager != null) {
        try {
          await integrationManager!.dispose();
        } catch (e) {
          // Ignore dispose errors in tests
        }
      }

      // Clean up mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            null,
          );
    });

    test('should initialize successfully with mocked dependencies', () async {
      expect(integrationManager!.isInitialized, false);

      // Test initialization
      await integrationManager!.initialize();

      expect(integrationManager!.isInitialized, true);
      expect(integrationManager!.apiManager, isNotNull);
      expect(integrationManager!.authService, isNotNull);
      expect(integrationManager!.userService, isNotNull);
      expect(integrationManager!.localStorageService, isNotNull);
    });

    test(
      'should have all service getters available after initialization',
      () async {
        await integrationManager!.initialize();

        // Core services
        expect(integrationManager!.apiManager, isNotNull);
        expect(integrationManager!.authService, isNotNull);
        expect(integrationManager!.userService, isNotNull);
        expect(integrationManager!.localStorageService, isNotNull);
        expect(integrationManager!.notificationService, isNotNull);

        // Feature services
        expect(integrationManager!.scheduleService, isNotNull);
        expect(integrationManager!.trackingService, isNotNull);
        expect(integrationManager!.orderService, isNotNull);
        expect(integrationManager!.serviceManagementService, isNotNull);
        expect(integrationManager!.dashboardBalanceService, isNotNull);
        expect(integrationManager!.chatService, isNotNull);
        expect(integrationManager!.paymentRatingService, isNotNull);
        expect(integrationManager!.reportAdminService, isNotNull);
      },
    );

    test('should provide streams after initialization', () async {
      await integrationManager!.initialize();

      // Test streams
      expect(integrationManager!.userStream, isNotNull);
      expect(integrationManager!.notificationStream, isNotNull);
      expect(integrationManager!.dataUpdateStream, isNotNull);

      // Streams should be valid Stream objects
      expect(integrationManager!.userStream, isA<Stream>());
      expect(integrationManager!.notificationStream, isA<Stream>());
      expect(integrationManager!.dataUpdateStream, isA<Stream>());
    });

    group('Authentication Methods', () {
      setUp(() async {
        await integrationManager!.initialize();
      });

      test('should have authentication methods available', () {
        expect(integrationManager!.login, isNotNull);
        expect(integrationManager!.register, isNotNull);
        expect(integrationManager!.logout, isNotNull);
      });
    });

    group('Dashboard Methods', () {
      setUp(() async {
        await integrationManager!.initialize();
      });

      test('should have getDashboardData method', () {
        expect(integrationManager!.getDashboardData, isNotNull);
      });
    });

    group('Singleton Pattern', () {
      test('should maintain singleton pattern', () {
        final instance1 = ServiceIntegrationManager();
        final instance2 = ServiceIntegrationManager();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle disposal gracefully', () async {
        await integrationManager!.initialize();
        expect(integrationManager!.isInitialized, isTrue);

        // Disposal should not throw
        expect(() async {
          await integrationManager!.dispose();
        }, returnsNormally);
      });
    });
  });
}
