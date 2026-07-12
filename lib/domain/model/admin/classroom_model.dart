// Modelo de Aula Virtual (Classroom)
// Endpoint: GET /api/classrooms/mine/ → lista de aulas del estudiante
// Endpoint: POST /api/classrooms/join/ → unirse con access_code

class ClassroomModel {
  const ClassroomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.accessCode,
    required this.teacherName,
    required this.isActive,
    required this.createdAt,
    this.studentsCount = 0,
    this.courseName,
    this.courseId,
  });

  final int id;
  final String name;
  final String description;
  final String accessCode;
  final String teacherName;
  final bool isActive;
  final DateTime createdAt;
  final int studentsCount;
  final String? courseName;
  final int? courseId;

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    // Soporte para respuesta plana o con enrollment anidado
    final classroom = json['classroom'] is Map<String, dynamic>
        ? json['classroom'] as Map<String, dynamic>
        : json;

    // El teacher puede venir como objeto o como string
    String teacherName = '';
    final teacher = classroom['teacher'];
    if (teacher is Map) {
      teacherName = teacher['full_name']?.toString() ??
          teacher['username']?.toString() ??
          teacher['email']?.toString() ??
          '';
    } else if (teacher is String) {
      teacherName = teacher;
    }
    if (teacherName.isEmpty) {
      teacherName = classroom['teacher_name']?.toString() ?? 'Docente';
    }

    int? courseId;
    final courseVal = classroom['course'];
    if (courseVal is int) {
      courseId = courseVal;
    } else if (courseVal != null) {
      courseId = int.tryParse(courseVal.toString());
    }

    return ClassroomModel(
      id: (classroom['id'] ?? 0) as int,
      name: classroom['name']?.toString() ?? '',
      description: classroom['description']?.toString() ?? '',
      accessCode: classroom['access_code']?.toString() ?? '',
      teacherName: teacherName,
      isActive: classroom['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(
              classroom['created_at']?.toString() ??
                  classroom['date_joined']?.toString() ??
                  '') ??
          DateTime.now(),
      studentsCount: classroom['total_students'] as int? ??
          classroom['students_count'] as int? ??
          classroom['enrolled_count'] as int? ??
          0,
      courseName: classroom['course_name']?.toString() ??
          classroom['course']?.toString(),
      courseId: courseId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'access_code': accessCode,
        'teacher_name': teacherName,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'students_count': studentsCount,
        'course_name': courseName,
        'course': courseId,
      };
}
