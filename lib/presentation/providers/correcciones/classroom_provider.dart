// lib/presentation/providers/classroom_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/classroom_repository.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';

final classroomNotifierProvider = StateNotifierProvider<ClassroomNotifier, AsyncValue<List<ClassroomModel>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).classrooms;
  return ClassroomNotifier(repository);
});

class ClassroomNotifier extends StateNotifier<AsyncValue<List<ClassroomModel>>> {
  final ClassroomRepository _repository;

  ClassroomNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchAllClassrooms();
  }

  // 📥 Obtener todas las aulas
  Future<void> fetchAllClassrooms() async {
    state = const AsyncValue.loading();
    try {
      final classrooms = await _repository.fetchAllClassrooms();
      state = AsyncValue.data(classrooms);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ➕ Crear aula
  Future<void> addClassroom({
    required String name,
    required String description,
    required int courseId,
  }) async {
    try {
      await _repository.createClassroom(
        name: name,
        description: description,
        courseId: courseId,
      );
      await fetchAllClassrooms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ✏️ Editar aula - ✅ NUEVO
  Future<void> updateClassroom({
    required int id,
    required String name,
    required String description,
  }) async {
    try {
      await _repository.updateClassroom(id, {
        'name': name,
        'description': description,
      });
      await fetchAllClassrooms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🗑️ Eliminar aula - ✅ NUEVO
  Future<void> deleteClassroom(int id) async {
    try {
      await _repository.deleteClassroom(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((c) => c.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 📋 Obtener alumnos de un aula
  Future<List<ClassroomEnrollment>> getEnrollments(int classroomId) async {
    try {
      return await _repository.fetchEnrollments(classroomId);
    } catch (e) {
      rethrow;
    }
  }

  // 🗑️ Eliminar alumno
  Future<void> removeStudent(int enrollmentId) async {
    try {
      await _repository.removeStudent(enrollmentId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🔄 Refrescar
  Future<void> refresh() async {
    await fetchAllClassrooms();
  }
}

// Providers con parámetros
final classroomsProvider = FutureProvider<List<ClassroomModel>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).classrooms;
  return repository.fetchAllClassrooms();
});

final enrollmentsProvider = FutureProvider.family<List<ClassroomEnrollment>, int>((ref, classroomId) {
  final repository = ref.watch(teacherRepositoryProvider).classrooms;
  return repository.fetchEnrollments(classroomId);
});