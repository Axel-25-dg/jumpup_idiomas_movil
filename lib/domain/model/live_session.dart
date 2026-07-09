class LiveSession {
  const LiveSession({
    required this.id,
    required this.title,
    required this.hostName,
    required this.startsAt,
    required this.status,
    this.description,
    this.participantCount = 0,
    this.hostAvatar,
  });

  final String id;
  final String title;
  final String hostName;
  final DateTime startsAt;
  final String status;
  final String? description;
  final int participantCount;
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
        return 'Programada';
    }
  }

  bool get isLive => status == 'live' || status == 'active' || status == 'started';
  bool get isScheduled => status == 'scheduled' || status == 'pending';
  bool get isEnded => status == 'ended' || status == 'finished' || status == 'completed';

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    Object? host = json['host'] ?? json['teacher'];
    String hostName = '';
    String? hostAvatar;
    if (host is Map) {
      hostName = host['name']?.toString() ??
          host['username']?.toString() ??
          host['full_name']?.toString() ??
          '';
      hostAvatar = host['avatar']?.toString() ?? host['avatar_url']?.toString();
    }
    return LiveSession(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      hostName: hostName.isNotEmpty
          ? hostName
          : json['host_name']?.toString() ??
              json['hostName']?.toString() ??
              json['teacher_name']?.toString() ??
              'Instructor',
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? '') ??
          DateTime.tryParse(json['startsAt']?.toString() ?? '') ??
          DateTime.tryParse(json['start_time']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'scheduled',
      description: json['description']?.toString(),
      participantCount: int.tryParse(json['participants_count']?.toString() ?? '') ??
          int.tryParse(json['participant_count']?.toString() ?? '0') ??
          0,
      hostAvatar: hostAvatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hostName': hostName,
      'startsAt': startsAt.toIso8601String(),
      'status': status,
      'description': description,
      'participantCount': participantCount,
      'hostAvatar': hostAvatar,
    };
  }
}
