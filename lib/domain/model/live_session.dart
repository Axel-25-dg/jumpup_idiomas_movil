class LiveSession {
  const LiveSession({
    required this.id,
    required this.title,
    required this.hostName,
    required this.startsAt,
    required this.status,
  });

  final String id;
  final String title;
  final String hostName;
  final DateTime startsAt;
  final String status;

  String get statusLabel {
    switch (status) {
      case 'live':
        return 'En vivo';
      case 'scheduled':
        return 'Programada';
      default:
        return 'Finalizada';
    }
  }

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? '',
      startsAt: DateTime.tryParse(json['startsAt']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hostName': hostName,
      'startsAt': startsAt.toIso8601String(),
      'status': status,
    };
  }
}
