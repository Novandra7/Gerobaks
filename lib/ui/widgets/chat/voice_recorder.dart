import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/audio_recorder_service.dart';

class VoiceRecorder extends StatefulWidget {
  final AudioRecorderService recorderService;
  final Function(String, int) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceRecorder({
    super.key,
    required this.recorderService,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _recordDuration = 0;
  late AnimationController _animationController;
  bool _isLocked = false;
  bool _showLockUI = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    widget.recorderService.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _recordDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startRecording() async {
    final hasPermission = await widget.recorderService.requestPermissions();

    if (hasPermission) {
      final success = await widget.recorderService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          _showLockUI = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start recording')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required to record audio'),
        ),
      );
    }
  }

  void _stopRecording() async {
    final path = await widget.recorderService.stopRecording();
    setState(() {
      _isRecording = false;
      _isLocked = false;
      _showLockUI = false;
      _dragOffset = 0;
    });

    if (path != null) {
      widget.onRecordingComplete(path, _recordDuration);
    }
  }

  void _cancelRecording() async {
    await widget.recorderService.cancelRecording();
    setState(() {
      _isRecording = false;
      _isLocked = false;
      _showLockUI = false;
      _dragOffset = 0;
    });
    widget.onCancel();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isLocked) return;

    setState(() {
      _dragOffset += details.delta.dy;
      // Limit drag to reasonable bounds
      _dragOffset = _dragOffset.clamp(-100.0, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset <= -60) {
      // Lock the recording
      setState(() {
        _isLocked = true;
        _dragOffset = 0;
      });
    } else {
      // Reset position
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isRecording ? _buildRecordingUI() : _buildStartButton();
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onLongPress: _startRecording,
      child: Container(
        decoration: BoxDecoration(color: greenColor, shape: BoxShape.circle),
        padding: const EdgeInsets.all(12),
        child: Icon(Icons.mic, color: whiteColor, size: 24),
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _isLocked
          ? _buildLockedRecordingUI()
          : _buildDraggableRecordingUI(),
    );
  }

  Widget _buildDraggableRecordingUI() {
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(
                        0.2 + _animationController.value * 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic, color: greenColor, size: 18),
                  );
                },
              ),
              Expanded(
                child: Text(
                  'Slide up to lock • ${_formatDuration(_recordDuration)}',
                  style: greyTextStyle.copyWith(fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: _cancelRecording,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Colors.red[400], size: 20),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.send, color: greenColor, size: 20),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          if (_showLockUI)
            Positioned(
              top: _dragOffset,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: greenColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock, color: whiteColor, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLockedRecordingUI() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(
                  0.2 + _animationController.value * 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic, color: greenColor, size: 18),
            );
          },
        ),
        Expanded(
          child: Text(
            _formatDuration(_recordDuration),
            style: greyTextStyle.copyWith(fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: _cancelRecording,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.close, color: Colors.red[400], size: 20),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.send, color: greenColor, size: 20),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
