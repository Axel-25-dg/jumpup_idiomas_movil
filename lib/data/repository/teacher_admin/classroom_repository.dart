// lib/data/repository/teacher_admin/classroom_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/classroom_enrollment_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_join_request_model.dart';

Map<String, dynamic> buildClassroomPayload({
  required String name,
  required String description,
  required int courseId,
  bool isActive = true,
}) {
  return {
    'name': name,
    'description': description,
    'course': courseId,
    'is_active': isActive,
  };
}

class ClassroomRepository extends BaseRepository {
  ClassroomRepository({Dio? dio}) : super(dio);
  // 📥 Obtener todas las aulas
  Future<List<ClassroomModel>> fetchAllClassrooms() {
    return getList<ClassroomModel>(
      'classrooms/',
      (json) => ClassroomModel.fromJson(json),
      message: 'Error al cargar aulas',
    ).then((list) {
      try {
        // ignore: avoid_print
        print('ClassroomRepository.fetchAllClassrooms: returned_count=${list.length}');
        // ignore: avoid_print
        print('ClassroomRepository.fetchAllClassrooms: ids=${list.map((e) => e.id).toList()}');
        // Print isActive for each returned classroom for debugging
        // ignore: avoid_print
        print('ClassroomRepository.fetchAllClassrooms: active_flags=${list.map((e) => {"id": e.id, "isActive": e.isActive}).toList()}');
      } catch (_) {}
      final filtered = list.where((c) => c.isActive).toList();
      // ignore: avoid_print
      print('ClassroomRepository.fetchAllClassrooms: filtered_count=${filtered.length}');
      return filtered;
    });
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
      data: buildClassroomPayload(
        name: name,
        description: description,
        courseId: courseId,
        isActive: true,
      ),
      message: 'Error al crear aula',
    );
  }

  // ✏️ Editar aula
  Future<void> updateClassroom(int id, Map<String, dynamic> data) {
    final payload = {
      ...data,
      if (!data.containsKey('course') && data.containsKey('course_id'))
        'course': data['course_id'],
      if (!data.containsKey('course') && data.containsKey('courseId'))
        'course': data['courseId'],
      if (!data.containsKey('is_active')) 'is_active': true,
    };

    return executeRequest(
      () async => await dio.patch('classrooms/$id/', data: payload),
      message: 'Error al actualizar aula',
    );
  }

  // 🗑️ Eliminar aula - ✅ NUEVO
  Future<void> deleteClassroom(int id) {
    return executeRequest(() async {
      // Log the request for debugging when running locally
      try {
        // ignore: avoid_print
        print('ClassroomRepository.deleteClassroom: deleting id=$id');
        final res = await dio.delete('classrooms/$id/');
        // ignore: avoid_print
        print('ClassroomRepository.deleteClassroom: response status=${res.statusCode}');
        return res;
      } catch (e) {
        // ignore: avoid_print
        print('ClassroomRepository.deleteClassroom: error=$e');
        rethrow;
      }
    }, message: 'Error al eliminar aula');
  }

  // 📋 Obtener alumnos de un aula
  Future<List<ClassroomEnrollment>> fetchEnrollments(int classroomId) {
    return handleRequest<List<ClassroomEnrollment>>(() async {
      // El backend expone las inscripciones dentro del detalle del aula,
      // no como el recurso independiente `classroom-enrollments/`.
      final response = await dio.get<dynamic>('classrooms/$classroomId/');
      final data = response.data;
      final enrollments = data is Map && data['enrollments'] is List
          ? data['enrollments'] as List
          : const <dynamic>[];
      return enrollments
          .whereType<Map>()
          .map((json) => ClassroomEnrollment.fromJson(
              Map<String, dynamic>.from(json)))
          .toList();
    }, message: 'Error al cargar alumnos');
  }

  // 🗑️ Eliminar alumno
  Future<void> removeStudent({
    required int classroomId,
    required int studentId,
  }) {
    return executeRequest(
      () async => await dio.post(
        'classrooms/$classroomId/remove-student/',
        data: {'student_id': studentId},
      ),
      message: 'Error al dar de baja al alumno',
    );
  }

  // 📥 Obtener solicitudes de ingreso pendientes
  Future<List<ClassroomJoinRequest>> fetchJoinRequests(int classroomId) {
    return getList<ClassroomJoinRequest>(
      'classrooms/$classroomId/requests/',
      (json) => ClassroomJoinRequest.fromJson(json),
      message: 'Error al cargar solicitudes de ingreso',
    );
  }

  // ✓ Aprobar solicitud de ingreso
  Future<void> approveJoinRequest({
    required int classroomId,
    required int requestId,
  }) {
    return executeRequest(
      () async => await dio.post(
        'classrooms/$classroomId/approve-request/',
        data: {'request_id': requestId},
      ),
      message: 'Error al aprobar la solicitud de ingreso',
    );
  }

  // ✗ Rechazar solicitud de ingreso
  Future<void> rejectJoinRequest({
    required int classroomId,
    required int requestId,
  }) {
    return executeRequest(
      () async => await dio.post(
        'classrooms/$classroomId/reject-request/',
        data: {'request_id': requestId},
      ),
      message: 'Error al rechazar la solicitud de ingreso',
    );
  }

  // ➕ Estudiante solicita ingresar a aula
  Future<void> requestJoin({
    required int classroomId,
    String? message,
  }) {
    return executeRequest(
      () async => await dio.post(
        'classrooms/request-join/',
        data: {
          'classroom_id': classroomId,
          if (message != null) 'message': message,
        },
      ),
      message: 'Error al solicitar el ingreso al aula',
    );
  }
}
