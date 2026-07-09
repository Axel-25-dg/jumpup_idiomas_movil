import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/core/network/dio_client.dart';

//Nuevas implementaciones
import 'package:jumpup_app/features/teacher-admin/models/classroom_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/enrollment_model.dart';
import 'package:jumpup_app/features/teacher-admin/models/resource_model.dart';
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


}