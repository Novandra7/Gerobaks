import 'package:bank_sha/models/user_model.dart';
import 'package:bank_sha/controllers/profile_controller.dart';
import 'package:flutter/material.dart';

/// Provider for user profile data
/// This can be used to access user data across the app
class ProfileProvider extends ChangeNotifier {
  final ProfileController _profileController;
  UserModel? _user;
  bool _isLoading = true;
  
  ProfileProvider({required ProfileController profileController}) 
      : _profileController = profileController {
    _loadUser();
  }
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get userName => _user?.name ?? 'Guest';
  String get userEmail => _user?.email ?? '';
  int get userPoints => _user?.points ?? 0;
  
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    _user = _profileController.currentUser;
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refreshUser() async {
    _isLoading = true;
    notifyListeners();
    
    await _profileController.refreshUserData();
    _user = _profileController.currentUser;
    _isLoading = false;
    notifyListeners();
  }
}
