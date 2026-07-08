import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_models.dart';
import '../auth/services/course_service.dart';

// ─── Providers de Servicio ───────────────────────────────────────────────────

/// Provider del servicio de cursos (singleton).
final courseServiceProvider = Provider<CourseService>((ref) {
  return const CourseService();
});

// ─── State Classes ───────────────────────────────────────────────────────────

/// Estado para listas paginadas de contenido educativo.
class ContentState<T> {
  const ContentState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<T> items;
  final bool isLoading;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty && !isLoading;

  ContentState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ContentState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─── Language Providers ──────────────────────────────────────────────────────

/// Provider que carga la lista de idiomas disponibles.
final languagesProvider = FutureProvider<List<LanguageModel>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLanguages();
});

/// Provider para el idioma seleccionado actualmente.
final selectedLanguageProvider = StateProvider<LanguageModel?>((ref) => null);

// ─── Course Providers ────────────────────────────────────────────────────────

/// Filtros para la lista de cursos.
class CourseFilters {
  const CourseFilters({
    this.difficultyLevel,
    this.languageId,
    this.search,
  });

  final String? difficultyLevel;
  final int? languageId;
  final String? search;
}

/// Provider del filtro activo para cursos.
final courseFiltersProvider = StateProvider<CourseFilters>((ref) {
  return const CourseFilters();
});

/// Provider que carga cursos según los filtros activos.
final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  final filters = ref.watch(courseFiltersProvider);
  return service.getCourses(
    difficultyLevel: filters.difficultyLevel,
    languageId: filters.languageId,
    search: filters.search,
  );
});

/// Provider para el detalle de un curso específico.
final courseDetailProvider =
    FutureProvider.family<CourseModel, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getCourseById(courseId);
});

/// Provider para el resumen de contenido de un curso (módulos, lecciones, XP).
final courseContentSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getCourseContentSummary(courseId);
});

/// Provider para cursos de un idioma específico.
final coursesByLanguageProvider =
    FutureProvider.family<List<CourseModel>, int>((ref, languageId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getCoursesByLanguage(languageId);
});

// ─── Module Providers ────────────────────────────────────────────────────────

/// Provider para módulos de un curso específico.
final modulesByCourseProvider =
    FutureProvider.family<List<ModuleModel>, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getModulesByCourse(courseId);
});

// ─── Lesson Providers ────────────────────────────────────────────────────────

/// Provider para lecciones de un módulo específico.
final lessonsByModuleProvider =
    FutureProvider.family<List<LessonModel>, int>((ref, moduleId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLessonsByModule(moduleId);
});

/// Provider para estadísticas de una lección.
final lessonStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, lessonId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLessonStats(lessonId);
});

/// Provider de la lección actualmente seleccionada.
final selectedLessonProvider = StateProvider<LessonModel?>((ref) => null);

// ─── Exercise Providers ──────────────────────────────────────────────────────

/// Provider para ejercicios de una lección específica.
final exercisesByLessonProvider =
    FutureProvider.family<List<ExerciseModel>, int>((ref, lessonId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getExercisesByLesson(lessonId);
});

/// Provider del índice del ejercicio activo durante una lección.
final currentExerciseIndexProvider = StateProvider<int>((ref) => 0);

/// Provider para obtener una lección por su ID.
final lessonDetailsProvider =
    FutureProvider.family<LessonModel, int>((ref, lessonId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLessonById(lessonId);
});

/// Provider para los recursos subidos por el docente para un aula.
final teacherResourcesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, classroomId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getTeacherResources(classroomId);
});
