import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';

import 'package:jumpup_app/presentation/providers/resource_provider.dart';


// Providers de admin — nombres con prefijo para evitar colisión con course_providers.dart
final adminLanguagesProvider = FutureProvider<List<Language>>((ref) async {
  final repo = ref.read(teacherRepositoryProvider);
  return repo.fetchLanguages();
});

final adminCoursesProvider =
    StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  return CourseNotifier(ref.read(teacherRepositoryProvider));
});

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final TeacherRepository _repo;

  CourseNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.fetchCourses());
  }

  Future<void> addCourse(Map<String, dynamic> data) async {
    await _repo.createCourse(data);
    await fetchCourses(); // Refresca la lista tras añadir
  }

  Future<void> editCourse(int id, Map<String, dynamic> data) async {
    await _repo.updateCourse(id, data);
    await fetchCourses(); // Refresca la lista tras editar
  }
  
  Future<void> addModule(Map<String, dynamic> data) async {
    await _repo.createModule(data);
  }
  
  Future<void> addLesson(Map<String, dynamic> data) async {
    await _repo.createLesson(data);
  }

  Future<void> deleteCourse(int id) async {
    await _repo.deleteCourse(id);
    await fetchCourses(); // Refresca la lista tras eliminar
  }
}

// Provider para módulos de un curso (usado en CreateLessonScreen)
final modulesForCourseProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, courseId) async {
  final repo = ref.read(teacherRepositoryProvider);
  try {
    return await repo.fetchModulesForCourse(courseId);
  } catch (_) {
    return [];
  }
});
