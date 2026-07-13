// lib/presentation/providers/module_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/module_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final moduleNotifierProvider = StateNotifierProvider<ModuleNotifier, AsyncValue<List<ModuleModel>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).modules;
  return ModuleNotifier(repository);
});

class ModuleNotifier extends StateNotifier<AsyncValue<List<ModuleModel>>> {
  final ModuleRepository _repository;

  ModuleNotifier(this._repository) : super(const AsyncValue.data([]));

  // Obtener TODOS los modulos
  Future<void> fetchAllModules() async {
    state = const AsyncValue.loading();
    try {
      final modules = await _repository.getAllModules();
      state = AsyncValue.data(modules);
    } catch (e) {
      state = AsyncValue.data([]);
    }
  }

  // Obtener modulos por curso
  Future<void> getModulesByCourse(int courseId) async {
    state = const AsyncValue.loading();
    try {
      final modules = await _repository.getModulesByCourse(courseId);
      state = AsyncValue.data(modules);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Crear modulo
  Future<void> addModule(Map<String, dynamic> data) async {
    try {
      await _repository.createModule(data);
      final courseId = data['course'] as int;
      await getModulesByCourse(courseId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Eliminar modulo
  Future<void> deleteModule(int id, int courseId) async {
    try {
      await _repository.deleteModule(id);
      await getModulesByCourse(courseId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Refrescar
  Future<void> refresh(int courseId) async {
    await getModulesByCourse(courseId);
  }
}

// Provider con parametro para obtener modulos por curso
final modulesByCourseProvider = FutureProvider.family<List<ModuleModel>, int>((ref, courseId) {
  final repository = ref.watch(teacherRepositoryProvider).modules;
  return repository.getModulesByCourse(courseId);
});