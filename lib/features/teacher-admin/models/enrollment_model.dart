
class ClassroomEnrollment {
  final int id;
  final int studentId;
  final String studentEmail;
  final String studentUsername;
  final DateTime enrolledAt;
  final bool isActive;

  ClassroomEnrollment({
    required this.id,
    required this.studentId,
    required this.studentEmail,
    required this.studentUsername,
    required this.enrolledAt,
    required this.isActive,
  });

  factory ClassroomEnrollment.fromJson(Map<String, dynamic> json) {
    return ClassroomEnrollment(
      id: json['id'] as int,
      studentId: json['student'] as int,
      studentEmail: json['student_email'] as String,
      studentUsername: json['student_username'] as String,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      isActive: json['is_active'] as bool,
    );
  }
}