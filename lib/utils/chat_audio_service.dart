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
  DateTime? _recordingStartTime;

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

      // Configure recording settings
      await _recorder.start(
        path: _currentRecordingPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      debugPrint('Recording started at: $_currentRecordingPath');
      return true;
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
      await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;
      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;

      debugPrint('Recording stopped, saved at: $recordingPath');
      return recordingPath;
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
      _recordingStartTime = null;
      _currentRecordingPath = null;
    }
  }

  // Check if currently recording
  bool get isRecording => _isRecording;

  // Get current recording duration in seconds
  Future<int> getRecordingDuration() async {
    if (!_isRecording || _recordingStartTime == null) return 0;

    try {
      final now = DateTime.now();
      final duration = now.difference(_recordingStartTime!);
      return duration.inSeconds;
    } catch (e) {
      debugPrint('Error getting recording duration: $e');
      return 0;
    }
  }

  // Dispose resources
  void dispose() {
    if (_isRecording) {
      _recorder.stop();
    }
    _isRecording = false;
    _recordingStartTime = null;
    _currentRecordingPath = null;
  }
}
