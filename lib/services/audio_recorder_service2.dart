import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Service untuk mengelola recording audio dengan handling platform yang lebih baik
///
/// Service ini mendukung:
/// - Platform Android, iOS, dan macOS
/// - Permission handling otomatis
/// - Recording dengan format M4A
/// - Duration tracking real-time
/// - Error handling yang robust
///
/// Tidak didukung: Linux, Windows
class AudioRecorderService2 {
  Record? _recorder;
  bool _isRecording = false;
  String? _path;
  Timer? _timer;
  int _recordDuration = 0;

  // Stream for duration updates during recording
  final StreamController<int> _durationController =
      StreamController<int>.broadcast();

  /// Stream yang memberikan update durasi recording setiap detik
  Stream<int> get onDurationChanged => _durationController.stream;

  /// Durasi recording saat ini dalam detik
  int get recordDuration => _recordDuration;

  /// Status apakah sedang recording
  bool get isRecording => _isRecording;

  /// Path file recording terakhir
  String? get recordedPath => _path;

  // Initialize the recorder
  Future<void> _initRecorder() async {
    try {
      // Cek platform support
      if (!_isPlatformSupported()) {
        debugPrint(
          'Platform ${Platform.operatingSystem} tidak didukung untuk recording',
        );
        return;
      }

      _recorder ??= Record();
      debugPrint('Audio recorder initialized successfully');
    } catch (e) {
      debugPrint('Error initializing audio recorder: $e');
      rethrow;
    }
  }

  // Check if platform supports recording
  bool _isPlatformSupported() {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  /// Request necessary permissions untuk recording
  ///
  /// Returns true jika semua permission berhasil didapat
  Future<bool> requestPermissions() async {
    try {
      // Cek platform support
      if (!_isPlatformSupported()) {
        debugPrint(
          'Platform ${Platform.operatingSystem} tidak didukung untuk recording',
        );
        return false;
      }

      // Check microphone permission
      var microphoneStatus = await Permission.microphone.status;
      debugPrint('Current microphone permission status: $microphoneStatus');

      if (!microphoneStatus.isGranted) {
        debugPrint('Requesting microphone permission...');
        microphoneStatus = await Permission.microphone.request();

        if (!microphoneStatus.isGranted) {
          debugPrint('Microphone permission denied: $microphoneStatus');
          return false;
        }
      }

      debugPrint('Microphone permission granted');

      // Additional Android permissions
      if (Platform.isAndroid) {
        var storageStatus = await Permission.storage.status;
        debugPrint('Current storage permission status: $storageStatus');

        if (!storageStatus.isGranted) {
          debugPrint('Requesting storage permission...');
          storageStatus = await Permission.storage.request();

          // Storage permission tidak wajib untuk Android 13+, jadi kita lanjutkan
          if (!storageStatus.isGranted) {
            debugPrint(
              'Storage permission not granted, continuing anyway (Android 13+ compatibility)',
            );
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Start recording audio
  ///
  /// Returns true jika recording berhasil dimulai
  Future<bool> startRecording() async {
    try {
      // Cek platform support
      if (!_isPlatformSupported()) {
        debugPrint(
          'Recording tidak didukung di platform ${Platform.operatingSystem}',
        );
        return false;
      }

      // Cek jika sudah recording
      if (_isRecording) {
        debugPrint('Already recording, stopping current recording first');
        await stopRecording();
      }

      // Request permissions
      if (!await requestPermissions()) {
        debugPrint('Permissions not granted for recording');
        return false;
      }

      // Initialize recorder
      await _initRecorder();

      if (_recorder == null) {
        debugPrint('Failed to initialize recorder');
        return false;
      }

      // Check if already recording
      if (_recorder!.isRecording()) {
        debugPrint('Recorder is already recording, stopping first');
        await _recorder!.stop();
      }

      // Generate file path
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _path = '${directory.path}/audio_$timestamp.m4a';

      debugPrint('Starting recording to: $_path');

      // Start recording - menggunakan API sederhana dari local record package
      final result = await _recorder!.start();

      if (result) {
        _isRecording = true;
        _recordDuration = 0;

        // Start a timer that emits duration updates
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          _recordDuration++;
          _durationController.add(_recordDuration);
        });

        debugPrint('Recording started successfully, duration tracking enabled');
        return true;
      } else {
        debugPrint('Failed to start recording - recorder returned false');
        return false;
      }
    } catch (e) {
      debugPrint('Exception during startRecording: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Stop recording dan return path file audio
  ///
  /// Returns path file audio jika berhasil, null jika gagal
  Future<String?> stopRecording() async {
    try {
      _timer?.cancel();

      if (!_isRecording || _recorder == null) {
        debugPrint('Not recording or recorder is null - cannot stop');
        return null;
      }

      debugPrint('Stopping recording...');
      final path = await _recorder!.stop();
      _isRecording = false;

      final resultPath = path ?? _path;
      debugPrint('Recording stopped successfully, file saved at: $resultPath');

      // Verify file exists
      if (resultPath != null) {
        final file = File(resultPath);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint('Recording file verified: $fileSize bytes');
        } else {
          debugPrint('Warning: Recording file does not exist at expected path');
        }
      }

      return resultPath;
    } catch (e) {
      debugPrint('Exception during stopRecording: $e');
      return null;
    } finally {
      _isRecording = false;
    }
  }

  /// Cancel recording dan hapus file yang sudah dibuat
  Future<void> cancelRecording() async {
    try {
      _timer?.cancel();

      if (!_isRecording || _recorder == null) {
        debugPrint('Not recording or recorder is null - nothing to cancel');
        return;
      }

      debugPrint('Canceling recording...');
      await _recorder!.stop();

      // Delete the recorded file
      if (_path != null) {
        final file = File(_path!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted recording file: $_path');
        } else {
          debugPrint('Recording file not found for deletion: $_path');
        }
      }

      debugPrint('Recording canceled successfully');
    } catch (e) {
      debugPrint('Exception during cancelRecording: $e');
    } finally {
      _isRecording = false;
      _path = null;
    }
  }

  /// Get current amplitude untuk visualisasi (simplified version)
  ///
  /// Returns nilai amplitude antara 0.0 - 1.0
  Future<double> getAmplitude() async {
    if (!_isRecording || _recorder == null) {
      return 0.0;
    }

    try {
      // Karena local record package tidak mendukung amplitude,
      // kita return nilai random untuk simulasi
      final simulatedAmplitude =
          0.1 + (DateTime.now().millisecond % 100) / 1000.0;
      return simulatedAmplitude.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('Error getting amplitude: $e');
      return 0.0;
    }
  }

  /// Check apakah recording didukung di platform saat ini
  static bool isRecordingSupported() {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  /// Get info platform support
  static String getPlatformSupportInfo() {
    if (isRecordingSupported()) {
      return 'Recording didukung di ${Platform.operatingSystem}';
    } else {
      return 'Recording tidak didukung di ${Platform.operatingSystem}. Didukung: Android, iOS, macOS';
    }
  }

  /// Dispose resources dan cleanup
  void dispose() {
    debugPrint('Disposing AudioRecorderService2...');

    try {
      _timer?.cancel();

      if (_recorder != null) {
        _recorder!.dispose();
        _recorder = null;
      }

      if (!_durationController.isClosed) {
        _durationController.close();
      }

      debugPrint('AudioRecorderService2 disposed successfully');
    } catch (e) {
      debugPrint('Error during dispose: $e');
    }
  }
}
