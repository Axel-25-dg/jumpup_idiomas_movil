import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

/// Estadísticas globales del panel de administración
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final repo = ref.read(teacherRepositoryProvider);
  return repo.getAdminStats();
});
