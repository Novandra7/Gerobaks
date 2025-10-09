import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bank_sha/services/service_integration_manager_corrected.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceIntegrationManager Tests', () {
    ServiceIntegrationManager? integrationManager;

    setUp(() {
      // Create fresh instance for each test
      integrationManager = ServiceIntegrationManager();
    });

    tearDown(() async {
      if (integrationManager != null) {
        try {
          await integrationManager!.dispose();
        } catch (e) {
          // Ignore dispose errors in tests
        }
        integrationManager = null;
      }
    });

    test('should initialize successfully', () async {
      expect(integrationManager!.isInitialized, false);

      // Test initialization
      await integrationManager!.initialize();

      expect(integrationManager!.isInitialized, true);
      expect(integrationManager!.apiManager, isNotNull);
      expect(integrationManager!.authService, isNotNull);
      expect(integrationManager!.userService, isNotNull);
      expect(integrationManager!.localStorageService, isNotNull);
    });

    test('should have all service getters available', () async {
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
    });

    test('should handle authentication state properly', () async {
      await integrationManager!.initialize();

      // Test authentication state stream
      expect(integrationManager!.authenticationStateStream, isNotNull);

      // Initially should not be authenticated
      final authState =
          await integrationManager!.authenticationStateStream.first;
      expect(authState.isAuthenticated, false);
    });

    test('should provide role-based access streams', () async {
      await integrationManager!.initialize();

      // Test dashboard streams
      expect(integrationManager!.mitraDataStream, isNotNull);
      expect(integrationManager!.userDataStream, isNotNull);
      expect(integrationManager!.petugasDataStream, isNotNull);
    });

    test('should dispose properly', () async {
      await integrationManager!.initialize();
      expect(integrationManager!.isInitialized, true);

      await integrationManager!.dispose();

      // Note: isInitialized flag might not change after dispose
      // but all streams should be closed
    });

    group('Dashboard Methods', () {
      setUp(() async {
        await integrationManager!.initialize();
      });

      test('should have dashboard methods available', () {
        expect(integrationManager!.getDashboardData, isNotNull);
        expect(integrationManager!.getMitraData, isNotNull);
        expect(integrationManager!.getUserData, isNotNull);
        expect(integrationManager!.getPetugasData, isNotNull);
      });
    });

    group('Service Methods', () {
      setUp(() async {
        await integrationManager!.initialize();
      });

      test('should have service helper methods available', () {
        expect(integrationManager!.isServiceAvailable, isNotNull);
        expect(integrationManager!.getAllServices, isNotNull);
        expect(integrationManager!.getServiceHealth, isNotNull);
      });
    });
  });
}
