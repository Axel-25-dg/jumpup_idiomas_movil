/// Representa el material didáctico del profesor.
class TeacherResource {
  final int id;
  final int course;
  final int? lesson;
  final String title;
  final String description;
  final String resourceType;
  final String? fileUrl;
  final bool isPublic;

  TeacherResource({
    required this.id,
    required this.course,
    this.lesson,
    required this.title,
    required this.description,
    required this.resourceType,
    this.fileUrl,
    required this.isPublic,
  });

  factory TeacherResource.fromJson(Map<String, dynamic> json) {
    return TeacherResource(
      id: json['id'] as int,
      course: json['course'] as int,
      lesson: json['lesson'] as int?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      resourceType: json['resource_type'] as String,
      fileUrl: json['file_url'] as String?,
      isPublic: json['is_public'] as bool,
    );
  }
}