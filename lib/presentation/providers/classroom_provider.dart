import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';

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
