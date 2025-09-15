import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/chat_model.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/audio_service_manager.dart';
import 'package:bank_sha/services/audio_player_service.dart';
import 'package:bank_sha/services/audio_recorder_service.dart';
import 'package:bank_sha/ui/widgets/chat/voice_message_bubble.dart';
import 'package:bank_sha/ui/widgets/chat/voice_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class MitraChatDetailPage extends StatefulWidget {
  final String conversationId;

  const MitraChatDetailPage({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<MitraChatDetailPage> createState() => _MitraChatDetailPageState();
}

class _MitraChatDetailPageState extends State<MitraChatDetailPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioServiceManager _audioServiceManager = AudioServiceManager();
  late final AudioRecorderService _audioRecorderService;
  late final AudioPlayerService _audioPlayerService;
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showVoiceRecorder = false;
  File? _selectedImage;
  ChatConversation? _conversation;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi audio services
    _audioRecorderService = _audioServiceManager.getAudioRecorderService();
    _audioPlayerService = _audioServiceManager.getAudioPlayerService();
    
    _loadMessages();
    _markAsRead();
    
    // Listen to message updates
    _chatService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _audioRecorderService.dispose();
    _audioPlayerService.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _messages = _chatService.getMessages(widget.conversationId);
      _conversation = _chatService.getConversationById(widget.conversationId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _markAsRead() {
    _chatService.markAsRead(widget.conversationId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
    
    if (statuses[Permission.camera]!.isPermanentlyDenied ||
        statuses[Permission.storage]!.isPermanentlyDenied) {
      // Show dialog suggesting to open app settings
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text(
              'Untuk mengirim gambar dalam chat, aplikasi memerlukan izin akses kamera dan penyimpanan. '
              'Silakan berikan izin melalui pengaturan aplikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _messageController.clear();
    
    try {
      await _chatService.sendMessage(widget.conversationId, message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );
      
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
        
        // Send the image
        await _sendImageMessage(pickedImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }
  
  Future<void> _sendImageMessage(XFile imageFile) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, upload the image to a server and get a URL
      // Here we'll simulate it with a local path
      final String imageUrl = imageFile.path;
      await _chatService.sendImageMessage(widget.conversationId, imageUrl);
      
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _handleVoiceRecordingComplete(String path, int durationInSeconds) {
    _sendVoiceMessage(path, durationInSeconds);
  }
  
  Future<void> _sendVoiceMessage(String path, int durationInSeconds) async {
    setState(() {
      _isLoading = true;
      _showVoiceRecorder = false;
    });
    
    try {
      await _chatService.sendVoiceMessage(widget.conversationId, path, durationInSeconds);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send voice message: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kirim Media',
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    _requestPermissions().then((_) => _pickImage(ImageSource.camera));
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _requestPermissions().then((_) => _pickImage(ImageSource.gallery));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: greenColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: blackTextStyle.copyWith(
              fontSize: 14,
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    }
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;
    
    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];
    
    return currentMessage.timestamp.day != previousMessage.timestamp.day ||
           currentMessage.timestamp.month != previousMessage.timestamp.month ||
           currentMessage.timestamp.year != previousMessage.timestamp.year;
  }

  @override
  Widget build(BuildContext context) {
    final userName = _conversation?.adminName ?? 'Pengguna';
    
    return Scaffold(
      appBar: CustomAppNotif(
        title: userName,
        showBackButton: true,
      ),
      backgroundColor: uicolor,
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Column(
                        children: [
                          if (_shouldShowDateHeader(index))
                            _buildDateHeader(_formatDateHeader(message.timestamp)),
                          _buildMessageBubble(message),
                        ],
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: greyTextStyle.copyWith(
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Mulai percakapan dengan mengirim pesan',
              style: greyTextStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // For mitra chat, the isFromUser logic is inverted
    // Here, messages from admin are considered from "me" (mitra admin)
    final isFromMe = !message.isFromUser;
    final isSystem = message.type == MessageType.system;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.message,
              style: greyTextStyle.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    
    // Handle voice message
    if (message.type == MessageType.voice && message.voiceUrl != null) {
      return VoiceMessageBubble(
        voiceUrl: message.voiceUrl!,
        durationInSeconds: message.voiceDuration ?? 0,
        isFromUser: isFromMe, // Inverted for mitra
        timestamp: message.timestamp,
        audioPlayerService: _audioPlayerService,
      );
    }
    
    // Handle image message
    if (message.type == MessageType.image && message.imageUrl != null) {
      return _buildImageBubble(message, isFromMe);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: greenColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isFromMe ? greenColor : whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isFromMe ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isFromMe ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.message,
                      style: (isFromMe ? whiteTextStyle : blackTextStyle).copyWith(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: greyTextStyle.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.support_agent,
                color: greenColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildImageBubble(ChatMessage message, bool isFromMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: greenColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isFromMe ? greenColor : whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isFromMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isFromMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isFromMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isFromMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Show full image preview
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    leading: IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    title: Text(
                                      'Image Preview',
                                      style: whiteTextStyle,
                                    ),
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 3.0,
                                      child: Image.file(
                                        File(message.imageUrl!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Image.file(
                            File(message.imageUrl!),
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: greyTextStyle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.support_agent,
                color: greenColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            if (_showVoiceRecorder) 
              VoiceRecorder(
                recorderService: _audioRecorderService,
                onRecordingComplete: _handleVoiceRecordingComplete,
                onCancel: () => setState(() => _showVoiceRecorder = false),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: 'Ketik pesan...',
                                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              style: blackTextStyle.copyWith(fontSize: 14),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              onChanged: (value) {
                                setState(() {}); // Refresh send button state
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: _showAttachmentOptions,
                            icon: Icon(
                              Icons.attach_file,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _messageController.text.trim().isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: _messageController.text.trim().isNotEmpty || _isLoading 
                                ? greenColor 
                                : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _sendMessage,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: whiteColor,
                                    size: 20,
                                  ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              _showVoiceRecorder = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: greenColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.mic,
                              color: whiteColor,
                              size: 20,
                            ),
                          ),
                        ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}