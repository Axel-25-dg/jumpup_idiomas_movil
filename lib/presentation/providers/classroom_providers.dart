import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/data/repository/auth/classroom_service.dart';

final classroomServiceProvider = Provider<ClassroomService>((ref) {
  return const ClassroomService();
});

// ── Mis aulas virtuales ─────────────────────────────────────────────────────

final myClassroomsProvider = FutureProvider<List<ClassroomModel>>((ref) async {
  return ref.watch(classroomServiceProvider).getMyClassrooms();
});

// ── Sesiones en vivo ────────────────────────────────────────────────────────

final classroomLiveSessionsProvider =
    FutureProvider<List<VirtualClassModel>>((ref) async {
  return ref.watch(classroomServiceProvider).getLiveSessions();
});

// ── Certificados ────────────────────────────────────────────────────────────

final studentCertificatesProvider =
    FutureProvider<List<CertificateModel>>((ref) async {
  return ref.watch(classroomServiceProvider).getCertificates();
});

// ── Notifier: Unirse por código ─────────────────────────────────────────────

enum JoinClassroomStatus { idle, loading, success, failure }

class JoinClassroomNotifier extends StateNotifier<JoinClassroomStatus> {
  JoinClassroomNotifier(this._service) : super(JoinClassroomStatus.idle);

  final ClassroomService _service;
  String? errorMessage;
  ClassroomModel? joinedClassroom;

  Future<bool> joinByCode(String code) async {
    state = JoinClassroomStatus.loading;
    errorMessage = null;
    joinedClassroom = null;
    try {
      final classroom = await _service.joinByCode(code);
      joinedClassroom = classroom;
      state = JoinClassroomStatus.success;
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      state = JoinClassroomStatus.failure;
      return false;
    }
  }

  void reset() {
    state = JoinClassroomStatus.idle;
    errorMessage = null;
    joinedClassroom = null;
  }
}

final joinClassroomProvider =
    StateNotifierProvider<JoinClassroomNotifier, JoinClassroomStatus>((ref) {
  return JoinClassroomNotifier(ref.watch(classroomServiceProvider));
});
