import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/teacher_repository.dart';

class ExerciseNotifier extends StateNotifier<AsyncValue<void>> {
  final TeacherRepository _repo;
  ExerciseNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> createExercise(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createExercise(data));
  }
}

final exerciseNotifierProvider = StateNotifierProvider<ExerciseNotifier, AsyncValue<void>>((ref) {
  return ExerciseNotifier(TeacherRepository());
});