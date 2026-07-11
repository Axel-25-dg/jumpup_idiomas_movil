// lib/presentation/providers/lesson_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/lesson_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';

final lessonNotifierProvider = StateNotifierProvider<LessonNotifier, AsyncValue<List<LessonModel>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).lessons;
  return LessonNotifier(repository);
});

class LessonNotifier extends StateNotifier<AsyncValue<List<LessonModel>>> {
  final LessonRepository _repository;

  LessonNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> getLessonsByModule(int moduleId) async {
    state = const AsyncValue.loading();
    try {
      final lessons = await _repository.getLessonsByModule(moduleId);
      state = AsyncValue.data(lessons);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addLesson(Map<String, dynamic> data) async {
    try {
      await _repository.createLesson(data);
      final moduleId = data['module_id'] as int;
      await getLessonsByModule(moduleId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteLesson(int id, int moduleId) async {
    try {
      await _repository.deleteLesson(id);
      await getLessonsByModule(moduleId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<LessonModel> getLessonById(int id) async {
    try {
      return await _repository.getLessonById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh(int moduleId) async {
    await getLessonsByModule(moduleId);
  }
}

// Providers con parámetros
final lessonsByModuleProvider = FutureProvider.family<List<LessonModel>, int>((ref, moduleId) {
  final repository = ref.watch(teacherRepositoryProvider).lessons;
  return repository.getLessonsByModule(moduleId);
});

final lessonDetailProvider = FutureProvider.family<LessonModel, int>((ref, lessonId) {
  final repository = ref.watch(teacherRepositoryProvider).lessons;
  return repository.getLessonById(lessonId);
});