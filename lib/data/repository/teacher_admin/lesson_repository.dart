// lib/data/repository/teacher_admin/lesson_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';


class LessonRepository extends BaseRepository {
  LessonRepository({Dio? dio}) : super(dio);
  // Obtener TODAS las lecciones
  Future<List<LessonModel>> fetchAllLessons() {
    return getList<LessonModel>(
      'lessons/',
      (json) => LessonModel.fromJson(json),
      message: 'Error al cargar lecciones',
    );
  }

  // Obtener lecciones por modulo
  Future<List<LessonModel>> getLessonsByModule(int moduleId) {
    return getList<LessonModel>(
      'lessons/',
      (json) => LessonModel.fromJson(json),
      queryParameters: {'module': moduleId},
      message: 'Error al cargar lecciones',
    );
  }

  // Obtener leccion por ID
  Future<LessonModel> getLessonById(int lessonId) {
    return getOne<LessonModel>(
      'lessons/$lessonId/',
      (json) => LessonModel.fromJson(json),
      message: 'Error al obtener leccion',
    );
  }

  // Crear leccion
  Future<void> createLesson(Map<String, dynamic> data) async {
    try {
      final payload = {
        'module': data['module'] ?? data['module_id'],
        'title': data['title'],
        'content_type': data['content_type'] ?? 'text',
        'order': data['order'] ?? 0,
        'xp_reward': data['xp_reward'] ?? 0,
      };
      await dio.post('lessons/', data: payload);
    } on DioException catch (e) {
      throw ApiException('Error al crear leccion', e.response?.statusCode, e);
    }
  }

  // Actualizar leccion
  Future<void> updateLesson(int id, Map<String, dynamic> data) async {
    try {
      final payload = {
        'module': data['module'] ?? data['module_id'],
        'title': data['title'],
        'content_type': data['content_type'] ?? 'text',
        'order': data['order'] ?? 0,
        'xp_reward': data['xp_reward'] ?? 0,
      };
      await dio.patch('lessons/$id/', data: payload);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar leccion', e.response?.statusCode, e);
    }
  }

  // Eliminar leccion
  Future<void> deleteLesson(int id) async {
    try {
      await dio.delete('lessons/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar leccion', e.response?.statusCode, e);
    }
  }
}