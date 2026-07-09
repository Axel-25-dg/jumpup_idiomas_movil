import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/virtual_class_models.dart';
import '../auth/services/virtual_class_service.dart';

final virtualClassServiceProvider = Provider<VirtualClassService>((ref) {
  return const VirtualClassService();
});

final virtualClassesProvider = FutureProvider<List<VirtualClassModel>>((ref) async {
  return ref.watch(virtualClassServiceProvider).getVirtualClasses();
});

final certificatesProvider = FutureProvider<List<CertificateModel>>((ref) async {
  return ref.watch(virtualClassServiceProvider).getCertificates();
});

/// Estado del registro a una clase
enum JoinClassStatus { idle, loading, success, failure }

class JoinClassNotifier extends StateNotifier<JoinClassStatus> {
  JoinClassNotifier(this._service) : super(JoinClassStatus.idle);
  final VirtualClassService _service;
  String? errorMessage;

  Future<void> joinClass(int classId) async {
    state = JoinClassStatus.loading;
    errorMessage = null;
    try {
      await _service.joinVirtualClass(classId);
      state = JoinClassStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      state = JoinClassStatus.failure;
    }
  }

  void reset() {
    state = JoinClassStatus.idle;
    errorMessage = null;
  }
}

final joinClassNotifierProvider =
    StateNotifierProvider<JoinClassNotifier, JoinClassStatus>((ref) {
  return JoinClassNotifier(ref.watch(virtualClassServiceProvider));
});

/// Provider para las clases/aulas en las que está inscrito el estudiante
final classroomEnrollmentsProvider =
    FutureProvider<List<VirtualClassModel>>((ref) async {
  return ref.watch(virtualClassServiceProvider).getClassroomEnrollments();
});

/// Estado de la inscripción a un aula por código
enum ClassroomEnrollStatus { idle, loading, success, failure }

class ClassroomEnrollNotifier extends StateNotifier<ClassroomEnrollStatus> {
  ClassroomEnrollNotifier(this._service) : super(ClassroomEnrollStatus.idle);
  final VirtualClassService _service;
  String? errorMessage;

  Future<bool> enrollByCode(String code) async {
    state = ClassroomEnrollStatus.loading;
    errorMessage = null;
    try {
      await _service.enrollInClassroom(code);
      state = ClassroomEnrollStatus.success;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      state = ClassroomEnrollStatus.failure;
      return false;
    }
  }

  void reset() {
    state = ClassroomEnrollStatus.idle;
    errorMessage = null;
  }
}

final classroomEnrollNotifierProvider =
    StateNotifierProvider<ClassroomEnrollNotifier, ClassroomEnrollStatus>((ref) {
  return ClassroomEnrollNotifier(ref.watch(virtualClassServiceProvider));
});
