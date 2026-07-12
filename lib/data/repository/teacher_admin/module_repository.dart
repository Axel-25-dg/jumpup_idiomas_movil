// lib/data/repository/teacher_admin/module_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

class ModuleRepository extends BaseRepository {
  Future<List<ModuleModel>> getModulesByCourse(int courseId) {
    return getList<ModuleModel>(
      'modules/',
      (json) => ModuleModel.fromJson(json),
      queryParameters: {'course_id': courseId},
      message: 'Error al cargar módulos',
    );
  }

  Future<void> createModule(Map<String, dynamic> data) async {
    try {
      await dio.post('modules/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al crear módulo', e.response?.statusCode, e);
    }
  }

  Future<void> updateModule(int id, Map<String, dynamic> data) async {
    try {
      await dio.patch('modules/$id/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar módulo', e.response?.statusCode, e);
    }
  }

  Future<void> deleteModule(int id) async {
    try {
      await dio.delete('modules/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar módulo', e.response?.statusCode, e);
    }
  }
}