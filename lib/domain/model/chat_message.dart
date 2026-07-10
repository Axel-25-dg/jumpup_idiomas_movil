class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  final int id;
  final int senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    Object? sender = json['sender'];
    String senderName = '';
    int senderId = 0;
    if (sender is Map) {
      senderName = sender['name']?.toString() ??
          sender['username']?.toString() ??
          sender['full_name']?.toString() ??
          '';
      senderId = sender['id'] as int? ?? 0;
    }
    return ChatMessage(
      id: json['id'] as int? ?? 0,
      senderId: senderId != 0
          ? senderId
          : json['sender_id'] as int? ??
              int.tryParse(json['senderId']?.toString() ?? '') ??
              0,
      senderName: senderName.isNotEmpty
          ? senderName
          : json['sender_name']?.toString() ??
              json['senderName']?.toString() ??
              'Usuario',
      body: json['body']?.toString() ?? json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['is_read'] == true || json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
