// lib/data/repository/teacher_admin/lesson_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

class LessonRepository extends BaseRepository {
  Future<List<LessonModel>> getLessonsByModule(int moduleId) {
    return getList<LessonModel>(
      'lessons/',
      (json) => LessonModel.fromJson(json),
      queryParameters: {'module_id': moduleId},
      message: 'Error al cargar lecciones',
    );
  }

  Future<LessonModel> getLessonById(int lessonId) {
    return getOne<LessonModel>(
      'lessons/$lessonId/',
      (json) => LessonModel.fromJson(json),
      message: 'Error al obtener lección',
    );
  }

  Future<void> createLesson(Map<String, dynamic> data) async {
    try {
      await dio.post('lessons/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al crear lección', e.response?.statusCode, e);
    }
  }

  Future<void> deleteLesson(int id) async {
    try {
      await dio.delete('lessons/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar lección', e.response?.statusCode, e);
    }
  }
}