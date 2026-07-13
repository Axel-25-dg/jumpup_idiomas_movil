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
      final cached = await _service.loadLocalStats();
      if (cached != null) {
        state = AsyncValue.data(cached);
      }
      final stats = await _service.getUserStats();
      final finalStats = stats ?? cached ?? UserStatsModel.empty();
      await _service.saveLocalStats(finalStats);
      state = AsyncValue.data(finalStats);
    } catch (e, s) {
      debugPrint('Error inicial cargando estadísticas: $e');
      final cached = await _service.loadLocalStats();
      state = AsyncValue.data(cached ?? UserStatsModel.empty());
    }
  }

  // Update locally (instant feedback)
  void updateXpLocally(int xpChange) {
    final current = state.valueOrNull ?? UserStatsModel.empty();
    
    final newTotalXp = current.totalXp + xpChange;
    const xpPerLevel = 100;
    final newLevel = (newTotalXp ~/ xpPerLevel) + 1;
    final newXpProgress = newTotalXp % xpPerLevel;
    
    final updatedStats = UserStatsModel(
      totalXp: newTotalXp,
      level: newLevel,
      xpForNextLevel: xpPerLevel,
      xpProgress: newXpProgress,
      xpProgressInLevel: newXpProgress,
      currentStreak: current.currentStreak,
      longestStreak: current.longestStreak,
      lastActivityDate: DateTime.now(),
    );
    state = AsyncValue.data(updatedStats);
    _service.saveLocalStats(updatedStats);
    
    // Invalidate dependents
    _ref.invalidate(progressSummaryProvider);
    _ref.invalidate(dashboardSummaryProvider);
    _ref.invalidate(rankingProvider);
    _ref.invalidate(myAchievementsProvider);
    
    debugPrint('Optimistic Update: XP +$xpChange -> New Total: $newTotalXp');
  }

  // Force a full refresh from backend
  Future<void> refresh() async {
    try {
      final stats = await _service.getUserStats();
      final finalStats = stats ?? UserStatsModel.empty();
      await _service.saveLocalStats(finalStats);
      state = AsyncValue.data(finalStats);
    } catch (e) {
      debugPrint('Error refrescando estadísticas: $e');
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
    final effectiveXp = xpEarned > 0 ? xpEarned : score.toInt();
    
    if (effectiveXp != 0) {
      _ref.read(localUserStatsProvider.notifier).updateXpLocally(effectiveXp);
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _service.registerProgress(
        lessonId: lessonId,
        status: status,
        score: score,
      );
      
      if (xpEarned != 0) {
        try {
          await _service.modifyXp(xpChange: xpEarned);
        } catch (e) {
          debugPrint('Error sumando XP al backend: $e');
        }
      }
      
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
    
    Future.microtask(() => _ref.read(localUserStatsProvider.notifier).refresh());
  }
}

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<UserProgressModel?>>(
        (ref) {
      return ProgressNotifier(ref.watch(progressServiceProvider), ref);
    });

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
  ref.watch(localUserStatsProvider);
  final service = ref.watch(progressServiceProvider);
  return service.getRanking(language: language);
});

final myRankingPositionProvider = FutureProvider<int?>((ref) async {
  ref.watch(localUserStatsProvider);
  final service = ref.watch(progressServiceProvider);
  final ranking = await service.getRanking();
  return ranking.myPosition > 0 ? ranking.myPosition : null;
});

final dailyChallengesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
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
    
    _ref.read(localUserStatsProvider.notifier).updateXpLocally(xpChange);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.modifyXp(xpChange: xpChange);
      await _ref.read(localUserStatsProvider.notifier).refresh();
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
