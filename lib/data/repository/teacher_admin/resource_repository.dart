// lib/data/repository/teacher_admin/resource_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/resource_model.dart';

class ResourceRepository extends BaseRepository {
  // 📥 Obtener TODOS los recursos
  Future<List<TeacherResource>> fetchAllResources() {
    return getList<TeacherResource>(
      'resources/',
      (json) => TeacherResource.fromJson(json),
      message: 'Error al cargar recursos',
    );
  }

  // 📥 Obtener recurso por ID
  Future<TeacherResource> getResourceById(int id) {
    return getOne<TeacherResource>(
      'resources/$id/',
      (json) => TeacherResource.fromJson(json),
      message: 'Error al obtener recurso',
    );
  }

  // ➕ Crear recurso
  Future<TeacherResource> createResource(Map<String, dynamic> resourceData) {
    return createOne<TeacherResource>(
      'resources/',
      (json) => TeacherResource.fromJson(json),
      data: resourceData,
      message: 'Error al subir el recurso',
    );
  }

  // ✏️ Actualizar recurso
  Future<TeacherResource> updateResource(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch('resources/$id/', data: data);
      return TeacherResource.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar recurso', e.response?.statusCode, e);
    }
  }

  // 🗑️ Eliminar recurso
  Future<void> deleteResource(int id) {
    return executeRequest(
      () async => await dio.delete('resources/$id/'),
      message: 'Error al eliminar recurso',
    );
  }
}