# PSD (Product Specification Document) - Aplikasi Gerobaks

## 📋 Informasi Dokumen
- **Nama Produk**: Gerobaks
- **Versi**: 1.0
- **Tanggal**: 28 Agustus 2025
- **Tim Teknis**: Gerobaks Engineering Team
- **Status**: Technical Specification
- **Lisensi**: 🔴 **"Closed Source"** - Project ini sepenuhnya dilisensikan kepada Gerobaks dan bukan open source

---

## 🏗️ Arsitektur Sistem

### Tech Stack Overview
```
Frontend: Flutter (Dart)
Backend: Node.js / Firebase
Database: Cloud Firestore, SQLite (local)
Storage: Firebase Storage, Local Storage
Authentication: Firebase Auth
Real-time: WebSocket, Firebase Realtime Database
Maps: Google Maps API
Payment: Midtrans, QRIS
Push Notifications: Firebase Cloud Messaging
```

### Arsitektur Aplikasi
```
┌─────────────────────────────────────────┐
│              Presentation Layer         │
│  ┌─────────────┐    ┌─────────────┐    │
│  │ End User UI │    │ Petugas UI  │    │
│  └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│             Business Logic              │
│  ┌───────────┐ ┌─────────┐ ┌─────────┐ │
│  │ Services  │ │ Models  │ │ Utils   │ │
│  └───────────┘ └─────────┘ └─────────┘ │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│              Data Layer                 │
│  ┌─────────────┐    ┌─────────────┐    │
│  │ Local DB    │    │ Remote API  │    │
│  │ (SQLite)    │    │ (Firebase)  │    │
│  └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────┘
```

---

## 📱 Spesifikasi Teknis Aplikasi

### Platform Support
- **Android**: Minimum API 21 (Android 5.0)
- **iOS**: Minimum iOS 12.0
- **Flutter Version**: 3.19.0+
- **Dart Version**: 3.3.0+

### Dependencies Utama
```yaml
dependencies:
  flutter: ^3.19.0
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_messaging: ^14.7.10
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  shared_preferences: ^2.2.2
  http: ^1.1.0
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  provider: ^6.1.1
  intl: ^0.18.1
  flutter_local_notifications: ^16.3.0
```

---

## 🗄️ Struktur Database

### Local Database (SQLite)
```sql
-- Users Table
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    profile_image TEXT,
    points INTEGER DEFAULT 15,
    role TEXT DEFAULT 'user', -- user, mitra
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Addresses Table
CREATE TABLE addresses (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    title TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude REAL,
    longitude REAL,
    is_primary BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Orders Table
CREATE TABLE orders (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    petugas_id TEXT,
    address_id TEXT,
    pickup_date DATE,
    pickup_time TIME,
    waste_type TEXT, -- organik,anorganik,b3
    weight REAL,
    status TEXT, -- pending,accepted,in_progress,completed,cancelled
    points_earned INTEGER,
    photo_evidence TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Subscriptions Table
CREATE TABLE subscriptions (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    plan_name TEXT,
    plan_type TEXT, -- basic,premium,family
    start_date DATE,
    end_date DATE,
    amount REAL,
    status TEXT, -- active,expired,cancelled
    payment_method TEXT,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Points History Table
CREATE TABLE points_history (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    order_id TEXT,
    type TEXT, -- earned,spent
    amount INTEGER,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);
```

### Cloud Database (Firestore)
```javascript
// Users Collection
users: {
  [userId]: {
    email: string,
    name: string,
    phone: string,
    profile_image: string,
    points: number,
    role: 'user' | 'mitra',
    addresses: string[], // address IDs
    subscription: {
      plan_id: string,
      status: 'active' | 'expired',
      end_date: timestamp
    },
    created_at: timestamp,
    updated_at: timestamp
  }
}

// Orders Collection
orders: {
  [orderId]: {
    user_id: string,
    petugas_id: string,
    pickup_location: {
      address: string,
      latitude: number,
      longitude: number
    },
    pickup_datetime: timestamp,
    waste_details: {
      type: 'organik' | 'anorganik' | 'b3',
      estimated_weight: number,
      actual_weight: number
    },
    status: 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled',
    tracking: {
      petugas_location: {
        latitude: number,
        longitude: number,
        timestamp: timestamp
      },
      status_history: [
        {
          status: string,
          timestamp: timestamp,
          notes: string
        }
      ]
    },
    payment: {
      amount: number,
      method: string,
      status: 'pending' | 'paid' | 'failed'
    },
    evidence: {
      before_photos: string[],
      after_photos: string[],
      signature: string
    },
    rating: {
      score: number,
      comment: string
    }
  }
}

// Petugas Collection
petugas: {
  [petugasId]: {
    personal_info: {
      name: string,
      nik: string,
      phone: string,
      email: string,
      profile_image: string
    },
    documents: {
      ktp: string,
      skck: string,
      vehicle_license: string
    },
    work_info: {
      vehicle_type: string,
      vehicle_plate: string,
      work_area: string[],
      status: 'active' | 'inactive' | 'suspended'
    },
    location: {
      latitude: number,
      longitude: number,
      last_updated: timestamp
    },
    statistics: {
      total_orders: number,
      completed_orders: number,
      rating: number,
      total_earnings: number
    }
  }
}
```

