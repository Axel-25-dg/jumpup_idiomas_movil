// lib/presentation/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/user_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';


final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<List<User>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).users;
  return UserNotifier(repository);
});

class UserNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchAllUsers();
  }

  // ─── STAFF ──────────────────────────────────────────────────────

  Future<List<User>> fetchUsers() async {
    try {
      final users = await _repository.fetchUsers();
      return users;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _repository.createUser(data);
      await fetchAllUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateUser(id, data);
      await fetchAllUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      await fetchAllUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ─── ESTUDIANTES ──────────────────────────────────────────────────

  Future<List<User>> fetchStudents() async {
    try {
      final students = await _repository.fetchStudents();
      return students;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudent(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateStudent(id, data);
      await fetchAllUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _repository.deleteStudent(id);
      await fetchAllUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ─── COMUNES ──────────────────────────────────────────────────────

  Future<void> fetchAllUsers() async {
    state = const AsyncValue.loading();
    try {
      final staff = await _repository.fetchUsers();
      final students = await _repository.fetchStudents();
      final allUsers = [...staff, ...students];
      state = AsyncValue.data(allUsers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleUserStatus(int id, bool isActive) async {
    try {
      await _repository.toggleUserStatus(id, isActive);
      await fetchAllUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> changeUserRole(int id, int roleId) async {
    try {
      await _repository.changeUserRole(id, roleId);
      await fetchAllUsers();
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
    await fetchAllUsers();
  }
}

// Providers de solo lectura
final usersProvider = FutureProvider<List<User>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).users;
  return repository.fetchUsers();
});

final studentsProvider = FutureProvider<List<User>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).users;
  return repository.fetchStudents();
});