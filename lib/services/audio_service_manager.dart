import 'package:flutter/foundation.dart';
import 'package:bank_sha/services/audio_player_service.dart';
import 'package:bank_sha/services/audio_recorder_service.dart';

// Singleton untuk audio service (hanya untuk mobile platform)
class AudioServiceManager {
  static final AudioServiceManager _instance = AudioServiceManager._internal();
  AudioPlayerService? _audioPlayerService;
  AudioRecorderService? _audioRecorderService;

  factory AudioServiceManager() {
    return _instance;
  }

  AudioServiceManager._internal();

  AudioPlayerService getAudioPlayerService() {
    try {
      if (_audioPlayerService == null) {
        _audioPlayerService = AudioPlayerService();
      }
      return _audioPlayerService!;
    } catch (e) {
      debugPrint('Error initializing AudioPlayerService: $e');
      // Fallback dengan membuat instance baru
      _audioPlayerService = AudioPlayerService();
      return _audioPlayerService!;
    }
  }

  AudioRecorderService getAudioRecorderService() {
    try {
      if (_audioRecorderService == null) {
        _audioRecorderService = AudioRecorderService();
      }
      return _audioRecorderService!;
    } catch (e) {
      debugPrint('Error initializing AudioRecorderService: $e');
      // Fallback dengan membuat instance baru
      _audioRecorderService = AudioRecorderService();
      return _audioRecorderService!;
    }
  }

  void dispose() {
    try {
      if (_audioPlayerService != null) {
        _audioPlayerService!.dispose();
        _audioPlayerService = null;
      }
      
      if (_audioRecorderService != null) {
        _audioRecorderService!.dispose();
        _audioRecorderService = null;
      }
    } catch (e) {
      debugPrint('Error disposing audio services: $e');
    }
  }
}