---

## 🔌 API Specification

### Authentication Endpoints
```typescript
// Register User
POST /api/auth/register
Request: {
  email: string,
  password: string,
  name: string,
  phone: string,
  role: 'user' | 'mitra'
}
Response: {
  success: boolean,
  user: UserModel,
  token: string
}

// Login
POST /api/auth/login
Request: {
  email: string,
  password: string
}
Response: {
  success: boolean,
  user: UserModel,
  token: string
}

// OTP Verification
POST /api/auth/verify-otp
Request: {
  phone: string,
  otp: string
}
Response: {
  success: boolean,
  verified: boolean
}
```

### User Management
```typescript
// Get User Profile
GET /api/users/profile
Headers: { Authorization: "Bearer {token}" }
Response: {
  success: boolean,
  user: UserModel
}

// Update Profile
PUT /api/users/profile
Request: {
  name?: string,
  phone?: string,
  profile_image?: string
}
Response: {
  success: boolean,
  user: UserModel
}

// Get Points History
GET /api/users/points/history
Response: {
  success: boolean,
  history: PointsHistoryModel[]
}
```

### Orders Management
```typescript
// Create Order
POST /api/orders
Request: {
  pickup_location: LocationModel,
  pickup_datetime: timestamp,
  waste_type: string,
  notes?: string
}
Response: {
  success: boolean,
  order: OrderModel
}

// Get User Orders
GET /api/orders/user
Response: {
  success: boolean,
  orders: OrderModel[]
}

// Update Order Status (Petugas)
PUT /api/orders/{orderId}/status
Request: {
  status: string,
  location?: LocationModel,
  photos?: string[],
  notes?: string
}
Response: {
  success: boolean,
  order: OrderModel
}

// Get Petugas Orders
GET /api/orders/petugas
Response: {
  success: boolean,
  orders: OrderModel[]
}
```

### Real-time Tracking
```typescript
// WebSocket Events
// Client -> Server
{
  type: 'JOIN_TRACKING',
  orderId: string
}

{
  type: 'UPDATE_LOCATION',
  orderId: string,
  location: {
    latitude: number,
    longitude: number
  }
}

// Server -> Client
{
  type: 'LOCATION_UPDATE',
  orderId: string,
  petugas_location: LocationModel,
  timestamp: number
}

{
  type: 'STATUS_UPDATE',
  orderId: string,
  status: string,
  timestamp: number
}
```

---

## 📐 Data Models

### User Model
```dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImage;
  final int points;
  final String role; // 'user' or 'mitra'
  final List<String> savedAddresses;
  final UserSubscription? subscription;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage,
    this.points = 15,
    this.role = 'user',
    this.savedAddresses = const [],
    this.subscription,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

### Order Model
```dart
class OrderModel {
  final String id;
  final String userId;
  final String? petugasId;
  final LocationModel pickupLocation;
  final DateTime pickupDatetime;
  final WasteDetails wasteDetails;
  final OrderStatus status;
  final TrackingInfo? tracking;
  final PaymentInfo? payment;
  final EvidenceInfo? evidence;
  final RatingInfo? rating;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    this.petugasId,
    required this.pickupLocation,
    required this.pickupDatetime,
    required this.wasteDetails,
    required this.status,
    this.tracking,
    this.payment,
    this.evidence,
    this.rating,
    required this.createdAt,
  });
}

enum OrderStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled
}
```

### Location Model
```dart
class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final String? title;
  final DateTime timestamp;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.title,
    required this.timestamp,
  });
}
```

### Subscription Model
```dart
class SubscriptionPlan {
  final String id;
  final String name;
  final String type; // 'basic', 'premium', 'family'
  final double price;
  final int durationMonths;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.durationMonths,
    required this.features,
    this.isPopular = false,
  });
}

