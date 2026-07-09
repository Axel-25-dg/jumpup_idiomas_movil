class MessageThread {
  const MessageThread({
    required this.id,
    required this.title,
    required this.participantName,
    this.unreadCount = 0,
    this.lastMessage,
  });

  final String id;
  final String title;
  final String participantName;
  final int unreadCount;
  final String? lastMessage;

  String get summary => '$title · $participantName';

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      participantName: json['participantName']?.toString() ?? '',
      unreadCount: int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      lastMessage: json['lastMessage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participantName': participantName,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage,
    };
  }
}
