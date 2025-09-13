import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/chat_model.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class MitraChatDetailPage extends StatefulWidget {
  final String conversationId;

  const MitraChatDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<MitraChatDetailPage> createState() => _MitraChatDetailPageState();
}

class _MitraChatDetailPageState extends State<MitraChatDetailPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  List<ChatMessage> _messages = [];
  bool _isSending = false;
  ChatConversation? _conversation;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
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
    _chatService.markConversationAsRead(widget.conversationId);
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
    // Request camera and storage permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();
    
    if (statuses[Permission.camera] != PermissionStatus.granted ||
        (statuses[Permission.storage] != PermissionStatus.granted && 
         statuses[Permission.photos] != PermissionStatus.granted)) {
      // Show dialog explaining why permissions are needed
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin diperlukan'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
  
  Future<void> _sendImageMessage(XFile imageFile) async {
    setState(() {
      _isSending = true;
    });
    
    try {
      // In a real app, upload the image to a server and get a URL
      // Here we'll simulate it with a local path
      final String imageUrl = imageFile.path;
      await _chatService.sendImageMessage(widget.conversationId, imageUrl);
      
      setState(() {
        _selectedImage = null;
      });
      
      // Simulate response after delay
      if (_conversation?.title.toLowerCase().contains('admin') ?? false) {
        Future.delayed(const Duration(seconds: 2), () {
          _chatService.simulateAdminResponse(widget.conversationId);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    _messageController.clear();
    _focusNode.requestFocus();

    try {
      await _chatService.sendMessage(widget.conversationId, message);
      
      // Simulate response from the other party after delay
      // In a real app, this would come from the server
      if (_conversation?.title.toLowerCase().contains('admin') ?? false) {
        Future.delayed(const Duration(seconds: 2), () {
          _chatService.simulateAdminResponse(widget.conversationId);
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          _chatService.simulateUserResponse(widget.conversationId);
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: redcolor,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  String _formatMessageTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      return 'Hari Ini';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppNotif(
        title: _conversation?.title ?? 'Chat',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: blackColor),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      backgroundColor: uicolor,
      body: Column(
        children: [
          // Status bar - Tunjukkan apakah mitra sedang online/offline
          _buildStatusBar(),
          
          // Chat messages area
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: uicolor,
                image: DecorationImage(
                  image: AssetImage('assets/img_bg_card.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
              child: _messages.isEmpty
                  ? _buildEmptyChat()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final bool showDate = _shouldShowDate(index);
                        
                        return Column(
                          children: [
                            if (showDate) _buildDateSeparator(message.timestamp),
                            _buildMessageBubble(message),
                          ],
                        );
                      },
                    ),
            ),
          ),
          
          // Input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final bool isWithAdmin = _conversation?.title.toLowerCase().contains('admin') ?? false;
    // Menggunakan status online statis untuk saat ini
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: greenColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Online',
            style: greyTextStyle.copyWith(fontSize: 12),
          ),
          const Spacer(),
          Text(
            isWithAdmin 
                ? 'Admin akan merespon dalam 5-10 menit' 
                : 'Biasanya membalas dalam 5 menit',
            style: greyTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDate(int index) {
    if (index == 0) return true;
    
    final currentDate = DateTime(
      _messages[index].timestamp.year,
      _messages[index].timestamp.month,
      _messages[index].timestamp.day,
    );
    
    final previousDate = DateTime(
      _messages[index - 1].timestamp.year,
      _messages[index - 1].timestamp.month,
      _messages[index - 1].timestamp.day,
    );
    
    return currentDate != previousDate;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: greyColor.withOpacity(0.3)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatMessageDate(date),
              style: greyTextStyle.copyWith(
                fontSize: 12,
                fontWeight: medium,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: greyColor.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isMine = message.isFromUser;
    
    // System message
    if (message.type == MessageType.system) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: greyColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.message,
          style: greyTextStyle.copyWith(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    // Regular message
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMine 
                ? greenColor 
                : Colors.white,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isMine ? const Radius.circular(4) : null,
              bottomLeft: !isMine ? const Radius.circular(4) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Message image if any
              if (message.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: message.imageUrl!.startsWith('http')
                      ? Image.network(
                          message.imageUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 150,
                            color: greyColor.withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: greyColor,
                            ),
                          ),
                        )
                      : Image.file(
                          File(message.imageUrl!),
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 150,
                            color: greyColor.withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: greyColor,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Message text
              Text(
                message.message,
                style: isMine
                    ? whiteTextStyle.copyWith(fontSize: 14)
                    : blackTextStyle.copyWith(fontSize: 14),
              ),
              
              // Message timestamp
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatMessageTime(message.timestamp),
                  style: (isMine ? whiteTextStyle : greyTextStyle).copyWith(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              onPressed: () {
                _showAttachmentOptions();
              },
              icon: Icon(
                Icons.attach_file_rounded,
                color: greyColor,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            
            // Text input field
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: greyTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: lightBackgroundColor,
                ),
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            
            // Send button
            InkWell(
              onTap: _isSending ? null : _sendMessage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: greenColor,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? SizedBox(
                        width: 24,
                        height: 24,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: greyColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: medium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai kirim pesan sekarang',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opsi Chat',
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 24),
            _buildChatOption(
              icon: Icons.delete_outline,
              label: 'Hapus Riwayat Chat',
              color: redcolor,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            _buildChatOption(
              icon: Icons.block,
              label: 'Blokir',
              color: redcolor,
              onTap: () {
                Navigator.pop(context);
                // Implementasi blokir pengguna
              },
            ),
            _buildChatOption(
              icon: Icons.flag_outlined,
              label: 'Laporkan',
              color: orangeColor,
              onTap: () {
                Navigator.pop(context);
                // Implementasi laporkan pengguna
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: blackTextStyle.copyWith(fontWeight: medium),
      ),
      onTap: onTap,
    );
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Riwayat Chat',
          style: blackTextStyle.copyWith(
            fontWeight: semiBold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus seluruh riwayat chat ini? Tindakan ini tidak dapat dibatalkan.',
          style: blackTextStyle.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: greyTextStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementasi hapus riwayat chat
              _chatService.clearConversation(widget.conversationId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Riwayat chat telah dihapus'),
                  backgroundColor: greenColor,
                ),
              );
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: redcolor),
            ),
          ),
        ],
      ),
    );
  }
}