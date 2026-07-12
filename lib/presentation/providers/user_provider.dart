// lib/presentation/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/user_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<List<User>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).users;
  return UserNotifier(repository);
});

class UserNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _repository.fetchUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUser(Map<String, dynamic> data) async {
    try {
      await _repository.createUser(data);
      await fetchUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateUser(id, data);
      await fetchUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((u) => u.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleUserStatus(int id, bool isActive) async {
    try {
      await _repository.toggleUserStatus(id, isActive);
      await fetchUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> changeUserRole(int id, int roleId) async {
    try {
      await _repository.changeUserRole(id, roleId);
      await fetchUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<User?> getUserById(int id) async {
    try {
      return await _repository.getUserById(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    await fetchUsers();
  }
}

// Provider de solo lectura
final usersProvider = FutureProvider<List<User>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).users;
  return repository.fetchUsers();
});
