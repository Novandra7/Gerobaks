import 'package:bank_sha/services/api_client.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/api_routes.dart';

/// Service Model untuk API response
class Service {
  final int id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String category;
  final bool isActive;
  final String? imageUrl;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.category,
    this.isActive = true,
    this.imageUrl,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'unit',
      category: map['category'] ?? 'general',
      isActive: map['is_active'] ?? true,
      imageUrl: map['image_url'],
      additionalInfo: map['additional_info'],
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'category': category,
      'is_active': isActive,
      'image_url': imageUrl,
      'additional_info': additionalInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice =>
      'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

/// Service untuk mengelola layanan sampah
class ServiceManagementService {
  ServiceManagementService._internal();
  static final ServiceManagementService _instance =
      ServiceManagementService._internal();
  factory ServiceManagementService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get list of services
  /// [includeInactive] - include inactive services (default: false)
  /// [category] - filter by category
  Future<List<Service>> getServices({
    bool includeInactive = false,
    String? category,
  }) async {
    try {
      final query = <String, dynamic>{
        if (includeInactive) 'all': 'true',
        if (category != null) 'category': category,
      };

      final response = await _api.getJson(ApiRoutes.services, query: query);

      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => Service.fromMap(item)).toList();
      }

      throw Exception('Failed to load services');
    } catch (e) {
      print('❌ Failed to get services: $e');
      rethrow;
    }
  }

  /// Get single service by ID
  Future<Service> getService(int id) async {
    try {
      final response = await _api.get(ApiRoutes.service(id));

      if (response != null && response['success'] == true) {
        return Service.fromMap(response['data']);
      }

      throw Exception('Service not found');
    } catch (e) {
      print('❌ Failed to get service $id: $e');
      rethrow;
    }
  }

  /// Create new service (requires admin role)
  Future<Service> createService({
    required String name,
    required String description,
    required double price,
    required String unit,
    required String category,
    bool isActive = true,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      _authManager.requireRole('admin'); // Only admin can create services

      final requestData = {
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'category': category,
        'is_active': isActive,
        if (imageUrl != null) 'image_url': imageUrl,
        if (additionalInfo != null) 'additional_info': additionalInfo,
      };

      final response = await _api.postJson(ApiRoutes.services, requestData);

      if (response != null && response['success'] == true) {
        return Service.fromMap(response['data']);
      }

      throw Exception('Failed to create service');
    } catch (e) {
      print('❌ Failed to create service: $e');
      rethrow;
    }
  }

  /// Update service (requires admin role)
  Future<Service> updateService(
    int id, {
    String? name,
    String? description,
    double? price,
    String? unit,
    String? category,
    bool? isActive,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      _authManager.requireRole('admin'); // Only admin can update services

      final requestData = <String, dynamic>{};
      if (name != null) requestData['name'] = name;
      if (description != null) requestData['description'] = description;
      if (price != null) requestData['price'] = price;
      if (unit != null) requestData['unit'] = unit;
      if (category != null) requestData['category'] = category;
      if (isActive != null) requestData['is_active'] = isActive;
      if (imageUrl != null) requestData['image_url'] = imageUrl;
      if (additionalInfo != null)
        requestData['additional_info'] = additionalInfo;

      final response = await _api.patchJson(ApiRoutes.service(id), requestData);

      if (response != null && response['success'] == true) {
        return Service.fromMap(response['data']);
      }

      throw Exception('Failed to update service');
    } catch (e) {
      print('❌ Failed to update service $id: $e');
      rethrow;
    }
  }

  /// Get services by category
  Future<List<Service>> getServicesByCategory(String category) async {
    return await getServices(category: category);
  }

  /// Get active services only
  Future<List<Service>> getActiveServices() async {
    return await getServices(includeInactive: false);
  }

  /// Get service categories
  List<String> getServiceCategories() {
    return [
      'household', // Sampah rumah tangga
      'commercial', // Sampah komersial
      'industrial', // Sampah industri
      'organic', // Sampah organik
      'recyclable', // Sampah daur ulang
      'electronic', // Sampah elektronik
      'hazardous', // Sampah berbahaya
      'construction', // Sampah konstruksi
    ];
  }

  /// Get service units
  List<String> getServiceUnits() {
    return [
      'kg', // Kilogram
      'unit', // Per unit
      'bag', // Per kantong
      'box', // Per kotak
      'trip', // Per perjalanan
      'hour', // Per jam
      'm3', // Meter kubik
    ];
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      _authManager.requireAuth();
      // Placeholder implementation - replace with actual notification service call
      return 0;
    } catch (e) {
      print('❌ Failed to get unread notifications count: $e');
      return 0;
    }
  }

  /// Check if user can manage services
  bool canManageServices() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }

  /// Search services by name or description
  Future<List<Service>> searchServices(String query) async {
    try {
      final allServices = await getActiveServices();
      final lowerQuery = query.toLowerCase();

      return allServices
          .where(
            (service) =>
                service.name.toLowerCase().contains(lowerQuery) ||
                service.description.toLowerCase().contains(lowerQuery) ||
                service.category.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      print('❌ Failed to search services: $e');
      rethrow;
    }
  }
}

