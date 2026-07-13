import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/data/repository/auth/virtual_class_repository_impl.dart';

final virtualClassServiceProvider = Provider<VirtualClassRepositoryImpl>((ref) {
  return const VirtualClassRepositoryImpl();
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
  final VirtualClassRepositoryImpl _service;
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
