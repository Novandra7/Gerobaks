class ChatMessage {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool isFromUser; // true jika dari user, false jika dari admin/CS
  final String? imageUrl;
  final String? voiceUrl;  // Add voiceUrl field
  final int? voiceDuration;  // Add voice duration in seconds
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isFromUser,
    this.imageUrl,
    this.voiceUrl,  // Add voiceUrl parameter
    this.voiceDuration,  // Add voiceDuration parameter
    this.type = MessageType.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isFromUser: json['isFromUser'],
      imageUrl: json['imageUrl'],
      voiceUrl: json['voiceUrl'],  // Add voiceUrl from JSON
      voiceDuration: json['voiceDuration'],  // Add voiceDuration from JSON
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,  // Add voiceUrl to JSON
      'voiceDuration': voiceDuration,  // Add voiceDuration to JSON
      'type': type.toString().split('.').last,
    };
  }
}

class ChatConversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isUnread;
  final int unreadCount;
  final String adminName;
  final String? adminAvatar;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isUnread = false,
    this.unreadCount = 0,
    this.adminName = 'Customer Service',
    this.adminAvatar,
    this.messages = const [],
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      isUnread: json['isUnread'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      adminName: json['adminName'] ?? 'Customer Service',
      adminAvatar: json['adminAvatar'],
      messages: (json['messages'] as List?)
          ?.map((m) => ChatMessage.fromJson(m))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'isUnread': isUnread,
      'unreadCount': unreadCount,
      'adminName': adminName,
      'adminAvatar': adminAvatar,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

enum MessageType {
  text,
  image,
  document,
  voice,  // Tambahkan voice message type
  system,
  typing,  // Add typing indicator message type
}
