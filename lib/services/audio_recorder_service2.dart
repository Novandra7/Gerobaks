import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

// Mock implementation untuk Linux platform
class RecordPlatformImplementation {
  static Future<bool> isLinux() async {
    return Platform.isLinux;
  }
}

/// Versi yang diperbaiki dari AudioRecorderService yang menangani masalah di platform Linux
class AudioRecorderService2 {
  AudioRecorder? _audioRecorder;
  bool _isRecording = false;
  String? _path;
  Timer? _timer;
  int _recordDuration = 0;
  
  // Stream for duration updates during recording
  final StreamController<int> _durationController = StreamController<int>.broadcast();
  Stream<int> get onDurationChanged => _durationController.stream;
  
  int get recordDuration => _recordDuration;
  bool get isRecording => _isRecording;
  String? get recordedPath => _path;
  
  // Initialize the recorder
  Future<void> _initRecorder() async {
    try {
      // Cek apakah platform Linux, jika ya maka kita perlu menangani secara khusus
      if (await RecordPlatformImplementation.isLinux()) {
        debugPrint('Linux platform detected, using alternative implementation');
        // Untuk Linux kita tidak melakukan inisialisasi recorder, karena tidak didukung
        return;
      }
      
      _audioRecorder ??= AudioRecorder();
    } catch (e) {
      debugPrint('Error initializing audio recorder: $e');
    }
  }
  
  // Request necessary permissions
  Future<bool> requestPermissions() async {
    try {
      // Cek apakah platform Linux, jika ya maka kita return false
      if (await RecordPlatformImplementation.isLinux()) {
        debugPrint('Linux platform detected, recording not supported');
        return false;
      }
      
      if (!await Permission.microphone.isGranted) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          return false;
        }
      }
      
      // On Android 13 and higher we also need storage permission
      if (Platform.isAndroid) {
        if (!await Permission.storage.isGranted) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }
  
  // Start recording
  Future<bool> startRecording() async {
    // Cek apakah platform Linux, jika ya maka kita return false
    if (await RecordPlatformImplementation.isLinux()) {
      debugPrint('Linux platform detected, recording not supported');
      return false;
    }
    
    if (!await requestPermissions()) {
      return false;
    }
    
    try {
      await _initRecorder();
      
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _path = '${directory.path}/audio_$timestamp.m4a';
      
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      
      // Make sure recording is stopped before starting a new one
      if (_audioRecorder != null) {
        final isRecording = await _audioRecorder!.isRecording();
        if (isRecording) {
          await _audioRecorder!.stop();
        }
      }
      
      if (_path != null && _audioRecorder != null) {
        await _audioRecorder!.start(config, path: _path!);
        
        _isRecording = true;
        _recordDuration = 0;
        
        // Start a timer that emits duration updates
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          _recordDuration++;
          _durationController.add(_recordDuration);
        });
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }
  
  // Stop recording
  Future<String?> stopRecording() async {
    _timer?.cancel();
    
    if (!_isRecording || _audioRecorder == null) {
      return null;
    }
    
    try {
      final path = await _audioRecorder!.stop();
      _isRecording = false;
      
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    } finally {
      _isRecording = false;
    }
  }
  
  // Cancel recording
  Future<void> cancelRecording() async {
    _timer?.cancel();
    
    if (!_isRecording || _audioRecorder == null) {
      return;
    }
    
    try {
      await _audioRecorder!.stop();
      
      // Delete the recorded file
      if (_path != null) {
        final file = File(_path!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    } finally {
      _isRecording = false;
      _path = null;
    }
  }
  
  // Get the current amplitude (for visualization)
  Future<double> getAmplitude() async {
    if (!_isRecording || _audioRecorder == null) {
      return 0.0;
    }
    
    try {
      final amplitude = await _audioRecorder!.getAmplitude();
      return amplitude.current;
    } catch (e) {
      debugPrint('Error getting amplitude: $e');
      return 0.0;
    }
  }
  
  // Dispose resources
  void dispose() {
    _timer?.cancel();
    if (_audioRecorder != null) {
      _audioRecorder!.dispose();
      _audioRecorder = null;
    }
    _durationController.close();
  }
}