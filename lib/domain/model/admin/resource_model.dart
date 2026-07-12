// lib/domain/model/resource_model.dart
class TeacherResource {
  final int id;
  final int teacher;
  final String teacherEmail;
  final int course;
  final String courseTitle;
  final int? lesson;
  final String? lessonTitle;
  final String title;
  final String description;
  final String resourceType;
  final String resourceTypeDisplay;
  final String? fileUrl;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeacherResource({
    required this.id,
    required this.teacher,
    required this.teacherEmail,
    required this.course,
    required this.courseTitle,
    this.lesson,
    this.lessonTitle,
    required this.title,
    required this.description,
    required this.resourceType,
    required this.resourceTypeDisplay,
    this.fileUrl,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherResource.fromJson(Map<String, dynamic> json) {
    return TeacherResource(
      id: json['id'] as int,
      teacher: json['teacher'] as int,
      teacherEmail: json['teacher_email'] as String? ?? '',
      course: json['course'] as int,
      courseTitle: json['course_title'] as String? ?? '',
      lesson: json['lesson'] as int?,
      lessonTitle: json['lesson_title'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      resourceType: json['resource_type'] as String,
      resourceTypeDisplay: json['resource_type_display'] as String? ?? json['resource_type'] as String,
      fileUrl: json['file_url'] as String?,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}