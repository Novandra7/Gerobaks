import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/services/user_service.dart';

class ProfileController {
  static ProfileController? _instance;
  late UserService _userService;
  UserModel? _cachedUser;
  
  // Singleton pattern
  static Future<ProfileController> getInstance() async {
    _instance ??= ProfileController._internal();
    return _instance!;
  }
  
  ProfileController._internal();
  
  Future<void> init() async {
    _userService = await UserService.getInstance();
    await _userService.init();
    
    // Pre-cache the user data
    await refreshUserData();
    
    // Set up listener for user changes
    _userService.addUserChangeListener(_handleUserChange);
  }
  
  void _handleUserChange(UserModel? user) {
    _cachedUser = user;
  }
  
  Future<void> refreshUserData() async {
    _cachedUser = await _userService.getCurrentUser();
  }
  
  UserModel? get currentUser => _cachedUser;
  
  String get userName => _cachedUser?.name ?? 'Guest';
  
  String get userEmail => _cachedUser?.email ?? '';
  
  String? get profilePicture => _cachedUser?.profilePicUrl;
  
  int get userPoints => _cachedUser?.points ?? 0;
  
  // Other profile-related methods can be added here
}
