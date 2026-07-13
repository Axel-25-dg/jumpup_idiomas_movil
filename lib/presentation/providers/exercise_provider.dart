// lib/presentation/providers/exercise_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/exercise_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final exerciseNotifierProvider = StateNotifierProvider<ExerciseNotifier, AsyncValue<List<ExerciseModel>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).exercises;
  return ExerciseNotifier(repository);
});

class ExerciseNotifier extends StateNotifier<AsyncValue<List<ExerciseModel>>> {
  final ExerciseRepository _repository;

  ExerciseNotifier(this._repository) : super(const AsyncValue.data([])) {
    fetchAllExercises();
  }

  // Obtener TODOS los ejercicios
  Future<void> fetchAllExercises() async {
    state = const AsyncValue.loading();
    try {
      final exercises = await _repository.getAllExercises();
      state = AsyncValue.data(exercises);
    } catch (e) {
      state = AsyncValue.data([]);
    }
  }

  // Obtener ejercicios por leccion
  Future<void> getExercisesByLesson(int lessonId) async {
    state = const AsyncValue.loading();
    try {
      final exercises = await _repository.getExercisesByLesson(lessonId);
      state = AsyncValue.data(exercises);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Crear ejercicio
  Future<void> createExercise(Map<String, dynamic> data) async {
    try {
      await _repository.createExercise(data);
      final lessonId = data['lesson'] as int;
      await getExercisesByLesson(lessonId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Actualizar ejercicio
  Future<void> updateExercise(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateExercise(id, data);
      final lessonId = data['lesson'] as int;
      await getExercisesByLesson(lessonId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Eliminar ejercicio
  Future<void> deleteExercise(int id, int lessonId) async {
    try {
      await _repository.deleteExercise(id);
      await getExercisesByLesson(lessonId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar
  Future<void> refresh(int lessonId) async {
    await getExercisesByLesson(lessonId);
  }
}

final exercisesByLessonProvider = FutureProvider.family<List<ExerciseModel>, int>((ref, lessonId) {
  final repository = ref.watch(teacherRepositoryProvider).exercises;
  return repository.getExercisesByLesson(lessonId);
});

final allExercisesProvider = FutureProvider<List<ExerciseModel>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).exercises;
  return repository.getAllExercises();
});