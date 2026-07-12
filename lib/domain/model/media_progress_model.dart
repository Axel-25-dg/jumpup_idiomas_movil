class MediaProgressModel {
  const MediaProgressModel({
    required this.id,
    required this.lesson,
    required this.positionSeconds,
    required this.durationSeconds,
    this.completed = false,
    this.updatedAt,
    this.lessonTitle,
    this.percentage,
    this.lastWatched,
  });

  final int id;
  final int lesson;
  final String? lessonTitle;
  final int positionSeconds;
  final int durationSeconds;
  final bool completed;
  final double? percentage;
  final DateTime? lastWatched;
  final DateTime? updatedAt;

  double get progress =>
      durationSeconds > 0 ? positionSeconds / durationSeconds : 0.0;

  factory MediaProgressModel.fromJson(Map<String, dynamic> json) {
    return MediaProgressModel(
      id: json['id'] as int,
      lesson: json['lesson'] as int,
      lessonTitle: json['lesson_title']?.toString(),
      positionSeconds: json['position_sec'] as int? ?? json['position_seconds'] as int? ?? 0,
      durationSeconds: json['duration_sec'] as int? ?? json['duration_seconds'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      percentage: (json['percentage'] as num?)?.toDouble(),
      lastWatched: json['last_watched'] != null
          ? DateTime.tryParse(json['last_watched'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'lesson': lesson,
        'position_sec': positionSeconds,
        'duration_sec': durationSeconds,
        'completed': completed,
      };
}
