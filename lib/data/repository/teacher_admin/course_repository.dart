// lib/data/repository/teacher_admin/course_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';

Map<String, dynamic> buildCoursePayload(Map<String, dynamic> data) {
  final languageId = data['language_id'] ?? data['language'] ?? data['course_language_id'];
  final payload = <String, dynamic>{
    'title': data['title'] ?? '',
    'description': data['description'] ?? '',
    'difficulty_level': data['difficulty_level'] ?? 'A1',
    'image_url': data['image_url'] ?? '',
    if (languageId != null) 'language': languageId,
    if (languageId != null) 'language_id': languageId,
  };
  return payload;
}

class CourseRepository extends BaseRepository {
  CourseRepository({Dio? dio}) : super(dio);
  Future<List<Course>> fetchCourses() {
    return getList<Course>(
      'courses/',
      (json) => Course.fromJson(json),
      message: 'Error al cargar cursos',
    );
  }

  Future<void> createCourse(Map<String, dynamic> data) async {
    try {
      final payload = buildCoursePayload(data);
      await dio.post('courses/', data: payload);
    } on DioException catch (e) {
      throw ApiException('Error al crear curso', e.response?.statusCode, e);
    }
  }

  Future<void> updateCourse(int id, Map<String, dynamic> data) async {
    try {
      await dio.patch('courses/$id/', data: buildCoursePayload(data));
    } on DioException catch (e) {
      throw ApiException('Error al actualizar curso', e.response?.statusCode, e);
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await dio.delete('courses/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar curso', e.response?.statusCode, e);
    }
  }

  Future<List<Course>> getCoursesByLanguage(int languageId) {
    return getList<Course>(
      'courses/',
      (json) => Course.fromJson(json),
      queryParameters: {'language_id': languageId},
      message: 'Error al cargar cursos por idioma',
    );
  }

  Future<Course?> getCourseById(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('courses/$id/');
      return Course.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException('Error al obtener curso', e.response?.statusCode, e);
    }
  }

  Future<void> createModule(Map<String, dynamic> data) async {
    try {
      await dio.post('modules/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al crear módulo', e.response?.statusCode, e);
    }
  }

  Future<void> createLesson(Map<String, dynamic> data) async {
    try {
      await dio.post('lessons/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al crear lección', e.response?.statusCode, e);
    }
  }
}