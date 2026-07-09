import '../repositories/base_repository.dart';
import '../models/progress_models.dart';

/// Servicio para consumir los endpoints de Progreso y Gamificación.
///
/// Endpoints cubiertos:
/// - GET  /api/progress/         — Progreso del usuario
/// - GET  /api/progress/summary/ — Resumen de progreso
/// - POST /api/progress/         — Registrar progreso en lección
/// - GET  /api/stats/            — Estadísticas XP y rachas
/// - GET  /api/achievements/     — Catálogo de logros
/// - GET  /api/my-achievements/  — Logros desbloqueados
/// - GET  /api/ranking/          — Top 100 por XP
class ProgressService extends BaseRepository {
  const ProgressService();

  // ─── Progress ────────────────────────────────────────────────────────────────

  /// Obtiene el resumen completo de progreso del usuario autenticado.
  Future<ProgressSummaryModel> getProgressSummary() async {
    return handleRequest<ProgressSummaryModel>(() async {
      // TODO: final response = await dio.get('/api/progress/summary/');
      return ProgressSummaryModel.fromJson(_mockProgressSummary());
    }, message: 'No se pudo obtener el resumen de progreso');
  }

  /// Obtiene el historial de progreso del usuario.
  Future<List<UserProgressModel>> getUserProgress({String? status}) async {
    return handleRequest<List<UserProgressModel>>(() async {
      // TODO: final response = await dio.get('/api/progress/', queryParameters: {'status': status});
      var progress = _mockUserProgress();
      if (status != null) {
        progress = progress.where((p) => p.status == status).toList();
      }
      return progress;
    }, message: 'No se pudo obtener el progreso');
  }

  /// Registra el progreso del usuario en una lección.
  Future<UserProgressModel> registerProgress({
    required int lessonId,
    required String status,
    double score = 0.0,
  }) async {
    return handleRequest<UserProgressModel>(() async {
      // TODO: final response = await dio.post('/api/progress/', data: {...});
      return UserProgressModel(
        id: DateTime.now().millisecondsSinceEpoch,
        lesson: lessonId,
        status: status,
        score: score,
        completedAt: status == 'completed' ? DateTime.now() : null,
      );
    }, message: 'No se pudo registrar el progreso');
  }

  // ─── Stats ───────────────────────────────────────────────────────────────────

  /// Obtiene las estadísticas del usuario autenticado (XP, nivel, rachas).
  Future<UserStatsModel> getUserStats() async {
    return handleRequest<UserStatsModel>(() async {
      // TODO: final response = await dio.get('/api/stats/');
      return UserStatsModel.fromJson(_mockUserStats());
    }, message: 'No se pudieron obtener las estadísticas');
  }

  // ─── Achievements ─────────────────────────────────────────────────────────

  /// Obtiene el catálogo completo de logros disponibles en la plataforma.
  Future<List<AchievementModel>> getAchievements() async {
    return handleRequest<List<AchievementModel>>(() async {
      // TODO: final response = await dio.get('/api/achievements/');
      return _mockAchievements();
    }, message: 'No se pudieron obtener los logros');
  }

  /// Obtiene los logros desbloqueados por el usuario autenticado.
  Future<List<UserAchievementModel>> getMyAchievements() async {
    return handleRequest<List<UserAchievementModel>>(() async {
      // TODO: final response = await dio.get('/api/my-achievements/');
      return _mockMyAchievements();
    }, message: 'No se pudieron obtener tus logros');
  }

  // ─── Ranking ──────────────────────────────────────────────────────────────

  /// Obtiene el Top 100 de usuarios por XP (tabla de clasificación).
  Future<List<RankingEntryModel>> getRanking() async {
    return handleRequest<List<RankingEntryModel>>(() async {
      // TODO: final response = await dio.get('/api/ranking/');
      return _mockRanking();
    }, message: 'No se pudo obtener el ranking');
  }

