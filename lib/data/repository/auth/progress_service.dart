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

  Future<List<RankingEntryModel>> getRanking() async {
    return getList('ranking/', RankingEntryModel.fromJson,
        message: 'No se pudo obtener el ranking');
  }

  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    return handleRequest<List<Map<String, dynamic>>>(() async {
      final response = await dio.get<dynamic>('daily-challenges/');
      final data = response.data;
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    }, message: 'No se pudieron obtener los retos diarios');
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
}
