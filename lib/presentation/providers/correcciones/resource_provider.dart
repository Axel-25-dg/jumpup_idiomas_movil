// lib/presentation/providers/resource_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/resource_repository.dart';
import 'package:jumpup_app/domain/model/resource_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';

final resourceNotifierProvider = StateNotifierProvider<ResourceNotifier, AsyncValue<List<TeacherResource>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).resources;
  return ResourceNotifier(repository);
});

class ResourceNotifier extends StateNotifier<AsyncValue<List<TeacherResource>>> {
  final ResourceRepository _repository;

  ResourceNotifier(this._repository) : super(const AsyncValue.data([])) {
    fetchAllResources();
  }

  // 📥 Obtener TODOS los recursos
  Future<void> fetchAllResources() async {
    state = const AsyncValue.loading();
    try {
      final resources = await _repository.fetchAllResources();
      state = AsyncValue.data(resources);
    } catch (e) {
      state = AsyncValue.data([]);
    }
  }

  // ➕ Crear recurso
  Future<void> uploadResource(Map<String, dynamic> resourceData) async {
    try {
      await _repository.createResource(resourceData);
      await fetchAllResources();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ✏️ Actualizar recurso
  Future<void> updateResource(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateResource(id, data);
      await fetchAllResources();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🗑️ Eliminar recurso
  Future<void> deleteResource(int id) async {
    try {
      await _repository.deleteResource(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((r) => r.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🔄 Refrescar
  Future<void> refresh() async {
    await fetchAllResources();
  }
}