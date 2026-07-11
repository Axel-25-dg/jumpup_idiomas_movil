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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      studentId: int.tryParse(json['student']?.toString() ?? '') ?? 0,
      studentEmail: json['student_email']?.toString() ?? '',
      studentUsername: json['student_username']?.toString() ?? '',
      enrolledAt: DateTime.tryParse(json['enrolled_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['is_active'] != false,
    );
  }
}
