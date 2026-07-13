// lib/presentation/providers/lesson_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/lesson_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';


final lessonNotifierProvider = StateNotifierProvider<LessonNotifier, AsyncValue<List<LessonModel>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).lessons;
  return LessonNotifier(repository);
});

class LessonNotifier extends StateNotifier<AsyncValue<List<LessonModel>>> {
  final LessonRepository _repository;

  LessonNotifier(this._repository) : super(const AsyncValue.data([])) {
  print('📚 LessonNotifier - iniciando');
  fetchAllLessons();
}

Future<void> fetchAllLessons() async {
  print('📚 fetchAllLessons - ejecutando');
  state = const AsyncValue.loading();
  try {
    final lessons = await _repository.fetchAllLessons();
    print('📚 fetchAllLessons - ${lessons.length} lecciones');
    state = AsyncValue.data(lessons);
  } catch (e) {
    print('📚 fetchAllLessons - error: $e');
    state = AsyncValue.data([]);
  }
}

  Future<void> getLessonsByModule(int moduleId) async {
    state = const AsyncValue.loading();
    try {
      final lessons = await _repository.getLessonsByModule(moduleId);
      state = AsyncValue.data(lessons);
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

  Future<void> addLesson(Map<String, dynamic> data) async {
    try {
      await _repository.createLesson(data);
      await fetchAllLessons();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateLesson(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateLesson(id, data);
      await fetchAllLessons();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteLesson(int id) async {
    try {
      await _repository.deleteLesson(id);
      await fetchAllLessons();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchAllLessons();
  }
}

final lessonsByModuleProvider = FutureProvider.family<List<LessonModel>, int>((ref, moduleId) {
  final repository = ref.watch(teacherRepositoryProvider).lessons;
  return repository.getLessonsByModule(moduleId);
});

final lessonDetailProvider = FutureProvider.family<LessonModel, int>((ref, lessonId) {
  final repository = ref.watch(teacherRepositoryProvider).lessons;
  return repository.getLessonById(lessonId);
});