import 'dart:io';
import 'package:bank_sha/services/api_service_manager.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageHelper {
  static final ApiServiceManager _apiService = ApiServiceManager();
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final imageFile = File(pickedFile.path);
      await validateImage(imageFile);

      return imageFile;
    } catch (e) {
      rethrow;
    }
  }

  /// Validate image file size and format
  Future<void> validateImage(File imageFile) async {
    // Check file size (max 2MB)
    final fileSize = await imageFile.length();
    if (fileSize > 2 * 1024 * 1024) {
      throw Exception('Ukuran gambar maksimal 2MB');
    }

    // Check file extension
    final extension = imageFile.path.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'heic'];
    if (!allowedExtensions.contains(extension)) {
      throw Exception('Format file harus JPG, PNG, JPEG, atau HEIC');
    }
  }

  /// Upload profile image to server
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final response = await _apiService.client.postMultipart(
        '/api/user/upload-profile-image',
        files: {'image': imageFile},
      );

      if (response['success'] == true) {
        // API returns image_url in response['data']['image_url']
        final newProfileImageUrl =
            response['data']['image_url'] ??
            response['data']['user']?['profile_picture'];

        if (newProfileImageUrl == null) {
          throw Exception('Gagal mendapatkan URL gambar dari response');
        }

        return newProfileImageUrl;
      } else {
        throw Exception(response['message'] ?? 'Gagal mengupload foto');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Remove profile image from server
  static Future<void> removeProfileImage() async {
    try {
      final response = await _apiService.client.postMultipart(
        '/api/user/upload-profile-image',
        files: {'remove': true},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus foto');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Pick and upload image in one call
  Future<String> pickAndUploadImage(ImageSource source) async {
    final imageFile = await pickImage(source);
    if (imageFile == null) {
      throw Exception('Tidak ada gambar yang dipilih');
    }
    return await uploadProfileImage(imageFile);
  }
}
