import 'package:bank_sha/services/api_client.dart';

/// Complete Users Service - User Management (Admin)
///
/// ⚠️ REQUIRES ADMIN ROLE - All endpoints require admin authentication
///
/// Features:
/// - Get all users (GET /api/admin/users) [FIXED PATH]
/// - Get user by ID (GET /api/admin/users/{id}) [FIXED PATH]
/// - Create user (POST /api/admin/users) [FIXED PATH]
/// - Update user (PATCH /api/admin/users/{id}) [FIXED PATH]
/// - Delete user (DELETE /api/admin/users/{id}) [FIXED PATH]
/// - Filter by role (end_user, mitra, admin)
/// - Search by name/email
///
/// Use Cases:
/// - Admin panel user management
/// - User CRUD operations
/// - Role-based filtering
/// - User search and discovery
class UsersService {
  final ApiClient _apiClient = ApiClient();

  // User roles
  static const List<String> roles = ['end_user', 'mitra', 'admin'];

  // ========================================
  // CRUD Operations
  // ========================================

  /// Get all users with filters
  ///
  /// GET /api/admin/users (FIXED: was /api/users)
  /// ⚠️ REQUIRES ADMIN ROLE
  ///
  /// Parameters:
  /// - [role]: Filter by role (end_user, mitra, admin)
  /// - [search]: Search by name or email
  /// - [page]: Page number for pagination (default: 1)
  /// - [perPage]: Items per page (default: 20, max: 100)
  ///
  /// Returns: List of users
  ///
  /// Example:
  /// ```dart
  /// // Get all users
  /// final users = await usersService.getUsers();
  ///
  /// // Get only mitras
  /// final mitras = await usersService.getUsers(role: 'mitra');
  ///
  /// // Search users
  /// final results = await usersService.getUsers(search: 'john');
  /// ```
  Future<List<dynamic>> getUsers({
    String? role,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Validate role if provided
      if (role != null && !roles.contains(role)) {
        throw ArgumentError(
          'Invalid role. Must be one of: ${roles.join(", ")}',
        );
      }

      final query = <String, dynamic>{'page': page, 'per_page': perPage};

      if (role != null) query['role'] = role;
      if (search != null && search.isNotEmpty) query['search'] = search;

      print('👥 Getting users (ADMIN)');
      if (role != null) print('   Filter: Role = $role');
      if (search != null) print('   Search: $search');

      final response = await _apiClient.getJson(
        '/api/admin/users',
        query: query,
      ); // FIXED: /users → /admin/users

      final List<dynamic> data = response['data'] ?? [];

      print('✅ Found ${data.length} users');
      return data;
    } catch (e) {
      print('❌ Error getting users: $e');
      rethrow;
    }
  }

  /// Get user by ID
  ///
  /// GET /api/admin/users/{id} (FIXED: was /api/users/{id})
  /// ⚠️ REQUIRES ADMIN ROLE
  ///
  /// Parameters:
  /// - [userId]: User ID
  ///
  /// Returns: User object
  ///
  /// Example:
  /// ```dart
  /// final user = await usersService.getUserById(123);
  /// print('Name: ${user['name']}');
  /// print('Role: ${user['role']}');
  /// ```
  Future<dynamic> getUserById(int userId) async {
    try {
      print('👥 Getting user #$userId');

      final response = await _apiClient.get('/api/admin/users/$userId');

      final user = response['data'];
      print('✅ User: ${user['name']} (${user['role']})');

      return user;
    } catch (e) {
      print('❌ Error getting user: $e');
      rethrow;
    }
  }

