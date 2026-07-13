class ClassroomJoinRequest {
  final int id;
  final int studentId;
  final String studentEmail;
  final String studentUsername;
  final String classroomName;
  final String? message;
  final String status;
  final DateTime createdAt;

  ClassroomJoinRequest({
    required this.id,
    required this.studentId,
    required this.studentEmail,
    required this.studentUsername,
    required this.classroomName,
    this.message,
    required this.status,
    required this.createdAt,
  });

  factory ClassroomJoinRequest.fromJson(Map<String, dynamic> json) {
    return ClassroomJoinRequest(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      studentId: int.tryParse(json['student']?.toString() ?? json['student_id']?.toString() ?? '') ?? 0,
      studentEmail: json['student_email']?.toString() ?? '',
      studentUsername: json['student_username']?.toString() ?? '',
      classroomName: json['classroom_name']?.toString() ?? '',
      message: json['message']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
