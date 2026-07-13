import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/data/repository/auth/progress_repository_impl.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

// Local cache for user stats to update instantly
class LocalUserStatsNotifier extends StateNotifier<AsyncValue<UserStatsModel?>> {
  LocalUserStatsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  final ProgressService _service;

  Future<void> _loadStats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getUserStats());
  }

  // Update locally (instant feedback)
  void updateXpLocally(int xpChange) {
    final current = state.valueOrNull;
    if (current != null) {
      // Update locally
      final newTotalXp = current.totalXp + xpChange;
      // Simple level logic: every 100 XP is a level
      final newLevel = (newTotalXp ~/ 100) + 1;
      final newXpProgress = newTotalXp % 100;
      
      state = AsyncValue.data(UserStatsModel(
        totalXp: newTotalXp,
        level: newLevel,
        xpForNextLevel: 100,
        xpProgress: newXpProgress, // Corregido: antes era newTotalXp
        xpProgressInLevel: newXpProgress,
        currentStreak: current.currentStreak,
        longestStreak: current.longestStreak,
        lastActivityDate: DateTime.now(),
      ));
    }
  }

  // Force a full refresh from backend
  Future<void> refresh() async {
    // No ponemos loading aquí para evitar parpadeo si ya tenemos datos optimistas
    try {
      final stats = await _service.getUserStats();
      state = AsyncValue.data(stats);
    } catch (e, s) {
      debugPrint('Error refrescando estadísticas: $e');
      // Si falla, mantenemos lo que tenemos o cargamos de cero si estaba vacío
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, s);
      }
    }
  }
}

final localUserStatsProvider =
    StateNotifierProvider<LocalUserStatsNotifier, AsyncValue<UserStatsModel?>>(
        (ref) {
      return LocalUserStatsNotifier(ref.watch(progressServiceProvider));
    });

final progressSummaryProvider =
    FutureProvider<ProgressSummaryModel>((ref) async {
  // Listen to local stats to refresh summary
  ref.watch(localUserStatsProvider);
  final service = ref.watch(progressServiceProvider);
  return service.getProgressSummary();
});

final userProgressProvider =
    FutureProvider.family<List<UserProgressModel>, String?>(
        (ref, status) async {
      final service = ref.watch(progressServiceProvider);
      return service.getUserProgress(status: status);
    });

class ProgressNotifier extends StateNotifier<AsyncValue<UserProgressModel?>> {
  ProgressNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  final ProgressService _service;
  final Ref _ref;

  Future<void> registerLessonProgress({
    required int lessonId,
    required String status,
    double score = 0.0,
    int xpEarned = 0,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Registrar progreso de la lección
      final result = await _service.registerProgress(
        lessonId: lessonId,
        status: status,
        score: score,
      );
      
      // 2. Sumar XP en el backend específicamente
      if (xpEarned != 0) {
        try {
          await _service.modifyXp(xpChange: xpEarned);
        } catch (e) {
          // Ignorar error de suma de XP si el progreso ya se guardó, 
          // pero loguearlo para depuración
          debugPrint('Error sumando XP al backend: $e');
        }
      }
      
      // 3. Actualizar caché local para feedback instantáneo
      final effectiveXp = xpEarned > 0 ? xpEarned : score.toInt();
      if (effectiveXp != 0) { // Permitir XP negativo (pérdidas)
        _ref.read(localUserStatsProvider.notifier).updateXpLocally(effectiveXp);
      }
      
      // 4. Invalidar todos los proveedores para forzar recarga de datos reales
      _invalidateAll();
      
      return result;
    });
  }

  void _invalidateAll() {
    _ref.invalidate(progressSummaryProvider);
    _ref.invalidate(rankingProvider);
    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(myAchievementsProvider);
    _ref.invalidate(userProfileProvider);
    _ref.invalidate(dailyChallengesProvider);
    _ref.read(localUserStatsProvider.notifier).refresh();
  }
}

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<UserProgressModel?>>(
        (ref) {
      return ProgressNotifier(ref.watch(progressServiceProvider), ref);
    });

// Sincronizar userStatsProvider con localUserStatsProvider para que la UI vea los cambios optimistas
final userStatsProvider = Provider<AsyncValue<UserStatsModel>>((ref) {
  final local = ref.watch(localUserStatsProvider);
  return local.when(
    data: (stats) => stats != null 
        ? AsyncValue.data(stats) 
        : const AsyncValue.loading(),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final progressByLanguageProvider =
    FutureProvider<List<ProgressByLanguage>>((ref) async {
      final service = ref.watch(progressServiceProvider);
      return service.getProgressByLanguage();
    });

final achievementsProvider =
    FutureProvider<List<AchievementModel>>((ref) async {
      final service = ref.watch(progressServiceProvider);
      return service.getAchievements();
    });

final myAchievementsProvider =
    FutureProvider<List<UserAchievementModel>>((ref) async {
      final service = ref.watch(progressServiceProvider);
      return service.getMyAchievements();
    });

final rankingProvider = FutureProvider.family<RankingModel, String?>((ref, language) async {
  // Refresh ranking when local stats change
  ref.watch(localUserStatsProvider);
  final service = ref.watch(progressServiceProvider);
  return service.getRanking(language: language);
});

final myRankingPositionProvider = FutureProvider<int?>((ref) async {
  // Refresh my position when local stats change
  ref.watch(localUserStatsProvider);
  final service = ref.watch(progressServiceProvider);
  final ranking = await service.getRanking();
  return ranking.myPosition > 0 ? ranking.myPosition : null;
});

final dailyChallengesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      // Re-fetch when stats change locally
      ref.watch(localUserStatsProvider);
      final service = ref.watch(progressServiceProvider);
      return service.getDailyChallenges();
    });

class ExerciseSubmitNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  ExerciseSubmitNotifier(this._service) : super(const AsyncValue.data(null));

  final ProgressService _service;

  Future<Map<String, dynamic>?> submitExercise({
    required int exerciseId,
    required String answer,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.submitExercise(
        exerciseId: exerciseId,
        answer: answer,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final exerciseSubmitNotifierProvider =
    StateNotifierProvider<ExerciseSubmitNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
      return ExerciseSubmitNotifier(ref.watch(progressServiceProvider));
    });

class GameXpNotifier extends StateNotifier<AsyncValue<void>> {
  GameXpNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  final ProgressService _service;
  final Ref _ref;

  Future<void> modifyXp({
    required int xpChange,
  }) async {
    if (xpChange <= 0) return;
    
    // First update local for instant feedback
    _ref.read(localUserStatsProvider.notifier).updateXpLocally(xpChange);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.modifyXp(xpChange: xpChange);
      
      // After backend call, refresh local stats to be sure we are in sync
      await _ref.read(localUserStatsProvider.notifier).refresh();
      
      // Invalidate everything else
      _invalidateAll();
    });
  }

  void _invalidateAll() {
    _ref.invalidate(progressSummaryProvider);
    _ref.invalidate(rankingProvider);
    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(myAchievementsProvider);
    _ref.invalidate(userStatsProvider);
    _ref.invalidate(dailyChallengesProvider);
  }
}

final gameXpNotifierProvider =
    StateNotifierProvider<GameXpNotifier, AsyncValue<void>>(
        (ref) {
      return GameXpNotifier(ref.watch(progressServiceProvider), ref);
    });
