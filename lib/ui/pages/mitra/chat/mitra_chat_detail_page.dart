import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/models/chat_model.dart';
import 'package:bank_sha/services/chat_service.dart';
import 'package:bank_sha/services/audio_service_manager.dart';
import 'package:bank_sha/services/audio_player_service.dart';
import 'package:bank_sha/services/chat_image_service.dart';
import 'package:bank_sha/ui/widgets/chat/voice_message_bubble.dart';
import 'package:bank_sha/ui/widgets/chat/enhanced_message_input.dart';
import 'package:bank_sha/utils/api_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';

class MitraChatDetailPage extends StatefulWidget {
  final String conversationId;
  final bool isReadOnly;
  final String? customTitle;
  final String? readOnlyMessage;

  const MitraChatDetailPage({
    super.key,
    required this.conversationId,
    this.isReadOnly = false,
    this.customTitle,
    this.readOnlyMessage,
  });

  @override
  State<MitraChatDetailPage> createState() => _MitraChatDetailPageState();
}

class _MitraChatDetailPageState extends State<MitraChatDetailPage>
    with WidgetsBindingObserver {
  static const bool _useRealtimeChannel = true;
  static const int _maxImagesToResolveFromCache = 24;
  static const Duration _realtimeStopDelay = Duration(milliseconds: 350);
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioServiceManager _audioServiceManager = AudioServiceManager();
  late final AudioPlayerService _audioPlayerService;
  late final ChatImageService _chatImageService;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isFirstFrameReady = false;
  final Map<String, String> _cachedImageFiles = {};
  ChatConversation? _conversation;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  Timer? _realtimeStartDebounce;
  Timer? _realtimeRetryTimer;
  Timer? _messagesApplyDebounce;
  Timer? _imageWorkDebounce;
  List<ChatMessage>? _pendingMessagesForUi;
  String _lastUiMessageSignature = '';
  bool _isStartingRealtime = false;
  bool _isResolvingCachedImages = false;
  bool _hasPendingCacheResolve = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi audio services
    _audioPlayerService = _audioServiceManager.getAudioPlayerService();
    _chatImageService = ChatImageService.getInstance();

    _loadMessages();
    _markAsRead();

    // Listen to message updates
    _messagesSubscription = _chatService.messagesStream.listen((messages) {
      if (!mounted) return;
      final snapshot = List<ChatMessage>.from(messages);
      final signature = _buildMessageSignature(snapshot);
      if (signature == _lastUiMessageSignature) return;

      _pendingMessagesForUi = snapshot;
      _messagesApplyDebounce?.cancel();
      _messagesApplyDebounce = Timer(const Duration(milliseconds: 80), () {
        final pending = _pendingMessagesForUi;
        if (!mounted || pending == null) return;
        _pendingMessagesForUi = null;

        final shouldAutoScroll = pending.length > _messages.length;
        setState(() {
          _messages = pending;
          _lastUiMessageSignature = _buildMessageSignature(pending);
        });
        _scheduleImageWork(pending);
        if (shouldAutoScroll) {
          _scrollToBottomOnNextFrame();
        }
      });
    });

    _focusNode.addListener(_handleInputFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isFirstFrameReady = true;
      _scheduleImageWork(_messages);
      if (_useRealtimeChannel) {
        _realtimeStartDebounce = Timer(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          unawaited(_startRealtimeSafely());
        });
        _realtimeRetryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (!mounted) return;
          unawaited(_startRealtimeSafely());
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_handleInputFocusChange);
    if (_useRealtimeChannel) {
      unawaited(
        Future<void>.delayed(_realtimeStopDelay, () {
          return _chatService.stopRealtimeForConversation(
            widget.conversationId,
          );
        }),
      );
    }
    _messagesSubscription?.cancel();
    _realtimeStartDebounce?.cancel();
    _realtimeRetryTimer?.cancel();
    _messagesApplyDebounce?.cancel();
    _imageWorkDebounce?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    unawaited(_audioPlayerService.stop());
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 120), _scrollToBottom);
    });
  }

  void _loadMessages() {
    setState(() {
      _messages = _chatService.getMessages(widget.conversationId);
      _lastUiMessageSignature = _buildMessageSignature(_messages);
      _conversation = _chatService.getConversationById(widget.conversationId);
    });
    _scheduleImageWork(_messages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
    _chatService.markAsRead(widget.conversationId);
  }

  void _markAsRead() {
    _chatService.markAsRead(widget.conversationId);
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      final offset = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(offset);
      }
    }
  }

  void _scrollToBottomOnNextFrame({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollToBottom(animated: animated);
    });
  }

  void _handleInputFocusChange() {
    if (!_focusNode.hasFocus || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 120), _scrollToBottom);
    });
  }

  String _buildMessageSignature(List<ChatMessage> messages) {
    if (messages.isEmpty) return '0';
    final last = messages.last;
    return '${messages.length}|${last.id}|${last.timestamp.microsecondsSinceEpoch}|${last.type.name}';
  }

  Future<void> _startRealtimeSafely() async {
    if (!_useRealtimeChannel || _isStartingRealtime) return;
    _isStartingRealtime = true;
    try {
      await _chatService.startRealtimeForConversation(widget.conversationId);
    } catch (e) {
      print('Mitra realtime start failed: $e');
    } finally {
      _isStartingRealtime = false;
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
    if (_isLikelyLocalDevicePath(normalized)) {
      return <String>[normalized];
    }
    if (_isRemoteImage(normalized)) {
      final uri = Uri.tryParse(normalized);
      if (uri != null) {
        final path = uri.path;
        if (path.startsWith('/uploads/')) {
          final storageUri = uri.replace(path: '/storage$path').toString();
          return <String>{storageUri, normalized}.toList();
        }
      }
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

    final candidates = <String>[];
    if (relative.startsWith('uploads/')) {
      candidates.add('$origin/storage/$relative');
      candidates.add('$origin/$relative');
    } else if (!relative.startsWith('storage/')) {
      candidates.add('$origin/storage/$relative');
      candidates.add('$origin/$relative');
    } else {
      candidates.add('$origin/$relative');
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
    var processedImages = 0;
    for (final message in messages.reversed) {
      if (message.type != MessageType.image) continue;
      final imageUrl = message.imageUrl?.trim() ?? '';
      if (imageUrl.isEmpty) continue;

      final candidates = _resolveImageCandidates(imageUrl);
      for (final candidate in candidates) {
        if (_isRemoteImage(candidate)) {
          remoteUrls.add(candidate);
        }
      }
      processedImages++;
      if (processedImages >= _maxImagesToResolveFromCache) break;
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

  void _scheduleImageWork(List<ChatMessage> messages) {
    if (!_isFirstFrameReady || !mounted) return;
    _imageWorkDebounce?.cancel();
    final snapshot = List<ChatMessage>.from(messages);
    _imageWorkDebounce = Timer(const Duration(milliseconds: 150), () {
      unawaited(_runImageWork(snapshot));
    });
  }

  Future<void> _runImageWork(List<ChatMessage> messages) async {
    if (_isResolvingCachedImages || !mounted) {
      _hasPendingCacheResolve = true;
      return;
    }
    _isResolvingCachedImages = true;
    try {
      await _resolveCachedImageFiles(messages);
    } finally {
      _isResolvingCachedImages = false;
      if (_hasPendingCacheResolve && mounted) {
        _hasPendingCacheResolve = false;
        _scheduleImageWork(_messages);
      }
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
    if (cachedFilePath != null) {
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

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (pickedImage != null) {
        // Send the image directly without storing state
        await _sendImageMessage(pickedImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ignore: unused_element
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
                    _requestPermissions().then(
                      (_) => _pickImage(ImageSource.camera),
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _requestPermissions().then(
                      (_) => _pickImage(ImageSource.gallery),
                    );
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
            child: Icon(icon, color: greenColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: blackTextStyle.copyWith(fontSize: 14, fontWeight: medium),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime.toLocal());
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = currentDate.difference(messageDate).inDays;

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
    final userName =
        widget.customTitle ?? _conversation?.adminName ?? 'Pengguna';

    return Scaffold(
      appBar: CustomAppNotif(title: userName, showBackButton: true),
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
    // For mitra view, mitra/admin messages should appear on the right (as "me")
    // and user messages should appear on the left
    final isFromMe =
        message.isFromUser ==
        false; // Messages from admin (isFromUser=false) are from "me" as mitra
    final isPendingMessage = isFromMe && message.id.startsWith('local_');
    final isSystem = message.type == MessageType.system;
    final isTyping = message.type == MessageType.typing;

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
          // Show typing indicator on the left (from customer)
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(Icons.person, color: greenColor, size: 16),
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
        isFromUser: isFromMe, // Use our corrected isFromMe value
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
        mainAxisAlignment: isFromMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(
                Icons.person, // Customer icon
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
                crossAxisAlignment: isFromMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isFromMe ? greenColor : whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isFromMe
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        bottomRight: isFromMe
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
                      style: (isFromMe ? whiteTextStyle : blackTextStyle)
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
          if (isFromMe) ...[
            const SizedBox(width: 8),
            _buildSupportAgentAvatar(isPending: isPendingMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage message, bool isFromMe) {
    final isPendingMessage = isFromMe && message.id.startsWith('local_');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: greenColor.withOpacity(0.1),
              child: Icon(Icons.person, color: greenColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
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
                      bottomLeft: isFromMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isFromMe
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
                      bottomLeft: isFromMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isFromMe
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
          if (isFromMe) ...[
            const SizedBox(width: 8),
            _buildSupportAgentAvatar(isPending: isPendingMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildSupportAgentAvatar({required bool isPending}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: greenColor.withOpacity(0.1),
          child: Icon(Icons.support_agent, color: greenColor, size: 16),
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

  Widget _buildMessageInput() {
    return MitraEnhancedMessageInput(
      onTextMessage: (message) async {
        if (widget.isReadOnly) return;
        try {
          await _chatService.sendMessage(widget.conversationId, message);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengirim pesan: $e'),
                backgroundColor: redcolor,
              ),
            );
          }
        }
      },
      onImageMessage: (imageFile) async {
        if (widget.isReadOnly) return;
        setState(() => _isLoading = true);
        try {
          // Validate image first
          final validation = await _chatImageService.validateImage(imageFile);
          if (!validation.isValid) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(validation.error ?? 'Gambar tidak valid'),
                  backgroundColor: redcolor,
                ),
              );
            }
            return;
          }

          await _chatService.sendImageMessage(
            widget.conversationId,
            imageFile.path,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengirim gambar: $e'),
                backgroundColor: redcolor,
              ),
            );
          }
        } finally {
          setState(() => _isLoading = false);
        }
      },
      isLoading: _isLoading,
    );
  }
}
