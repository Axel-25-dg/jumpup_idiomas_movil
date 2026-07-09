class MessageThread {
  const MessageThread({
    required this.id,
    required this.title,
    required this.participantName,
    this.unreadCount = 0,
    this.lastMessage,
    this.participantAvatar,
    this.lastMessageAt,
  });

  final String id;
  final String title;
  final String participantName;
  final int unreadCount;
  final String? lastMessage;
  final String? participantAvatar;
  final DateTime? lastMessageAt;

  String get summary => '$title · $participantName';

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    Object? participant = json['participant'] ?? json['other_user'];
    String participantName = '';
    String? participantAvatar;
    if (participant is Map) {
      participantName = participant['name']?.toString() ??
          participant['username']?.toString() ??
          participant['full_name']?.toString() ??
          '';
      participantAvatar = participant['avatar']?.toString() ??
          participant['avatar_url']?.toString();
    }
    return MessageThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      participantName: participantName.isNotEmpty
          ? participantName
          : json['participant_name']?.toString() ??
              json['participantName']?.toString() ??
              'Usuario',
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ??
          int.tryParse(json['unreadCount']?.toString() ?? '0') ??
          0,
      lastMessage: json['last_message']?.toString() ??
          json['lastMessage']?.toString() ??
          json['last_message_preview']?.toString(),
      participantAvatar: participantAvatar,
      lastMessageAt: DateTime.tryParse(json['last_message_at']?.toString() ?? '') ??
          DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participantName': participantName,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage,
      'participantAvatar': participantAvatar,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
    };
  }
}
