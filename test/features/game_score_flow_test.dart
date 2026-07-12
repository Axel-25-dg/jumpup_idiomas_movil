import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/data/repository/auth/progress_service.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';

class _MockProgressAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  int scoreSubmitted = 0;
  
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    
    if (options.method == 'POST' && options.path == 'progress/') {
      final data = options.data as Map<String, dynamic>;
      scoreSubmitted = (data['score'] as num).toInt();
      return ResponseBody.fromString(
        jsonEncode({
          'id': 1,
          'lesson': data['lesson'],
          'status': data['status'],
          'score': data['score'],
          'updated_at': DateTime.now().toIso8601String(),
        }),
        201,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );
    }
    
    if (options.method == 'GET' && options.path == 'stats/') {
      return ResponseBody.fromString(
        jsonEncode({
          'total_xp': 500 + scoreSubmitted,
          'current_streak': 5,
          'level': 3,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );
    }

    if (options.method == 'GET' && options.path == 'ranking/') {
      return ResponseBody.fromString(
        jsonEncode([
          {'user_id': 1, 'username': 'TestUser', 'total_xp': 500 + scoreSubmitted, 'position': 1},
          {'user_id': 2, 'username': 'Other', 'total_xp': 400, 'position': 2},
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
  group('Game Score and Ranking Flow', () {
    late ProgressService progressService;
    late _MockProgressAdapter dioAdapter;
    late Dio dio;

    setUp(() {
      dio = Dio();
      dioAdapter = _MockProgressAdapter();
      dio.httpClientAdapter = dioAdapter;
      progressService = ProgressService();
      // Inyectamos el dio mockeado. Como ProgressService extiende BaseRepository 
      // y BaseRepository tiene un constructor con Dio?, podemos hacerlo.
      // Pero ProgressService no expone el dio directamente, usa el singleton o el inyectado.
      // Mirando progress_service.dart, usa BaseRepository.
    });

    // Nota: Para que el test funcione con la implementación actual, 
    // necesitamos que ProgressService use la instancia de Dio configurada.
    // BaseRepository suele usar un interceptor o una instancia global si no se pasa.
    
    test('Submitting a game score updates user stats and ranking', () async {
      final service = ProgressServiceTestable(dio);

      // 1. Submit score (simulating game completion)
      const gameScore = 150.0;
      await service.registerProgress(
        lessonId: 1, 
        status: 'completed',
        score: gameScore,
      );

      // 2. Verify POST request
      final postReq = dioAdapter.requests.firstWhere((r) => r.method == 'POST' && r.path == 'progress/');
      expect(postReq.data['score'], gameScore);

      // 3. Fetch stats and verify XP increase
      final stats = await service.getUserStats();
      expect(stats.totalXp, 650);

      // 4. Fetch ranking and verify updated position/score
      final ranking = await service.getRanking();
      expect(ranking.first.totalXp, 650);
      expect(ranking.first.username, 'TestUser');
    });
  });
}

// Helper class to inject Dio into ProgressService for testing
class ProgressServiceTestable extends ProgressService {
  final Dio _testDio;
  ProgressServiceTestable(this._testDio);
  
  @override
  Dio get dio => _testDio;
}
