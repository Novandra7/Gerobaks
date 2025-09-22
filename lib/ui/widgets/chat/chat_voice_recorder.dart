import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/chat_audio_service.dart';
import 'dart:async';

/// Widget untuk voice recording yang dikhususkan untuk chat
///
/// Features:
/// - Modern UI dengan drag-to-lock functionality
/// - Real-time duration tracking
/// - Visual feedback dengan waveform simulation
/// - Auto permission handling
/// - Voice message validation
/// - Error handling dengan user-friendly messages
class ChatVoiceRecorder extends StatefulWidget {
  final Function(String, int) onRecordingComplete;
  final VoidCallback onCancel;

  const ChatVoiceRecorder({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<ChatVoiceRecorder> createState() => _ChatVoiceRecorderState();
}

class _ChatVoiceRecorderState extends State<ChatVoiceRecorder>
    with SingleTickerProviderStateMixin {
  late ChatAudioService _audioService;
  bool _isRecording = false;
  bool _isInitialized = false;
  int _recordDuration = 0;
  late AnimationController _animationController;
  bool _isLocked = false;
  bool _isDragging = false;
  bool _showLockUI = false;
  double _dragOffset = 0;
  StreamSubscription<int>? _durationSubscription;
  double _currentAmplitude = 0.0;
  Timer? _amplitudeTimer;

  @override
  void initState() {
    super.initState();
    _audioService = ChatAudioService.getInstance();
    _initializeService();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  Future<void> _initializeService() async {
    try {
      await _audioService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _durationSubscription?.cancel();
    _amplitudeTimer?.cancel();
    super.dispose();
  }

  void _startRecording() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio service sedang diinisialisasi...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_audioService.isVoiceRecordingAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_audioService.getPlatformInfo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Request permissions
    final hasPermission = await _audioService.requestVoicePermissions();

    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin mikrofon diperlukan untuk mengirim pesan suara',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Start recording
    final success = await _audioService.startVoiceRecording();
    if (success) {
      setState(() {
        _isRecording = true;
        _showLockUI = true;
        _recordDuration = 0;
      });

      // Listen to duration updates
      final durationStream = _audioService.recordingDurationStream;
      if (durationStream != null) {
        _durationSubscription?.cancel();
        _durationSubscription = durationStream.listen((duration) {
          if (mounted) {
            setState(() {
              _recordDuration = duration;
            });
          }
        });
      }

      // Start amplitude monitoring for visual feedback
      _startAmplitudeMonitoring();

      debugPrint('Voice recording started successfully');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memulai recording'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      if (_isRecording) {
        final amplitude = await _audioService.getCurrentAmplitude();
        if (mounted) {
          setState(() {
            _currentAmplitude = amplitude;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _stopRecording() async {
    debugPrint('Stopping voice recording...');

    _durationSubscription?.cancel();
    _amplitudeTimer?.cancel();

    final voiceMessage = await _audioService.stopVoiceRecording();

    setState(() {
      _isRecording = false;
      _isLocked = false;
      _showLockUI = false;
      _dragOffset = 0;
      _currentAmplitude = 0.0;
    });

    if (voiceMessage != null && voiceMessage.isValid) {
      debugPrint('Voice recording completed: $voiceMessage');

      // Move file to chat directory
      final chatFilePath = await _audioService.moveToChatsDirectory(
        voiceMessage.filePath,
      );

      if (chatFilePath != null) {
        widget.onRecordingComplete(
          chatFilePath,
          voiceMessage.durationInSeconds,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan pesan suara'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      debugPrint('Invalid voice message: $voiceMessage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesan suara terlalu pendek atau tidak valid'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _cancelRecording() async {
    debugPrint('Canceling voice recording...');

    _durationSubscription?.cancel();
    _amplitudeTimer?.cancel();

    await _audioService.cancelVoiceRecording();

    setState(() {
      _isRecording = false;
      _isLocked = false;
      _showLockUI = false;
      _dragOffset = 0;
      _currentAmplitude = 0.0;
    });

    widget.onCancel();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(-100.0, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset <= -60) {
      // Lock the recording
      setState(() {
        _isLocked = true;
        _isDragging = false;
        _dragOffset = 0;
      });
    } else {
      // Reset position
      setState(() {
        _isDragging = false;
        _dragOffset = 0;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Inisialisasi audio...',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return _isRecording ? _buildRecordingUI() : _buildStartButton();
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onLongPress: _startRecording,
      child: Container(
        decoration: BoxDecoration(
          color: greenColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: greenColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(Icons.mic, color: whiteColor, size: 24),
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Recording indicator with animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(_animationController.value),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Waveform visualization
          _buildWaveform(),
          const SizedBox(width: 8),

          // Duration text
          Text(
            _formatDuration(_recordDuration),
            style: blackTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // Control buttons
          if (_isLocked) _buildLockedControls() else _buildDragControls(),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      children: List.generate(5, (index) {
        final height = 4.0 + (_currentAmplitude * 16.0 * (index % 3 + 1));
        return Container(
          width: 3,
          height: height.clamp(4.0, 20.0),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  Widget _buildDragControls() {
    return GestureDetector(
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: Column(
        children: [
          if (_showLockUI && _dragOffset < -20)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock, size: 16, color: Colors.grey[600]),
            ),
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: GestureDetector(
              onTap: _stopRecording,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: greenColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: whiteColor, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _cancelRecording,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete, color: Colors.red[400], size: 20),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: greenColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.send, color: whiteColor, size: 20),
          ),
        ),
      ],
    );
  }
}
