import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';

/// Contrato para la gestión de aulas virtuales.
abstract class ClassroomRepositoryBase {
  /// Devuelve todas las aulas del profesor autenticado.
  Future<List<ClassroomModel>> fetchAllClassrooms();

  /// Crea una nueva aula virtual.
  Future<ClassroomModel> createClassroom({
    required String name,
    required String description,
    required int courseId,
  });

  /// Actualiza los datos de un aula existente.
  Future<ClassroomModel> updateClassroom({
    required int id,
    required String name,
    required String description,
    required int courseId,
  });

  /// Elimina un aula por id.
  Future<void> deleteClassroom(int id);

  /// Devuelve los alumnos inscritos en un aula.
  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId);

  /// Retira a un estudiante de un aula.
  Future<void> removeStudent(int enrollmentId);
}
