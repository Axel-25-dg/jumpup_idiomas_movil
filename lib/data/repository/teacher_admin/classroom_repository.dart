// lib/data/repository/teacher_admin/classroom_repository.dart
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';

class ClassroomRepository extends BaseRepository {
  // 📥 Obtener todas las aulas
  Future<List<ClassroomModel>> fetchAllClassrooms() {
    return getList<ClassroomModel>(
      'classrooms/',
      (json) => ClassroomModel.fromJson(json),
      message: 'Error al cargar aulas',
    );
  }

  // ➕ Crear aula
  Future<ClassroomModel> createClassroom({
    required String name,
    required String description,
    required int courseId,
  }) {
    return createOne<ClassroomModel>(
      'classrooms/',
      (json) => ClassroomModel.fromJson(json),
      data: {
        'name': name,
        'description': description,
        'course': courseId,
        'is_active': true,
      },
      message: 'Error al crear aula',
    );
  }

  // ✏️ Editar aula - ✅ NUEVO
  Future<void> updateClassroom(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('classrooms/$id/', data: data),
      message: 'Error al actualizar aula',
    );
  }

  // 🗑️ Eliminar aula - ✅ NUEVO
  Future<void> deleteClassroom(int id) {
    return executeRequest(
      () async => await dio.delete('classrooms/$id/'),
      message: 'Error al eliminar aula',
    );
  }

  // 📋 Obtener alumnos de un aula
  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId) {
    return getList<ClassroomEnrollment>(
      'classroom-enrollments/',
      (json) => ClassroomEnrollment.fromJson(json),
      queryParameters: {'classroom': classroomId},
      message: 'Error al cargar alumnos',
    );
  }

  // 🗑️ Eliminar alumno
  Future<void> removeStudent(int enrollmentId) {
    return executeRequest(
      () async => await dio.delete('classroom-enrollments/$enrollmentId/'),
      message: 'Error al dar de baja al alumno',
    );
  }
}