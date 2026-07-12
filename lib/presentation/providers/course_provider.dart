// lib/presentation/providers/course_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/course_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final courseNotifierProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).courses;
  return CourseNotifier(repository);
});

final adminCoursesProvider = courseNotifierProvider;

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseRepository _repository;

  CourseNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    state = const AsyncValue.loading();
    try {
      final courses = await _repository.fetchCourses();
      state = AsyncValue.data(courses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCourse(Map<String, dynamic> data) async {
    try {
      await _repository.createCourse(data);
      await fetchCourses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editCourse(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCourse(id, data);
      await fetchCourses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await _repository.deleteCourse(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((c) => c.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Course>> getCoursesByLanguage(int languageId) async {
    try {
      return await _repository.getCoursesByLanguage(languageId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

  Future<Course?> getCourseById(int id) async {
    try {
      return await _repository.getCourseById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addModule(Map<String, dynamic> data) async {
    try {
      await _repository.createModule(data);
      await fetchCourses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addLesson(Map<String, dynamic> data) async {
    try {
      await _repository.createLesson(data);
      await fetchCourses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchCourses();
  }
}
