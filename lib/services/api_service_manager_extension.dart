import 'package:bank_sha/services/api_service_manager.dart';
import 'package:bank_sha/services/api_client_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Extension untuk menambahkan fitur yang dibutuhkan untuk service mitra
extension ApiServiceManagerExtension on ApiServiceManager {
  
  /// Mendapatkan data user yang sedang login
  Future<Map<String, dynamic>> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    
    return user.toMap();
  }
  
  /// Memastikan pengguna memiliki role yang diizinkan
  void requireRole(String requiredRole) {
    if (!isAuthenticated) {
      throw Exception('Anda harus login terlebih dahulu');
    }
    
    final role = userRole;
    if (requiredRole == 'mitra' && role != 'mitra' && role != 'admin') {
      throw Exception('Anda tidak memiliki hak akses sebagai mitra');
    }
    
    if (requiredRole == 'admin' && role != 'admin') {
      throw Exception('Anda tidak memiliki hak akses sebagai admin');
    }
  }
  
  /// Check if user has mitra role
  bool get isMitraRole => userRole == 'mitra' || userRole == 'admin';

  /// Check if user has admin role
  bool get isAdminRole => userRole == 'admin';
  
  /// Check if user has end_user role
  bool get isEndUserRole => userRole == 'end_user';
  
  /// Get driver (mitra) ID
  Future<String?> getDriverId() async {
    if (!isAuthenticated) return null;
    if (userRole != 'mitra' && userRole != 'admin') return null;
    return currentUser?.id.toString();
  }
  
  /// Save persisted current area for mitra
  Future<void> saveCurrentArea(String area) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_work_area', area);
  }
  
  /// Get current persisted area for mitra
  Future<String?> getCurrentArea() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_work_area');
  }
  
  /// Set mitra online/offline status
  Future<void> setMitraStatus(String status) async {
    requireRole('mitra');
    
    final mitraId = currentUser?.id.toString();
    if (mitraId == null) {
      throw Exception('Mitra ID tidak ditemukan');
    }
    
    // Store locally for offline access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mitra_status', status);
    
    // Send to API
    await client.patchJson('/api/mitra/$mitraId/status', {'status': status});
  }
  
  /// Get mitra online/offline status
  Future<String> getMitraStatus() async {
    requireRole('mitra');
    
    final prefs = await SharedPreferences.getInstance();
    final localStatus = prefs.getString('mitra_status');
    
    if (localStatus != null) {
      return localStatus;
    }
    
    // If not stored locally, get from user data
    final userData = await getCurrentUserData();
    return userData['status'] ?? 'offline';
  }
  
  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? vehicleType,
    String? vehiclePlate,
    String? workArea,
  }) async {    
    if (!isAuthenticated) {
      throw Exception('Anda harus login terlebih dahulu');
    }
    
    final data = <String, dynamic>{
      'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      // Add mitra-specific fields
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (workArea != null) 'work_area': workArea,
    };
    
    final response = await client.postJson('/api/user/update-profile', data);
    
    if (response != null && response['success'] == true) {
      // Update cached user data
      await _verifyCurrentUser();
      return response['data'];
    }
    
    throw Exception('Gagal memperbarui profil: ${response?['message'] ?? 'Terjadi kesalahan'}');
  }
  
  /// Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(File image) async {
    if (!isAuthenticated) {
      throw Exception('Anda harus login terlebih dahulu');
    }
    
    final response = await client.uploadFile(
      '/api/user/upload-profile-image',
      'profile_image',
      image,
    );
    
    if (response != null && response['success'] == true) {
      // Update cached user data
      await _verifyCurrentUser();
      return response['data'];
    }
    
    throw Exception('Gagal mengunggah gambar: ${response?['message'] ?? 'Terjadi kesalahan'}');
  }
  
  /// Private method to verify current user - exposed from ApiServiceManager
  Future<void> _verifyCurrentUser() async {
    if (!isAuthenticated) return;
    
    try {
      await refreshUser();
    } catch (e) {
      throw Exception('Gagal memperbarui data pengguna');
    }
  }
}