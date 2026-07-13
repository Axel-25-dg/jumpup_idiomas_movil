import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

/// Provider para obtener la lista de aulas.
final classroomsListProvider = FutureProvider<List<ClassroomModel>>((ref) async {
  final repo = ref.read(teacherRepositoryProvider);
  final list = await repo.fetchAllClassrooms();
  // Filter out inactive (soft-deleted) classrooms returned by the API
  final filtered = list.where((c) => c.isActive).toList();
  return filtered;
});

/// Notificador para acciones CRUD sobre Aulas (Crear, Editar, Borrar)
class ClassroomNotifier extends StateNotifier<AsyncValue<List<ClassroomModel>>> {
  final TeacherRepository _repo;

  ClassroomNotifier(this._repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final list = await _repo.fetchAllClassrooms();
      return list.where((c) => c.isActive).toList();
    });
  }

  Future<void> addClassroom({
    required String name,
    required String description,
    required int courseId,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repo.createClassroom(
          name: name,
          description: description,
          courseId: courseId,
        ));
    
    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
    } else {
      await refresh();
    }
  }

  // ✅ CORREGIDO: Ahora acepta courseId obligatorio como en el antiguo
  Future<void> updateClassroom({
    required int id,
    required String name,
    required String description,
    required int courseId,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await AsyncValue.guard(() => _repo.updateClassroom(
          id: id,
          name: name,
          description: description,
          courseId: courseId,
        ));

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
    } else {
      await refresh();
    }
  }

  Future<void> deleteClassroom(int id) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repo.deleteClassroom(id));
    
    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
    } else {
      await refresh();
    }
  }

  // ✅ NUEVO: Método getEnrollments como en el antiguo
  Future<List<ClassroomEnrollment>> getEnrollments(int classroomId) async {
    try {
      return await _repo.fetchEnrollments(classroomId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeStudent({
    required int classroomId,
    required int studentId,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _repo.removeStudent(
          classroomId: classroomId,
          studentId: studentId,
        ));

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
    } else {
      await refresh();
    }
  }
}

final classroomNotifierProvider =
    StateNotifierProvider<ClassroomNotifier, AsyncValue<List<ClassroomModel>>>((ref) {
  return ClassroomNotifier(ref.read(teacherRepositoryProvider));
});

// ✅ NUEVO: Provider para enrollments (como en el antiguo)
final enrollmentsProvider = FutureProvider.family<List<ClassroomEnrollment>, int>((ref, classroomId) {
  final notifier = ref.read(classroomNotifierProvider.notifier);
  return notifier.getEnrollments(classroomId);
});