class UserSubscription {
  final String id;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String status; // 'active', 'expired', 'cancelled'
  final String? paymentMethod;

  bool get isActive => 
    status == 'active' && DateTime.now().isBefore(endDate);
  
  int get daysRemaining => 
    isActive ? endDate.difference(DateTime.now()).inDays : 0;
}
```

---

## 🔧 Services Architecture

### LocalStorageService
```dart
class LocalStorageService {
  static LocalStorageService? _instance;
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  
  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    await _instance!._init();
    return _instance!;
  }

  // User Management
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  
  // Points Management
  Future<void> updateUserPoints(int points);
  Future<int> getUserPoints();
  Future<void> addPoints(int amount);
  
  // Address Management
  Future<void> saveAddress(String address);
  Future<List<String>> getSavedAddresses();
  
  // Session Management
  Future<bool> isLoggedIn();
  Future<void> logout();
}
```

### UserService
```dart
class UserService {
  static UserService? _instance;
  late LocalStorageService _localStorage;
  
  static Future<UserService> getInstance() async {
    _instance ??= UserService._();
    await _instance!.init();
    return _instance!;
  }

  Future<void> init();
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> registerUser(Map<String, dynamic> userData);
  Future<UserModel?> loginUser({required String email, required String password});
  Future<void> updateUser(UserModel user);
  Future<void> logout();
  
  // User change notifications
  void addUserChangeListener(Function(UserModel?) listener);
  void removeUserChangeListener(Function(UserModel?) listener);
}
```

### SubscriptionService
```dart
class SubscriptionService {
  late LocalStorageService _localStorage;
  
  Future<void> initialize();
  List<SubscriptionPlan> getAvailablePlans();
  UserSubscription? getCurrentSubscription();
  Future<bool> subscribeToPlan(SubscriptionPlan plan, String paymentMethod);
  Future<bool> cancelSubscription();
  Future<List<PaymentMethod>> getPaymentMethods();
}
```

### NotificationService
```dart
class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  Future<void> initialize();
  Future<void> requestPermission();
  Future<String?> getToken();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  
  // Local notifications
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });
  
  // Push notification handlers
  void handleForegroundMessage(RemoteMessage message);
  void handleBackgroundMessage(RemoteMessage message);
}
```

### TrackingService
```dart
class TrackingService {
  late StreamController<LocationModel> _locationController;
  late Timer _locationTimer;
  
  Stream<LocationModel> get locationStream => _locationController.stream;
  
  Future<void> startTracking(String orderId);
  Future<void> stopTracking();
  Future<LocationModel> getCurrentLocation();
  Future<List<LocationModel>> getRouteToDestination(
    LocationModel origin,
    LocationModel destination,
  );
  
  // Real-time updates via WebSocket
  void connectToOrderTracking(String orderId);
  void disconnectFromOrderTracking();
}
```

---

## 🎨 UI/UX Specifications

### Design System
```dart
// Colors
class AppColors {
  static const Color primary = Color(0xFF2ECC71);
  static const Color secondary = Color(0xFF3498DB);
  static const Color accent = Color(0xFFE74C3C);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color success = Color(0xFF27AE60);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textDisabled = Color(0xFFBDC3C7);
}

// Typography
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

// Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
```

### Responsive Design
```dart
class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }
  
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isTablet(context)) return baseSize * 1.2;
    if (isDesktop(context)) return baseSize * 1.4;
    return baseSize;
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isTablet(context)) return const EdgeInsets.all(24);
    if (isDesktop(context)) return const EdgeInsets.all(32);
    return const EdgeInsets.all(16);
  }
}
```

### Component Specifications
```dart
// Custom App Bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Loading States
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;
  
  const LoadingWidget({
    this.message,
    this.showMessage = true,
  });
}

// Empty States
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? icon;
  final VoidCallback? onActionPressed;
  final String? actionText;
}

// Error States
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final String? retryText;
}
```

---

## 🔒 Security Specifications

### Authentication Security
```dart
class SecurityService {
  // Token Management
  static Future<void> saveSecureToken(String token);
  static Future<String?> getSecureToken();
  static Future<void> clearSecureToken();
  
  // Data Encryption
  static String encryptSensitiveData(String data);
  static String decryptSensitiveData(String encryptedData);
  
