class SocialComment {
  const SocialComment({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    this.authorAvatar,
    this.reactionCount = 0,
  });

  final int id;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final String? authorAvatar;
  final int reactionCount;

  factory SocialComment.fromJson(Map<String, dynamic> json) {
    return SocialComment(
      id: json['id'] as int? ?? 0,
      authorName: json['author_name']?.toString() ??
          json['author_username']?.toString() ??
          json['authorName']?.toString() ??
          json['author']?.toString() ??
          'Usuario',
      body: json['body']?.toString() ?? json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      authorAvatar: json['author_avatar']?.toString() ??
          json['authorAvatar']?.toString(),
      reactionCount: json['reaction_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'author_avatar': authorAvatar,
      'reaction_count': reactionCount,
    };
  }
}
