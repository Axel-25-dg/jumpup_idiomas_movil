class Classroom {
  final int id;
  final String name;
  final int totalStudents;
  final String description;
  final int course;
  final String? courseTitle;
  final String accessCode;
  final bool isActive;

  Classroom({
    required this.id,
    required this.name,
    required this.totalStudents,
    required this.description,
    required this.course,
    this.courseTitle,
    required this.accessCode,
    required this.isActive,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      totalStudents: json['total_students'] ?? 0,
      description: json['description']?.toString() ?? '',
      course: int.tryParse(json['course']?.toString() ?? '') ?? 0,
      courseTitle: json['course_title']?.toString(),
      accessCode: json['access_code']?.toString() ?? '',
      isActive: json['is_active'] == true,
    );
  }
}
