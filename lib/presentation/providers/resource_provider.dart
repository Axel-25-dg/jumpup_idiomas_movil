import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';

final teacherRepositoryProvider =
    Provider<TeacherRepository>((ref) => TeacherRepository());

class ResourceUploadNotifier
    extends StateNotifier<AsyncValue<TeacherResource?>> {
  ResourceUploadNotifier(this._repository) : super(const AsyncValue.data(null));

  final TeacherRepository _repository;

  Future<void> create({
    required String title,
    required int courseId,
    required String fileUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createResource({
          'title': title,
          'course': courseId,
          'file_url': fileUrl,
          'resource_type': 'pdf',
          'is_public': true,
        }));
  }
}

final resourceUploadProvider =
    StateNotifierProvider<ResourceUploadNotifier, AsyncValue<TeacherResource?>>(
        (ref) {
  return ResourceUploadNotifier(ref.read(teacherRepositoryProvider));
});

final resourceLoadingProvider =
    Provider<bool>((ref) => ref.watch(resourceUploadProvider).isLoading);

final resourcesListProvider = FutureProvider<List<TeacherResource>>((ref) async {
  final repo = ref.read(teacherRepositoryProvider);
  return repo.fetchResources();
});
