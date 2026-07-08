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
