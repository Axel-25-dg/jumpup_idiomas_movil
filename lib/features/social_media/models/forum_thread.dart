class ForumThread {
  const ForumThread({
    required this.id,
    required this.title,
    required this.authorName,
    required this.language,
    this.replies = 0,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String authorName;
  final String language;
  final int replies;
  final bool isPinned;

  factory ForumThread.fromJson(Map<String, dynamic> json) {
    return ForumThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      replies: int.tryParse(json['replies']?.toString() ?? '0') ?? 0,
      isPinned: json['isPinned'] == true,
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
    };
  }
}
