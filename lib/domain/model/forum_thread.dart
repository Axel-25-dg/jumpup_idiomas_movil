class ForumThread {
  const ForumThread({
    required this.id,
    required this.title,
    required this.authorName,
    required this.language,
    this.replies = 0,
    this.isPinned = false,
    this.body,
    this.createdAt,
    this.authorAvatar,
  });

  final String id;
  final String title;
  final String authorName;
  final String language;
  final int replies;
  final bool isPinned;
  final String? body;
  final DateTime? createdAt;
  final String? authorAvatar;

  factory ForumThread.fromJson(Map<String, dynamic> json) {
    Object? author = json['author'];
    String authorName = '';
    String? authorAvatar;
    if (author is Map) {
      authorName = author['name']?.toString() ??
          author['username']?.toString() ??
          author['full_name']?.toString() ??
          '';
      authorAvatar = author['avatar']?.toString() ??
          author['avatar_url']?.toString();
    }
    return ForumThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      authorName: authorName.isNotEmpty
          ? authorName
          : json['author_name']?.toString() ??
              json['authorName']?.toString() ??
              'Usuario',
      language: json['language']?.toString() ??
          json['language_name']?.toString() ??
          '',
      replies: int.tryParse(json['posts_count']?.toString() ?? '') ??
          int.tryParse(json['replies']?.toString() ?? '0') ??
          0,
      isPinned: json['is_pinned'] == true || json['isPinned'] == true,
      body: json['body']?.toString() ?? json['description']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      authorAvatar: authorAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authorName': authorName,
      'language': language,
      'replies': replies,
      'isPinned': isPinned,
      'body': body,
      'createdAt': createdAt?.toIso8601String(),
      'authorAvatar': authorAvatar,
    };
  }
}
