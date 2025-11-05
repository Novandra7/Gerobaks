import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_recorder_service.dart';

/// Service adapter untuk mengintegrasikan AudioRecorderService2 dengan fitur chat
///
/// Service ini menyediakan:
/// - Interface yang kompatibel dengan sistem chat yang ada
/// - Automatic permission handling untuk chat voice messages
/// - File management yang optimal untuk chat recordings
/// - Error handling khusus untuk chat context
/// - Voice message validation dan optimization
class ChatAudioService {
  static ChatAudioService? _instance;
  AudioRecorderService? _recorderService;

  // Private constructor untuk singleton pattern
  ChatAudioService._();

  /// Get singleton instance
  static ChatAudioService getInstance() {
    _instance ??= ChatAudioService._();
    return _instance!;
  }

  /// Initialize the chat audio service
  Future<void> initialize() async {
    try {
      _recorderService = AudioRecorderService();
      debugPrint('ChatAudioService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ChatAudioService: $e');
      rethrow;
    }
  }

  /// Check if voice recording is supported dan available untuk chat
  bool isVoiceRecordingAvailable() {
    // Untuk iOS dan Android, voice recording tersedia
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Get platform support information
  Map<String, String> getPlatformInfo() {
    return {
      'os': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  /// Request permissions untuk voice recording di chat
  ///
  /// Returns true jika semua permission berhasil didapat
  Future<bool> requestVoicePermissions() async {
    try {
      if (_recorderService == null) {
        await initialize();
      }

      if (!isVoiceRecordingAvailable()) {
        debugPrint('Voice recording tidak tersedia di platform ini');
        return false;
      }

      debugPrint('Requesting voice permissions for chat...');
      final hasPermission = await _recorderService!.requestPermissions();

      if (hasPermission) {
        debugPrint('Voice permissions granted for chat');
      } else {
        debugPrint('Voice permissions denied for chat');
      }

      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting voice permissions: $e');
      return false;
    }
  }

  /// Start recording voice message untuk chat
  ///
  /// Returns true jika recording berhasil dimulai
  Future<bool> startVoiceRecording() async {
    try {
      if (_recorderService == null) {
        debugPrint('Recorder service not initialized');
        return false;
      }

      debugPrint('Starting voice recording for chat...');
      final started = await _recorderService!.startRecording();

      if (started) {
        debugPrint('Voice recording started successfully for chat');
      } else {
        debugPrint('Failed to start voice recording for chat');
      }

      return started;
    } catch (e) {
      debugPrint('Error starting voice recording: $e');
      return false;
    }
  }

  /// Stop recording dan return voice message data
  ///
  /// Returns ChatVoiceMessage jika berhasil, null jika gagal
  Future<ChatVoiceMessage?> stopVoiceRecording() async {
    try {
      if (_recorderService == null) {
        debugPrint('Recorder service not initialized');
        return null;
      }

      debugPrint('Stopping voice recording for chat...');
      final filePath = await _recorderService!.stopRecording();

      if (filePath == null) {
        debugPrint('No file path returned from recording');
        return null;
      }

      // Validate file
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('Recording file does not exist: $filePath');
        return null;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('Recording file is empty: $filePath');
        await file.delete();
        return null;
      }

      // Get recording duration
      final duration = _recorderService!.recordDuration;

      // Validate duration
      if (duration < 1) {
        debugPrint('Recording too short: ${duration}s');
        await file.delete();
        return null;
      }

      if (duration > 300) {
        // Max 5 minutes
        debugPrint('Recording too long: ${duration}s');
        await file.delete();
        return null;
      }

      debugPrint('Voice recording completed: ${duration}s, $fileSize bytes');

      return ChatVoiceMessage(
        filePath: filePath,
        durationInSeconds: duration,
        fileSizeInBytes: fileSize,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error stopping voice recording: $e');
      return null;
    }
  }

  /// Cancel voice recording dan cleanup
  Future<void> cancelVoiceRecording() async {
    try {
      if (_recorderService == null) {
        debugPrint('Recorder service not initialized');
        return;
      }

      debugPrint('Canceling voice recording for chat...');
      await _recorderService!.cancelRecording();
      debugPrint('Voice recording canceled successfully');
    } catch (e) {
      debugPrint('Error canceling voice recording: $e');
    }
  }

  /// Get current recording duration
  int get currentRecordingDuration {
    return _recorderService?.recordDuration ?? 0;
  }

  /// Check if currently recording
  bool get isRecording {
    return _recorderService?.isRecording ?? false;
  }

  /// Get recording duration stream
  Stream<int>? get recordingDurationStream {
    return _recorderService?.onDurationChanged;
  }

  /// Get current amplitude untuk UI visualization
  Future<double> getCurrentAmplitude() async {
    try {
      if (_recorderService == null || !isRecording) {
        return 0.0;
      }

      return await _recorderService!.getAmplitude();
    } catch (e) {
      debugPrint('Error getting amplitude: $e');
      return 0.0;
    }
  }

  /// Move recorded file ke chat storage directory
  Future<String?> moveToChatsDirectory(String originalPath) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        debugPrint('Original file does not exist: $originalPath');
        return null;
      }

      // Get app documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final chatsDir = Directory('${documentsDir.path}/chats/voice_messages');

      // Create directory if not exists
      if (!await chatsDir.exists()) {
        await chatsDir.create(recursive: true);
      }

      // Generate new filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${chatsDir.path}/voice_$timestamp.m4a';

      // Copy file to new location
      await originalFile.copy(newPath);

      // Delete original file
      await originalFile.delete();

      debugPrint('Voice message moved to: $newPath');
      return newPath;
    } catch (e) {
      debugPrint('Error moving voice message to chats directory: $e');
      return null;
    }
  }

  /// Validate voice message file
  Future<bool> validateVoiceMessage(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        debugPrint('Voice message file does not exist: $filePath');
        return false;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('Voice message file is empty: $filePath');
        return false;
      }

      if (fileSize > 50 * 1024 * 1024) {
        // Max 50MB
        debugPrint('Voice message file too large: $fileSize bytes');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating voice message: $e');
      return false;
    }
  }

  /// Dispose service dan cleanup resources
  void dispose() {
    try {
      debugPrint('Disposing ChatAudioService...');
      _recorderService?.dispose();
      _recorderService = null;
      debugPrint('ChatAudioService disposed successfully');
    } catch (e) {
      debugPrint('Error disposing ChatAudioService: $e');
    }
  }
}

/// Data class untuk voice message yang telah direcord
class ChatVoiceMessage {
  final String filePath;
  final int durationInSeconds;
  final int fileSizeInBytes;
  final DateTime timestamp;

  ChatVoiceMessage({
    required this.filePath,
    required this.durationInSeconds,
    required this.fileSizeInBytes,
    required this.timestamp,
  });

  /// Format duration untuk display
  String get formattedDuration {
    final minutes = (durationInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format file size untuk display
  String get formattedFileSize {
    if (fileSizeInBytes < 1024) {
      return '$fileSizeInBytes B';
    } else if (fileSizeInBytes < 1024 * 1024) {
      return '${(fileSizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if recording is valid untuk sending
  bool get isValid {
    return durationInSeconds >= 1 &&
        durationInSeconds <= 300 &&
        fileSizeInBytes > 0 &&
        fileSizeInBytes <= 50 * 1024 * 1024;
  }

  @override
  String toString() {
    return 'ChatVoiceMessage(duration: $formattedDuration, size: $formattedFileSize, path: $filePath)';
  }
}
