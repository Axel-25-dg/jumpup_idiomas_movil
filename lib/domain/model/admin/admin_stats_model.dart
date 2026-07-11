class AdminStats {
  final int totalUsers;
  final int teachers;
  final int students;
  final int courses;
  final int classrooms;
  final int subscriptions;
  final int payments;
  final int certificates;

  AdminStats({
    required this.totalUsers,
    required this.teachers,
    required this.students,
    required this.courses,
    required this.classrooms,
    required this.subscriptions,
    required this.payments,
    required this.certificates,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    // El endpoint /dashboard/admin/ devuelve los campos con estos nombres exactos
    return AdminStats(
      totalUsers: json['total_users'] ?? json['users'] ?? 0,
      teachers: json['total_teachers'] ?? json['teachers'] ?? 0,
      students: json['total_students'] ?? json['students'] ?? 0,
      courses: json['total_courses'] ?? json['courses'] ?? 0,
      classrooms: json['total_classrooms'] ?? json['classrooms'] ?? 0,
      subscriptions: json['total_subscriptions'] ?? json['subscriptions'] ?? 0,
      payments: json['total_payments'] ?? json['payments'] ?? 0,
      certificates: json['total_certificates'] ?? json['certificates'] ?? 0,
    );
  }
}
