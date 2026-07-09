// Modelos del módulo de Clases Virtuales y Certificados
// Cubre: VirtualClass, VirtualClassRegistration, Certificate

// ─── VirtualClass ─────────────────────────────────────────────────────────────

class VirtualClassModel {
  const VirtualClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.scheduledAt,
    required this.durationMinutes,
    this.meetingUrl,
    required this.maxParticipants,
    this.currentParticipants = 0,
    required this.status,
  });

  final int id;
  final String title;
  final String description;
  final String instructorName;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? meetingUrl;
  final int maxParticipants;
  final int currentParticipants;
  final String status; // 'scheduled' | 'ongoing' | 'completed' | 'cancelled'

  bool get isFull => currentParticipants >= maxParticipants;
  bool get isScheduled => status == 'scheduled';
  bool get isOngoing => status == 'ongoing';
  bool get canJoin =>
      isOngoing ||
      (isScheduled && scheduledAt.difference(DateTime.now()).inMinutes <= 15);

  factory VirtualClassModel.fromJson(Map<String, dynamic> json) {
    return VirtualClassModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      instructorName: json['instructor_name']?.toString() ?? '',
      scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ??
          DateTime.now(),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      meetingUrl: json['meeting_url']?.toString(),
      maxParticipants: json['max_participants'] as int? ?? 50,
      currentParticipants: json['current_participants'] as int? ?? 0,
      status: json['status']?.toString() ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'instructor_name': instructorName,
        'scheduled_at': scheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        'meeting_url': meetingUrl,
        'max_participants': maxParticipants,
        'current_participants': currentParticipants,
        'status': status,
      };
}

// ─── VirtualClassRegistration ──────────────────────────────────────────────────

class VirtualClassRegistrationModel {
  const VirtualClassRegistrationModel({
    required this.id,
    required this.virtualClass,
    required this.registeredAt,
    required this.status,
  });

  final int id;
  final VirtualClassModel virtualClass;
  final DateTime registeredAt;
  final String status; // 'registered' | 'attended' | 'missed'

  factory VirtualClassRegistrationModel.fromJson(Map<String, dynamic> json) {
    return VirtualClassRegistrationModel(
      id: json['id'] as int,
      virtualClass: VirtualClassModel.fromJson(
          json['virtual_class'] as Map<String, dynamic>),
      registeredAt:
          DateTime.tryParse(json['registered_at']?.toString() ?? '') ??
              DateTime.now(),
      status: json['status']?.toString() ?? 'registered',
    );
  }
}

// ─── Certificate ──────────────────────────────────────────────────────────────

class CertificateModel {
  const CertificateModel({
    required this.id,
    required this.courseName,
    required this.issueDate,
    required this.certificateUrl,
    required this.code,
    this.score,
  });

  final int id;
  final String courseName;
  final DateTime issueDate;
  final String certificateUrl;
  final String code;
  final double? score;

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as int,
      courseName: json['course_name']?.toString() ?? '',
      issueDate: DateTime.tryParse(json['issue_date']?.toString() ?? '') ??
          DateTime.now(),
      certificateUrl: json['certificate_url']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_name': courseName,
        'issue_date': issueDate.toIso8601String(),
        'certificate_url': certificateUrl,
        'code': code,
        'score': score,
      };
}
