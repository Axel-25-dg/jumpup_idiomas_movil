import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_join_request_model.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

/// Provider para obtener la lista de aulas.
/// Si necesitas filtrar o buscar, puedes convertirlo a un [AsyncNotifierProvider].
final classroomsListProvider = FutureProvider<List<ClassroomModel>>((ref) async {
  final repo = ref.read(teacherRepositoryProvider);
  final list = await repo.fetchAllClassrooms();
  // Filter out inactive (soft-deleted) classrooms returned by the API
  final filtered = list.where((c) => c.isActive).toList();
  // ignore: avoid_print
  print('classroomsListProvider: original=${list.length}, filtered=${filtered.length}');
  return filtered;
});

/// Notificador para acciones CRUD sobre Aulas (Crear, Editar, Borrar)
class ClassroomNotifier extends StateNotifier<AsyncValue<ClassroomModel?>> {
  final TeacherRepository _repo;
  ClassroomNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> create(String name, String desc, int courseId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.createClassroom(
          name: name,
          description: desc,
          courseId: courseId,
        ));
  }

  Future<void> update(int id, String name, String desc, int courseId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.updateClassroom(
          id: id,
          name: name,
          description: desc,
          courseId: courseId,
        ));
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteClassroom(id);
      return null;
    });
  }
}

final classroomNotifierProvider =
    StateNotifierProvider<ClassroomNotifier, AsyncValue<ClassroomModel?>>((ref) {
  return ClassroomNotifier(ref.read(teacherRepositoryProvider));
});

/// Provider de la lista de solicitudes de ingreso para un aula en específico.
final classroomJoinRequestsProvider = FutureProvider.family<List<ClassroomJoinRequest>, int>((ref, classroomId) async {
  final repo = ref.read(teacherRepositoryProvider);
  return await repo.fetchJoinRequests(classroomId);
});

/// Notificador para Aprobar / Rechazar solicitudes de ingreso a aulas.
class ClassroomJoinRequestsNotifier extends StateNotifier<AsyncValue<void>> {
  final TeacherRepository _repo;
  final Ref _ref;

  ClassroomJoinRequestsNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<void> approveRequest(int classroomId, int requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.approveJoinRequest(classroomId: classroomId, requestId: requestId);
      _ref.invalidate(classroomJoinRequestsProvider(classroomId));
    });
  }

  Future<void> rejectRequest(int classroomId, int requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.rejectJoinRequest(classroomId: classroomId, requestId: requestId);
      _ref.invalidate(classroomJoinRequestsProvider(classroomId));
    });
  }

  Future<void> requestJoin(int classroomId, String? message) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.requestJoin(classroomId: classroomId, message: message);
    });
  }
}

final classroomJoinRequestsNotifierProvider = StateNotifierProvider<ClassroomJoinRequestsNotifier, AsyncValue<void>>((ref) {
  return ClassroomJoinRequestsNotifier(ref.read(teacherRepositoryProvider), ref);
});
