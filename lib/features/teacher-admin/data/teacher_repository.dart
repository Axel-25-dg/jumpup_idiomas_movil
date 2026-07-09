import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/core/network/dio_client.dart';
import 'package:jumpup_app/features/teacher-admin/models/admin_stats_model.dart';

//Nuevas implementaciones
import 'package:jumpup_app/features/teacher-admin/models/classroom_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/course_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/enrollment_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/language_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/resource_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/user_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/user_stats.dart';

class TeacherRepository {
  TeacherRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;
  final Dio _dio;

  Future<Classroom> createClassroom({
    required String name,
    required String description,
    required int courseId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/classrooms/',
        data: {
          'name': name,
          'description': description,
          'course': courseId,
          'is_active': true,
        },
      );
      return Classroom.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Error al crear aula', e.response?.statusCode, e);
    }
  }
  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId) async {
  try {
    final response = await _dio.get<List<dynamic>>(
      '/api/classroom-enrollments/',
      queryParameters: {'classroom': classroomId},
    );
    return (response.data ?? [])
        .map((json) => ClassroomEnrollment.fromJson(json as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw ApiException('Error al cargar alumnos', e.response?.statusCode, e);
  }
}

Future<void> removeStudent(int enrollmentId) async {
  try {
    // Si tu backend hace baja lógica, usualmente es DELETE o PATCH.
    // Según tu petición, usaremos DELETE.
    await _dio.delete('/api/classroom-enrollments/$enrollmentId/');
  } on DioException catch (e) {
    throw ApiException('Error al dar de baja al alumno', e.response?.statusCode, e);
  }
}

Future<UserStats> fetchUserStats(String studentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/user-stats/$studentId/');
      // Usamos el factory definido en el modelo de dominio
      return UserStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException('Error al obtener estadísticas del alumno', e.response?.statusCode, e);
    }
  }

/// Envía un nuevo recurso al backend.
  Future<TeacherResource> createResource(Map<String, dynamic> resourceData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/api/resources/', data: resourceData);
      return TeacherResource.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['course']?.toString() ?? 'Error al subir el recurso', 
        e.response?.statusCode, 
        e
      );
    }
    
  }

  /// Obtiene todas las aulas del profesor
  Future<List<Classroom>> fetchAllClassrooms() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/classrooms/');
      return (response.data ?? [])
          .map((json) => Classroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException('Error al cargar las aulas', e.response?.statusCode, e);
    }
  }

  //Exercise

  Future<void> createExercise(Map<String, dynamic> exerciseData) async {
  try {
    await _dio.post('/api/exercises/', data: exerciseData);
  } on DioException catch (e) {
    throw ApiException('Error al crear el ejercicio', e.response?.statusCode, e);
  }
}

//Perfil docente

Future<void> updateProfile({
  required String firstName,
  required String lastName,
  required List<int> languagesLearning,
  required List<int> languagesTeaching,
}) async {
  try {
    // El backend espera 'profile' como un objeto dentro del payload
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'profile': {
        'languages_learning': languagesLearning,
        'languages_teaching': languagesTeaching,
      }
    };
    await _dio.patch('/api/auth/profile/', data: data);
  } on DioException catch (e) {
    throw ApiException('Error al actualizar perfil', e.response?.statusCode, e);
  }
}

//Admin dashboard

Future<AdminStats> getAdminStats() async {
  try {
    final response = await _dio.get('/api/admin-dashboard/');
    return AdminStats.fromJson(response.data);
  } on DioException catch (e) {
    throw ApiException('Error al cargar estadísticas', e.response?.statusCode, e);
  }
}
//Usuarios crud

Future<List<User>> fetchUsers() async {
  final response = await _dio.get('/api/users/');
  // Extraemos la lista de la llave 'results'
  final List data = response.data['results'];
  return data.map((u) => User.fromJson(u)).toList();
}

Future<void> updateUser(int id, Map<String, dynamic> data) async {
  await _dio.put('/api/users/$id/', data: data);
}

//Cursos-Idiomas
// Idiomas
Future<List<Language>> fetchLanguages() async {
  final res = await _dio.get('/api/languages/');
  return (res.data as List).map((i) => Language.fromJson(i)).toList();
}

Future<void> createLanguage(Map<String, dynamic> data) async => await _dio.post('/api/languages/', data: data);

// Cursos
Future<List<Course>> fetchCourses() async {
  final res = await _dio.get('/api/courses/');
  return (res.data as List).map((c) => Course.fromJson(c)).toList();
}

Future<void> createCourse(Map<String, dynamic> data) async => await _dio.post('/api/courses/', data: data);
Future<void> deleteCourse(int id) async => await _dio.delete('/api/courses/$id/');








}

