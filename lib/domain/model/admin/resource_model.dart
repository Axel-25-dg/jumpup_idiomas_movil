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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }

    int courseId = 0;
    final courseVal = json['course'];
    if (courseVal is Map) {
      courseId = toInt(courseVal['id'] ?? courseVal['course_id']);
    } else {
      courseId = toInt(courseVal);
    }

    int? lessonId;
    final lessonVal = json['lesson'];
    if (lessonVal is Map) {
      lessonId = toInt(lessonVal['id'] ?? lessonVal['lesson_id']);
    } else if (lessonVal != null) {
      lessonId = toInt(lessonVal);
    }

    return TeacherResource(
      id: toInt(json['id']),
      course: courseId,
      lesson: lessonId,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      resourceType: json['resource_type']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? json['file']?.toString(),
      isPublic: json['is_public'] == true || json['is_public'] == 1 || json['is_public'] == 'true',
    );
  }
}
