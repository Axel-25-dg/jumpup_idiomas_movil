import 'package:dio/dio.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/data/remote/dto/course_dto.dart';

class CourseRepositoryImpl extends BaseRepository {
  const CourseRepositoryImpl({Dio? dio}) : super(dio);

  final Map<String, Future<List<CourseModel>>> _courseListCache =
      const <String, Future<List<CourseModel>>>{};

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

    final cacheKey = 'all:${params.toString()}';
    final existing = _courseListCache[cacheKey];
    if (existing != null) {
      return existing;
    }

    final request = handleRequest<List<CourseModel>>(() async {
      final response = await dio.get<dynamic>(
        'courses/',
        queryParameters: params.isNotEmpty ? params : null,
      );

      final List<dynamic> list;
      if (response.data is List) {
        list = response.data as List;
      } else if (response.data is Map && response.data['results'] is List) {
        list = response.data['results'] as List;
      } else {
        list = [];
      }

      return list.map((json) {
        final dto = CourseDto.fromJson(json as Map<String, dynamic>);
        return CourseModel(
          id: dto.id,
          language: dto.language,
          languageName: dto.languageName,
          title: dto.title,
          description: dto.description,
          difficultyLevel: dto.difficultyLevel,
          imageUrl: dto.imageUrl,
          teacherName: dto.teacherName,
          teacherEmail: dto.teacherEmail,
          modulesCount: dto.modulesCount,
          lessonsCount: dto.lessonsCount,
          totalXpReward: dto.totalXpReward,
        );
      }).toList();
    }, message: 'No se pudieron cargar los cursos').whenComplete(() {
      if (_courseListCache[cacheKey] != null) {
        _courseListCache.remove(cacheKey);
      }
    });

    _courseListCache[cacheKey] = request;
    return request;
  }

  Future<List<CourseModel>> getStudentEnrolledCourses({
    String? difficultyLevel,
    String? search,
  }) async {
    final params = <String, dynamic>{'enrolled': true};
    if (difficultyLevel != null) params['difficulty_level'] = difficultyLevel;
    if (search != null) params['search'] = search;

    final cacheKey = 'enrolled:${params.toString()}';
    final existing = _courseListCache[cacheKey];
    if (existing != null) {
      return existing;
    }

    final request = handleRequest<List<CourseModel>>(() async {
      final response = await dio.get<dynamic>(
        'courses/',
        queryParameters: params,
      );

      final List<dynamic> list;
      if (response.data is List) {
        list = response.data as List;
      } else if (response.data is Map && response.data['results'] is List) {
        list = response.data['results'] as List;
      } else {
        list = [];
      }

      return list.map((json) {
        final dto = CourseDto.fromJson(json as Map<String, dynamic>);
        return CourseModel(
          id: dto.id,
          language: dto.language,
          languageName: dto.languageName,
          title: dto.title,
          description: dto.description,
          difficultyLevel: dto.difficultyLevel,
          imageUrl: dto.imageUrl,
          teacherName: dto.teacherName,
          teacherEmail: dto.teacherEmail,
          modulesCount: dto.modulesCount,
          lessonsCount: dto.lessonsCount,
          totalXpReward: dto.totalXpReward,
        );
      }).toList();
    }, message: 'No se pudieron cargar los cursos inscritos').whenComplete(() {
      if (_courseListCache[cacheKey] != null) {
        _courseListCache.remove(cacheKey);
      }
    });

    _courseListCache[cacheKey] = request;
    return request;
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

  Future<List<TeacherResource>> getLessonResources(int lessonId) async {
    return getList('resources/', TeacherResource.fromJson,
        queryParameters: {'lesson': lessonId},
        message: 'No se pudieron cargar los recursos de la lección');
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
