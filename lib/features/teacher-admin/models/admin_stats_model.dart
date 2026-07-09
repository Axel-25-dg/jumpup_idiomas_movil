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
    return AdminStats(
      totalUsers: json['users'] ?? 0,
      teachers: json['teachers'] ?? 0,
      students: json['students'] ?? 0,
      courses: json['courses'] ?? 0,
      classrooms: json['classrooms'] ?? 0,
      subscriptions: json['subscriptions'] ?? 0,
      payments: json['payments'] ?? 0,
      certificates: json['certificates'] ?? 0,
    );
  }
}