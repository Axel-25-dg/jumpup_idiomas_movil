// lib/data/repository/teacher_admin/resource_repository.dart
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';

class ResourceRepository extends BaseRepository {
  Future<TeacherResource> createResource(Map<String, dynamic> resourceData) {
    return createOne<TeacherResource>(
      'resources/',
      (json) => TeacherResource.fromJson(json),
      data: resourceData,
      message: 'Error al subir el recurso',
    );
  }
}