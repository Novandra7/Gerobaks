import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bank_sha/services/chat_audio_service.dart';

/// Utility functions untuk mengelola voice messages di chat
class ChatAudioUtils {
  static final ChatAudioService _audioService = ChatAudioService.getInstance();

  /// Check apakah voice recording tersedia di platform ini
  static bool isVoiceRecordingSupported() {
    return ChatAudioService.getInstance().isVoiceRecordingAvailable();
  }

  /// Get informasi platform support
  static String getPlatformSupportInfo() {
    return ChatAudioService.getInstance().getPlatformInfo();
  }

  /// Check dan request permissions untuk voice recording
  ///
  /// Returns true jika semua permission tersedia
  static Future<bool> checkAndRequestPermissions() async {
    try {
      // Check platform support terlebih dahulu
      if (!isVoiceRecordingSupported()) {
        debugPrint('Voice recording tidak didukung di platform ini');
        return false;
      }

      await _audioService.initialize();
      return await _audioService.requestVoicePermissions();
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  /// Validate voice message file sebelum dikirim
  static Future<VoiceMessageValidation> validateVoiceMessage(
    String filePath,
  ) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return VoiceMessageValidation(
          isValid: false,
          error: 'File tidak ditemukan',
        );
      }

      final fileSize = await file.length();

      if (fileSize == 0) {
        return VoiceMessageValidation(isValid: false, error: 'File kosong');
      }

      if (fileSize > 50 * 1024 * 1024) {
        // Max 50MB
        return VoiceMessageValidation(
          isValid: false,
          error: 'File terlalu besar (maksimal 50MB)',
        );
      }

      // Get file extension
      final extension = filePath.split('.').last.toLowerCase();
      if (!['m4a', 'aac', 'mp3', 'wav'].contains(extension)) {
        return VoiceMessageValidation(
          isValid: false,
          error: 'Format file tidak didukung',
        );
      }

      return VoiceMessageValidation(
        isValid: true,
        fileSizeInBytes: fileSize,
        formattedFileSize: _formatFileSize(fileSize),
      );
    } catch (e) {
      debugPrint('Error validating voice message: $e');
      return VoiceMessageValidation(
        isValid: false,
        error: 'Error validasi file: $e',
      );
    }
  }

  /// Format file size untuk display
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Format duration untuk display
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '0:${seconds.toString().padLeft(2, '0')}';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get maximum voice message duration dalam detik
  static int getMaxVoiceMessageDuration() {
    return 300; // 5 minutes
  }

  /// Get minimum voice message duration dalam detik
  static int getMinVoiceMessageDuration() {
    return 1; // 1 second
  }

  /// Check apakah duration valid untuk voice message
  static bool isValidDuration(int durationInSeconds) {
    return durationInSeconds >= getMinVoiceMessageDuration() &&
        durationInSeconds <= getMaxVoiceMessageDuration();
  }

  /// Get storage path untuk voice messages
  static Future<String> getVoiceMessagesDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory('${documentsDir.path}/chats/voice_messages');

    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }

    return voiceDir.path;
  }

  /// Clean up old voice message files (older than 30 days)
  static Future<void> cleanupOldVoiceMessages() async {
    try {
      final voiceDir = await getVoiceMessagesDirectory();
      final directory = Directory(voiceDir);

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
        debugPrint('Cleaned up $deletedCount old voice message files');
      }
    } catch (e) {
      debugPrint('Error cleaning up old voice messages: $e');
    }
  }

  /// Get total size of voice messages directory
  static Future<int> getVoiceMessagesStorageSize() async {
    try {
      final voiceDir = await getVoiceMessagesDirectory();
      final directory = Directory(voiceDir);

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
      debugPrint('Error calculating voice messages storage size: $e');
      return 0;
    }
  }

  /// Get formatted storage size
  static Future<String> getFormattedStorageSize() async {
    final sizeInBytes = await getVoiceMessagesStorageSize();
    return _formatFileSize(sizeInBytes);
  }

  /// Check permission status tanpa meminta permission
  static Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  /// Open app settings untuk permission
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get voice message info dari file path
  static Future<VoiceMessageInfo?> getVoiceMessageInfo(String filePath) async {
    try {
      final validation = await validateVoiceMessage(filePath);
      if (!validation.isValid) {
        return null;
      }

      final file = File(filePath);
      final stat = await file.stat();
      final fileName = file.path.split('/').last;

      return VoiceMessageInfo(
        filePath: filePath,
        fileName: fileName,
        fileSizeInBytes: validation.fileSizeInBytes!,
        formattedFileSize: validation.formattedFileSize!,
        createdAt: stat.modified,
        extension: fileName.split('.').last.toLowerCase(),
      );
    } catch (e) {
      debugPrint('Error getting voice message info: $e');
      return null;
    }
  }

  /// Copy voice message ke external storage (for sharing)
  static Future<String?> copyVoiceMessageForSharing(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = originalFile.path.split('/').last;
      final tempPath = '${tempDir.path}/$fileName';

      await originalFile.copy(tempPath);
      return tempPath;
    } catch (e) {
      debugPrint('Error copying voice message for sharing: $e');
      return null;
    }
  }
}

/// Data class untuk hasil validasi voice message
class VoiceMessageValidation {
  final bool isValid;
  final String? error;
  final int? fileSizeInBytes;
  final String? formattedFileSize;

  VoiceMessageValidation({
    required this.isValid,
    this.error,
    this.fileSizeInBytes,
    this.formattedFileSize,
  });

  @override
  String toString() {
    if (isValid) {
      return 'VoiceMessageValidation(valid: true, size: $formattedFileSize)';
    } else {
      return 'VoiceMessageValidation(valid: false, error: $error)';
    }
  }
}

/// Data class untuk informasi voice message
class VoiceMessageInfo {
  final String filePath;
  final String fileName;
  final int fileSizeInBytes;
  final String formattedFileSize;
  final DateTime createdAt;
  final String extension;

  VoiceMessageInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSizeInBytes,
    required this.formattedFileSize,
    required this.createdAt,
    required this.extension,
  });

  @override
  String toString() {
    return 'VoiceMessageInfo(file: $fileName, size: $formattedFileSize, created: $createdAt)';
  }
}
