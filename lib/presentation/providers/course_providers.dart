import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/data/repository/auth/course_service.dart';

final courseServiceProvider = Provider<CourseService>((ref) {
  return const CourseService();
});

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

final languagesProvider = FutureProvider<List<LanguageModel>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLanguages();
});

final selectedLanguageProvider = StateProvider<LanguageModel?>((ref) => null);

class CourseFilters {
  const CourseFilters({
    this.difficultyLevel,
    this.languageId,
    this.search,
  });

  final String? difficultyLevel;
  final int? languageId;
  final String? search;

  CourseFilters copyWith({
    String? difficultyLevel,
    int? languageId,
    String? search,
  }) {
    return CourseFilters(
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      languageId: languageId ?? this.languageId,
      search: search ?? this.search,
    );
  }
}

final courseFiltersProvider = StateProvider<CourseFilters>((ref) {
  return const CourseFilters();
});

final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  final filters = ref.watch(courseFiltersProvider);
  return service.getCourses(
    difficultyLevel: filters.difficultyLevel,
    languageId: filters.languageId,
    search: filters.search,
  );
});

final courseDetailProvider =
    FutureProvider.family<CourseModel, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getCourseById(courseId);
});

final courseContentSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getCourseContentSummary(courseId);
});

final coursesByLanguageProvider =
    FutureProvider.family<List<CourseModel>, int>((ref, languageId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getCoursesByLanguage(languageId);
});

final modulesByCourseProvider =
    FutureProvider.family<List<ModuleModel>, int>((ref, courseId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getModulesByCourse(courseId);
});

final lessonsByModuleProvider =
    FutureProvider.family<List<LessonModel>, int>((ref, moduleId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLessonsByModule(moduleId);
});

final lessonStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, lessonId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLessonStats(lessonId);
});

final selectedLessonProvider = StateProvider<LessonModel?>((ref) => null);

final exercisesByLessonProvider =
    FutureProvider.family<List<ExerciseModel>, int>((ref, lessonId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getExercisesByLesson(lessonId);
});

final currentExerciseIndexProvider = StateProvider<int>((ref) => 0);

final lessonDetailsProvider =
    FutureProvider.family<LessonModel, int>((ref, lessonId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getLessonById(lessonId);
});

final teacherResourcesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, classroomId) async {
  final service = ref.watch(courseServiceProvider);
  return service.getTeacherResources(classroomId);
});
