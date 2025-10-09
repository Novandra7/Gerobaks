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

    test('should handle authentication state properly', () async {
      // Test authentication state stream
      expect(integrationManager!.authenticationStateStream, isNotNull);

      // Authentication state should be available
      expect(integrationManager!.authenticationStateStream, isA<Stream>());
    });

    test('should provide role-based access streams', () async {
      // Test dashboard streams
      expect(integrationManager!.mitraDataStream, isNotNull);
      expect(integrationManager!.userDataStream, isNotNull);
      expect(integrationManager!.petugasDataStream, isNotNull);
    });

    group('Dashboard Methods', () {
      test('should have dashboard methods available', () {
        expect(integrationManager!.getDashboardData, isNotNull);
        expect(integrationManager!.getMitraData, isNotNull);
        expect(integrationManager!.getUserData, isNotNull);
        expect(integrationManager!.getPetugasData, isNotNull);
      });
    });

    group('Service Methods', () {
      test('should have service helper methods available', () {
        expect(integrationManager!.isServiceAvailable, isNotNull);
        expect(integrationManager!.getAllServices, isNotNull);
        expect(integrationManager!.getServiceHealth, isNotNull);
      });

      test('should report service availability correctly', () {
        // All services should be available after initialization
        expect(integrationManager!.isServiceAvailable('api'), true);
        expect(integrationManager!.isServiceAvailable('auth'), true);
        expect(integrationManager!.isServiceAvailable('user'), true);
        expect(integrationManager!.isServiceAvailable('notification'), true);
        expect(integrationManager!.isServiceAvailable('schedule'), true);
        expect(integrationManager!.isServiceAvailable('tracking'), true);
        expect(integrationManager!.isServiceAvailable('order'), true);
        expect(
          integrationManager!.isServiceAvailable('service_management'),
          true,
        );
        expect(
          integrationManager!.isServiceAvailable('dashboard_balance'),
          true,
        );
        expect(integrationManager!.isServiceAvailable('chat'), true);
        expect(integrationManager!.isServiceAvailable('payment_rating'), true);
        expect(integrationManager!.isServiceAvailable('report_admin'), true);
      });

      test('should return all services in getAllServices', () {
        final services = integrationManager!.getAllServices();
        expect(services, isA<Map<String, dynamic>>());
        expect(services, isNotEmpty);

        // Check if core services are present
        expect(services.containsKey('apiManager'), true);
        expect(services.containsKey('authService'), true);
        expect(services.containsKey('userService'), true);
        expect(services.containsKey('notificationService'), true);
      });

      test('should provide service health information', () {
        final health = integrationManager!.getServiceHealth();
        expect(health, isA<Map<String, dynamic>>());
        expect(health, isNotEmpty);

        // Should contain basic health info
        expect(health.containsKey('isInitialized'), true);
        expect(health.containsKey('servicesCount'), true);
        expect(health['isInitialized'], true);
        expect(health['servicesCount'], greaterThan(0));
      });
    });

    group('Error Handling', () {
      test('should handle invalid service names gracefully', () {
        expect(
          integrationManager!.isServiceAvailable('invalid_service'),
          false,
        );
      });
    });
  });
}
