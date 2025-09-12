import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/subscription_service.dart';

class ChatIconWithBadge extends StatefulWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double iconSize;
  final bool forHeader;

  const ChatIconWithBadge({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize = 24.0,
    this.forHeader = false,
  });

  @override
  State<ChatIconWithBadge> createState() => _ChatIconWithBadgeState();
}

class _ChatIconWithBadgeState extends State<ChatIconWithBadge> {
  final ChatService _chatService = ChatService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  int _unreadCount = 0;
  String _subscriptionStatus = 'none';

  @override
  void initState() {
    super.initState();
    _initializeAndListenToChats();
    _loadSubscriptionStatus();
  }

  void _initializeAndListenToChats() async {
    // Initialize chat service
    await _chatService.initializeData();
    
    // Get initial unread count
    _updateUnreadCount();
    
    // Listen to conversation updates
    _chatService.conversationsStream.listen((conversations) {
      if (mounted) {
        _updateUnreadCount();
      }
    });
  }

  void _loadSubscriptionStatus() async {
    final currentSubscription = _subscriptionService.getCurrentSubscription();
    if (mounted) {
      setState(() {
        _subscriptionStatus = currentSubscription?.planName ?? 'none';
      });
    }
  }

  void _updateUnreadCount() {
    final newCount = _chatService.getTotalUnreadCount();
    if (mounted && newCount != _unreadCount) {
      setState(() {
        _unreadCount = newCount;
      });
    }
  }

  String _getSubscriptionBadge() {
    switch (_subscriptionStatus.toLowerCase()) {
      case 'basic':
        return '🏠';
      case 'premium':
        return '⭐';
      case 'pro':
        return '🏢';
      default:
        return '!'; // Exclamation mark for no subscription
    }
  }

  String? _getSubscriptionText() {
    switch (_subscriptionStatus.toLowerCase()) {
      case 'basic':
      case 'premium':
      case 'pro':
        return null; // No text needed for subscribed users
      default:
        return 'Anda belum berlangganan';
    }
  }

  Color _getSubscriptionColor() {
    switch (_subscriptionStatus.toLowerCase()) {
      case 'basic':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      case 'pro':
        return Colors.amber;
      default:
        return Colors.red; // Red for no subscription to draw attention
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionText = _getSubscriptionText();
    final Color iconColor = widget.iconColor ?? (widget.forHeader ? Colors.white : blackColor);
    
    Widget chatIcon = GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.chat_bubble_outline,
              color: iconColor,
              size: widget.iconSize,
            ),
          ),
          // Subscription badge (top-left)
          if (!widget.forHeader)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getSubscriptionColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    _getSubscriptionBadge(),
                    style: TextStyle(
                      fontSize: 8,
                      color: _subscriptionStatus.toLowerCase() == 'none' 
                          ? Colors.white 
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          // Unread message badge (top-right)
          if (_unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: redcolor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: whiteTextStyle.copyWith(
                    fontSize: 9,
                    fontWeight: bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );

    // Wrap with Tooltip if user hasn't subscribed
    if (subscriptionText != null && !widget.forHeader) {
      return Tooltip(
        message: subscriptionText,
        child: chatIcon,
      );
    }
    
    return chatIcon;
  }
}
