import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/teacher_repository.dart';
import '../../models/course_model.dart';
import '../../models/language_model.dart';

// 1. Provider para cargar la lista de idiomas
final languagesProvider = FutureProvider<List<Language>>((ref) async {
  return TeacherRepository().fetchLanguages();
});

// 2. Provider para el CRUD de Cursos
final coursesProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
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

  Future<void> deleteCourse(int id) async {
    await _repo.deleteCourse(id);
    await fetchCourses(); // Refresca la lista tras eliminar
  }
}