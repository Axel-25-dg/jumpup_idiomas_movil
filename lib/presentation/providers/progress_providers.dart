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
  LocalUserStatsNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  final ProgressService _service;
  final Ref _ref;

  Future<void> _loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _service.getUserStats();
      state = AsyncValue.data(stats ?? UserStatsModel.empty());
    } catch (e, s) {
      debugPrint('Error inicial cargando estadísticas: $e');
      // Para usuarios nuevos, el backend puede devolver 404 o error si no hay stats.
      // Retornamos un modelo vacío para que la UI no se rompa y muestre 0 XP.
      state = AsyncValue.data(UserStatsModel.empty());
    }
  }

  // Update locally (instant feedback)
  void updateXpLocally(int xpChange) {
    final current = state.valueOrNull ?? UserStatsModel.empty();
    
    // Update locally
    final newTotalXp = current.totalXp + xpChange;
      
      // Resilient level logic matching model logic
      const xpPerLevel = 100;
      final newLevel = (newTotalXp ~/ xpPerLevel) + 1;
      final newXpProgress = newTotalXp % xpPerLevel;
      
      state = AsyncValue.data(UserStatsModel(
        totalXp: newTotalXp,
        level: newLevel,
        xpForNextLevel: xpPerLevel,
        xpProgress: newXpProgress,
        xpProgressInLevel: newXpProgress,
        currentStreak: current.currentStreak,
        longestStreak: current.longestStreak,
        lastActivityDate: DateTime.now(),
      ));
      
      // Forzar invalidación inmediata de dependientes
      _ref.invalidate(progressSummaryProvider);
      _ref.invalidate(dashboardSummaryProvider);
      _ref.invalidate(rankingProvider);
      _ref.invalidate(myAchievementsProvider);
      
      debugPrint('Optimistic Update: XP +$xpChange -> New Total: $newTotalXp');
    }
  }

  // Force a full refresh from backend
  Future<void> refresh() async {
    // No ponemos loading aquí para evitar parpadeo si ya tenemos datos optimistas
    try {
      final stats = await _service.getUserStats();
      state = AsyncValue.data(stats ?? UserStatsModel.empty());
    } catch (e, s) {
      debugPrint('Error refrescando estadísticas: $e');
      // Si falla, nos aseguramos de tener al menos el modelo vacío si no hay nada
      if (state.valueOrNull == null) {
        state = AsyncValue.data(UserStatsModel.empty());
      }
    }
  }
}

final localUserStatsProvider =
    StateNotifierProvider<LocalUserStatsNotifier, AsyncValue<UserStatsModel?>>(
        (ref) {
      return LocalUserStatsNotifier(ref.watch(progressServiceProvider), ref);
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
    // Determine effective XP to show feedback
    final effectiveXp = xpEarned > 0 ? xpEarned : score.toInt();
    
    // 1. Update local cache first (Optimistic Update)
    if (effectiveXp != 0) {
      _ref.read(localUserStatsProvider.notifier).updateXpLocally(effectiveXp);
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 2. Registrar progreso de la lección
      final result = await _service.registerProgress(
        lessonId: lessonId,
        status: status,
        score: score,
      );
      
      // 3. Sumar XP en el backend específicamente
      if (xpEarned != 0) {
        try {
          await _service.modifyXp(xpChange: xpEarned);
        } catch (e) {
          debugPrint('Error sumando XP al backend: $e');
        }
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
    
    // Forzar actualización de stats locales desde el servidor
    Future.microtask(() => _ref.read(localUserStatsProvider.notifier).refresh());
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
    data: (stats) => AsyncValue.data(stats ?? UserStatsModel.empty()),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.data(UserStatsModel.empty()),
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
