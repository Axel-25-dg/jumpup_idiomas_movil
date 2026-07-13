class ClassroomJoinRequest {
  final int id;
  final String studentEmail;
  final int studentId;
  final String classroomName;
  final String message;
  final String status;
  final DateTime createdAt;

  ClassroomJoinRequest({
    required this.id,
    required this.studentEmail,
    required this.studentId,
    required this.classroomName,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory ClassroomJoinRequest.fromJson(Map<String, dynamic> json) {
    return ClassroomJoinRequest(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      studentEmail: json['student_email']?.toString() ?? '',
      studentId: int.tryParse(json['student_id']?.toString() ?? '') ?? 0,
      classroomName: json['classroom_name']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
