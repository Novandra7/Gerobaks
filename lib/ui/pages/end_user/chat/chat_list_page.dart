import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/chat_model.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/ui/pages/end_user/chat/chat_detail_page.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  List<ChatConversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _chatService.initializeData();
    _loadConversations();
    
    // Listen to conversation updates
    _chatService.conversationsStream.listen((conversations) {
      if (mounted) {
        setState(() {
          _conversations = conversations;
        });
      }
    });
  }

  void _loadConversations() {
    setState(() {
      _conversations = _chatService.getConversations();
    });
  }

  void _startNewChat() async {
    final conversationId = await _chatService.createNewConversation();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(conversationId: conversationId),
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'id_ID').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppNotif(
        title: 'Chat',
        showBackButton: true,
      ),
      backgroundColor: uicolor,
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: greenColor,
        child: Icon(
          Icons.chat_outlined,
          color: whiteColor,
        ),
      ),
      body: _conversations.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return _buildConversationItem(conversation);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada percakapan',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: medium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai chat baru dengan customer service',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.chat),
            label: const Text('Mulai Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: greenColor.withOpacity(0.1),
        child: conversation.adminAvatar != null
            ? ClipOval(
                child: Image.asset(
                  conversation.adminAvatar!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.support_agent,
                color: greenColor,
                size: 28,
              ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.adminName,
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: conversation.isUnread ? semiBold : medium,
              ),
            ),
          ),
          Text(
            _formatTime(conversation.lastMessageTime),
            style: greyTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage,
              style: greyTextStyle.copyWith(
                fontSize: 14,
                fontWeight: conversation.isUnread ? medium : regular,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: redcolor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: whiteTextStyle.copyWith(
                  fontSize: 10,
                  fontWeight: bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              conversationId: conversation.id,
            ),
          ),
        );
      },
    );
  }
}
