// lib/presentation/providers/module_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/module_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';


final moduleNotifierProvider = StateNotifierProvider<ModuleNotifier, AsyncValue<List<ModuleModel>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).modules;
  return ModuleNotifier(repository);
});

class ModuleNotifier extends StateNotifier<AsyncValue<List<ModuleModel>>> {
  final ModuleRepository _repository;

  ModuleNotifier(this._repository) : super(const AsyncValue.loading()) {
    // ✅ Cargar TODOS los módulos al iniciar
    fetchAllModules();
  }

  // 📥 Obtener TODOS los módulos
  Future<void> fetchAllModules() async {
    state = const AsyncValue.loading();
    try {
      final modules = await _repository.fetchAllModules();
      state = AsyncValue.data(modules);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 📥 Obtener módulos por curso
  Future<void> getModulesByCourse(int courseId) async {
    state = const AsyncValue.loading();
    try {
      final modules = await _repository.getModulesByCourse(courseId);
      state = AsyncValue.data(modules);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ➕ Crear módulo
  Future<void> addModule(Map<String, dynamic> data) async {
    try {
      await _repository.createModule(data);
      await fetchAllModules(); // ✅ Recargar TODOS
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ✏️ Actualizar módulo
  Future<void> updateModule(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateModule(id, data);
      await fetchAllModules(); // ✅ Recargar TODOS
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🗑️ Eliminar módulo
  Future<void> deleteModule(int id, int courseId) async {
    try {
      await _repository.deleteModule(id);
      await fetchAllModules(); // ✅ Recargar TODOS
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🔄 Refrescar (recarga TODOS)
  Future<void> refresh() async {
    await fetchAllModules();
  }
}

// Provider con parámetro para obtener módulos por curso
final modulesByCourseProvider = FutureProvider.family<List<ModuleModel>, int>((ref, courseId) {
  final repository = ref.watch(teacherRepositoryProvider).modules;
  return repository.getModulesByCourse(courseId);
});