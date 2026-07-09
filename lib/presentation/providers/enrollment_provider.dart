import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/enrollment_model.dart';
import 'package:jumpup_app/presentation/providers/resource_provider.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';

/// Provider para la lista de alumnos matriculados en un aula específica.
/// Usamos [family] porque depende del ID del aula ([classroomId]).
/// 
final enrollmentsProvider = FutureProvider.family<List<ClassroomEnrollment>, int>((ref, classroomId) async {
  return ref.read(teacherRepositoryProvider).fetchEnrollments(classroomId);
});

/// Notificador para dar de baja a alumnos
class EnrollmentNotifier extends StateNotifier<AsyncValue<void>> {
  final TeacherRepository _repo;
  EnrollmentNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> removeStudent(int enrollmentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.removeStudent(enrollmentId));
  }
}

final enrollmentNotifierProvider = StateNotifierProvider<EnrollmentNotifier, AsyncValue<void>>((ref) {
  return EnrollmentNotifier(ref.read(teacherRepositoryProvider));
});