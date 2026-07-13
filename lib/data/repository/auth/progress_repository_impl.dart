import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class ProgressService extends BaseRepository {
  const ProgressService();

  Future<ProgressSummaryModel> getProgressSummary() async {
    return getOne('progress/summary/', ProgressSummaryModel.fromJson,
        message: 'No se pudo obtener el resumen de progreso');
  }

  Future<List<UserProgressModel>> getUserProgress({String? status}) async {
    final params = status != null ? {'status': status} : null;
    return getList('progress/', UserProgressModel.fromJson,
        queryParameters: params, message: 'No se pudo obtener el progreso');
  }

  Future<List<ProgressByLanguage>> getProgressByLanguage() async {
    return getList('progress/by-language/', ProgressByLanguage.fromJson,
        message: 'No se pudo obtener el progreso por idioma');
  }

  Future<UserProgressModel> registerProgress({
    required int lessonId,
    required String status,
    double score = 0.0,
  }) async {
    return createOne('progress/', UserProgressModel.fromJson,
        data: {
          'lesson': lessonId,
          'status': status,
          'score': score,
        },
        message: 'No se pudo registrar el progreso');
  }

  Future<UserStatsModel> getUserStats() async {
    return getOne('stats/', UserStatsModel.fromJson,
        message: 'No se pudieron obtener las estadísticas');
  }

  Future<List<AchievementModel>> getAchievements() async {
    return getList('achievements/', AchievementModel.fromJson,
        message: 'No se pudieron obtener los logros');
  }

  Future<List<UserAchievementModel>> getMyAchievements() async {
    return getList('my-achievements/', UserAchievementModel.fromJson,
        message: 'No se pudieron obtener tus logros');
  }

  Future<RankingModel> getRanking({String? language}) async {
    final params = language != null ? {'language': language} : null;
    return getOne('ranking/', RankingModel.fromJson,
        queryParameters: params,
        message: 'No se pudo obtener el ranking');
  }

  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    return handleRequest<List<Map<String, dynamic>>>(() async {
      // El backend no tiene endpoint daily-challenges/.
      // Los construimos en base a stats y logros del usuario.
      final statsResp = await dio.get<dynamic>('stats/');
      final statsData = statsResp.data is Map<String, dynamic>
          ? statsResp.data as Map<String, dynamic>
          : <String, dynamic>{};

      final currentXp = (statsData['total_xp'] ?? statsData['xp'] ?? 0) as int;
      final streak = (statsData['current_streak'] ?? statsData['streak'] ?? 0) as int;

      // Reto 1: completar una lección hoy
      final progressResp = await dio.get<dynamic>(
        'progress/',
        queryParameters: {'page_size': 5},
      );
      final progressList = progressResp.data is List
          ? progressResp.data as List
          : (progressResp.data is Map && progressResp.data['results'] is List
              ? progressResp.data['results'] as List
              : []);
      final completedToday = progressList.where((p) {
        if (p is! Map) return false;
        final updated = p['updated_at']?.toString() ?? p['completed_at']?.toString() ?? '';
        if (updated.isEmpty) return false;
        final date = DateTime.tryParse(updated);
        if (date == null) return false;
        final now = DateTime.now();
        return date.year == now.year && date.month == now.month && date.day == now.day;
      }).length;

      return [
        {
          'title': 'Completa una lección hoy',
          'xpReward': 50,
          'progress': (completedToday >= 1 ? 1.0 : completedToday.toDouble()),
          'current': completedToday.clamp(0, 1),
          'target': 1,
          'icon': 'menu_book',
          'isCompleted': completedToday >= 1,
        },
        {
          'title': 'Mantén tu racha diaria',
          'xpReward': 30,
          'progress': streak > 0 ? 1.0 : 0.0,
          'current': streak > 0 ? 1 : 0,
          'target': 1,
          'icon': 'quiz',
          'isCompleted': streak > 0,
        },
        {
          'title': 'Gana 20 XP hoy',
          'xpReward': 20,
          'progress': (currentXp % 100).clamp(0, 20) / 20.0,
          'current': (currentXp % 100).clamp(0, 20),
          'target': 20,
          'icon': 'smart_toy',
          'isCompleted': (currentXp % 100) >= 20,
        },
      ];
    }, message: 'No se pudieron obtener los retos diarios');
  }

  Future<Map<String, dynamic>> submitExercise({
    required int exerciseId,
    required String answer,
  }) async {
    return handleRequest<Map<String, dynamic>>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        'exercises/$exerciseId/validar/',
        data: {'respuesta_usuario': answer},
      );
      return response.data!;
    }, message: 'No se pudo enviar la respuesta');
  }

  Future<List<int>> getOfflinePack(List<int> lessonIds) async {
    return handleRequest<List<int>>(() async {
      final response = await dio.get<dynamic>(
        'lessons/offline-pack/',
        queryParameters: {'lessons': lessonIds.join(',')},
      );
      final data = response.data;
      if (data is List) return data.cast<int>();
      return lessonIds;
    }, message: 'No se pudo descargar el paquete offline');
  }

  Future<UserStatsModel> modifyXp({required int xpChange}) async {
    return handleRequest<UserStatsModel>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        'stats/add_xp/',
        data: {'xp_to_add': xpChange},
      );
      return UserStatsModel.fromJson(response.data!);
    }, message: 'No se pudo sumar el XP');
  }
}
