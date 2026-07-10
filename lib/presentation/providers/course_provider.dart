import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';

// Re-export del teacherRepositoryProvider para que otros providers lo puedan usar
export 'package:jumpup_app/presentation/providers/resource_provider.dart'
    show teacherRepositoryProvider;


// 1. Provider para cargar la lista de idiomas
final languagesProvider = FutureProvider<List<Language>>((ref) async {
  return TeacherRepository().fetchLanguages();
});

// 2. Provider para el CRUD de Cursos
final coursesProvider =
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
