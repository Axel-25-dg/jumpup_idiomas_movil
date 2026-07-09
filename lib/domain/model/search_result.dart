class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String type;
  final String? subtitle;
  final String? imageUrl;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? json['model_type']?.toString() ?? 'content',
      subtitle: json['subtitle']?.toString() ??
          json['description']?.toString() ??
          json['snippet']?.toString(),
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['thumbnail']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
    };
  }
}
