class LiveSession {
  const LiveSession({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.hostName = '',
    this.teacherEmail,
    this.meetingUrl,
    this.courseId,
    this.startsAt,
    this.participantCount = 0,
    this.maxStudents = 0,
    this.hostAvatar,
  });

  final int id;
  final String title;
  final String status;
  final String? description;
  final String hostName;
  final String? teacherEmail;
  final String? meetingUrl;
  final int? courseId;
  final DateTime? startsAt;
  final int participantCount;
  final int maxStudents;
  final String? hostAvatar;

  String get statusLabel {
    switch (status) {
      case 'live':
      case 'active':
      case 'started':
        return 'En vivo';
      case 'scheduled':
      case 'pending':
        return 'Programada';
      case 'ended':
      case 'finished':
      case 'completed':
        return 'Finalizada';
      default:
        return status;
    }
  }

  bool get isLive => status == 'live' || status == 'active' || status == 'started';
  bool get isScheduled => status == 'scheduled' || status == 'pending';
  bool get isEnded => status == 'ended' || status == 'finished' || status == 'completed';

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    Object? host = json['host'] ?? json['teacher'];
    String hostName = '';
    String? hostAvatar;
    String? teacherEmail;
    if (host is Map) {
      hostName = host['name']?.toString() ??
          host['username']?.toString() ??
          host['full_name']?.toString() ??
          '';
      hostAvatar = host['avatar']?.toString() ?? host['avatar_url']?.toString();
      teacherEmail = host['email']?.toString();
    }
    return LiveSession(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'scheduled',
      description: json['description']?.toString(),
      hostName: hostName.isNotEmpty
          ? hostName
          : json['host_name']?.toString() ??
              json['teacher_name']?.toString() ??
              'Instructor',
      teacherEmail: teacherEmail ?? json['teacher_email']?.toString(),
      meetingUrl: json['meeting_url']?.toString(),
      courseId: json['course'] as int?,
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '') ??
          DateTime.tryParse(json['scheduled_at']?.toString() ?? ''),
      participantCount: json['participants_count'] as int? ??
          json['participant_count'] as int? ?? 0,
      maxStudents: json['max_students'] as int? ?? 0,
      hostAvatar: hostAvatar,
    );
  }
}
