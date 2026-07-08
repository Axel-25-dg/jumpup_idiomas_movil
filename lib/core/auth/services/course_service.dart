import '../repositories/base_repository.dart';
import '../models/course_models.dart';

/// Servicio para consumir los endpoints de Contenido Educativo de la API JumpUp.
///
/// Endpoints cubiertos:
/// - GET /api/languages/
/// - GET /api/languages/{id}/courses/
/// - GET /api/courses/
/// - GET /api/courses/{id}/
/// - GET /api/courses/{id}/content-summary/
/// - GET /api/modules/
/// - GET /api/lessons/
/// - GET /api/lessons/{id}/stats/
/// - GET /api/exercises/
class CourseService extends BaseRepository {
  const CourseService();

  // ─── Languages ──────────────────────────────────────────────────────────────

  /// Obtiene la lista de idiomas disponibles en la plataforma.
  Future<List<LanguageModel>> getLanguages() async {
    return handleRequest<List<LanguageModel>>(() async {
      // TODO: Integrar con Dio client cuando esté disponible
      // final response = await dio.get('/api/languages/');
      // return (response.data['results'] as List)
      //     .map((e) => LanguageModel.fromJson(e))
      //     .toList();
      return _mockLanguages();
    }, message: 'No se pudieron cargar los idiomas');
  }

  /// Obtiene los cursos disponibles para un idioma específico.
  Future<List<CourseModel>> getCoursesByLanguage(int languageId) async {
    return handleRequest<List<CourseModel>>(() async {
      // TODO: final response = await dio.get('/api/languages/$languageId/courses/');
      return _mockCourses().where((c) => c.language == languageId).toList();
    }, message: 'No se pudieron cargar los cursos del idioma');
  }

  // ─── Courses ────────────────────────────────────────────────────────────────

  /// Obtiene la lista completa de cursos con filtros opcionales.
  Future<List<CourseModel>> getCourses({
    String? difficultyLevel,
    int? languageId,
    String? search,
  }) async {
    return handleRequest<List<CourseModel>>(() async {
      // TODO: Implementar con query params
      // Map<String, dynamic> params = {};
      // if (difficultyLevel != null) params['difficulty_level'] = difficultyLevel;
      // if (languageId != null) params['language'] = languageId;
      // if (search != null) params['search'] = search;
      // final response = await dio.get('/api/courses/', queryParameters: params);
      var courses = _mockCourses();
      if (difficultyLevel != null) {
        courses = courses.where((c) => c.difficultyLevel == difficultyLevel).toList();
      }
      if (languageId != null) {
        courses = courses.where((c) => c.language == languageId).toList();
      }
      return courses;
    }, message: 'No se pudieron cargar los cursos');
  }

  /// Obtiene el detalle de un curso por su ID.
  Future<CourseModel> getCourseById(int courseId) async {
    return handleRequest<CourseModel>(() async {
      // TODO: final response = await dio.get('/api/courses/$courseId/');
      return _mockCourses().firstWhere(
        (c) => c.id == courseId,
        orElse: () => throw Exception('Curso no encontrado'),
      );
    }, message: 'No se pudo obtener el curso');
  }

  /// Obtiene el resumen de contenido completo de un curso (módulos + lecciones + XP).
  Future<Map<String, dynamic>> getCourseContentSummary(int courseId) async {
    return handleRequest<Map<String, dynamic>>(() async {
      // TODO: final response = await dio.get('/api/courses/$courseId/content-summary/');
      return {
        'course_id': courseId,
        'total_modules': 3,
        'total_lessons': 12,
        'total_exercises': 36,
        'total_xp': 240,
        'modules': [],
      };
    }, message: 'No se pudo obtener el resumen del curso');
  }

  // ─── Modules ────────────────────────────────────────────────────────────────

  /// Obtiene los módulos de un curso específico.
  Future<List<ModuleModel>> getModulesByCourse(int courseId) async {
    return handleRequest<List<ModuleModel>>(() async {
      // TODO: final response = await dio.get('/api/modules/?course=$courseId');
      return _mockModules().where((m) => m.course == courseId).toList();
    }, message: 'No se pudieron cargar los módulos');
  }

  // ─── Lessons ────────────────────────────────────────────────────────────────

  /// Obtiene las lecciones de un módulo específico.
  Future<List<LessonModel>> getLessonsByModule(int moduleId) async {
    return handleRequest<List<LessonModel>>(() async {
      // TODO: final response = await dio.get('/api/lessons/?module=$moduleId');
      return _mockLessons().where((l) => l.module == moduleId).toList();
    }, message: 'No se pudieron cargar las lecciones');
  }

  /// Obtiene las estadísticas de una lección (intentos, tasa de éxito, score promedio).
  Future<Map<String, dynamic>> getLessonStats(int lessonId) async {
    return handleRequest<Map<String, dynamic>>(() async {
      // TODO: final response = await dio.get('/api/lessons/$lessonId/stats/');
      return {
        'lesson_id': lessonId,
        'total_attempts': 0,
        'completed': 0,
        'success_rate': 0.0,
        'average_score': 0.0,
        'exercises_count': 0,
      };
    }, message: 'No se pudieron obtener las estadísticas de la lección');
  }

  /// Obtiene una lección por su ID.
  Future<LessonModel> getLessonById(int lessonId) async {
    return handleRequest<LessonModel>(() async {
      // TODO: final response = await dio.get('/api/lessons/$lessonId/');
      return _mockLessons().firstWhere(
        (l) => l.id == lessonId,
        orElse: () => LessonModel(
          id: lessonId,
          module: 1,
          moduleTitle: 'Saludos',
          title: 'Lección $lessonId',
          contentType: 'interactive',
          order: 1,
          xpReward: 20,
          exercisesCount: 5,
        ),
      );
    }, message: 'No se pudo obtener la lección');
  }

