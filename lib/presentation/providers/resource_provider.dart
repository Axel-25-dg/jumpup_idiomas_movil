// lib/presentation/providers/resource_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/resource_repository.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final resourceNotifierProvider = StateNotifierProvider<ResourceNotifier, AsyncValue<TeacherResource?>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).resources;
  return ResourceNotifier(repository);
});

final resourceUploadProvider = resourceNotifierProvider;

class ResourceNotifier extends StateNotifier<AsyncValue<TeacherResource?>> {
  final ResourceRepository _repository;

  ResourceNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> uploadResource(Map<String, dynamic> resourceData) async {
    state = const AsyncValue.loading();
    try {
      final resource = await _repository.createResource(resourceData);
      state = AsyncValue.data(resource);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> create({
    required String title,
    required int courseId,
    int? lessonId,
    required String fileUrl,
    String resourceType = 'document',
    String description = '',
    bool isPublic = true,
    String? filePath,
  }) async {
    await uploadResource({
      'title': title,
      'course': courseId,
      if (lessonId != null) 'lesson': lessonId,
      'file_url': fileUrl,
      'resource_type': resourceType,
      'description': description,
      'is_public': isPublic,
      if (filePath != null) 'file_path': filePath,
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final resourcesListProvider = FutureProvider<List<TeacherResource>>((ref) async {
  final repository = ref.watch(teacherRepositoryProvider).resources;
  return repository.fetchResources();
});

final resourceManagerProvider = StateNotifierProvider<ResourceManagerNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).resources;
  return ResourceManagerNotifier(repository, ref);
});

class ResourceManagerNotifier extends StateNotifier<AsyncValue<void>> {
  ResourceManagerNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  final ResourceRepository _repository;
  final Ref _ref;

  Future<bool> updateResource({
    required int resourceId,
    required String title,
    required String description,
    required String fileUrl,
    required String resourceType,
    required bool isPublic,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateResource(resourceId, {
        'title': title,
        'description': description,
        'file_url': fileUrl,
        'resource_type': resourceType,
        'is_public': isPublic,
      });
      _ref.invalidate(resourcesListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> deleteResource(int resourceId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteResource(resourceId);
      _ref.invalidate(resourcesListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

