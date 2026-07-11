// lib/data/repository/teacher_admin/report_repository.dart
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';

class ReportRepository extends BaseRepository {
  Future<List<Report>> fetchReports() {
    return getList<Report>(
      'reports/',
      (json) => Report.fromJson(json),
      message: 'Error al cargar reportes',
    );
  }

  Future<void> updateReport(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('reports/$id/', data: data),
      message: 'Error al actualizar reporte',
    );
  }
}