class Classroom {
  final int id;
  final String name;
  final String description;
  final int course;
  final String? courseTitle;
  final String accessCode;
  final bool isActive;

  Classroom({
    required this.id,
    required this.name,
    required this.description,
    required this.course,
    this.courseTitle,
    required this.accessCode,
    required this.isActive,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      course: json['course'] as int,
      courseTitle: json['course_title'] as String?,
      accessCode: json['access_code'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}