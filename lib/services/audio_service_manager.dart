// Fungsi ini akan digunakan untuk membuat lazy loading pada audio service
import 'package:bank_sha/services/audio_player_service.dart';
import 'package:bank_sha/services/audio_recorder_service.dart';

// Singleton untuk audio player service
class AudioServiceManager {
  static final AudioServiceManager _instance = AudioServiceManager._internal();
  AudioPlayerService? _audioPlayerService;
  AudioRecorderService? _audioRecorderService;

  factory AudioServiceManager() {
    return _instance;
  }

  AudioServiceManager._internal();

  AudioPlayerService getAudioPlayerService() {
    _audioPlayerService ??= AudioPlayerService();
    return _audioPlayerService!;
  }

  AudioRecorderService getAudioRecorderService() {
    _audioRecorderService ??= AudioRecorderService();
    return _audioRecorderService!;
  }

  void dispose() {
    _audioPlayerService?.dispose();
    _audioRecorderService?.dispose();
    _audioPlayerService = null;
    _audioRecorderService = null;
  }
}