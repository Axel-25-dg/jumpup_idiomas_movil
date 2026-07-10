import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin_language_model.dart';

// Providers de admin — nombres con prefijo para evitar colisión con course_providers.dart
final adminLanguagesProvider = FutureProvider<List<Language>>((ref) async {
  return TeacherRepository().fetchLanguages();
});

final adminCoursesProvider =
    StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  return CourseNotifier(TeacherRepository());
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
