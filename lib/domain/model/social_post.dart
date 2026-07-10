class SocialPost {
  const SocialPost({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.postType = 'general',
    this.imageUrl,
    this.authorAvatar,
  });

  final int id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int reactionCount;
  final int commentCount;
  final bool isLiked;
  final String postType;
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
      id: json['id'] as int? ?? 0,
      authorName: authorName.isNotEmpty
          ? authorName
          : json['author_name']?.toString() ??
              json['author_username']?.toString() ??
              json['authorName']?.toString() ??
              'Usuario',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      reactionCount: json['reaction_count'] as int? ??
          int.tryParse(json['likes_count']?.toString() ?? '') ??
          int.tryParse(json['likes']?.toString() ?? '0') ??
          0,
      commentCount: json['comment_count'] as int? ??
          int.tryParse(json['comments_count']?.toString() ?? '') ??
          int.tryParse(json['comments']?.toString() ?? '0') ??
          0,
      isLiked: json['is_liked'] == true || json['isLiked'] == true,
      postType: json['post_type']?.toString() ?? 'general',
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString(),
      authorAvatar: authorAvatar,
    );
  }

  get likes => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'reaction_count': reactionCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'post_type': postType,
      'image_url': imageUrl,
      'authorAvatar': authorAvatar,
    };
  }

  SocialPost copyWith({
    int? id,
    String? authorName,
    String? content,
    DateTime? createdAt,
    int? reactionCount,
    int? commentCount,
    bool? isLiked,
    String? postType,
    String? imageUrl,
    String? authorAvatar,
  }) {
    return SocialPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      postType: postType ?? this.postType,
      imageUrl: imageUrl ?? this.imageUrl,
      authorAvatar: authorAvatar ?? this.authorAvatar,
    );
  }
}
