// lib/presentation/providers/report_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/report_repository.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';

final reportNotifierProvider = StateNotifierProvider<ReportNotifier, AsyncValue<List<Report>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).reports;
  return ReportNotifier(repository);
});

class ReportNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  final ReportRepository _repository;

  ReportNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    state = const AsyncValue.loading();
    try {
      final reports = await _repository.fetchReports();
      state = AsyncValue.data(reports);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateReport(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateReport(id, data);
      await fetchReports();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchReports();
  }
}

// Provider de solo lectura
final reportsProvider = FutureProvider<List<Report>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).reports;
  return repository.fetchReports();
});