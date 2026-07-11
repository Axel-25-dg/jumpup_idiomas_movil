import 'package:jumpup_app/domain/model/classroom_model.dart';
import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

/// Servicio para Aulas Virtuales (Classroom) y Sesiones en Vivo (LiveSession).
/// Separa claramente los dos recursos del backend:
///   - /api/classrooms/  → Aulas con código de acceso
///   - /api/live-sessions/ → Sesiones de videotutoría en vivo
class ClassroomService extends BaseRepository {
  const ClassroomService();

  // ── Aulas virtuales ─────────────────────────────────────────────────────

  Future<List<ClassroomModel>> getMyClassrooms() async {
    return getList('classrooms/mine/', ClassroomModel.fromJson,
        message: 'No se pudieron cargar tus aulas');
  }

  Future<ClassroomModel> joinByCode(String code) async {
    return handleRequest<ClassroomModel>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        'classrooms/join/',
        data: {'access_code': code},
      );
      // El backend devuelve { classroom: {...} } o directamente {...}
      final data = response.data!;
      final classroomData = data['classroom'] is Map<String, dynamic>
          ? data['classroom'] as Map<String, dynamic>
          : data;
      return ClassroomModel.fromJson(classroomData);
    }, message: 'No se pudo unir al aula. Verifica el código.');
  }

  // ── Sesiones en vivo (LiveSession) ──────────────────────────────────────

  Future<List<VirtualClassModel>> getLiveSessions() async {
    return getList('live-sessions/', VirtualClassModel.fromJson,
        message: 'No se pudieron cargar las sesiones en vivo');
  }

  Future<void> joinLiveSession(int sessionId) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('live-sessions/$sessionId/join/');
    }, message: 'No te pudiste unir a la sesión en vivo');
  }

  // ── Certificados ──────────────────────────────────────────────────────────

  Future<List<CertificateModel>> getCertificates() async {
    return getList('certificates/', CertificateModel.fromJson,
        message: 'No se pudieron cargar los certificados');
  }
}
