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
      await integrationManager.initialize();

      // Core services
      expect(integrationManager.apiManager, isNotNull);
      expect(integrationManager.authService, isNotNull);
      expect(integrationManager.userService, isNotNull);
      expect(integrationManager.localStorageService, isNotNull);
      expect(integrationManager.notificationService, isNotNull);

      // Feature services
      expect(integrationManager.scheduleService, isNotNull);
      expect(integrationManager.trackingService, isNotNull);
      expect(integrationManager.orderService, isNotNull);
      expect(integrationManager.serviceManagementService, isNotNull);
      expect(integrationManager.dashboardBalanceService, isNotNull);
      expect(integrationManager.chatService, isNotNull);
      expect(integrationManager.paymentRatingService, isNotNull);
      expect(integrationManager.reportAdminService, isNotNull);
    });

    test('should handle authentication state properly', () async {
      await integrationManager.initialize();

      // Initially not authenticated
      expect(integrationManager.isAuthenticated, false);
      expect(integrationManager.currentUser, isNull);
      expect(integrationManager.isAdmin, false);
      expect(integrationManager.isMitra, false);
      expect(integrationManager.isEndUser, false);
    });

    test('should provide role-based access streams', () async {
      await integrationManager.initialize();

      expect(integrationManager.userStream, isNotNull);
      expect(integrationManager.notificationStream, isNotNull);
      expect(integrationManager.dataUpdateStream, isNotNull);
    });

    test('should dispose properly', () async {
      await integrationManager.initialize();
      expect(integrationManager.isInitialized, true);

      await integrationManager.dispose();
      expect(integrationManager.isInitialized, false);
    });
  });
}
