import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageUploadPicker extends StatelessWidget {
  final String? currentImageUrl;
  final File? selectedImage;
  final bool isUploading;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback? onRemoveTap;
  final String defaultInitials;

  const ProfileImageUploadPicker({
    super.key,
    this.currentImageUrl,
    this.selectedImage,
    required this.isUploading,
    required this.onCameraTap,
    required this.onGalleryTap,
    this.onRemoveTap,
    this.defaultInitials = '?',
  });

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: greenColor),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                onCameraTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: greenColor),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                onGalleryTap();
              },
            ),
            if ((currentImageUrl != null && currentImageUrl!.isNotEmpty) || 
                selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRemoveTap?.call();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    } else if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      // Add cache buster with timestamp to force reload
      final imageUrl = currentImageUrl!.contains('?')
          ? '$currentImageUrl&t=${DateTime.now().millisecondsSinceEpoch}'
          : '$currentImageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return Image.network(
        imageUrl,
        key: ValueKey(imageUrl), // Unique key to force rebuild
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return _buildInitialAvatar();
    }
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        defaultInitials,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: greenColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: isUploading ? null : () => _showImagePickerOptions(context),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: greenColor.withAlpha(25),
              border: Border.all(color: greenColor.withAlpha(77), width: 2),
            ),
            child: ClipOval(child: _buildProfileContent()),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isUploading ? null : () => _showImagePickerOptions(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: greenColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
