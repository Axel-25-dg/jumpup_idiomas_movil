import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';

class ReportRepository extends BaseRepository {
  // 📥 Obtener todos los reportes
  Future<List<Report>> fetchReports() {
    return getList<Report>(
      'reports/',
      (json) => Report.fromJson(json),
      message: 'Error al cargar reportes',
    );
  }

  // ✏️ Actualizar reporte
  Future<void> updateReport(int id, Map<String, dynamic> data) async {
    try {
      await dio.patch('reports/$id/', data: data);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar reporte', e.response?.statusCode, e);
    }
  }

  // 🗑️ Eliminar reporte (opcional)
  Future<void> deleteReport(int id) async {
    try {
      await dio.delete('reports/$id/');
    } on DioException catch (e) {
      throw ApiException('Error al eliminar reporte', e.response?.statusCode, e);
    }
  }
}