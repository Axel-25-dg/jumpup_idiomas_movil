import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

/// Servicio para los endpoints de Clases Virtuales y Certificados.
///
/// Endpoints:
/// - GET  /api/virtual-classes/          — Clases virtuales programadas/en curso
/// - POST /api/virtual-classes/{id}/join — Unirse a una clase virtual
/// - GET  /api/certificates/             — Certificados obtenidos por el usuario
/// - GET  /api/certificates/{id}/pdf     — Descargar PDF del certificado
class VirtualClassService extends BaseRepository {
  const VirtualClassService();

  // ─── Virtual Classes ────────────────────────────────────────────────────────

  /// Obtiene la lista de clases virtuales disponibles.
  Future<List<VirtualClassModel>> getVirtualClasses() async {
    return handleRequest(() async {
      // TODO: final response = await dio.get('/api/virtual-classes/');
      return _mockVirtualClasses();
    }, message: 'No se pudieron cargar las clases virtuales');
  }

  /// Registra al usuario para unirse a una clase virtual.
  Future<VirtualClassRegistrationModel> joinVirtualClass(int classId) async {
    return handleRequest(() async {
      // TODO: final response = await dio.post('/api/virtual-classes/$classId/join/');
      final vClass = _mockVirtualClasses().firstWhere((c) => c.id == classId);
      if (vClass.isFull) {
        throw Exception('La clase ya está llena');
      }
      return VirtualClassRegistrationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        virtualClass: vClass,
        registeredAt: DateTime.now(),
        status: 'registered',
      );
    }, message: 'No te pudiste unir a la clase virtual');
  }

  // ─── Certificates ───────────────────────────────────────────────────────────

  /// Obtiene la lista de certificados del usuario.
  Future<List<CertificateModel>> getCertificates() async {
    return handleRequest(() async {
      // TODO: final response = await dio.get('/api/certificates/');
      return _mockCertificates();
    }, message: 'No se pudieron cargar los certificados');
  }

  /// Obtiene las aulas/clases en las que está inscrito el estudiante.
  Future<List<VirtualClassModel>> getClassroomEnrollments() async {
    return handleRequest(() async {
      // TODO: final response = await dio.get('/api/classroom-enrollments/');
      return _mockVirtualClasses().sublist(0, 1);
    }, message: 'No se pudieron obtener tus inscripciones');
  }

  /// Inscribe al estudiante en un aula virtual mediante un código de 6 dígitos.
  Future<VirtualClassRegistrationModel> enrollInClassroom(String code) async {
    return handleRequest(() async {
      // TODO: final response = await dio.post('/api/classroom-enrollments/', data: {'code': code});
      if (code.length != 6) {
        throw Exception('El código de inscripción debe tener 6 dígitos');
      }
      final vClass = _mockVirtualClasses()[2]; // Francés para Viajeros
      return VirtualClassRegistrationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        virtualClass: vClass,
        registeredAt: DateTime.now(),
        status: 'registered',
      );
    }, message: 'No se pudo completar la inscripción');
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────

  List<VirtualClassModel> _mockVirtualClasses() => [
        VirtualClassModel(
          id: 1,
          title: 'Conversación A1 - Saludos',
          description: 'Práctica de saludos y presentaciones básicas en inglés.',
          instructorName: 'Prof. Ana García',
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          durationMinutes: 60,
          meetingUrl: 'https://zoom.us/j/123456789',
          maxParticipants: 10,
          currentParticipants: 8,
          status: 'scheduled',
        ),
        VirtualClassModel(
          id: 2,
          title: 'Gramática B1 - Condicionales',
          description: 'Repaso intensivo de First y Second Conditional.',
          instructorName: 'Prof. John Smith',
          scheduledAt: DateTime.now().subtract(const Duration(minutes: 10)),
          durationMinutes: 90,
          meetingUrl: 'https://zoom.us/j/987654321',
          maxParticipants: 20,
          currentParticipants: 20,
          status: 'ongoing',
        ),
        VirtualClassModel(
          id: 3,
          title: 'Francés para Viajeros',
          description: 'Vocabulario útil para sobrevivir en París.',
          instructorName: 'Prof. Marie Curie',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          durationMinutes: 45,
          maxParticipants: 15,
          currentParticipants: 2,
          status: 'scheduled',
        ),
      ];

  List<CertificateModel> _mockCertificates() => [
        CertificateModel(
          id: 1,
          courseName: 'Inglés A1 - Principiantes',
          issueDate: DateTime.now().subtract(const Duration(days: 30)),
          certificateUrl: 'https://jumpup.edu/certs/A1-123.pdf',
          code: 'CERT-A1-123456',
          score: 95.5,
        ),
        CertificateModel(
          id: 2,
          courseName: 'Francés A1 - Débutant',
          issueDate: DateTime.now().subtract(const Duration(days: 5)),
          certificateUrl: 'https://jumpup.edu/certs/FR-456.pdf',
          code: 'CERT-FR-654321',
          score: 100.0,
        ),
      ];
}
