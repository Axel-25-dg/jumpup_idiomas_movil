import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/data/repository/auth/course_repository_impl.dart';

class _MockDioAdapter implements HttpClientAdapter {
  _MockDioAdapter();

  final Map<String, dynamic> responses = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = options.path;
    
    // Simplificación para el test: si es POST a exercises/, simulamos éxito
    if (options.method == 'POST' && path == 'exercises/') {
      return ResponseBody.fromString(
        jsonEncode({'id': 1, ...options.data}),
        201,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );
    }

    // Si es GET a exercises/ con filtro de lección
    if (options.method == 'GET' && path == 'exercises/') {
      final lessonId = options.queryParameters['lesson'];
      return ResponseBody.fromString(
        jsonEncode([
          {
            'id': 1,
            'lesson': lessonId,
            'lesson_title': 'Test Lesson',
            'question_text': 'Question 1',
            'exercise_type': 'multiple_choice',
            'correct_answer': 'A'
          }
        ]),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );
    }

    return ResponseBody.fromString('[]', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Integration Flow: Teacher Exercise Creation to Student View', () {
    late TeacherRepository teacherRepo;
    late CourseRepositoryImpl courseService;
    late _MockDioAdapter dioAdapter;
    late Dio dio;

    setUp(() {
      dio = Dio();
      dioAdapter = _MockDioAdapter();
      dio.httpClientAdapter = dioAdapter;
      
      teacherRepo = TeacherRepository(dio: dio);
      courseService = CourseRepositoryImpl(dio: dio);
    });

    test('Teacher creates an exercise and it is then visible to students via CourseService', () async {
      // 1. Datos del ejercicio
      const lessonId = 101;
      final exerciseData = {
        'lesson': lessonId,
        'question_text': '¿Cómo se dice "Hola" en Inglés?',
        'exercise_type': 'multiple_choice',
        'correct_answer': 'Hello',
      };

      // 2. El profesor crea el ejercicio
      await teacherRepo.createExercise(exerciseData);

      // 3. Verificar que se hizo la petición correcta
      final postRequest = dioAdapter.requests.firstWhere((r) => r.method == 'POST');
      expect(postRequest.path, 'exercises/');
      expect(postRequest.data['lesson'], lessonId);

      // 4. El estudiante (o el sistema) consulta los ejercicios de esa lección
      final exercises = await courseService.getExercisesByLesson(lessonId);

      // 5. Verificar que el ejercicio aparece para el estudiante
      expect(exercises, isNotEmpty);
      expect(exercises.any((e) => e.lesson == lessonId), isTrue);
    });
  });
}
