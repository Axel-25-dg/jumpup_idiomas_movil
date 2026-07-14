// lib/domain/model/certificate_model.dart
class Certificate {
  final int? id;
  final int student;
  final String? studentEmail;
  final int? issuedBy;
  final String? issuedByEmail;
  final String level;
  final String? levelDisplay;
  final String title;
  final String? description;
  final String? certificateCode;
  final String status;
  final String? statusDisplay;
  final DateTime? issuedAt;
  final DateTime? createdAt;

  Certificate({
    this.id,
    required this.student,
    this.studentEmail,
    this.issuedBy,
    this.issuedByEmail,
    required this.level,
    this.levelDisplay,
    required this.title,
    this.description,
    this.certificateCode,
    required this.status,
    this.statusDisplay,
    this.issuedAt,
    this.createdAt,
  });

  // Para POST (creación) - respuesta sin id
  factory Certificate.fromCreateJson(Map<String, dynamic> json) {
    return Certificate(
      id: null,
      student: json['student'] as int,
      studentEmail: null,
      issuedBy: null,
      issuedByEmail: null,
      level: json['level'] as String,
      levelDisplay: null,
      title: json['title'] as String,
      description: json['description'] as String?,
      certificateCode: null,
      status: json['status'] as String,
      statusDisplay: null,
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : null,
      createdAt: null,
    );
  }

  // Para GET (listar/detalle) - respuesta con id y todos los campos
  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int,
      student: json['student'] as int,
      studentEmail: json['student_email'] as String?,
      issuedBy: json['issued_by'] as int?,
      issuedByEmail: json['issued_by_email'] as String?,
      level: json['level'] as String,
      levelDisplay: json['level_display'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      certificateCode: json['certificate_code'] as String?,
      status: json['status'] as String,
      statusDisplay: json['status_display'] as String?,
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  // Helper para saber si el certificado está emitido
  bool get isIssued => status == 'issued';
  bool get isPending => status == 'pending';
  bool get isRevoked => status == 'revoked';
}