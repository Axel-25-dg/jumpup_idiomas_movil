import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/media_progress_model.dart';
import 'package:jumpup_app/data/repository/auth/media_progress_service.dart';

final mediaProgressServiceProvider = Provider<MediaProgressService>((ref) {
  return const MediaProgressService();
});

final mediaProgressProvider =
    FutureProvider.family<MediaProgressModel?, int>((ref, lessonId) async {
  final service = ref.watch(mediaProgressServiceProvider);
  return service.getProgress(lessonId);
});

class MediaProgressNotifier
    extends StateNotifier<AsyncValue<MediaProgressModel?>> {
  MediaProgressNotifier(this._service) : super(const AsyncValue.data(null));

  final MediaProgressService _service;
  int? _currentLessonId;

  Future<void> loadProgress(int lessonId) async {
    _currentLessonId = lessonId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getProgress(lessonId));
  }

  Future<void> saveProgress({
    required int positionSeconds,
    required int durationSeconds,
    bool completed = false,
  }) async {
    if (_currentLessonId == null) return;
    state = await AsyncValue.guard(() => _service.saveProgress(
          lessonId: _currentLessonId!,
          positionSeconds: positionSeconds,
          durationSeconds: durationSeconds,
          completed: completed,
        ));
  }
}

final mediaProgressNotifierProvider = StateNotifierProvider<
    MediaProgressNotifier, AsyncValue<MediaProgressModel?>>((ref) {
  return MediaProgressNotifier(ref.watch(mediaProgressServiceProvider));
});
