/// Modelo de estadísticas del profesor obtenido desde GET /dashboard/teacher/
class TeacherStats {
  final int totalAulas;
  final int totalAlumnos;
  final int totalCursos;
  final int sesionesActivas;
  final int recursosPendientes;

  TeacherStats({
    required this.totalAulas,
    required this.totalAlumnos,
    this.totalCursos = 0,
    this.sesionesActivas = 0,
    this.recursosPendientes = 0,
  });

  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    return TeacherStats(
      totalAulas: json['total_classrooms'] ??
          json['classrooms'] ??
          json['total_aulas'] ??
          0,
      totalAlumnos: json['total_students'] ??
          json['students'] ??
          json['total_alumnos'] ??
          0,
      totalCursos: json['total_courses'] ?? json['courses'] ?? 0,
      sesionesActivas: json['active_sessions'] ??
          json['live_sessions'] ??
          json['sesiones_activas'] ??
          0,
      recursosPendientes:
          json['pending_resources'] ?? json['recursos_pendientes'] ?? 0,
    );
  }
}