  // Biometric Authentication
  static Future<bool> isBiometricAvailable();
  static Future<bool> authenticateWithBiometric();
  
  // Session Management
  static Future<void> validateSession();
  static Future<void> refreshToken();
}
```

### Data Protection
- **Local Storage**: Encrypt sensitive data using AES-256
- **Network Communication**: HTTPS only with certificate pinning
- **User Data**: GDPR compliant data handling
- **Payment Data**: PCI DSS compliance for payment information

### Permission Management
```dart
class PermissionService {
  static Future<bool> requestLocationPermission();
  static Future<bool> requestCameraPermission();
  static Future<bool> requestStoragePermission();
  static Future<bool> requestNotificationPermission();
  
  static Future<bool> checkLocationPermission();
  static Future<bool> checkCameraPermission();
  static Future<bool> checkStoragePermission();
}
```

---

## 📊 Performance Specifications

### App Performance Targets
- **Cold Start Time**: <3 seconds
- **Hot Start Time**: <1 second
- **Navigation Time**: <300ms between screens
- **API Response Time**: <2 seconds for most calls
- **Map Loading Time**: <5 seconds with cached tiles

### Memory Management
```dart
class PerformanceOptimizer {
  // Image Caching
  static void optimizeImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }
  
  // Memory Monitoring
  static void monitorMemoryUsage() {
    // Implementation for memory monitoring
  }
  
  // Resource Cleanup
  static void cleanupResources() {
    // Cleanup unused resources
  }
}
```

### Offline Capability
```dart
class OfflineService {
  // Cache Management
  static Future<void> cacheEssentialData();
  static Future<void> syncWhenOnline();
  
  // Offline Storage
  static Future<void> saveOfflineOrder(OrderModel order);
  static Future<List<OrderModel>> getOfflineOrders();
  
  // Network Status
  static Stream<bool> get connectivityStream;
  static Future<bool> get isOnline;
}
```

---

## 🧪 Testing Specifications

### Unit Testing
```dart
// User Service Tests
class UserServiceTest {
  group('UserService', () {
    test('should register user successfully', () async {
      // Test implementation
    });
    
    test('should login user with valid credentials', () async {
      // Test implementation
    });
    
    test('should handle invalid login credentials', () async {
      // Test implementation
    });
  });
}
```

### Integration Testing
```dart
// Order Flow Integration Test
class OrderFlowTest {
  group('Order Flow Integration', () {
    testWidgets('complete order creation flow', (tester) async {
      // Test complete order creation from UI to database
    });
    
    testWidgets('petugas order acceptance flow', (tester) async {
      // Test petugas accepting and completing orders
    });
  });
}
```

### Performance Testing
```dart
class PerformanceTest {
  test('app launch performance', () async {
    // Measure app launch time
  });
  
  test('API response time', () async {
    // Test API response times
  });
  
  test('memory usage under load', () async {
    // Test memory consumption
  });
}
```

---

## 🚀 Deployment Specifications

### Build Configuration
```yaml
# Flutter Build Settings
flutter:
  version: 3.19.0
  
android:
  minSdkVersion: 21
  targetSdkVersion: 34
  buildToolsVersion: 34.0.0
  
ios:
  platform: ios, '12.0'
  deployment_target: 12.0
```

### Environment Configuration
```dart
class Environment {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  static String get currentEnvironment {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: development);
  }
  
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case development:
        return 'https://dev-api.gerobaks.com';
      case staging:
        return 'https://staging-api.gerobaks.com';
      case production:
        return 'https://api.gerobaks.com';
      default:
        return 'https://dev-api.gerobaks.com';
    }
  }
}
```

### CI/CD Pipeline
```yaml
# GitHub Actions Configuration
name: Build and Deploy
on:
  push:
    branches: [main, staging, development]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test
      
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - run: flutter build ios --release
      
  deploy:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to Play Store
        uses: r0adkll/upload-google-play@v1
      - name: Deploy to App Store
        uses: apple-actions/upload-testflight-build@v1
```

---

## 📈 Analytics & Monitoring

### Analytics Implementation
```dart
class AnalyticsService {
  // Event Tracking
  static void trackEvent(String eventName, Map<String, dynamic> parameters);
  static void trackScreenView(String screenName);
  static void trackUserAction(String action, Map<String, dynamic> context);
  
  // User Properties
  static void setUserProperty(String name, String value);
  static void setUserId(String userId);
  
