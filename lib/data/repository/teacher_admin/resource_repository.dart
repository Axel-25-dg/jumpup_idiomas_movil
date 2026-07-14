// lib/data/repository/teacher_admin/resource_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/resource_model.dart';

class ResourceRepository extends BaseRepository {
  ResourceRepository({Dio? dio}) : super(dio);

  Future<TeacherResource> createResource(Map<String, dynamic> resourceData) {
    if (resourceData['file_path'] != null) {
      return handleRequest<TeacherResource>(() async {
        final filePath = resourceData['file_path'] as String;
        final formDataMap = Map<String, dynamic>.from(resourceData);
        formDataMap.remove('file_path');
        
        if (formDataMap['file_url'] == 'local-file') {
          formDataMap.remove('file_url');
        }

        final file = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        );
        formDataMap['file'] = file;
        
        final file2 = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        );
        formDataMap['image'] = file2;

        final formData = FormData.fromMap(formDataMap);
        final response = await dio.post<dynamic>('resources/', data: formData);
        return TeacherResource.fromJson(response.data as Map<String, dynamic>);
      }, message: 'Error al subir el recurso');
    }
    return createOne<TeacherResource>(
      'resources/',
      (json) => TeacherResource.fromJson(json),
      data: resourceData,
      message: 'Error al subir el recurso',
    );
  }

  Future<TeacherResource> updateResource(int resourceId, Map<String, dynamic> resourceData) {
    return handleRequest<TeacherResource>(() async {
      final response = await dio.patch<Map<String, dynamic>>(
        'resources/$resourceId/',
        data: resourceData,
      );
      return TeacherResource.fromJson(response.data!);
    }, message: 'Error al actualizar el recurso');
  }

  Future<void> deleteResource(int resourceId) {
    return handleRequest<void>(() async {
      await dio.delete('resources/$resourceId/');
    }, message: 'Error al eliminar el recurso');
  }

  Future<List<TeacherResource>> fetchResources() {
    return getList<TeacherResource>(
      'resources/',
      (json) => TeacherResource.fromJson(json),
      message: 'Error al obtener los recursos',
    );
  }
}