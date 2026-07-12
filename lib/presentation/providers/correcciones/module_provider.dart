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

  ModuleNotifier(this._repository) : super(const AsyncValue.loading());

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
      final courseId = data['course_id'] as int;
      await getModulesByCourse(courseId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ✏️ Actualizar módulo
  Future<void> updateModule(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateModule(id, data);
      final courseId = data['course_id'] as int;
      await getModulesByCourse(courseId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🗑️ Eliminar módulo
  Future<void> deleteModule(int id, int courseId) async {
    try {
      await _repository.deleteModule(id);
      await getModulesByCourse(courseId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🔄 Refrescar
  Future<void> refresh(int courseId) async {
    await getModulesByCourse(courseId);
  }
}

// Provider con parámetro para obtener módulos por curso
final modulesByCourseProvider = FutureProvider.family<List<ModuleModel>, int>((ref, courseId) {
  final repository = ref.watch(teacherRepositoryProvider).modules;
  return repository.getModulesByCourse(courseId);
});