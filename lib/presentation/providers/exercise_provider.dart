import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';

/// Notificador para crear ejercicios
class ExerciseNotifier extends StateNotifier<AsyncValue<void>> {
  ExerciseNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> createExercise(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = _ref.read(teacherRepositoryProvider);
      await repo.createExercise(data);
    });
  }
}

final exerciseNotifierProvider =
    StateNotifierProvider<ExerciseNotifier, AsyncValue<void>>((ref) {
  return ExerciseNotifier(ref);
});
