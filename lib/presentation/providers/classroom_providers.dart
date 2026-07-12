import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/data/repository/auth/classroom_repository_impl.dart';

final classroomServiceProvider = Provider<ClassroomRepositoryImpl>((ref) {
  return const ClassroomRepositoryImpl();
});

// ── Mis aulas virtuales ─────────────────────────────────────────────────────

final myClassroomsProvider = FutureProvider<List<ClassroomModel>>((ref) async {
  return ref.watch(classroomServiceProvider).getMyClassrooms();
});

// ── Sesiones en vivo ────────────────────────────────────────────────────────

final classroomLiveSessionsProvider =
    FutureProvider<List<LiveSession>>((ref) async {
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

  final ClassroomRepositoryImpl _service;
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