/// Notification Model untuk API response
class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toInt() ?? 0,
      userId: map['user_id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'general',
      isRead: map['is_read'] ?? false,
      data: map['data'],
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Service untuk mengelola notifikasi
class NotificationApiService {
  NotificationApiService._internal();
  static final NotificationApiService _instance =
      NotificationApiService._internal();
  factory NotificationApiService() => _instance;

  final ApiClient _api = ApiClient();
  final ApiServiceManager _authManager = ApiServiceManager();

  /// Get list of notifications with pagination
  /// [page] - halaman data (default: 1)
  /// [limit] - jumlah data per halaman (default: 20)
  /// [isRead] - filter berdasarkan status baca
  /// [type] - filter berdasarkan tipe notifikasi
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (isRead != null) 'is_read': isRead,
        if (type != null) 'type': type,
      };

      final response = await _api.getJson(
        ApiRoutes.notifications,
        query: query,
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        return {
          'notifications': (data['data'] as List)
              .map((item) => NotificationModel.fromMap(item))
              .toList(),
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'per_page': data['per_page'] ?? limit,
            'total': data['total'] ?? 0,
          },
          'unread_count': data['unread_count'] ?? 0,
        };
      }

      throw Exception('Failed to load notifications');
    } catch (e) {
      print('❌ Failed to get notifications: $e');
      rethrow;
    }
  }

  /// Create notification (requires admin role)
  Future<NotificationModel> createNotification({
    required int userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      _authManager.requireRole('admin'); // Only admin can create notifications

      final requestData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        if (data != null) 'data': data,
      };

      final response = await _api.postJson(
        ApiRoutes.notifications,
        requestData,
      );

      if (response != null && response['success'] == true) {
        return NotificationModel.fromMap(response['data']);
      }

      throw Exception('Failed to create notification');
    } catch (e) {
      print('❌ Failed to create notification: $e');
      rethrow;
    }
  }

  /// Mark notifications as read
  Future<void> markNotificationsAsRead(List<int> notificationIds) async {
    try {
      _authManager.requireAuth(); // Requires authentication

      final requestData = {'notification_ids': notificationIds};

      final response = await _api.postJson(
        ApiRoutes.notificationMarkRead,
        requestData,
      );

      if (response == null || response['success'] != true) {
        throw Exception('Failed to mark notifications as read');
      }
    } catch (e) {
      print('❌ Failed to mark notifications as read: $e');
      rethrow;
    }
  }

  /// Mark single notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    await markNotificationsAsRead([notificationId]);
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final result = await getNotifications(limit: 100, isRead: false);
      final unreadNotifications =
          result['notifications'] as List<NotificationModel>;

      if (unreadNotifications.isNotEmpty) {
        final ids = unreadNotifications.map((n) => n.id).toList();
        await markNotificationsAsRead(ids);
      }
    } catch (e) {
      print('❌ Failed to mark all notifications as read: $e');
      rethrow;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final result = await getNotifications(limit: 1);
      return result['unread_count'] as int;
    } catch (e) {
      print('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Get notification types
  List<String> getNotificationTypes() {
    return [
      'general', // General notifications
      'order', // Order-related notifications
      'schedule', // Schedule-related notifications
      'payment', // Payment-related notifications
      'system', // System notifications
      'promotion', // Promotional notifications
    ];
  }

  /// Check if user can create notifications
  bool canCreateNotifications() {
    return _authManager.isAuthenticated && _authManager.isAdmin;
  }

  /// Stream of real-time notifications (polling-based)
  Stream<List<NotificationModel>> watchNotifications() async* {
    while (true) {
      try {
        final result = await getNotifications(limit: 20);
        yield result['notifications'] as List<NotificationModel>;

        // Poll every 30 seconds
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        print('❌ Error in notification stream: $e');
        yield [];
        await Future.delayed(
          const Duration(minutes: 1),
        ); // Longer delay on error
      }
    }
  }
}
