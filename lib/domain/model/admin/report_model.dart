// lib/domain/model/report_model.dart
class Report {
  final int id;
  final int user;
  final String reportType;
  final String description;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.user,
    required this.reportType,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as int,
        user: json['user'] as int,
        reportType: json['report_type'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'OPEN',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}