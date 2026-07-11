// import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';

/// Contrato para la gestión de recursos educativos (PDFs, audios, videos).
abstract class ResourceRepositoryBase {
  /// Devuelve todos los recursos subidos por el profesor.
  Future<List<TeacherResource>> fetchResources();

  /// Publica un nuevo recurso vinculado a un curso.
  Future<TeacherResource> createResource(Map<String, dynamic> data);
}
