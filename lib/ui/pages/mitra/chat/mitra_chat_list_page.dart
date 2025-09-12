import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/chat_model.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/ui/pages/mitra/chat/mitra_chat_detail_page.dart';
import 'package:intl/intl.dart';

class MitraChatListPage extends StatefulWidget {
  const MitraChatListPage({super.key});

  @override
  State<MitraChatListPage> createState() => _MitraChatListPageState();
}

class _MitraChatListPageState extends State<MitraChatListPage> with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  List<ChatConversation> _conversations = [];
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeChat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
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
    setState(() => _isLoading = false);
  }

  void _loadConversations() {
    setState(() {
      _conversations = _chatService.getConversations();
    });
  }

  // Membuat percakapan baru dengan customer service/admin
  void _startNewChatWithAdmin() async {
    final conversationId = await _chatService.createNewConversation(
      title: 'Chat dengan Admin',
      adminName: 'Admin Gerobaks',
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MitraChatDetailPage(conversationId: conversationId),
        ),
      );
    }
  }

  // Membuat percakapan baru dengan end-user
  void _startNewChatWithUser() async {
    // Show dialog to select user or order
    showDialog(
      context: context,
      builder: (context) => _buildSelectUserDialog(),
    );
  }

  Widget _buildSelectUserDialog() {
    return AlertDialog(
      title: Text(
        'Pilih Pelanggan',
        style: blackTextStyle.copyWith(
          fontWeight: semiBold,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari pelanggan',
                prefixIcon: Icon(Icons.search, color: greyColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: lightBackgroundColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: lightBackgroundColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 3, // Sample data
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: greenColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: greenColor),
                    ),
                    title: Text(
                      'Pelanggan ${index + 1}',
                      style: blackTextStyle.copyWith(fontWeight: medium),
                    ),
                    subtitle: Text(
                      'ID: USER-00${index + 1}',
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final conversationId = await _chatService.createNewConversation(
                        title: 'Chat dengan Pelanggan ${index + 1}',
                        adminName: 'Pelanggan ${index + 1}',
                      );
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MitraChatDetailPage(conversationId: conversationId),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: greyTextStyle,
          ),
        ),
      ],
    );
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
      appBar: CustomAppNotif(
        title: 'Chat',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              _tabController.index == 0 
                ? _startNewChatWithUser() 
                : _startNewChatWithAdmin();
            },
            icon: Icon(
              Icons.add_comment_rounded,
              color: blackColor,
            ),
            tooltip: 'Chat Baru',
          ),
        ],
      ),
      backgroundColor: uicolor,
      body: Column(
        children: [
          // Tab Bar untuk memisahkan chat dengan Pelanggan dan Admin
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: greenColor,
              unselectedLabelColor: greyColor,
              indicatorColor: greenColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontWeight: semiBold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Pelanggan'),
                Tab(text: 'Admin/CS'),
              ],
            ),
          ),
          
          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Pelanggan
                _isLoading
                    ? _buildLoadingState()
                    : _buildConversationList(isUserChat: true),
                
                // Tab Admin/CS
                _isLoading
                    ? _buildLoadingState()
                    : _buildConversationList(isUserChat: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.index == 0 
              ? _startNewChatWithUser() 
              : _startNewChatWithAdmin();
        },
        backgroundColor: greenColor,
        child: Icon(
          Icons.chat_outlined,
          color: whiteColor,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: greenColor,
      ),
    );
  }

  Widget _buildEmptyState(bool isUserChat) {
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
            isUserChat 
                ? 'Mulai chat baru dengan pelanggan' 
                : 'Mulai chat baru dengan admin/CS',
            style: greyTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              isUserChat ? _startNewChatWithUser() : _startNewChatWithAdmin();
            },
            icon: const Icon(Icons.chat),
            label: Text(isUserChat ? 'Chat Pelanggan' : 'Chat Admin'),
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

  Widget _buildConversationList({required bool isUserChat}) {
    // Filter percakapan berdasarkan tipe (dengan pelanggan atau admin)
    final filteredConversations = _conversations.where((conv) {
      // Logika filter sederhana berdasarkan judul percakapan
      // Di implementasi nyata, ini harus menggunakan data yang lebih spesifik
      return isUserChat 
          ? conv.title.toLowerCase().contains('pelanggan')
          : conv.title.toLowerCase().contains('admin') || 
            conv.title.toLowerCase().contains('cs');
    }).toList();
    
    if (filteredConversations.isEmpty) {
      return _buildEmptyState(isUserChat);
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredConversations.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFE0E0E0),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: conversation.title.toLowerCase().contains('admin')
            ? blueColor.withOpacity(0.1)
            : greenColor.withOpacity(0.1),
        radius: 24,
        child: conversation.adminAvatar != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  conversation.adminAvatar!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: conversation.title.toLowerCase().contains('admin')
                        ? blueColor
                        : greenColor,
                    size: 24,
                  ),
                ),
              )
            : Icon(
                Icons.person,
                color: conversation.title.toLowerCase().contains('admin')
                    ? blueColor
                    : greenColor,
                size: 24,
              ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.title,
              style: blackTextStyle.copyWith(
                fontWeight: conversation.isUnread ? semiBold : medium,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(conversation.lastMessageTime),
            style: greyTextStyle.copyWith(
              fontSize: 12,
              fontWeight: conversation.isUnread ? medium : regular,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage,
              style: conversation.isUnread
                  ? blackTextStyle.copyWith(fontSize: 13)
                  : greyTextStyle.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.isUnread && conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: greenColor,
                shape: BoxShape.circle,
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
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MitraChatDetailPage(
              conversationId: conversation.id,
            ),
          ),
        );
      },
    );
  }
}
