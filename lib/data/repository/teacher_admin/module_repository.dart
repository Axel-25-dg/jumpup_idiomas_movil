// lib/data/repository/teacher_admin/module_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

class ModuleRepository extends BaseRepository {
  ModuleRepository({Dio? dio}) : super(dio);
  // Obtener TODOS los modulos
  Future<List<ModuleModel>> getAllModules() {
    return getList<ModuleModel>(
      'modules/',
      (json) => ModuleModel.fromJson(json),
      message: 'Error al cargar modulos',
    );
  }

  // Obtener modulos por curso
  Future<List<ModuleModel>> getModulesByCourse(int courseId) {
    return getList<ModuleModel>(
      'modules/',
      (json) => ModuleModel.fromJson(json),
      queryParameters: {
        'course': courseId,
        'course_id': courseId,
      },
      message: 'Error al cargar módulos',
    );
  }

  // Crear modulo
  Future<void> createModule(Map<String, dynamic> data) async {
    try {
      await dio.post('modules/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al crear modulo', e.response?.statusCode, e);
    }
  }

  // Eliminar modulo
  Future<void> deleteModule(int id) async {
    try {
      await dio.delete('modules/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar modulo', e.response?.statusCode, e);
    }
  }
}