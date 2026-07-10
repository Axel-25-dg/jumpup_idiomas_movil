class MessageThread {
  const MessageThread({
    required this.id,
    required this.subject,
    this.unreadCount = 0,
    this.lastMessageBody,
    this.lastMessageAt,
    this.participantNames = const [],
    this.participantAvatar, required String title, required String participantName,
  });

  final int id;
  final String subject;
  final int unreadCount;
  final String? lastMessageBody;
  final DateTime? lastMessageAt;
  final List<String> participantNames;
  final String? participantAvatar;

  String get participantName =>
      participantNames.isNotEmpty ? participantNames.first : 'Usuario';

  String get title => subject;

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    List<String> participantNames = [];
    String? participantAvatar;
    final participants = json['participants'];
    if (participants is List) {
      for (final p in participants) {
        if (p is Map) {
          final name = p['username']?.toString() ??
              p['name']?.toString() ??
              p['full_name']?.toString() ??
              '';
          if (name.isNotEmpty) participantNames.add(name);
          participantAvatar ??= p['avatar']?.toString() ??
              p['avatar_url']?.toString();
        }
      }
    } else if (participants is Map) {
      final name = participants['username']?.toString() ??
          participants['name']?.toString() ?? '';
      if (name.isNotEmpty) participantNames.add(name);
      participantAvatar = participants['avatar']?.toString() ??
          participants['avatar_url']?.toString();
    }

    Object? lastMsg = json['last_message'];
    String? lastMessageBody;
    if (lastMsg is Map) {
      lastMessageBody = lastMsg['body']?.toString() ??
          lastMsg['content']?.toString();
    } else if (lastMsg is String) {
      lastMessageBody = lastMsg;
    }

    return MessageThread(
      id: json['id'] as int? ?? 0,
      subject: json['subject']?.toString() ?? '',
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageBody: lastMessageBody,
      lastMessageAt: DateTime.tryParse(json['last_message_at']?.toString() ?? '') ??
          DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      participantNames: participantNames,
      participantAvatar: participantAvatar, title: '', participantName: '',
    );
  }
}
