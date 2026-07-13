// lib/data/repository/teacher_admin/exercise_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

class ExerciseRepository extends BaseRepository {
  ExerciseRepository({Dio? dio}) : super(dio);
  // Obtener ejercicios por leccion
  Future<List<ExerciseModel>> getExercisesByLesson(int lessonId) {
    return getList<ExerciseModel>(
      'exercises/',
      (json) => ExerciseModel.fromJson(json),
      queryParameters: {'lesson_id': lessonId},
      message: 'Error al cargar ejercicios',
    );
  }

  // Obtener TODOS los ejercicios
  Future<List<ExerciseModel>> getAllExercises() {
    return getList<ExerciseModel>(
      'exercises/',
      (json) => ExerciseModel.fromJson(json),
      message: 'Error al cargar ejercicios',
    );
  }

  // Crear ejercicio
  Future<void> createExercise(Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{
        'lesson': data['lesson'],
        'question_text': data['question_text'],
        'exercise_type': data['exercise_type'],
        'correct_answer': data['correct_answer'],
      };

      // ✅ options solo para multiple_choice
      if (data['exercise_type'] == 'multiple_choice') {
        final options = data['options'] as List?;
        if (options != null && options.isNotEmpty) {
          payload['options'] = options;
        } else {
          payload['options'] = ['Opcion 1', 'Opcion 2', 'Opcion 3'];
        }
      }

      // ✅ audio_url solo para listen
      if (data['exercise_type'] == 'listen' && data['audio_url'] != null) {
        payload['audio_url'] = data['audio_url'];
      }

      print('📤 CREATE EXERCISE - Payload: $payload');
      final response = await dio.post('exercises/', data: payload);
      print('✅ CREATE EXERCISE - Status: ${response.statusCode}');
      print('✅ CREATE EXERCISE - Response: ${response.data}');
    } on DioException catch (e) {
      print('❌ CREATE EXERCISE - Error: ${e.message}');
      print('❌ CREATE EXERCISE - Response: ${e.response?.data}');
      print('❌ CREATE EXERCISE - Status: ${e.response?.statusCode}');
      throw ApiException('Error al crear ejercicio', e.response?.statusCode, e);
    }
  }

  // Actualizar ejercicio
  Future<void> updateExercise(int id, Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{
        'lesson': data['lesson'],
        'question_text': data['question_text'],
        'exercise_type': data['exercise_type'],
        'correct_answer': data['correct_answer'],
      };

      if (data['exercise_type'] == 'multiple_choice') {
        final options = data['options'] as List?;
        if (options != null && options.isNotEmpty) {
          payload['options'] = options;
        } else {
          payload['options'] = ['Opcion 1', 'Opcion 2', 'Opcion 3'];
        }
      }

      if (data['exercise_type'] == 'listen' && data['audio_url'] != null) {
        payload['audio_url'] = data['audio_url'];
      }

      print('📤 UPDATE EXERCISE - Payload: $payload');
      final response = await dio.patch('exercises/$id/', data: payload);
      print('✅ UPDATE EXERCISE - Status: ${response.statusCode}');
      print('✅ UPDATE EXERCISE - Response: ${response.data}');
    } on DioException catch (e) {
      print('❌ UPDATE EXERCISE - Error: ${e.message}');
      print('❌ UPDATE EXERCISE - Response: ${e.response?.data}');
      print('❌ UPDATE EXERCISE - Status: ${e.response?.statusCode}');
      throw ApiException('Error al actualizar ejercicio', e.response?.statusCode, e);
    }
  }

  // Eliminar ejercicio
  Future<void> deleteExercise(int id) async {
    try {
      print('🗑️ DELETE EXERCISE - id: $id');
      final response = await dio.delete('exercises/$id/');
      print('✅ DELETE EXERCISE - Status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DELETE EXERCISE - Error: ${e.message}');
      print('❌ DELETE EXERCISE - Response: ${e.response?.data}');
      throw ApiException('Error al eliminar ejercicio', e.response?.statusCode, e);
    }
  }
}