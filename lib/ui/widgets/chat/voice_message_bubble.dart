import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/audio_player_service.dart';
import 'package:bank_sha/services/audio_service_manager.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String voiceUrl;
  final int durationInSeconds;
  final bool isFromUser;
  final DateTime timestamp;
  final AudioPlayerService? audioPlayerService;

  const VoiceMessageBubble({
    Key? key,
    required this.voiceUrl,
    required this.durationInSeconds,
    required this.isFromUser,
    required this.timestamp,
    this.audioPlayerService,
  }) : super(key: key);

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  bool _isPlaying = false;
  int _currentPosition = 0;
  late String _durationText;
  late AudioPlayerService _audioPlayerService;
  
  @override
  void initState() {
    super.initState();
    _durationText = _formatDuration(widget.durationInSeconds);
    
    // Menggunakan audioPlayerService dari widget jika tersedia, jika tidak ambil dari manager
    _audioPlayerService = widget.audioPlayerService ?? AudioServiceManager().getAudioPlayerService();
    
    _setupAudioPlayerListeners();
  }
  
  void _setupAudioPlayerListeners() {
    try {
      _audioPlayerService.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing && 
                        _audioPlayerService.currentlyPlayingUrl == widget.voiceUrl;
            
            if (state == PlayerState.completed && 
                _audioPlayerService.currentlyPlayingUrl == widget.voiceUrl) {
              _currentPosition = 0;
            }
          });
        }
      });
      
      _audioPlayerService.onPositionChanged.listen((position) {
        if (mounted && _audioPlayerService.currentlyPlayingUrl == widget.voiceUrl) {
          setState(() {
            _currentPosition = position.inSeconds;
          });
        }
      });
    } catch (e) {
      debugPrint('Error setting up audio player listeners: $e');
    }
  }
  
  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String _formatMessageTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _togglePlay() async {
    try {
      await _audioPlayerService.play(widget.voiceUrl);
    } catch (e) {
      debugPrint('Error playing voice message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.isFromUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.support_agent,
                color: greenColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                    minWidth: MediaQuery.of(context).size.width * 0.4,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? greenColor : whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: isUser ? whiteColor : greenColor,
                          size: 32,
                        ),
                        onPressed: _togglePlay,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _isPlaying ? 
                                (_currentPosition / widget.durationInSeconds) : 
                                (_currentPosition > 0 ? (_currentPosition / widget.durationInSeconds) : 0),
                              backgroundColor: isUser ? 
                                whiteColor.withOpacity(0.3) : 
                                greenColor.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUser ? whiteColor : greenColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isPlaying ? 
                                _formatDuration(_currentPosition) : 
                                _durationText,
                              style: (isUser ? whiteTextStyle : blackTextStyle).copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(widget.timestamp),
                  style: greyTextStyle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: greenColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}