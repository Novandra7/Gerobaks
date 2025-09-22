import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Service untuk mengelola image sharing dalam chat
///
/// Features:
/// - Image picker dari camera atau gallery
/// - Permission handling untuk camera dan storage
/// - Image compression dan optimization
/// - Validation untuk image size dan format
/// - File management untuk chat images
class ChatImageService {
  static ChatImageService? _instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Private constructor untuk singleton pattern
  ChatImageService._();

  /// Get singleton instance
  static ChatImageService getInstance() {
    _instance ??= ChatImageService._();
    return _instance!;
  }

  /// Check dan request permissions untuk camera dan gallery
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Check camera permission
      final cameraStatus = await Permission.camera.status;
      final storageStatus = await Permission.storage.status;
      final photosStatus = await Permission.photos.status;

      debugPrint('Camera permission: $cameraStatus');
      debugPrint('Storage permission: $storageStatus');
      debugPrint('Photos permission: $photosStatus');

      bool hasAllPermissions = true;

      // Request camera permission jika belum ada
      if (cameraStatus.isDenied || cameraStatus.isRestricted) {
        final newCameraStatus = await Permission.camera.request();
        if (!newCameraStatus.isGranted) {
          hasAllPermissions = false;
        }
      }

      // Request storage/photos permission jika belum ada (untuk gallery)
      if (Platform.isAndroid) {
        if (storageStatus.isDenied || storageStatus.isRestricted) {
          final newStorageStatus = await Permission.storage.request();
          if (!newStorageStatus.isGranted) {
            hasAllPermissions = false;
          }
        }
      } else if (Platform.isIOS) {
        if (photosStatus.isDenied || photosStatus.isRestricted) {
          final newPhotosStatus = await Permission.photos.request();
          if (!newPhotosStatus.isGranted) {
            hasAllPermissions = false;
          }
        }
      }

      return hasAllPermissions;
    } catch (e) {
      debugPrint('Error checking image permissions: $e');
      return false;
    }
  }

  /// Pick image dari camera
  Future<File?> pickImageFromCamera() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('Camera permission tidak tersedia');
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        final optimizedFile = await _optimizeImage(file);
        return optimizedFile;
      }

      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image dari gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('Gallery permission tidak tersedia');
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        final optimizedFile = await _optimizeImage(file);
        return optimizedFile;
      }

      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images dari gallery
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('Gallery permission tidak tersedia');
        return [];
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      // Limit jumlah gambar yang bisa dipilih
      final limitedImages = images.take(maxImages).toList();

      final List<File> optimizedFiles = [];
      for (final image in limitedImages) {
        final file = File(image.path);
        final optimizedFile = await _optimizeImage(file);
        if (optimizedFile != null) {
          optimizedFiles.add(optimizedFile);
        }
      }

      return optimizedFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Optimize image untuk chat (compress dan resize)
  Future<File?> _optimizeImage(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('Failed to decode image');
        return originalFile;
      }

      // Resize image jika terlalu besar
      img.Image resizedImage = image;
      if (image.width > 1920 || image.height > 1920) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1920 : null,
        );
      }

      // Compress image
      final compressedBytes = img.encodeJpg(resizedImage, quality: 80);

      // Save optimized image
      final chatImagesDir = await getChatImagesDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_chat.jpg';
      final optimizedFile = File(path.join(chatImagesDir, fileName));

      await optimizedFile.writeAsBytes(compressedBytes);

      debugPrint(
        'Image optimized: ${originalFile.lengthSync()} -> ${optimizedFile.lengthSync()} bytes',
      );

      return optimizedFile;
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      return originalFile;
    }
  }

  /// Validate image file
  Future<ImageValidationResult> validateImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return ImageValidationResult(
          isValid: false,
          error: 'File tidak ditemukan',
        );
      }

      final fileSize = await imageFile.length();

      // Check file size (max 10MB)
      if (fileSize > 10 * 1024 * 1024) {
        return ImageValidationResult(
          isValid: false,
          error: 'Ukuran gambar terlalu besar (maksimal 10MB)',
        );
      }

      // Check file extension
      final extension = path.extension(imageFile.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
        return ImageValidationResult(
          isValid: false,
          error: 'Format gambar tidak didukung',
        );
      }

      // Try to decode image to check if it's valid
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return ImageValidationResult(
          isValid: false,
          error: 'File gambar rusak atau tidak valid',
        );
      }

      return ImageValidationResult(
        isValid: true,
        fileSizeInBytes: fileSize,
        formattedFileSize: _formatFileSize(fileSize),
        width: image.width,
        height: image.height,
        format: extension.substring(1),
      );
    } catch (e) {
      debugPrint('Error validating image: $e');
      return ImageValidationResult(
        isValid: false,
        error: 'Error validasi gambar: $e',
      );
    }
  }

  /// Format file size untuk display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get directory untuk menyimpan chat images
  Future<String> getChatImagesDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final chatImagesDir = Directory('${documentsDir.path}/chats/images');

    if (!await chatImagesDir.exists()) {
      await chatImagesDir.create(recursive: true);
    }

    return chatImagesDir.path;
  }

  /// Clean up old chat images (older than 30 days)
  Future<void> cleanupOldImages() async {
    try {
      final chatImagesDir = await getChatImagesDirectory();
      final directory = Directory(chatImagesDir);

      if (!await directory.exists()) {
        return;
      }

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final files = await directory.list().toList();

      int deletedCount = 0;
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint('Cleaned up $deletedCount old chat image files');
      }
    } catch (e) {
      debugPrint('Error cleaning up old chat images: $e');
    }
  }

  /// Get total size of chat images storage
  Future<int> getChatImagesStorageSize() async {
    try {
      final chatImagesDir = await getChatImagesDirectory();
      final directory = Directory(chatImagesDir);

      if (!await directory.exists()) {
        return 0;
      }

      int totalSize = 0;
      final files = await directory.list(recursive: true).toList();

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating chat images storage size: $e');
      return 0;
    }
  }

  /// Get formatted storage size untuk images
  Future<String> getFormattedStorageSize() async {
    final sizeInBytes = await getChatImagesStorageSize();
    return _formatFileSize(sizeInBytes);
  }

  /// Copy image untuk sharing
  Future<String?> copyImageForSharing(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(originalFile.path);
      final tempPath = path.join(tempDir.path, fileName);

      await originalFile.copy(tempPath);
      return tempPath;
    } catch (e) {
      debugPrint('Error copying image for sharing: $e');
      return null;
    }
  }

  /// Show image picker options dialog
  Future<File?> showImagePickerDialog(context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pilih Gambar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await pickImageFromCamera();
                    Navigator.pop(context, image);
                  },
                ),
                _buildImagePickerOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await pickImageFromGallery();
                    Navigator.pop(context, image);
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption(
    context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class untuk hasil validasi image
class ImageValidationResult {
  final bool isValid;
  final String? error;
  final int? fileSizeInBytes;
  final String? formattedFileSize;
  final int? width;
  final int? height;
  final String? format;

  ImageValidationResult({
    required this.isValid,
    this.error,
    this.fileSizeInBytes,
    this.formattedFileSize,
    this.width,
    this.height,
    this.format,
  });

  @override
  String toString() {
    if (isValid) {
      return 'ImageValidationResult(valid: true, size: $formattedFileSize, dimensions: ${width}x$height)';
    } else {
      return 'ImageValidationResult(valid: false, error: $error)';
    }
  }
}
