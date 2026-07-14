// lib/domain/model/admin/broadcast_email_model.dart
class BroadcastEmail {
  final int id;
  final String subject;
  final String message;
  final String audience;
  final int? targetCourse;
  final String? targetCourseTitle;
  final String? actionUrl;
  final String? actionText;
  final int sentCount;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BroadcastEmail({
    required this.id,
    required this.subject,
    required this.message,
    required this.audience,
    this.targetCourse,
    this.targetCourseTitle,
    this.actionUrl,
    this.actionText,
    required this.sentCount,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BroadcastEmail.fromJson(Map<String, dynamic> json) {
    return BroadcastEmail(
      id: json['id'] as int? ?? 0,
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      audience: json['audience']?.toString() ?? 'all',
      targetCourse: json['target_course'] as int?,
      targetCourseTitle: json['target_course_title']?.toString(),
      actionUrl: json['action_url']?.toString(),
      actionText: json['action_text']?.toString(),
      sentCount: json['sent_count'] as int? ?? 0,
      isSent: json['is_sent'] as bool? ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'message': message,
      'audience': audience,
      if (targetCourse != null) 'target_course': targetCourse,
      if (actionUrl != null && actionUrl!.isNotEmpty) 'action_url': actionUrl,
      if (actionText != null && actionText!.isNotEmpty) 'action_text': actionText,
    };
  }

  // ✅ Solo datos, sin lógica de UI
  String get audienceDisplay {
    switch (audience) {
      case 'all': return 'Todos los usuarios';
      case 'students': return 'Estudiantes';
      case 'teachers': return 'Profesores';
      case 'course': return targetCourseTitle != null 
          ? 'Curso: $targetCourseTitle' 
          : 'Curso específico';
      default: return audience;
    }
  }

  String get statusDisplay => isSent ? 'Enviado' : 'Pendiente';
}