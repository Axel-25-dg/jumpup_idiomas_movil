// lib/data/repository/teacher_admin/lesson_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

class LessonRepository extends BaseRepository {
  //  Obtener TODAS las lecciones
  Future<List<LessonModel>> fetchAllLessons() {
    return getList<LessonModel>(
      'lessons/',
      (json) => LessonModel.fromJson(json),
      message: 'Error al cargar lecciones',
    );
  }

  //  Obtener lecciones por módulo
  Future<List<LessonModel>> getLessonsByModule(int moduleId) {
    return getList<LessonModel>(
      'lessons/',
      (json) => LessonModel.fromJson(json),
      queryParameters: {'module_id': moduleId},
      message: 'Error al cargar lecciones',
    );
  }

  //  Obtener lección por ID
  Future<LessonModel> getLessonById(int lessonId) {
    return getOne<LessonModel>(
      'lessons/$lessonId/',
      (json) => LessonModel.fromJson(json),
      message: 'Error al obtener lección',
    );
  }

  //  Crear lección
  Future<void> createLesson(Map<String, dynamic> data) async {
    try {
      await dio.post('lessons/', data: {
        'module': data['module'],
        'title': data['title'],
        'content_type': data['content_type'] ?? 'text',
        'order': data['order'] ?? 0,
        'xp_reward': data['xp_reward'] ?? 0,
      });
    } on DioException catch (e) {
      throw ApiException('Error al crear lección', e.response?.statusCode, e);
    }
  }

  //  Actualizar lección
  Future<void> updateLesson(int id, Map<String, dynamic> data) async {
    try {
      await dio.patch('lessons/$id/', data: {
        'module': data['module'],
        'title': data['title'],
        'content_type': data['content_type'] ?? 'text',
        'order': data['order'] ?? 0,
        'xp_reward': data['xp_reward'] ?? 0,
      });
    } on DioException catch (e) {
      throw ApiException('Error al actualizar lección', e.response?.statusCode, e);
    }
  }

  //  Eliminar lección
  Future<void> deleteLesson(int id) async {
    try {
      await dio.delete('lessons/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar lección', e.response?.statusCode, e);
    }
  }
}