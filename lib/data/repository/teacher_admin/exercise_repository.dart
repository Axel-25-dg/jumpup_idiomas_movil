// lib/data/repository/teacher_admin/exercise_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

class ExerciseRepository extends BaseRepository {
  Future<List<ExerciseModel>> getExercisesByLesson(int lessonId) {
    return getList<ExerciseModel>(
      'exercises/',
      (json) => ExerciseModel.fromJson(json),
      queryParameters: {'lesson_id': lessonId},
      message: 'Error al cargar ejercicios',
    );
  }

  Future<void> createExercise(Map<String, dynamic> data) async {
    try {
      await dio.post('exercises/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al crear ejercicio', e.response?.statusCode, e);
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await dio.delete('exercises/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar ejercicio', e.response?.statusCode, e);
    }
  }

  Future<void> updateExercise(int id, Map<String, dynamic> data) async {
  try {
    await dio.patch('exercises/$id/', data: data);
  } on DioException catch (e) {
    throw ApiException('Error al actualizar ejercicio', e.response?.statusCode, e);
  }
}
}