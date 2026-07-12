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
    required String fileUrl,
  }) async {
    await uploadResource({
      'title': title,
      'course_id': courseId,
      'file_url': fileUrl,
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