  // Custom Metrics
  static void trackOrderCompletion(OrderModel order);
  static void trackSubscriptionPurchase(SubscriptionPlan plan);
  static void trackErrorEvent(String error, Map<String, dynamic> context);
}
```

### Crash Reporting
```dart
class CrashReportingService {
  static Future<void> initialize();
  static void recordError(dynamic error, StackTrace? stackTrace);
  static void recordFlutterError(FlutterErrorDetails details);
  static void setCustomKey(String key, dynamic value);
}
```

---

## 🔗 External Integrations

### Payment Integration
```dart
class PaymentService {
  // Midtrans Integration
  static Future<PaymentResult> processPayment({
    required double amount,
    required String orderId,
    required PaymentMethod method,
  });
  
  // QRIS Integration
  static Future<String> generateQRISCode(double amount);
  
  // Payment Status
  static Future<PaymentStatus> checkPaymentStatus(String transactionId);
}
```

### Maps Integration
```dart
class MapsService {
  // Google Maps
  static Future<LocationModel> getCurrentLocation();
  static Future<List<LocationModel>> searchPlaces(String query);
  static Future<DirectionsResult> getDirections(
    LocationModel origin,
    LocationModel destination,
  );
  
  // Geocoding
  static Future<String> getAddressFromCoordinates(double lat, double lng);
  static Future<LocationModel> getCoordinatesFromAddress(String address);
}
```

---

## 📋 Development Guidelines

### Code Standards
```dart
// Naming Conventions
class NamingConventions {
  // Classes: PascalCase
  class UserService {}
  
  // Variables: camelCase
  String userName = '';
  
  // Constants: UPPER_SNAKE_CASE
  static const String API_BASE_URL = '';
  
  // Files: snake_case
  // user_service.dart, order_model.dart
}
```

### Project Structure
```
lib/
├── main.dart
├── shared/
│   ├── theme.dart
│   └── constants.dart
├── models/
│   ├── user_model.dart
│   ├── order_model.dart
│   └── subscription_model.dart
├── services/
│   ├── user_service.dart
│   ├── local_storage_service.dart
│   └── notification_service.dart
├── ui/
│   ├── pages/
│   │   ├── end_user/
│   │   └── mitra/
│   └── widgets/
│       ├── shared/
│       └── custom/
├── utils/
│   ├── helpers.dart
│   └── validators.dart
└── controllers/
    ├── user_controller.dart
    └── order_controller.dart
```

### Git Workflow
```bash
# Branch Naming
feature/user-authentication
bugfix/order-creation-error
hotfix/payment-gateway-fix

# Commit Message Format
feat: add user registration functionality
fix: resolve payment gateway timeout issue
docs: update API documentation
style: format code according to style guide
refactor: restructure user service
test: add unit tests for order service
```

---

## 🔒 Lisensi dan Keamanan Source Code

### Status Lisensi
🔴 **"CLOSED SOURCE"** - Aplikasi Gerobaks adalah produk proprietary yang sepenuhnya dimiliki dan dilisensikan kepada Gerobaks.

### Perlindungan Kode
- **Copyright**: © 2025 Gerobaks. All rights reserved.
- **Confidentiality**: Source code bersifat strictly confidential
- **Access Control**: Hanya authorized developers yang memiliki akses
- **Code Distribution**: Dilarang mendistribusikan atau membagikan source code

### Security Measures
```dart
// Code Obfuscation
class CodeProtection {
  // Production builds menggunakan code obfuscation
  static bool get isObfuscated => kReleaseMode;
  
  // API keys dan secrets terenkripsi
  static String get encryptedApiKey => Platform.environment['ENCRYPTED_API_KEY'] ?? '';
  
  // Source code protection
  static void validateSourceIntegrity() {
    // Implementasi validasi integritas kode
  }
}
```

### Repository Guidelines
- **Private Repository**: Semua repository bersifat private
- **Access Management**: Role-based access dengan minimal privilege
- **Audit Trail**: Semua perubahan code tracked dan logged
- **Branch Protection**: Main/production branch dilindungi dari direct push

### Intellectual Property
- **Trade Secrets**: Algoritma dan business logic adalah trade secret
- **Proprietary Technology**: Custom framework dan tools milik Gerobaks
- **Third-party Licenses**: Compliance dengan license third-party libraries
- **Patent Protection**: Teknologi unik dilindungi dengan patent filing

---

*Dokumen ini merupakan spesifikasi teknis lengkap untuk pengembangan aplikasi Gerobaks dan akan terus diperbarui seiring dengan perkembangan produk.*
