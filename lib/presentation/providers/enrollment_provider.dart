import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';

/// Listado de inscritos en un aula específica
final enrollmentsProvider =
    FutureProvider.family<List<ClassroomEnrollment>, int>((ref, classroomId) {
  final repo = ref.read(teacherRepositoryProvider);
  return repo.fetchEnrollments(classroomId);
});

/// Notificador para acciones sobre inscripciones (eliminar estudiante)
class EnrollmentNotifier extends StateNotifier<AsyncValue<void>> {
  EnrollmentNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> removeStudent(int enrollmentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = _ref.read(teacherRepositoryProvider);
      await repo.removeStudent(enrollmentId);
    });
  }
}

final enrollmentNotifierProvider =
    StateNotifierProvider<EnrollmentNotifier, AsyncValue<void>>((ref) {
  return EnrollmentNotifier(ref);
});