  /// Create new user
  ///
  /// POST /api/users
  ///
  /// Parameters:
  /// - [name]: User name
  /// - [email]: Email address (unique)
  /// - [password]: Password (min 8 chars)
  /// - [role]: User role (end_user, mitra, admin)
  /// - [phone]: Phone number (optional)
  /// - [address]: Address (optional)
  /// - [profilePicture]: Profile picture URL/base64 (optional)
  ///
  /// Returns: Created user object
  ///
  /// Example:
  /// ```dart
  /// final user = await usersService.createUser(
  ///   name: 'John Doe',
  ///   email: 'john@example.com',
  ///   password: 'password123',
  ///   role: 'end_user',
  ///   phone: '08123456789',
  /// );
  /// ```
  Future<dynamic> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? profilePicture,
  }) async {
    try {
      // Validate required fields
      if (name.trim().isEmpty) {
        throw ArgumentError('Name is required');
      }
      if (email.trim().isEmpty) {
        throw ArgumentError('Email is required');
      }
      if (password.length < 8) {
        throw ArgumentError('Password must be at least 8 characters');
      }
      if (!roles.contains(role)) {
        throw ArgumentError(
          'Invalid role. Must be one of: ${roles.join(", ")}',
        );
      }

      final body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
        if (profilePicture != null && profilePicture.isNotEmpty)
          'profile_picture': profilePicture,
      };

      print('👥 Creating user');
      print('   Name: $name');
      print('   Email: $email');
      print('   Role: $role');

      final response = await _apiClient.postJson('/api/admin/users', body);

      print('✅ User created');
      return response['data'];
    } catch (e) {
      print('❌ Error creating user: $e');
      rethrow;
    }
  }

  /// Update existing user
  ///
  /// PUT /api/users/{id}
  ///
  /// Parameters:
  /// - [userId]: User ID to update
  /// - [name]: User name (optional)
  /// - [email]: Email address (optional)
  /// - [password]: New password (optional, min 8 chars)
  /// - [role]: User role (optional)
  /// - [phone]: Phone number (optional)
  /// - [address]: Address (optional)
  /// - [profilePicture]: Profile picture URL/base64 (optional)
  ///
  /// Returns: Updated user object
  ///
  /// Example:
  /// ```dart
  /// // Update user name only
  /// final user = await usersService.updateUser(
  ///   userId: 123,
  ///   name: 'Jane Doe',
  /// );
  ///
  /// // Update multiple fields
  /// final user = await usersService.updateUser(
  ///   userId: 123,
  ///   name: 'Jane Doe',
  ///   phone: '08199999999',
  ///   address: 'New Address',
  /// );
  /// ```
  Future<dynamic> updateUser({
    required int userId,
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
    String? address,
    String? profilePicture,
  }) async {
    try {
      // Validate password if provided
      if (password != null && password.length < 8) {
        throw ArgumentError('Password must be at least 8 characters');
      }

      // Validate role if provided
      if (role != null && !roles.contains(role)) {
        throw ArgumentError(
          'Invalid role. Must be one of: ${roles.join(", ")}',
        );
      }

      final body = <String, dynamic>{};

      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (role != null) body['role'] = role;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;
      if (profilePicture != null) body['profile_picture'] = profilePicture;

      if (body.isEmpty) {
        throw ArgumentError('At least one field must be provided for update');
      }

      print('👥 Updating user #$userId');

      final response = await _apiClient.putJson(
        '/api/admin/users/$userId',
        body,
      );

      print('✅ User updated');
      return response['data'];
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user
  ///
  /// DELETE /api/users/{id}
  ///
  /// Parameters:
  /// - [userId]: User ID to delete
  ///
  /// Example:
  /// ```dart
  /// await usersService.deleteUser(123);
  /// print('User deleted successfully');
  /// ```
  Future<void> deleteUser(int userId) async {
    try {
      print('🗑️ Deleting user #$userId');

      await _apiClient.delete('/api/admin/users/$userId');

      print('✅ User deleted');
    } catch (e) {
      print('❌ Error deleting user: $e');
      rethrow;
    }
  }

  // ========================================
  // Helper Methods
  // ========================================

  /// Get users by role
  ///
  /// Parameters:
  /// - [role]: User role to filter by
  ///
  /// Returns: List of users with specified role
  ///
  /// Example:
  /// ```dart
  /// final mitras = await usersService.getUsersByRole('mitra');
  /// final admins = await usersService.getUsersByRole('admin');
  /// ```
  Future<List<dynamic>> getUsersByRole(String role) async {
    return getUsers(role: role);
  }

  /// Search users by name or email
  ///
  /// Parameters:
  /// - [query]: Search query
  ///
  /// Returns: List of matching users
  ///
  /// Example:
  /// ```dart
  /// final results = await usersService.searchUsers('john');
  /// ```
  Future<List<dynamic>> searchUsers(String query) async {
    return getUsers(search: query);
  }

  /// Get user count by role
  ///
  /// Parameters:
  /// - [role]: Role to count (optional, counts all if null)
  ///
  /// Returns: User count
  ///
  /// Example:
  /// ```dart
  /// final totalMitras = await usersService.getUserCount(role: 'mitra');
  /// final totalUsers = await usersService.getUserCount();
  /// ```
  Future<int> getUserCount({String? role}) async {
    try {
      final users = await getUsers(role: role, perPage: 1);

      // Note: This is a simple implementation
      // For production, backend should provide a count endpoint
      // GET /api/users/count?role=xxx

      return users.length;
    } catch (e) {
      print('❌ Error getting user count: $e');
      return 0;
    }
  }

  /// Validate email format
  ///
  /// Parameters:
  /// - [email]: Email to validate
  ///
  /// Returns: true if valid, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (!usersService.isValidEmail('test@example.com')) {
  ///   showError('Invalid email format');
  /// }
  /// ```
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number format (Indonesian)
  ///
  /// Parameters:
  /// - [phone]: Phone number to validate
  ///
  /// Returns: true if valid, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (!usersService.isValidPhone('08123456789')) {
  ///   showError('Invalid phone number');
  /// }
  /// ```
  bool isValidPhone(String phone) {
    // Indonesian phone: starts with 08, 10-13 digits
    final phoneRegex = RegExp(r'^08\d{8,11}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Get role display name
  ///
  /// Parameters:
  /// - [role]: Role code
  ///
  /// Returns: Display name
  ///
  /// Example:
  /// ```dart
  /// print(usersService.getRoleDisplayName('end_user')); // "End User"
  /// print(usersService.getRoleDisplayName('mitra')); // "Mitra"
  /// ```
  String getRoleDisplayName(String role) {
    switch (role) {
      case 'end_user':
        return 'End User';
      case 'mitra':
        return 'Mitra';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}
