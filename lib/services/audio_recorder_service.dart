import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Implementasi sederhana untuk pengganti package record
/// yang menyebabkan masalah pada build
class AudioRecorderService {
  bool _isRecording = false;
  String? _path;
  Timer? _timer;
  int _recordDuration = 0;
  
  // Stream untuk update durasi rekaman
  final StreamController<int> _durationController = StreamController<int>.broadcast();
  Stream<int> get onDurationChanged => _durationController.stream;
  
  int get recordDuration => _recordDuration;
  bool get isRecording => _isRecording;
  String? get recordedPath => _path;
  
  // Meminta izin yang diperlukan
  Future<bool> requestPermissions() async {
    try {
      if (!await Permission.microphone.isGranted) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          return false;
        }
      }
      
      // Pada Android 13 dan yang lebih tinggi kita juga memerlukan izin storage
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
  
  // Mulai merekam - Implementasi Dummy
  Future<bool> startRecording() async {
    if (!await requestPermissions()) {
      return false;
    }
    
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _path = '${directory.path}/audio_$timestamp.m4a';
      
      // Simulasi rekaman
      _isRecording = true;
      _recordDuration = 0;
      
      // Mulai timer yang mengeluarkan update durasi
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        _recordDuration++;
        _durationController.add(_recordDuration);
      });
      
      // Pada implementasi asli, kita akan memulai rekaman sebenarnya di sini
      // Untuk sementara, kita hanya simulasikan
      
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }
  
  // Berhenti merekam
  Future<String?> stopRecording() async {
    _timer?.cancel();
    
    if (!_isRecording) {
      return null;
    }
    
    try {
      // Pada implementasi asli, kita akan berhenti merekam di sini
      // Untuk sementara, kita hanya simulasikan
      
      _isRecording = false;
      
      // Buat file dummy untuk simulasi
      if (_path != null) {
        final file = File(_path!);
        if (!await file.exists()) {
          await file.create();
          await file.writeAsString('Dummy audio content for testing');
        }
      }
      
      return _path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    } finally {
      _isRecording = false;
    }
  }
  
  // Batalkan rekaman
  Future<void> cancelRecording() async {
    _timer?.cancel();
    
    if (!_isRecording) {
      return;
    }
    
    try {
      // Hapus file rekaman
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
  
  // Dapatkan amplitudo saat ini (untuk visualisasi)
  Future<double> getAmplitude() async {
    if (!_isRecording) {
      return 0.0;
    }
    
    try {
      // Simulasi amplitudo acak antara 0 dan 1
      return _recordDuration % 10 / 10;
    } catch (e) {
      debugPrint('Error getting amplitude: $e');
      return 0.0;
    }
  }
  
  // Buang resource
  void dispose() {
    _timer?.cancel();
    _durationController.close();
  }
}