  /// Obtiene los retos o misiones del día actual.
  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    return handleRequest<List<Map<String, dynamic>>>(() async {
      // TODO: final response = await dio.get('/api/daily-challenges/');
      return [
        {
          'title': 'Completa 2 lecciones',
          'xpReward': 50,
          'progress': 0.5,
          'current': 1,
          'target': 2,
          'icon': 'menu_book',
          'isCompleted': false,
        },
        {
          'title': 'Obtén 90% en un Quiz',
          'xpReward': 30,
          'progress': 0.0,
          'current': 0,
          'target': 1,
          'icon': 'quiz',
          'isCompleted': false,
        },
        {
          'title': 'Practica 10 minutos con JumpUp AI',
          'xpReward': 40,
          'progress': 1.0,
          'current': 10,
          'target': 10,
          'icon': 'smart_toy',
          'isCompleted': true,
        }
      ];
    }, message: 'No se pudieron obtener los retos diarios');
  }

  /// Descarga el paquete offline para un grupo de lecciones.
  Future<List<int>> getOfflinePack(List<int> lessonIds) async {
    return handleRequest<List<int>>(() async {
      // TODO: final response = await dio.get('/api/lessons/offline-pack/', queryParameters: {'lessons': lessonIds.join(',')});
      return lessonIds;
    }, message: 'No se pudo descargar el paquete offline');
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────

  Map<String, dynamic> _mockProgressSummary() => {
        'total_lessons': 50,
        'lessons_completed': 12,
        'lessons_in_progress': 3,
        'courses_started': 2,
        'courses_completed': 0,
        'percentage': 24.0,
        'total_xp': 240,
        'level': 3,
        'xp_for_next_level': 300,
        'xp_progress': 40,
        'current_streak': 5,
        'longest_streak': 7,
        'achievements_count': 3,
      };

  Map<String, dynamic> _mockUserStats() => {
        'total_xp': 240,
        'level': 3,
        'xp_for_next_level': 300,
        'xp_progress': 40,
        'current_streak': 5,
        'longest_streak': 7,
      };

  List<UserProgressModel> _mockUserProgress() => [
        UserProgressModel(id: 1, lesson: 1, status: 'completed', score: 95.0, completedAt: DateTime.now().subtract(const Duration(days: 1))),
        UserProgressModel(id: 2, lesson: 2, status: 'completed', score: 80.0, completedAt: DateTime.now().subtract(const Duration(hours: 5))),
        UserProgressModel(id: 3, lesson: 3, status: 'in_progress'),
      ];

  List<AchievementModel> _mockAchievements() => [
        const AchievementModel(id: 1, name: 'Primer Paso', description: 'Completa tu primera lección', requiredXp: 0),
        const AchievementModel(id: 2, name: 'En Racha', description: 'Mantén una racha de 7 días', requiredXp: 50),
        const AchievementModel(id: 3, name: 'Explorador', description: 'Completa 10 lecciones', requiredXp: 100),
        const AchievementModel(id: 4, name: 'Dedicado', description: 'Alcanza el nivel 5', requiredXp: 200),
        const AchievementModel(id: 5, name: 'Maestro del Idioma', description: 'Completa un curso completo', requiredXp: 500),
      ];

  List<UserAchievementModel> _mockMyAchievements() => [
        UserAchievementModel(
          id: 1,
          achievement: const AchievementModel(id: 1, name: 'Primer Paso', description: 'Completa tu primera lección', requiredXp: 0),
          unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        UserAchievementModel(
          id: 2,
          achievement: const AchievementModel(id: 3, name: 'Explorador', description: 'Completa 10 lecciones', requiredXp: 100),
          unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  List<RankingEntryModel> _mockRanking() => List.generate(
        10,
        (i) => RankingEntryModel(
          position: i + 1,
          userId: i + 1,
          username: 'usuario_${i + 1}',
          email: 'user${i + 1}@ute.edu.ec',
          totalXp: (10 - i) * 100,
          level: (10 - i),
          currentStreak: (10 - i) * 2,
        ),
      );
}
