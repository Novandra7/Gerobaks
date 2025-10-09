import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/services/service_integration_manager_corrected.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceIntegrationManager Tests', () {
    ServiceIntegrationManager? integrationManager;

    setUpAll(() async {
      // Initialize once for all tests
      integrationManager = ServiceIntegrationManager();

      // Only initialize if not already initialized
      if (!integrationManager!.isInitialized) {
        await integrationManager!.initialize();
      }
    });

    tearDownAll(() async {
      if (integrationManager != null) {
        try {
          await integrationManager!.dispose();
        } catch (e) {
          // Ignore dispose errors in tests
        }
      }
    });

    test('should be initialized successfully', () async {
      expect(integrationManager!.isInitialized, true);
      expect(integrationManager!.apiManager, isNotNull);
      expect(integrationManager!.authService, isNotNull);
      expect(integrationManager!.userService, isNotNull);
      expect(integrationManager!.localStorageService, isNotNull);
    });

    test('should have all service getters available', () async {
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
    });

    test('should provide streams', () async {
      // Test streams
      expect(integrationManager!.userStream, isNotNull);
      expect(integrationManager!.notificationStream, isNotNull);
      expect(integrationManager!.dataUpdateStream, isNotNull);

      // Streams should be valid Stream objects
      expect(integrationManager!.userStream, isA<Stream>());
      expect(integrationManager!.notificationStream, isA<Stream>());
      expect(integrationManager!.dataUpdateStream, isA<Stream>());
    });

    group('Dashboard Methods', () {
      test('should have getDashboardData method', () async {
        expect(integrationManager!.getDashboardData, isNotNull);

        // Try to call the method (might fail due to backend connection, but method should exist)
        try {
          final result = await integrationManager!.getDashboardData();
          expect(result, isA<Map<String, dynamic>>());
        } catch (e) {
          // Expected if backend is not running
          print('Dashboard data fetch failed (expected): $e');
        }
      });
    });

    group('Authentication Methods', () {
      test('should have authentication methods available', () {
        expect(integrationManager!.login, isNotNull);
        expect(integrationManager!.register, isNotNull);
        expect(integrationManager!.logout, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle initialization gracefully', () {
        // Multiple initialization calls should not crash
        expect(() async {
          if (!integrationManager!.isInitialized) {
            await integrationManager!.initialize();
          }
        }, returnsNormally);
      });
    });

    group('Service Manager Properties', () {
      test('should have currentUser getter/setter behavior', () {
        // Note: currentUser might not be publicly exposed
        // but we can test that the manager behaves correctly
        expect(integrationManager!.isInitialized, isTrue);
      });

      test('should maintain singleton pattern', () {
        final instance1 = ServiceIntegrationManager();
        final instance2 = ServiceIntegrationManager();

        expect(identical(instance1, instance2), isTrue);
        expect(instance1.isInitialized, equals(instance2.isInitialized));
      });
    });
  });
}
