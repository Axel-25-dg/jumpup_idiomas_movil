class UserProgressDto {
  final int id;
  final int user;
  final String userEmail;
  final int lesson;
  final String lessonTitle;
  final int lessonXp;
  final String courseTitle;
  final String languageCode;
  final String status;
  final double score;
  final String? completedAt;

  UserProgressDto({
    required this.id,
    required this.user,
    required this.userEmail,
    required this.lesson,
    required this.lessonTitle,
    required this.lessonXp,
    required this.courseTitle,
    required this.languageCode,
    required this.status,
    this.score = 0.0,
    this.completedAt,
  });

  factory UserProgressDto.fromJson(Map<String, dynamic> json) {
    return UserProgressDto(
      id: json['id'] as int,
      user: json['user'] as int,
      userEmail: json['user_email']?.toString() ?? '',
      lesson: json['lesson'] as int,
      lessonTitle: json['lesson_title']?.toString() ?? '',
      lessonXp: json['lesson_xp'] as int? ?? 0,
      courseTitle: json['course_title']?.toString() ?? '',
      languageCode: json['language_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'user_email': userEmail,
        'lesson': lesson,
        'lesson_title': lessonTitle,
        'lesson_xp': lessonXp,
        'course_title': courseTitle,
        'language_code': languageCode,
        'status': status,
        'score': score,
        'completed_at': completedAt,
      };
}
