import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/teacher_repository.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final TeacherRepository _repo;
  ProfileNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required List<int> languagesLearning,
    required List<int> languagesTeaching,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      languagesLearning: languagesLearning,
      languagesTeaching: languagesTeaching,
    ));
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  return ProfileNotifier(TeacherRepository());
});