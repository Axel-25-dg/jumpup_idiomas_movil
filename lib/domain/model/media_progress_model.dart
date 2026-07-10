class MediaProgressModel {
  const MediaProgressModel({
    required this.id,
    required this.lesson,
    required this.positionSeconds,
    required this.durationSeconds,
    this.completed = false,
    this.updatedAt,
  });

  final int id;
  final int lesson;
  final int positionSeconds;
  final int durationSeconds;
  final bool completed;
  final DateTime? updatedAt;

  double get progress =>
      durationSeconds > 0 ? positionSeconds / durationSeconds : 0.0;

  factory MediaProgressModel.fromJson(Map<String, dynamic> json) {
    return MediaProgressModel(
      id: json['id'] as int,
      lesson: json['lesson'] as int,
      positionSeconds: json['position_seconds'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'lesson': lesson,
        'position_seconds': positionSeconds,
        'duration_seconds': durationSeconds,
        'completed': completed,
      };
}
