import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';

/// Contrato para el catálogo público de cursos e idiomas.
abstract class CatalogRepository {
  /// Devuelve la lista de idiomas disponibles.
  Future<List<Language>> fetchLanguages();

  /// Devuelve la lista de cursos. Opcionalmente filtra por idioma.
  Future<List<Course>> fetchCourses({int? languageId});

  /// Crea un nuevo curso (solo admin/teacher).
  Future<void> createCourse(Map<String, dynamic> data);

  /// Elimina un curso por id (solo admin).
  Future<void> deleteCourse(int id);

  /// Crea un módulo dentro de un curso.
  Future<void> createModule(Map<String, dynamic> data);

  /// Devuelve los módulos de un curso específico.
  Future<List<Map<String, dynamic>>> fetchModulesForCourse(int courseId);

  /// Crea una lección dentro de un módulo.
  Future<void> createLesson(Map<String, dynamic> data);
}
