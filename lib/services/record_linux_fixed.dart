import 'dart:async';
import 'dart:typed_data';
import 'package:record_platform_interface/record_platform_interface.dart';

class RecordLinuxFixed extends RecordPlatform {
  @override
  Future<void> dispose(String recorderId) async {
    // Noop implementation
    return;
  }

  @override
  Future<AmplitudeResult> getAmplitude(String recorderId) async {
    // Mock implementation
    return AmplitudeResult(current: 0.0, max: 0.0);
  }

  @override
  Future<String?> hasPermission() async {
    return 'microphone';
  }

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) async {
    return false;
  }

  @override
  Future<bool> isRecording(String recorderId) async {
    return false;
  }

  @override
  Future<String?> start(
    String recorderId,
    RecordConfig config, {
    required String path,
  }) async {
    return null;
  }

  @override
  Future<Stream<Uint8List>> startStream(
      String recorderId, RecordConfig config) async {
    // Return an empty stream
    return Stream<Uint8List>.empty();
  }

  @override
  Future<String?> stop(String recorderId) async {
    return null;
  }
}