class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
  });

  final String id;
  final String title;
  final String type;
  final String? subtitle;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'content',
      subtitle: json['subtitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'subtitle': subtitle,
    };
  }
}
