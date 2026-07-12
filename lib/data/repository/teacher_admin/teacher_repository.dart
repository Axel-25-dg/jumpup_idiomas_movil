// lib/data/repository/teacher_admin/teacher_repository.dart
import 'package:jumpup_app/data/repository/teacher_admin/language_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/course_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/module_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/lesson_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/exercise_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/user_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/report_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/announcement_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/classroom_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/stats_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/resource_repository.dart';

import 'package:dio/dio.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/domain/model/admin/user_stats.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';
import 'package:jumpup_app/domain/model/admin/stats_teacher_model.dart';

class TeacherRepository {
  final LanguageRepository languages = LanguageRepository();
  final CourseRepository courses = CourseRepository();
  final ModuleRepository modules = ModuleRepository();
  final LessonRepository lessons = LessonRepository();
  final ExerciseRepository exercises = ExerciseRepository();
  final UserRepository users = UserRepository();
  final ReportRepository reports = ReportRepository();
  final AnnouncementRepository announcements = AnnouncementRepository();
  final ClassroomRepository classrooms = ClassroomRepository();
  final StatsRepository stats = StatsRepository();
  final ResourceRepository resources = ResourceRepository();

  final Dio _dio = DioClient.instance.dio;

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  // ── Aulas ──────────────────────────────────────────────────────────────────

