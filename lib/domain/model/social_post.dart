class SocialPost {
  const SocialPost({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.imageUrl,
    this.authorAvatar,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;
  final String? imageUrl;
  final String? authorAvatar;

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    Object? author = json['author'];
    String authorName = '';
    String? authorAvatar;
    if (author is Map) {
      authorName = author['name']?.toString() ??
          author['username']?.toString() ??
          author['full_name']?.toString() ??
          '';
      authorAvatar = author['avatar']?.toString() ??
          author['avatar_url']?.toString() ??
          author['profile_picture']?.toString();
    }
    return SocialPost(
      id: json['id']?.toString() ?? '',
      authorName: authorName.isNotEmpty
          ? authorName
          : json['author_name']?.toString() ??
              json['authorName']?.toString() ??
              'Usuario',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      likes: int.tryParse(json['likes_count']?.toString() ?? '') ??
          int.tryParse(json['likes']?.toString() ?? '0') ??
          0,
      comments: int.tryParse(json['comments_count']?.toString() ?? '') ??
          int.tryParse(json['comments']?.toString() ?? '0') ??
          0,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString(),
      authorAvatar: authorAvatar,
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
      'isLiked': isLiked,
      'imageUrl': imageUrl,
      'authorAvatar': authorAvatar,
    };
  }

  SocialPost copyWith({
    String? id,
    String? authorName,
    String? content,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLiked,
    String? imageUrl,
    String? authorAvatar,
  }) {
    return SocialPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      imageUrl: imageUrl ?? this.imageUrl,
      authorAvatar: authorAvatar ?? this.authorAvatar,
    );
  }
}
