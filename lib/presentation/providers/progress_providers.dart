import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/data/repository/auth/progress_repository_impl.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_providers.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return const ProgressService();
});

final progressSummaryProvider =
    FutureProvider<ProgressSummaryModel>((ref) async {
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
  ProgressNotifier(this._service) : super(const AsyncValue.data(null));

  final ProgressService _service;

  Future<void> registerLessonProgress({
    required int lessonId,
    required String status,
    double score = 0.0,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _service.registerProgress(
        lessonId: lessonId,
        status: status,
        score: score,
      );
      
      // Invalidate ALL related providers to force immediate UI refresh
      ref.invalidate(userStatsProvider);
      ref.invalidate(progressSummaryProvider);
      ref.invalidate(rankingProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(myAchievementsProvider);
      
      return result;
    });
  }
}

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<UserProgressModel?>>(
        (ref) {
  return ProgressNotifier(ref.watch(progressServiceProvider));
});

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.getUserStats();
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
  final service = ref.watch(progressServiceProvider);
  return service.getRanking(language: language);
});

final myRankingPositionProvider = FutureProvider<int?>((ref) async {
  final service = ref.watch(progressServiceProvider);
  final ranking = await service.getRanking();
  return ranking.myPosition > 0 ? ranking.myPosition : null;
});

final dailyChallengesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
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
