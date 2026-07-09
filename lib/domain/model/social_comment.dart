class SocialComment {
  const SocialComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.authorAvatar,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final String? authorAvatar;

  factory SocialComment.fromJson(Map<String, dynamic> json) {
    return SocialComment(
      id: json['id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ??
          json['authorName']?.toString() ??
          json['author']?.toString() ??
          'Usuario',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      authorAvatar: json['author_avatar']?.toString() ??
          json['authorAvatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'authorAvatar': authorAvatar,
    };
  }
}