  // ─── Exercises ──────────────────────────────────────────────────────────────

  /// Obtiene los ejercicios de una lección específica.
  Future<List<ExerciseModel>> getExercisesByLesson(int lessonId) async {
    return handleRequest<List<ExerciseModel>>(() async {
      // TODO: final response = await dio.get('/api/exercises/?lesson=$lessonId');
      return _mockExercises().where((e) => e.lesson == lessonId).toList();
    }, message: 'No se pudieron cargar los ejercicios');
  }

  /// Obtiene los recursos subidos por el docente para un aula.
  Future<List<Map<String, dynamic>>> getTeacherResources(int classroomId) async {
    return handleRequest<List<Map<String, dynamic>>>(() async {
      // TODO: final response = await dio.get('/api/teacher-resources/?classroom=$classroomId');
      return [
        {
          'folder': 'Módulo 1: Conceptos Básicos',
          'files': [
            {'name': 'Guía de Gramática Básica.pdf', 'size': '2.4 MB', 'type': 'pdf'},
            {'name': 'Lista de Vocabulario.xlsx', 'size': '150 KB', 'type': 'spreadsheet'},
            {'name': 'Audio Pronunciación.mp3', 'size': '4.1 MB', 'type': 'audio'},
          ]
        },
        {
          'folder': 'Módulo 2: Conversación Práctica',
          'files': [
            {'name': 'Conversación de Ejemplo.pdf', 'size': '1.2 MB', 'type': 'pdf'},
          ]
        }
      ];
    }, message: 'No se pudieron cargar los recursos');
  }

  // ─── Mock Data ──────────────────────────────────────────────────────────────
  // Datos de demostración hasta que el backend esté integrado con Dio

  List<LanguageModel> _mockLanguages() => [
        const LanguageModel(id: 1, name: 'Inglés', code: 'EN', coursesCount: 3),
        const LanguageModel(id: 2, name: 'Francés', code: 'FR', coursesCount: 2),
        const LanguageModel(id: 3, name: 'Alemán', code: 'DE', coursesCount: 1),
      ];

  List<CourseModel> _mockCourses() => [
        const CourseModel(
          id: 1, language: 1, languageName: 'Inglés',
          title: 'Inglés A1 - Principiantes', description: 'Curso básico de inglés',
          difficultyLevel: 'A1', modulesCount: 3, lessonsCount: 12, totalXpReward: 240,
        ),
        const CourseModel(
          id: 2, language: 1, languageName: 'Inglés',
          title: 'Inglés B1 - Intermedio', description: 'Curso intermedio de inglés',
          difficultyLevel: 'B1', modulesCount: 4, lessonsCount: 16, totalXpReward: 320,
        ),
        const CourseModel(
          id: 3, language: 2, languageName: 'Francés',
          title: 'Francés A1 - Débutant', description: 'Curso básico de francés',
          difficultyLevel: 'A1', modulesCount: 3, lessonsCount: 10, totalXpReward: 200,
        ),
      ];

  List<ModuleModel> _mockModules() => [
        const ModuleModel(id: 1, course: 1, courseTitle: 'Inglés A1', title: 'Saludos y presentaciones', order: 1, lessonsCount: 4),
        const ModuleModel(id: 2, course: 1, courseTitle: 'Inglés A1', title: 'Números y colores', order: 2, lessonsCount: 4),
        const ModuleModel(id: 3, course: 1, courseTitle: 'Inglés A1', title: 'La familia', order: 3, lessonsCount: 4),
      ];

  List<LessonModel> _mockLessons() => [
        const LessonModel(id: 1, module: 1, moduleTitle: 'Saludos y presentaciones', title: 'Hello & Goodbye', contentType: 'video', order: 1, xpReward: 20, exercisesCount: 3),
        const LessonModel(id: 2, module: 1, moduleTitle: 'Saludos y presentaciones', title: 'My name is...', contentType: 'interactive', order: 2, xpReward: 20, exercisesCount: 3),
      ];

  List<ExerciseModel> _mockExercises() => [
        const ExerciseModel(id: 1, lesson: 1, lessonTitle: 'Hello & Goodbye', questionText: '¿Cómo se dice "Hola" en inglés?', exerciseType: 'multiple_choice', correctAnswer: 'Hello'),
        const ExerciseModel(id: 2, lesson: 1, lessonTitle: 'Hello & Goodbye', questionText: 'Traduce: "I want a cup of coffee, please."', exerciseType: 'translate', correctAnswer: 'Quiero una taza de café, por favor'),
        const ExerciseModel(id: 3, lesson: 1, lessonTitle: 'Hello & Goodbye', questionText: 'Empareja los saludos correctos', exerciseType: 'match', correctAnswer: 'Hello=Hola, Goodbye=Adiós, Good morning=Buenos días'),
        const ExerciseModel(id: 4, lesson: 1, lessonTitle: 'Hello & Goodbye', questionText: 'Escucha el audio y escribe lo que oyes', exerciseType: 'listen', correctAnswer: 'Welcome to JumpUp'),
        const ExerciseModel(id: 5, lesson: 1, lessonTitle: 'Hello & Goodbye', questionText: '¿Cómo se dice "Adiós" en inglés?', exerciseType: 'fill_blank', correctAnswer: 'Goodbye'),
      ];
}
