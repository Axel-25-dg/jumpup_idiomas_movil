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
        id: json['id'],
        user: json['user'],
        reportType: json['report_type'],
        description: json['description'],
        status: json['status'], // 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'
        createdAt: DateTime.parse(json['created_at']),
      );
}
