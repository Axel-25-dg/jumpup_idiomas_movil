import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin_user_model.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';

class UserListNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final TeacherRepository _repo;

  UserListNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.fetchUsers());
  }

  Future<void> updateUserStatus(int id, bool isActive) async {
    // Optimistic update podría ir aquí, pero por seguridad esperamos al server
    await _repo.updateUser(id, {'is_active': isActive});
    await fetchUsers(); // Recargamos para reflejar cambios
  }
}

final userListProvider =
    StateNotifierProvider<UserListNotifier, AsyncValue<List<User>>>((ref) {
  return UserListNotifier(TeacherRepository());
});
