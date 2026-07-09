import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/report_model.dart';

final reportsProvider = StateNotifierProvider<ReportNotifier, AsyncValue<List<Report>>>((ref) {
  return ReportNotifier();
});

class ReportNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  // Nota: Asegúrate de que TeacherRepository esté correctamente inyectado o instanciado
  final _repo = TeacherRepository(); 

  ReportNotifier() : super(const AsyncValue.loading()) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.fetchReports());
  }

  Future<void> updateStatus(int id, String newStatus) async {
    await _repo.updateReport(id, {'status': newStatus});
    await fetchReports();
  }
}