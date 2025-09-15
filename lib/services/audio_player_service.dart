import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  AudioPlayer? _audioPlayer;
  String? _currentlyPlayingUrl;
  
  final StreamController<PlayerState> _playerStateController = StreamController<PlayerState>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;
  Stream<Duration> get onPositionChanged => _positionController.stream;
  
  AudioPlayerService() {
    _initPlayer();
  }
  
  void _initPlayer() {
    try {
      _audioPlayer = AudioPlayer();
      _initStreams();
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }
  
  void _initStreams() {
    try {
      if (_audioPlayer != null) {
        _audioPlayer!.onPlayerStateChanged.listen((state) {
          _playerStateController.add(state);
          
          if (state == PlayerState.completed) {
            _currentlyPlayingUrl = null;
          }
        });
        
        _audioPlayer!.onPositionChanged.listen((position) {
          _positionController.add(position);
        });
      }
    } catch (e) {
      debugPrint('Error initializing audio player streams: $e');
    }
  }
  
  String? get currentlyPlayingUrl => _currentlyPlayingUrl;
  
  Future<void> play(String url) async {
    if (_audioPlayer == null) {
      _initPlayer();
      if (_audioPlayer == null) return;
    }
    
    if (_currentlyPlayingUrl == url) {
      // Same URL, toggle play/pause
      try {
        if (await _audioPlayer!.state == PlayerState.playing) {
          await pause();
        } else {
          await resume();
        }
      } catch (e) {
        debugPrint('Error toggling play/pause: $e');
      }
      return;
    }
    
    // Different URL, stop current and play new
    if (_currentlyPlayingUrl != null) {
      await stop();
    }
    
    try {
      await _audioPlayer!.play(
        url.startsWith('http') ? UrlSource(url) : DeviceFileSource(url),
        mode: PlayerMode.lowLatency,
      );
      _currentlyPlayingUrl = url;
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }
  
  Future<void> pause() async {
    if (_audioPlayer == null) return;
    
    try {
      await _audioPlayer!.pause();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }
  
  Future<void> resume() async {
    if (_audioPlayer == null) return;
    
    try {
      await _audioPlayer!.resume();
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }
  
  Future<void> stop() async {
    if (_audioPlayer == null) return;
    
    try {
      await _audioPlayer!.stop();
      _currentlyPlayingUrl = null;
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }
  
  Future<void> seek(Duration position) async {
    if (_audioPlayer == null) return;
    
    try {
      await _audioPlayer!.seek(position);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }
  
  Future<Duration?> getDuration() async {
    if (_audioPlayer == null) return null;
    
    try {
      return await _audioPlayer!.getDuration();
    } catch (e) {
      debugPrint('Error getting duration: $e');
      return null;
    }
  }
  
  void dispose() {
    try {
      if (_audioPlayer != null) {
        _audioPlayer!.dispose();
        _audioPlayer = null;
      }
      _playerStateController.close();
      _positionController.close();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }
  
  // Format duration for display
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}