class CourseDto {
  final int id;
  final int language;
  final String languageName;
  final String title;
  final String description;
  final String difficultyLevel;
  final String? imageUrl;
  final String? teacherName;
  final String? teacherEmail;
  final int modulesCount;
  final int lessonsCount;
  final int totalXpReward;

  CourseDto({
    required this.id,
    required this.language,
    required this.languageName,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    this.imageUrl,
    this.teacherName,
    this.teacherEmail,
    this.modulesCount = 0,
    this.lessonsCount = 0,
    this.totalXpReward = 0,
  });

  factory CourseDto.fromJson(Map<String, dynamic> json) {
    return CourseDto(
      id: json['id'] as int,
      language: json['language'] as int,
      languageName: json['language_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      teacherName: json['teacher_name']?.toString(),
      teacherEmail: json['teacher_email']?.toString(),
      modulesCount: json['modules_count'] as int? ?? 0,
      lessonsCount: json['lessons_count'] as int? ?? 0,
      totalXpReward: json['total_xp_reward'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'language_name': languageName,
        'title': title,
        'description': description,
        'difficulty_level': difficultyLevel,
        'image_url': imageUrl,
        'teacher_name': teacherName,
        'teacher_email': teacherEmail,
        'modules_count': modulesCount,
        'lessons_count': lessonsCount,
        'total_xp_reward': totalXpReward,
      };
}
