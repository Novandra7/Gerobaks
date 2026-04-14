import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/chat_model.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/audio_service_manager.dart';
import 'package:bank_sha/services/audio_player_service.dart';
import 'package:bank_sha/ui/widgets/chat/voice_message_bubble.dart';
import 'package:bank_sha/ui/widgets/chat/enhanced_message_input.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  final bool isReadOnly;
  final String? customTitle;
  final String? readOnlyMessage;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    this.isReadOnly = false,
    this.customTitle,
    this.readOnlyMessage,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final AudioServiceManager _audioServiceManager = AudioServiceManager();
  late final AudioPlayerService _audioPlayerService;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isFirstFrameReady = false;
  final Map<String, String> _cachedImageFiles = {};
  ChatConversation? _conversation;

  @override
  void initState() {
    super.initState();

    // Initialize audio services
    _audioPlayerService = _audioServiceManager.getAudioPlayerService();

    _loadMessages();
    _markAsRead();

    // Listen to message updates
    _messagesSubscription = _chatService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        unawaited(_resolveCachedImageFiles(messages));
        _primeImageCache(messages);
        _scrollToBottom();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isFirstFrameReady = true;
      unawaited(_resolveCachedImageFiles(_messages));
      _primeImageCache(_messages);
    });
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _scrollController.dispose();
    unawaited(_audioPlayerService.stop());
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _messages = _chatService.getMessages(widget.conversationId);
      _conversation = _chatService.getConversationById(widget.conversationId);
    });
    unawaited(_resolveCachedImageFiles(_messages));
    _primeImageCache(_messages);
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

  bool _isRemoteImage(String imagePath) {
    final uri = Uri.tryParse(imagePath);
    if (uri == null) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  bool _isLikelyLocalDevicePath(String imagePath) {
    final normalized = imagePath.trim();
    if (normalized.isEmpty) return false;
    if (normalized.startsWith('file://') ||
        normalized.startsWith('content://')) {
      return true;
    }
    if (RegExp(r'^[a-zA-Z]:\\').hasMatch(normalized)) {
      return true;
    }
    return normalized.startsWith('/data/') ||
        normalized.startsWith('/storage/') ||
        normalized.startsWith('/var/') ||
        normalized.startsWith('/private/');
  }

  List<String> _resolveImageCandidates(String imagePath) {
    final normalized = imagePath.trim();
    if (normalized.isEmpty) return const <String>[];
    if (_isRemoteImage(normalized) || _isLikelyLocalDevicePath(normalized)) {
      return <String>[normalized];
    }

    final apiUri = Uri.tryParse(ApiRoutes.baseUrl);
    final origin =
        (apiUri != null &&
            apiUri.hasScheme &&
            apiUri.host.isNotEmpty &&
            apiUri.authority.isNotEmpty)
        ? '${apiUri.scheme}://${apiUri.authority}'
        : ApiRoutes.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final relative = normalized.replaceAll(RegExp(r'^/+'), '');

    final candidates = <String>['$origin/$relative'];

    if (relative.startsWith('uploads/')) {
      candidates.add('$origin/storage/$relative');
    } else if (!relative.startsWith('storage/')) {
      candidates.add('$origin/storage/$relative');
    }

    return candidates.toSet().toList();
  }

  String _resolveImageUrl(String imagePath) {
    final candidates = _resolveImageCandidates(imagePath);
    if (candidates.isEmpty) return imagePath.trim();
    return candidates.first;
  }

  Future<void> _resolveCachedImageFiles(List<ChatMessage> messages) async {
    final remoteUrls = <String>{};
    for (final message in messages) {
      if (message.type != MessageType.image) continue;
      final imageUrl = message.imageUrl?.trim() ?? '';
      if (imageUrl.isEmpty) continue;

      final candidates = _resolveImageCandidates(imageUrl);
      for (final candidate in candidates) {
        if (_isRemoteImage(candidate)) {
          remoteUrls.add(candidate);
        }
      }
    }

    if (remoteUrls.isEmpty) return;

    final resolved = Map<String, String>.from(_cachedImageFiles);
    var hasChange = false;

    for (final url in remoteUrls) {
      final cached = await DefaultCacheManager().getFileFromCache(url);
      final file = cached?.file;
      if (file == null) continue;
      if (!await file.exists()) continue;
      if (resolved[url] != file.path) {
        resolved[url] = file.path;
        hasChange = true;
      }
    }

    if (hasChange && mounted) {
      setState(() {
        _cachedImageFiles
          ..clear()
          ..addAll(resolved);
      });
    }
  }

  void _primeImageCache(List<ChatMessage> messages) {
    if (!mounted || !_isFirstFrameReady || messages.isEmpty) return;

    final remoteUrls = <String>{};
    for (final message in messages) {
      if (message.type != MessageType.image) continue;
      final imageUrl = message.imageUrl?.trim() ?? '';
      if (imageUrl.isEmpty) continue;

      final candidates = _resolveImageCandidates(imageUrl);
      for (final candidate in candidates) {
        if (_isRemoteImage(candidate)) {
          remoteUrls.add(candidate);
        }
      }
    }

    for (final url in remoteUrls) {
      unawaited(
        precacheImage(CachedNetworkImageProvider(url), context).catchError((_) {
          return null;
        }),
      );
    }
  }

  Widget _buildBrokenImagePlaceholder({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingImagePlaceholder({
    required double width,
    required double height,
  }) {
    return Container(width: width, height: height, color: Colors.grey[200]);
  }

  Widget _buildNetworkImageWithFallback(
    List<String> urls, {
    required int index,
    required BoxFit fit,
    required double width,
    required double height,
  }) {
    if (index >= urls.length) {
      return _buildBrokenImagePlaceholder(width: width, height: height);
    }

    final cachedFilePath = _cachedImageFiles[urls[index]];
    if (cachedFilePath != null && File(cachedFilePath).existsSync()) {
      return Image.file(
        File(cachedFilePath),
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildNetworkImageWithFallback(
            urls,
            index: index + 1,
            fit: fit,
            width: width,
            height: height,
          );
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: urls[index],
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (context, url) =>
          _buildLoadingImagePlaceholder(width: width, height: height),
      errorWidget: (context, url, error) {
        return _buildNetworkImageWithFallback(
          urls,
          index: index + 1,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }

  Widget _buildChatImage(
    String imagePath, {
    required BoxFit fit,
    required double width,
    required double height,
  }) {
    final candidates = _resolveImageCandidates(imagePath);
    if (candidates.isNotEmpty && _isRemoteImage(candidates.first)) {
      return _buildNetworkImageWithFallback(
        candidates,
        index: 0,
        fit: fit,
        width: width,
        height: height,
      );
    }

    final resolvedPath = _resolveImageUrl(imagePath);
    return Image.file(
      File(resolvedPath),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return _buildBrokenImagePlaceholder(width: width, height: height);
      },
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
    final adminName =
        widget.customTitle ?? _conversation?.adminName ?? 'Customer Service';

    return Scaffold(
      appBar: CustomAppNotif(title: adminName, showBackButton: true),
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
                            _buildDateHeader(
                              _formatDateHeader(message.timestamp),
                            ),
                          _buildMessageBubble(message),
                        ],
                      );
                    },
                  ),
          ),
          if (widget.isReadOnly)
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.readOnlyMessage ??
                    'Chat ini read-only karena pickup sudah selesai/dibatalkan.',
                textAlign: TextAlign.center,
                style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
              ),
            )
          else
            UserEnhancedMessageInput(
              onTextMessage: _handleTextMessage,
              onImageMessage: _handleImageMessage,
              isLoading: _isLoading,
            ),
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
              style: greyTextStyle.copyWith(fontSize: 12, fontWeight: medium),
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
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: blackTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
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
    final isUser = message.isFromUser;
    final isPendingMessage = isUser && message.id.startsWith('local_');
    final isSystem = message.type == MessageType.system;
    final isTyping = message.type == MessageType.typing;

    // Handle system messages (centered grey bubble)
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

    // Handle typing indicator
    if (isTyping) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(Icons.support_agent, color: greenColor, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: lightBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Handle voice message
    if (message.type == MessageType.voice && message.voiceUrl != null) {
      return VoiceMessageBubble(
        voiceUrl: message.voiceUrl!,
        durationInSeconds: message.voiceDuration ?? 0,
        isFromUser: isUser,
        timestamp: message.timestamp,
        audioPlayerService: _audioPlayerService,
      );
    }

    // Handle image message
    if (message.type == MessageType.image && message.imageUrl != null) {
      return _buildImageBubble(message);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(Icons.support_agent, color: greenColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? greenColor : whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        bottomRight: isUser
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
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
                      style: (isUser ? whiteTextStyle : blackTextStyle)
                          .copyWith(fontSize: 14, height: 1.4),
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
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(isPending: isPendingMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage message) {
    final isUser = message.isFromUser;
    final isPendingMessage = isUser && message.id.startsWith('local_');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(Icons.support_agent, color: greenColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? greenColor : whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
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
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
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
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    title: Text(
                                      message.imageUrl!.split('/').last,
                                      style: whiteTextStyle,
                                    ),
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 3.0,
                                      child: _buildChatImage(
                                        message.imageUrl!,
                                        fit: BoxFit.contain,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: _buildChatImage(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 200,
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
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(isPending: isPendingMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar({required bool isPending}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: greenColor.withOpacity(0.1),
          child: Icon(Icons.person, color: greenColor, size: 16),
        ),
        if (isPending)
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(greenColor),
            ),
          ),
      ],
    );
  }

  // Handler methods for EnhancedMessageInput
  Future<void> _handleTextMessage(String message) async {
    if (widget.isReadOnly) return;
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _chatService.sendMessage(widget.conversationId, message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleImageMessage(File imageFile) async {
    if (widget.isReadOnly) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, upload the image to a server and get a URL
      // Here we'll simulate it with a local path
      final String imageUrl = imageFile.path;
      await _chatService.sendImageMessage(widget.conversationId, imageUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
