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

  Future<void> updateClassroom({
    required int id,
    required String name,
    required String description,
    int? courseId, // Optional in UI call sometimes, but TeacherRepository might need it
  }) async {
    state = const AsyncValue.loading();
    // In classrooms_screen.dart, courseId might not be passed if we only edit name/desc
    // but TeacherRepository.updateClassroom requires it. 
    // We should probably fetch the current classroom first or change the repo to handle partial updates.
    // For now, let's assume we need to pass a courseId. 
    // The UI currently passes it if it can.
    
    final result = await AsyncValue.guard(() async {
      // If courseId is null, we might have a problem if repo requires it.
      // Let's check TeacherRepository.updateClassroom signature.
      // It says: required int courseId.
      
      // We'll try to find the current classroom to get its courseId if not provided.
      int finalCourseId = courseId ?? 0;
      if (courseId == null) {
        final currentClassrooms = state.valueOrNull ?? [];
        final classroomFound = currentClassrooms.where((c) => c.id == id);
        if (classroomFound.isNotEmpty) {
           finalCourseId = classroomFound.first.courseId ?? 0;
        }
      }

      return await _repo.updateClassroom(
        id: id,
        name: name,
        description: description,
        courseId: finalCourseId,
      );
    });

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

  Future<void> removeStudent(int classroomId, int studentId) async {
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
