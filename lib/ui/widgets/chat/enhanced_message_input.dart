import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/chat_audio_service.dart';
import 'package:bank_sha/services/chat_image_service.dart';
import 'package:bank_sha/ui/widgets/chat/chat_voice_recorder.dart';
import 'dart:io';

/// Enhanced message input widget dengan support untuk text, voice, dan image
///
/// Features:
/// - Text input dengan emoji support
/// - Voice recording dengan modern UI
/// - Image picker dari camera/gallery
/// - Permission handling
/// - Loading states
/// - Error handling
class EnhancedMessageInput extends StatefulWidget {
  final Function(String) onTextMessage;
  final Function(String, int) onVoiceMessage;
  final Function(File) onImageMessage;
  final bool isLoading;
  final String? hint;

  const EnhancedMessageInput({
    super.key,
    required this.onTextMessage,
    required this.onVoiceMessage,
    required this.onImageMessage,
    this.isLoading = false,
    this.hint = 'Ketik pesan...',
  });

  @override
  State<EnhancedMessageInput> createState() => _EnhancedMessageInputState();
}

class _EnhancedMessageInputState extends State<EnhancedMessageInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late ChatAudioService _audioService;
  late ChatImageService _imageService;

  bool _showVoiceRecorder = false;
  bool _hasText = false;
  bool _isRecordingPermissionGranted = false;
  bool _isImagePermissionGranted = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _audioService = ChatAudioService.getInstance();
    _imageService = ChatImageService.getInstance();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.trim().isNotEmpty;
      });
    });

    _checkPermissions();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final audioPermission = await _audioService.requestVoicePermissions();
    final imagePermission = await _imageService.checkAndRequestPermissions();

    setState(() {
      _isRecordingPermissionGranted = audioPermission;
      _isImagePermissionGranted = imagePermission;
    });
  }

  void _sendTextMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || widget.isLoading) return;

    widget.onTextMessage(message);
    _messageController.clear();
    _focusNode.unfocus();
  }

  void _handleVoiceRecordingComplete(String filePath, int duration) {
    setState(() {
      _showVoiceRecorder = false;
    });
    widget.onVoiceMessage(filePath, duration);
  }

  void _handleVoiceRecordingCancel() {
    setState(() {
      _showVoiceRecorder = false;
    });
  }

  Future<void> _showImagePicker() async {
    if (!_isImagePermissionGranted) {
      await _checkPermissions();
      if (!_isImagePermissionGranted) {
        _showPermissionDialog('Image');
        return;
      }
    }

    final image = await _imageService.showImagePickerDialog(context);
    if (image != null) {
      widget.onImageMessage(image);
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Izin Diperlukan',
          style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 18),
        ),
        content: Text(
          'Untuk mengirim $permissionType, aplikasi memerlukan izin akses. '
          'Silakan berikan izin melalui pengaturan aplikasi.',
          style: greyTextStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: greyTextStyle.copyWith(fontWeight: medium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkPermissions();
            },
            child: Text(
              'Coba Lagi',
              style: greenTextStyle.copyWith(fontWeight: medium),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleVoiceRecorder() async {
    if (!_isRecordingPermissionGranted) {
      await _checkPermissions();
      if (!_isRecordingPermissionGranted) {
        _showPermissionDialog('Voice Recording');
        return;
      }
    }

    setState(() {
      _showVoiceRecorder = !_showVoiceRecorder;
    });

    if (_showVoiceRecorder) {
      _focusNode.unfocus();
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: [
              if (_showVoiceRecorder) ...[
                ChatVoiceRecorder(
                  onRecordingComplete: _handleVoiceRecordingComplete,
                  onCancel: _handleVoiceRecordingCancel,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _handleVoiceRecordingCancel,
                      icon: Icon(Icons.close, color: redcolor),
                      label: Text(
                        'Batalkan',
                        style: TextStyle(color: redcolor, fontWeight: medium),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    // Attachment button (Image)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: widget.isLoading ? null : _showImagePicker,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isImagePermissionGranted
                                ? greenColor.withOpacity(0.1)
                                : greyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.attach_file,
                            color: _isImagePermissionGranted
                                ? greenColor
                                : greyColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Text input field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: lightBackgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? greenColor.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                focusNode: _focusNode,
                                maxLines: 4,
                                minLines: 1,
                                enabled: !widget.isLoading,
                                decoration: InputDecoration(
                                  hintText: widget.hint,
                                  hintStyle: greyTextStyle.copyWith(
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: blackTextStyle.copyWith(fontSize: 14),
                                textInputAction: TextInputAction.newline,
                                onSubmitted: (_) => _sendTextMessage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send button or Voice button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _hasText
                          ? Material(
                              key: const ValueKey('send'),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: widget.isLoading
                                    ? null
                                    : _sendTextMessage,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: greenColor,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: greenColor.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: widget.isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: whiteColor,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          Icons.send,
                                          color: whiteColor,
                                          size: 24,
                                        ),
                                ),
                              ),
                            )
                          : Material(
                              key: const ValueKey('voice'),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: widget.isLoading
                                    ? null
                                    : _toggleVoiceRecorder,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _isRecordingPermissionGranted
                                        ? greenColor.withOpacity(0.1)
                                        : greyColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.mic,
                                    color: _isRecordingPermissionGranted
                                        ? greenColor
                                        : greyColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced message input for mitra dengan additional options
class MitraEnhancedMessageInput extends StatelessWidget {
  final Function(String) onTextMessage;
  final Function(String, int) onVoiceMessage;
  final Function(File) onImageMessage;
  final bool isLoading;

  const MitraEnhancedMessageInput({
    super.key,
    required this.onTextMessage,
    required this.onVoiceMessage,
    required this.onImageMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedMessageInput(
      onTextMessage: onTextMessage,
      onVoiceMessage: onVoiceMessage,
      onImageMessage: onImageMessage,
      isLoading: isLoading,
      hint: 'Balas pelanggan...',
    );
  }
}

/// Enhanced message input for user dengan additional options
class UserEnhancedMessageInput extends StatelessWidget {
  final Function(String) onTextMessage;
  final Function(String, int) onVoiceMessage;
  final Function(File) onImageMessage;
  final bool isLoading;

  const UserEnhancedMessageInput({
    super.key,
    required this.onTextMessage,
    required this.onVoiceMessage,
    required this.onImageMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedMessageInput(
      onTextMessage: onTextMessage,
      onVoiceMessage: onVoiceMessage,
      onImageMessage: onImageMessage,
      isLoading: isLoading,
      hint: 'Ketik pesan ke admin...',
    );
  }
}
