// admin_course_model.dart
class Course {
  final int id;
  final int languageId;
  final String languageName;
  final String title;
  final String description;
  final String difficultyLevel;
  final String imageUrl;
  final String? teacherName;
  final String? teacherEmail;

  Course(
      {required this.id,
      required this.languageId,
      required this.languageName,
      required this.title,
      required this.description,
      required this.difficultyLevel,
      required this.imageUrl,
      this.teacherName,
      this.teacherEmail});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        languageId: int.tryParse(json['language']?.toString() ?? '') ?? 0,
        languageName: json['language_name']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        difficultyLevel: json['difficulty_level']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        teacherName: json['teacher_name']?.toString(),
        teacherEmail: json['teacher_email']?.toString(),
      );
}
