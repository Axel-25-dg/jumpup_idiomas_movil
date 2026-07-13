class ForumThread {
  const ForumThread({
    required this.id,
    required this.title,
    required this.body,
    this.categoryId = 0,
    this.categoryName = '',
    this.authorName = '',
    this.views = 0,
    this.postCount = 0,
    this.isPinned = false,
    this.isClosed = false,
    this.createdAt,
    this.authorAvatar,
  });

  final int id;
  final String title;
  final String body;
  final int categoryId;
  final String categoryName;
  final String authorName;
  final int views;
  final int postCount;
  final bool isPinned;
  final bool isClosed;
  final DateTime? createdAt;
  final String? authorAvatar;

  factory ForumThread.fromJson(Map<String, dynamic> json) {
    // Manejo robusto del Autor
    Object? author = json['author'];
    String authorName = '';
    String? authorAvatar;
    if (author is Map) {
      authorName = author['full_name']?.toString() ??
          author['name']?.toString() ??
          author['username']?.toString() ??
          author['email']?.toString() ??
          '';
      authorAvatar = author['avatar']?.toString() ??
          author['avatar_url']?.toString();
    } else if (author != null) {
      authorName = author.toString();
    }

    // Manejo robusto de la Categoría
    Object? cat = json['category'];
    int categoryId = 0;
    String categoryName = '';
    if (cat is Map) {
      categoryId = cat['id'] as int? ?? 0;
      categoryName = cat['name']?.toString() ?? '';
    } else if (cat is int) {
      categoryId = cat;
      categoryName = json['category_name']?.toString() ?? '';
    } else if (cat != null) {
      categoryId = int.tryParse(cat.toString()) ?? 0;
    }

    return ForumThread(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['description']?.toString() ?? '',
      categoryId: categoryId,
      categoryName: categoryName,
      authorName: authorName.isNotEmpty
          ? authorName
          : json['author_name']?.toString() ??
              json['author_username']?.toString() ??
              'Usuario',
      views: json['views'] as int? ?? 0,
      postCount: json['post_count'] as int? ??
          int.tryParse(json['replies']?.toString() ?? '0') ??
          0,
      isPinned: json['is_pinned'] == true || json['is_pinned'] == 1 || json['isPinned'] == true,
      isClosed: json['is_closed'] == true || json['is_closed'] == 1 || json['isClosed'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      authorAvatar: authorAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': categoryId,
      'authorName': authorName,
      'views': views,
      'post_count': postCount,
      'is_pinned': isPinned,
      'is_closed': isClosed,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ForumCategory {
  const ForumCategory({
    required this.id,
    required this.name,
    this.threadCount = 0,
  });

  final int id;
  final String name;
  final int threadCount;

  factory ForumCategory.fromJson(Map<String, dynamic> json) {
    return ForumCategory(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      threadCount: json['thread_count'] as int? ?? 0,
    );
  }
}

class ForumPost {
  const ForumPost({
    required this.id,
    required this.body,
    required this.authorName,
    this.threadId = 0,
    this.parentId,
    this.reactionCount = 0,
    this.isDeleted = false,
    this.createdAt,
  });

  final int id;
  final String body;
  final String authorName;
  final int threadId;
  final int? parentId;
  final int reactionCount;
  final bool isDeleted;
  final DateTime? createdAt;

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    // Manejo robusto del Autor (puede ser un Map o un String/ID)
    Object? author = json['author'];
    String authorName = 'Usuario';
    if (author is Map) {
      authorName = author['full_name']?.toString() ??
          author['name']?.toString() ??
          author['username']?.toString() ??
          author['email']?.toString() ??
          'Usuario';
    } else if (author != null) {
      authorName = author.toString();
    }

    // Manejo robusto del Hilo (puede venir como ID o como Objeto)
    Object? thread = json['thread'];
    int threadId = 0;
    if (thread is Map) {
      threadId = thread['id'] as int? ?? 0;
    } else if (thread is int) {
      threadId = thread;
    } else if (thread != null) {
      threadId = int.tryParse(thread.toString()) ?? 0;
    }

    // Manejo robusto del Parent (para respuestas anidadas)
    Object? parent = json['parent'];
    int? parentId;
    if (parent is Map) {
      parentId = parent['id'] as int?;
    } else if (parent is int) {
      parentId = parent;
    }

    return ForumPost(
      id: json['id'] as int? ?? 0,
      body: json['body']?.toString() ?? '',
      authorName: authorName.isNotEmpty
          ? authorName
          : json['author_name']?.toString() ?? 'Usuario',
      threadId: threadId,
      parentId: parentId,
      reactionCount: json['reaction_count'] as int? ?? 0,
      isDeleted: json['is_deleted'] == true || json['is_deleted'] == 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
