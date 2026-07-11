import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class CourseService extends BaseRepository {
  const CourseService();

  Future<List<LanguageModel>> getLanguages() async {
    return getList('languages/', LanguageModel.fromJson,
        message: 'No se pudieron cargar los idiomas');
  }

  Future<List<CourseModel>> getCoursesByLanguage(int languageId) async {
    return getList('languages/$languageId/courses/', CourseModel.fromJson,
        message: 'No se pudieron cargar los cursos del idioma');
  }

  Future<List<CourseModel>> getCourses({
    String? difficultyLevel,
    int? languageId,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (difficultyLevel != null) params['difficulty_level'] = difficultyLevel;
    if (languageId != null) params['language'] = languageId;
    if (search != null) params['search'] = search;
    return getList('courses/', CourseModel.fromJson,
        queryParameters: params.isNotEmpty ? params : null,
        message: 'No se pudieron cargar los cursos');
  }

  Future<CourseModel> getCourseById(int courseId) async {
    return getOne('courses/$courseId/', CourseModel.fromJson,
        message: 'No se pudo obtener el curso');
  }

  Future<Map<String, dynamic>> getCourseContentSummary(int courseId) async {
    return handleRequest<Map<String, dynamic>>(() async {
      final response = await dio.get<Map<String, dynamic>>(
        'courses/$courseId/content-summary/',
      );
      return response.data!;
    }, message: 'No se pudo obtener el resumen del curso');
  }

  Future<List<ModuleModel>> getModulesByCourse(int courseId) async {
    return getList('modules/', ModuleModel.fromJson,
        queryParameters: {'course': courseId},
        message: 'No se pudieron cargar los módulos');
  }

  Future<List<LessonModel>> getLessonsByModule(int moduleId) async {
    return getList('lessons/', LessonModel.fromJson,
        queryParameters: {'module': moduleId},
        message: 'No se pudieron cargar las lecciones');
  }

  Future<Map<String, dynamic>> getLessonStats(int lessonId) async {
    return handleRequest<Map<String, dynamic>>(() async {
      final response = await dio.get<Map<String, dynamic>>(
        'lessons/$lessonId/stats/',
      );
      return response.data!;
    }, message: 'No se pudieron obtener las estadísticas de la lección');
  }

  Future<LessonModel> getLessonById(int lessonId) async {
    return getOne('lessons/$lessonId/', LessonModel.fromJson,
        message: 'No se pudo obtener la lección');
  }

  Future<List<ExerciseModel>> getExercisesByLesson(int lessonId) async {
    return getList('exercises/', ExerciseModel.fromJson,
        queryParameters: {'lesson': lessonId},
        message: 'No se pudieron cargar los ejercicios');
  }

  Future<List<Map<String, dynamic>>> getTeacherResources(
      int classroomId) async {
    return handleRequest<List<Map<String, dynamic>>>(() async {
      final response = await dio.get<dynamic>('resources/', queryParameters: {
        'classroom': classroomId,
      });
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      if (data is Map && data['results'] is List) {
        return (data['results'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    }, message: 'No se pudieron cargar los recursos');
  }
}