  Future<ClassroomModel> createClassroom({
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
      return ClassroomModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
          e.message ?? 'Error al crear aula', e.response?.statusCode, e);
    }
  }

  Future<ClassroomModel> updateClassroom({
    required int id,
    required String name,
    required String description,
    required int courseId,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        'classrooms/$id/',
        data: {
          'name': name,
          'description': description,
          'course': courseId,
        },
      );
      return ClassroomModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
          e.message ?? 'Error al actualizar aula', e.response?.statusCode, e);
    }
  }

  Future<void> deleteClassroom(int id) async {
    try {
      // ignore: avoid_print
      print('TeacherRepository.deleteClassroom: deleting id=$id');
      final res = await _dio.delete('classrooms/$id/');
      // ignore: avoid_print
      print('TeacherRepository.deleteClassroom: response status=${res.statusCode}');
    } on DioException catch (e) {
      // ignore: avoid_print
      print('TeacherRepository.deleteClassroom: error=${e.response}');
      throw ApiException(
          e.message ?? 'Error al eliminar aula', e.response?.statusCode, e);
    }
  }

  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId) async {
    try {
      final response = await _dio.get<dynamic>(
        'classrooms/$classroomId/',
      );
      final data = response.data;
      final enrollments = data is Map && data['enrollments'] is List
          ? data['enrollments'] as List
          : const <dynamic>[];
      return enrollments
          .map((json) =>
              ClassroomEnrollment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException('Error al cargar alumnos', e.response?.statusCode, e);
    }
  }

  Future<void> removeStudent({
    required int classroomId,
    required int studentId,
  }) async {
    try {
      await _dio.post(
        'classrooms/$classroomId/remove-student/',
        data: {'student_id': studentId},
      );
    } on DioException catch (e) {
      throw ApiException(
          'Error al dar de baja al alumno', e.response?.statusCode, e);
    }
  }

  Future<UserStats> fetchUserStats(String studentId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('user-stats/$studentId/');
      return UserStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException('Error al obtener estadísticas del alumno',
          e.response?.statusCode, e);
    }
  }

  // ── Recursos ───────────────────────────────────────────────────────────────

  Future<TeacherResource> createResource(
      Map<String, dynamic> resourceData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'resources/',
        data: resourceData,
      );
      return TeacherResource.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['course']?.toString() ??
              'Error al subir el recurso',
          e.response?.statusCode,
          e);
    }
  }

  Future<List<TeacherResource>> fetchResources() async {
    try {
      final response = await _dio.get<dynamic>('resources/');
      return _listFrom(response.data)
          .map((json) => TeacherResource.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
          'Error al cargar los recursos', e.response?.statusCode, e);
    }
  }

  Future<List<ClassroomModel>> fetchAllClassrooms() async {
    try {
      final response = await _dio.get<dynamic>('classrooms/');
      return _listFrom(response.data)
          .map((json) => ClassroomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
          'Error al cargar las aulas', e.response?.statusCode, e);
    }
  }

  // ── Ejercicios ─────────────────────────────────────────────────────────────

  Future<void> createExercise(Map<String, dynamic> exerciseData) async {
    try {
      await _dio.post('exercises/', data: exerciseData);
    } on DioException catch (e) {
      throw ApiException(
          'Error al crear el ejercicio', e.response?.statusCode, e);
    }
  }

  // ── Perfil docente ─────────────────────────────────────────────────────────

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required List<int> languagesLearning,
    required List<int> languagesTeaching,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (languagesLearning.isNotEmpty) {
        data['languages_learning'] = languagesLearning;
      }
      if (languagesTeaching.isNotEmpty) {
        data['languages_teaching'] = languagesTeaching;
      }
      await _dio.patch('auth/profile/update-languages/', data: data);
    } on DioException catch (e) {
      throw ApiException(
          'Error al actualizar perfil', e.response?.statusCode, e);
    }
  }

  // ── Admin dashboard ────────────────────────────────────────────────────────

  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _dio.get('dashboard/admin/');
      return AdminStats.fromJson(_mapFrom(response.data));
    } on DioException catch (e) {
      throw ApiException(
          'Error al cargar estadísticas', e.response?.statusCode, e);
    }
  }

  // ── Usuarios CRUD ──────────────────────────────────────────────────────────

  Future<List<User>> fetchUsers() async {
    final response = await _dio.get<dynamic>('users/');
    return _listFrom(response.data).map((u) => User.fromJson(u)).toList();
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _dio.patch('users/$id/', data: data);
  }

  // ── Idiomas ────────────────────────────────────────────────────────────────

  Future<List<Language>> fetchLanguages() async {
    final res = await _dio.get<dynamic>('languages/');
    return _listFrom(res.data).map((i) => Language.fromJson(i)).toList();
  }

  Future<void> createLanguage(Map<String, dynamic> data) async =>
      await _dio.post('languages/', data: data);

  // ── Cursos ─────────────────────────────────────────────────────────────────

  Future<List<Course>> fetchCourses() async {
    final res = await _dio.get<dynamic>('courses/');
    return _listFrom(res.data).map((c) => Course.fromJson(c)).toList();
  }

  Future<void> createCourse(Map<String, dynamic> data) async =>
      await _dio.post('courses/', data: data);

  Future<void> updateCourse(int id, Map<String, dynamic> data) async =>
      await _dio.patch('courses/$id/', data: data);

  Future<void> createModule(Map<String, dynamic> data) async =>
      await _dio.post('modules/', data: data);

  Future<void> createLesson(Map<String, dynamic> data) async =>
      await _dio.post('lessons/', data: data);

  Future<void> deleteCourse(int id) async =>
      await _dio.delete('courses/$id/');

  Future<List<Map<String, dynamic>>> fetchModulesForCourse(int courseId) async {
    try {
      final res = await _dio.get<dynamic>(
        'modules/',
        queryParameters: {'course': courseId},
      );
      return _listFrom(res.data)
          .map((m) => {
                'id': m['id'],
                'title': m['title']?.toString() ?? 'Módulo',
              })
          .toList();
    } on DioException catch (e) {
      throw ApiException('Error al cargar módulos', e.response?.statusCode, e);
    }
  }

  // ── Reportes ───────────────────────────────────────────────────────────────

  Future<List<Report>> fetchReports() async {
    final res = await _dio.get<dynamic>('reports/');
    return _listFrom(res.data).map((i) => Report.fromJson(i)).toList();
  }

  Future<void> updateReport(int id, Map<String, dynamic> data) async {
    await _dio.patch('reports/$id/', data: data);
  }

  // ── Anuncios ───────────────────────────────────────────────────────────────

  Future<List<Announcement>> fetchAnnouncements() async {
    final res = await _dio.get<dynamic>('announcements/');
    return _listFrom(res.data).map((i) => Announcement.fromJson(i)).toList();
  }

  // ── Teacher Dashboard ──────────────────────────────────────────────────────

  Future<TeacherStats> fetchTeacherStats() async {
    try {
      final res = await _dio.get<dynamic>('dashboard/teacher/');
      return TeacherStats.fromJson(_mapFrom(res.data));
    } on DioException catch (e) {
      // Fallback: calcular desde aulas si el endpoint no existe
      try {
        final classroomsRes = await _dio.get<dynamic>('classrooms/');
        final classrooms = _listFrom(classroomsRes.data)
            .map((i) => ClassroomModel.fromJson(i))
            .toList();
        return TeacherStats(
          totalAulas: classrooms.length,
          totalAlumnos:
              classrooms.fold(0, (sum, item) => sum + item.studentsCount),
        );
      } catch (_) {
        throw ApiException('Error al cargar estadísticas del profesor',
            e.response?.statusCode, e);
      }
    }
  }
}
