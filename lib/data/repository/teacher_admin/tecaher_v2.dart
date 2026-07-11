/*

import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';

//Nuevas implementaciones
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';
import 'package:jumpup_app/domain/model/admin/stats_teacher_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_subscription_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/domain/model/admin/user_stats.dart';

class TeacherRepository {
  TeacherRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;
  final Dio _dio;

  List<dynamic> _listFrom(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['results'] is List) return raw['results'] as List;
    return const [];
  }

  Map<String, dynamic> _mapFrom(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  // ─── IDIOMAS (Implementación HTTP) ─────────────────────────────────────────

  /// Obtener todos los idiomas
  Future<List<Language>> fetchLanguages() async {
    try {
      final response = await _dio.get<dynamic>('languages/');
      final data = _listFrom(response.data);
      return data.map((json) => Language.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar idiomas: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Crear un nuevo idioma
  Future<Language> createLanguage({
    required String name,
    required String code,
    String? flagIconUrl,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'languages/',
        data: {
          'name': name,
          'code': code.toLowerCase(),
          'flag_icon_url': flagIconUrl ?? '',
        },
      );
      return Language.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        'Error al crear idioma: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Actualizar un idioma existente
  Future<void> updateLanguage({
    required int id,
    required String name,
    required String code,
    String? flagIconUrl,
  }) async {
    try {
      await _dio.patch(
        'languages/$id/',
        data: {
          'name': name,
          'code': code.toLowerCase(),
          'flag_icon_url': flagIconUrl ?? '',
        },
      );
    } on DioException catch (e) {
      throw ApiException(
        'Error al actualizar idioma: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Eliminar un idioma
  Future<void> deleteLanguage(int id) async {
    try {
      await _dio.delete('languages/$id/');
    } on DioException catch (e) {
      // Si el error es 409 (conflicto), significa que tiene cursos asociados
      if (e.response?.statusCode == 409) {
        throw ApiException(
          'No se puede eliminar el idioma porque tiene cursos asociados',
          409,
          e,
        );
      }
      throw ApiException(
        'Error al eliminar idioma: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Obtener un idioma por ID
  Future<Language?> getLanguageById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('languages/$id/');
      return Language.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException(
        'Error al obtener idioma: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── CURSOS (Implementación HTTP) ─────────────────────────────────────────

  /// Obtener todos los cursos
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _dio.get<dynamic>('courses/');
      final data = _listFrom(response.data);
      return data.map((json) => Course.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar cursos: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Crear un nuevo curso
  Future<void> createCourse(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        'courses/',
        data: {
          'language_id': data['language_id'],
          'title': data['title'],
          'description': data['description'] ?? '',
          'difficulty_level': data['difficulty_level'] ?? 'beginner',
          'image_url': data['image_url'] ?? '',
        },
      );
    } on DioException catch (e) {
      throw ApiException(
        'Error al crear curso: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Actualizar un curso existente
  Future<void> updateCourse(int id, Map<String, dynamic> data) async {
    try {
      await _dio.patch(
        'courses/$id/',
        data: {
          'language_id': data['language_id'],
          'title': data['title'],
          'description': data['description'] ?? '',
          'difficulty_level': data['difficulty_level'] ?? 'beginner',
          'image_url': data['image_url'] ?? '',
        },
      );
    } on DioException catch (e) {
      throw ApiException(
        'Error al actualizar curso: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Eliminar un curso
  Future<void> deleteCourse(int id) async {
    try {
      await _dio.delete('courses/$id/');
    } on DioException catch (e) {
      throw ApiException(
        'Error al eliminar curso: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Obtener cursos por idioma
  Future<List<Course>> getCoursesByLanguage(int languageId) async {
    try {
      final response = await _dio.get<dynamic>(
        'courses/',
        queryParameters: {'language_id': languageId},
      );
      final data = _listFrom(response.data);
      return data.map((json) => Course.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar cursos por idioma: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Obtener un curso por ID
  Future<Course?> getCourseById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('courses/$id/');
      return Course.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException(
        'Error al obtener curso: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── MÓDULOS ─────────────────────────────────────────────────────────────────

  /// Obtener módulos por curso
  Future<List<ModuleModel>> getModulesByCourse(int courseId) async {
    try {
      final response = await _dio.get<dynamic>(
        'modules/',
        queryParameters: {'course_id': courseId},
      );
      final data = _listFrom(response.data);
      return data.map((json) => ModuleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar módulos: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Crear un nuevo módulo
  Future<void> createModule(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        'modules/',
        data: {
          'course_id': data['course_id'],
          'title': data['title'],
          'order': data['order'] ?? 0,
        },
      );
    } on DioException catch (e) {
      throw ApiException(
        'Error al crear módulo: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Eliminar un módulo
  Future<void> deleteModule(int id) async {
    try {
      await _dio.delete('modules/$id/');
    } on DioException catch (e) {
      throw ApiException(
        'Error al eliminar módulo: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── LECCIONES ──────────────────────────────────────────────────────────────

  /// Obtener lecciones por módulo
  Future<List<LessonModel>> getLessonsByModule(int moduleId) async {
    try {
      final response = await _dio.get<dynamic>(
        'lessons/',
        queryParameters: {'module_id': moduleId},
      );
      final data = _listFrom(response.data);
      return data.map((json) => LessonModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar lecciones: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Obtener una lección por ID
  Future<LessonModel> getLessonById(int lessonId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('lessons/$lessonId/');
      return LessonModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        'Error al obtener lección: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Crear una nueva lección
  Future<void> createLesson(Map<String, dynamic> data) async {
    try {
      await _dio.post(
        'lessons/',
        data: {
          'module_id': data['module_id'],
          'title': data['title'],
          'content_type': data['content_type'] ?? 'text',
          'order': data['order'] ?? 0,
          'xp_reward': data['xp_reward'] ?? 0,
        },
      );
    } on DioException catch (e) {
      throw ApiException(
        'Error al crear lección: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  /// Eliminar una lección
  Future<void> deleteLesson(int id) async {
    try {
      await _dio.delete('lessons/$id/');
    } on DioException catch (e) {
      throw ApiException(
        'Error al eliminar lección: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── EJERCICIOS ─────────────────────────────────────────────────────────────

  /// Obtener ejercicios por lección
  Future<List<ExerciseModel>> getExercisesByLesson(int lessonId) async {
    try {
      final response = await _dio.get<dynamic>(
        'exercises/',
        queryParameters: {'lesson_id': lessonId},
      );
      final data = _listFrom(response.data);
      return data.map((json) => ExerciseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar ejercicios: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── ESTADÍSTICAS ───────────────────────────────────────────────────────────

  /// Obtener estadísticas del dashboard
  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('dashboard/admin/');
      return AdminStats.fromJson(_mapFrom(response.data));
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar estadísticas: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── USUARIOS CRUD ─────────────────────────────────────────────────────────

  Future<List<User>> fetchUsers() async {
    try {
      final response = await _dio.get<dynamic>('users/');
      final data = _listFrom(response.data);
      return data.map((u) => User.fromJson(u)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar usuarios: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _dio.patch('users/$id/', data: data);
    } on DioException catch (e) {
      throw ApiException(
        'Error al actualizar usuario: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── REPORTES ──────────────────────────────────────────────────────────────

  Future<List<Report>> fetchReports() async {
    try {
      final res = await _dio.get<dynamic>('reports/');
      final data = _listFrom(res.data);
      return data.map((i) => Report.fromJson(i)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar reportes: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<void> updateReport(int id, Map<String, dynamic> data) async {
    try {
      await _dio.patch('reports/$id/', data: data);
    } on DioException catch (e) {
      throw ApiException(
        'Error al actualizar reporte: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── ANUNCIOS ──────────────────────────────────────────────────────────────

  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final res = await _dio.get<dynamic>('announcements/');
      final data = _listFrom(res.data);
      return data.map((i) => Announcement.fromJson(i)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar anuncios: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── SUSCRIPCIONES ─────────────────────────────────────────────────────────

  Future<List<Subscription>> fetchSubscriptions() async {
    try {
      final res = await _dio.get<dynamic>('subscriptions/');
      final data = _listFrom(res.data);
      return data.map((i) => Subscription.fromJson(i)).toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar suscripciones: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<String> initiateCheckout(int subscriptionId) async {
    try {
      final res = await _dio.post('subscriptions/checkout/', data: {
        'subscription_id': subscriptionId,
      });
      return res.data['url'];
    } on DioException catch (e) {
      throw ApiException(
        'Error al iniciar pago: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── AULAS ──────────────────────────────────────────────────────────────────

  Future<Classroom> createClassroom({
    required String name,
    required String description,
    required int courseId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'classrooms/',
        data: {
          'name': name,
          'description': description,
          'course': courseId,
          'is_active': true,
        },
      );
      return Classroom.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        'Error al crear aula: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<List<Classroom>> fetchAllClassrooms() async {
    try {
      final response = await _dio.get<dynamic>('classrooms/');
      return _listFrom(response.data)
          .map((json) => Classroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar aulas: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId) async {
    try {
      final response = await _dio.get<dynamic>(
        'classroom-enrollments/',
        queryParameters: {'classroom': classroomId},
      );
      return _listFrom(response.data)
          .map((json) => ClassroomEnrollment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        'Error al cargar alumnos: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  Future<void> removeStudent(int enrollmentId) async {
    try {
      await _dio.delete('classroom-enrollments/$enrollmentId/');
    } on DioException catch (e) {
      throw ApiException(
        'Error al dar de baja al alumno: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── ESTADÍSTICAS DE USUARIO ──────────────────────────────────────────────

  Future<UserStats> fetchUserStats(String studentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('user-stats/$studentId/');
      return UserStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        'Error al obtener estadísticas: ${e.message}',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── RECURSOS ──────────────────────────────────────────────────────────────

  Future<TeacherResource> createResource(Map<String, dynamic> resourceData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('resources/', data: resourceData);
      return TeacherResource.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['course']?.toString() ?? 'Error al subir el recurso',
        e.response?.statusCode,
        e,
      );
    }
  }

  // ─── ESTADÍSTICAS DEL PROFESOR ────────────────────────────────────────────

  Future<TeacherStats> fetchTeacherStats() async {
    try {
      final res = await _dio.get<dynamic>('dashboard/teacher/');
      return TeacherStats.fromJson(_mapFrom(res.data));
    } on DioException catch (e) {
      // Fallback: calcular desde classrooms
      try {
        final classroomsRes = await _dio.get<dynamic>('classrooms/');
        final classrooms = _listFrom(classroomsRes.data)
            .map((i) => Classroom.fromJson(i))
            .toList();
        return TeacherStats(
          totalAulas: classrooms.length,
          totalAlumnos: classrooms.fold(0, (sum, item) => sum + item.totalStudents),
        );
      } catch (_) {
        throw ApiException(
          'Error al cargar estadísticas del profesor',
          e.response?.statusCode,
          e,
        );
      }
    }
  }
}
*/