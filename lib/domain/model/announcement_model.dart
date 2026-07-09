class Announcement {
  final int id;
  final String title;
  final String content;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    startDate: DateTime.parse(json['start_date']),
    endDate: DateTime.parse(json['end_date']),
    isActive: json['is_active'],
  );
}
