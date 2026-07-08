class SocialPost {
  const SocialPost({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      comments: int.tryParse(json['comments']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }
}
