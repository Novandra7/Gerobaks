import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
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
    print("Registering user: $name ($email)");

    // Check if user already exists
    final existingUser = await _getUserByEmail(email);
    if (existingUser != null) {
      print("Email already in use: $email");
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

    print("Created new user model: ${newUser.name} (${newUser.id})");

    // Convert to JSON for storage - this ensures all fields use the correct keys
    final Map<String, dynamic> userData = newUser.toJson();
    // Add password for authentication
    userData['password'] = password;

    try {
      // Save credentials for auto-login
      await _localStorage.saveCredentials(email, password);
      print("Saved credentials for: $email");

      // Save user data with password
      await _localStorage.saveUserData(userData);
      print("Saved user data for: $email");

      // Save user model
      await _localStorage.saveUser(newUser);
      print("Saved user model for: ${newUser.name}");

      // Notify listeners about the new user
      _notifyUserChange(newUser);
      print("Notified listeners about new user: ${newUser.name}");

      // Double-check the user was saved
      final checkUser = await _localStorage.getUser();
      if (checkUser != null) {
        // print(
        //   "Verification - User found: ${checkUser.name} (${checkUser.email})",
        // );
      } else {
        print("WARNING: User not found after saving!");
      }

      return newUser;
    } catch (e) {
      print("Error saving user: $e");
      throw Exception("Failed to save user: $e");
    }
  }

  // Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    // print("🔐 === LOGIN ATTEMPT START ===");
    // print("🔐 Email: $email");

    try {
      // Step 1: Check localStorage first
      // print("🔐 Step 1: Checking localStorage...");
      final userData = await _localStorage.getUserData();
      // print("🔐 LocalStorage data found: ${userData != null}");

      if (userData != null &&
          userData['email'] == email &&
          userData['password'] == password) {
        // print("🔐 Step 1.1: Credentials match existing user data");

        // Get or create UserModel
        UserModel? user = await _localStorage.getUser();

        if (user != null) {
          // print("🔐 Step 1.2: Found existing UserModel: ${user.name}");
          final updatedUser = user.copyWith(lastLogin: DateTime.now());
          await _localStorage.saveUser(updatedUser);
        } else {
          // print("🔐 Step 1.3: Creating UserModel from userData");
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

        // ✅ CRITICAL FIX: Set login flag to true
        await _localStorage.saveBool(_localStorage.getLoginKey(), true);
        // print("🔐 ✅ Login flag set to TRUE for existing user");

        _notifyUserChange(user);
        // print("🔐 ✅ LOGIN SUCCESS with existing user");
        return user;
      }

      // Step 2: Check mock data
      // print("🔐 Step 2: Checking mock data...");
      final mockUserData = UserDataMock.getUserByEmail(email);
      // print("🔐 Mock user found: ${mockUserData != null}");

      if (mockUserData != null && mockUserData['password'] == password) {
        // print("🔐 Step 2.1: Mock credentials match");

        // Generate new UUID for mock user conversion
        final newId = const Uuid().v4();
        // print("🔐 Step 2.2: Generated new UUID: $newId");

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
        
        // Tambahkan data penting yang tidak ada di model
        userData['password'] = password;
        userData['role'] = mockUserData['role'] ?? 'end_user';
        
        print("� [USER] Login success for ${user.name} with role: ${userData['role']}");
        
        // Simpan data lengkap dan pastikan set flag login
        await _localStorage.saveUserData(userData);
        await _localStorage.saveUser(user);
        await _localStorage.saveCredentials(email, password);
        await _localStorage.saveBool(_localStorage.getLoginKey(), true);

        _notifyUserChange(user);
        // print("🔐 ✅ LOGIN SUCCESS with mock user (converted to real user)");
        return user;
      }

      return null;
    } catch (e, stackTrace) {
      print("🔐 ❌ LOGIN ERROR: $e");
      print("🔐 StackTrace: $stackTrace");
      return null;
    } finally {
      print("🔐 === LOGIN ATTEMPT END ===");
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final isLoggedIn = await _localStorage.isLoggedIn();
    if (!isLoggedIn) {
      return null;
    }

    return await _localStorage.getUser();
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
    final user = await _localStorage.getUser();

    if (user == null) {
      throw Exception('User not logged in');
    }

    final updatedUser = user.copyWith(
      name: name ?? user.name,
      phone: phone ?? user.phone,
      address: address ?? user.address,
      latitude: latitude ?? user.latitude,
      longitude: longitude ?? user.longitude,
      profilePicUrl: profilePicUrl ?? user.profilePicUrl,
      isPhoneVerified: isPhoneVerified ?? user.isPhoneVerified,
    );

    await _localStorage.saveUser(updatedUser);
    _notifyUserChange(updatedUser);
    return updatedUser;
  }

  // Update user's saved addresses
  Future<UserModel> updateSavedAddresses(List<String> addresses) async {
    final user = await _localStorage.getUser();

    if (user == null) {
      throw Exception('User not logged in');
    }

    final updatedUser = user.copyWith(savedAddresses: addresses);

    await _localStorage.saveUser(updatedUser);
    _notifyUserChange(updatedUser);
    return updatedUser;
  }

  // Add points to user
  Future<int> addPoints(int amount) async {
    await _localStorage.addPoints(amount);
    return await _localStorage.getUserPoints();
  }

  // Use points (deduct from user's balance)
  Future<int> usePoints(int amount) async {
    final currentPoints = await _localStorage.getUserPoints();

    if (currentPoints < amount) {
      throw Exception('Not enough points');
    }

    await _localStorage.updateUserPoints(currentPoints - amount);
    return await _localStorage.getUserPoints();
  }
  
  // Update user data directly
  Future<UserModel> updateUserData(UserModel user) async {
    await _localStorage.saveUser(user);
    _notifyUserChange(user);
    return user;
  }
  
  // Request OTP for phone verification
  Future<String> requestPhoneVerification(String phoneNumber) async {
    // In a real app, this would call an API to send SMS
    // For demo purposes, we'll generate a simple OTP
    final otp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    
    // In a real app, store this OTP with the phone number in a temporary storage
    // For demo, we'll store it in localStorage with a key based on the phone number
    await _localStorage.saveValue('otp_for_$phoneNumber', otp);
    
    print('Generated OTP for $phoneNumber: $otp');
    return otp; // Return OTP for demo purposes, in production just return success status
  }
  
  // Verify phone with OTP
  Future<bool> verifyPhoneWithOTP(String phoneNumber, String otp) async {
    // In a real app, validate against stored OTP or call API
    // For demo, we'll check against our localStorage
    final storedOTP = await _localStorage.getValue('otp_for_$phoneNumber');
    
    if (storedOTP == otp) {
      // Update user with verified phone
      final user = await getCurrentUser();
      if (user != null) {
        await updateUserProfile(
          phone: phoneNumber,
          isPhoneVerified: true,
        );
      }
      
      // Clear OTP after successful verification
      await _localStorage.removeValue('otp_for_$phoneNumber');
      return true;
    }
    
    return false;
  }

  // Save an address
  Future<List<String>> saveAddress(String address) async {
    await _localStorage.saveAddress(address);
    return await _localStorage.getSavedAddresses();
  }

  // Get all saved addresses
  Future<List<String>> getSavedAddresses() async {
    return await _localStorage.getSavedAddresses();
  }

  // Log out - modified to preserve user data
  Future<void> logout() async {
    // Log out the user (changing login status) without deleting data
    await _localStorage.logout();

    // Notify listeners that the user has logged out
    _notifyUserChange(null);

    print("User logged out via UserService");
  }

  // Helper method to find user by email
  Future<Map<String, dynamic>?> _getUserByEmail(String email) async {
    final userData = await _localStorage.getUserData();
    if (userData != null && userData['email'] == email) {
      return userData;
    }
    return null;
  }
}
