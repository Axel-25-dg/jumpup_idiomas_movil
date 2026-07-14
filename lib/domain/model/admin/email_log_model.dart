// lib/domain/model/admin/email_log_model.dart
class EmailLog {
  final int id;
  final String uuid;
  final String recipient;
  final String subject;
  final String templateName;
  final String status;
  final String? response;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmailLog({
    required this.id,
    required this.uuid,
    required this.recipient,
    required this.subject,
    required this.templateName,
    required this.status,
    this.response,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmailLog.fromJson(Map<String, dynamic> json) {
    return EmailLog(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid']?.toString() ?? '',
      recipient: json['recipient']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      templateName: json['template_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      response: json['response']?.toString(),
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

  // ✅ Solo datos, sin lógica de UI
  String get statusDisplay {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'sent': return 'Enviado';
      case 'failed': return 'Fallido';
      default: return status;
    }
  }
}