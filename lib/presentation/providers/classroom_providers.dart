import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_join_request_model.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/data/repository/auth/classroom_repository_impl.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final classroomServiceProvider = Provider<ClassroomRepositoryImpl>((ref) {
  return const ClassroomRepositoryImpl();
});

// ── Mis aulas virtuales ─────────────────────────────────────────────────────

final myClassroomsProvider = FutureProvider<List<ClassroomModel>>((ref) async {
  return ref.watch(classroomServiceProvider).getMyClassrooms();
});

final classroomsByCourseProvider =
    FutureProvider.family<List<ClassroomModel>, int>((ref, courseId) async {
  return ref.watch(classroomServiceProvider).getClassroomsByCourse(courseId);
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

// ── Notifier: Solicitar ingreso ─────────────────────────────────────────────

class RequestJoinNotifier extends StateNotifier<JoinClassroomStatus> {
  RequestJoinNotifier(this._service) : super(JoinClassroomStatus.idle);

  final ClassroomRepositoryImpl _service;
  String? errorMessage;

  Future<bool> requestJoin(int classroomId, String message) async {
    state = JoinClassroomStatus.loading;
    errorMessage = null;
    try {
      await _service.requestJoin(classroomId, message);
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
  }
}

final requestJoinProvider =
    StateNotifierProvider<RequestJoinNotifier, JoinClassroomStatus>((ref) {
  return RequestJoinNotifier(ref.watch(classroomServiceProvider));
});

class ClassroomJoinRequestsNotifier
    extends StateNotifier<AsyncValue<List<ClassroomJoinRequest>>> {
  ClassroomJoinRequestsNotifier(this._repo, int classroomId)
      : super(const AsyncValue.loading()) {
    loadRequests(classroomId);
  }

  final TeacherRepository _repo;

  Future<void> loadRequests(int classroomId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repo.fetchJoinRequests(classroomId);
    });
  }

  Future<bool> approve(int classroomId, int requestId) async {
    try {
      await _repo.approveJoinRequest(classroomId: classroomId, requestId: requestId);
      await loadRequests(classroomId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reject(int classroomId, int requestId) async {
    try {
      await _repo.rejectJoinRequest(classroomId: classroomId, requestId: requestId);
      await loadRequests(classroomId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final classroomJoinRequestsProvider = StateNotifierProvider.family<
    ClassroomJoinRequestsNotifier, AsyncValue<List<ClassroomJoinRequest>>, int>(
  (ref, classroomId) {
    return ClassroomJoinRequestsNotifier(
      ref.read(teacherRepositoryProvider),
      classroomId,
    );
  },
);

final classroomJoinRequestsProviderFamily =
    FutureProvider.family<List<ClassroomJoinRequest>, int>((ref, classroomId) async {
  final repo = ref.read(teacherRepositoryProvider);
  return repo.fetchJoinRequests(classroomId);
});
