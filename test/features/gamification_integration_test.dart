import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/data/repository/auth/progress_repository_impl.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';

class _MockGamificationAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  int currentXp = 0;
  int currentStreak = 0;
  bool firstStatsCall = true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    
    if (options.method == 'GET' && options.path == 'stats/') {
      if (firstStatsCall) {
        firstStatsCall = false;
        // Simular usuario nuevo (404 o vacio)
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Not found.'}),
          404,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({
          'total_xp': currentXp,
          'current_streak': currentStreak,
          'level': (currentXp ~/ 100) + 1,
          'xp_for_next_level': 100,
          'xp_progress': currentXp % 100,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );
    }
    
    if (options.method == 'POST' && options.path == 'stats/add_xp/') {
      final data = options.data as Map<String, dynamic>;
      final xpToAdd = data['xp_to_add'] as int;
      currentXp += xpToAdd;
      if (currentStreak == 0) currentStreak = 1;
      
      return ResponseBody.fromString(
        jsonEncode({
          'total_xp': currentXp,
          'current_streak': currentStreak,
          'level': (currentXp ~/ 100) + 1,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );
    }

    if (options.method == 'POST' && options.path == 'progress/') {
      return ResponseBody.fromString(
        jsonEncode({'status': 'success'}),
        201,
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

class ProgressServiceTestable extends ProgressService {
  final Dio _testDio;
  ProgressServiceTestable(this._testDio);
  @override
  Dio get dio => _testDio;
}

void main() {
  group('Gamification Integration Flow', () {
    late ProgressService service;
    late _MockGamificationAdapter dioAdapter;
    late Dio dio;

    setUp(() {
      dio = Dio();
      dioAdapter = _MockGamificationAdapter();
      dio.httpClientAdapter = dioAdapter;
      service = ProgressServiceTestable(dio);
    });

    test('New user stats should be resilient (404 -> ApiException)', () async {
      try {
        await service.getUserStats();
        fail('Should have thrown ApiException');
      } catch (e) {
        // El BaseRepository extrae el mensaje del cuerpo del error si existe
        expect(e.toString(), contains('Not found.'));
      }
    });

    test('Winning XP in a game should update total XP and initialize streak', () async {
      // Simular la primera ganancia de XP
      const xpEarned = 50;
      
      // Llamada al backend para sumar XP
      final statsAfter = await service.modifyXp(xpChange: xpEarned);
      
      expect(statsAfter.totalXp, xpEarned);
      expect(statsAfter.currentStreak, 1); // Streak initialized to 1
      
      // Verificar que se hizo el POST correcto
      final postReq = dioAdapter.requests.firstWhere((r) => r.path == 'stats/add_xp/');
      expect(postReq.data['xp_to_add'], xpEarned);
    });
  });
}
