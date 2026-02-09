import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/auth_api_service.dart';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/utils/user_data_mock.dart';
import 'package:uuid/uuid.dart';

class UserService {
  static UserService? _instance;
  late LocalStorageService _localStorage;

  final List<Function(UserModel?)> _userChangeListeners = [];

  void addUserChangeListener(Function(UserModel?) listener) {
    _userChangeListeners.add(listener);
  }

  void removeUserChangeListener(Function(UserModel?) listener) {
    _userChangeListeners.remove(listener);
  }

  void _notifyUserChange(UserModel? user) {
    for (var listener in _userChangeListeners) {
      listener(user);
    }
  }

  // Singleton pattern
  static Future<UserService> getInstance() async {
    _instance ??= UserService._internal();
    return _instance!;
  }

  UserService._internal();

  // Initialize the service with localStorage
  Future<void> init() async {
    _localStorage = await LocalStorageService.getInstance();
  }

  // Register a new user
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email already in use');
      }

      final String userId = const Uuid().v4();
      final DateTime now = DateTime.now();

      // Create user model first
      final newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        points: 15,
        profilePicUrl: 'assets/img_profile.png',
        createdAt: now,
        lastLogin: now,
        savedAddresses: address != null ? [address] : null,
      );

      // Convert to JSON for storage - this ensures all fields use the correct keys
      final Map<String, dynamic> userData = newUser.toJson();
      // Add password for authentication
      userData['password'] = password;

      // Save credentials for auto-login
      await _localStorage.saveCredentials(email, password);

      // Save user data with password
      await _localStorage.saveUserData(userData);

      // Save user model
      await _localStorage.saveUser(newUser);

      // Notify listeners about the new user
      _notifyUserChange(newUser);

      return newUser;
    } catch (e) {
      throw Exception("Failed to register user: $e");
    }
  }

  // Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Check localStorage first
      final userData = await _localStorage.getUserData();

      if (userData != null &&
          userData['email'] == email &&
          userData['password'] == password) {
        // Get or create UserModel
        UserModel? user = await _localStorage.getUser();

        if (user != null) {
          final updatedUser = user.copyWith(lastLogin: DateTime.now());
          await _localStorage.saveUser(updatedUser);
          user = updatedUser;
        } else {
          user = UserModel(
            id: userData['id'] ?? const Uuid().v4(),
            name: userData['name'] ?? 'User',
            email: userData['email'],
            phone: userData['phone'],
            address: userData['address'],
            profilePicUrl:
                userData['profilePicUrl'] ?? userData['profile_picture'],
            points: userData['points'] ?? 15,
            createdAt: userData['createdAt'] != null
                ? DateTime.parse(userData['createdAt'])
                : DateTime.now(),
            lastLogin: DateTime.now(),
          );

          await _localStorage.saveUser(user);
        }

        // Set login flag to true
        await _localStorage.saveBool(_localStorage.getLoginKey(), true);

        _notifyUserChange(user);
        return user;
      }

      // Step 2: Check mock data
      final mockUserDataFuture = UserDataMock.getUserByEmail(email);
      final mockUserData = await mockUserDataFuture;

      if (mockUserData != null && mockUserData['password'] == password) {
        // Generate new UUID for mock user conversion
        final newId = const Uuid().v4();

        // Create UserModel from mock data
        final user = UserModel(
          id: newId,
          name: mockUserData['name'],
          email: mockUserData['email'],
          phone: mockUserData['phone'],
          address: mockUserData['address'],
          profilePicUrl: mockUserData['profile_picture'],
          points: mockUserData['points'] ?? 15,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Save mock user data for future sessions
        final userData = user.toJson();

        // Add important data not in model
        userData['password'] = password;
        userData['role'] = mockUserData['role'] ?? 'end_user';

        // Save complete data and set login flag
        await _localStorage.saveUserData(userData);
        await _localStorage.saveUser(user);
        await _localStorage.saveCredentials(email, password);
        await _localStorage.saveBool(_localStorage.getLoginKey(), true);

        _notifyUserChange(user);
        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final isLoggedIn = await _localStorage.isLoggedIn();
      if (!isLoggedIn) {
        return null;
      }

      return await _localStorage.getUser();
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? profilePicUrl,
    bool? isPhoneVerified,
  }) async {
    try {
      final user = await _localStorage.getUser();

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Call API to update profile
      try {
        final apiService = ApiServiceManager();
        final data = <String, dynamic>{};

        if (name != null) data['name'] = name;
        if (phone != null) data['phone'] = phone;
        if (address != null) data['address'] = address;
        if (latitude != null) data['latitude'] = latitude;
        if (longitude != null) data['longitude'] = longitude;

        // Only send to API if there are fields to update
        if (data.isNotEmpty) {
          final response = await apiService.client.postJson(
            '/api/user/update-profile',
            data,
          );

          if (response == null || response['success'] != true) {
            throw Exception(
              response?['message'] ?? 'Gagal memperbarui profil di server',
            );
          }
        }
      } catch (e) {
        // If API fails, continue with local update only
        // This allows offline functionality
      }

      // For profilePicUrl, if empty string is passed, use it (to clear the photo)
      // Otherwise, use the provided value or keep the existing one
      final newProfilePicUrl = profilePicUrl != null
          ? (profilePicUrl.isEmpty ? '' : profilePicUrl)
          : user.profilePicUrl;

      final updatedUser = user.copyWith(
        name: name ?? user.name,
        phone: phone ?? user.phone,
        address: address ?? user.address,
        latitude: latitude ?? user.latitude,
        longitude: longitude ?? user.longitude,
        profilePicUrl: newProfilePicUrl,
        isPhoneVerified: isPhoneVerified ?? user.isPhoneVerified,
      );

      await _localStorage.saveUser(updatedUser);
      _notifyUserChange(updatedUser);

      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user's saved addresses
  Future<UserModel> updateSavedAddresses(List<String> addresses) async {
    try {
      final user = await _localStorage.getUser();

      if (user == null) {
        throw Exception('User not logged in');
      }

      final updatedUser = user.copyWith(savedAddresses: addresses);

      await _localStorage.saveUser(updatedUser);
      _notifyUserChange(updatedUser);
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update saved addresses: $e');
    }
  }

  // Add points to user
  Future<int> addPoints(int amount) async {
    try {
      await _localStorage.addPoints(amount);
      return await _localStorage.getUserPoints();
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  // Use points (deduct from user's balance)
  Future<int> usePoints(int amount) async {
    try {
      final currentPoints = await _localStorage.getUserPoints();

      if (currentPoints < amount) {
        throw Exception('Not enough points');
      }

      await _localStorage.updateUserPoints(currentPoints - amount);
      return await _localStorage.getUserPoints();
    } catch (e) {
      throw Exception('Failed to use points: $e');
    }
  }

  // Update user data directly
  Future<UserModel> updateUserData(UserModel user) async {
    try {
      await _localStorage.saveUser(user);
      _notifyUserChange(user);
      return user;
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Request OTP for phone verification
  Future<String> requestPhoneVerification(String phoneNumber) async {
    try {
      // In a real app, this would call an API to send SMS
      // For demo purposes, we'll generate a simple OTP
      final otp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
          .toString();

      // In a real app, store this OTP with the phone number in a temporary storage
      // For demo, we'll store it in localStorage with a key based on the phone number
      await _localStorage.saveValue('otp_for_$phoneNumber', otp);

      return otp; // Return OTP for demo purposes, in production just return success status
    } catch (e) {
      throw Exception('Failed to request phone verification: $e');
    }
  }

  // Verify phone with OTP
  Future<bool> verifyPhoneWithOTP(String phoneNumber, String otp) async {
    try {
      // In a real app, validate against stored OTP or call API
      // For demo, we'll check against our localStorage
      final storedOTP = await _localStorage.getValue('otp_for_$phoneNumber');

      if (storedOTP == otp) {
        // Update user with verified phone
        final user = await getCurrentUser();
        if (user != null) {
          await updateUserProfile(phone: phoneNumber, isPhoneVerified: true);
        }

        // Clear OTP after successful verification
        await _localStorage.removeValue('otp_for_$phoneNumber');
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Failed to verify phone: $e');
    }
  }

  // Save an address
  Future<List<String>> saveAddress(String address) async {
    try {
      await _localStorage.saveAddress(address);
      return await _localStorage.getSavedAddresses();
    } catch (e) {
      throw Exception('Failed to save address: $e');
    }
  }

  // Get all saved addresses
  Future<List<String>> getSavedAddresses() async {
    try {
      return await _localStorage.getSavedAddresses();
    } catch (e) {
      throw Exception('Failed to get saved addresses: $e');
    }
  }

  // Log out - now uses AuthApiService as primary method
  Future<void> logout() async {
    try {
      // Log out from API first (primary method)
      final authService = AuthApiService();
      await authService.logout();
    } catch (e) {
      // Continue with local logout even if API fails
    }

    try {
      // Also log out locally for backward compatibility
      await _localStorage.logout();

      // Notify listeners that the user has logged out
      _notifyUserChange(null);
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Helper method to find user by email
  Future<Map<String, dynamic>?> _getUserByEmail(String email) async {
    try {
      final userData = await _localStorage.getUserData();
      if (userData != null && userData['email'] == email) {
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
