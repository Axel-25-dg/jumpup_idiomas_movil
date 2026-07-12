import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/progress_models.dart';
import 'package:jumpup_app/data/repository/auth/progress_repository_impl.dart';
import 'package:jumpup_app/presentation/providers/auth_provider.dart';

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

  Future<void> submitExercise({
    required int exerciseId,
    required String answer,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.submitExercise(
          exerciseId: exerciseId,
          answer: answer,
        ));
  }
}

final exerciseSubmitNotifierProvider =
    StateNotifierProvider<ExerciseSubmitNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return ExerciseSubmitNotifier(ref.watch(progressServiceProvider));
});
