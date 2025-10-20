import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Singleton service for managing chat audio recording and playback
class ChatAudioService {
  static ChatAudioService? _instance;
  final Record _recorder = Record();
  bool _isRecording = false;
  String? _currentRecordingPath;

  // Platform information for debugging
  final Map<String, String> _platformInfo = {
    'os': Platform.operatingSystem,
    'version': Platform.operatingSystemVersion,
  };

  // Private constructor
  ChatAudioService._();

  // Factory constructor to return the singleton instance
  static ChatAudioService getInstance() {
    _instance ??= ChatAudioService._();
    return _instance!;
  }

  // Check if voice recording is available on this platform
  bool isVoiceRecordingAvailable() {
    // Voice recording is supported on mobile platforms
    return Platform.isAndroid || Platform.isIOS;
  }

  // Get platform information for debugging
  Map<String, String> getPlatformInfo() {
    return _platformInfo;
  }

  // Request microphone permissions
  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permissions: $e');
      return false;
    }
  }

  // Initialize the audio service
  Future<void> initialize() async {
    // No specific initialization needed with our simplified implementation
    debugPrint('ChatAudioService initialized');
  }

  // Request voice permissions - convenience method that calls requestPermissions()
  Future<bool> requestVoicePermissions() async {
    return await requestPermissions();
  }

  // Start recording audio
  Future<bool> startRecording() async {
    if (!isVoiceRecordingAvailable()) {
      debugPrint('Voice recording not available on this platform');
      return false;
    }

    if (_isRecording) {
      debugPrint('Already recording');
      return true;
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('No microphone permission granted');
      return false;
    }

    try {
      // Get temporary directory to store recording
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/chat_audio_$timestamp.m4a';

      // Start recording using the simplified API
      final success = await _recorder.start();
      _isRecording = success;

      if (success) {
        debugPrint('Recording started at: $_currentRecordingPath');
      } else {
        debugPrint('Failed to start recording');
      }

      return success;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      return false;
    }
  }

  // Stop recording and return the file path
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      debugPrint('Not currently recording');
      return null;
    }

    try {
      final recordingPath = await _recorder.stop();
      _isRecording = false;

      // Use the path from the recorder if available, otherwise use our stored path
      final finalPath = recordingPath ?? _currentRecordingPath;
      _currentRecordingPath = null;

      debugPrint('Recording stopped, saved at: $finalPath');
      return finalPath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      _currentRecordingPath = null;
      return null;
    }
  }

  // Cancel current recording
  Future<void> cancelRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      await _recorder.stop();

      // Delete the recorded file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted recording at: $_currentRecordingPath');
        }
      }
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    } finally {
      _isRecording = false;
      _currentRecordingPath = null;
    }
  }

  // Check if currently recording
  bool get isRecording => _isRecording;

  // Get current recording duration in seconds - always returns 0 with our simplified implementation
  Future<int> getRecordingDuration() async {
    // With our simplified Record implementation, we can't get the amplitude
    // So we'll just return a default value
    return _isRecording ? 1 : 0;
  }

  // Helper method for ChatAudioUtils.getAmplitude() to avoid errors
  // Always returns a default value with our simplified implementation
  Future<RecordingAmplitude> getAmplitude() async {
    return RecordingAmplitude(current: 0.0, max: 0.0);
  }

  // Dispose resources
  void dispose() {
    if (_isRecording) {
      _recorder.stop();
    }
    _recorder.dispose();
    _isRecording = false;
    _currentRecordingPath = null;
  }
}

// Simple class to emulate the original Record package's RecordingAmplitude
class RecordingAmplitude {
  final double current;
  final double max;
  final Duration duration = const Duration(seconds: 0);

  RecordingAmplitude({required this.current, required this.max});
}
