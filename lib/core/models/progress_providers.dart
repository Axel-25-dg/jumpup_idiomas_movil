import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_models.dart';
import '../auth/services/progress_service.dart';

// ─── Providers de Servicio ───────────────────────────────────────────────────

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

// ─── Progress Providers ──────────────────────────────────────────────────────

/// Provider para el resumen de progreso del usuario.
final progressSummaryProvider = FutureProvider<ProgressSummaryModel>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.getProgressSummary();
});

/// Provider para el historial de progreso filtrado por estado.
final userProgressProvider =
    FutureProvider.family<List<UserProgressModel>, String?>((ref, status) async {
  final service = ref.watch(progressServiceProvider);
  return service.getUserProgress(status: status);
});

/// Notifier para registrar progreso en tiempo real.
class ProgressNotifier extends StateNotifier<AsyncValue<UserProgressModel?>> {
  ProgressNotifier(this._service) : super(const AsyncValue.data(null));

  final ProgressService _service;

  Future<void> registerLessonProgress({
    required int lessonId,
    required String status,
    double score = 0.0,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.registerProgress(
          lessonId: lessonId,
          status: status,
          score: score,
        ));
  }
}

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<UserProgressModel?>>((ref) {
  return ProgressNotifier(ref.watch(progressServiceProvider));
});

// ─── Stats Providers ─────────────────────────────────────────────────────────

/// Provider para las estadísticas XP, nivel y rachas del usuario.
final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.getUserStats();
});

// ─── Achievement Providers ───────────────────────────────────────────────────

/// Provider para el catálogo completo de logros.
final achievementsProvider = FutureProvider<List<AchievementModel>>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.getAchievements();
});

/// Provider para los logros desbloqueados por el usuario.
final myAchievementsProvider = FutureProvider<List<UserAchievementModel>>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.getMyAchievements();
});

// ─── Ranking Providers ───────────────────────────────────────────────────────

/// Provider para el Top 100 de usuarios por XP.
final rankingProvider = FutureProvider<List<RankingEntryModel>>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.getRanking();
});

/// Posición del usuario actual en el ranking (calculada del lado del cliente).
final myRankingPositionProvider = FutureProvider<int?>((ref) async {
  final rankingAsync = await ref.watch(rankingProvider.future);
  // TODO: Comparar con el userId del usuario autenticado
  // Para demo retorna null si no se encuentra
  return rankingAsync.isEmpty ? null : rankingAsync.first.position;
});
