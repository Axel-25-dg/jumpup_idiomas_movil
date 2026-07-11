import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/data/repository/auth/virtual_class_service.dart';
import 'package:jumpup_app/data/repository/auth/classroom_service.dart';

final virtualClassServiceProvider = Provider<VirtualClassService>((ref) {
  return const VirtualClassService();
});

final classroomServiceProvider = Provider<ClassroomService>((ref) {
  return const ClassroomService();
});

final virtualClassesProvider =
    FutureProvider<List<VirtualClassModel>>((ref) async {
  return ref.watch(virtualClassServiceProvider).getVirtualClasses();
});

final certificatesProvider =
    FutureProvider<List<CertificateModel>>((ref) async {
  return ref.watch(virtualClassServiceProvider).getCertificates();
});

enum JoinClassStatus { idle, loading, success, failure }

class JoinClassNotifier extends StateNotifier<JoinClassStatus> {
  JoinClassNotifier(this._service) : super(JoinClassStatus.idle);
  final VirtualClassService _service;
  String? errorMessage;

  Future<VirtualClassRegistrationModel?> joinClass(int classId) async {
    state = JoinClassStatus.loading;
    errorMessage = null;
    try {
      final result = await _service.joinVirtualClass(classId);
      state = JoinClassStatus.success;
      return result;
    } catch (e) {
      errorMessage = e.toString();
      state = JoinClassStatus.failure;
      return null;
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

final myClassroomsProvider =
    FutureProvider<List<ClassroomModel>>((ref) async {
  return ref.watch(classroomServiceProvider).getMyClassrooms();
});

enum ClassroomEnrollStatus { idle, loading, success, failure }

class ClassroomEnrollNotifier extends StateNotifier<ClassroomEnrollStatus> {
  ClassroomEnrollNotifier(this._service) : super(ClassroomEnrollStatus.idle);
  final ClassroomService _service;
  String? errorMessage;

  Future<bool> enrollByCode(String code) async {
    state = ClassroomEnrollStatus.loading;
    errorMessage = null;
    try {
      await _service.joinByCode(code);
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
    StateNotifierProvider<ClassroomEnrollNotifier, ClassroomEnrollStatus>(
        (ref) {
  return ClassroomEnrollNotifier(ref.watch(classroomServiceProvider));
});
