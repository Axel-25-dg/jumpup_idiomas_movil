import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/domain/model/admin_stats_model.dart';
import 'package:jumpup_app/domain/model/announcement_model.dart';

//Nuevas implementaciones
import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin_course_model.dart';
import 'package:jumpup_app/domain/model/enrollment_model.dart';
import 'package:jumpup_app/domain/model/admin_language_model.dart';
import 'package:jumpup_app/domain/model/report_model.dart';
import 'package:jumpup_app/domain/model/resource_model.dart';
import 'package:jumpup_app/domain/model/stats_teacher_model.dart';
import 'package:jumpup_app/domain/model/admin_subscription_model.dart';
import 'package:jumpup_app/domain/model/admin_user_model.dart';
import 'package:jumpup_app/domain/model/user_stats.dart';

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
          e.message ?? 'Error al crear aula', e.response?.statusCode, e);
    }
  }

  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId) async {
    try {
      final response = await _dio.get<dynamic>(
        'classroom-enrollments/',
        queryParameters: {'classroom': classroomId},
      );
      return _listFrom(response.data)
          .map((json) =>
              ClassroomEnrollment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException('Error al cargar alumnos', e.response?.statusCode, e);
    }
  }

  Future<void> removeStudent(int enrollmentId) async {
    try {
      // Si tu backend hace baja lógica, usualmente es DELETE o PATCH.
      // Según tu petición, usaremos DELETE.
      await _dio.delete('classroom-enrollments/$enrollmentId/');
    } on DioException catch (e) {
      throw ApiException(
          'Error al dar de baja al alumno', e.response?.statusCode, e);
    }
  }

  Future<UserStats> fetchUserStats(String studentId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('user-stats/$studentId/');
      // Usamos el factory definido en el modelo de dominio
      return UserStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException('Error al obtener estadísticas del alumno',
          e.response?.statusCode, e);
    }
  }

  /// Envía un nuevo recurso al backend.
  Future<TeacherResource> createResource(
      Map<String, dynamic> resourceData) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('resources/',
          data: resourceData);
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

  /// Obtiene todas las aulas del profesor
  Future<List<Classroom>> fetchAllClassrooms() async {
    try {
      final response = await _dio.get<dynamic>('classrooms/');
      return _listFrom(response.data)
          .map((json) => Classroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
          'Error al cargar las aulas', e.response?.statusCode, e);
    }
  }

  //Exercise

  Future<void> createExercise(Map<String, dynamic> exerciseData) async {
    try {
      await _dio.post('exercises/', data: exerciseData);
    } on DioException catch (e) {
      throw ApiException(
          'Error al crear el ejercicio', e.response?.statusCode, e);
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

//Admin dashboard

  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _dio.get('dashboard/admin/');
      return AdminStats.fromJson(_mapFrom(response.data));
    } on DioException catch (e) {
      throw ApiException(
          'Error al cargar estadísticas', e.response?.statusCode, e);
    }
  }
//Usuarios crud

  Future<List<User>> fetchUsers() async {
    final response = await _dio.get<dynamic>('users/');
    final data = _listFrom(response.data);
    return data.map((u) => User.fromJson(u)).toList();
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _dio.patch('users/$id/', data: data);
  }

//Cursos-Idiomas
// Idiomas
  Future<List<Language>> fetchLanguages() async {
    final res = await _dio.get<dynamic>('languages/');
    return _listFrom(res.data).map((i) => Language.fromJson(i)).toList();
  }

  Future<void> createLanguage(Map<String, dynamic> data) async =>
      await _dio.post('languages/', data: data);

// Cursos
  Future<List<Course>> fetchCourses() async {
    final res = await _dio.get<dynamic>('courses/');
    return _listFrom(res.data).map((c) => Course.fromJson(c)).toList();
  }

  Future<void> createCourse(Map<String, dynamic> data) async =>
      await _dio.post('courses/', data: data);
      
  Future<void> createModule(Map<String, dynamic> data) async =>
      await _dio.post('modules/', data: data);
      
  Future<void> createLesson(Map<String, dynamic> data) async =>
      await _dio.post('lessons/', data: data);

  Future<void> deleteCourse(int id) async => await _dio.delete('courses/$id/');

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
      throw ApiException(
          'Error al cargar módulos', e.response?.statusCode, e);
    }
  }


//informes globales
// obtener la lista de reportes
  Future<List<Report>> fetchReports() async {
    final res = await _dio.get<dynamic>('reports/');
    // Dependiendo de tu respuesta, si viene en un objeto con "results", usa:
    final data = _listFrom(res.data);
    return data.map((i) => Report.fromJson(i)).toList();
  }

// actualizar el estado de un reporte
  Future<void> updateReport(int id, Map<String, dynamic> data) async {
    await _dio.patch('reports/$id/', data: data);
  }

//anuncios
  Future<List<Announcement>> fetchAnnouncements() async {
    // Realiza el GET al endpoint que ya tienes configurado en Django
    final res = await _dio.get<dynamic>('announcements/');

    // Si tu API usa paginación (StandardPagination), accedemos a 'results'
    final data = _listFrom(res.data);

    return data.map((i) => Announcement.fromJson(i)).toList();
  }

//Suscripciones

// Obtener lista de planes para mostrar al usuario
  Future<List<Subscription>> fetchSubscriptions() async {
    final res = await _dio.get<dynamic>('subscriptions/');
    final data = _listFrom(res.data);
    return data.map((i) => Subscription.fromJson(i)).toList();
  }

// Iniciar el proceso de pago (Checkout)
  Future<String> initiateCheckout(int subscriptionId) async {
    final res = await _dio.post('subscriptions/checkout/', data: {
      'subscription_id': subscriptionId,
    });
    return res.data['url']; // URL de Stripe
  }

//Teacher Dashboard
  Future<TeacherStats> fetchTeacherStats() async {
    try {
      final res = await _dio.get<dynamic>('dashboard/teacher/');
      return TeacherStats.fromJson(_mapFrom(res.data));
    } on DioException catch (e) {
      // Si el endpoint falla, calcula desde classrooms como fallback
      try {
        final classroomsRes = await _dio.get<dynamic>('classrooms/');
        final classrooms = _listFrom(classroomsRes.data)
            .map((i) => Classroom.fromJson(i))
            .toList();
        return TeacherStats(
          totalAulas: classrooms.length,
          totalAlumnos:
              classrooms.fold(0, (sum, item) => sum + item.totalStudents),
        );
      } catch (_) {
        throw ApiException('Error al cargar estadísticas del profesor',
            e.response?.statusCode, e);
      }
    }
  }
}
